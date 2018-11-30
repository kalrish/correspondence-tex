local assert = assert
local load = load
local table_concat = table.concat
local lua_setbytecode = lua.setbytecode
local serialize_table = require("utils.serialize_table")

return function(t, n)
	local s = { "return" }
	
	serialize_table(t, s, 1)
	
	lua_setbytecode(n, assert(load(table_concat(s))))
end
