function formlettermap()
	letterunits_map = {}
	
	local lettermap = {}
	local letterunitlist = {}
	
	if (#letterunits > 0) then
		for i,unitid in ipairs(letterunits) do
			local unit = mmf.newObject(unitid)
			
			if (unit.values[TYPE] == 5) and (unit.flags[DEAD] == false) then
				local x,y = unit.values[XPOS],unit.values[YPOS]
				local tileid = x + y * roomsizex
				
				local name = string.sub(unit.strings[UNITNAME], 6)
				
				if (lettermap[tileid] == nil) then
					lettermap[tileid] = {}
				end
				
				table.insert(lettermap[tileid], {name, unitid})
			end
		end
		
		for tileid,v in pairs(lettermap) do
			local x = math.floor(tileid % roomsizex)
			local y = math.floor(tileid / roomsizex)
			
			local ux,uy = x,y-1
			local lx,ly = x-1,y
			local dx,dy = x,y+1
			local rx,ry = x+1,y
			
			local tidr = rx + ry * roomsizex
			local tidu = ux + uy * roomsizex
			local tidl = lx + ly * roomsizex
			local tidd = dx + dy * roomsizex
			
			local continuer = false
			local continued = false
			
			if (lettermap[tidr] ~= nil) then
				continuer = true
			end
			
			if (lettermap[tidd] ~= nil) then
				continued = true
			end
			
			if (#cobjects > 0) then
				for a,b in ipairs(v) do
					local n = b[1]
					if (cobjects[n] ~= nil) or (n == "i") then
						continuer = true
						continued = true
						break
					end
				end
			else
				for a,b in ipairs(v) do
					local n = b[1]
					if (n == "i") then
						continuer = true
						continued = true
						break
					end
				end
			end
			
			if (lettermap[tidl] == nil) and continuer then
				letterunitlist = formletterunits(x,y,lettermap,1,letterunitlist)
			end
			
			if (lettermap[tidu] == nil) and continued then
				letterunitlist = formletterunits(x,y,lettermap,2,letterunitlist)
			end
		end
		
		if (unitreference["text_play"] ~= nil) then
			letterunitlist = cullnotes(letterunitlist)
		end
		
		for i,v in ipairs(letterunitlist) do
			local x = v[3]
			local y = v[4]
			local w = v[6]
			local dir = v[5]
			
			local dr = dirs[dir]
			local ox,oy = dr[1],dr[2]
			
			--[[
			MF_debug(x,y,1)
			MF_alert("In database: " .. v[1] .. ", dir " .. tostring(v[5]))
			]]--
			
			local tileid = x + y * roomsizex
			
			if (letterunits_map[tileid] == nil) then
				letterunits_map[tileid] = {}
			end
			
			table.insert(letterunits_map[tileid], {v[1], v[2], v[3], v[4], v[5], v[6], v[7]})
			
			if (w > 1) then
				local endtileid = (x + ox * (w - 1)) + (y + oy * (w - 1)) * roomsizex
				
				if (letterunits_map[endtileid] == nil) then
					letterunits_map[endtileid] = {}
				end
				
				table.insert(letterunits_map[endtileid], {v[1], v[2], v[3], v[4], v[5], v[6], v[7]})
			end
		end
	end
end

function cullnotes(database_)
	local database = database_
	local freqs = play_data.freqs
	
	local comparison = {}
	local delthese = {}
	
	local specialcases =
	{
		bsharp = 1,
		esharp = 1,
		cflat_ = 1,
		fflat_ = 1,
	}
	
	for i,v in ipairs(database) do
		local w = v[1]
		local sw = string.sub(w .. "_", 1, 6)
		
		if (freqs[w] ~= nil) or (specialcases[sw] ~= nil) then
			local tileid = v[3] + v[4] * roomsizex + (v[5] - 1) * roomsizex * roomsizey
			
			if (comparison[tileid] == nil) then
				comparison[tileid] = {}
				comparison[tileid]["longest"] = #w
			end
			
			comparison[tileid]["longest"] = math.max(#w, comparison[tileid]["longest"])
			
			--MF_alert("Adding " .. w .. ", dir " .. tostring(v[5]) .. " to " .. tostring(tileid) .. ", longest " .. tostring(comparison[tileid]["longest"]))
			
			table.insert(comparison[tileid], {#w, i})
		end
	end
	
	for i,v in pairs(comparison) do
		for a,b in ipairs(v) do
			if (b[1] < v.longest) then
				table.insert(delthese, b[2])
			end
		end
	end
	
	table.sort(delthese)
	
	local i = #delthese
	
	for j=1,#delthese do
		local c = delthese[i]
		
		--MF_alert("Deleting " .. tostring(c) .. ", " .. database[c][1])
		
		table.remove(database, c)
		
		i = i - 1
	end
	
	return database
end

function formletterunits(x,y,lettermap,dir,database_)
	local dr = dirs[dir]
	local ox,oy = dr[1],dr[2]
	local cx,cy = x,y
	
	local jumble = {}
	local jumblecombo = {}
	local totalcombos = 1
	local done = false
	
	local database = database_
	
	while (done == false) do
		local tileid = cx + cy * roomsizex
		
		if (lettermap[tileid] ~= nil) then
			table.insert(jumble, {})
			local cjumble = jumble[#jumble]
			
			for i,v in ipairs(lettermap[tileid]) do
				table.insert(cjumble, {v[1], v[2]})
			end
			
			table.insert(jumblecombo, 0)
			totalcombos = totalcombos * #cjumble
			
			cx = cx + ox
			cy = cy + oy
		else
			done = true
		end
	end
	
	local been_seen = {}
	
	if (#jumble > 0) then
		for j=1,totalcombos do
			local word = ""
			local subword = ""
			local prevword = ""
			local prevwordid = 0
			local wordids = {}
			local branches = {}
			local offset = 0
			local updatecombo = true
			
			for i,cjumble in ipairs(jumble) do
				local ccombo = jumblecombo[i] + 1
				local cword = cjumble[ccombo]
				
				word = word .. cword[1]
				if (i > 1) then
					subword = prevword .. cword[1]
				end
				
				if updatecombo then
					jumblecombo[i] = jumblecombo[i] + 1
					
					if (jumblecombo[i] >= #cjumble) then
						jumblecombo[i] = 0
						updatecombo = true
					else
						updatecombo = false
					end
				end
				
				local found,fullwords,partwords = findletterwords(word,i - 1,subword)
				
				for a,b in ipairs(partwords) do
					table.insert(branches, {prevword, i - 2, false, {prevwordid}})
				end
				
				prevword = cword[1]
				prevwordid = cword[2]
				
				-- MF_alert(tostring(j) .. " Currently " .. word .. ", " .. subword .. ", " .. prevword .. ", " .. tostring(dir))
				
				for a,b in ipairs(branches) do
					local w = b[1]
					local pos = b[2]
					local dead = b[3]
					local wids = b[4]
					w = w .. cword[1]
					b[1] = w
					
					table.insert(b[4], cword[2])
					
					if (dead == false) then
						local sfound,sfullwords = findletterwords(w,i - 1,nil,false)
						
						if (sfound == false) then
							b[3] = true
							
							if (#b[4] > 0) then
								table.remove(b[4], #b[4])
							end
						else
							if (#sfullwords > 0) then
								for c,d in ipairs(sfullwords) do
									local w = d[1]
									local t = d[2]
									local wordcode = w .. tostring(pos)
									
									local fwids = {}
									for c,d in ipairs(b[4]) do
										table.insert(fwids, d)
									end
									
									if (been_seen[wordcode] == nil) then
										been_seen[wordcode] = 1
										
										table.insert(database, {w, t, x + ox * pos, y + oy * pos, dir, #fwids, fwids})
									end
								end
							end
						end
					end
				end
				
				if (found == false) then
					if (string.len(word) > 0) and (#wordids > 0) then
						word = string.sub(word, -1)
						
						local wid = wordids[#wordids]
						wordids = {wid}
						
						offset = i - 1
					end
				else
					if (#fullwords > 0) then
						for a,b in ipairs(fullwords) do
							local w = b[1]
							if(w == "text_i2") then
								local t = b[2]
								local pos = b[3]
								local wordcode = w .. tostring(pos)
								
								local fwids = {cword[2]}
								
								if (been_seen[wordcode] == nil) then
									been_seen[wordcode] = 1
									
									table.insert(database, {w, t, x + ox * pos, y + oy * pos, dir, #fwids, fwids})
								end
							else
								local t = b[2]
								local pos = b[3]
								local fulloffset = offset + pos
								local wordcode = w .. tostring(fulloffset)
								
								local fwids = {}
								for c,d in ipairs(wordids) do
									table.insert(fwids, d)
								end
								
								if (been_seen[wordcode] == nil) then
									been_seen[wordcode] = 1
									
									--MF_alert("Adding to database: " .. w .. ", " .. tostring(dir) .. ", " .. wordcode)
									table.insert(database, {w, t, x + ox * fulloffset, y + oy * fulloffset, dir, #fwids, fwids})
								end
							end
						end
					end
				end
			end
		end
	end
	
	return database
end

function findletterwords(word_,wordpos_,subword_,mainbranch_)
	local word = word_
	local subword = subword_
	local wordpos = wordpos_ or 0
	local mainbranch = true
	local found = false
	local foundsub = false
	local fullwords = {}
	local fullwords_c = {}
	local newbranches = {}
	
	if (mainbranch_ ~= nil) then
		mainbranch = mainbranch_
	end
	
	local result = {}
	
	if (string.len(word) > 1) or (word == "i") then
		for i,v in pairs(unitreference) do
			local name = i
			
			if (string.len(name) > 5) and (string.sub(name, 1, 5) == "text_") then
				name = string.sub(name, 6)
			end
			
			if (string.len(word) <= string.len(name)) and (string.sub(name, 1, string.len(word)) == word) then
				if (string.len(word) == string.len(name)) then
					table.insert(fullwords, {name, 0})
					found = true
				else
					found = true
				end
			end
			
			if (wordpos > 0) and ((string.len(word) >= 2) or (word == "i")) and mainbranch then
				if (string.len(name) >= string.len(subword)) and (string.sub(name, 1, string.len(subword)) == subword) then
					--[[
					if (subword == name) then
						table.insert(fullwords, {name, wordpos + 1})
						foundsub = true
					else
						table.insert(newbranches, {subword, wordpos})
						foundsub = true
					end
					]]--
					
					table.insert(newbranches, {subword, wordpos})
					foundsub = true
				end
			end
		end
	end
	
	if (string.len(word) > 0) then
		for c,d in pairs(cobjects) do
			if (c ~= 1) and (string.len(tostring(c)) > 0) then
				local name = c
				
				if (string.len(name) > 5) and (string.sub(name, 1, 5) == "text_") then
					name = string.sub(name, 6)
				end
				
				if (string.len(word) <= string.len(name)) and (string.sub(name, 1, string.len(word)) == word) then
					if (string.len(word) == string.len(name)) then
						table.insert(fullwords_c, {name, 0})
						found = true
					else
						found = true
					end
				end
				
				if (wordpos > 0) and ((string.len(word) >= 2) or (word == "i")) and mainbranch then
					if (string.len(name) >= string.len(subword)) and (string.sub(name, 1, string.len(subword)) == subword) then
						table.insert(newbranches, {subword, wordpos})
						foundsub = true
					end
				end
			end
		end
	end
	
	if (string.len(word) <= 1) then
		found = true
	end
	
	if (#fullwords > 0) then
		for i,v in ipairs(fullwords) do
			local text = v[1]
			if(text == "i") then
				text = "i2"
			end
			local textpos = v[2]
			local alttext = "text_" .. text
			
			local name_base = unitreference[text]
			local name_general = objectpalette[text]
			local altname_base = unitreference[alttext]
			local altname_general = objectpalette[alttext]
			
			local realname = altname_general
			local realname_general = name_general
			
			if (generaldata.strings[WORLD] == generaldata.strings[BASEWORLD]) then
				realname = altname_base
				realname_general = name_base
			end
			
			if (realname ~= nil) then
				local name = getactualdata_objlist(realname,"name")
				local wtype = getactualdata_objlist(realname,"type")
				
				if (name == text) or (name == alttext) then
					if (wtype ~= 5) then
						if (realname_general ~= nil) then
							objectlist[text] = 1
						elseif (((text == "all") or (text == "empty")) and (realname ~= nil)) then
							objectlist[text] = 1
						end
						
						table.insert(result, {name, wtype, textpos})
					end
				end
			end
		end
	end
	
	if (#fullwords_c > 0) then
		for i,v in ipairs(fullwords_c) do
			if (word == v[1]) then
				table.insert(result, {v[1], 8, v[2]})
			end
		end
	end
	
	return found,result,newbranches
end