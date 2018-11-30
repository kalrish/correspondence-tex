local texio_write = texio.write
local texio_write_nl = texio.write_nl

do
	local package_searchers = package.searchers or package.loaders
	local lua_getbytecode = lua.getbytecode
	
	local name2slot = lua_getbytecode(2)
	if name2slot then
		texio_write_nl("log", "loading own Lua modules from the format")
		
		name2slot = name2slot()
		
		local searcher = function(name)
			local slot = name2slot[name]
			if slot then
				texio_write_nl("log", "Lua module loader: module '")
				texio_write("log", name, "' was assigned the bytecode register ", tostring(slot))
				
				return lua_getbytecode(slot)
			else
				return "\n\tno slot assigned"
			end
		end
		
		-- We can entirely replace the default searcher because we don't use external modules,
		-- i.e. every module we use is collected and stored in the format
		package_searchers[2] = searcher
		--table.insert(package_searchers or package.loaders, 2, searcher)
	else
		local default_searcher = package_searchers[2]
		
		local local_path = "../../?.lua"
		
		package_searchers[2] = function(module_name)
			local path = package.searchpath(module_name, "../../?.lua")
			if path then
				local r1, r2 = loadfile(path, "t")
				return r1 or r2
			else
				return default_searcher(module_name)
			end
		end
	end
end

local participants = assert(loadfile("participants.texluajitbc", "b"))()
local letters = assert(loadfile("letters.texluajitbc", "b"))()

local fonts
do
	fonts = {
		
	}
end

do
	local lua_functions_table = lua.get_functions_table()
	
	lua_functions_table[1] = function()
		require("correspondence.whole")(tex.get("jobname"), participants, letters)
	end
end
