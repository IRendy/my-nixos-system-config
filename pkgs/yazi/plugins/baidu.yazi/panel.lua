--- A modal browser for the Baidu pan, mirroring yazi's own keymap and theme:
--- `<Space>` selects, `y`/`x` yank (green) / cut (red), `a` creates, `p` pastes.
--- @since 26.5.6

local util = require(".util")
local actions = require(".actions")

local toggle_ui = ya.sync(function(self)
	if self.children then
		Modal:children_remove(self.children)
		self.children = nil
	else
		self.children = Modal:children_add(self, 10)
	end
	ui.render()
end)

local update = ya.sync(function(self, cwd, entries, err, cursor)
	self.cwd, self.entries, self.err = cwd, entries, err

	-- `cursor` is nil when the directory is merely reloaded: put the cursor back where
	-- it was the last time this directory was visited.
	local want = cursor ~= nil and cursor or (self.positions or {})[cwd]
	self.cursor = math.max(0, math.min(want or self.cursor or 0, #entries - 1))
	ui.render()
end)

local move_cursor = ya.sync(function(self, cursor)
	if #(self.entries or {}) == 0 then
		self.cursor = 0
	else
		self.cursor = ya.clamp(0, (self.cursor or 0) + cursor, #self.entries - 1)
	end
	self.positions = self.positions or {}
	if self.cwd then
		self.positions[self.cwd] = self.cursor
	end
	ui.render()
end)

local set_cursor = ya.sync(function(self, cursor)
	self.cursor = math.max(0, math.min(cursor, #(self.entries or {}) - 1))
	self.positions = self.positions or {}
	if self.cwd then
		self.positions[self.cwd] = self.cursor
	end
	ui.render()
end)

--- Like yazi's own selection, entries are remembered by their remote path, so a selection
--- can span directories.
--- @param cwd string
--- @param name string
--- @return string
local function path_of(cwd, name)
	local base = cwd == "/" and "" or cwd:gsub("/+$", "")
	return base .. "/" .. name
end

--- `<Space>` toggles, `<C-a>` selects everything and `<C-r>` inverts, all like yazi's own
--- file list. Specifying `all`/`invert` applies to every entry of the current directory.
local toggle_select = ya.sync(function(self, how)
	local cwd = self.cwd or "/"
	local entries = self.entries or {}
	local cursor = self.cursor or 0
	self.selected = self.selected or {}

	if how == "all" or how == "invert" then
		for _, e in ipairs(entries) do
			local path = path_of(cwd, e.name)
			if how == "all" then
				self.selected[path] = true
			elseif self.selected[path] then
				self.selected[path] = nil
			else
				self.selected[path] = true
			end
		end
	elseif entries[cursor + 1] then
		local path = path_of(cwd, entries[cursor + 1].name)
		if self.selected[path] then
			self.selected[path] = nil
		else
			self.selected[path] = true
		end
	end
	ui.render()
end)

--- `y` / `x`: remember the selected entries (or the hovered one) for a later paste, then
--- drop the selection — this is what turns the yellow markers green/red in yazi too.
--- @param mode string "copy" or "cut"
local yank = ya.sync(function(self, mode)
	local cwd = self.cwd or "/"
	local entries = self.entries or {}
	local cursor = self.cursor or 0

	local paths = {}
	for path in pairs(self.selected or {}) do
		paths[path] = true
	end
	if not next(paths) and entries[cursor + 1] then
		paths[path_of(cwd, entries[cursor + 1].name)] = true
	end

	self.yanked = next(paths) and { mode = mode, paths = paths } or nil
	self.selected = {}
	ui.render()
end)

--- Forget paths that no longer exist after a remove or a move.
--- @param paths string[]
local prune_selection = ya.sync(function(self, paths)
	for _, path in ipairs(paths) do
		if self.selected then
			self.selected[path] = nil
		end
	end
	ui.render()
end)

local unyank = ya.sync(function(self)
	self.yanked = nil
	ui.render()
end)

--- A consistent snapshot for the coroutines and the renderer.
local snapshot = ya.sync(function(self)
	return {
		cwd = self.cwd or "/",
		cursor = self.cursor or 0,
		entries = self.entries or {},
		selected = self.selected or {},
		yanked = self.yanked,
		err = self.err,
	}
end)

--- Every selected entry as a remote path, or the hovered one when nothing is selected.
--- @param s table snapshot
--- @return string[]
local function targets(s)
	local paths = {}
	for path in pairs(s.selected) do
		paths[#paths + 1] = path
	end
	table.sort(paths)

	if #paths == 0 and s.entries[s.cursor + 1] then
		paths[1] = path_of(s.cwd, s.entries[s.cursor + 1].name)
	end
	return paths
end

--- The yanked/cut entries as remote paths.
--- @param s table snapshot
--- @return string[]
local function yanked_paths(s)
	local paths = {}
	for path in pairs((s.yanked or {}).paths or {}) do
		paths[#paths + 1] = path
	end
	table.sort(paths)
	return paths
end

--- @param s table snapshot
--- @param name string
--- @return integer  number of selected entries
local function count_selected(s)
	local n = 0
	for _ in pairs(s.selected) do
		n = n + 1
	end
	return n
end

--- @param entries table[]
--- @param name string
--- @return integer? 0-based index of the entry
local function index_of(entries, name)
	for i, e in ipairs(entries) do
		if e.name == name then
			return i - 1
		end
	end
end

--- Load a remote directory. `focus` is the child directory we came back from, so that
--- returning to a parent puts the cursor on the directory we just left.
--- @param cwd string
--- @param focus string?
local function load(cwd, focus)
	update(cwd, {}, nil, 0)

	local out, err = util.run({ "ls", "-l", cwd })
	if err then
		return update(cwd, {}, err, 0)
	end

	local entries = util.parse_ls(out)
	if #entries == 0 then
		return update(cwd, {}, "Empty or unreadable directory", 0)
	end
	util.remember("remote_dir", cwd)
	update(cwd, entries, nil, focus and index_of(entries, focus) or nil)
end

local M = {
	cursor = 0,
	entries = {},
	selected = {},
	keys = {
		{ on = "q", run = "quit" },
		{ on = "<Esc>", run = "quit" },
		{ on = "<C-c>", run = "quit" },

		{ on = "j", run = "down" },
		{ on = "<Down>", run = "down" },
		{ on = "k", run = "up" },
		{ on = "<Up>", run = "up" },
		{ on = "g", run = "top" },
		{ on = "G", run = "bot" },

		{ on = "l", run = "enter" },
		{ on = "<Right>", run = "enter" },
		{ on = "<Enter>", run = "download" },
		{ on = "o", run = "download" },
		{ on = "h", run = "leave" },
		{ on = "<Left>", run = "leave" },
		{ on = "<Backspace>", run = "leave" },

		{ on = "<Space>", run = "toggle" },
		{ on = "<C-a>", run = "select_all" },
		{ on = "<C-r>", run = "select_invert" },
		{ on = "y", run = "yank" },
		{ on = "x", run = "cut" },
		{ on = "p", run = "paste" },
		{ on = "P", run = "paste_move" },
		{ on = "Y", run = "unyank" },
		{ on = "X", run = "unyank" },

		{ on = "d", run = "rm" },
		{ on = "D", run = "rm" },
		{ on = "a", run = "create" },
		{ on = "r", run = "rename" },

		{ on = "u", run = "upload" },
		{ on = "s", run = "search" },
		{ on = "t", run = "tree" },
		{ on = "i", run = "info" },
		{ on = "c", run = "share" },
		{ on = "C", run = "locate" },

		{ on = "R", run = "refresh" },
		{ on = ":", run = "goto" },
		{ on = "~", run = "help" },
	},
}

--- @param area Rect
function M:new(area)
	self:layout(area)
	return self
end

--- @param area Rect
function M:layout(area)
	local rows = ui.Layout()
		:constraints {
			ui.Constraint.Percentage(15),
			ui.Constraint.Percentage(70),
			ui.Constraint.Percentage(15),
		}
		:split(area)

	local cols = ui.Layout()
		:direction(ui.Layout.HORIZONTAL)
		:constraints {
			ui.Constraint.Percentage(10),
			ui.Constraint.Percentage(80),
			ui.Constraint.Percentage(10),
		}
		:split(rows[2])

	self._area = cols[2]

	local inner = ui.Layout()
		:constraints {
			ui.Constraint.Length(1),
			ui.Constraint.Fill(1),
			ui.Constraint.Length(1),
		}
		:split(self._area:pad(ui.Pad(1, 2, 1, 2)))

	self._info, self._table, self._hint = inner[1], inner[2], inner[3]
end

local KEY_HELP = "j/k move   h/l leave/enter   <Space> select   <C-a> all   y copy   x cut   p paste   "
	.. "P move   Y/X unyank\nd delete   a create   r rename   o download   u upload here   s search   "
	.. "t tree   i quota   c share   C direct link\nR reload   : go to path   ~ keys   q close"

--- @param job { args: table, keep: boolean? } `keep` preserves the selection when the panel
--- reopens itself after an action, the way yazi keeps it across its own actions.
function M:entry(job)
	local args = job.args or {}
	local start = util.remote(args[1]) or util.remembered("remote_dir", "/")

	if not job.keep then
		self.selected, self.yanked, self.cursor = {}, nil, 0
	end
	toggle_ui()

	-- Loading a directory hits the network for a second or two. It must not run between two
	-- `ya.which` calls: for as long as this plugin does not hold the Which layer, yazi falls
	-- back to the manager keymap and `h`/`l`/`q` typed in the panel would leak into it.
	-- The key loop therefore only queues requests, and the loader resolves them one by one
	-- against the directory it has actually loaded by then.
	local tx, rx = ya.chan("mpsc")

	local function loader()
		while true do
			local req = rx:recv()
			if not req then
				break
			end

			local op, arg = req[1], req[2]
			if op == "start" then
				load(arg)
			elseif op == "enter" then
				local s = snapshot()
				local e = s.entries[arg + 1]
				if e and e.dir then
					load(util.join(s.cwd, e.name))
				end
			elseif op == "leave" then
				local s = snapshot()
				load(util.parent(s.cwd), s.cwd:match("[^/]+$"))
			elseif op == "refresh" then
				load(snapshot().cwd)
			end
		end
	end

	local function keys()
		tx:send { "start", start }

		-- yazi can only run one prompt at a time: anything below that needs `ya.input`,
		-- a confirmation or the terminal itself closes the panel first and runs afterwards.
		local action = nil
		while not action do
			local idx = ya.which { cands = self.keys, silent = true }
			local run = (self.keys[idx] or {}).run

			if run == nil then
				-- An unbound key or a cancelled picker: keep the panel open.
			elseif run == "quit" then
				break
			elseif run == "up" then
				move_cursor(-1)
			elseif run == "down" then
				move_cursor(1)
			elseif run == "top" then
				set_cursor(0)
			elseif run == "bot" then
				set_cursor(#(snapshot().entries) - 1)
			elseif run == "toggle" then
				-- yazi's own `<Space>` is `toggle; arrow 1`, so multi-select flows naturally.
				toggle_select(nil)
				move_cursor(1)
			elseif run == "select_all" then
				toggle_select("all")
			elseif run == "select_invert" then
				toggle_select("invert")
			elseif run == "yank" then
				yank("copy")
			elseif run == "cut" then
				yank("cut")
			elseif run == "unyank" then
				unyank()
			elseif run == "leave" then
				tx:send { "leave" }
			elseif run == "refresh" then
				tx:send { "refresh" }
			elseif run == "enter" then
				-- Like yazi's `l`: only directories are entered, files need `<Enter>`/`o`.
				local s = snapshot()
				local e = s.entries[s.cursor + 1]
				if e and e.dir then
					tx:send { "enter", s.cursor }
				end
			elseif run == "help" then
				util.notify(KEY_HELP, "info", "Baidu pan keys")
			else
				action = run
			end
		end

		tx:send(false)
		return action
	end

	local action = ya.join(loader, keys)
	toggle_ui()

	local s = snapshot()
	if action == "download" then
		local paths = targets(s)
		if #paths > 0 then
			return actions.download(paths)
		end
	elseif action == "upload" then
		return actions.upload { s.cwd }
	elseif action == "rm" then
		local paths = targets(s)
		-- yazi drops removed files from the selection too, so stale paths are not acted on later.
		if #paths > 0 and actions.rm(paths) then
			prune_selection(paths)
		end
	elseif action == "create" then
		actions.create(util.join(s.cwd, ""))
	elseif action == "rename" then
		local paths = targets(s)
		if #paths > 0 then
			actions.rename(paths[1])
		end
	elseif action == "paste" or action == "paste_move" then
		local move = action == "paste_move"
		local paths = yanked_paths(s)
		if #paths > 0 and actions.paste(paths, move, s.cwd) then
			prune_selection(paths)
			if move then
				unyank()
			end
		end
	elseif action == "share" then
		local paths = targets(s)
		if #paths > 0 then
			actions.share { paths[1] }
		end
	elseif action == "locate" then
		local paths = targets(s)
		if #paths > 0 then
			actions.locate { paths[1] }
		end
	elseif action == "search" then
		actions.search(s.cwd)
	elseif action == "tree" then
		actions.tree { s.cwd }
	elseif action == "info" then
		actions.info()
	elseif action == "goto" then
		local target = actions.input("Go to (remote dir):", s.cwd, 60)
		if target then
			return M:entry { args = { target }, keep = true }
		end
	end

	-- Reopen at the same directory after quick actions, so the panel is where the user left it.
	if action and action ~= "download" and action ~= "upload" then
		return M:entry { args = { s.cwd }, keep = true }
	end
end

function M:reflow() return { self } end

function M:redraw()
	local s = snapshot()
	local rows, cursor = {}, s.cursor

	if s.err then
		rows[1] = ui.Row { "", s.err }
	else
		for i, e in ipairs(s.entries) do
			local path = path_of(s.cwd, e.name)
			local marker = ""
			if s.selected[path] then
				marker = ui.Line { ui.Span(th.mgr.marker_symbol):style(th.mgr.marker_selected) }
			elseif (s.yanked or {}).paths and s.yanked.paths[path] then
				marker = ui.Line {
					ui.Span(th.mgr.marker_symbol):style(
						s.yanked.mode == "cut" and th.mgr.marker_cut or th.mgr.marker_copied
					),
				}
			end

			local name = e.name .. (e.dir and "/" or "")
			if i - 1 == cursor then
				name = ui.Line(name):style(th.indicator.current)
			end
			rows[#rows + 1] = ui.Row { marker, name, e.size, e.mtime:sub(1, 16) }
		end
	end

	local who = util.active_account()
	local info = ("%s · %s · %d/%d · %d selected%s"):format(
		s.cwd,
		who and who.name or "not logged in",
		#s.entries > 0 and cursor + 1 or 0,
		#s.entries,
		count_selected(s),
		s.yanked and (" · %d yanked (%s)"):format(
			#yanked_paths(s),
			s.yanked.mode == "cut" and "cut" or "copy"
		) or ""
	)

	return {
		ui.Clear(self._area),
		ui.Border(ui.Edge.ALL)
			:area(self._area)
			:type(ui.Border.ROUNDED)
			:style(th.mgr.border_style)
			:title(ui.Line(" Baidu pan "):align(ui.Align.CENTER)),
		ui.Text { ui.Line(info):style(th.mgr.cwd) }:area(self._info),
		ui.Table(rows)
			:area(self._table)
			:header(ui.Row { "", "Name", "Size", "Modified" }:style(ui.Style():bold()))
			:row(s.cursor)
			:widths {
				ui.Constraint.Length(1),
				ui.Constraint.Fill(1),
				ui.Constraint.Length(10),
				ui.Constraint.Length(18),
			},
		ui.Text { ui.Line(" " .. KEY_HELP:gsub("\n", " ")):style(th.which.rest) }:area(self._hint),
	}
end

function M:click() end
function M:scroll() end
function M:touch() end

return M
