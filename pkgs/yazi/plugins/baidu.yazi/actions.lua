--- Every BaiduPCS-Go operation the plugin exposes, shared by the keymap commands and the panel.
--- @since 26.5.6

local util = require(".util")

local M = {}

--- Prompt for one line of text; nil when cancelled or left empty.
--- @param title string
--- @param value string? pre-filled value
--- @param width integer?
--- @return string?
function M.input(title, value, width)
	local opts = { title = title, pos = { "top-center", y = 3, w = width or 60 } }
	if value and value ~= "" then
		opts.value = value
	end

	local v, event = ya.input(opts)
	if event ~= 1 or not v then
		return nil
	end
	v = v:gsub("^%s+", ""):gsub("%s+$", "")
	return v ~= "" and v or nil
end

--- Ask the user to confirm; `ya.confirm` wants a position and a `ui.Text` body.
--- @param title string
--- @param lines string[]
--- @return boolean
function M.confirm(title, lines)
	local body = {}
	for _, line in ipairs(lines) do
		body[#body + 1] = ui.Line(line)
	end

	return ya.confirm {
		pos = { "center", w = 60, h = #lines + 4 },
		title = title,
		body = ui.Text(body),
	} == true
end

--- @param message string
--- @param argv string[]
--- @return boolean
local function succeeded(message, argv)
	local _, err = util.run(argv)
	if err then
		util.notify(err, "error")
		return false
	end
	util.notify(message)
	return true
end

--- @param list (string?)[]
--- @return string[]
local function compact(list)
	local out = {}
	for _, v in ipairs(list or {}) do
		if v then
			out[#out + 1] = v
		end
	end
	return out
end

--- Upload the selected (or hovered) local entries into a remote directory.
--- @param argv string[]? [remote dir] to skip the prompt
function M.upload(argv)
	local files = util.selected_or_hovered()
	util.trace("upload: files", #files)
	if #files == 0 then
		return util.notify("Nothing selected or hovered", "warn")
	end

	local target = util.remote((argv or {})[1] or M.input("Upload to (remote dir):", util.remembered("upload_dir", "/")))
	if not target then
		return
	end
	util.remember("upload_dir", target)

	-- NOTE: `table.unpack` only expands in the last position of a table constructor, so the
	-- file list is appended entry by entry instead of being spliced into the literal.
	local args = { "upload" }
	for _, f in ipairs(files) do
		args[#args + 1] = f
	end
	args[#args + 1] = target
	util.run_block(args)
end

--- Download remote paths into the local directory yazi is showing.
--- @param argv string[] remote paths
--- @param dest string? local destination, defaults to yazi's cwd
function M.download(argv, dest)
	local paths = {}
	for _, p in ipairs(argv or {}) do
		paths[#paths + 1] = util.remote(p)
	end

	if #paths == 0 then
		local v = M.input("Download from (remote path):", util.remembered("remote_dir", "/"))
		if not v then
			return
		end
		paths[1] = util.remote(v)
	end
	util.remember("remote_dir", util.parent(paths[1]))

	util.run_block(compact({ "download", "--saveto", dest or util.cwd(), table.unpack(paths) }))
end

--- @param argv string[] remote paths to remove
function M.rm(argv)
	local paths = {}
	for _, p in ipairs(argv or {}) do
		paths[#paths + 1] = util.remote(p)
	end
	if #paths == 0 then
		local v = M.input("Remove (remote path):")
		if not v then
			return
		end
		paths[1] = util.remote(v)
	end

	local prompt = { "Delete from the pan?" }
	for _, p in ipairs(paths) do
		prompt[#prompt + 1] = p
	end
	prompt[#prompt + 1] = "Deleted files stay in the pan's recycle bin."

	if not M.confirm("Remove from Baidu pan?", prompt) then
		return
	end

	return succeeded(("Removed %d item(s)"):format(#paths), compact({ "rm", table.unpack(paths) }))
end

--- @param argv string[]? [source, destination]
function M.mv(argv)
	local src = util.remote((argv or {})[1] or M.input("Move/rename (remote path):"))
	if not src then
		return
	end
	local dst = util.remote((argv or {})[2] or M.input("To (remote path):", util.parent(src) .. "/"))
	if not dst then
		return
	end

	succeeded(("Moved to %s"):format(dst), { "mv", src, dst })
end

--- @param argv string[]? [remote directory] given as-is, otherwise prompted for
--- @param dir string? prompt default
function M.mkdir(argv, dir)
	local path = util.remote((argv or {})[1] or M.input("Create directory:", dir or util.remembered("remote_dir", "/")))
	if not path then
		return
	end

	succeeded("Created " .. path, { "mkdir", path })
end

--- yazi's `create`: a trailing slash makes a directory. The pan cannot create an empty
--- file, so a bare file name is refused rather than silently making a directory.
--- @param dir string prompt default
function M.create(dir)
	local path = M.input("Create (end with / for a directory):", dir, 60)
	if not path then
		return
	end
	if path:sub(-1) ~= "/" then
		return util.notify("The pan cannot create empty files — end the name with `/`", "warn")
	end

	succeeded("Created " .. path, { "mkdir", util.remote(path) })
end

--- yazi's `rename`, pre-filled with the current name.
--- @param path string remote path
function M.rename(path)
	local v = M.input("Rename to:", path:match("[^/]+$"), 60)
	if not v then
		return
	end

	succeeded(("Renamed to %s"):format(v), { "mv", path, util.join(util.parent(path), v) })
end

--- yazi's `paste`: `cp` for yanked entries, `mv` for cut ones.
--- @param paths string[] remote paths that were yanked or cut
--- @param move boolean
--- @param dest string remote directory
function M.paste(paths, move, dest)
	if #paths == 0 then
		return
	end
	if not M.confirm(("%s %d item(s) to %s?"):format(move and "Move" or "Copy", #paths, dest), paths) then
		return
	end

	local args = { move and "mv" or "cp" }
	for _, p in ipairs(paths) do
		args[#args + 1] = p
	end
	args[#args + 1] = dest

	return succeeded(("%s %d item(s)"):format(move and "Moved" or "Copied", #paths), args)
end

--- @param dir string remote directory to search in
function M.search(dir)
	local kw = M.input("Search in " .. dir .. ":", nil, 60)
	if not kw then
		return
	end

	util.run_block({ "search", "-path=" .. dir, kw })
end

--- Quota plus the account currently in use, without an extra `who` request.
function M.info()
	local out, err = util.run({ "quota" })
	if err then
		return util.notify(err, "error")
	end

	local who = util.active_account()
	util.notify((who and who.name or "not logged in") .. "\n" .. out)
end

--- @param argv string[]? [remote path]
function M.share(argv)
	local target = util.remote((argv or {})[1] or M.input("Share (remote path):"))
	if not target then
		return
	end

	local out, err = util.run({ "share", target })
	if err then
		return util.notify(err, "error")
	end
	if util.copy(out) then
		util.notify("Share link copied to clipboard:\n" .. out)
	else
		util.notify(out)
	end
end

--- @param argv string[]? [remote path]
function M.locate(argv)
	local target = util.remote((argv or {})[1] or M.input("Direct link (remote path):"))
	if not target then
		return
	end

	local out, err = util.run({ "locate", target })
	if err then
		return util.notify(err, "error")
	end
	if util.copy(out) then
		util.notify("Direct link copied to clipboard:\n" .. out)
	else
		util.notify(out)
	end
end

--- @param argv string[]? [remote directory]
function M.ls(argv)
	local path = util.remote((argv or {})[1] or util.remembered("remote_dir", "/")) or "/"
	util.run_block({ "ls", "-l", path })
end

--- @param argv string[]? [remote path]
function M.tree(argv)
	local path = util.remote((argv or {})[1] or util.remembered("remote_dir", "/")) or "/"
	util.run_block({ "tree", path })
end

function M.quota()
	local out, err = util.run({ "quota" })
	if err then
		return util.notify(err, "error")
	end
	util.notify(out)
end

function M.who()
	local out, err = util.run({ "who" })
	if err then
		return util.notify(err, "error")
	end
	util.notify(out)
end

function M.loglist()
	local out, err = util.run({ "loglist" })
	if err then
		return util.notify(err, "error")
	end
	util.notify(out)
end

--- @param argv string[]? [uid]
function M.su(argv)
	util.run_block(compact({ "su", table.unpack(argv or {}) }))
end

function M.logout()
	if not M.confirm("Log out of the Baidu account?", { "Log in again later with cookies or BDUSS." }) then
		return
	end
	succeeded("Logged out", { "logout", "-y" })
end

--- @param argv string[]? [cookies]
function M.login_cookies(argv)
	local cookies = (argv or {})[1] or M.input("Baidu pan cookies:", nil, 100)
	if not cookies then
		return
	end
	M.login({ "login", "-cookies=" .. cookies })
end

--- BDUSS (+ optional STOKEN), the pair BaiduPCS-Go accepts without cookies.
function M.login_bduss()
	local bduss = M.input("BDUSS:", nil, 100)
	if not bduss then
		return
	end
	local stoken = M.input("STOKEN (optional):", nil, 100)

	M.login(compact({ "login", "-bduss=" .. bduss, stoken and ("-stoken=" .. stoken) }))
end

--- @param argv string[]
function M.login(argv)
	local out, err = util.run(argv)
	if err then
		return util.notify(err, "error")
	end

	local who = util.active_account()
	util.notify(who and ("Logged in as " .. who.name) or (out ~= "" and out or "Logged in"))
end

--- Account submenu, built on yazi's own `which` picker.
local account_items = {
	{ on = "c", desc = "Log in with cookies", run = "login_cookies" },
	{ on = "b", desc = "Log in with BDUSS + STOKEN", run = "login_bduss" },
	{ on = "w", desc = "Show the current account", run = "who" },
	{ on = "l", desc = "List logged-in accounts", run = "loglist" },
	{ on = "s", desc = "Switch account", run = "su" },
	{ on = "o", desc = "Log out", run = "logout" },
}

function M.account()
	local idx = ya.which { cands = account_items }
	local item = idx and account_items[idx]
	if item then
		return M[item.run]()
	end
end

return M
