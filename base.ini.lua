local loadfile = loadfile
local lua_setbytecode = lua.setbytecode
local texio_write = texio.write
local texio_write_nl = texio.write_nl
local read_file = require("utils.read_file")
local store_table = require("utils.store_table")

local collect_modules

do
	local redump_lua_modules = false
	
	local lua_module_list_file = io.open("lua_module_list.txt", "rb")
	if lua_module_list_file then
		local lua_module_list = lua_module_list_file:read("*a")
		
		lua_module_list_file:close()
		
		if lua_module_list then
			texio_write_nl("term", "Preloading Lua modules")
			
			collect_modules = true
			
			local name2slot = {}
			
			local offset = 10
			local i = 1
			
			for path in string.gmatch(lua_module_list, "[^ \r\n]+") do
				local module_name = string.gsub(string.match(path, "^([^.]+)%..+$"), "/", ".")
				local module_loader, error_message = loadfile(path, "b")
				if module_loader then
					if redump_lua_modules then
						module_loader = assert(load(string.dump(module_loader, true), "dump", "b"))
					end
					
					local slot = offset + i
					
					name2slot[module_name] = slot
					
					lua_setbytecode(slot, module_loader)
					
					texio_write_nl("log", "Lua module preloader: module '")
					texio_write("log", module_name, "' stored in bytecode register ", tostring(slot))
				else
					tex.error("Lua module couldn't be loaded",
						{
							module_name,
							error_message
						}
					)
				end
				
				i = i + 1
			end
			
			store_table(name2slot, offset)
		else
			tex.error("couldn't read Lua module list",
				{
					"file read operation failed"
				}
			)
		end
	else
		-- collect_modules = false
	end
end

do
	local texlua_bytecode_extension = read_file("texlua_bytecode_extension.txt")
	if texlua_bytecode_extension then
		texio_write_nl("term and log", "Lua bytecode file name extension: ")
		texio_write("term and log", texlua_bytecode_extension)
		
		if collect_modules then
			lua_setbytecode(1, assert(loadfile("setup." .. texlua_bytecode_extension, "b")))
		else
			lua_setbytecode(1,
				function()
					_G.assert(_G.loadfile("../../setup.lua", "t"))()
				end
			)
		end
	end
end

tex.enableprimitives("",
	{
		"luafunction",
		"outputbox",
		"pageheight",
		"pagewidth",
	}
)

pdf.setminorversion(5)
pdf.setcompresslevel(9)
pdf.setobjcompresslevel(9)
