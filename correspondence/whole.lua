local output_letter = require("correspondence.letter")

return function(id, participants, letters)
	do
		local i = 1
		local letter = letters[1]
		repeat
			output_letter(id, i, letter)
			
			i = i + 1
			letter = letters[i]
		until letter == nil
	end
end
