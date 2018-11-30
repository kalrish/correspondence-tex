local tostring = tostring
local node = node
local node_new = node.new
local img_scan = img.scan

return function(id, letter_number, page_number, image_format)
	img_scan{
		filename="../../../data/" .. id .. "/" .. tostring(letter_number) .. "/" .. tostring(page_number) .. "." .. image_format
	}
end
