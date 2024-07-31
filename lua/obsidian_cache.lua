local cache_path = vim.fn.resolve(vim.fn.stdpath("cache"))

local cache = {}

local function load_cache()
	local file = io.open(cache_path, "r")
	if file == nil then
		print("Could not load cache")
		return
	end

	local cache_json = file:read("*a")
	file:close()
	cache = vim.fn.json_decode(cache_json)
end

return {
	init = function(path, data)
		cache_path = vim.fn.resolve(cache_path .. path)
		local file = io.open(cache_path, "r")
		if file == nil then
			file = io.open(cache_path, "a+")
			if file == nil then
				print("Could not create/load cache")
				return
			end
			local cache_json = vim.fn.json_encode(data)
			file:write(cache_json)
			file:close()
		end
		load_cache()
	end,
	get = function()
		return cache
	end,
	store = function(new_cache)
		local file = io.open(cache_path, "w")
		if file == nil then
			print("Could not load cache")
			return
		end
		local cache_json = vim.fn.json_encode(new_cache)
		file:write(cache_json)
		file:close()
		load_cache()
	end,
}
