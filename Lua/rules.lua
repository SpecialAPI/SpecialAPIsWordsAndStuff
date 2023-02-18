function code(alreadyrun_)
	local playrulesound = false
	local alreadyrun = alreadyrun_ or false
	poweredstatus = {}
	
	if (updatecode == 1) then
		HACK_INFINITY = HACK_INFINITY + 1
		--MF_alert("code being updated!")
		
		if generaldata.flags[LOGGING] then
			logrulelist.new = {}
		end
		
		MF_removeblockeffect(0)
		wordrelatedunits = {}
		
		do_mod_hook("rule_update",{alreadyrun})
		
		if (HACK_INFINITY < 200) then
			local checkthese = {}
			local wordidentifier = ""
			wordunits,wordidentifier,wordrelatedunits = findwordunits()
			local wordunitresult = {}
			
			if (#wordunits > 0) then
				for i,v in ipairs(wordunits) do
					if testcond(v[2],v[1]) then
						wordunitresult[v[1]] = 1
						table.insert(checkthese, v[1])
					else
						wordunitresult[v[1]] = 0
					end
				end
			end
			
			features = {}
			featureindex = {}
			condfeatureindex = {}
			visualfeatures = {}
			notfeatures = {}
			groupfeatures = {}
			
			local firstwords = {}
			local alreadyused = {}
			
			do_mod_hook("rule_baserules")
			
			for i,v in ipairs(baserulelist) do
				addbaserule(v[1],v[2],v[3],v[4])
			end
			
			formlettermap()
			
			if (#codeunits > 0) then
				for i,v in ipairs(codeunits) do
					table.insert(checkthese, v)
				end
			end
		
			if (#checkthese > 0) or (#letterunits > 0) then
				for iid,unitid in ipairs(checkthese) do
					local unit = mmf.newObject(unitid)
					local x,y = unit.values[XPOS],unit.values[YPOS]
					local ox,oy,nox,noy = 0,0
					local tileid = x + y * roomsizex

					setcolour(unit.fixed)
					
					if (alreadyused[tileid] == nil) and (unit.values[TYPE] ~= 5) and (unit.flags[DEAD] == false) then
						for i=1,2 do
							local drs = dirs[i+2]
							local ndrs = dirs[i]
							ox = drs[1]
							oy = drs[2]
							nox = ndrs[1]
							noy = ndrs[2]
							
							--MF_alert("Doing firstwords check for " .. unit.strings[UNITNAME] .. ", dir " .. tostring(i))
							
							local hm = codecheck(unitid,ox,oy,i,nil,wordunitresult)
							local hm2 = codecheck(unitid,nox,noy,i,nil,wordunitresult)
							
							if (#hm == 0) and (#hm2 > 0) then
								--MF_alert("Added " .. unit.strings[UNITNAME] .. " to firstwords, dir " .. tostring(i))
								
								table.insert(firstwords, {{unitid}, i, 1, unit.strings[UNITNAME], unit.values[TYPE], {}})
								
								if (alreadyused[tileid] == nil) then
									alreadyused[tileid] = {}
								end
								
								alreadyused[tileid][i] = 1
							end
						end
					end
				end
				
				--table.insert(checkthese, {unit.strings[UNITNAME], unit.values[TYPE], unit.values[XPOS], unit.values[YPOS], 0, 1, {unitid})
				
				for a,b in pairs(letterunits_map) do
					for iid,data in ipairs(b) do
						local x,y,i = data[3],data[4],data[5]
						local unitids = data[7]
						local width = data[6]
						local word,wtype = data[1],data[2]
						
						local unitid = unitids[1]
						
						local tileid = x + y * roomsizex
						
						if (alreadyused[tileid] == nil) or ((alreadyused[tileid] ~= nil) and (alreadyused[tileid][i] == nil)) then
							local drs = dirs[i+2]
							local ndrs = dirs[i]
							ox = drs[1]
							oy = drs[2]
							nox = ndrs[1] * width
							noy = ndrs[2] * width
							
							local hm = codecheck(unitid,ox,oy,i)
							local hm2 = codecheck(unitid,nox,noy,i)
							
							if (#hm == 0) and (#hm2 > 0) then
								-- MF_alert(word .. ", " .. tostring(width))
								
								table.insert(firstwords, {unitids, i, width, word, wtype, {}})
								
								if (alreadyused[tileid] == nil) then
									alreadyused[tileid] = {}
								end
								
								alreadyused[tileid][i] = 1
							end
						end
					end
				end
				
				docode(firstwords,wordunits)
				subrules()
				grouprules()
				playrulesound = postrules(alreadyrun)
				updatecode = 0
				
				local newwordunits,newwordidentifier,wordrelatedunits = findwordunits()
				
				--MF_alert("ID comparison: " .. newwordidentifier .. " - " .. wordidentifier)
				
				if (newwordidentifier ~= wordidentifier) then
					updatecode = 1
					code(true)
				else
					--domaprotation()
				end
			end
		else
			MF_alert("Level destroyed - code() run too many times")
			destroylevel("infinity")
			return
		end
		
		if (alreadyrun == false) then
			effects_decors()
			
			if (featureindex["broken"] ~= nil) then
				brokenblock(checkthese)
			end
			
			if (featureindex["3d"] ~= nil) then
				updatevisiontargets()
			end
			
			if generaldata.flags[LOGGING] then
				updatelogrules()
			end
		end
		
		do_mod_hook("rule_update_after",{alreadyrun})
	end
	
	if (alreadyrun == false) then
		local rulesoundshort = ""
		alreadyrun = true
		if playrulesound and (generaldata5.values[LEVEL_DISABLERULEEFFECT] == 0) then
			local pmult,sound = checkeffecthistory("rule")
			rulesoundshort = sound
			local rulename = "rule" .. tostring(math.random(1,5)) .. rulesoundshort
			MF_playsound(rulename)
		end
	end
end

function docode(firstwords)
	local donefirstwords = {}
	local existingfinals = {}
	local limiter = 0
	
	if (#firstwords > 0) then
		for k,unitdata in ipairs(firstwords) do
			if (type(unitdata[1]) == "number") then
				timedmessage("Old rule format detected. Please replace modified .lua files to ensure functionality.")
			end
			
			local unitids = unitdata[1]
			local unitid = unitids[1]
			local dir = unitdata[2]
			local width = unitdata[3]
			local word = unitdata[4]
			local wtype = unitdata[5]
			local existing = unitdata[6] or {}
			local existing_wordid = unitdata[7] or 1
			local existing_id = unitdata[8] or ""
			
			if (string.sub(word, 1, 5) == "text_") then
				word = string.sub(word, 6)
			end
			
			local unit = mmf.newObject(unitid)
			local x,y = unit.values[XPOS],unit.values[YPOS]
			local tileid_id = x + y * roomsizex
			local unique_id = tostring(tileid_id) .. "_" .. existing_id
			
			--MF_alert("Testing " .. word .. ": " .. tostring(donefirstwords[unique_id]) .. ", " .. tostring(dir) .. ", " .. tostring(unitid) .. ", " .. tostring(unique_id))
			
			limiter = limiter + 1
			
			if (limiter > 5000) then
				MF_alert("Level destroyed - firstwords run too many times")
				destroylevel("toocomplex")
				return
			end
			
			--[[
			MF_alert("Current unique id: " .. tostring(unique_id))
			
			if (donefirstwords[unique_id] ~= nil) and (donefirstwords[unique_id][dir] ~= nil) then
				MF_alert("Already used: " .. tostring(unitid) .. ", " .. tostring(unique_id))
			end
			]]--
			
			if (donefirstwords[unique_id] == nil) or ((donefirstwords[unique_id] ~= nil) and (donefirstwords[unique_id][dir] == nil)) and (limiter < 5000) then
				local ox,oy = 0,0
				local name = word
				
				local drs = dirs[dir]
				ox = drs[1]
				oy = drs[2]
				
				if (donefirstwords[unique_id] == nil) then
					donefirstwords[unique_id] = {}
				end
				
				donefirstwords[unique_id][dir] = 1
				
				local sentences = {}
				local finals = {}
				local maxlen = 0
				local variations = 1
				local sent_ids = {}
				local newfirstwords = {}
				
				if (#existing == 0) then
					sentences,finals,maxlen,variations,sent_ids,newfirstwords = calculatesentences(unitid,x,y,dir)
				else
					sentences[1] = existing
					maxlen = 3
					finals[1] = {}
					sent_ids = {existing_id}
				end
				
				if (sentences == nil) then
					return
				end
				
				if (#newfirstwords > 0) then
					for i,v in ipairs(newfirstwords) do
						table.insert(firstwords, v)
					end
				end
				
				--[[
				-- BIG DEBUG MESS
				if (variations > 0) then
					for i=1,variations do
						local dsent = ""
						local currsent = sentences[i]
						
						for a,b in ipairs(currsent) do
							dsent = dsent .. b[1] .. " "
						end
						
						MF_alert(tostring(k) .. ": Variant " .. tostring(i) .. ": " .. dsent)
					end
				end
				]]--
				
				if (maxlen > 2) then
					for i=1,variations do
						local current = finals[i]
						local isI = false
						local isYou = false
						local letterword = ""
						local stage = 0
						local prevstage = 0
						local tileids = {}
						
						local notids = {}
						local notwidth = 0
						local notslot = 0
						
						local stage3reached = false
						local stage2reached = false
						local doingcond = false
						local nocondsafterthis = false
						local condsafeand = false
						
						local firstrealword = false
						local letterword_prevstage = 0
						local letterword_firstid = 0
						
						local currtiletype = 0
						local prevtiletype = 0
						
						local prevsafewordid = 0
						local prevsafewordtype = 0
						
						local stop = false
						
						local sent = sentences[i]
						local sent_id = sent_ids[i]
						
						local thissent = ""
						
						local j = 0
						for wordid=existing_wordid,#sent do
							j = j + 1
							
							local s = sent[wordid]
							local nexts = sent[wordid + 1] or {-1, -1, {-1}, 1}
							
							prevtiletype = currtiletype
							
							local tilename = s[1]
							local tiletype = s[2]
							local tileid = s[3][1]
							local tilewidth = s[4]
							
							if (string.sub(tilename, 1, 10) == "text_text_") then
								tilename = string.sub(tilename, 6)
							end
							
							local wordtile = false
							
							currtiletype = tiletype
							
							thissent = thissent .. tilename .. "," .. tostring(wordid) .. "  "
							
							for a,b in ipairs(s[3]) do
								table.insert(tileids, b)
							end
							
							--[[
								0 = objekti
								1 = verbi
								2 = quality
								3 = alkusana (LONELY)
								4 = Not
								5 = letter
								6 = And
								7 = ehtosana
								8 = customobject
							]]--
							
							if (tiletype ~= 5) then
								if (stage == 0) then
									if (tiletype == 0) then
										if(tilename == "i2") then
											isI = true
										end
										if(tilename == "oyou" or tilename == "we" or tilename == "they") then
											isYou = true
										end
										prevstage = stage
										stage = 2
									elseif (tiletype == 3) then
										prevstage = stage
										stage = 1
									elseif (tiletype ~= 4) then
										prevstage = stage
										stage = -1
										stop = true
									end
								elseif (stage == 1) then
									if (tiletype == 0) then
										prevstage = stage
										stage = 2
									elseif (tiletype == 6) then
										prevstage = stage
										stage = 6
									elseif (tiletype ~= 4) then
										prevstage = stage
										stage = -1
										stop = true
									end
								elseif (stage == 2) then
									if (wordid ~= #sent) then
										if (tiletype == 1) and (prevtiletype ~= 4) and ((prevstage ~= 4) or doingcond or (stage3reached == false)) then
											if(isI or isYou) and ((isI and tilename == "am") or (isYou and tilename == "are")) then
												tilename = "is"
												stage2reached = true
												doingcond = false
												prevstage = stage
												nocondsafterthis = true
												stage = 3
											elseif(isI or isYou) and (tilename == "have") then
												tilename = "has"
												stage2reached = true
												doingcond = false
												prevstage = stage
												nocondsafterthis = true
												stage = 3
											elseif((isI or isYou) and ((tilename == "is") or (tilename == "has") or (tilename == "are") or (tilename == "am"))) or (not isI and not isYou and (tilename == "are" or tilename == "am" or tilename == "have")) then
												prevstage = stage
												stage = -1
												stop = true
											else
												stage2reached = true
												doingcond = false
												prevstage = stage
												nocondsafterthis = true
												stage = 3
											end
										elseif (tiletype == 7) and (stage2reached == false) and (nocondsafterthis == false) and ((doingcond == false) or (prevstage ~= 4)) then
											doingcond = true
											prevstage = stage
											stage = 3
										elseif (tiletype == 6) and (prevtiletype ~= 4) then
											isI = false
											isYou = false
											prevstage = stage
											stage = 4
										elseif (tiletype ~= 4) then
											prevstage = stage
											stage = -1
											stop = true
										end
									else
										stage = -1
										stop = true
									end
								elseif (stage == 3) then
									stage3reached = true
									
									if (tiletype == 0) or (tiletype == 2) or (tiletype == 8) then
										prevstage = stage
										stage = 5
									elseif (tiletype ~= 4) then
										stage = -1
										stop = true
									end
								elseif (stage == 4) then
									if (wordid <= #sent) then
										if (tiletype == 0) or ((tiletype == 2) and stage3reached) or ((tiletype == 8) and stage3reached) then
											prevstage = stage
											stage = 2
										elseif ((tiletype == 1) and stage3reached) and (doingcond == false) and (prevtiletype ~= 4) then
											stage2reached = true
											nocondsafterthis = true
											prevstage = stage
											stage = 3
										elseif (tiletype == 7) and (nocondsafterthis == false) and ((prevtiletype ~= 6) or ((prevtiletype == 6) and doingcond)) then
											doingcond = true
											stage2reached = true
											prevstage = stage
											stage = 3
										elseif (tiletype ~= 4) then
											prevstage = stage
											stage = -1
											stop = true
										end
									else
										stage = -1
										stop = true
									end
								elseif (stage == 5) then
									if (wordid ~= #sent) then
										if (tiletype == 1) and doingcond and (prevtiletype ~= 4) then
											stage2reached = true
											doingcond = false
											prevstage = stage
											nocondsafterthis = true
											stage = 3
										elseif (tiletype == 6) and (prevtiletype ~= 4) then
											prevstage = stage
											stage = 4
										elseif (tiletype ~= 4) then
											prevstage = stage
											stage = -1
											stop = true
										end
									else
										stage = -1
										stop = true
									end
								elseif (stage == 6) then
									if (tiletype == 3) then
										prevstage = stage
										stage = 1
									elseif (tiletype ~= 4) then
										prevstage = stage
										stage = -1
										stop = true
									end
								end
							end
							
							if (stage > 0) then
								firstrealword = true
							end
							
							if (tiletype == 4) then
								if (#notids == 0) or (prevtiletype == 0) then
									notids = s[3]
									notwidth = tilewidth
									notslot = wordid
								end
							else
								if (stop == false) and (tiletype ~= 0) then
									notids = {}
									notwidth = 0
									notslot = 0
								end
							end
							
							if (prevtiletype ~= 4) and (wordid > existing_wordid) then
								prevsafewordid = wordid - 1
								prevsafewordtype = prevtiletype
							end
							
							if (prevtiletype == 4) and (tiletype == 6) then
								stop = true
								stage = -1
							end
							
							--MF_alert(tilename .. ", " .. tostring(wordid) .. ", " .. tostring(stage) .. ", " .. tostring(#sent) .. ", " .. tostring(tiletype) .. ", " .. tostring(prevtiletype) .. ", " .. tostring(stop) .. ", " .. name .. ", " .. tostring(i))
							
							--MF_alert(tostring(k) .. "_" .. tostring(i) .. "_" .. tostring(wordid) .. ": " .. tilename .. ", " .. tostring(tiletype) .. ", " .. tostring(stop) .. ", " .. tostring(stage) .. ", " .. tostring(letterword_firstid).. ", " .. tostring(prevtiletype))
							
							if (stop == false) then
								local subsent_id = string.sub(sent_id, (wordid - existing_wordid)+1)
								current.sent = sent
								table.insert(current, {tilename, tiletype, tileids, tilewidth, wordid, subsent_id})
								tileids = {}
								
								if (wordid == #sent) and (#current >= 3) and (j > 1) then
									subsent_id = tostring(tileid_id) .. "_" .. string.sub(sent_id, 1, j) .. "_" .. tostring(dir)
									--MF_alert("Checking finals: " .. subsent_id .. ", " .. tostring(existingfinals[subsent_id]))
									if (existingfinals[subsent_id] == nil) then
										existingfinals[subsent_id] = 1
									else
										finals[i] = {}
									end
								end
							else
								for a=1,#s[3] do
									if (#tileids > 0) then
										table.remove(tileids, #tileids)
									end
								end
								
								if (tiletype == 0) and (prevtiletype == 0) and (#notids > 0) then
									notids = {}
									notwidth = 0
								end
								
								if (#current >= 3) and (j > 1) then
									local subsent_id = tostring(tileid_id) .. "_" .. string.sub(sent_id, 1, j-1) .. "_" .. tostring(dir)
									--MF_alert("Checking finals: " .. subsent_id .. ", " .. tostring(existingfinals[subsent_id]))
									if (existingfinals[subsent_id] == nil) then
										existingfinals[subsent_id] = 1
									else
										finals[i] = {}
									end
								end
								
								if (wordid < #sent) then
									if (wordid > existing_wordid) then
										if (#notids > 0) and firstrealword and (notslot > 1) and ((tiletype ~= 7) or ((tiletype == 7) and (prevtiletype == 0))) and ((tiletype ~= 1) or ((tiletype == 1) and (prevtiletype == 0))) then
											-- MF_alert(tostring(notslot) .. ", not -> A, " .. unique_id .. ", " .. sent_id)
											local subsent_id = string.sub(sent_id, (notslot - existing_wordid)+1)
											table.insert(firstwords, {notids, dir, notwidth, "not", 4, sent, notslot, subsent_id})
											
											if (nexts[2] ~= nil) and ((nexts[2] == 0) or (nexts[2] == 3) or (nexts[2] == 4)) and (tiletype ~= 3) then
												-- MF_alert(tostring(wordid) .. ", " .. tilename .. " -> B, " .. unique_id .. ", " .. sent_id)
												subsent_id = string.sub(sent_id, j)
												table.insert(firstwords, {s[3], dir, tilewidth, tilename, tiletype, sent, wordid, subsent_id})
											end
										else
											if (prevtiletype == 0) and ((tiletype == 1) or (tiletype == 7)) then
												-- MF_alert(tostring(wordid-1) .. ", " .. sent[wordid - 1][1] .. " -> C, " .. unique_id .. ", " .. sent_id)
												local subsent_id = string.sub(sent_id, wordid - existing_wordid)
												table.insert(firstwords, {sent[wordid - 1][3], dir, tilewidth, tilename, tiletype, sent, wordid-1, subsent_id})
											elseif (prevsafewordtype == 0) and (prevsafewordid > 0) and (prevtiletype == 4) and (tiletype ~= 1) and (tiletype ~= 2) then
												-- MF_alert(tostring(prevsafewordid) .. ", " .. sent[prevsafewordid][1] .. " -> D, " .. unique_id .. ", " .. sent_id)
												local subsent_id = string.sub(sent_id, (prevsafewordid - existing_wordid)+1)
												table.insert(firstwords, {sent[prevsafewordid][3], dir, tilewidth, tilename, tiletype, sent, prevsafewordid, subsent_id})
											else
												-- MF_alert(tostring(wordid) .. ", " .. tilename .. " -> E, " .. unique_id .. ", " .. sent_id)
												local subsent_id = string.sub(sent_id, j)
												table.insert(firstwords, {s[3], dir, tilewidth, tilename, tiletype, sent, wordid, subsent_id})
											end
										end
										
										break
									elseif (wordid == existing_wordid) then
										if (nexts[3][1] ~= -1) then
											-- MF_alert(tostring(wordid+1) .. ", " .. nexts[1] .. " -> F, " .. unique_id .. ", " .. sent_id)
											local subsent_id = string.sub(sent_id, j+1)
											table.insert(firstwords, {nexts[3], dir, nexts[4], nexts[1], nexts[2], sent, wordid+1, subsent_id})
										end
										
										break
									end
								end
							end
						end
						
						--MF_alert(thissent)
					end
				end
				
				if (#finals > 0) then
					for i,sentence in ipairs(finals) do
						local group_objects = {}
						local group_targets = {}
						local group_conds = {}
						
						local group = group_objects
						local stage = 0
						
						local prefix = ""
						
						local allowedwords = {0}
						local allowedwords_extra = {}
						local disallowedwords_extra = {}
						
						local testing = ""
						
						local extraids = {}
						local extraids_current = ""
						local extraids_ifvalid = {}
						
						local valid = true
						
						if (#sentence >= 3) then
							if (#finals > 1) then
								for a,b in ipairs(finals) do
									if (#b == #sentence) and (a > i) then
										local identical = true
										
										for c,d in ipairs(b) do
											local currids = d[3]
											local equivids = sentence[c][3] or {}
											
											for e,f in ipairs(currids) do
												--MF_alert(tostring(a) .. ": " .. tostring(f) .. ", " .. tostring(equivids[e]))
												if (f ~= equivids[e]) then
													identical = false
												end
											end
										end
										
										if identical then
											--MF_alert(sentence[1][1] .. ", " .. sentence[2][1] .. ", " .. sentence[3][1] .. " (" .. tostring(i) .. ") is identical to " .. b[1][1] .. ", " .. b[2][1] .. ", " .. b[3][1] .. " (" .. tostring(a) .. ")")
											valid = false
										end
									end
								end
							end
						else
							valid = false
						end
						
						if valid then
							for index,wdata in ipairs(sentence) do
								local wname = wdata[1]
								local wtype = wdata[2]
								local wid = wdata[3]
								
								testing = testing .. wname .. " "
								
								local wcategory = -1
								
								if (wtype == 1) or (wtype == 3) or (wtype == 7) then
									wcategory = 1
								elseif (wtype ~= 4) and (wtype ~= 6) then
									wcategory = 0
								else
									table.insert(extraids_ifvalid, {prefix .. wname, wtype, wid})
									extraids_current = wname
								end
								
								if (wcategory == 0) then
									local allowed = false
									
									for a,b in ipairs(allowedwords) do
										if (b == wtype) then
											allowed = true
											break
										end
									end
									
									if (allowed == false) then
										for a,b in ipairs(allowedwords_extra) do
											if (wname == b) then
												allowed = true
												break
											end
										end
									end
									
									if(allowed == true) then
										for a,b in ipairs(disallowedwords_extra) do
											if (wname == b) or ((b == "groupx") and (string.sub(wname, 1, 5) == "group")) or ((b == "usex") and (string.sub(wname, 1, 3) == "use")) or (b == "throwx" and string.sub(wname, 1, 5) == "throw") then
												allowed = false
												break
											end
										end
									end
									
									if allowed then
										table.insert(group, {prefix .. wname, wtype, wid})
									else
										local sent = sentence.sent
										local wordid = wdata[5]
										local subsent_id = wdata[6]
										table.insert(firstwords, {{wid[1]}, dir, 1, wname, wtype, sent, wordid, subsent_id})
										break
									end
								elseif (wcategory == 1) then
									if (index < #sentence) then
										allowedwords = {0}
										allowedwords_extra = {}
										disallowedwords_extra = {}
										
										--if(wname == "become") then
											--table.insert(disallowedwords_extra, "groupx")
											--table.insert(disallowedwords_extra, "usex")
											--table.insert(disallowed)
										--end
										
										local realname = unitreference["text_" .. wname]
										local cargtype = false
										local cargextra = false
										
										local argtype = {0}
										local argextra = {}
										
										if (changes[realname] ~= nil) then
											local wchanges = changes[realname]
											
											if (wchanges.argtype ~= nil) then
												argtype = wchanges.argtype
												cargtype = true
											end
											
											if (wchanges.argextra ~= nil) then
												argextra = wchanges.argextra
												cargextra = true
											end
										end
										
										if (cargtype == false) or (cargextra == false) then
											local wvalues = tileslist[realname] or {}
											
											if (cargtype == false) then
												argtype = wvalues.argtype or {0}
											end
											
											if (cargextra == false) then
												argextra = wvalues.argextra or {}
											end
										end
										
										--MF_alert(wname .. ", " .. tostring(realname) .. ", " .. "text_" .. wname)
										
										if (realname == nil) then
											MF_alert("No object found for " .. wname .. "!")
											valid = false
											break
										else
											if (wtype == 1) then
												allowedwords = argtype
												allowedwords_extra = argextra
												
												stage = 1
												local target = {prefix .. wname, wtype, wid}
												table.insert(group_targets, {target, {}})
												local sid = #group_targets
												group = group_targets[sid][2]
												
												newcondgroup = 1
											elseif (wtype == 3) then
												allowedwords = {0}
												local cond = {prefix .. wname, wtype, wid}
												table.insert(group_conds, {cond, {}})
											elseif (wtype == 7) then
												allowedwords = argtype
												allowedwords_extra = argextra
												
												stage = 2
												local cond = {prefix .. wname, wtype, wid}
												table.insert(group_conds, {cond, {}})
												local sid = #group_conds
												group = group_conds[sid][2]
											end
										end
									end
								end
								
								if (wtype == 4) then
									if (prefix == "not ") then
										prefix = ""
									else
										prefix = "not "
									end
								else
									prefix = ""
								end
								
								if (wname ~= extraids_current) and (string.len(extraids_current) > 0) and (wtype ~= 4) then
									for a,extraids_valid in ipairs(extraids_ifvalid) do
										table.insert(extraids, {prefix .. extraids_valid[1], extraids_valid[2], extraids_valid[3]})
									end
									
									extraids_ifvalid = {}
									extraids_current = ""
								end
							end
							--MF_alert("Testing: " .. testing)
							
							if generaldata.flags[LOGGING] then
								rulelog(sentence, testing)
							end
							
							local conds = {}
							local condids = {}
							for c,group_cond in ipairs(group_conds) do
								local rule_cond = group_cond[1][1]
								--table.insert(condids, group_cond[1][3])
								
								condids = copytable(condids, group_cond[1][3])
								
								table.insert(conds, {rule_cond,{}})
								local condgroup = conds[#conds][2]
								
								for e,condword in ipairs(group_cond[2]) do
									local rule_condword = condword[1]
									--table.insert(condids, condword[3])
									
									condids = copytable(condids, condword[3])
									
									table.insert(condgroup, rule_condword)
								end
							end
							
							for c,group_object in ipairs(group_objects) do
								local rule_object = group_object[1]
								
								for d,group_target in ipairs(group_targets) do
									local rule_verb = group_target[1][1]
									
									for e,target in ipairs(group_target[2]) do
										local rule_target = target[1]
										
										local finalconds = {}
										for g,finalcond in ipairs(conds) do
											table.insert(finalconds, {finalcond[1], finalcond[2]})
										end
										
										local rule = {rule_object,rule_verb,rule_target}
										
										local ids = {}
										ids = copytable(ids, group_object[3])
										ids = copytable(ids, group_target[1][3])
										ids = copytable(ids, target[3])
										
										for g,h in ipairs(extraids) do
											ids = copytable(ids, h[3])
										end
										
										for g,h in ipairs(condids) do
											ids = copytable(ids, h)
										end
									
										addoption(rule,finalconds,ids)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function codecheck(unitid,ox,oy,cdir_,ignore_end_,wordunitresult_)
	local unit = mmf.newObject(unitid)
	local ux,uy = unit.values[XPOS],unit.values[YPOS]
	local x = unit.values[XPOS] + ox
	local y = unit.values[YPOS] + oy
	local result = {}
	local letters = false
	local justletters = false
	local cdir = cdir_ or 0
	local wordunitresult = wordunitresult_ or {}
	
	local ignore_end = false
	if (ignore_end_ ~= nil) then
		ignore_end = ignore_end_
	end
	
	if (cdir == 0) then
		MF_alert("CODECHECK - CDIR == 0 - why??")
	end
	
	local tileid = x + y * roomsizex
	
	if (unitmap[tileid] ~= nil) then
		for i,b in ipairs(unitmap[tileid]) do
			local v = mmf.newObject(b)
			local w = 1
			
			if (v.values[TYPE] ~= 5) and (v.flags[DEAD] == false) then
				if (v.strings[UNITTYPE] == "text") then
					table.insert(result, {{b}, w, v.strings[NAME], v.values[TYPE], cdir})
				else
					if (#wordunits > 0) then
						local valid = false
						
						if (wordunitresult[b] ~= nil) and (wordunitresult[b] == 1) then
							valid = true
						elseif (wordunitresult[b] == nil) then
							for c,d in ipairs(wordunits) do
								if (b == d[1]) and testcond(d[2],d[1]) then
									valid = true
									break
								end
							end
						end
						
						if valid then
							table.insert(result, {{b}, w, v.strings[UNITNAME], v.values[TYPE], cdir})
						end
					end
				end
			else
				justletters = true
			end
		end
	end
	
	if (letterunits_map[tileid] ~= nil) then
		for i,v in ipairs(letterunits_map[tileid]) do
			local unitids = v[7]
			local width = v[6]
			local word = v[1]
			local wtype = v[2]
			local dir = v[5]
			
			if (string.len(word) > 5) and (string.sub(word, 1, 5) == "text_") then
				word = string.sub(v[1], 6)
			end
			
			local valid = true
			if ignore_end and ((x ~= v[3]) or (y ~= v[4])) and (width > 1) then
				valid = false
			end
			
			if (cdir ~= 0) and (width > 1) then
				if ((cdir == 1) and (ux > v[3]) and (ux < v[3] + width)) or ((cdir == 2) and (uy > v[4]) and (uy < v[4] + width)) then
					valid = false
				end
			end
			
			--MF_alert(word .. ", " .. tostring(valid) .. ", " .. tostring(dir) .. ", " .. tostring(cdir))
			
			if (dir == cdir) and valid then
				table.insert(result, {unitids, width, word, wtype, dir})
				letters = true
			end
		end
	end
	
	return result,letters,justletters
end

function addoption(option,conds_,ids,visible,notrule,tags_)
	--MF_alert(option[1] .. ", " .. option[2] .. ", " .. option[3])
	
	local visual = true
	
	if (visible ~= nil) then
		visual = visible
	end
	
	local conds = {}
	
	if (conds_ ~= nil) then
		conds = conds_
	else
		MF_alert("nil conditions in rule: " .. option[1] .. ", " .. option[2] .. ", " .. option[3])
	end
	
	local tags = tags_ or {}
	
	if (#option == 3) then
		local rule = {option,conds,ids,tags}
		table.insert(features, rule)
		local target = option[1]
		local verb = option[2]
		local effect = option[3]
	
		if (featureindex[effect] == nil) then
			featureindex[effect] = {}
		end
		
		if (featureindex[target] == nil) then
			featureindex[target] = {}
		end
		
		if (featureindex[verb] == nil) then
			featureindex[verb] = {}
		end
		
		table.insert(featureindex[effect], rule)
		table.insert(featureindex[verb], rule)
		
		if (target ~= effect) then
			table.insert(featureindex[target], rule)
		end
		
		if visual then
			local visualrule = copyrule(rule)
			table.insert(visualfeatures, visualrule)
		end
		
		local groupcond = false
		
		if (string.sub(target, 1, 5) == "group") or (string.sub(effect, 1, 5) == "group") or (string.sub(target, 1, 9) == "not group") or (string.sub(effect, 1, 9) == "not group") or (string.sub(target, 1, 3) == "use") or (string.sub(effect, 1, 3) == "use") or (string.sub(target, 1, 7) == "not use") or (string.sub(effect, 1, 7) == "not use") or (string.sub(target, 1, 5) == "throw") or (string.sub(effect, 1, 5) == "throw") or (string.sub(target, 1, 9) == "not throw") or (string.sub(effect, 1, 9) == "not throw") then
			groupcond = true
		end
		
		if (notrule ~= nil) then
			local notrule_effect = notrule[1]
			local notrule_id = notrule[2]
			
			if (notfeatures[notrule_effect] == nil) then
				notfeatures[notrule_effect] = {}
			end
			
			local nr_e = notfeatures[notrule_effect]
			
			if (nr_e[notrule_id] == nil) then
				nr_e[notrule_id] = {}
			end
			
			local nr_i = nr_e[notrule_id]
			
			table.insert(nr_i, rule)
		end
		
		if (#conds > 0) then
			local addedto = {}
			
			for i,cond in ipairs(conds) do
				local condname = cond[1]
				if (string.sub(condname, 1, 4) == "not ") then
					condname = string.sub(condname, 5)
				end
				
				if (condfeatureindex[condname] == nil) then
					condfeatureindex[condname] = {}
				end
				
				if (addedto[condname] == nil) then
					table.insert(condfeatureindex[condname], rule)
					addedto[condname] = 1
				end
				
				if (cond[2] ~= nil) then
					if (#cond[2] > 0) then
						local newconds = {}
						
						--alreadyused[target] = 1
						
						for a,b in ipairs(cond[2]) do
							local alreadyused = {}
							
							if (b ~= "all") and (b ~= "not all") then
								alreadyused[b] = 1
								table.insert(newconds, b)
							elseif (b == "all") then
								for a,mat in pairs(objectlist) do
									if (alreadyused[a] == nil) and (findnoun(a,nlist.short) == false) then
										table.insert(newconds, a)
										alreadyused[a] = 1
									end
								end
							elseif (b == "not all") then
								table.insert(newconds, "empty")
								table.insert(newconds, "text")
							end
							
							if (string.sub(b, 1, 5) == "group") or (string.sub(b, 1, 9) == "not group") or (string.sub(b, 1, 3) == "use") or (string.sub(b, 1, 7) == "not use") or (string.sub(b, 1, 5) == "throw") or (string.sub(b, 1, 9) == "not throw") then
								groupcond = true
							end
						end
						
						cond[2] = newconds
					end
				end
			end
		end
		
		if groupcond then
			table.insert(groupfeatures, rule)
		end

		local targetnot = string.sub(target, 1, 4)
		local targetnot_ = string.sub(target, 5)
		
		if (targetnot == "not ") and (objectlist[targetnot_] ~= nil) and (string.sub(targetnot_, 1, 5) ~= "group") and (string.sub(effect, 1, 5) ~= "group") and (string.sub(effect, 1, 9) ~= "not group") and (string.sub(targetnot_, 1, 5) ~= "throw") and (string.sub(effect, 1, 5) ~= "throw") and (string.sub(effect, 1, 9) ~= "not thrpw") and (string.sub(targetnot_, 1, 3) ~= "use") and (string.sub(effect, 1, 3) ~= "use") and (string.sub(effect, 1, 7) ~= "not use") or (((string.sub(effect, 1, 5) == "group") or (string.sub(effect, 1, 9) == "not group") or (string.sub(effect, 1, 5) == "throw") or (string.sub(effect, 1, 9) == "not throw") or (string.sub(effect, 1, 3) == "use") or (string.sub(effect, 1, 7) == "not use")) and (targetnot_ == "all")) then
			if (targetnot_ ~= "all") then
				for i,mat in pairs(objectlist) do
					if (i ~= targetnot_) and (findnoun(i) == false) then
						local rule = {i,verb,effect}
						local newconds = {}
						for a,b in ipairs(conds) do
							table.insert(newconds, b)
						end
						addoption(rule,newconds,ids,false,{effect,#featureindex[effect]},tags)
					end
				end
			else
				local mats = {"empty","text"}
				
				for m,i in pairs(mats) do
					local rule = {i,verb,effect}
					local newconds = {}
					for a,b in ipairs(conds) do
						table.insert(newconds, b)
					end
					addoption(rule,newconds,ids,false,{effect,#featureindex[effect]},tags)
				end
			end
		end
	end
end

function subrules()
	local mimicprotects = {}
	
	if (featureindex["all"] ~= nil) then
		for k,rules in ipairs(featureindex["all"]) do
			local rule = rules[1]
			local conds = rules[2]
			local ids = rules[3]
			local tags = rules[4]
			
			if (rule[3] == "all") then
				if (rule[2] ~= "is") then
					local nconds = {}
					
					if (featureindex["not all"] ~= nil) then
						for a,prules in ipairs(featureindex["not all"]) do
							local prule = prules[1]
							local pconds = prules[2]
							
							if (prule[1] == rule[1]) and (prule[2] == rule[2]) and (prule[3] == "not all") then
								local ipconds = invertconds(pconds)
								
								for c,d in ipairs(ipconds) do
									table.insert(nconds, d)
								end
							end
						end
					end
					
					for i,mat in pairs(objectlist) do
						if (findnoun(i) == false) then
							local newrule = {rule[1],rule[2],i}
							local newconds = {}
							for a,b in ipairs(conds) do
								table.insert(newconds, b)
							end
							for a,b in ipairs(nconds) do
								table.insert(newconds, b)
							end
							addoption(newrule,newconds,ids,false,nil,tags)
						end
					end
				end
			end

			if (rule[1] == "all") and (string.sub(rule[3], 1, 4) ~= "not ") then
				local nconds = {}
				
				if (featureindex["not all"] ~= nil) then
					for a,prules in ipairs(featureindex["not all"]) do
						local prule = prules[1]
						local pconds = prules[2]
						
						if (prule[1] == rule[1]) and (prule[2] == rule[2]) and (prule[3] == "not " .. rule[3]) then
							local ipconds = invertconds(pconds)
							
							if crashy_ then
								crashy = true
							end
							
							for c,d in ipairs(ipconds) do
								table.insert(nconds, d)
							end
						end
					end
				end
				
				for i,mat in pairs(objectlist) do
					if (findnoun(i) == false) then
						local newrule = {i,rule[2],rule[3]}
						local newconds = {}
						for a,b in ipairs(conds) do
							table.insert(newconds, b)
						end
						for a,b in ipairs(nconds) do
							table.insert(newconds, b)
						end
						addoption(newrule,newconds,ids,false,nil,tags)
					end
				end
			end
			
			if (rule[1] == "all") and (string.sub(rule[3], 1, 4) == "not ") then
				for i,mat in pairs(objectlist) do
					if (findnoun(i) == false) then
						local newrule = {i,rule[2],rule[3]}
						local newconds = {}
						for a,b in ipairs(conds) do
							table.insert(newconds, b)
						end
						addoption(newrule,newconds,ids,false,nil,tags)
					end
				end
			end
		end
	end
	
	if (featureindex["mimic"] ~= nil) then
		for i,rules in ipairs(featureindex["mimic"]) do
			local rule = rules[1]
			local conds = rules[2]
			local tags = rules[4]
			
			if (rule[2] == "mimic") then
				local object = rule[1]
				local target = rule[3]
				
				local isnot = false
				
				if (string.sub(target, 1, 4) == "not ") then
					target = string.sub(target, 5)
					isnot = true
				end
				
				if isnot then
					if (mimicprotects[object] == nil) then
						mimicprotects[object] = {}
					end
					
					table.insert(mimicprotects[object], {target, conds, rule[3]})
				end
			end
		end
	end
	
	local limiter = 0
	local limit = 250
	
	if (featureindex["mimic"] ~= nil) then
		for i,rules in ipairs(featureindex["mimic"]) do
			local rule = rules[1]
			local conds = rules[2]
			local tags = rules[4]
			
			if (rule[2] == "mimic") then
				local object = rule[1]
				local target = rule[3]
				local mprotects = mimicprotects[object] or {}
				local extraconds = {}
				
				local valid = true
				
				if (string.sub(target, 1, 4) == "not ") then
					valid = false
				end
				
				for a,b in ipairs(mprotects) do
					if (b[1] == target) then
						local pconds = b[2]
						
						if (#pconds == 0) then
							valid = false
						else
							local newconds = invertconds(pconds)
							
							for c,d in ipairs(newconds) do
								table.insert(extraconds, d)
							end
						end
					end
				end
				
				local copythese = {}
				
				if valid then
					if(target == "self") then
						target = object
					end

					if (getmat(object) ~= nil) and (getmat(target) ~= nil) then
						if (featureindex[target] ~= nil) then
							copythese = featureindex[target]
						end
					end
				
					for a,b in ipairs(copythese) do
						local trule = b[1]
						local tconds = b[2]
						local ids = b[3]
						local ttags = b[4]
						
						local valid = true
						for c,d in ipairs(ttags) do
							if (d == "mimic") then
								valid = false
							end
						end
						
						if (trule[1] == target) and (trule[2] ~= "mimic") and valid then
							local newconds = {}
							local newtags = {}
							
							for c,d in ipairs(tconds) do
								table.insert(newconds, d)
							end
							
							for c,d in ipairs(conds) do
								table.insert(newconds, d)
							end
							
							for c,d in ipairs(extraconds) do
								table.insert(newconds, d)
							end
							
							for c,d in ipairs(ttags) do
								table.insert(newtags, d)
							end
							
							for c,d in ipairs(tags) do
								table.insert(newtags, d)
							end
							
							table.insert(newtags, "mimic")
							
							local newword1 = object
							local newword2 = trule[2]
							local newword3 = trule[3]
							
							local newrule = {newword1, newword2, newword3}
							
							limiter = limiter + 1
							addoption(newrule,newconds,ids,true,nil,newtags)
							
							if (limiter > limit) then
								MF_alert("Level destroyed - mimic happened too many times!")
								destroylevel("toocomplex")
								return
							end
						end
					end
				end
			end
		end
	end
end

function postrules(alreadyrun_)
	local protects = {}
	local newruleids = {}
	local ruleeffectlimiter = {}
	local playrulesound = false
	local alreadyrun = alreadyrun_ or false
	
	for i,unit in ipairs(units) do
		unit.active = false
	end
	
	local limit = #features
	
	for i,rules in ipairs(features) do
		if (i <= limit) then
			local rule = rules[1]
			local conds = rules[2]
			local ids = rules[3]
			
			if (rule[1] == rule[3]) and (rule[2] == "is") then
				table.insert(protects, i)
			end
			
			if (ids ~= nil) then
				local works = true
				local idlist = {}
				local effectsok = false
				
				if (#ids > 0) then
					for a,b in ipairs(ids) do
						table.insert(idlist, b)
					end
				end
				
				if (#idlist > 0) and works then
					for a,d in ipairs(idlist) do
						for c,b in ipairs(d) do
							if (b ~= 0) then
								local bunit = mmf.newObject(b)
								
								if (bunit.strings[UNITTYPE] == "text") then
									bunit.active = true
									setcolour(b,"active")
								end
								newruleids[b] = 1
								
								if (ruleids[b] == nil) and (#undobuffer > 1) and (alreadyrun == false) and (generaldata5.values[LEVEL_DISABLERULEEFFECT] == 0) then
									if (ruleeffectlimiter[b] == nil) then
										local x,y = bunit.values[XPOS],bunit.values[YPOS]
										local c1,c2 = getcolour(b,"active")
										--MF_alert(b)
										MF_particles_for_unit("bling",x,y,5,c1,c2,1,1,b)
										ruleeffectlimiter[b] = 1
									end
									
									if (rule[2] ~= "play") then
										playrulesound = true
									end
								end
							end
						end
					end
				elseif (#idlist > 0) and (works == false) then
					for a,visualrules in pairs(visualfeatures) do
						local vrule = visualrules[1]
						local same = comparerules(rule,vrule)
						
						if same then
							table.remove(visualfeatures, a)
						end
					end
				end
			end

			local rulenot = 0
			local neweffect = ""
			
			local nothere = string.sub(rule[3], 1, 4)
			
			if (nothere == "not ") then
				rulenot = 1
				neweffect = string.sub(rule[3], 5)
			end
			
			if (rulenot == 1) then
				local newconds,crashy = invertconds(conds,nil,rule[3])
				
				local newbaserule = {rule[1],rule[2],neweffect}
				
				local target = rule[1]
				local verb = rule[2]
				
				local targetlists = {}
				table.insert(targetlists, target)
				
				if (verb == "is") and (neweffect == "text") and (featureindex["write"] ~= nil) then
					table.insert(targetlists, "write")
				end
				
				for e,g in ipairs(targetlists) do
					for a,b in ipairs(featureindex[g]) do
						local same = comparerules(newbaserule,b[1])
						
						if same or ((g == "write") and (target == b[1][1]) and (b[1][2] == "write")) then
							--MF_alert(rule[1] .. ", " .. rule[2] .. ", " .. neweffect .. ": " .. b[1][1] .. ", " .. b[1][2] .. ", " .. b[1][3])
							local theseconds = b[2]
							
							if (#newconds > 0) then
								if (newconds[1] ~= "never") then
									for c,d in ipairs(newconds) do
										table.insert(theseconds, d)
									end
								else
									theseconds = {"never",{}}
								end
							end
							
							if crashy then
								addoption({rule[1],"is","crash"},theseconds,ids,false,nil,rules[4])
							end
							
							b[2] = theseconds
						end
					end
				end
			end
		end
	end
	
	if (#protects > 0) then
		for i,v in ipairs(protects) do
			local rule = features[v]
			
			local baserule = rule[1]
			local conds = rule[2]
			
			local target = baserule[1]
			
			local newconds = {{"never",{}}}
			
			if (conds[1] ~= "never") then
				if (#conds > 0) then
					newconds = {}
					
					for a,b in ipairs(conds) do
						local condword = b[1]
						local condgroup = {}
						
						if (string.sub(condword, 1, 1) == "(") then
							condword = string.sub(condword, 2)
						end
						
						if (string.sub(condword, -1) == ")") then
							condword = string.sub(condword, 1, #condword - 1)
						end
						
						local newcondword = "not " .. condword
						
						if (string.sub(condword, 1, 3) == "not") then
							newcondword = string.sub(condword, 5)
						end
						
						if (a == 1) then
							newcondword = "(" .. newcondword
						end
						
						if (a == #conds) then
							newcondword = newcondword .. ")"
						end
						
						if (b[2] ~= nil) then
							for c,d in ipairs(b[2]) do
								table.insert(condgroup, d)
							end
						end
						
						table.insert(newconds, {newcondword, condgroup})
					end
				end		
			
				if (featureindex[target] ~= nil) then
					for a,rules in ipairs(featureindex[target]) do
						local targetrule = rules[1]
						local targetconds = rules[2]
						local object = targetrule[3]
						
						if (targetrule[1] == target) and (((targetrule[2] == "is") and (target ~= object)) or ((targetrule[2] == "write") and (string.sub(object, 1, 4) ~= "not "))) and ((getmat(object) ~= nil) or (object == "revert") or ((targetrule[2] == "write") and (string.sub(object, 1, 4) ~= "not "))) and (string.sub(object, 1, 5) ~= "group") and (string.sub(object, 1, 5) ~= "use") and (string.sub(object, 1, 5) ~= "throw") then
							if (#newconds > 0) then
								if (newconds[1] == "never") then
									targetconds = {}
								end
								
								for c,d in ipairs(newconds) do
									table.insert(targetconds, d)
								end
							end
							
							rules[2] = targetconds
						end
					end
				end
			end
		end
	end
	
	ruleids = newruleids
	
	if (spritedata.values[VISION] == 0) then
		ruleblockeffect()
	end
	
	return playrulesound
end

function grouprules()
	groupmembers = {}
	local groupmembers_quick = {}
	
	local isgroup = {}
	local isnotgroup = {}
	local xgroup = {}
	local xnotgroup = {}
	local groupx = {}
	local notgroupx = {}
	local groupxgroup = {}
	local groupxgroup_diffname = {}
	local groupisnotgroup = {}
	local notgroupisgroup = {}
	
	local evilrecursion = false
	local notgroupisgroup_diffname = {}
	
	local memberships = {}
	
	local combined = {}
	
	for i,v in ipairs(groupfeatures) do
		local rule = v[1]
		local conds = v[2]
		
		local type_isgroup = false
		local type_isnotgroup = false
		local type_xgroup = false
		local type_xnotgroup = false
		local type_groupx = false
		local type_notgroupx = false
		local type_recursive = false
		
		local groupname1 = ""
		local groupname2 = ""
		
		if (string.sub(rule[1], 1, 5) == "group") or (string.sub(rule[1], 1, 3) == "use") or (string.sub(rule[1], 1, 5) == "throw") then
			type_groupx = true
			groupname1 = rule[1]
		elseif (string.sub(rule[1], 1, 9) == "not group") or (string.sub(rule[1], 1, 7) == "not use") or (string.sub(rule[1], 1, 9) == "not throw") then
			type_notgroupx = true
			groupname1 = string.sub(rule[1], 5)
		end
		
		if (string.sub(rule[3], 1, 5) == "group") or (string.sub(rule[3], 1, 3) == "use") or (string.sub(rule[3], 1, 5) == "throw") then
			type_xgroup = true
			groupname2 = rule[3]
			
			if (rule[2] == "is") then
				type_isgroup = true
			end
		elseif (string.sub(rule[3], 1, 9) == "not group") or (string.sub(rule[3], 1, 7) == "not use") or (string.sub(rule[3], 1, 9) == "not throw") then
			type_xnotgroup = true
			groupname2 = string.sub(rule[3], 5)
			
			if (rule[2] == "is") then
				type_isnotgroup = true
			end
		end
		
		if (conds ~= nil) and (#conds > 0) then
			for a,cond in ipairs(conds) do
				local params = cond[2] or {}
				for c,param in ipairs(params) do
					if (string.sub(param, 1, 5) == "group") or (string.sub(param, 1, 9) == "not group") or (string.sub(param, 1, 3) == "use") or (string.sub(param, 1, 7) == "not use") or (string.sub(param, 1, 5) == "throw") or (string.sub(param, 1, 9) == "not throw") then
						type_recursive = true
						break
					end
				end
			end
		end
		
		if type_isgroup then
			if (type_groupx == false) and (type_notgroupx == false) then
				table.insert(isgroup, {v, type_recursive})
				
				if (memberships[rule[3]] == nil) then
					memberships[rule[3]] = {}
				end
				
				if (memberships[rule[3]][rule[1]] == nil) then
					memberships[rule[3]][rule[1]] = {}
				end
				
				table.insert(memberships[rule[3]][rule[1]], {v, type_recursive})
			elseif (type_notgroupx == false) then
				if (groupname1 == groupname2) then
					table.insert(groupxgroup, {v, type_recursive})
				else
					table.insert(groupxgroup_diffname, {v, type_recursive})
				end
			else
				if (groupname1 == groupname2) then
					table.insert(notgroupisgroup, {v, type_recursive})
				else
					evilrecursion = true
					table.insert(notgroupisgroup_diffname, {v, type_recursive})
				end
			end
		elseif type_xgroup then
			if (type_groupx == false) and (type_notgroupx == false) then
				table.insert(xgroup, {v, type_recursive})
			else
				table.insert(groupxgroup, {v, type_recursive})
			end
		elseif type_isnotgroup then
			if (type_groupx == false) and (type_notgroupx == false) then
				if (isnotgroup[rule[1]] == nil) then
					isnotgroup[rule[1]] = {}
				end
				
				table.insert(isnotgroup[rule[1]], {v, type_recursive})
				
				if (xnotgroup[rule[1]] == nil) then
					xnotgroup[rule[1]] = {}
				end
				
				table.insert(xnotgroup[rule[1]], {v, type_recursive})
			elseif (type_notgroupx == false) then
				if (groupname1 == groupname2) then
					table.insert(groupisnotgroup, {v, type_recursive})
				else
					table.insert(groupxgroup_diffname, {v, type_recursive})
				end
			else
				if (groupname1 == groupname2) then
					table.insert(groupxgroup, {v, type_recursive})
				else
					evilrecursion = true
					table.insert(notgroupisgroup_diffname, {v, type_recursive})
				end
			end
		elseif type_xnotgroup then
			if (xnotgroup[rule[1]] == nil) then
				xnotgroup[rule[1]] = {}
			end
			
			table.insert(xnotgroup[rule[1]], {v, type_recursive})
		elseif type_groupx then
			table.insert(groupx, {v, type_recursive})
		elseif type_notgroupx then
			table.insert(notgroupx, {v, type_recursive})
		end
	end
	
	local diffname_done = false
	local diffname_used = {}
	
	while (diffname_done == false) do
		diffname_done = true
		
		for i,v_ in ipairs(groupxgroup_diffname) do
			if (diffname_used[i] == nil) then
				local v = v_[1]
				local recursion = v_[2] or false
				
				local rule = v[1]
				local conds = v[2]
				local ids = v[3]
				local tags = v[4]
				
				local gn1 = rule[1]
				local gn2 = rule[3]
				
				local notrule = false
				if (string.sub(gn2, 1, 4) == "not ") then
					notrule = true
				end
				
				local newconds = {}
				newconds = copyconds(newconds,conds)
				
				for a,b_ in ipairs(isgroup) do
					local b = b_[1]
					local brec = b_[2] or recursion or false
					local grule = b[1]
					local gconds = b[2]
					
					if (grule[3] == gn1) then
						diffname_used[i] = 1
						diffname_done = false
						
						newconds = copyconds(newconds,gconds)
						
						local newrule = {grule[1],"is",gn2}
						
						if (notrule == false) then
							table.insert(isgroup, {{newrule,newconds,ids,tags}, brec})
						else
							if (isnotgroup[grule[1]] == nil) then
								isnotgroup[grule[1]] = {}
							end
							
							table.insert(isnotgroup[grule[1]], {{newrule,newconds,ids,tags}, brec})
						end
					end
				end
			end
		end
	end
	
	if evilrecursion then
		diffname_done = false
		local evilrec_id = ""
		local evilrec_id_base = ""
		local evilrec_memberships_base = {}
		local evilrec_memberships_quick = {}
		
		local evilrec_limit = 0
		
		for i,v in pairs(memberships) do
			evilrec_id_base = evilrec_id_base .. i
			for a,b in pairs(v) do
				evilrec_id_base = evilrec_id_base .. a
				
				if (evilrec_memberships_quick[i] == nil) then
					evilrec_memberships_quick[i] = {}
				end
				
				evilrec_memberships_quick[i][a] = b
				
				if (evilrec_memberships_base[i] == nil) then
					evilrec_memberships_base[i] = {}
				end
				
				evilrec_memberships_base[i][a] = b
			end
		end
		
		evilrec_id = evilrec_id_base
		
		while (diffname_done == false) and (evilrec_limit < 10) do
			local foundmembers = {}
			local foundid = evilrec_id_base
			
			for i,v in pairs(evilrec_memberships_base) do
				foundid = foundid .. i
				for a,b in pairs(v) do
					foundid = foundid .. a
				end
			end
			
			for i,v_ in ipairs(notgroupisgroup_diffname) do
				local v = v_[1]
				local recursion = v_[2] or false
				
				local rule = v[1]
				local conds = v[2]
				local ids = v[3]
				local tags = v[4]
				
				local notrule = false
				local gn1 = string.sub(rule[1], 5)
				local gn2 = rule[3]
				
				if (string.sub(gn2, 1, 4) == "not ") then
					notrule = true
					gn2 = string.sub(gn2, 5)
				end
				
				if (foundmembers[gn2] == nil) then
					foundmembers[gn2] = {}
				end
				
				for a,b in pairs(objectlist) do
					if (findnoun(a) == false) and ((evilrec_memberships_quick[gn1] == nil) or ((evilrec_memberships_quick[gn1] ~= nil) and (evilrec_memberships_quick[gn1][a] == nil))) then
						if (foundmembers[gn2][a] == nil) then
							foundmembers[gn2][a] = {}
						end
						
						table.insert(foundmembers[gn2][a], {v, recursion})
					end
				end
			end
			
			for i,v in pairs(foundmembers) do
				foundid = foundid .. i
				for a,b in pairs(v) do
					foundid = foundid .. a
				end
			end
			
			-- MF_alert(foundid .. " == " .. evilrec_id)
			
			if (foundid == evilrec_id) then
				diffname_done = true
				
				for i,v in pairs(foundmembers) do
					for a,d in pairs(v) do
						for c,b_ in ipairs(d) do
							local b = b_[1]
							local brule = b[1]
							local rec = b_[2] or false
							
							local newrule = {a,"is",brule[3]}
							local newconds = {}
							newconds = copyconds(newconds,b[2])
							local newids = concatenate(b[3])
							local newtags = concatenate(b[4])
							
							if (string.sub(brule[3], 1, 4) ~= "not ") then
								table.insert(isgroup, {{newrule,newconds,newids,newtags}, rec})
							else
								if (isnotgroup[a] == nil) then
									isnotgroup[a] = {}
								end
								
								table.insert(isnotgroup[a], {{newrule,newconds,newids,newtags}, rec})
							end
						end
					end
				end
			else
				evilrec_memberships_quick = {}
				evilrec_id = foundid
				
				for i,v in pairs(evilrec_memberships_base) do
					evilrec_memberships_quick[i] = {}
					
					for a,b in pairs(v) do
						evilrec_memberships_quick[i][a] = b
					end
				end
				
				for i,v in pairs(foundmembers) do
					evilrec_memberships_quick[i] = {}
					
					for a,b in pairs(v) do
						evilrec_memberships_quick[i][a] = b
					end
				end
				
				evilrec_limit = evilrec_limit + 1
			end
		end
		
		if (evilrec_limit >= 10) then
			HACK_INFINITY = 200
			destroylevel("infinity")
			return
		end
	end
	
	memberships = {}
	
	for i,v_ in ipairs(isgroup) do
		local v = v_[1]
		local recursion = v_[2] or false
		
		local rule = v[1]
		
		local isuse = (string.sub(rule[3], 1, 3) == "use")
		local isthrow = (string.sub(rule[3], 1, 5) == "throw")
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]
		
		local name_ = rule[1]
		local namelist = {}
		
		if (string.sub(name_, 1, 4) ~= "not ") then
			namelist = {name_}
		elseif (name_ ~= "not all") then
			for a,b in pairs(objectlist) do
				if (findnoun(a) == false) and (a ~= string.sub(name_, 5)) then
					table.insert(namelist, a)
				end
			end
		end
		
		for index,name in ipairs(namelist) do
			local never = false
			
			local prevents = {}
			
			if (isnotgroup[name] ~= nil) then
				for a,b_ in ipairs(isnotgroup[name]) do
					local b = b_[1]
					local brule = b[1]
					
					local grouptype = string.sub(brule[3], 5)
					
					if (grouptype == rule[3]) then
						recursion = b_[2] or recursion
						local pconds,crashy,neverfound = invertconds(b[2])
						
						if (neverfound == false) then
							for a,cond in ipairs(pconds) do
								table.insert(prevents, cond)
							end
						else
							never = true
							break
						end
					end
				end
			end
			
			if (never == false) then
				local fconds = {}
				fconds = copyconds(fconds,conds)
				fconds = copyconds(fconds,prevents)
				
				table.insert(groupmembers, {name,fconds,rule[3],recursion})
				
				if (groupmembers_quick[name .. "_" .. rule[3]] == nil) then
					groupmembers_quick[name .. "_" .. rule[3]] = {}
				end
				
				table.insert(groupmembers_quick[name .. "_" .. rule[3]], {name,fconds,rule[3],recursion})
				
				if (memberships[rule[3]] == nil) then
					memberships[rule[3]] = {}
				end
				
				table.insert(memberships[rule[3]], {name,fconds})
				
				table.insert(combined, {{name, "is", "faceasyou"}, {{"idle"}, {"facedbyyou"}}, {}, {}})

				for a,b_ in ipairs(groupx) do
					local b = b_[1]
					recursion = b_[2] or recursion
					
					local grule = b[1]
					local gconds = b[2]
					local gids = b[3]
					local gtags = b[4]
					
					if (grule[1] == rule[3]) then
						local newrule = {name,grule[2],grule[3]}
						local newconds = {}
						local newids = concatenate(ids,gids)
						local newtags = concatenate(tags,gtags)
						
						newconds = copyconds(newconds,conds)
						newconds = copyconds(newconds,gconds)
						if(isuse == true) then
							newconds = copyconds(newconds, {{"idle"}, {"onyou"}})
						end
						if(isthrow == true) then
							newconds = copyconds(newconds, {{"idle"}, {"facedbyyou"}})
						end
						
						if (#prevents == 0) then
							table.insert(combined, {newrule,newconds,newids,newtags})
						else
							newconds = copyconds(newconds,prevents)
							table.insert(combined, {newrule,newconds,newids,newtags})
						end
					end
				end
			end
		end
	end
	
	for i,v_ in ipairs(groupxgroup) do
		local v = v_[1]
		local recursion = v_[2] or false
		
		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]
		
		local gn1 = rule[1]
		local gn2 = rule[3]
		local isuse = (string.sub(gn2, 1, 3) == "use")
		local isthrow = (string.sub(gn2, 1, 3) == "throw")
		
		local never = false
		
		local notrule = false
		if (string.sub(gn1, 1, 4) == "not ") then
			notrule = true
			gn1 = string.sub(gn1, 5)
		end
		
		local prevents = {}
		if (xnotgroup[gn1] ~= nil) then
			for a,b_ in ipairs(xnotgroup[gn1]) do
				local b = b_[1]
				local brule = b[1]
				
				if (brule[1] == rule[1]) and (brule[2] == rule[2]) and (brule[3] == "not " .. rule[3]) then
					recursion = b_[2] or recursion
					
					local pconds,crashy,neverfound = invertconds(b[2])
					
					if (neverfound == false) then
						for a,cond in ipairs(pconds) do
							table.insert(prevents, cond)
						end
					else
						never = true
						break
					end
				end
			end
		end
		
		if (never == false) then
			local team1 = {}
			local team2 = {}
			
			if (notrule == false) then
				if (memberships[gn1] ~= nil) then
					for a,b in ipairs(memberships[gn1]) do
						table.insert(team1, b)
					end
				end
			else
				local ignorethese = {}
				
				if (memberships[gn1] ~= nil) then
					for a,b in ipairs(memberships[gn1]) do
						ignorethese[b[1]] = 1
						
						local iconds,icrash,inever = invertconds(b[2])
						
						if (inever == false) then
							table.insert(team1, {b[1],iconds})
						end
					end
				end
				
				for a,b in pairs(objectlist) do
					if (findnoun(a) == false) and (ignorethese[a] == nil) then
						table.insert(team1, {a})
					end
				end
			end
			
			if (memberships[gn2] ~= nil) then
				for a,b in ipairs(memberships[gn2]) do
					table.insert(team2, b)
				end
			end
			
			for a,b in ipairs(team1) do
				for c,d in ipairs(team2) do
					local newrule = {b[1],rule[2],d[1]}
					local newconds = {}
					newconds = copyconds(newconds,conds)
					
					if (b[2] ~= nil) then
						newconds = copyconds(newconds,b[2])
					end
					
					if (d[2] ~= nil) then
						newconds = copyconds(newconds,d[2])
					end
					
					if (#prevents > 0) then
						newconds = copyconds(newconds,prevents)
					end
					if(isuse == true) and (notrule == false) then
						newconds = copyconds(newconds, {{"idle"}, {"onyou"}})
					end
					if(isthrow == true) and (notrule == false) then
						newconds = copyconds(newconds, {{"idle"}, {"facedbyyou"}})
					end
					
					local newids = concatenate(ids)
					local newtags = concatenate(tags)
					
					table.insert(combined, {newrule,newconds,newids,newtags})
				end
			end
		end
	end
	
	if (#notgroupx > 0) then
		for name,v in pairs(objectlist) do
			if (findnoun(name) == false) then
				for a,b_ in ipairs(notgroupx) do
					local b = b_[1]
					local recursion = b_[2] or false
					
					local rule = b[1]
					local conds = b[2]
					local ids = b[3]
					local tags = b[4]
					
					local newconds = {}
					newconds = copyconds(newconds,conds)
					
					local groupname = string.sub(rule[1], 5)
					local valid = true
					
					if (groupmembers_quick[name .. "_" .. groupname] ~= nil) then
						for c,d in ipairs(groupmembers_quick[name .. "_" .. groupname]) do
							recursion = d[4] or recursion
							
							local iconds,icrash,inever = invertconds(d[2])
							newconds = copyconds(newconds,iconds)
							
							if inever then
								valid = false
								break
							end
						end
					end
					
					if valid then
						local newrule = {name,rule[2],rule[3]}
						local newids = {}
						local newtags = {}
						newids = concatenate(newids,ids)
						newtags = concatenate(newtags,tags)
						
						table.insert(combined, {newrule,newconds,newids,newtags})
					end
				end
			end
		end
	end
	
	for i,v_ in ipairs(xgroup) do
		local v = v_[1]
		local recursion = v_[2] or false
		
		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]
		
		if (string.sub(rule[1], 1, 5) ~= "group") and (string.sub(rule[1], 1, 9) ~= "not group") and (string.sub(rule[1], 1, 3) ~= "use") and (string.sub(rule[1], 1, 7) ~= "not use") and (string.sub(rule[1], 1, 5) ~= "throw") and (string.sub(rule[1], 1, 9) ~= "not throw") and (rule[2] ~= "is") then
			local team2 = {}
			
			if (memberships[rule[3]] ~= nil) then
				for a,b in ipairs(memberships[rule[3]]) do
					table.insert(team2, b)
				end
			end
			
			for a,b in ipairs(team2) do
				local newrule = {rule[1],rule[2],b[1]}
				local newconds = {}
				newconds = copyconds(newconds,conds)
				
				if (b[2] ~= nil) then
					newconds = copyconds(newconds,b[2])
				end
				
				local newids = concatenate(ids)
				local newtags = concatenate(tags)
				
				table.insert(combined, {newrule,newconds,newids,newtags})
			end
		end
	end
	
	for i,k in pairs(xnotgroup) do
		for c,v_ in ipairs(k) do
			local v = v_[1]
			local recursion = v_[2] or false
			
			local rule = v[1]
			local conds = v[2]
			local ids = v[3]
			local tags = v[4]
			
			if (string.sub(rule[1], 1, 5) ~= "group") and (string.sub(rule[1], 1, 9) ~= "not group") and (string.sub(rule[1], 1, 3) ~= "use") and (string.sub(rule[1], 1, 7) ~= "not use") and (string.sub(rule[1], 1, 5) ~= "throw") and (string.sub(rule[1], 1, 9) ~= "not throw") and (rule[2] ~= "is") then
				local team2 = {}
				
				local gn2 = string.sub(rule[3], 5)
				
				if (memberships[gn2] ~= nil) then
					for a,b in ipairs(memberships[gn2]) do
						table.insert(team2, b)
					end
				end
				
				for a,b in ipairs(team2) do
					local newrule = {rule[1],rule[2],"not " .. b[1]}
					local newconds = {}
					newconds = copyconds(newconds,conds)
					
					if (b[2] ~= nil) then
						newconds = copyconds(newconds,b[2])
					end
					
					local newids = concatenate(ids)
					local newtags = concatenate(tags)
					
					table.insert(combined, {newrule,newconds,newids,newtags})
				end
			end
		end
	end
	
	for i,v_ in ipairs(groupisnotgroup) do
		local v = v_[1]
		local recursion = v_[2] or false
		
		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]
		
		local team1 = {}
		
		if (memberships[rule[1]] ~= nil) then
			for a,b in ipairs(memberships[rule[1]]) do
				table.insert(team1, b)
			end
		end
		
		for a,b in ipairs(team1) do
			local newrule = {b[1],"is","crash"}
			local newconds = {}
			newconds = copyconds(newconds,conds)
			
			if (b[2] ~= nil) then
				newconds = copyconds(newconds,b[2])
			end
			
			local newids = concatenate(ids)
			local newtags = concatenate(tags)
			
			table.insert(combined, {newrule,newconds,newids,newtags})
		end
	end
	
	for i,v_ in ipairs(notgroupisgroup) do
		local v = v_[1]
		local recursion = v_[2] or false
		
		local rule = v[1]
		local conds = v[2]
		local ids = v[3]
		local tags = v[4]
		
		local team1 = {}
		
		local gn1 = string.sub(rule[1], 5)
		
		local ignorethese = {}
		
		if (memberships[gn1] ~= nil) then
			for a,b in ipairs(memberships[gn1]) do
				ignorethese[b[1]] = 1
				
				local iconds,icrash,inever = invertconds(b[2])
				
				if (inever == false) then
					table.insert(team1, {b[1],iconds})
				end
			end
		end
		
		for a,b in pairs(objectlist) do
			if (findnoun(a) == false) and (ignorethese[a] == nil) then
				table.insert(team1, {a})
			end
		end
		
		for a,b in ipairs(team1) do
			local newrule = {b[1],"is","crash"}
			local newconds = {}
			newconds = copyconds(newconds,conds)
			
			if (b[2] ~= nil) then
				newconds = copyconds(newconds,b[2])
			end
			
			local newids = concatenate(ids)
			local newtags = concatenate(tags)
			
			table.insert(combined, {newrule,newconds,newids,newtags})
		end
	end

	for i,v in ipairs(combined) do
		addoption(v[1],v[2],v[3],false,nil,v[4])
	end
end

function copyrule(rule)
	local baserule = rule[1]
	local conds = rule[2]
	local ids = rule[3]
	local tags = rule[4]
	
	local newbaserule = {}
	local newconds = {}
	local newids = {}
	local newtags = {}
	
	newbaserule = {baserule[1],baserule[2],baserule[3]}
	
	if (#conds > 0) then
		for i,cond in ipairs(conds) do
			local newcond = {cond[1]}
			
			if (cond[2] ~= nil) then
				local condnames = cond[2]
				newcond[2] = {}
				
				for a,b in ipairs(condnames) do
					table.insert(newcond[2], b)
				end
			end
			
			table.insert(newconds, newcond)
		end
	end
	
	if (#ids > 0) then
		for i,id in ipairs(ids) do
			local iid = {}
			
			for a,b in ipairs(id) do
				table.insert(iid, b)
			end
			
			table.insert(newids, iid)
		end
	end
	
	if (#tags > 0) then
		for i,tag in ipairs(tags) do
			table.insert(newtags, tag)
		end
	end
	
	local newrule = {newbaserule,newconds,newids,newtags}
	
	return newrule
end

function comparerules(baserule1,baserule2)
	local same = true
	
	for i,v in ipairs(baserule1) do
		if (v ~= baserule2[i]) then
			same = false
		end
	end
	
	return same
end

function findwordunits()
	local result = {}
	local alreadydone = {}
	local checkrecursion = {}
	local related = {}
	
	local identifier = ""
	local fullid = {}
	
	if (featureindex["word"] ~= nil) then
		for i,v in ipairs(featureindex["word"]) do
			local rule = v[1]
			local conds = v[2]
			local ids = v[3]
			
			local name = rule[1]
			local subid = ""
			
			if (rule[2] == "is") then
				if (objectlist[name] ~= nil) and (name ~= "text") and (alreadydone[name] == nil) then
					local these = findall({name,{}})
					alreadydone[name] = 1
					
					if (#these > 0) then
						for a,b in ipairs(these) do
							local bunit = mmf.newObject(b)
							local valid = true
							
							if (featureindex["broken"] ~= nil) then
								if (hasfeature(getname(bunit),"is","broken",b,bunit.values[XPOS],bunit.values[YPOS]) ~= nil) and (hasfeature(getname(bunit),"is","fixed",b,bunit.values[XPOS],bunit.values[YPOS]) == nil) then
									valid = false
								end
							end
							
							if valid then
								table.insert(result, {b, conds})
								subid = subid .. name
								-- LISÄÄ TÄHÄN LISÄÄ DATAA
							end
						end
					end
				end
				
				if (#subid > 0) then
					for a,b in ipairs(conds) do
						local condtype = b[1]
						local params = b[2] or {}
						
						subid = subid .. condtype
						
						if (#params > 0) then
							for c,d in ipairs(params) do
								subid = subid .. tostring(d)
								
								related = findunits(d,related,conds)
							end
						end
					end
				end
				
				table.insert(fullid, subid)
				
				--MF_alert("Going through " .. name)
				
				if (#ids > 0) then
					if (#ids[1] == 1) then
						local firstunit = mmf.newObject(ids[1][1])
						
						local notname = name
						if (string.sub(name, 1, 4) == "not ") then
							notname = string.sub(name, 5)
						end
						
						if (firstunit.strings[UNITNAME] ~= "text_" .. name) and (firstunit.strings[UNITNAME] ~= "text_" .. notname) then
							--MF_alert("Checking recursion for " .. name)
							table.insert(checkrecursion, {name, i})
						end
					end
				else
					MF_alert("No ids listed in Word-related rule! rules.lua line 1302 - this needs fixing asap (related to grouprules line 1118)")
				end
			end
		end
		
		table.sort(fullid)
		for i,v in ipairs(fullid) do
			-- MF_alert("Adding " .. v .. " to id")
			identifier = identifier .. v
		end
		
		--MF_alert("Identifier: " .. identifier)
		
		for a,checkname_ in ipairs(checkrecursion) do
			local found = false
			
			local checkname = checkname_[1]
			
			local b = checkname
			if (string.sub(b, 1, 4) == "not ") then
				b = string.sub(checkname, 5)
			end
			
			for i,v in ipairs(featureindex["word"]) do
				local rule = v[1]
				local ids = v[3]
				local tags = v[4]
				
				if (rule[1] == b) or (rule[1] == "all") or ((rule[1] ~= b) and (string.sub(rule[1], 1, 3) == "not")) then
					for c,g in ipairs(ids) do
						for a,d in ipairs(g) do
							local idunit = mmf.newObject(d)
							
							-- Tässä pitäisi testata myös Group!
							if (idunit.strings[UNITNAME] == "text_" .. rule[1]) or (rule[1] == "all") then
								--MF_alert("Matching objects - found")
								found = true
							elseif (string.sub(rule[1], 1, 5) == "group") or (string.sub(rule[1], 1, 3) == "use") or (string.sub(rule[1], 1, 5) == "throw") then
								--MF_alert("Group - found")
								found = true
							elseif (rule[1] ~= checkname) and (string.sub(rule[1], 1, 3) == "not") then
								--MF_alert("Not Object - found")
								found = true
							end
						end
					end
					
					for c,g in ipairs(tags) do
						if (g == "mimic") then
							found = true
						end
					end
				end
			end
			
			if (found == false) then
				--MF_alert("Wordunit status for " .. b .. " is unstable!")
				identifier = "null"
				wordunits = {}
				
				for i,v in pairs(featureindex["word"]) do
					local rule = v[1]
					local ids = v[3]
					
					--MF_alert("Checking to disable: " .. rule[1] .. " " .. ", not " .. b)
					
					if (rule[1] == b) or (rule[1] == "not " .. b) then
						v[2] = {{"never",{}}}
					end
				end
				
				if (string.sub(checkname, 1, 4) == "not ") then
					local notrules_word = notfeatures["word"]
					local notrules_id = checkname_[2]
					local disablethese = notrules_word[notrules_id]
					
					for i,v in ipairs(disablethese) do
						v[2] = {{"never",{}}}
					end
				end
			end
		end
	end
	
	--MF_alert("Current id (end): " .. identifier)
	
	return result,identifier,related
end

function ruleblockeffect()
	local handled = {}
	
	for i,rules in pairs(features) do
		local rule = rules[1]
		local conds = rules[2]
		local ids = rules[3]
		local blocked = false
		
		for a,b in ipairs(conds) do
			if (b[1] == "never") then
				blocked = true
				break
			end
		end
		
		--MF_alert(rule[1] .. " " .. rule[2] .. " " .. rule[3] .. ": " .. tostring(blocked))
		
		if blocked then
			for a,d in ipairs(ids) do
				for c,b in ipairs(d) do
					if (handled[b] == nil) then
						local runit = mmf.newObject(b)
						
						local blockid = MF_create("Ingame_blocked")
						local bunit = mmf.newObject(blockid)
						
						bunit.x = runit.x
						bunit.y = runit.y
						
						bunit.values[XPOS] = runit.values[XPOS]
						bunit.values[YPOS] = runit.values[YPOS]
						bunit.layer = 1
						bunit.values[ZLAYER] = 20
						bunit.values[TYPE] = b
						
						bunit.scaleX = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]
						bunit.scaleY = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]
						
						bunit.visible = runit.visible
						
						local c1,c2 = getuicolour("blocked")
						MF_setcolour(blockid,c1,c2)
						
						handled[b] = 2
					end
				end
			end
		else
			for a,d in ipairs(ids) do
				for c,b in ipairs(d) do
					if (handled[b] == nil) then
						handled[b] = 1
					elseif (handled[b] == 2) then
						MF_removeblockeffect(b)
					end
				end
			end
		end
	end
end

function getsentencevariant(sentences,combo)
	local result = {}
	
	for i,words in ipairs(sentences) do
		local currcombo = combo[i]
		
		local current = words[currcombo]
		
		table.insert(result, current)
	end
	
	return result
end

function addbaserule(rule1,rule2,rule3,conds_)
	if (featureindex[rule1] == nil) then
		featureindex[rule1] = {}
	end
	
	if (featureindex[rule2] == nil) then
		featureindex[rule2] = {}
	end
	
	if (featureindex[rule3] == nil) then
		featureindex[rule3] = {}
	end
	
	local conds = conds_ or {}
	
	local rule = {rule1,rule2,rule3}
	local fullrule = {rule,conds,{},{"base"}}
	
	table.insert(features, fullrule)
	table.insert(featureindex[rule1], fullrule)
	table.insert(featureindex[rule2], fullrule)
	table.insert(featureindex[rule3], fullrule)
end

function calculatesentences(unitid,x,y,dir)
	local drs = dirs[dir]
	local ox,oy = drs[1],drs[2]
	
	local finals = {}
	local sentences = {}
	local sentence_ids = {}
	local firstwords = {}
	
	local sents = {}
	local done = false
	local verbfound = false
	local objfound = false
	local starting = true
	
	local step = 0
	local rstep = 0
	local combo = {}
	local variantshere = {}
	local totalvariants = 1
	local maxpos = 0
	local prevsharedtype = -1
	local prevmaxw = 1
	local currw = 0
	
	local limiter = 5000
	
	local combospots = {}
	
	local unit = mmf.newObject(unitid)
	
	local done = false
	while (done == false) and (totalvariants < limiter) do
		local words,letters,jletters = codecheck(unitid,ox*rstep,oy*rstep,dir,true)
		
		--MF_alert(tostring(unitid) .. ", " .. unit.strings[UNITNAME] .. ", " .. tostring(#words))
		
		step = step + 1
		rstep = rstep + 1
		
		if (totalvariants >= limiter) then
			MF_alert("Level destroyed - too many variants A")
			destroylevel("toocomplex")
			return nil
		end
		
		if (totalvariants < limiter) then
			local sharedtype = -1
			local maxw = 1
			
			if (#words > 0) then
				sents[step] = {}
				
				for i,v in ipairs(words) do
					--unitids, width, word, wtype, dir
					
					--MF_alert("Step " .. tostring(step) .. ", word " .. v[3] .. " here, " .. tostring(v[2]))
					
					if (sharedtype == -1) then
						sharedtype = v[4]
					elseif (v[4] ~= sharedtype) then
						sharedtype = -2
					end
					
					if (v[4] == 1) then
						verbfound = true
					end
					
					if (v[4] == 0) then
						objfound = true
					end
					
					if starting and ((v[4] == 0) or (v[4] == 3) or (v[4] == 4)) then
						starting = false
					end
					
					maxw = math.max(maxw, v[2])
					table.insert(sents[step], v)
					
					if (v[2] > 1) then
						currw = math.max(currw, v[2] + 1)
					end
				end
				
				if (sharedtype >= 0) and (prevsharedtype >= 0) and (#words > 0) and (maxw == 1) and (prevmaxw == 1) and (currw == 0) then
					if ((sharedtype == 0) and (prevsharedtype == 0)) or ((sharedtype == 1) and (prevsharedtype == 1)) or ((sharedtype == 2) and (prevsharedtype == 2)) or ((sharedtype == 0) and (prevsharedtype == 2)) then
						done = true
						sents[step] = nil
						--MF_alert("added " .. words[1][3])
						table.insert(firstwords, {words[1][1], dir, words[1][2], words[1][3], words[1][4], {}})
					end
				end
				
				currw = math.max(currw - 1, 0)
				
				prevsharedtype = sharedtype
				prevmaxw = maxw
				
				if (done == false) then
					if starting then
						sents[step] = nil
						step = step - 1
					else
						totalvariants = totalvariants * #words
						variantshere[step] = #words
						combo[step] = 1
						
						if (totalvariants >= limiter) then
							MF_alert("Level destroyed - too many variants B")
							destroylevel("toocomplex")
							return nil
						end
						
						if (#words > 1) then
							combospots[#combospots + 1] = step
						end
						
						if (totalvariants > #finals) then
							local limitdiff = totalvariants - #finals
							for i=1,limitdiff do
								table.insert(finals, {})
							end
						end
					end
				end
			else
				--MF_alert("Step " .. tostring(step) .. ", no words here, " .. tostring(letters) .. ", " .. tostring(jletters))
				
				if jletters then
					variantshere[step] = 0
					sents[step] = {}
					combo[step] = 0
					
					if starting then
						sents[step] = nil
						step = step - 1
					end
				else
					done = true
				end
			end
		end
	end
	
	--MF_alert(tostring(step) .. ", " .. tostring(totalvariants))
	
	if (totalvariants >= limiter) then
		MF_alert("Level destroyed - too many variants C")
		destroylevel("toocomplex")
		return nil
	end
	
	if (verbfound == false) or (step < 3) or (objfound == false) then
		return {},{},0,0,{},firstwords
	end
	
	maxpos = step
	
	local combostep = 0
	
	for i=1,totalvariants do
		step = 1
		sentences[i] = {}
		sentence_ids[i] = ""
		
		while (step < maxpos) do
			local c = combo[step]
			
			if (c ~= nil) then
				if (c > 0) then
					local s = sents[step]
					local word = s[c]
					
					local w = word[2]
					
					--MF_alert(tostring(i) .. ", step " .. tostring(step) .. ": " .. word[3] .. ", " .. tostring(#word[1]) .. ", " .. tostring(w))
					
					table.insert(sentences[i], {word[3], word[4], word[1], word[2]})
					sentence_ids[i] = sentence_ids[i] .. tostring(c - 1)
					
					step = step + w
				else
					break
				end
			else
				MF_alert("c is nil, " .. tostring(step))
				break
			end
		end
		
		if (#combospots > 0) then
			combostep = 0
			
			local targetstep = combospots[combostep + 1]
			
			combo[targetstep] = combo[targetstep] + 1
			
			while (combo[targetstep] > variantshere[targetstep]) do
				combo[targetstep] = 1
				
				combostep = (combostep + 1) % #combospots
				
				targetstep = combospots[combostep + 1]
				
				combo[targetstep] = combo[targetstep] + 1
			end
		end
	end
	
	--[[
	MF_alert(tostring(totalvariants) .. ", " .. tostring(#sentences))
	for i,v in ipairs(sentences) do
		local text = ""
		
		for a,b in ipairs(v) do
			text = text .. b[1] .. " "
		end
		
		MF_alert(text)
	end
	]]--
	
	return sentences,finals,maxpos,totalvariants,sentence_ids,firstwords
end

function invertconds(conds,db,target_)
	local newconds = db or {}
	local crash = false
	local doparentheses = true
	local neverfound = false
	
	if (#conds > 0) then
		for a,cond in ipairs(conds) do
			local newcond = {}
			local condname = cond[1]
			local condname_s = ""
			local params = cond[2]
			
			local prefix = string.sub(condname, 1, 4)
			
			if (prefix == "(not") then
				condname_s = string.sub(condname, 6)
				condname = string.sub(condname, 6)
			elseif (prefix == "not ") then
				condname_s = string.sub(condname, 5)
				condname = string.sub(condname, 5)
			else
				condname_s = condname
				condname = "not " .. condname
			end
			
			newcond[1] = condname
			newcond[2] = {}
			local valid = true
			
			if (#params > 0) then
				for m,n in ipairs(params) do
					if (condname_s ~= "feeling") then
						table.insert(newcond[2], n)
					else
						--MF_alert(n .. ", " .. tostring(target_) .. ", " .. cond[1] .. ", " .. condname .. ", " .. condname_s)
						if (target_ == nil) or (target_ ~= "not " .. n) then
							table.insert(newcond[2], n)
						elseif (cond[1] == "feeling") then
							crash = true
						end
					end
				end
			end
			
			if (#params > 0) and (#newcond[2] == 0) then
				valid = false
			end
			
			if valid then
				table.insert(newconds, newcond)
			end
		end
	else
		table.insert(newconds, {"never",{}})
		doparentheses = false
		neverfound = true
	end
	
	if doparentheses then
		for i,cond in ipairs(newconds) do
			if (i == 1) then
				cond[1] = "(" .. cond[1]
			end
			
			if (i == #newconds) then
				cond[1] = cond[1] .. ")"
			end
		end
	end
	
	return newconds,crash,neverfound
end

function rulelog(sent,text)
	local wdata = sent[1]
	local wids = wdata[3]
	local unitid = wids[1]
	local x,y = 0,0
	
	if (unitid ~= nil) then
		local unit = mmf.newObject(unitid)
		x = unit.values[XPOS]
		y = unit.values[YPOS]
	end
	
	local bundle = {x,y,text}
	table.insert(logrulelist.new, bundle)
end

function updatelogrules()
	local checklist1 = {}
	local checklist2 = {}
	local newrules = {}
	local gonerules = {}
	
	if (logrulelist ~= nil) and (logrulelist.new ~= nil) and (logrulelist.old ~= nil) then
		if (generaldata.values[UPDATE] < 2) then
			for i,v in ipairs(logrulelist.old) do
				local id = v[3]
				checklist1[id] = 1
			end
			
			for i,v in ipairs(logrulelist.new) do
				local id = v[3]
				checklist2[id] = 1
				
				if (checklist1[id] == nil) then
					table.insert(newrules, {v[1], v[2], v[3]})
				end
			end
			
			for i,v in ipairs(logrulelist.old) do
				local id = v[3]
				
				if (checklist2[id] == nil) then
					table.insert(gonerules, {v[1], v[2], v[3]})
				end
			end
			
			for i,v in ipairs(gonerules) do
				id = tostring(v[1]) .. ":" .. tostring(v[2]) .. ":" .. tostring(v[3])
				dolog("rule_remove","event",id)
				-- MF_alert("rule_remove: " .. v[3])
			end
			
			for i,v in ipairs(newrules) do
				id = tostring(v[1]) .. ":" .. tostring(v[2]) .. ":" .. tostring(v[3])
				dolog("rule_add","event",id)
				-- MF_alert("rule_add: " .. v[3])
			end
		end
		
		logrulelist.old = {}
		for i,v in ipairs(logrulelist.new) do
			table.insert(logrulelist.old, {v[1], v[2], v[3]})
		end
		logrulelist.new = {}
	end
end