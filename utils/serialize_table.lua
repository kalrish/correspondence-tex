--[[
local next = next
local type = type
local string_format = string.format

local serializers = {
	number = function(v)
		return tostring(v)
	end,
	string = function(v)
		return string_format("%q", v)
	end
}

return function(t)
	local i, v = next(t)
	return function()
		if i then
			local s = serializers[type(i)](i)
			
			i, v = next(t, i)
			
			return s
		end
	end
end
]]
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

return serialize_table
