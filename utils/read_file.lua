return function(name)
	local fd, error_message = io.open(name, "rb")
	if fd then
		local contents = fd:read("*a")
		
		fd:close()
		
		if contents then
			contents = string.gsub(contents, "\r\n", "")
		else
			tex.error("couldn't read from `" .. name .. "'",
				{
					"something bad happened"
				}
			)
		end
		
		return contents
	else
		tex.error("couldn't open `" .. name .. "' for reading",
			{
				error_message
			}
		)
	end
end
