local arg = arg
local assert = assert
local loadfile = loadfile

local ser
do
	local type = type
	local pairs = pairs
	local tostring = tostring
	local string_format = string.format

	local serializers

	local serialize_array = function(t, s, c)
		local i = 1
		local entry = t[1]
		while entry do
			c = serializers[type(entry)](entry, s, c)
			
			c = c + 1
			s[c] = ","
			
			i = i + 1
			entry = t[i]
		end
		
		return c
	end

	local serialize_map = function(t, s, c)
		for i, v in pairs(t) do
			c = c + 1
			s[c] = "["
			
			c = serializers[type(i)](i, s, c)
			
			c = c + 1
			s[c] = "]="
			
			c = serializers[type(v)](v, s, c)
			
			c = c + 1
			s[c] = ","
		end
		
		return c
	end

	local serialize_table = function(t, s, c)
		c = c + 1
		s[c] = "{"
		
		c = serialize_array(t, s, c)
		c = serialize_map(t, s, c)
		
		c = c + 1
		s[c] = "}"
		
		return c
	end

	local tostring_serializer = function(v, s, c)
		c = c + 1
		
		s[c] = tostring(v)
		
		return c
	end

	serializers = {
		boolean = tostring_serializer,
		number = tostring_serializer,
		string = function(v, s, c)
			c = c + 1
			
			s[c] = string_format("%q", v)
			
			return c
		end,
		table = serialize_table
	}
	
	ser = serialize_table
end

local serialize_table = function(t)
	local s = { "return" }
	
	ser(t, s, 1)
	
	return string.dump(assert(load(table.concat(s), "string", "t", {})), true)
end

local letters = {}
do
	local i = 2
	local argument = arg[2]
	repeat
		local letter = assert(loadfile(argument, "b"))()
		
		if letter.image_format == "png" then
			letter.image_format = "pdf"
			letter.processed_image = true
		end
		
		letters[i-1] = letter
		
		i = i + 1
		argument = arg[i]
	until argument == nil
end

do
	local output = assert(io.open(arg[1], "wb"))

	output:write(serialize_table(letters))

	output:close()
end
