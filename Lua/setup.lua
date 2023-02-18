table.insert(editor_objlist_order, "text_facedby")
table.insert(editor_objlist_order, "text_seenby")
table.insert(editor_objlist_order, "text_being")
table.insert(editor_objlist_order, "text_having")
table.insert(editor_objlist_order, "text_making")
table.insert(editor_objlist_order, "text_writing")
table.insert(editor_objlist_order, "text_eating")
table.insert(editor_objlist_order, "text_mimicing")
table.insert(editor_objlist_order, "text_fearing")
table.insert(editor_objlist_order, "text_followin")

table.insert(editor_objlist_order, "text_become")
table.insert(editor_objlist_order, "text_feel")
table.insert(editor_objlist_order, "text_no")
table.insert(editor_objlist_order, "text_grow")
table.insert(editor_objlist_order, "text_fakeyou")
table.insert(editor_objlist_order, "text_fakeyou2")
table.insert(editor_objlist_order, "text_falldir")
table.insert(editor_objlist_order, "text_hold")
table.insert(editor_objlist_order, "text_use")
table.insert(editor_objlist_order, "text_use2")
table.insert(editor_objlist_order, "text_use3")
table.insert(editor_objlist_order, "text_throw")
table.insert(editor_objlist_order, "text_throw2")
table.insert(editor_objlist_order, "text_throw3")
table.insert(editor_objlist_order, "text_fixed")
table.insert(editor_objlist_order, "text_horiz")
table.insert(editor_objlist_order, "text_vert")
table.insert(editor_objlist_order, "text_reversehoriz")
table.insert(editor_objlist_order, "text_reversevert")
table.insert(editor_objlist_order, "text_")
table.insert(editor_objlist_order, "text_self")

--objects
table.insert(editor_objlist_order, "blossom")
table.insert(editor_objlist_order, "text_blossom")
table.insert(editor_objlist_order, "i2")
table.insert(editor_objlist_order, "text_i2")
table.insert(editor_objlist_order, "text_am")
table.insert(editor_objlist_order, "oyou")
table.insert(editor_objlist_order, "text_oyou")
table.insert(editor_objlist_order, "we")
table.insert(editor_objlist_order, "text_we")
table.insert(editor_objlist_order, "they")
table.insert(editor_objlist_order, "text_they")
table.insert(editor_objlist_order, "text_are")
table.insert(editor_objlist_order, "text_have")

editor_objlist["text_no"] = 
{
	name = "text_no",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_quality","danger"},
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
	tags = {"text_condition"},
	tiling = -1,
	type = 7,
	layer = 20,
	colour = {0, 2},
	colour_active = {0, 3},
	argtype = {0}
}

editor_objlist["text_seenby"] = 
{
	name = "text_seenby",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_condition"},
	tiling = -1,
	type = 7,
	layer = 20,
	colour = {0, 2},
	colour_active = {0, 3},
	argtype = {0}
}

editor_objlist["text_having"] = 
{
	name = "text_having",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_condition"},
	tiling = -1,
	type = 7,
	layer = 20,
	colour = {0, 2},
	colour_active = {0, 3},
	argtype = {0}
}

editor_objlist["text_being"] = 
{
	name = "text_being",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_condition"},
	tiling = -1,
	type = 7,
	layer = 20,
	colour = {0, 2},
	colour_active = {0, 3},
	argtype = {0}
}

editor_objlist["text_writing"] = 
{
	name = "text_writing",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_condition"},
	tiling = -1,
	type = 7,
	layer = 20,
	colour = {0, 2},
	colour_active = {0, 3},
	argtype = {0, 2}
}

editor_objlist["text_eating"] = 
{
	name = "text_eating",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_condition"},
	tiling = -1,
	type = 7,
	layer = 20,
	colour = {0, 2},
	colour_active = {0, 3},
	argtype = {0}
}

editor_objlist["text_mimicing"] = 
{
	name = "text_mimicing",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_condition"},
	tiling = -1,
	type = 7,
	layer = 20,
	colour = {0, 2},
	colour_active = {0, 3},
	argtype = {0}
}

editor_objlist["text_making"] = 
{
	name = "text_making",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_condition"},
	tiling = -1,
	type = 7,
	layer = 20,
	colour = {0, 2},
	colour_active = {0, 3},
	argtype = {0}
}

editor_objlist["text_fearing"] = 
{
	name = "text_fearing",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_condition"},
	tiling = -1,
	type = 7,
	layer = 20,
	colour = {0, 2},
	colour_active = {0, 3},
	argtype = {0}
}

editor_objlist["text_followin"] = 
{
	name = "text_followin",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_condition"},
	tiling = -1,
	type = 7,
	layer = 20,
	colour = {0, 2},
	colour_active = {0, 3},
	argtype = {0}
}

editor_objlist["text_grow"] = 
{
	name = "text_grow",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_quality", "text_special"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {5, 0},
	colour_active = {5, 2},
}

editor_objlist["text_self"] = 
{
	name = "text_self",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_quality", "text_special"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {4,0},
	colour_active = {4, 1},
}

editor_objlist["text_fakeyou"] = 
{
	name = "text_fakeyou",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_quality","text_special","movement"},
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
	tags = {"text_quality","text_special","movement"},
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
	tags = {"text_quality","sky","movement"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {5, 1},
	colour_active = {5, 3},
}

editor_objlist["text_hold"] = 
{
	name = "text_hold",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_quality","movement"},
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
	tags = {"text_verb"},
	tiling = -1,
	type = 1,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 3},
	argtype = {0, 2}
}

editor_objlist["text_are"] = 
{
	name = "text_are",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_verb"},
	tiling = -1,
	type = 1,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 3},
	argtype = {0, 2}
}

editor_objlist["text_have"] = 
{
	name = "text_have",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_verb"},
	tiling = -1,
	type = 1,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 3},
	argtype = {0}
}

editor_objlist["text_use"] = 
{
	name = "text_use",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_special"},
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
	tags = {"text_special"},
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
	tags = {"text_special"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {5, 2},
	colour_active = {5, 3},
}

editor_objlist["text_throw"] = 
{
	name = "text_throw",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_special"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {3, 2},
	colour_active = {3, 3},
}

editor_objlist["text_throw2"] = 
{
	name = "text_throw2",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_special"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {2, 1},
	colour_active = {2, 2},
}

editor_objlist["text_throw3"] = 
{
	name = "text_throw3",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_special"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {5, 2},
	colour_active = {5, 3},
}

editor_objlist["text_fixed"] = 
{
	name = "text_fixed",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_quality","abstract"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {4, 0},
	colour_active = {4, 1},
}

editor_objlist["text_horiz"] = 
{
	name = "text_horiz",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_quality","movement"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {1, 3},
	colour_active = {1, 4},
}

editor_objlist["text_vert"] = 
{
	name = "text_vert",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_quality","movement"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {1, 3},
	colour_active = {1, 4},
}

editor_objlist["text_become"] = 
{
	name = "text_become",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_verb"},
	tiling = -1,
	type = 1,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 3},
	argtype = {0},
	argextra = {"self"}
}

editor_objlist["text_feel"] = 
{
	name = "text_feel",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_verb"},
	tiling = -1,
	type = 1,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 3},
	argtype = {2}
}

editor_objlist["text_reversehoriz"] = 
{
	name = "text_reversehoriz",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_quality","movement"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {5, 2},
	colour_active = {5, 3},
}

editor_objlist["text_reversevert"] = 
{
	name = "text_reversevert",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_quality","movement"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {5, 2},
	colour_active = {5, 3},
}

editor_objlist["text_"] = 
{
	name = "text_",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text_quality", "text_special"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 3},
}

-- objects
editor_objlist["blossom"] = 
{
	name = "blossom",
	sprite_in_root = true,
	unittype = "object",
	tags = {"plant","decorative","abstract"},
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
	tags = {"plant","decorative","abstract"},
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
	tags = {"animal"},
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
	tags = {"animal"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {1, 2},
	colour_active = {1, 4},
}

editor_objlist["we"] = 
{
	name = "we",
	sprite_in_root = false,
	unittype = "object",
	tags = {"animal"},
	tiling = 2,
	type = 0,
	layer = 18,
	colour = {1, 4},
}
editor_objlist["text_we"] = 
{
	name = "text_we",
	sprite_in_root = false,
	unittype = "text",
	tags = {"animal"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {1, 2},
	colour_active = {1, 4},
}

editor_objlist["they"] = 
{
	name = "they",
	sprite_in_root = false,
	unittype = "object",
	tags = {"animal"},
	tiling = 2,
	type = 0,
	layer = 18,
	colour = {2, 2},
}
editor_objlist["text_they"] = 
{
	name = "text_they",
	sprite_in_root = false,
	unittype = "text",
	tags = {"animal"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {2, 1},
	colour_active = {2, 2},
}

editor_objlist["oyou"] = 
{
	name = "oyou",
	sprite_in_root = false,
	unittype = "object",
	tags = {"abstract"},
	tiling = 2,
	type = 0,
	layer = 18,
	colour = {4, 1},
}
editor_objlist["text_oyou"] = 
{
	name = "text_oyou",
	sprite_in_root = false,
	unittype = "text",
	tags = {"abstract"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {4, 0},
	colour_active = {4, 1},
}

editor_objlist[151].argextra = {"right","up","left","down", "horiz", "vert"}
editor_objlist[161].argextra = {"self"}
editor_objlist[244].argextra = {"self"}

table.insert(mod_hook_functions["rule_baserules"],
	function()
		addbaserule("oyou","is","you")
	end
)

formatobjlist()