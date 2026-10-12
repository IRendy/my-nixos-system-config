--- Drive BaiduPCS-Go (百度网盘) from yazi.
---
--- Usage: `plugin baidu -- <command> [args...]`, see README.md for the full list.
--- @since 26.5.6

local util = require(".util")
local actions = require(".actions")
local panel = require(".panel")

--- @type table<string, fun(argv: string[]): any>
local commands = {
	panel = function(argv) return panel:entry { args = argv } end,

	upload = actions.upload,
	download = actions.download,
	rm = actions.rm,
	mv = actions.mv,
	mkdir = actions.mkdir,
	share = actions.share,
	locate = actions.locate,
	ls = actions.ls,
	tree = actions.tree,

	quota = actions.quota,
	who = actions.who,
	account = actions.account,
	login_cookies = actions.login_cookies,
	login_bduss = actions.login_bduss,
	loglist = actions.loglist,
	su = actions.su,
	logout = actions.logout,
}

return {
	--- @param job { args: string[] }
	entry = function(_, job)
		local argv = job.args or {}
		local name = argv[1] or "panel"

		local fn = commands[name]
		if not fn then
			return util.notify("Unknown command: " .. tostring(name), "error")
		end

		local rest = {}
		for i = 2, #argv do
			rest[#rest + 1] = argv[i]
		end
		util.trace("entry", name, table.concat(rest, " "))
		return fn(rest)
	end,
}
