-- API Documentation can be found in README.txt
guideBooks = {}
local c = {}
guideBooks.registered = {}

c.register_guideBook = function(name, def)
	local _def = {}
	
	_def.description=def.description_short or string.split(name, ":")[1].." Guidebook"
	if def.description_long then _def.description=_def.description.."\n"..def.description_long end
	
	_def.inventory_image=def.inventory_image or "guidebooks_book.png"
	_def.wield_image=def.wield_image or _def.inventory_image
	
	_def.stack_max=1

	_def.style={}
	if def.style.cover then
		_def.style.cover={w=def.style.cover.w or 5, h=def.style.cover.h or 8, bg=def.style.cover.bg or "guidebooks_cover.png", next=def.style.cover.next or "guidebooks_nxtBtn.png"}
	else
		_def.style.cover={w=5, h=8, bg="guidebooks_cover.png", next="guidebooks_nxtBtn.png"}
	end
	if def.style.page then
		_def.style.page={w=def.style.page.w or 10, h=def.style.page.h or 8, bg=def.style.page.bg or "guidebooks_bg.png", next=def.style.page.next or "guidebooks_nxtBtn.png", prev=def.style.page.prev or "guidebooks_prvBtn.png", begn=def.style.page.start or "guidebooks_bgnBtn.png"}
	else
		_def.style.page= {w=10, h=8, bg="guidebooks_bg.png", next="guidebooks_nxtBtn.png", prev="guidebooks_prvBtn.png", begn="guidebooks_bgnBtn.png"}
	end
	
	_def.style.buttonGeneric=def.style.buttonGeneric or "guidebooks_bscBtn.png"
	
	_def.groups={book=1, guide=1, flammable=1}
	
	minetest.register_craft({
		type="fuel",
		recipe=name,
		burntime=30
	})
	
	_def.on_use=function(book, reader, pointed_thing)
		local meta=book:get_meta()
		local def=minetest.registered_items[book:get_name()]
		local reg=guideBooks.registered[book:get_name()]
		meta:set_string("guidebooks:place", nil)
		minetest.show_formspec(reader:get_player_name(), "guideBooks:book_"..book:get_name(), reg.coverTmp)
		return book
	end
	
	minetest.register_on_player_receive_fields(function(reader, formname, fields)
		local book=reader:get_wielded_item()
		local meta=book:get_meta()
		if formname=="guideBooks:book_"..book:get_name() then
			local def=minetest.registered_items[book:get_name()]
			local reg=guideBooks.registered[book:get_name()]
			local seg=string.split(meta:get_string("guidebooks:place"), ":")
			if fields.beginning then
				local y=-0.1
					x=1
					num=0
					local form=reg.pageTmp
					for _,v in pairs(reg.sections) do
						if  _ ~= "Main" and _ ~= "Hidden" then
							form=form.."style[goto_".._..";border=false]image_button["..x..","..y..";"..((def.style.page.w/2)-2)..",0.5;"..def.style.buttonGeneric..";goto_".._..";"..(v.description or _).."]"
							y=y+0.6
							num=num+1
							if num>13 then x=(def.style.page.w/2)+1 y=-0.1 num=0 end
						end
					end
					minetest.show_formspec(reader:get_player_name(), "guideBooks:book_"..book:get_name(), form)
					meta:set_string("guidebooks:place", "Main:Index")
			elseif fields.next then
				if #seg == 2 then
					local pn=tonumber(seg[2])
					if type(pn)=="number" then
						pn=pn+1
						if reg.sections[seg[1]] then
							if reg.sections[seg[1]].Pages[pn] then
								form=reg.sections[seg[1]].Pages[pn].form.."textarea[0.5,0.5;"..((def.style.page.w/2)-1)..","..(def.style.page.h-0.5)..";;;"..reg.sections[seg[1]].Pages[pn].text1.."]"
								form=form.."textarea["..((def.style.page.w/2)+0.5)..",0.5;"..((def.style.page.w/2)-0.5)..","..(def.style.page.h-0.5)..";;;"..reg.sections[seg[1]].Pages[pn].text2.."]"
								if reg.sections[seg[1]].Pages[pn+1] then
									form=form..reg.nextTmp
								end
								meta:set_string("guidebooks:place", seg[1]..":"..pn)
								minetest.show_formspec(reader:get_player_name(), "guideBooks:book_"..book:get_name(), form)
							else
								meta:set_string("guidebooks:place", nil)
								minetest.show_formspec(reader:get_player_name(), "guideBooks:book_"..book:get_name(), reg.coverTmp)
							end
						else
							meta:set_string("guidebooks:place", nil)
							minetest.show_formspec(reader:get_player_name(), "guideBooks:book_"..book:get_name(), reg.coverTmp)
						end
					else
						meta:set_string("guidebooks:place", nil)
						minetest.show_formspec(reader:get_player_name(), "guideBooks:book_"..book:get_name(), reg.coverTmp)
					end
				else
					local y=-0.1
					x=1
					num=0
					local form=reg.pageTmp
					for _,v in pairs(reg.sections) do
						if  _ ~= "Main" and _ ~= "Hidden" then
							form=form.."style[goto_".._..";border=false]image_button["..x..","..y..";"..((def.style.page.w/2)-2)..",0.5;"..def.style.buttonGeneric..";goto_".._..";"..(v.description or _).."]"
							y=y+0.6
							num=num+1
							if num>13 then x=(def.style.page.w/2)+1 y=-0.1 num=0 end
						end
					end
					minetest.show_formspec(reader:get_player_name(), "guideBooks:book_"..book:get_name(), form)
					meta:set_string("guidebooks:place", "Main:Index")
				end
				reader:set_wielded_item(book)
			elseif fields.prev then
				if #seg == 2 then
					local pn=tonumber(seg[2])
					if type(pn)=="number" then
						pn=pn-1
						if reg.sections[seg[1]] then
							if reg.sections[seg[1]].Pages[pn] then
								form=reg.sections[seg[1]].Pages[pn].form.."textarea[0.5,0.5;"..((def.style.page.w/2)-1)..","..(def.style.page.h-0.5)..";;;"..reg.sections[seg[1]].Pages[pn].text1.."]"
								form=form.."textarea["..((def.style.page.w/2)+0.5)..",0.5;"..((def.style.page.w/2)-0.5)..","..(def.style.page.h-0.5)..";;;"..reg.sections[seg[1]].Pages[pn].text2.."]"
								if reg.sections[seg[1]].Pages[pn+1] then
									form=form..reg.nextTmp
								end
								meta:set_string("guidebooks:place", seg[1]..":"..pn)
								minetest.show_formspec(reader:get_player_name(), "guideBooks:book_"..book:get_name(), form)
							else
								if meta:get_string("guidebooks:place")=="Main:Index" then
									meta:set_string("guidebooks:place", nil)
									minetest.show_formspec(reader:get_player_name(), "guideBooks:book_"..book:get_name(), reg.coverTmp)
								else
									local y=-0.1
									x=1
									num=0
									local form=reg.pageTmp
									for _,v in pairs(reg.sections) do
										if  _ ~= "Main" and _ ~= "Hidden" then
											form=form.."style[goto_".._..";border=false]image_button["..x..","..y..";"..((def.style.page.w/2)-2)..",0.5;"..def.style.buttonGeneric..";goto_".._..";"..(v.description or _).."]"
											y=y+0.6
											num=num+1
											if num>13 then x=(def.style.page.w/2)+1 y=-0.1 num=0 end
										end
									end
									minetest.show_formspec(reader:get_player_name(), "guideBooks:book_"..book:get_name(), form)
									meta:set_string("guidebooks:place", "Main:Index")
								end
							end
						else
							if meta:get_string("guidebooks:place")=="Main:Index" then
								meta:set_string("guidebooks:place", nil)
								minetest.show_formspec(reader:get_player_name(), "guideBooks:book_"..book:get_name(), reg.coverTmp)
							else
								local y=-0.1
								x=1
								num=0
								local form=reg.pageTmp
								for _,v in pairs(reg.sections) do
									if  _ ~= "Main" and _ ~= "Hidden" then
										form=form.."style[goto_".._..";border=false]image_button["..x..","..y..";"..((def.style.page.w/2)-2)..",0.5;"..def.style.buttonGeneric..";goto_".._..";"..(v.description or _).."]"
										y=y+0.6
										num=num+1
										if num>13 then x=(def.style.page.w/2)+1 y=-0.1 num=0 end
									end
								end
								minetest.show_formspec(reader:get_player_name(), "guideBooks:book_"..book:get_name(), form)
								meta:set_string("guidebooks:place", "Main:Index")
							end
						end
					else
						if meta:get_string("guidebooks:place")=="Main:Index" then
							meta:set_string("guidebooks:place", nil)
							minetest.show_formspec(reader:get_player_name(), "guideBooks:book_"..book:get_name(), reg.coverTmp)
						else
							local y=-0.1
							x=1
							num=0
							local form=reg.pageTmp
							for _,v in pairs(reg.sections) do
								if  _ ~= "Main" and _ ~= "Hidden" then
									form=form.."style[goto_".._..";border=false]image_button["..x..","..y..";"..((def.style.page.w/2)-2)..",0.5;"..def.style.buttonGeneric..";goto_".._..";"..(v.description or _).."]"
									y=y+0.6
									num=num+1
									if num>13 then x=(def.style.page.w/2)+1 y=-0.1 num=0 end
								end
							end
							minetest.show_formspec(reader:get_player_name(), "guideBooks:book_"..book:get_name(), form)
							meta:set_string("guidebooks:place", "Main:Index")
						end
					end
				end
				reader:set_wielded_item(book)
			else
				for _,v in pairs(reg.sections) do
					if fields["goto_".._] then
						if v.Pages[1] then
							form=v.Pages[1].form.."textarea[0.5,0.5;"..((def.style.page.w/2)-1)..","..(def.style.page.h-0.5)..";;;"..v.Pages[1].text1.."]"
							form=form.."textarea["..((def.style.page.w/2)+0.5)..",0.5;"..((def.style.page.w/2)-0.5)..","..(def.style.page.h-0.5)..";;;"..v.Pages[1].text2.."]"
							if v.Pages[2] then
								form=form..reg.nextTmp
							end
							meta:set_string("guidebooks:place", _..":".."1")
							minetest.show_formspec(reader:get_player_name(), "guideBooks:book_"..book:get_name(), form)
						end
					end
				end
				reader:set_wielded_item(book)
			end
		end
	end)
	
	local cover=""..
	"size[".._def.style.cover.w..",".._def.style.cover.h.."]"..
	"background[0,0;0,0;".._def.style.cover.bg..";true]"..
	"style[next;border=false]"..
	"image_button["..(_def.style.cover.w-0.7)..","..(_def.style.cover.h-0.5)..";1,1;".._def.style.cover.next..";next;]"
	local page=""..
	"size[".._def.style.page.w..",".._def.style.page.h.."]"..
	"background[0,0;0,0;".._def.style.page.bg..";true]"..
	"style[beginning;border=false]image_button[-0.3,-0.3;1,1;".._def.style.page.begn..";beginning;]"
	
	local next="style[next;border=false]image_button["..(_def.style.page.w-0.7)..","..(_def.style.page.h-0.5)..";1,1;".._def.style.page.next..";next;]"
	local prev="style[prev;border=false]image_button[0,"..(_def.style.page.h-0.5)..";1,1;".._def.style.page.prev..";prev;]"
	
	page=page..prev
	
	guideBooks.registered[name]={coverTmp=cover, pageTmp=page, nextTmp=next, prevTmp=prev, sections={Main={Pages={Index={}}}, Hidden={Pages={}}}}
	
	minetest.register_craftitem(name, _def)
end

c.register_section = function(book, name, def)
	if guideBooks.registered[book] then
		def.Pages={}
		guideBooks.registered[book].sections[name]=def
	else
		error("Attempt to register section in non-existent guide")
	end
end

c.register_page = function(book, section, num, def)
	if guideBooks.registered[book] then
		if guideBooks.registered[book].sections[section] then
			local _def={}
			_def.form =def.form or guideBooks.registered[book].pageTmp
			if def.extra then _def.form=_def.form..def.extra end
			_def.text1 = def.text1 or ""
			_def.text2 = def.text2 or ""
			guideBooks.registered[book].sections[section].Pages[num]=_def
		else
			error("Attempt to register page in non-existent section")
		end
	else
		error("Attempt to register page in non-existent guide")
	end
end

guideBooks.Common=c

guideBooks.Common.register_guideBook("guidebooks:test", {description_long="A book about books", style={cover={bg="guidebooks_cover.png^guidebooks_title.png"}}})

guideBooks.Common.register_section("guidebooks:test", "a", {description="Section a"})
guideBooks.Common.register_section("guidebooks:test", "b", {description="Section b"})
guideBooks.Common.register_section("guidebooks:test", "c", {description="Section c"})

guideBooks.Common.register_page("guidebooks:test", "a", 1, {text1="Some text", text2="Some other text"})

guideBooks.Common.register_page("guidebooks:test", "b", 1, {text1="A page", text2=""})
guideBooks.Common.register_page("guidebooks:test", "b", 2, {text1="Another", text2=""})

guideBooks.Common.register_page("guidebooks:test", "c", 1, {text1="", text2="An image", extra="background[0,0;5,8;guidebooks_map.png;false]"})

for i=1,25 do
	guideBooks.Common.register_section("guidebooks:test", ""..i, {description="Empty Section"})
end