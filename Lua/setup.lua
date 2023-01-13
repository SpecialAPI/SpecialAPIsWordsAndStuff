table.insert(editor_objlist_order, "text_no")
table.insert(editor_objlist_order, "text_facedby")
table.insert(editor_objlist_order, "text_grow")
table.insert(editor_objlist_order, "text_fakeyou")
table.insert(editor_objlist_order, "text_fakeyou2")
table.insert(editor_objlist_order, "text_falldir")
table.insert(editor_objlist_order, "text_having")
table.insert(editor_objlist_order, "text_hold")
table.insert(editor_objlist_order, "text_am")
table.insert(editor_objlist_order, "text_use")
table.insert(editor_objlist_order, "text_use2")
table.insert(editor_objlist_order, "text_use3")

--objects
table.insert(editor_objlist_order, "blossom")
table.insert(editor_objlist_order, "text_blossom")
table.insert(editor_objlist_order, "i2")
table.insert(editor_objlist_order, "text_i2")

editor_objlist["text_no"] = 
{
	name = "text_no",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {2, 0},
	colour_active = {2, 1},
}

editor_objlist["text_facedby"] = 
{
	name = "text_facedby",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 7,
	layer = 20,
	colour = {0, 2},
	colour_active = {0, 3},
}

editor_objlist["text_grow"] = 
{
	name = "text_grow",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {5, 0},
	colour_active = {5, 2},
}

editor_objlist["text_fakeyou"] = 
{
	name = "text_fakeyou",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {3, 0},
	colour_active = {3, 1},
}

editor_objlist["text_fakeyou2"] = 
{
	name = "text_fakeyou2",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {3, 0},
	colour_active = {3, 1},
}

editor_objlist["text_falldir"] = 
{
	name = "text_falldir",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {5, 1},
	colour_active = {5, 3},
}

editor_objlist["text_having"] = 
{
	name = "text_having",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 7,
	layer = 20,
	colour = {0, 2},
	colour_active = {0, 3},
}

editor_objlist["text_hold"] = 
{
	name = "text_hold",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {2, 1},
	colour_active = {2, 2},
}

editor_objlist["text_am"] = 
{
	name = "text_am",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 1,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 3},
}

editor_objlist["text_use"] = 
{
	name = "text_use",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {3, 2},
	colour_active = {3, 3},
}

editor_objlist["text_use2"] = 
{
	name = "text_use2",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {2, 1},
	colour_active = {2, 2},
}

editor_objlist["text_use3"] = 
{
	name = "text_use3",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {5, 2},
	colour_active = {5, 3},
}

-- objects
editor_objlist["blossom"] = 
{
	name = "blossom",
	sprite_in_root = false,
	unittype = "object",
	tags = {"garden"},
	tiling = -1,
	type = 0,
	layer = 16,
	colour = {0, 3},
}
editor_objlist["text_blossom"] = 
{
	name = "text_blossom",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {0, 2},
	colour_active = {0, 3},
}
editor_objlist["i2"] = 
{
	name = "i2",
	sprite_in_root = false,
	unittype = "object",
	tags = {"garden"},
	tiling = 2,
	type = 0,
	layer = 18,
	colour = {1, 4},
}
editor_objlist["text_i2"] = 
{
	name = "text_i2",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {1, 2},
	colour_active = {1, 4},
}

formatobjlist()