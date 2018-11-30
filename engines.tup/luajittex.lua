LUATEX = tup.getconfig("LUAJITTEX")
TEXLUA_BYTECODE_EXTENSION = "texluajitbc"

local command_start = LUATEX .. " --luaconly -bt raw " .. tup.getconfig("LUAJITTEX_LUAC_FLAGS") .. " "
texluac = function(name)
	local input = name .. ".lua"
	local output = name .. "." .. TEXLUA_BYTECODE_EXTENSION
	tup.definerule{
		inputs={
			input
		},
		command=command_start .. input .. " " .. output,
		outputs={
			output
		}
	}
	
	return output
end
