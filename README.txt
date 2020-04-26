guidebooks (c) by PolySaken

guidebooks is licensed under a
Creative Commons Attribution-ShareAlike 4.0 International License.

You should have received a copy of the license along with this
work. If not, see http://creativecommons.org/licenses/by-sa/4.0/

-- API --

- Creating a new book 
guideBooks.Common.register_guideBook("modname:itemname", { --modname is the name of your mod, itemname is whatever you want
	description_short="Book",                              -- The name of your book
	description_long="A book about books",                 -- an optional field to give your book an extra description
	inventory_image="modname_book.png",                    -- The image of the book when in the inventory
	wield_image="modname_book_wield.png",                  -- An optional image of the book when in the hand
	style={                                                -- a table of values that describe how your book looks
		cover={                                            --- The very first page of your book
			w=5,                                           ---- how wide should the cover be?
			h=8,                                           ---- how tall should the cover be? 
			bg="modname_cover.png",                        ---- the file name of an image to use for the cover
			next="modname_next.png"                        ---- the filename of an image to use for the 'next page' button
		},
		page={                                             --- The generic page style
			w=10,                                          ---- How wide is the book? (2*cover width works best)
			h=8,                                           ---- How tall is the book? (usually same as cover height)
			bg="modname_bg.png",                           ---- the background image for the open book
			next="modname_next.png",                       ---- the filename of an image to use for the 'next page' button
			prev="modname_prev.png",                       ---- the filename of an image to use for the 'previous page' button
			start="modname_start.png"                      ---- the filename of an image to use for the 'first page' button
		},
		buttonGeneric="modname_button.png",                --- A generic button image
	},
	ptype=false,						-- When true, the book will only display text1 on each page
})


-- Adding a section 
currently a maximum of 28 sections per index is supported, meaning a book can store 784 sections if all of the sections in the main index are masters.
(this can be circumvented by building custom directories using the 'extra' field of a page, but is not recommended)

guideBooks.Common.register_section(
	"modname:itemname",             -- The name of a registered book
	"section_1",                    -- The name to give the section, only string values supported
	{                               -- A list of preset values (you could also put page definitions here.)
		description="Section 1",    --- The display name of the section
		hidden=false,               --- Whether the section is visible in the main index (set to true to hide)
		master=false,               --- Whether this section leads to an index (set to true to create a new index under this section)
		slave=false,                --- Set to false to show in the main index, set to the name of another section to show in that index. cannot be used with master=true
		Pages={                		--- The pages to preload into the section (use only for certain instances when required)
			Index={}                ---- A special page used only by the 'Main' section that loads after the cover
		},
		locked=false                --- If this is true, only players with the meta field <bookItem>:<sectionName>:unlocked=="true" will be able to see this section
	}
)

The sections 'Hidden' and 'Main' exist in any book by default

-- adding pages
guideBooks.Common.register_page(
	"modname:itemname",                                       -- The name of a registered book
	"section_1",                                              -- The name of a section in the book
	1,                                                        -- the page number (or name in the case of special pages such as Index)
	{                                                         -- content definition
		text1="foo bar",                                      --- the text to display on the first half of the page
		text2="lorem ipsum dolor sit amet",                   --- the text to display on the second half of the page
		extra="background[0,0;5,8;modname_image.png;false]"   --- A minetest formspec string used to add extra content to a page, such as an image
	}
)

The page 'Index' exists in the 'Main' section by default but can be overriden.
