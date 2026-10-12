--- Shared helpers for the baidu.yazi plugin (BaiduPCS-Go control panel).
--- @since 26.5.6

local M = {}

--- Path or name of the BaiduPCS-Go binary; override with $BAIDU_YAZI_BIN.
M.bin = os.getenv("BAIDU_YAZI_BIN") or "baidupcs-go"

--- Append a line to $BAIDU_YAZI_TRACE when it is set, for debugging without yazi's logger.
--- @param ... any
function M.trace(...)
	local path = os.getenv("BAIDU_YAZI_TRACE")
	if not path then
		return
	end
	local f = io.open(path, "a")
	if not f then
		return
	end

	local parts = {}
	for _, v in ipairs({ ... }) do
		parts[#parts + 1] = tostring(v)
	end
	f:write(os.date("%H:%M:%S"), " ", table.concat(parts, " "), "\n")
	f:close()
end

--- Quote `s` so it survives a trip through `sh -c`.
--- @param s string|number
--- @return string
function M.shq(s)
	return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

--- Directory where BaiduPCS-Go keeps its own config (and credentials).
--- @return string
function M.config_dir()
	return os.getenv("BAIDUPCS_GO_CONFIG_DIR") or (os.getenv("HOME") or "") .. "/.config/BaiduPCS-Go"
end

--- yazi's config home points at a read-only Nix store path, so plugin state lives in XDG_STATE_HOME.
--- @return string
function M.state_dir()
	local base = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") or "") .. "/.local/state"
	return base .. "/baidu.yazi"
end

--- @return table<string, string>
function M.load_state()
	local f = io.open(M.state_dir() .. "/state.json", "r")
	if not f then
		return {}
	end
	local raw = f:read("*a")
	f:close()

	local ok, t = pcall(ya.json_decode, raw)
	if ok and type(t) == "table" then
		return t
	end
	return {}
end

--- @param state table<string, string>
--- @return boolean
function M.save_state(state)
	fs.create("dir_all", Url(M.state_dir()))

	local f = io.open(M.state_dir() .. "/state.json", "w")
	if not f then
		return false
	end
	f:write(ya.json_encode(state))
	f:close()
	return true
end

--- One remembered value, e.g. the last remote directory used.
--- @param key string
--- @param default string
--- @return string
function M.remembered(key, default)
	return M.load_state()[key] or default
end

--- @param key string
--- @param value string
function M.remember(key, value)
	local state = M.load_state()
	state[key] = value
	M.save_state(state)
end

--- The account currently active in BaiduPCS-Go, without issuing any API request.
--- @return table? { uid = string, name = string }
function M.active_account()
	local f = io.open(M.config_dir() .. "/pcs_config.json", "r")
	if not f then
		return nil
	end
	local raw = f:read("*a")
	f:close()

	local ok, cfg = pcall(ya.json_decode, raw)
	if not ok or type(cfg) ~= "table" then
		return nil
	end
	for _, u in ipairs(cfg.baidu_user_list or {}) do
		if tostring(u.uid) == tostring(cfg.baidu_active_uid) then
			return { uid = tostring(u.uid), name = u.name or "?" }
		end
	end
	return nil
end

--- Strip ANSI escapes and the `----` separators BaiduPCS-Go prints.
--- @param text string
--- @return string
function M.clean(text)
	text = text:gsub("\27%[[%d;]*[A-Za-z]", "")
	text = text:gsub("\r", "")
	text = text:gsub("^%-%-%-%-\n", "")
	return text:gsub("\n+$", ""):gsub("^%s*\n", "")
end

--- @param content string
--- @param level string? "info" | "warn" | "error"
--- @param title string?
function M.notify(content, level, title)
	ya.notify {
		title = title or "Baidu",
		content = content,
		level = level or "info",
		timeout = 6,
	}
end

--- Run `baidupcs-go <args...>` without a shell and return its output.
--- @param args string[]
--- @return string? out cleaned output when the command succeeded
--- @return string? err human readable error otherwise
function M.run(args)
	M.trace("run", table.concat(args, " "))
	local output, err = Command(M.bin):arg(args):output()
	if not output then
		return nil, ("Cannot run %s: %s"):format(M.bin, err)
	end

	local stdout = M.clean(output.stdout or "")
	local stderr = M.clean(output.stderr or "")
	if not output.status.success then
		local detail = stderr ~= "" and stderr or stdout
		return nil, ("%s failed (exit %s)%s"):format(args[1], output.status.code, detail ~= "" and (":\n" .. detail) or "")
	end
	return stdout ~= "" and stdout or stderr, nil
end

--- Hand the terminal over to `baidupcs-go <args...>` so progress bars render natively.
--- @param args string[]
function M.run_block(args)
	M.trace("run_block", table.concat(args, " "))
	local parts = { M.shq(M.bin) }
	for _, a in ipairs(args) do
		parts[#parts + 1] = M.shq(a)
	end
	ya.emit("shell", { table.concat(parts, " "), block = true, confirm = false })
end

--- Put `text` on the system clipboard; returns false when no clipboard tool is available.
--- @param text string
--- @return boolean
function M.copy(text)
	local wayland = os.getenv("WAYLAND_DISPLAY") ~= nil or os.getenv("XDG_SESSION_TYPE") == "wayland"
	local tool, args = wayland and "wl-copy" or "xclip", wayland and {} or { "-selection", "clipboard" }

	-- wl-copy forks and keeps stdio open, NULL keeps `output()` from blocking forever.
	local output = Command(tool):arg(args):arg(text):stdout(Command.NULL):stderr(Command.NULL):output()
	return output ~= nil and output.status.success
end

--- Normalise a remote path: leading `/`, no trailing `/`, no surrounding blanks.
--- @param path string?
--- @return string? nil when the input is blank
function M.remote(path)
	path = (path or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if path == "" then
		return nil
	end
	if path:sub(1, 1) ~= "/" then
		path = "/" .. path
	end
	if #path > 1 then
		path = path:gsub("/+$", "")
	end
	return path
end

--- @param dir string remote directory
--- @param name string child name
--- @return string
function M.join(dir, name)
	if dir == "/" or dir == "" then
		return "/" .. name
	end
	return dir:gsub("/+$", "") .. "/" .. name
end

--- @param path string
--- @return string
function M.parent(path)
	path = M.remote(path) or "/"
	if path == "/" then
		return "/"
	end
	local parent = path:match("^(.*)/[^/]+$")
	return (parent == "" or parent == nil) and "/" or parent
end

--- Split a line on runs of two or more spaces, the column separator of `ls -l`.
--- @param line string
--- @return string[]
local function split_columns(line)
	local fields, from = {}, 1
	while true do
		local s, e = line:find("%s%s+", from)
		if not s then
			fields[#fields + 1] = line:sub(from)
			break
		end
		if s > from then
			fields[#fields + 1] = line:sub(from, s - 1)
		end
		from = e + 1
	end
	return fields
end

--- Parse the table printed by `baidupcs-go ls -l`.
--- @param text string
--- @return table[] entries { name = string, dir = boolean, size = string, mtime = string }
function M.parse_ls(text)
	local entries = {}
	for raw in text:gmatch("[^\r\n]+") do
		local line = raw:gsub("%s+$", "")
		local fields = split_columns(line)

		-- Data rows start with a numeric index and always end with the file name column.
		if #fields >= 2 and fields[1]:match("^%d+$") then
			local name, size, mtime = fields[#fields], nil, nil
			for i, f in ipairs(fields) do
				if f:match("^%d+%-%d+%-%d+ %d+:%d+:%d+$") then
					-- Two timestamps per row: the first is the creation time, the second the mtime.
					if mtime then
						break
					end
					mtime = f
					size = fields[i - 1]
				end
			end

			local dir = name:sub(-1) == "/"
			entries[#entries + 1] = {
				name = dir and name:sub(1, -2) or name,
				dir = dir,
				size = (size and size ~= "-") and size or "",
				mtime = mtime or "",
			}
		end
	end
	return entries
end

--- Local files selected in yazi, falling back to the hovered entry.
--- @return string[]
M.selected_or_hovered = ya.sync(function()
	local tab, paths = cx.active, {}
	for _, url in pairs(tab.selected) do
		paths[#paths + 1] = tostring(url)
	end
	if #paths == 0 and tab.current.hovered then
		paths[1] = tostring(tab.current.hovered.url)
	end
	return paths
end)

--- Local directory yazi is currently showing.
--- @return string
M.cwd = ya.sync(function() return tostring(cx.active.current.cwd) end)

return M
