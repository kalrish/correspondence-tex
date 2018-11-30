local tostring = tostring

local month_names = {
	"January","February","March","April","May","June","July","August","September","October","November","December"
}

local numbersuffixes = {
	"st","nd","rd","th","th","th","th","th","th","th","th","th","th","th","th","th","th","th","th","th","st","nd","rd","th","th","th","th","th","th","th","st"
}

return {
	to = "to",
	make_date = function( day , month , year )
		return { tostring(day) , numbersuffixes[day] , " " , month_names[month] , " " , tostring(year) }
	end,
	received = "received",
	amendment = "Amendment",
--	locations = "Locations",
	page = "Page",
	pictures = "Pictures"
}