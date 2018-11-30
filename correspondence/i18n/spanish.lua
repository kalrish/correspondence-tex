local tostring = tostring

local month_names = {
	"enero","febrero","marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre"
}

return {
	to = "a",
	make_date = function( day , month , year )
		return { tostring(day) , " de " , month_names[month] , " de " , tostring(year) }
	end,
	received = "recibido",
	amendment = "Enmienda",
--	locations = "Lugares",
	page = "Página",
	pictures = "Fotografías"
}