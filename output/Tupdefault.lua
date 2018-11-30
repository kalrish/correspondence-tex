local title = tup.getdirectory()

local data_path = data_dir .. "/" .. title .. "/"

local exists = function(name)
	local file = io.open(name, "r")
	if file then
		file:close()
		
		return true
	else
		return false
	end
end

local participants_texluabc
do
	local output = "participants.lua"
	
	tup.definerule{
		command="json2lua " .. data_path .. "participants.json " .. output,
		outputs={
			output
		}
	}
	
	participants_texluabc = texluac("participants")
end

local letters = {}
do
	local letternumber = 1
	local letternumber_base10 = "1"
	while exists(data_path .. letternumber_base10 .. "/letter.json") do
		local output = letternumber_base10 .. ".lua"
		
		tup.definerule{
			command="json2lua " .. data_path .. letternumber_base10 .. "/letter.json " .. output,
			outputs={
				output
			}
		}
		
		letters[letternumber] = texluac(letternumber_base10)
		
		do
			local scannumber = 1
			local base = data_path .. letternumber_base10 .. "/1"
			local path = base .. ".png"
			while exists(path) do
				tup.definerule{
					command=tup.getconfig("LUATEX_IMG2PDF") .. " -- " .. path,
					outputs{
						base .. ".pdf"
					}
				}
				
				scannumber = scannumber + 1
				base = data_path .. letternumber_base10 .. "/" .. tostring(scannumber)
				path = base .. ".png"
			end
		end
		
		letternumber = letternumber + 1
		letternumber_base10 = tostring(letternumber)
	end
end

do
	local letters_texluabc = "letters." .. TEXLUA_BYTECODE_EXTENSION
	do
		local compile_letters_luabc = "../../compile_letters." .. TEXLUA_BYTECODE_EXTENSION
		local compile_letters_inputs = { compile_letters_luabc }
		tup.append_table(compile_letters_inputs, letters)
		
		tup.definerule{
			inputs=compile_letters_inputs,
			command=LUATEX .. " --luaonly " .. compile_letters_luabc .. " " .. letters_texluabc .. " " .. table.concat(letters, " "),
			outputs={
				letters_texluabc
			}
		}
	end
	
	tup.definerule{
		inputs={
			"../../base.fmt",
			letters_texluabc,
			participants_texluabc
		},
		command=LUATEX .. " --interaction=nonstopmode --fmt=../../base.fmt --jobname=" .. title .. " --output-format=pdf -- main.tex",
		outputs={
			title .. ".log",
			title .. ".pdf"
		}
	}
end
