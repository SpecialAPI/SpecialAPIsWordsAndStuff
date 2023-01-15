function effects(timer)
	doeffect(timer,nil,"win","unlock",1,2,20,{2,4})
	doeffect(timer,nil,"best","unlock",6,30,2,{2,4})
	doeffect(timer,nil,"tele","glow",1,5,20,{1,4})
	doeffect(timer,nil,"hot","hot",1,80,10,{0,1})
	doeffect(timer,nil,"bonus","bonus",1,2,20,{4,1})
	doeffect(timer,nil,"wonder","wonder",1,10,5,{0,3})
	doeffect(timer,nil,"sad","tear",1,2,20,{3,2})
	doeffect(timer,nil,"sleep","sleep",1,2,60,{3,2})
	doeffect(timer,nil,"broken","error",3,10,8,{2,2})
	doeffect(timer,nil,"pet","pet",1,0,50,{3,1},"nojitter")
	
	doeffect(timer,nil,"power","electricity",2,5,8,{2,4})
	doeffect(timer,nil,"power2","electricity",2,5,8,{5,4})
	doeffect(timer,nil,"power3","electricity",2,5,8,{4,4})
	--doeffect(timer,"play",nil,"music",1,2,30,{0,3})
	
	local rnd = math.random(2,4)
	doeffect(timer,nil,"end","unlock",1,1,10,{1,rnd},"inwards")
	--rnd = math.random(0,2)
	--doeffect(timer,"melt","unlock",1,1,10,{4,rnd},"inwards")
	
	do_mod_hook("effect_always")
end

function effects_decors()
	MF_cleandecors()
	--adddecor("best","glasses")
end

function shorteffectblock()
	doshorteffect(nil,"party","confetti",6,{-20,20},{-25,-10},{{1,4},{2,2},{2,4},{4,1},{5,3}})
	
	do_mod_hook("effect_once")
end
	
function doeffect(timer,word2_,word3,particle,count,chance,timing,colour,specialrule_,layer_)
	local zoom = generaldata2.values[ZOOM]
	
	local specialrule = specialrule_ or ""
	local layer = layer_ or 1
	local word2 = word2_ or "is"
	
	if (timer % timing == 0) then
		local this = findfeature(nil,word2,word3)
		
		local c1 = colour[1]
		local c2 = colour[2]
		
		if (this ~= nil) then
			for k,v in ipairs(this) do
				if (v[1] ~= "empty") and (v[1] ~= "all") and (v[1] ~= "level") then
					local these = findall(v,true)
					
					if (#these > 0) then
						for a,b in ipairs(these) do
							local unit = mmf.newObject(b)
							local x,y = unit.values[XPOS],unit.values[YPOS]
							if(word3 ~= "broken") or (hasfeature(getname(unit), "is", "fixed", b, x, y, {}, true) == nil) then
							
								if (word3 == "broken") then
									if (unit.strings[UNITTYPE] == "text") then
										c1,c2 = getcolour(b,"active")
									else
										c1,c2 = getcolour(b)
									end
								end
								
								if unit.visible then
									for i=1,count do
										local partid = 0
										
										if (chance > 1) then
											if (math.random(chance) == 1) then
												if (specialrule ~= "nojitter") then
													partid = MF_particle(particle,x,y,c1,c2,layer)
												else
													partid = MF_staticparticle(particle,x,y,c1,c2,layer)
												end
											end
										else
											if (specialrule ~= "nojitter") then
												partid = MF_particle(particle,x,y,c1,c2,layer)
											else
												partid = MF_staticparticle(particle,x,y,c1,c2,layer)
											end
										end
										
										if (partid ~= nil) and (specialrule == "inwards") and (partid ~= 0) then
											local part = mmf.newObject(partid)
											
											part.values[ONLINE] = 2
											local midx = math.floor(roomsizex * 0.5)
											local midy = math.floor(roomsizey * 0.5)
											local mx = x + 0.5 - midx
											local my = y + 0.5 - midy
											
											local dir = 0 - math.atan2(my, mx)
											local dist = math.sqrt(my ^ 2 + mx ^ 2)
											local roomrad = math.rad(generaldata2.values[ROOMROTATION])
											
											mx = Xoffset + (midx + math.cos(dir + roomrad) * dist * zoom) * tilesize * spritedata.values[TILEMULT]
											my = Yoffset + (midy - math.sin(dir + roomrad) * dist * zoom) * tilesize * spritedata.values[TILEMULT]
											
											part.x = mx + math.random(0 - tilesize * 1.5 * zoom,tilesize * 1.5 * zoom)
											part.y = my + math.random(0 - tilesize * 1.5 * zoom,tilesize * 1.5 * zoom)
											part.values[XPOS] = part.x
											part.values[YPOS] = part.y
											
											dir = math.pi - math.atan2(part.y - my, part.x - mx)
											dist = math.sqrt((part.y - my) ^ 2 + (part.x - mx) ^ 2)
											part.values[XVEL] = math.cos(dir) * (dist * 0.2)
											part.values[YVEL] = 0 - math.sin(dir) * (dist * 0.2)
										end
									end
								end
							end
						end
					end
				elseif ((v[1] == "empty") or (v[1] == "level")) then
					local ignorebroken = false
					if (word3 == "broken") then
						ignorebroken = true
					end
					
					if (v[1] ~= "level") or ((v[1] == "level") and testcond(v[2],1)) then
						for i=1,roomsizex-2 do
							for j=1,roomsizey-2 do
								local tileid = i + j * roomsizex
								
								if (unitmap[tileid] == nil) or ((unitmap[tileid] ~= nil) and (#unitmap[tileid] == 0)) then
									if (v[1] ~= "empty") or ((v[1] == "empty") and testcond(v[2],2,i,j,nil,nil,nil,ignorebroken)) then
										local partid = 0
										
										if (chance > 1) then
											if (math.random(chance) == 1) then
												if (specialrule ~= "nojitter") then
													partid = MF_particle(particle,i,j,c1,c2,layer)
												else
													partid = MF_staticparticle(particle,i,j,c1,c2,layer)
												end
											end
										else
											if (specialrule ~= "nojitter") then
												partid = MF_particle(particle,i,j,c1,c2,layer)
											else
												partid = MF_staticparticle(particle,i,j,c1,c2,layer)
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
	end
end

function domaprotation()
	if (featureindex["level"] ~= nil) then
		for i,v in ipairs(featureindex["level"]) do
			local rule = v[1]
			local conds = v[2]
			
			if testcond(conds,1) then
				if (rule[1] == "level") and (rule[2] == "is") then
					if (rule[3] == "right") and (mapdir ~= 0) then
						updateundo = true
						addundo({"maprotation",maprotation,90,0})
						addundo({"mapdir",mapdir,0})
						maprotation = 90
						mapdir = 0
						MF_levelrotation(maprotation)
					elseif (rule[3] == "up") and (mapdir ~= 1) then
						updateundo = true
						addundo({"maprotation",maprotation,180,1})
						addundo({"mapdir",mapdir,1})
						maprotation = 180
						mapdir = 1
						MF_levelrotation(maprotation)
					elseif (rule[3] == "left") and (mapdir ~= 2) then
						updateundo = true
						addundo({"maprotation",maprotation,270,2})
						addundo({"mapdir",mapdir,2})
						maprotation = 270
						mapdir = 2
						MF_levelrotation(maprotation)
					elseif (rule[3] == "down") and (mapdir ~= 3) then
						updateundo = true
						addundo({"maprotation",maprotation,0,3})
						addundo({"mapdir",mapdir,3})
						maprotation = 0
						mapdir = 3
						MF_levelrotation(maprotation)
					end
				end
			end
		end
	end
end

function levelparticles(name)
	if (particletypes[name] ~= nil) then
		local data = particletypes[name]
		
		if (data.customfunc == nil) then
			local amount = data.amount
			
			for i=1,amount do
				local unitid = MF_specialcreate("Level_particle")
				local unit = mmf.newObject(unitid)
				
				unit.values[ONLINE] = 1
				unit.x = Xoffset + math.random(0, screenw - 1)
				unit.y = Yoffset + math.random(0, screenh - 1)
				unit.layer = 1
				
				unit.values[XPOS] = unit.x
				unit.values[YPOS] = unit.y
				
				if (data.animation ~= nil) then
					if (type(data.animation) == "number") then
						unit.direction = data.animation
					elseif (type(data.animation) == "table") then
						local chunk = amount / #data.animation
						local which = math.floor((i - 1) / chunk) + 1
						unit.direction = data.animation[which]
					end
				end
				
				if (data.x_velocity ~= nil) then
					unit.values[XVEL] = data.x_velocity
				end
				
				if (data.y_velocity ~= nil) then
					unit.values[YVEL] = data.y_velocity
				end
				
				if (data.colour ~= nil) then
					local c = data.colour
					MF_setcolour(unitid,c[1],c[2])
					
					unit.strings[COLOUR] = tostring(c[1]) .. "," .. tostring(c[2])
				end
				
				unit.values[DIR] = math.random(0,259)
				unit.strings[1] = name
				
				if (data.extra ~= nil) then
					data.extra(unitid)
				end
			end
		else
			data.customfunc()
		end
	else
		print("No particles with name " .. name)
	end
end

function dotransition()
	local sw = screenw * 0.5
	local sh = screenh * 0.5
	
	local mult = 1.5
	
	local initialdistx = sw * mult
	local initialdisty = sh * mult
	
	local xpos = sw
	local ypos = sh
	
	local count = 36
	local increment = 360 / count
	
	for i=0,count-1 do
		local blobid = MF_specialcreate("Transition_blob")
		local blob = mmf.newObject(blobid)
		
		blob.values[ONLINE] = 1
		blob.values[XPOS] = xpos + math.cos(math.rad(increment) * i) * initialdistx
		blob.values[YPOS] = ypos - math.sin(math.rad(increment) * i) * initialdisty
		blob.flags[10] = true
		MF_setcolour(blobid,1,0)
		
		local x,y = blob.values[XPOS],blob.values[YPOS]
		
		local steps = 50
		if (generaldata.values[FASTTRANSITION] == 1) then
			steps = 22.5
		end
		
		local spd = math.sqrt((y - sh) ^ 2 + (x - sw) ^ 2) / steps * 5 + math.random(-9,7)
		
		local dir = 0 - math.atan2(ypos - y,xpos - x)
		blob.values[XVEL] = math.cos(dir) * spd
		blob.values[YVEL] = 0 - math.sin(dir) * spd
		blob.layer = 2
		blob.x = -256
		blob.y = -256
	end
	
	count = 12
	increment = 360 / count
	mult = 1.8
	
	initialdistx = sw * mult
	initialdisty = sh * mult
	
	for i=1,count do
		local blobid = MF_specialcreate("Transition_bigblob")
		local blob = mmf.newObject(blobid)
		
		blob.values[ONLINE] = 1
		blob.values[XPOS] = xpos + math.cos(math.rad(increment) * i) * initialdistx
		blob.values[YPOS] = ypos - math.sin(math.rad(increment) * i) * initialdisty
		blob.flags[10] = true
		MF_setcolour(blobid,1,0)
		
		local x,y = blob.values[XPOS],blob.values[YPOS]
		
		local steps = 72
		if (generaldata.values[FASTTRANSITION] == 1) then
			steps = 36
		end
		
		local spd = math.sqrt((y - sh) ^ 2 + (x - sw) ^ 2) / steps * 5
		
		local dir = 0 - math.atan2(ypos - y,xpos - x)
		blob.values[XVEL] = math.cos(dir) * spd * 1.01
		blob.values[YVEL] = 0 - math.sin(dir) * spd
		blob.layer = 2
		blob.x = -256
		blob.y = -256
		blob.scale = 1.15
	end
	
	count = 4
	local locations = {{-1,-1},{1,-1},{1,1},{-1,1}}
	mult = 1.8
	
	for i=1,count do
		local blobid = MF_specialcreate("Transition_bigblob")
		local blob = mmf.newObject(blobid)
		
		local l = locations[i]
		local lx,ly = l[1],l[2]
		
		blob.values[ONLINE] = 1
		blob.values[XPOS] = sw + lx * sw * mult
		blob.values[YPOS] = sh + ly * sh * mult
		blob.flags[10] = true
		MF_setcolour(blobid,1,0)
		
		local x,y = blob.values[XPOS],blob.values[YPOS]
		
		local steps = 72
		if (generaldata.values[FASTTRANSITION] == 1) then
			steps = 36
		end
		
		local spd = math.sqrt((y - sh) ^ 2 + (x - sw) ^ 2) / steps * 5
		
		local dir = 0 - math.atan2(ypos - y,xpos - x)
		blob.values[XVEL] = math.cos(dir) * spd * 1.01
		blob.values[YVEL] = 0 - math.sin(dir) * spd
		blob.layer = 2
		blob.x = -256
		blob.y = -256
		blob.scale = 1.15
	end
end

function particles(name,x,y,count,colour,layer_,zoom_)
	local layer = layer_ or 1
	local zoom = zoom_ or 1
	
	MF_particles(name,x,y,count,colour[1],colour[2],layer,zoom)
end

function doparticles(name,x,y,count,c1,c2,layer_,zoom_)
	local layer = layer_ or 1
	local zoom = zoom_ or 1
	
	local ax,ay = 0,0
	local rx,ry = 0,0
	local mult = 0
	
	if (zoom == 1) then
		local mtx = roomsizex * 0.5
		local mty = roomsizey * 0.5
		
		local mx = mtx * tilesize * spritedata.values[TILEMULT]
		local my = mty * tilesize * spritedata.values[TILEMULT]
		
		local dx = x - (mtx - 0.5)
		local dy = y - (mty - 0.5)
		
		local dir = 0 - math.atan2(dy, dx)
		local dist = math.sqrt(dy ^ 2 + dx ^ 2)
		
		local roomrotrad = math.rad(generaldata2.values[ROOMROTATION])
		mult = tilesize * spritedata.values[TILEMULT] * generaldata2.values[ZOOM]
		
		ax = Xoffset + mx + (math.cos(dir + roomrotrad) * dist) * mult
		ay = Yoffset + my - (math.sin(dir + roomrotrad) * dist) * mult
	elseif (zoom == 0) then
		ax = Xoffset + x * tilesize + tilesize * 0.5
		ay = Yoffset + y * tilesize + tilesize * 0.5
		
		mult = tilesize
	end
		
	for i=1,count do
		local unitid = MF_effectcreate("effect_" .. name)
		local unit = mmf.newObject(unitid)
		
		rx = math.random(0 - mult * 0.5,mult * 0.5)
		ry = math.random(0 - mult * 0.5,mult * 0.5)
		
		unit.x = ax + rx
		unit.y = ay + ry
		
		MF_setcolour(unitid, c1, c2)
		
		unit.values[XPOS] = -20
		unit.values[YPOS] = -20
		unit.values[24] = ax
		unit.values[25] = ay
		
		unit.layer = layer
		
		if (zoom == 1) then
			unit.scaleX = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]
			unit.scaleY = spritedata.values[TILEMULT] * generaldata2.values[ZOOM]
		end
	end
end

function adddecor(rule3,decor)
	local targets = findallfeature(nil,"is",rule3,true)
	
	for i,unitid in ipairs(targets) do
		local unit = mmf.newObject(unitid)
		
		if (unit.strings[DECOR] ~= decor) then
			local dunitid = 0
			if (unit.strings[DECOR] == "") then
				dunitid = MF_specialcreate("Level_decor")
			else
				dunitid = MF_finddecor(unitid)
			end
			
			local dunit = mmf.newObject(dunitid)
			
			dunit.values[DECOR_OWNER] = unitid
			dunit.values[DECOR_DIR] = unit.values[DIR]
			dunit.values[DECOR_SET] = 1
			
			local unitname = unit.strings[UNITNAME]
			
			unit.strings[DECOR] = decor
			
			if (decor_offsets[unitname] ~= nil) then
				local data = decor_offsets[unitname]
				
				MF_alert(#data)
				
				local r = {}
				
				if (#data == 4) then
					r = data[1]
					dunit.values[DECOR_OXR] = r[1]
					dunit.values[DECOR_OYR] = r[2]
				else
					r = decor_offsets[unitname]
					dunit.values[DECOR_OXR] = r[1]
					dunit.values[DECOR_OYR] = r[2]
				end
				
				if (#data == 4) then
					r = data[2]
					dunit.values[DECOR_OXU] = r[1]
					dunit.values[DECOR_OYU] = r[2]
				else
					r = decor_offsets[unitname]
					dunit.values[DECOR_OXU] = 0
					dunit.values[DECOR_OYU] = r[2]
				end
				
				if (#data == 4) then
					r = data[3]
					dunit.values[DECOR_OXL] = r[1]
					dunit.values[DECOR_OYL] = r[2]
				else
					r = decor_offsets[unitname]
					dunit.values[DECOR_OXL] = 0 - r[1]
					dunit.values[DECOR_OYL] = r[2]
				end
				
				if (#data == 4) then
					r = data[4]
					dunit.values[DECOR_OXD] = r[1]
					dunit.values[DECOR_OYD] = r[2]
				else
					r = decor_offsets[unitname]
					dunit.values[DECOR_OXD] = 0
					dunit.values[DECOR_OYD] = r[2]
				end
			end
		end
	end
end

function unitcoloureffect()
	if (generaldata5.values[DISABLEBLINKING] == 0) then
		if (generaldata5.values[AUTO_ON] == 0) or (generaldata5.values[AUTO_DELAY] > 10) then
			for i,unit in pairs(units) do
				if (unit.colours ~= nil) and (#unit.colours > 1) then
					local curr = (unit.currcolour % #unit.colours) + 1
					local c = unit.colours[curr]
					unit.currcolour = (unit.currcolour + 1) % #unit.colours
					
					unit.colour = {c[1],c[2]}
					MF_setcolour(unit.fixed,c[1],c[2])
				end
			end
		end
		
		if (generaldata5.values[AUTO_ON] == 0) then
			if (leveldata.colours ~= nil) and (#leveldata.colours > 1) then
				local curr = (leveldata.currcolour % #leveldata.colours) + 1
				local c = leveldata.colours[curr]
				leveldata.currcolour = (leveldata.currcolour + 1) % #leveldata.colours
				
				if (c[1] == 0) and (c[2] == 4) then
					MF_backcolour(c[1], c[2])
				else
					MF_backcolour_dim(c[1], c[2])
				end
			end
		end
	end
end

function doshorteffect(word2_,word3,particle,count,xvel_,yvel_,colours,layer_)
	local xvel = 0
	local yvel = 0
	local c1,c2 = 0,3
	local layer = layer_ or 1
	
	local xmin,xmax = 0,0
	local ymin,ymax = 0,0
	
	if (xvel_ ~= nil) then
		if (type(xvel_) == "table") then
			xmin = xvel_[1]
			xmax = xvel_[2]
		else
			xvel = tonumber(xvel_) or 0
		end
	end
	
	if (yvel_ ~= nil) then
		if (type(yvel_) == "table") then
			ymin = yvel_[1]
			ymax = yvel_[2]
		else
			yvel = tonumber(yvel_) or 0
		end
	end
	
	local cnum = 0
	
	if (colours ~= nil) then
		local c = colours[1]
		
		if (type(c) == "table") then
			cnum = #colours
		else
			c1 = tonumber(colours[1]) or 0
			c2 = tonumber(colours[2]) or 3
		end
	end
	
	local word2 = word2_ or "is"
	local this = findfeature(nil,word2,word3)
	
	if (this ~= nil) then
		for k,v in ipairs(this) do
			if (v[1] ~= "empty") and (v[1] ~= "all") and (v[1] ~= "level") then
				local these = findall(v,true)
				
				for a,b in ipairs(these) do
					local unit = mmf.newObject(b)
					local x,y = unit.values[XPOS],unit.values[YPOS]
					
					if unit.visible then
						for i=1,count do
							if (cnum > 0) then
								local rnd = math.random(1,cnum)
								local col = colours[rnd]
								c1 = col[1]
								c2 = col[2]
							end
							
							local partid = MF_particle(particle,x,y,c1,c2,layer)
							
							if (partid ~= nil) and (partid ~= 0) then
								local part = mmf.newObject(partid)
								part.values[ONLINE] = 1
								
								part.x = unit.x
								part.y = unit.y
								
								part.values[XPOS] = unit.x
								part.values[YPOS] = unit.y
								
								if (xmin ~= 0) or (xmax ~= 0) then
									xvel = math.random(xmin,xmax)
								end
								
								if (ymin ~= 0) or (ymax ~= 0) then
									yvel = math.random(ymin,ymax)
								end
								
								part.values[XVEL] = xvel
								part.values[YVEL] = yvel
							end
						end
					end
				end
			elseif ((v[1] == "empty") or (v[1] == "level")) then
				if (v[1] ~= "level") or ((v[1] == "level") and testcond(v[2],1)) then
					for i=1,roomsizex-2 do
						for j=1,roomsizey-2 do
							local tileid = i + j * roomsizex
							
							if (cnum > 0) then
								local rnd = math.random(1,cnum)
								local col = colours[rnd]
								c1 = col[1]
								c2 = col[2]
							end
							
							if (unitmap[tileid] == nil) or ((unitmap[tileid] ~= nil) and (#unitmap[tileid] == 0)) then
								if (v[1] ~= "empty") or ((v[1] == "empty") and testcond(v[2],2,i,j,nil,nil,nil,ignorebroken)) then
									local partid = MF_particle(particle,i,j,c1,c2,layer)
									
									if (partid ~= nil) and (partid ~= 0) then
										local part = mmf.newObject(partid)
										part.values[ONLINE] = 1
										
										part.x = Xoffset + (i-1) * tilesize * spritedata.values[TILEMULT] + tilesize * 1.5 * spritedata.values[TILEMULT]
										part.y = Yoffset + (j-1) * tilesize * spritedata.values[TILEMULT] + tilesize * 1.5 * spritedata.values[TILEMULT]
										
										part.values[XPOS] = part.x
										part.values[YPOS] = part.y
										
										if (xmin ~= 0) or (xmax ~= 0) then
											xvel = math.random(xmin,xmax)
										end
										
										if (ymin ~= 0) or (ymax ~= 0) then
											yvel = math.random(ymin,ymax)
										end
										
										part.values[XVEL] = xvel
										part.values[YVEL] = yvel
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