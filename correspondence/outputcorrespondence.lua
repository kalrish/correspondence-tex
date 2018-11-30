local string = string
local string_utfvalues = string.utfvalues
local string_format = string.format
local math_max = math.max
local table_insert = table.insert
local tostring = tostring
local load = load
local io_open = io.open
local bit = require('bit')
local bit_rshift = bit.rshift
local bit_and = bit.band
local tex = tex
local tex_sprint = tex.sprint
local tex_write = tex.write
local tex_getcount = tex.getcount
local tex_setcount = tex.setcount
local tex_getbox = tex.getbox
local tex_setdimen = tex.setdimen
local img_scan = img.scan
local img_write = img.write
require('ltluatex')
local luatexbase = luatexbase


luatexbase.provides_module(
	{
		--name="correspondence",-- historic
		name="outputcorrespondence",
		date="2015/10/20"--wow, me ha dado por mirar la fecha y justo ahora (00:19) es 20 de octubre de 2016 (2016/10/20), justo un año… El destino. (Estaba revisando la cls, este lua module, und so and so)
	}
)


local lua_functions_table = lua.get_functions_table()

local luafunction_updateheaderheight = luatexbase.registernumber('correspondence@updateheaderheight')
--local luafunction_outputimage = luatexbase.registernumber('correspondence@outputimage')
local luafunction_beforeamendment = luatexbase.registernumber('correspondence@beforeamendment')
local luafunction_afteramendment = luatexbase.registernumber('correspondence@afteramendment')

lua_functions_table[luafunction_updateheaderheight] = function()
	local headl = tex_getbox('correspondence@headl')
	local headr = tex_getbox('correspondence@headr')
	tex_setdimen( 'global' , 'headheight' , math_max(
			headl.height+headl.depth,
			headr.height+headr.depth,
			tex.baselineskip.width
		)
	)
end

--lua_functions_table[luafunction_outputimage] = function()
--	local a = img_scan{ filename=filename , visiblefilename="" }
--	local ratio_between_originalwidth_maxwidth = a.width / (tex.dimen.textwidth-183500)
--	local ratio_between_originalheight_maxheight = a.height / (tex.dimen.textheight-249036)
--	local biggest_ratio = math_max( ratio_between_originalwidth_maxwidth , ratio_between_originalheight_maxheight )
--	a.width = a.width / biggest_ratio
--	a.height = a.height / biggest_ratio
--	img_write(a)
--end

local function increment_perletter_page_counter()
	tex_setcount( 'global' , 'correspondence@perletterpage' , tex_getcount('correspondence@perletterpage') + 1 )
end

lua_functions_table[luafunction_beforeamendment] = function()
	tex_setcount( 'global' , 'correspondence@perletterpage' , 1 )
	luatexbase.add_to_callback( 'finish_pdfpage' , increment_perletter_page_counter , 'correspondence.increment_perletter_page_counter' )
end

lua_functions_table[luafunction_afteramendment] = function()
	luatexbase.remove_from_callback( 'finish_pdfpage' , 'correspondence.increment_perletter_page_counter' )
end

local index = 1
local entry = _G[1]
while entry do
	index = index + 1
	entry = _G[index]
end
_G[index] = function( filename )
	local a = img_scan{ filename=filename , visiblefilename="" }
	local ratio_between_originalwidth_maxwidth = a.width / (tex.dimen.textwidth-183500)
	local ratio_between_originalheight_maxheight = a.height / (tex.dimen.textheight-249036)
	local biggest_ratio = math_max( ratio_between_originalwidth_maxwidth , ratio_between_originalheight_maxheight )
	a.width = a.width / biggest_ratio
	a.height = a.height / biggest_ratio
	img_write(a)
end
local outputimage_stretch_base10 = tostring(index)
index = index + 1
entry = _G[index]
while entry do
	index = index + 1
	entry = _G[index]
end
_G[index] = function( filename , ratio )
	local a = img_scan{ filename=filename , visiblefilename="" }
	a.width = a.width / ratio
	a.height = a.height / ratio
	img_write(a)
end
local outputimage_scale_base10 = tostring(index)

local catcodetableatletter = luatexbase.registernumber('catcodetable@atletter')
local luafunction_updateheaderheight_base10 = tostring(luafunction_updateheaderheight)
--local luafunction_outputimage_base10 = tostring(luafunction_outputimage)
local luafunction_beforeamendment_base10 = tostring(luafunction_beforeamendment)
local luafunction_afteramendment_base10 = tostring(luafunction_afteramendment)
local output_pdf = ( tex.outputmode == 1 )

local function UTF_8_to_escaped_UTF_16_as_table( s )
	local t = {}
	local n = 0
	
	for code_point in string_utfvalues(s) do
		n = n + 1
		if code_point < 0x10000 then
			t[n] = string_format("\\%03o\\%03o", bit_rshift(code_point,8), bit_and(code_point,255))
		else
			code_point = code_point - 0x10000
			local high_surrogate = bit_rshift(code_point,10) + 0xD800
			local low_surrogate = bit_and(code_point,1023) + 0xDC00
			t[n] = string_format("\\%03o\\%03o\\%03o\\%03o", bit_rshift(high_surrogate,8), bit_and(high_surrogate,255), bit_rshift(low_surrogate,8), bit_and(low_surrogate,255))
		end
	end
	
	return t
end

local use_full_names
local function name_short_or_full( name )
	if use_full_names == false then
		return name.short
	else
		return name.full
	end
end

local function outputletter_internal( text , from , to , lhead_additional , rhead )
	tex_sprint( catcodetableatletter , [[\sbox\correspondence@headl{\letterheaderfont{]] , from.headerfont , name_short_or_full(from.name) , [[} ]] , text.to , [[ {]] , to.headerfont , name_short_or_full(to.name) , [[}]] )
	if lhead_additional then
		tex_sprint( -2 , ", " )
		tex_sprint( catcodetableatletter , lhead_additional )
	end
	tex_sprint( catcodetableatletter , [[}\sbox\correspondence@headr{]] )
	if rhead then
		tex_sprint( catcodetableatletter , [[\letterreceivedfont]] )
		tex_sprint( catcodetableatletter , rhead )
	end
	tex_sprint( catcodetableatletter , [[}\luafunction]] , luafunction_updateheaderheight_base10 , [=[\checkandfixthelayout[fixed]]=] )
end

local directory_separator = string.match(package.config, "^([^\n]+)")
local directory_separator_appropriately_escaped = string.match(string_format("%q", directory_separator), "^\"(.+)\"$")

local UTF16BE_BOM = [[\376\377]]
local ucs_0020_as_UTF16BE = [[\000\040]]
local ucs_002C_as_UTF16BE = [[\000\054]]
local ucs_002E_as_UTF16BE = [[\000\056]]

return function()
	local everything_ok = true
	
	local parameters = {}
	local r1, r2 = loadfile( "parameters.texluajitbc" , "b" , parameters )
	if r1 then
		r1()
	else
		everything_ok = false
		error(r2)
	end
	
	local participants = {}
	r1, r2 = loadfile( "participants.texluajitbc" , "b" , participants )
	if r1 then
		r1()
	else
		everything_ok = false
		error(r2)
	end
	
	if everything_ok then
		local text = require( "correspondence.i18n." .. parameters.language )
		
		local text_page_as_UTF16BE = UTF_8_to_escaped_UTF_16_as_table(text.page)
		
		use_full_names = parameters.use_full_names
		
		local i = 1
		
		::outputletter::
		local i_base10 = tostring(i)
		local file = io_open( i_base10 .. directory_separator .. "letter.texluajitbc" , "rb" )
		if file then
			local file_contents = file:read("*a")
			if file_contents then
				local letter = {}
				r1, r2 = load( file_contents , i_base10 , "b" , letter )
				if r1 then
					r1()
					
					local letterdate = text.make_date( letter.sent.day , letter.sent.month , letter.sent.year )
					local rhead
					if letter.received then
						rhead = text.make_date( letter.received.day , letter.received.month , letter.received.year )
						table_insert( rhead , 1 , "(" )
						table_insert( rhead , 2 , text.received )
						table_insert( rhead , 3 , ": " )
						table_insert( rhead , ")" )
					end
					if output_pdf then
						tex_sprint( catcodetableatletter , [[\pdfextension outline goto page \the\c@page {/XYZ} ]] )
						local subs = letter.pages
						if letter.pictures then
							subs = subs + 1
						end
						if letter.amendment then
							subs = subs + 1
						end
						tex_write( "count -" , tostring(subs) )
						tex_sprint( catcodetableatletter , [[{]] )
						tex_write( UTF16BE_BOM )
						tex_write( UTF_8_to_escaped_UTF_16_as_table(i_base10) )
						tex_write( ucs_002E_as_UTF16BE )
						tex_write( ucs_0020_as_UTF16BE )
						tex_write( UTF_8_to_escaped_UTF_16_as_table(name_short_or_full(participants[letter.from.who].name)) )
						tex_write( ucs_0020_as_UTF16BE )
						tex_write( UTF_8_to_escaped_UTF_16_as_table(text.to) )
						tex_write( ucs_0020_as_UTF16BE )
						tex_write( UTF_8_to_escaped_UTF_16_as_table(name_short_or_full(participants[letter.to.who].name)) )
						tex_write( ucs_002C_as_UTF16BE , ucs_0020_as_UTF16BE )
						local i = 1
						local pdfoutline_additional_entry = letterdate[1]
						while pdfoutline_additional_entry do
							tex_write( UTF_8_to_escaped_UTF_16_as_table(pdfoutline_additional_entry) )
							
							i = i + 1
							pdfoutline_additional_entry = letterdate[i]
						end
						tex_sprint( catcodetableatletter , [[}]] )
					end
					outputletter_internal(
						text,
						participants[ letter.from.who ],
						participants[ letter.to.who ],
						letterdate,
						rhead,
						letterdate,
						0,
						letter.pages
					)
					for j = 1, letter.pages do
						local j_base10 = tostring(j)
						
						tex_sprint( catcodetableatletter , [[\def\correspondence@theperletterpage{]] , j_base10 , [[}\noindent{\centering\fboxrule=0.4pt \fboxsep=1pt \fbox{\directlua{]] )
						tex_write( "_G[" , outputimage_stretch_base10 , [[]("]] , i_base10 , directory_separator_appropriately_escaped , j_base10 , "." , letter.imagetype , [[")]] )
						tex_sprint( catcodetableatletter , [[}}\par}]] )
						if output_pdf then
							tex_sprint( catcodetableatletter , [[\pdfextension outline goto page \the\c@page {/XYZ} {]] )
							tex_write( UTF16BE_BOM )
							tex_write( text_page_as_UTF16BE )
							tex_write( ucs_0020_as_UTF16BE )
							tex_write( UTF_8_to_escaped_UTF_16_as_table(j_base10) )
							tex_sprint( catcodetableatletter , [[}]] )
						end
						
						if j < letter.pages then
							tex_sprint( catcodetableatletter , [[\newpage]] )
						end
					end
					
					if letter.pictures then
						tex_sprint( catcodetableatletter , [[\newpage\def\correspondence@theperletterpage{}]] )
						local nofpictures = #letter.pictures
						if output_pdf then
							tex_sprint( catcodetableatletter , [[\pdfextension outline goto page \the\c@page {/XYZ} ]] )
							tex_write( "count -" , tostring(nofpictures) )
							tex_sprint( catcodetableatletter , [[{]] )
							tex_write( UTF16BE_BOM )
							tex_write( UTF_8_to_escaped_UTF_16_as_table(text.pictures) )
							tex_sprint( catcodetableatletter , [[}]] )
						end
						local letter_picturenumberfont = letter.picturenumberfont
						local letter_skip_between_picture_number_and_picture = letter.skip_between_picture_number_and_picture
						local letter_picturecaptionfont = letter.picturecaptionfont
						local letter_skip_between_picture_and_picture_caption = letter.skip_between_picture_and_picture_caption
						for j = 1, nofpictures do
							local j_base10 = tostring(j)
							
							local picture = letter.pictures[j]
							
							if output_pdf then
								tex_sprint( catcodetableatletter , [[\pdfextension outline goto page \the\c@page {/XYZ} {]] )
								tex_write( UTF16BE_BOM )
								tex_write( UTF_8_to_escaped_UTF_16_as_table(j_base10) )
								tex_sprint( catcodetableatletter , [[}]] )
							end
							
							tex_sprint( catcodetableatletter , [[\begin{vplace}\noindent{\centering{]] , letter_picturenumberfont )
							tex_write( j_base10 )
							tex_sprint( catcodetableatletter , [[}\vskip]] , letter_skip_between_picture_number_and_picture , [[\leavevmode\directlua{]] )
							tex_write( "_G[" )
							if picture.scale then
								tex_write( outputimage_scale_base10 )
							else
								tex_write( outputimage_stretch_base10 )
							end
							tex_write( [[]("]] , i_base10 , directory_separator_appropriately_escaped , "pictures" , directory_separator_appropriately_escaped , j_base10 , [[.]] , picture.format , [["]] )
							if picture.scale then
								tex_write( "," , tostring(picture.scale) )
							end
							tex_sprint( catcodetableatletter , [[)}\vskip]] , letter_skip_between_picture_and_picture_caption , [[\noindent{]] , letter_picturecaptionfont )
							tex_write( picture.caption )
							tex_sprint( catcodetableatletter , [[}\par}\end{vplace}]] )
							
							if j < nofpictures then
								tex_sprint( catcodetableatletter , [[\newpage]] )
							end
						end
					end
					
					if letter.amendment then
						tex_sprint( catcodetableatletter , [[\newpage]] )
						if output_pdf then
							tex_sprint( catcodetableatletter , [[\pdfextension outline attr{/F 1} goto page \the\c@page {/XYZ} {]] )
							tex_write( UTF16BE_BOM )
							tex_write( UTF_8_to_escaped_UTF_16_as_table(text.amendment) )
							tex_sprint( catcodetableatletter , [[}]] )
						end
						outputletter_internal(
							text,
							participants[ letter.from.who ],
							participants[ letter.to.who ],
							nil,
							{ [[\amendmentfont]] , text.amended_version }
						)
						tex_sprint( catcodetableatletter , [[\def\correspondence@theperletterpage{\the\correspondence@perletterpage}\luafunction]] , luafunction_beforeamendment_base10 , [[\noindent{\input{]] )
						tex_write( i_base10 , directory_separator_appropriately_escaped , "amended" )
						tex_sprint( catcodetableatletter , [[}}\luafunction]] , luafunction_afteramendment_base10 )
					end
					
					tex_sprint( catcodetableatletter , [[\newpage]] )
				else
					error(r2)
				end
			else
				error("READ failure")
			end
			
			i = i + 1
			goto outputletter
		end
	end
end