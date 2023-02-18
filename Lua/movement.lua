function movecommand(ox,oy,dir_,playerid_,dir_2,no3d_)
	statusblock(nil,nil,true)
	movelist = {}
	local debug_moves = 0
	
	local take = 1
	local takecount = 8
	local finaltake = false
	local no3d = no3d_ or false
	local playerid = playerid_ or 1
	
	local still_moving = {}
	
	local levelpush = -1
	local levelpull = -1
	local levelmovedir = dir_
	
	local levelmove = {}
	local levelmove2 = {}

	faceasyou = getunitswitheffect("faceasyou", true)
	for id,unit in ipairs(faceasyou) do
		local unitname = getname(unit)
		if (unit.fixed ~= 1) then
			for tdir = 0,3 do
				local ndrs = ndirs[tdir+1]
				local ox2 = ndrs[1]
				local oy2 = ndrs[2]
				
				local x = unit.values[XPOS]
				local y = unit.values[YPOS]
				local tileid = (x + ox2) + (y + oy2) * roomsizex
				if (unitmap[tileid] ~= nil) then
					for c,d in ipairs(unitmap[tileid]) do
						if (d ~= unitid) then
							local unit2 = mmf.newObject(d)
							local name_ = getname(unit2)
							local udir = unit2.values[DIR]
							
							if(hasfeature(name_, "is", "you", d)) and (((udir > 1) and (udir - 2 == tdir)) or ((udir < 2) and (udir + 2 == tdir))) then
								local horiz = hasfeature(unitname,"is","horiz",v)
								local vert = hasfeature(unitname,"is","vert",v)
								if((horiz == nil) and (vert == nil)) or ((horiz ~= nil) and (vert == nil) and ((udir == 0) or (udir == 2))) or ((horiz == nil) and (vert ~= nil) and ((udir == 1) or (udir == 3))) then
									updatedir(unit.fixed,udir)
								end
							end
						end
					end
				end
			end
		end
	end
	
	if (playerid == 1) then
		levelmove = findfeature("level","is","you") or findfeature("level","is","fakeyou")
	elseif (playerid == 2) then
		levelmove = findfeature("level","is","you2") or findfeature("level","is","fakeyou2")
		
		if (levelmove == nil) then
			levelmove = findfeature("level","is","you") or findfeature("level","is","fakeyou")
		end
	elseif (playerid == 3) then
		levelmove = findfeature("level","is","you") or findfeature("level","is","fakeyou") or {}
		levelmove2 = findfeature("level","is","you2") or findfeature("level","is","fakeyou2")
		
		if (#levelmove > 0) and (dir_ ~= nil) then
			levelmovedir = dir_
		elseif (levelmove2 ~= nil) and (dir_ ~= nil) then
			levelmovedir = dir_
		elseif (dir_2 ~= nil) then
			levelmovedir = dir_2
		end
		
		if (levelmove2 ~= nil) then
			for i,v in ipairs(levelmove2) do
				table.insert(levelmove, v)
			end
		end
		
		if (#levelmove == 0) then
			levelmove = nil
		end
	end
	
	if (levelmove ~= nil) then
		local valid = false
		
		for i,v in ipairs(levelmove) do
			if (valid == false) and testcond(v[2],1) then
				valid = true
			end
		end
		
		if (featureindex["reverse"] ~= nil) or (featureindex["reversehoriz"] ~= nil) or (featureindex["reversevert"] ~= nil) then
			levelmovedir = reversecheck(1,levelmovedir)
		end
		
		if cantmove("level",1,levelmovedir) then
			valid = false
		end
		
		if valid then
			local ndrs = ndirs[levelmovedir + 1]
			local ox,oy = ndrs[1],ndrs[2]
			
			if (isstill(1,nil,nil,levelmovedir) == false) then
				addundo({"levelupdate",Xoffset,Yoffset,Xoffset + ox * tilesize,Yoffset + oy * tilesize,mapdir,levelmovedir})
				MF_scrollroom(ox * tilesize,oy * tilesize)
			else
				addundo({"levelupdate",Xoffset,Yoffset,Xoffset,Yoffset,mapdir,levelmovedir})
			end
			
			if (levelmovedir ~= 4) then
				mapdir = levelmovedir
			end
			updateundo = true
		end
	end
	
	while (take <= takecount) or finaltake do
		local moving_units = {}
		local been_seen = {}
		local skiptake = false
		
		if (finaltake == false) then
			if (take == 1) then
				local players = {}
				local players2 = {}
				local players3 = {}
				local empty = {}
				local empty2 = {}
				local empty3 = {}
				local fakeplayers = {}
				local fakeplayers2 = {}
				local fakeplayers3 = {}
				local fakeempty = {}
				local fakeempty2 = {}
				local fakeempty3 = {}
				
				if (playerid == 1) then
					players,empty = findallfeature(nil,"is","you")
					fakeplayers,fakeempty = findallfeature(nil,"is","fakeyou")
					for i,v in ipairs(fakeplayers) do
						table.insert(players, v)
					end
					
					for i,v in ipairs(fakeempty) do
						table.insert(empty, v)
					end
				elseif (playerid == 2) then
					players,empty = findallfeature(nil,"is","you2")
					fakeplayers,fakeempty = findallfeature(nil,"is","fakeyou2")
					
					for i,v in ipairs(fakeplayers) do
						table.insert(players, v)
					end
					
					for i,v in ipairs(fakeempty) do
						table.insert(empty, v)
					end
					
					if (#players == 0) then
						players,empty = findallfeature(nil,"is","you")
					end
					if(#fakeplayers == 0) then
						fakeplayers,fakeempty = findallfeature(nil,"is","fakeyou")
						for i,v in ipairs(fakeplayers) do
							table.insert(players, v)
						end
						
						for i,v in ipairs(fakeempty) do
							table.insert(empty, v)
						end
					end
				elseif (playerid == 3) then
					players,empty = findallfeature(nil,"is","you")
					players2,empty2 = findallfeature(nil,"is","you2")
					
					for i,v in ipairs(players2) do
						table.insert(players, v)
					end
					
					for i,v in ipairs(empty2) do
						table.insert(empty, v)
					end
					
					
					fakeplayers,fakeempty = findallfeature(nil,"is","fakeyou")
					fakeplayers2,fakeempty2 = findallfeature(nil,"is","fakeyou2")
					
					for i,v in ipairs(fakeplayers) do
						table.insert(players, v)
					end
					for i,v in ipairs(fakeplayers2) do
						table.insert(players, v)
					end
					
					for i,v in ipairs(fakeempty) do
						table.insert(empty, v)
					end
					for i,v in ipairs(fakeempty2) do
						table.insert(empty, v)
					end
				end
				
				local fdir = 4
				
				for i,v in ipairs(players) do
					local sleeping = false
					
					fdir = dir_
					
					if (playerid == 3) then
						if (i > #players - #players2) then
							fdir = dir_2
						end
					end
					
					if (v ~= 2) then
						local unit = mmf.newObject(v)
						
						local unitname = getname(unit)
						local sleep = hasfeature(unitname,"is","sleep",v)
						local still = cantmove(unitname,v,fdir)
						local horiz = hasfeature(unitname,"is","horiz",v)
						local vert = hasfeature(unitname,"is","vert",v)
						
						if (sleep ~= nil) then
							sleeping = true
						elseif still then
							sleeping = true
							
							if (fdir ~= 4) then
								if((horiz == nil) and (vert == nil)) or (horiz ~= nil and vert ~= nil) or ((horiz ~= nil) and (vert == nil) and ((fdir == 0) or (fdir == 2))) or ((horiz == nil) and (vert ~= nil) and ((fdir == 1) or (fdir == 3))) then
									updatedir(v,fdir)
								end
							end
						else
							
							if (fdir ~= 4) then
								if((horiz == nil) and (vert == nil)) or (horiz ~= nil and vert ~= nil) or ((horiz ~= nil) and (vert == nil) and ((fdir == 0) or (fdir == 2))) or ((horiz == nil) and (vert ~= nil) and ((fdir == 1) or (fdir == 3))) then
									updatedir(v,fdir)
								end
							end
						end
					else
						local thisempty = empty[i]
						
						for a,b in pairs(thisempty) do
							local x = a % roomsizex
							local y = math.floor(a / roomsizex)
							
							local sleep = hasfeature("empty","is","sleep",2,x,y)
							local still = cantmove("empty",2,fdir,x,y)
							
							if (sleep ~= nil) or still then
								thisempty[a] = nil
							end
						end
					end
					
					if (sleeping == false) and (fdir ~= 4) then
						if (been_seen[v] == nil) then
							local x,y = -1,-1
							if (v ~= 2) then
								local unit = mmf.newObject(v)
								x,y = unit.values[XPOS],unit.values[YPOS]
								
								table.insert(moving_units, {unitid = v, reason = "you", state = 0, moves = 1, dir = fdir, xpos = x, ypos = y})
								been_seen[v] = #moving_units
							else
								local thisempty = empty[i]
								
								for a,b in pairs(thisempty) do
									x = a % roomsizex
									y = math.floor(a / roomsizex)
								
									table.insert(moving_units, {unitid = 2, reason = "you", state = 0, moves = 1, dir = fdir, xpos = x, ypos = y})
									been_seen[v] = #moving_units
								end
							end
						else
							local id = been_seen[v]
							local this = moving_units[id]
							--this.moves = this.moves + 1
						end
					end
				end
				
				fdir = 4
				
				if (featureindex["3d"] ~= nil) and (spritedata.values[CAMTARGET] ~= 0) and (spritedata.values[CAMTARGET] ~= 0.5) and (no3d == false) then
					local sleeping = false
					local domove = false
					local turndir = 0
					local ox,oy = 0,0
					
					local v = MF_getfixed(spritedata.values[CAMTARGET]) or 0
					
					if (v ~= 2) and (v ~= 0) then
						local unit = mmf.newObject(v)
						
						local udir = unit.values[DIR]
						local ndrs = ndirs[udir + 1]
						ox,oy = ndrs[1],ndrs[2]
						
						if (dir_ == 1) then
							domove = true
						elseif (dir_ == 0) then
							turndir = -1
						elseif (dir_ == 2) then
							turndir = 1
						end
						
						fdir = (udir + turndir + 4) % 4
						
						local unitname = getname(unit)
						local sleep = hasfeature(unitname,"is","sleep",v)
						local still = cantmove(unitname,v,fdir)
						
						if (sleep ~= nil) then
							sleeping = true
						elseif still then
							sleeping = true
							
							if (fdir ~= 4) then
								updatedir(v, fdir)
							end
						else
							if (fdir ~= 4) then
								updatedir(v, fdir)
							end
						end
					
						if (sleeping == false) and (fdir ~= 4) and domove then
							if (been_seen[v] == nil) then
								local x,y = -1,-1
								if (v ~= 2) then
									local unit = mmf.newObject(v)
									x,y = unit.values[XPOS],unit.values[YPOS]
									
									table.insert(moving_units, {unitid = v, reason = "you", state = 0, moves = 1, dir = fdir, xpos = x, ypos = y})
									been_seen[v] = #moving_units
								end
							else
								local id = been_seen[v]
								local this = moving_units[id]
								--this.moves = this.moves + 1
							end
						end
					end
				end
			end
			
			if (take == 2) then
				local movers,mempty = findallfeature(nil,"is","move")
				moving_units,been_seen = add_moving_units("move",movers,moving_units,been_seen,mempty)
				
				local amovers,aempty = findallfeature(nil,"is","auto")
				moving_units,been_seen = add_moving_units("auto",amovers,moving_units,been_seen,aempty)
				
				local chillers,cempty = findallfeature(nil,"is","chill")
				moving_units,been_seen = add_moving_units("chill",chillers,moving_units,been_seen,cempty)
			elseif (take == 3) then
				local nudges1,nempty1 = findallfeature(nil,"is","nudgeright")
				moving_units,been_seen = add_moving_units("nudgeright",nudges1,moving_units,been_seen,nempty1)
				
				if (#moving_units == 0) then
					skiptake = true
				end
			elseif (take == 4) then
				local nudges2,nempty2 = findallfeature(nil,"is","nudgeup")
				moving_units,been_seen = add_moving_units("nudgeup",nudges2,moving_units,been_seen,nempty2)
				
				if (#moving_units == 0) then
					skiptake = true
				end
			elseif (take == 5) then
				local nudges3,nempty3 = findallfeature(nil,"is","nudgeleft")
				moving_units,been_seen = add_moving_units("nudgeleft",nudges3,moving_units,been_seen,nempty3)
				
				if (#moving_units == 0) then
					skiptake = true
				end
			elseif (take == 6) then
				local nudges4,nempty4 = findallfeature(nil,"is","nudgedown")
				moving_units,been_seen = add_moving_units("nudgedown",nudges4,moving_units,been_seen,nempty4)
				
				if (#moving_units == 0) then
					skiptake = true
				end
			elseif (take == 7) then
				local fears = getunitverbtargets("fear")
				
				for i,v in ipairs(fears) do
					local fearname = v[1]
					local fearlist = v[2]
					
					for a,b in ipairs(fearlist) do
						local sleeping = false
						local uid = b[1]
						local feartargets = b[2]
						local valid,feardir = false,4
						local amount = #feartargets
						
						if (fearname ~= "empty") then
							valid,feardir,amount = findfears(uid,feartargets)
						else
							local x = math.floor(uid % roomsizex)
							local y = math.floor(uid / roomsizex)
							valid,feardir = findfears(2,feartargets,x,y)
						end
						
						if valid and (amount > 0) then
							if (fearname ~= "empty") then
								local unit = mmf.newObject(uid)
							
								local unitname = getname(unit)
								local sleep = hasfeature(unitname,"is","sleep",uid)
								local still = cantmove(unitname,uid,feardir)
								local horiz = hasfeature(unitname,"is","horiz",uid)
								local vert = hasfeature(unitname,"is","vert",uid)
								
								if (sleep ~= nil) then
									sleeping = true
								elseif still then
									sleeping = true
									if((horiz == nil) and (vert == nil)) or (horiz ~= nil and vert ~= nil) or ((horiz ~= nil) and (vert == nil) and ((feardir == 0) or (feardir == 2))) or ((horiz == nil) and (vert ~= nil) and ((feardir == 1) or (feardir == 3))) then
										updatedir(uid,feardir)
									end
								else
									if((horiz == nil) and (vert == nil)) or (horiz ~= nil and vert ~= nil) or ((horiz ~= nil) and (vert == nil) and ((feardir == 0) or (feardir == 2))) or ((horiz == nil) and (vert ~= nil) and ((feardir == 1) or (feardir == 3))) then
										updatedir(uid,feardir)
									end
								end
							else
								local x = uid % roomsizex
								local y = math.floor(uid / roomsizex)
								
								local sleep = hasfeature("empty","is","sleep",2,x,y)
								local still = cantmove("empty",2,feardir,x,y)
								
								if (sleep ~= nil) or still then
									sleeping = true
								end
							end
							
							local bsid = uid
							if (fearname == "empty") then
								bsid = uid + 200
							end
							
							if (sleeping == false) then
								if (been_seen[bsid] == nil) then
									local x,y = -1,-1
									if (fearname ~= "empty") then
										local unit = mmf.newObject(uid)
										x,y = unit.values[XPOS],unit.values[YPOS]
										
										table.insert(moving_units, {unitid = uid, reason = "fear", state = 0, moves = amount, dir = feardir, xpos = x, ypos = y})
										been_seen[bsid] = #moving_units
									else
										x = uid % roomsizex
										y = math.floor(uid / roomsizex)
									
										table.insert(moving_units, {unitid = 2, reason = "fear", state = 0, moves = amount, dir = feardir, xpos = x, ypos = y})
										been_seen[bsid] = #moving_units
									end
								else
									local id = been_seen[bsid]
									local this = moving_units[id]
									this.moves = this.moves + 1
								end
							end
						end
					end
				end
			elseif (take == 8) then
				local shifts = findallfeature(nil,"is","shift",true)
				
				for i,v in ipairs(shifts) do
					if (v ~= 2) then
						local affected = {}
						local unit = mmf.newObject(v)
						
						local x,y = unit.values[XPOS],unit.values[YPOS]
						local tileid = x + y * roomsizex
						
						if (unitmap[tileid] ~= nil) then
							if (#unitmap[tileid] > 1) then
								for a,b in ipairs(unitmap[tileid]) do
									if (b ~= v) and floating(b,v,x,y) then
									
										--updatedir(b, unit.values[DIR])
										
										if (isstill_or_locked(b,x,y,unit.values[DIR]) == false) then
											if (been_seen[b] == nil) then
												table.insert(moving_units, {unitid = b, reason = "shift", state = 0, moves = 1, dir = unit.values[DIR], xpos = x, ypos = y})
												been_seen[b] = #moving_units
											else
												local id = been_seen[b]
												local this = moving_units[id]
												this.moves = this.moves + 1
											end
										end
									end
								end
							end
						end
					end
				end
				
				local levelshift = findfeature("level","is","shift")
				
				if (levelshift ~= nil) then
					local leveldir = mapdir
					local valid = false
					
					for a,b in ipairs(levelshift) do
						if (valid == false) and testcond(b[2],1) then
							valid = true
						end
					end
					
					if valid then
						for a,unit in ipairs(units) do
							local x,y = unit.values[XPOS],unit.values[YPOS]
							
							if floating_level(unit.fixed) then
								local unitname = getname(unit)
								local horiz = hasfeature(unitname,"is","horiz",unit.fixed)
								local vert = hasfeature(unitname,"is","vert",unit.fixed)
								if((horiz == nil) and (vert == nil)) or (horiz ~= nil and vert ~= nil) or ((horiz ~= nil) and (vert == nil) and ((leveldir == 0) or (leveldir == 2))) or ((horiz == nil) and (vert ~= nil) and ((leveldir == 1) or (leveldir == 3))) then
									updatedir(unit.fixed, leveldir)
								end
								
								if (isstill_or_locked(unit.fixed,x,y,leveldir) == false) and (issleep(unit.fixed,x,y) == false) then
									table.insert(moving_units, {unitid = unit.fixed, reason = "shift", state = 0, moves = 1, dir = leveldir, xpos = x, ypos = y})
								end
							end
						end
					end
				end
			end
		else
			for i,data in ipairs(still_moving) do
				if (data.unitid ~= 2) then
					local unit = mmf.newObject(data.unitid)
					
					table.insert(moving_units, {unitid = data.unitid, reason = data.reason, state = data.state, moves = data.moves, dir = unit.values[DIR], xpos = unit.values[XPOS], ypos = unit.values[YPOS]})
				else
					-- MF_alert("Still moving: " .. tostring(data.xpos) .. ", " .. tostring(data.ypos) .. ", " .. tostring(data.moves))
					table.insert(moving_units, {unitid = data.unitid, reason = data.reason, state = data.state, moves = data.moves, dir = data.dir, xpos = data.xpos, ypos = data.ypos})
				end
			end
			
			still_moving = {}
		end
		
		local unitcount = #moving_units
		local done = false
		local state = 0
		
		if skiptake then
			done = true
		end
		
		while (done == false) and (skiptake == false) and (debug_moves < movelimit) do
			local smallest_state = 99
			local delete_moving_units = {}
			
			for i,data in ipairs(moving_units) do
				local solved = false
				local skipthis = false
				smallest_state = math.min(smallest_state,data.state)
				
				if (data.unitid == 0) then
					solved = true
				end
				
				if (data.state == state) and (data.moves > 0) and (data.unitid ~= 0) then
					local unit = {}
					local dir,name = 4,""
					local x,y = data.xpos,data.ypos
					local holder = 0
					local olderDir = 4
					local horiz = nil
					local vert = nil
					
					if (data.unitid ~= 2) then
						unit = mmf.newObject(data.unitid)
						dir = unit.values[DIR]
						name = getname(unit)
						x,y = unit.values[XPOS],unit.values[YPOS]
						holder = unit.holder or 0
						horiz = hasfeature(name,"is","horiz",data.unitid)
						vert = hasfeature(name,"is","vert",data.unitid)
						if(data.reason ~= "nudgeup") and (data.reason ~= "nudgedown") and (data.reason ~= "nudgeleft") and (data.reason ~= "nudgeright") and data.reason ~= "move" and data.reason ~= "auto" and (((horiz ~= nil) and (vert == nil)) or ((horiz == nil) and (vert ~= nil))) then
							olderDir = dir
							dir = data.dir
						end
					else
						dir = data.dir
						name = "empty"
					end
					
					debug_moves = debug_moves + 1
					
					--MF_alert(name .. " (" .. tostring(data.unitid) .. ") doing " .. data.reason .. ", take " .. tostring(take) .. ", state " .. tostring(state) .. ", moves " .. tostring(data.moves) .. ", dir " .. tostring(dir))
					
					if (x ~= -1) and (y ~= -1) and (holder == 0) then
						local result = -1
						solved = false
						
						if (state == 0) then
							if (data.unitid == 2) and (((data.reason == "move") and (dir == 4)) or (data.reason == "chill")) then
								data.dir = fixedrandom(0,3)
								dir = data.dir
								
								if cantmove(name,data.unitid,dir,x,y) then
									skipthis = true
								end
							end
						elseif (state == 3) then
							if ((data.reason == "move") or (data.reason == "chill")) then
								local newdir_ = rotate(dir)
								
								if (cantmove(name,data.unitid,newdir_,x,y) == false) then
									dir = newdir_
								end
								
								if (data.unitid ~= 2) and (unit.flags[DEAD] == false) then
									
									updatedir(data.unitid, newdir_)
									--unit.values[DIR] = dir
									
									if cantmove(name,data.unitid,newdir_,x,y) then
										skipthis = true
									end
								end
							end
						end
						
						if (state == 0) and (data.reason == "shift") and (data.unitid ~= 2) then
							if((horiz == nil) and (vert == nil)) or (horiz ~= nil and vert ~= nil) or ((horiz ~= nil) and (vert == nil) and ((data.dir == 0) or (data.dir == 2))) or ((horiz == nil) and (vert ~= nil) and ((data.dir == 1) or (data.dir == 3))) then
								updatedir(data.unitid, data.dir)
							end
							dir = data.dir
						end
						
						if (dir == 4) then
							dir = fixedrandom(0,3)
						end
						
						local olddir = dir
						local returnolddir = false
						
						if (data.reason == "nudgeright") then
							dir = 0
							returnolddir = true
						elseif (data.reason == "nudgeup") then
							dir = 1
							returnolddir = true
						elseif (data.reason == "nudgeleft") then
							dir = 2
							returnolddir = true
						elseif (data.reason == "nudgedown") then
							dir = 3
							returnolddir = true
						end
						
						if (featureindex["reverse"] ~= nil) or (featureindex["reversehoriz"] ~= nil) or (featureindex["reversevert"] ~= nil) then
							local revdir = reversecheck(data.unitid,dir,x,y)
							if (revdir ~= dir) then
								dir = revdir
								returnolddir = true
							end
						end
						
						--MF_alert(data.reason)
						
						local newdir = dir
						
						local ndrs = ndirs[dir + 1]
						
						if (ndrs == nil) then
							MF_alert("dir is invalid: " .. tostring(dir) .. ", " .. tostring(name))
						end
						
						local ox,oy = ndrs[1],ndrs[2]
						local pushobslist = {}
						
						local obslist,allobs,specials = check(data.unitid,x,y,dir,false,data.reason)
						local pullobs,pullallobs,pullspecials = check(data.unitid,x,y,dir,true,data.reason)
						
						if returnolddir then
							dir = olddir
						end
						
						local swap = hasfeature(name,"is","swap",data.unitid,x,y)
						local still = cantmove(name,data.unitid,newdir,x,y)
						
						if returnolddir then
							dir = newdir
							
							--MF_alert(tostring(olddir) .. ", " .. tostring(newdir))
						end
						
						for c,obs in pairs(obslist) do
							if (solved == false) then
								if (obs == 0) then
									if (state == 0) then
										result = math.max(result, 0)
									else
										result = math.max(result, 0)
									end
								elseif (obs == -1) then
									result = math.max(result, 2)
									
									local levelpush_ = findfeature("level","is","push")
									
									if (levelpush_ ~= nil) then
										for e,f in ipairs(levelpush_) do
											if testcond(f[2],1) then
												levelpush = dir
											end
										end
									end
								else
									if (swap == nil) or still then
										if (#allobs == 0) then
											obs = 0
										end
										
										if (obs == 1) then
											local thisobs = allobs[c]
											local solid = true
											
											for f,g in pairs(specials) do
												if (g[1] == thisobs) and (g[2] == "weak") then
													solid = false
													obs = 0
													result = math.max(result, 0)
												end
											end
											
											if solid then
												if (state < 2) then
													data.state = math.max(data.state, 2)
													result = math.max(result, 2)
												else
													result = math.max(result, 2)
												end
											end
										else
											if (state < 1) then
												data.state = math.max(data.state, 1)
												result = math.max(result, 1)
											else
												table.insert(pushobslist, obs)
												result = math.max(result, 1)
											end
										end
									else
										result = math.max(result, 0)
									end
								end
							end
						end
						
						if (skipthis == false) then
							local result_check = false
							
							while (result_check == false) and (solved == false) do
								if (result == 0) then
									if (state > 0) then
										for j,jdata in pairs(moving_units) do
											if (jdata.state >= 2) and (jdata.state ~= 10) then
												jdata.state = 0
											end
										end
									end
									
									if((horiz ~= nil) and (vert == nil) and ((olddir == 1) or (olddir == 3))) or ((horiz == nil) and (vert ~= nil) and ((olddir == 0) or (olddir == 2))) then
										table.insert(movelist, {data.unitid,ox,oy,olderdir,specials,x,y})
									else
										table.insert(movelist, {data.unitid,ox,oy,olddir,specials,x,y})
									end
									if (data.unitid == 2) and (data.moves > 1) then
										data.xpos = x + ox
										data.ypos = y + oy
										data.dir = dir
									end
									--move(data.unitid,ox,oy,dir,specials)
									
									local swapped = {}
									
									if (swap ~= nil) and (still == false) then
										for a,b in ipairs(allobs) do
											if (b ~= -1) and (b ~= 2) and (b ~= 0) then
												local swapunit = mmf.newObject(b)
												local swapname = getname(swapunit)
												
												local obsstill = hasfeature(swapname,"is","still",b,x+ox,y+oy)
												
												if (obsstill == nil) then
													addaction(b,{"update",x,y,nil})
													swapped[b] = 1
												end
											end
										end
									end
									
									local swaps = findfeatureat(nil,"is","swap",x+ox,y+oy,{"still"})
									if (swaps ~= nil) then
										for a,b in ipairs(swaps) do
											if (swapped[b] == nil) and (b ~= 2) then
												addaction(b,{"update",x,y,nil})
											end
										end
									end
									
									local finalpullobs = {}
									
									for c,pobs in ipairs(pullobs) do
										if (pobs < -1) or (pobs > 1) then
											local paobs = pullallobs[c]
											local hm = 0
											
											if (paobs ~= 2) then
												hm = trypush(paobs,ox,oy,dir,true,x,y,data.reason,data.unitid)
											else
												hm = trypush(paobs,ox,oy,dir,true,x-ox,y-oy,data.reason,data.unitid)
											end
											
											if (hm == 0) then
												table.insert(finalpullobs, paobs)
											end
										elseif (pobs == -1) then
											local levelpull_ = findfeature("level","is","pull")
										
											if (levelpull_ ~= nil) then
												for e,f in ipairs(levelpull_) do
													if testcond(f[2],1) then
														levelpull = dir
													end
												end
											end
										end
									end
									
									for c,pobs in ipairs(finalpullobs) do
										pushedunits = {}
										
										if (pobs ~= 2) then
											dopush(pobs,ox,oy,dir,true,x,y,data.reason,data.unitid)
										else
											dopush(pobs,ox,oy,dir,true,x-ox,y-oy,data.reason,data.unitid)
										end
									end
									
									solved = true
								elseif (result == 1) then
									if (state < 1) then
										data.state = math.max(data.state, 1)
										result_check = true
									else
										local finalpushobs = {}
										
										for c,pushobs in ipairs(pushobslist) do
											local hm = 0
											if (pushobs ~= 2) then
												hm = trypush(pushobs,ox,oy,dir,false,x,y,data.reason)
											else
												hm = trypush(pushobs,ox,oy,dir,false,x+ox,y+oy,data.reason)
											end
											
											if (hm == 0) then
												table.insert(finalpushobs, pushobs)
											elseif (hm == 1) or (hm == -1) then
												result = math.max(result, 2)
											else
												MF_alert("HOO HAH")
												return
											end
										end
										
										if (result == 1) then
											for c,pushobs in ipairs(finalpushobs) do
												pushedunits = {}
												
												if (pushobs ~= 2) then
													dopush(pushobs,ox,oy,dir,false,x,y,data.reason)
												else
													dopush(pushobs,ox,oy,dir,false,x+ox,y+oy,data.reason)
												end
											end
											result = 0
										end
									end
								elseif (result == 2) then
									if (state < 2) then
										data.state = math.max(data.state, 2)
										result_check = true
									else
										if (state < 3) then
											data.state = math.max(data.state, 3)
											result_check = true
										else
											if ((data.reason == "move") or (data.reason == "chill")) and (state < 4) then
												data.state = math.max(data.state, 4)
												result_check = true
											else
												local weak = hasfeature(name,"is","weak",data.unitid,x,y)
												
												if (weak ~= nil) and (issafe(data.unitid,x,y) == false) then
													delete(data.unitid,x,y)
													generaldata.values[SHAKE] = 3
													
													local pmult,sound = checkeffecthistory("weak")
													MF_particles("destroy",x,y,5 * pmult,0,3,1,1)
													setsoundname("removal",1,sound)
													data.moves = 1
												end
												solved = true
											end
										end
									end
								else
									result_check = true
								end
							end
						else
							solved = true
						end
					else
						solved = true
					end
				end
				
				if solved then
					data.moves = data.moves - 1
					
					if (state > 0) then
						data.state = 10
					end
					
					-- MF_alert("(" .. tostring(data.unitid) .. ") solved, " .. data.reason .. ", t " .. tostring(take) .. ", s " .. tostring(data.state) .. ", m " .. tostring(data.moves) .. ", " .. tostring(data.xpos) .. ", " .. tostring(data.ypos))
					
					if (data.moves == 0) then
						--MF_alert(tunit.strings[UNITNAME] .. " - removed from queue")
						table.insert(delete_moving_units, i)
					else
						table.insert(still_moving, {unitid = data.unitid, reason = data.reason, state = data.state, moves = data.moves, dir = data.dir, xpos = data.xpos, ypos = data.ypos})
						--MF_alert(tunit.strings[UNITNAME] .. " - removed from queue")
						table.insert(delete_moving_units, i)
					end
				end
			end
			
			local deloffset = 0
			for i,v in ipairs(delete_moving_units) do
				local todel = v - deloffset
				table.remove(moving_units, todel)
				deloffset = deloffset + 1
			end
			
			if (#movelist > 0) then
				for i,data in ipairs(movelist) do
					move(data[1],data[2],data[3],data[4],data[5],nil,nil,data[6],data[7])
				end
			end
			
			movelist = {}
			
			if (smallest_state > state) then
				state = state + 1
			else
				state = smallest_state
			end
			
			if (#moving_units == 0) then
				doupdate()
				done = true
			else
				movemap = {}
			end
		end
		
		if (debug_moves >= movelimit) then
			HACK_INFINITY = 200
			destroylevel("toocomplex")
			return
		end

		if (#still_moving > 0) then
			finaltake = true
			moving_units = {}
		else
			finaltake = false
		end
		
		if (finaltake == false) then
			take = take + 1
		end
	end
	
	if (levelpush >= 0) then
		local ndrs = ndirs[levelpush + 1]
		local ox,oy = ndrs[1],ndrs[2]
		
		addundo({"levelupdate",Xoffset,Yoffset,Xoffset + ox * tilesize,Yoffset + oy * tilesize,mapdir,levelpush})
		
		mapdir = levelpush
		
		MF_scrollroom(ox * tilesize,oy * tilesize)
		updateundo = true
	end
	
	if (levelpull >= 0) then
		local ndrs = ndirs[levelpull + 1]
		local ox,oy = ndrs[1],ndrs[2]
		
		addundo({"levelupdate",Xoffset,Yoffset,Xoffset + ox * tilesize,Yoffset + oy * tilesize,mapdir,levelpull})
		
		mapdir = levelpull
		
		MF_scrollroom(ox * tilesize,oy * tilesize)
		updateundo = true
	end
	
	if (HACK_MOVES >= 10000) then
		HACK_MOVES = 0
		HACK_INFINITY = 200
		destroylevel("infinity")
		return
	end
	
	doupdate()
	code()
	conversion()
	doupdate()
	code()
	moveblock()
	
	if (dir_ ~= nil) then
		mapcursor_move(ox,oy,dir_)
	end
	
	if (#units > 0) and (no3d == false) then
		local vistest,vt2 = findallfeature(nil,"is","3d",true)
		if (#vistest > 0) or (#vt2 > 0) then
			local target = vistest[1] or vt[1]
			visionmode(1)
		elseif (spritedata.values[VISION] == 1) then
			local vistest2 = findfeature(nil,"is","3d")
			if (vistest2 == nil) then
				visionmode(0)
			end
		end
	end
end

function check(unitid,x,y,dir,pulling_,reason)
	local pulling = false
	if (pulling_ ~= nil) then
		pulling = pulling_
	end
	
	local dir_ = dir
	if pulling then
		dir_ = rotate(dir)
	end
	
	local ndrs = ndirs[dir_ + 1]
	local ox,oy = ndrs[1],ndrs[2]
	
	local result = {}
	local results = {}
	local specials = {}
	local unit = {}
	local name = ""
	
	if (unitid ~= 2) then
		unit = mmf.newObject(unitid)
		name = getname(unit)
	else
		name = "empty"
	end
	
	local lockpartner = ""
	local open = hasfeature(name,"is","open",unitid,x,y)
	local shut = hasfeature(name,"is","shut",unitid,x,y)
	local eat = hasfeature(name,"eat",nil,unitid,x,y)
	local phantom = hasfeature(name,"is","phantom",unitid,x,y)
	
	if pulling then
		phantom = nil
	end
	
	if (open ~= nil) then
		lockpartner = "shut"
	elseif (shut ~= nil) then
		lockpartner = "open"
	end
	
	local obs = findobstacle(x+ox,y+oy)
	
	if (#obs > 0) and (phantom == nil) then
		for i,id in ipairs(obs) do
			if (id == -1) then
				table.insert(result, -1)
				table.insert(results, -1)
			else
				local obsunit = mmf.newObject(id)
				local obsname = getname(obsunit)
				
				local alreadymoving = findupdate(id,"update")
				local valid = true
				
				local localresult = 0
				
				if (#alreadymoving > 0) then
					for a,b in ipairs(alreadymoving) do
						local nx,ny = b[3],b[4]
						
						if ((nx ~= x) and (ny ~= y)) and ((reason == "shift") and (pulling == false)) then
							valid = false
						end
						
						if ((nx == x) and (ny == y + oy * 2)) or ((ny == y) and (nx == x + ox * 2)) then
							valid = false
						end
					end
				end
				
				if (lockpartner ~= "") and (pulling == false) then
					local partner = hasfeature(obsname,"is",lockpartner,id,x+ox,y+oy)
					
					if (partner ~= nil) and ((issafe(id,x+ox,y+oy) == false) or (issafe(unitid,x,y) == false)) and floating(id,unitid,x+ox,y+oy) then
						valid = false
						table.insert(specials, {id, "lock"})
					end
				end
				
				if (eat ~= nil) and (pulling == false) then
					local eats = hasfeature(name,"eat",obsname,unitid,x+ox,y+oy)
					
					if (eats ~= nil) and (issafe(id,x+ox,y+oy) == false) and floating(id,unitid,x+ox,y+oy) then
						valid = false
						table.insert(specials, {id, "eat"})
					end
				end
				
				local weak = hasfeature(obsname,"is","weak",id,x+ox,y+oy)
				if (weak ~= nil) and (pulling == false) then
					if (issafe(id,x+ox,y+oy) == false) and floating(id,unitid,x+ox,y+oy) then
						--valid = false
						table.insert(specials, {id, "weak"})
					end
				end
				
				local added = false
				
				if valid then
					--MF_alert("checking for solidity for " .. obsname .. " by " .. name .. " at " .. tostring(x) .. ", " .. tostring(y))
					
					local isstop = hasfeature(obsname,"is","stop",id,x+ox,y+oy)
					local ispush = hasfeature(obsname,"is","push",id,x+ox,y+oy)
					local ispull = hasfeature(obsname,"is","pull",id,x+ox,y+oy)
					local isswap = hasfeature(obsname,"is","swap",id,x+ox,y+oy)
					local isstill = cantmove(obsname,id,dir,x+ox,y+oy)
					
					--MF_alert(obsname .. " -- stop: " .. tostring(isstop) .. ", push: " .. tostring(ispush))
					
					if (ispush ~= nil) and isstill then
						ispush = nil
						isstop = true
					end
					
					if (ispull ~= nil) and isstill then
						ispull = nil
						isstop = true
					end
					
					if (isswap ~= nil) and isstill then
						isswap = nil
					end
					
					if (isstop ~= nil) and (obsname == "level") and (obsunit.visible == false) then
						isstop = nil
					end
					
					if (((isstop ~= nil) and (ispush == nil) and ((ispull == nil) or ((ispull ~= nil) and (pulling == false)))) or ((ispull ~= nil) and (pulling == false) and (ispush == nil))) and (isswap == nil) then
						if (weak == nil) or ((weak ~= nil) and (floating(id,unitid,x+ox,y+oy) == false)) then
							table.insert(result, 1)
							table.insert(results, id)
							localresult = 1
							added = true
						end
					end
					
					if (localresult ~= 1) and (localresult ~= -1) then
						if (ispush ~= nil) and (pulling == false) and (isswap == nil) then
							--MF_alert(obsname .. " added to push list")
							table.insert(result, id)
							table.insert(results, id)
							added = true
						end
						
						if (ispull ~= nil) and pulling then
							table.insert(result, id)
							table.insert(results, id)
							added = true
						end
					end
				end
				
				if (added == false) then
					table.insert(result, 0)
					table.insert(results, id)
				end
			end
		end
	elseif (phantom == nil) then
		local emptystop = hasfeature("empty","is","stop",2,x+ox,y+oy)
		local emptypush = hasfeature("empty","is","push",2,x+ox,y+oy)
		local emptypull = hasfeature("empty","is","pull",2,x+ox,y+oy)
		local emptyswap = hasfeature("empty","is","swap",2,x+ox,y+oy)
		local emptystill = cantmove("empty",2,dir_,x+ox,y+oy)
		
		local localresult = 0
		local valid = true
		local bname = "empty"
		
		if (eat ~= nil) and (pulling == false) then
			local eats = hasfeature(name,"eat","empty",unitid,x+ox,y+oy)
			
			if (eats ~= nil) and (issafe(2,x+ox,y+oy) == false) and floating(unitid,2,x+ox,y+oy) then
				valid = false
				table.insert(specials, {2, "eat"})
			end
		end
		
		if (lockpartner ~= "") and (pulling == false) then
			local partner = hasfeature("empty","is",lockpartner,2,x+ox,y+oy)
			
			if (partner ~= nil) and ((issafe(2,x+ox,y+oy) == false) or (issafe(unitid,x,y) == false)) and floating(unitid,2,x+ox,y+oy) then
				valid = false
				table.insert(specials, {2, "lock"})
			end
		end
		
		local weak = hasfeature("empty","is","weak",2,x+ox,y+oy)
		if (weak ~= nil) and (pulling == false) then
			if (issafe(2,x+ox,y+oy) == false) and floating(unitid,2,x+ox,y+oy) then
				valid = false
				table.insert(specials, {2, "weak"})
			end
		end
		
		local added = false
		
		if valid then
			local estop = 0
			
			if (emptyswap ~= nil) and emptystill then
				emptyswap = nil
			end
			
			if (emptypush == nil) and (emptyswap == nil) then
				if (emptypull ~= nil) and (pulling == false) then
					estop = 1
				elseif (emptypull ~= nil) and pulling and emptystill then
					estop = 1
				elseif (emptypull == nil) and (emptystop ~= nil) then
					estop = 1
				end
			elseif emptystill then
				estop = 1
			end
			
			if (estop == 1) then
				localresult = 1
				table.insert(result, 1)
				table.insert(results, 2)
				added = true
			end
			
			if (localresult ~= 1) then
				if (emptypush ~= nil) and (pulling == false) and (emptyswap == nil) then
					table.insert(result, 2)
					table.insert(results, 2)
					added = true
				end
				
				if (emptypull ~= nil) and pulling then
					table.insert(result, 2)
					table.insert(results, 2)
					added = true
				end
			end
		end
		
		if (added == false) then
			table.insert(result, 0)
			table.insert(results, 2)
		end
	end
	
	if (#results == 0) then
		result = {0}
		results = {0}
	end
	
	return result,results,specials
end

function trypush(unitid,ox,oy,dir,pulling_,x_,y_,reason,pusherid)
	local x,y = 0,0
	local unit = {}
	local name = ""
	
	if (unitid ~= 2) then
		unit = mmf.newObject(unitid)
		x,y = unit.values[XPOS],unit.values[YPOS]
		name = getname(unit)
	else
		x = x_
		y = y_
		name = "empty"
	end
	
	local tileid = x + y * roomsizex
	local moveid = tostring(tileid) .. name .. tostring(dir)
	
	if (movemap[moveid] == nil) then
		movemap[moveid] = {}
	end
	
	if (movemap[moveid]["tryresult"] == nil) then
		movemap[moveid]["tryresult"] = 0
	end
	
	local movedata = movemap[moveid]
	
	local pulling = pulling_ or false
	
	local weak = hasfeature(name,"is","weak",unitid,x_,y_)

	if (weak == nil) or pulling or ((weak ~= nil) and issafe(unitid,x_,y_)) then
		local result = 0
		
		if (movedata.tryresult == 0) then
			local hmlist,hms,specials = check(unitid,x,y,dir,false,reason)
			
			for i,hm in pairs(hmlist) do
				local done = false
				
				while (done == false) do
					if (hm == 0) then
						result = math.max(0, result)
						done = true
					elseif (hm == 1) or (hm == -1) then
						if (pulling == false) or (pulling and (hms[i] ~= pusherid)) then
							result = math.max(1, result)
							done = true
						else
							result = math.max(0, result)
							done = true
						end
					else
						if (pulling == false) then
							hm = trypush(hm,ox,oy,dir,pulling,x+ox,y+oy,reason,unitid)
						else
							result = math.max(0, result)
							done = true
						end
					end
				end
			end
			
			movedata.tryresult = result + 1
		else
			result = movedata.tryresult - 1
		end
		
		return result
	else
		return 0
	end
end

function dopush(unitid,ox,oy,dir,pulling_,x_,y_,reason,pusherid)
	local pid2 = tostring(ox + oy * roomsizex) .. tostring(unitid)
	pushedunits[pid2] = 1
	
	local x,y = 0,0
	local unit = {}
	local name = ""
	local pushsound = false
	
	if (unitid ~= 2) then
		unit = mmf.newObject(unitid)
		x,y = unit.values[XPOS],unit.values[YPOS]
		name = getname(unit)
	else
		x = x_
		y = y_
		name = "empty"
	end
	
	local pulling = false
	if (pulling_ ~= nil) then
		pulling = pulling_
	end
	
	local swaps = findfeatureat(nil,"is","swap",x+ox,y+oy,{"still"})
	
	if (swaps ~= nil) and ((unitid ~= 2) or ((unitid == 2) and (pulling == false))) then
		for a,b in ipairs(swaps) do
			if (pulling == false) or (pulling and (b ~= pusherid)) then
				local alreadymoving = findupdate(b,"update")
				local valid = true
				
				if (#alreadymoving > 0) then
					valid = false
				end
				
				if valid then
					addaction(b,{"update",x,y,nil})
				end
			end
		end
	end
	
	if pulling then
		local swap = hasfeature(name,"is","swap",unitid,x,y,{"still"})
		
		if swap then
			local swapthese = findallhere(x+ox,y+oy)
			
			for a,b in ipairs(swapthese) do
				if (b ~= pusherid) then
					local alreadymoving = findupdate(b,"update")
					local valid = true
					
					if (#alreadymoving > 0) then
						valid = false
					end
					
					if valid and (b ~= 2) then
						addaction(b,{"update",x,y,nil})
						pushsound = true
					end
				end
			end
		end
	end

	local hm = 0
	local tileid = x + y * roomsizex
	local moveid = tostring(tileid) .. name .. tostring(dir)
	
	if (movemap[moveid] == nil) then
		movemap[moveid] = {}
	end
	
	if (movemap[moveid]["push"] == nil) then
		movemap[moveid]["push"] = 0
		movemap[moveid]["pull"] = 0
		movemap[moveid]["result"] = 0
	end
	
	local movedata = movemap[moveid]
	
	if (HACK_MOVES < 10000) then
		local hmlist,hms,specials = check(unitid,x,y,dir,false,reason)
		local pullhmlist,pullhms,pullspecials = check(unitid,x,y,dir,true,reason)
		local result = 0
		
		local weak = hasfeature(name,"is","weak",unitid,x_,y_)
		
		if (movedata.result == 0) then
			for i,obs in pairs(hmlist) do
				local done = false
				while (done == false) do
					if (obs == 0) then
						result = math.max(0, result)
						done = true
					elseif (obs == 1) or (obs == -1) then
						if (pulling == false) or (pulling and (hms[i] ~= pusherid)) then
							result = math.max(2, result)
							done = true
						else
							result = math.max(0, result)
							done = true
						end
					else
						if (pulling == false) or (pulling and (hms[i] ~= pusherid)) then
							result = math.max(1, result)
							done = true
						else
							result = math.max(0, result)
							done = true
						end
					end
				end
			end
			
			movedata.result = result + 1
		else
			result = movedata.result - 1
			done = true
		end
		
		local finaldone = false
		
		while (finaldone == false) and (HACK_MOVES < 10000) do
			if (result == 0) then
				if(unitid ~= 2) then
					local horiz = hasfeature(name, "is", "horiz", unitid)
					local vert = hasfeature(name, "is", "vert", unitid)
					if((horiz ~= nil) and (vert == nil) and ((dir == 1) or (dir == 3))) or ((horiz == nil) and (vert ~= nil) and ((dir == 0) or (dir == 2))) then
						table.insert(movelist, {unitid,ox,oy,unit.values[DIR],specials,x,y})
					else
						table.insert(movelist, {unitid,ox,oy,dir,specials,x,y})
					end
				else
					table.insert(movelist, {unitid,ox,oy,dir,specials,x,y})
				end
				--move(unitid,ox,oy,dir,specials)
				pushsound = true
				finaldone = true
				hm = 0
				
				if (pulling == false) and (movedata.pull == 0) then
					for i,obs in ipairs(pullhmlist) do
						if (obs < -1) or (obs > 1) and (obs ~= pusherid) then
							if (obs ~= 2) then
								_unit = mmf.newObject(obs)
								_name = getname(unit)
								local horiz = hasfeature(_name, "is", "horiz", obs)
								local vert = hasfeature(_name, "is", "vert", obs)
								if((horiz ~= nil) and (vert == nil) and ((dir == 1) or (dir == 3))) or ((horiz == nil) and (vert ~= nil) and ((dir == 0) or (dir == 2))) then
									table.insert(movelist, {obs,ox,oy,_unit.values[DIR],pullspecials,x,y})
								else
									table.insert(movelist, {obs,ox,oy,dir,pullspecials,x,y})
								end
								pushsound = true
								--move(obs,ox,oy,dir,specials)
							end
							
							local pid = tostring(x-ox + (y-oy) * roomsizex) .. tostring(obs)
							
							if (pushedunits[pid] == nil) then
								pushedunits[pid] = 1
								
								hm = dopush(obs,ox,oy,dir,true,x-ox,y-oy,reason,unitid)
							end
							
							movedata.pull = 1
						end
					end
				end
			elseif (result == 1) then
				if (movedata.push == 0) then
					for i,v in ipairs(hmlist) do
						if (v ~= -1) and (v ~= 0) and (v ~= 1) then
							local pid = tostring(x+ox + (y+oy) * roomsizex) .. tostring(v)
							
							if (pulling == false) or (pulling and (hms[i] ~= pusherid)) and (pushedunits[pid] == nil) then
								pushedunits[pid] = 1
								hm = dopush(v,ox,oy,dir,false,x+ox,y+oy,reason,unitid)
							end
						end
					end
				else
					hm = movedata.push - 1
				end
				
				movedata.push = hm + 1
				
				if (hm == 0) then
					result = 0
				else
					result = 2
				end
			elseif (result == 2) then
				hm = 1
				
				if (weak ~= nil) then
					delete(unitid,x,y)
					
					local pmult,sound = checkeffecthistory("weak")
					setsoundname("removal",1,sound)
					generaldata.values[SHAKE] = 3
					MF_particles("destroy",x,y,5 * pmult,0,3,1,1)
					result = 0
					hm = 0
				end
				
				finaldone = true
			end
		end
		
		if pulling and (HACK_MOVES < 10000) then
			hmlist,hms,specials = check(unitid,x,y,dir,pulling,reason)
			hm = 0
		
			for i,obs in pairs(hmlist) do
				if (obs < -1) or (obs > 1) then
					local pid = tostring(x - ox + (y - oy) * roomsizex) .. tostring(obs)
					
					if (obs ~= 2) and (pushedunits[pid] == nil) then
						_unit = mmf.newObject(obs)
						_name = getname(unit)
						local horiz = hasfeature(_name, "is", "horiz", obs)
						local vert = hasfeature(_name, "is", "vert", obs)
						if((horiz ~= nil) and (vert == nil) and ((dir == 1) or (dir == 3))) or ((horiz == nil) and (vert ~= nil) and ((dir == 0) or (dir == 2))) then
							table.insert(movelist, {obs,ox,oy,_unit.values[DIR],specials,x,y})
						else
							table.insert(movelist, {obs,ox,oy,dir,specials,x,y})
						end
						table.insert(movelist, {obs,ox,oy,dir,specials,x,y})
						pushsound = true
					end
					
					if (pushedunits[pid] == nil) then
						pushedunits[pid] = 1
						hm = dopush(obs,ox,oy,dir,pulling,x-ox,y-oy,reason,unitid)
					end
				end
			end
			
			if (movedata.pull == 0) then
				movedata.pull = hm + 1
			else
				hm = movedata.pull - 1
			end
		end
		
		if pushsound and (generaldata2.strings[TURNSOUND] == "") then
			setsoundname("turn",5)
		end
	end
	
	HACK_MOVES = HACK_MOVES + 1
	
	return hm
end

function move(unitid,ox,oy,dir,specials_,instant_,simulate_,x_,y_)
	local instant = instant_ or false
	local simulate = simulate_ or false
	
	local x,y = 0,0
	local unit = {}
	
	if (unitid ~= 2) then
		unit = mmf.newObject(unitid)
		x,y = unit.values[XPOS],unit.values[YPOS]
	else
		x = x_
		y = y_
	end
	
	local specials = {}
	if (specials_ ~= nil) then
		specials = specials_
	end
	
	local gone = false
	
	for i,v in pairs(specials) do
		if (gone == false) then
			local b = v[1]
			local reason = v[2]
			local dodge = false
			
			local bx,by = 0,0
			if (b ~= 2) and (deleted[b] ~= nil) then
				MF_alert("Already gone")
				dodge = true
			elseif (b ~= 2) and (reason ~= "weak") then
				local bunit = mmf.newObject(b)
				bx,by = bunit.values[XPOS],bunit.values[YPOS]
				
				if (bx ~= x+ox) or (by ~= y+oy) then
					dodge = true
				else
					for c,d in ipairs(movelist) do
						if (d[1] == b) then
							local nx,ny = d[2],d[3]
							
							--print(tostring(nx) .. "," .. tostring(ny) .. " --> " .. tostring(x+ox) .. "," .. tostring(y+oy) .. " (" .. tostring(bx) .. "," .. tostring(by) .. ")")
							if (nx ~= x+ox) or (ny ~= y+oy) then
								dodge = true
							end
						end
					end
				end
			else
				bx,by = x+ox,y+oy
			end
			
			if (dodge == false) then
				if (reason == "lock") then
					local unlocked = false
					local valid = true
					local soundshort = ""
					
					if (b ~= 2) then
						local bunit = mmf.newObject(b)
						
						if bunit.flags[DEAD] then
							valid = false
						end
					end
					
					if (unitid ~= 2) and unit.flags[DEAD] then
						valid = false
					end
					
					if valid then
						local pmult = 1.0
						local effect1 = false
						local effect2 = false
						
						if (issafe(b,bx,by) == false) then
							delete(b,bx,by)
							unlocked = true
							effect1 = true
						end
						
						if (issafe(unitid,x,y) == false) then
							delete(unitid,x,y)
							unlocked = true
							gone = true
							effect2 = true
						end
						
						if effect1 or effect2 then
							local pmult,sound = checkeffecthistory("unlock")
							soundshort = sound
						end
						
						if effect1 then
							MF_particles("unlock",bx,by,15 * pmult,2,4,1,1)
							generaldata.values[SHAKE] = 8
						end
						
						if effect2 then
							MF_particles("unlock",x,y,15 * pmult,2,4,1,1)
							generaldata.values[SHAKE] = 8
						end
					end
					
					if unlocked then
						setsoundname("turn",7,soundshort)
					end
				elseif (reason == "eat") then
					local pmult,sound = checkeffecthistory("eat")
					MF_particles("eat",bx,by,10 * pmult,0,3,1,1)
					generaldata.values[SHAKE] = 3
					delete(b,bx,by)
					
					setsoundname("removal",1,sound)
				elseif (reason == "weak") then
					if (b == 2) and (unitid ~= 2) then
						local pmult,sound = checkeffecthistory("weak")
						MF_particles("destroy",bx,by,5 * pmult,0,3,1,1)
						generaldata.values[SHAKE] = 3
						delete(b,bx,by)
						
						setsoundname("removal",1,sound)
					end
				end
			end
		end
	end
	
	if (gone == false) and (simulate == false) and (unitid ~= 2) then
		if instant then
			update(unitid,x+ox,y+oy,dir)
			MF_alert("Instant movement on " .. tostring(unitid))
		else
			addaction(unitid,{"update",x+ox,y+oy,dir})
		end
		
		if unit.visible and (#movelist < 700) and (spritedata.values[VISION] == 0) then
			if (generaldata.values[DISABLEPARTICLES] == 0) and (generaldata5.values[LEVEL_DISABLEPARTICLES] == 0) then
				local effectid = MF_effectcreate("effect_bling")
				local effect = mmf.newObject(effectid)
				
				local midxdelta = spritedata.values[XMIDTILE] - roomsizex * 0.5
				local midydelta = spritedata.values[YMIDTILE] - roomsizey * 0.5
				local midx = roomsizex * 0.5 + midxdelta * generaldata2.values[ZOOM]
				local midy = roomsizey * 0.5 + midydelta * generaldata2.values[ZOOM]
				local mx = x - midx
				local my = y - midy
				
				local c1,c2 = 0,0
				
				if (unit.colour ~= nil) and (unit.colour[1] ~= nil) and (unit.colour[2] ~= nil) then
					c1 = unit.colour[1]
					c2 = unit.colour[2]
				else
					if (unit.active == false) then
						c1,c2 = getcolour(unitid)
					else
						c1,c2 = getcolour(unitid,"active")
					end
				end
				MF_setcolour(effectid,c1,c2)
				
				local xvel,yvel = 0,0
				
				if (ox ~= 0) then
					xvel = 0 - ox / math.abs(ox)
				end
				
				if (oy ~= 0) then
					yvel = 0 - oy / math.abs(oy)
				end
				
				local dx = mx + 0.5
				local dy = my + 0.75
				local dxvel = xvel
				local dyvel = yvel
				
				if (generaldata2.values[ROOMROTATION] == 90) then
					dx = my + 0.75
					dy = 0 - mx - 0.5
					dxvel = yvel
					dyvel = 0 - xvel
				elseif (generaldata2.values[ROOMROTATION] == 180) then
					dx = 0 - mx - 0.5
					dy = 0 - my - 0.75
					dxvel = 0 - xvel
					dyvel = 0 - yvel
				elseif (generaldata2.values[ROOMROTATION] == 270) then
					dx = 0 - my - 0.75
					dy = mx + 0.5
					dxvel = 0 - yvel
					dyvel = xvel
				end
				
				effect.values[ONLINE] = 3
				effect.values[XPOS] = Xoffset + (midx + (dx) * generaldata2.values[ZOOM]) * tilesize * spritedata.values[TILEMULT]
				effect.values[YPOS] = Yoffset + (midy + (dy) * generaldata2.values[ZOOM]) * tilesize * spritedata.values[TILEMULT]
				effect.scaleX = generaldata2.values[ZOOM] * spritedata.values[TILEMULT]
				effect.scaleY = generaldata2.values[ZOOM] * spritedata.values[TILEMULT]
				
				effect.values[XVEL] = dxvel * math.random(10,30) * 0.1 * spritedata.values[TILEMULT] * generaldata2.values[ZOOM]
				effect.values[YVEL] = dyvel * math.random(10,30) * 0.1 * spritedata.values[TILEMULT] * generaldata2.values[ZOOM]
			end
			
			if (unit.values[TILING] == 2) then
				unit.values[VISUALDIR] = ((unit.values[VISUALDIR] + 1) + 4) % 4
			end
		end
	end
	
	return gone
end

function add_moving_units(rule,newdata,data,been_seen,empty_)
	local result = data
	local seen = been_seen
	local emptyseen = {}
	local empty = empty_ or {}
	
	for i,v in ipairs(newdata) do
		local sleeping = false
		
		if (v ~= 2) then
			local unit = mmf.newObject(v)
			local unitname = getname(unit)
			local sleep = hasfeature(unitname,"is","sleep",v)
			
			if (rule == "chill") and (sleep == nil) then
				local dir = fixedrandom(0,3)
				
				if(hasfeature(name,"is","horiz",unit.fixed) ~= nil) and (hasfeature(name,"is","vert",unit.fixed) == nil) then
					if(dir == 1) then
						dir = 0
					elseif(dir == 3) then
						dir = 2
					end
				elseif(hasfeature(name,"is","horiz",unit.fixed) == nil) and (hasfeature(name,"is","vert",unit.fixed) ~= nil) then
					if(dir == 0) then
						dir = 1
					elseif(dir == 2) then
						dir = 3
					end
				end
				
				if (data.unitid ~= 2) then
					updatedir(v, dir)
				end
			end
			
			local dir = unit.values[DIR]
			if (rule == "nudgeright") then
				dir = 0
			elseif (rule == "nudgeup") then
				dir = 1
			elseif (rule == "nudgeleft") then
				dir = 2
			elseif (rule == "nudgedown") then
				dir = 3
			end
			
			local still = cantmove(unitname,v,dir)
			
			if (sleep ~= nil) or still then
				sleeping = true
			end
		else
			local thisempty = empty[i]
			
			for a,b in pairs(thisempty) do
				local x = a % roomsizex
				local y = math.floor(a / roomsizex)
				
				local dir = data.dir
				if (rule == "nudgeright") then
					dir = 0
				elseif (rule == "nudgeup") then
					dir = 1
				elseif (rule == "nudgeleft") then
					dir = 2
				elseif (rule == "nudgedown") then
					dir = 3
				end
				
				local sleep = hasfeature("empty","is","sleep",2,x,y)
				local still = cantmove("empty",2,dir,x,y)
				
				if (sleep ~= nil) or still then
					thisempty[a] = nil
				end
			end
		end
		
		if (sleeping == false) then
			local seencode = v
			if (v == 2) then
				seencode = i * 1000 + v
			end
			
			if (seen[seencode] == nil) then
				local dir_ = 4
				
				local x,y = -1,-1
				if (v ~= 2) then
					local unit = mmf.newObject(v)
					x,y = unit.values[XPOS],unit.values[YPOS]
					
					table.insert(result, {unitid = v, reason = rule, state = 0, moves = 1, dir = dir_, xpos = x, ypos = y})
					seen[seencode] = #result
				else
					local thisempty = empty[i]
				
					for a,b in pairs(thisempty) do
						x = a % roomsizex
						y = math.floor(a / roomsizex)
						
						dir_ = emptydir(x,y)
						
						table.insert(result, {unitid = 2, reason = rule, state = 0, moves = 1, dir = dir_, xpos = x, ypos = y})
						seen[seencode] = #result
						
						if (emptyseen[seencode] == nil) then
							emptyseen[seencode] = {}
						end
						
						table.insert(emptyseen[seencode], #result)
					end
				end
			else
				if (v ~= 2) then
					local id = seen[seencode]
					local this = result[id]
					this.moves = this.moves + 1
				elseif (emptyseen[seencode] ~= nil) then
					for a,b in ipairs(emptyseen[seencode]) do
						local this = result[b]
						this.moves = this.moves + 1
					end
				end
			end
		end
	end
	
	return result,seen
end