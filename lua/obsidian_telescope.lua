local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")

return {
	obsidian_tags_in_workspace = function(workspaces, active_workspace, opts)
		opts = opts or {}
		for _, workspace in pairs(workspaces) do
			if workspace.name == active_workspace then
				print("Searching in " .. workspace.path)
				pickers
					.new(opts, {
						finder = finders.new_oneshot_job({ "rg", "-l", "#", workspace.path }, opts),
						sorter = sorters.get_generic_fuzzy_sorter(opts),
					})
					:find()
			end
		end
	end,

	obsidian_file_ext_tags_in_all_workspaces = function(workspaces, opts)
		local filetype = vim.bo.filetype

		local paths = {}

		for _, workspace in pairs(workspaces) do
			paths = paths .. " " .. workspace.path
		end

		opts = opts or {}
		pickers
			.new(opts, {
				finder = finders.new_oneshot_job({ "rg", "-l", "#" .. filetype, paths }, opts),
				sorter = sorters.get_generic_fuzzy_sorter(opts),
			})
			:find()
	end,

	obsidian_tag_in_workspace = function(workspaces, active_workspace, tag, opts)
		opts = opts or {}
		for _, workspace in pairs(workspaces) do
			if workspace.name == active_workspace then
				print("Searching in " .. workspace.path .. " with tag " .. tag)
				pickers
					.new(opts, {
						finder = finders.new_oneshot_job({ "rg", "-l", "#" .. tag, workspace.path }, opts),
						sorter = sorters.get_generic_fuzzy_sorter(opts),
					})
					:find()
			end
		end
	end,
}
