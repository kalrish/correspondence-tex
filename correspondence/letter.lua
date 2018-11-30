local output_page = require("correspondence.page")

return function(id, letter_number, letter)
	local image_format = letter.image_format
	for i = 1, letter.pages do
		output_page(id, letter_number, i, image_format)
	end
end
