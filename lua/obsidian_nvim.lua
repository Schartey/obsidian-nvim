require("obsidian_telescope")

local cache = require("obsidian_cache")

local augroup = vim.api.nvim_create_augroup("ObsidianNvimBuffer", { clear = true })

local config = {
	workspaces = {},
	default_workspace = nil,
}

local function splitpath(path)
	local parts = {}
	for dir in vim.fs.parents(path) do
		local basename = vim.fs.basename(dir)
		if basename ~= "" then
			table.insert(parts, 0, basename)
		end
	end
	return parts
end

local function main()
	local buffer_path = splitpath(vim.api.nvim_buf_get_name(0))

	local obsidian_data = cache.get()

	local best_workspace = 0
	local similarity = 0

	for index, v in pairs(obsidian_data.workspaces) do
		local workspace_path = splitpath(v.path)
		local l_similarity = 0

		for k, p in pairs(buffer_path) do
			if workspace_path[k] ~= nil and workspace_path[k] == p then
				l_similarity = l_similarity + 1
			end
		end

		if l_similarity > similarity then
			similarity = l_similarity
			best_workspace = index
		end
	end
	obsidian_data.active_workspace = best_workspace
	cache.store(obsidian_data)

	vim.notify_once("Active Workspace: " .. best_workspace, vim.log.levels.INFO, {})
end

function Dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. Dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

local function setup(opts)
	local dir = os.getenv("HOME")
	if opts ~= nil and opts.dir ~= nil then
		dir = opts.dir
	end

	cache.init("/obsidian_nvim", config)
	local obsidian_data = cache.get()

	vim.system(
		{ "find", dir, "-name", ".obsidian", "-print" },
		{},
		vim.schedule_wrap(function(obj)
			for s in obj.stdout:gmatch("[^\r\n]+") do
				local workspace_path = s:sub(0, s:len() - (vim.fs.basename(s):len() + 1))
				local workspace_name = vim.fs.basename(workspace_path)
				obsidian_data.workspaces[workspace_name] = { path = workspace_path, name = workspace_name }
			end
			cache.store(obsidian_data)
		end)
	)
	vim.api.nvim_create_autocmd(
		"VimEnter",
		{ group = augroup, desc = "Set a fennel scratch buffer on load", once = true, callback = main }
	)
end

local function try_add_workspace(name, path)
	print("Add Workspaces")
	local obsidian_data = cache.get()
	obsidian_data.workspaces[name] = { path = path, name = name }
	cache.store(obsidian_data)
end

local function set_default_workspace(workspace)
	print("Set default workspace")
end

return { setup = setup, try_add_workspaces = try_add_workspaces, set_default_workspace = set_default_workspace }
