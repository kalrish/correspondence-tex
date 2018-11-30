local tostring = tostring

local month_names = {
	"Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember"
}

return {
	to = "an",
	make_date = function( day , month , year )
		return { "den " , tostring(day) , ". " , month_names[month] , " " , tostring(year) }
	end,
	received = "erhalten",
	amendment = "Verbesserung", -- Abänderung
--	locations = "Lugares",
	page = "Seite",
	pictures = "Fotografien"
}