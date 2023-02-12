function findfeature(rule1,rule2,rule3)
	local options = {}
	local result = {}
	local rule = ""
	
	if (rule1 ~= nil) then
		rule = rule1 .. " "
	end
	
	if (rule2 ~= nil) then
		rule = rule .. rule2 .. " "
	end
	
	if (rule3 ~= nil) then
		rule = rule .. rule3
	end
	
	if (featureindex[rule1] ~= nil) then
		for i,rules in ipairs(featureindex[rule1]) do
			local rule = rules[1]
			local conds = rules[2]
			
			if (conds[1] ~= "never") then
				if (rule[1] == rule1) and ((rule[2] == rule2) or ((rule2 == "is") and (rule[2] == "feel"))) then
					local baserule = {rule[1],rule[2],rule[3]}
					table.insert(options, {baserule,conds})
				end
			end
		end
	end
	
	if (featureindex[rule3] ~= nil) and (featureindex[rule1] == nil) then
		for i,rules in ipairs(featureindex[rule3]) do
			local rule = rules[1]
			local conds = rules[2]
			
			if (conds[1] ~= "never") then
				if (rule[3] == rule3) and ((rule[2] == rule2) or ((rule2 == "is") and (rule[2] == "feel"))) then
					local baserule = {rule[1],rule[2],rule[3]}
					table.insert(options, {baserule,conds})
				end
			end
		end
	end
	
	if (rule1 == nil) and (rule3 == nil) and (rule2 ~= nil) then
		if (featureindex[rule2] ~= nil) then 
			for i,rules in ipairs(featureindex[rule2]) do
				local usable = false
				local rule = rules[1]
				local conds = rules[2]

				if (conds[1] ~= "never") then
					for a,mat in pairs(objectlist) do
						if (a == rule[3]) then
							usable = true
						end
					end
					
					for a,mat in ipairs(customobjects) do
						if (mat == rule[3]) then
							usable = true
						end
					end
					
					if (rule[2] == rule2) and usable then
						local baserule = {rule[1],rule[2],rule[3]}
						table.insert(options, {baserule,conds})
					end
				end
			end
		end
		if(rule2 == "is") and (featureindex["feel"] ~= nil) then
			for i,rules in ipairs(featureindex["feel"]) do
				local usable = false
				local rule = rules[1]
				local conds = rules[2]

				if (conds[1] ~= "never") then
					for a,mat in pairs(objectlist) do
						if (a == rule[3]) then
							usable = true
						end
					end
					
					for a,mat in ipairs(customobjects) do
						if (mat == rule[3]) then
							usable = true
						end
					end
					
					if (rule[2] == "feel") and usable then
						local baserule = {rule[1],rule[2],rule[3]}
						table.insert(options, {baserule,conds})
					end
				end
			end
		end
	end
	
	for i,rules in ipairs(options) do
		local words = {}
		local baserule = rules[1]
		
		for a,b in ipairs(baserule) do
			table.insert(words, b)
		end
		
		if (#words >= 3) then
			local one = words[3]
			local two = words[2] .. " " .. words[3]
			local three = words[1] .. " " .. words[2] .. " " .. words[3]
			if(rule2 == "is") and (words[2] == "feel") then
				two = "is " .. words[3]
				three = words[1] .. " is " .. words[3]
			end
			if (one == rule) or (two == rule) or (three == rule) or (((words[2] == rule2) or ((rule2 == "is") and (words[2] == "feel"))) and (rule1 == nil) and (rule3 == nil)) then
				table.insert(result, {baserule[1], rules[2]})
			end
		end
	end
	
	if (#result > 0) then
		return result
	else
		return nil
	end
end

function findfeatureat(rule1,rule2,rule3,x,y,blockers_,checkedconds)
	local result = {}
	local blockers = blockers_ or {}
	local targets = findfeature(rule1,rule2,rule3)
	
	if (targets ~= nil) then
		local tileid = x + y * roomsizex
		
		if (unitmap[tileid] ~= nil) and (#unitmap[tileid] > 0) then
			for a,unitid in ipairs(unitmap[tileid]) do
				local unit = mmf.newObject(unitid)
				local name = getname(unit)
				
				for i,v in ipairs(targets) do
					if (name == v[1]) then
						local valid = true
						
						for c,d in ipairs(blockers) do
							local testing = hasfeature(name,"is",d,unitid,x,y,checkedconds)
							
							if (testing ~= nil) then
								valid = false
								break
							end
						end
						
						if valid then
							local conds = v[2]
							if testcond(conds,unit.fixed,nil,nil,nil,nil,checkedconds) then
								table.insert(result, unit.fixed)
							end
						end
					end
				end
			end
		end
	end
	
	if (#result > 0) then
		return result
	else
		return nil
	end
end

function hasfeature(rule1,rule2,rule3,unitid,x,y,checkedconds,ignorebroken_)
	local ignorebroken = false
	if (ignorebroken_ ~= nil) then
		ignorebroken = ignorebroken_
	end
	
	if (rule1 ~= nil) and (rule2 ~= nil) and (rule3 ~= nil) then
		if (featureindex[rule1] ~= nil) then
			for i,rules in ipairs(featureindex[rule1]) do
				local rule = rules[1]
				local conds = rules[2]
				
				if (conds[1] ~= "never") then
					if (rule[1] == rule1) and ((rule[2] == rule2) or ((rule2 == "is") and (rule[2] == "feel"))) and (rule[3] == rule3) then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end
		
		if (string.sub(rule1,1,5) == "text_") and (featureindex["text"] ~= nil) then
			for i,rules in ipairs(featureindex["text"]) do
				local rule = rules[1]
				local conds = rules[2]
				
				if (conds[1] ~= "never") then
					if (rule[1] == "text") and ((rule[2] == rule2) or ((rule2 == "is") and (rule[2] == "feel"))) and (rule[3] == rule3) then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end
	end
	
	if (rule3 ~= nil) and (rule2 ~= nil) and (rule1 ~= nil) then
		if (featureindex[rule3] ~= nil) then
			for i,rules in ipairs(featureindex[rule3]) do
				local rule = rules[1]
				local conds = rules[2]
				
				if (conds[1] ~= "never") then
					if (rule[1] == rule1) and ((rule[2] == rule2) or ((rule2 == "is") and (rule[2] == "feel"))) and (rule[3] == rule3) then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end
		
		if (string.sub(rule3,1,5) == "text_") and (featureindex["text"] ~= nil) then
			for i,rules in ipairs(featureindex["text"]) do
				local rule = rules[1]
				local conds = rules[2]
				
				if (conds[1] ~= "never") then
					if (rule[1] == rule1) and ((rule[2] == rule2) or ((rule2 == "is") and (rule[2] == "feel"))) and (rule[3] == "text") then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end
	end
	
	if ((featureindex[rule2] ~= nil) or ((rule2 == "is") and (featureindex["being"] ~= nil))) and (rule1 ~= nil) and (rule3 == nil) then
		local usable = false
		
		if (featureindex[rule1] ~= nil) then
			for i,rules in ipairs(featureindex[rule1]) do
				local rule = rules[1]
				local conds = rules[2]
				
				if (conds[1] ~= "never") then
					for a,mat in pairs(objectlist) do
						if (a == rule[1]) then
							usable = true
							break
						end
					end
					
					if (rule[1] == rule1) and ((rule[2] == rule2) or ((rule2 == "is") and (rule[2] == "feel"))) and usable then
						if testcond(conds,unitid,x,y,nil,nil,checkedconds,ignorebroken) then
							return true
						end
					end
				end
			end
		end
	end
	
	return nil
end

function findallfeature(rule1,rule2,rule3,ignore_empty_,checkedconds)
	local group = findfeature(rule1,rule2,rule3)
	local ignore_empty = ignore_empty_ or false
	
	local result = {}
	local empty = {}
	
	if (group ~= nil) then
		for i,v in ipairs(group) do
			if (v[1] ~= "empty") then
				local fgroupmembers = findall(v)
				
				for a,b in ipairs(fgroupmembers) do
					table.insert(result, b)
					table.insert(empty, {})
				end
			else
				if (ignore_empty == false) then
					local conds = v[2]
					local needstest = false
					local testbroken = false
					local valid = true
					
					if (#conds > 0) and ((conds[1] ~= nil) and (conds[1][1] ~= "never")) then
						needstest = true
					elseif (#conds > 0) and ((conds[1] ~= nil) and (conds[1][1] == "never")) then
						valid = false
					end
					
					if (featureindex["broken"] ~= nil) then
						testbroken = true
					end
					
					if valid then
						table.insert(result, 2)
						table.insert(empty, {})
						
						local thisempty = empty[#empty]
						
						for a=1,roomsizex-2 do
							for b=1,roomsizey-2 do
								local tileid = a + b * roomsizex
								
								if ((unitmap[tileid] == nil) or (#unitmap[tileid] == 0)) then
									valid = true
									if testbroken then
										local brok = isitbroken("empty",2,a,b)
										
										if (brok == 1) then
											valid = false
										end
									end
									
									if valid then
										if (needstest == false) then
											thisempty[tileid] = 0
										else
											if testcond(conds,2,a,b,nil,nil,checkedconds) then
												thisempty[tileid] = 0
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
	
	return result,empty
end

function getunitswitheffect(rule3,nolevels_,ignorethese_,checkedconds)
	local group = {}
	local result = {}
	local ignorethese = ignorethese_ or {}
	
	local nolevels = nolevels_ or false
	
	if (featureindex[rule3] ~= nil) then
		for i,v in ipairs(featureindex[rule3]) do
			local rule = v[1]
			local conds = v[2]
			
			if ((rule[2] == "is") or (rule[2] == "feel")) and (conds[1] ~= "never") and (findnoun(rule[1],nlist.brief) == false) then
				table.insert(group, {rule[1], conds})
			end
		end
		
		for i,v in ipairs(group) do
			if (v[1] ~= "empty") then
				local name = v[1]
				local fgroupmembers = unitlists[name]
				
				local valid = true
				
				if (name == "level") and nolevels then
					valid = false
				end
				
				if (fgroupmembers ~= nil) and valid then
					for a,b in ipairs(fgroupmembers) do
						if testcond(v[2],b,nil,nil,nil,nil,checkedconds) then
							local unit = mmf.newObject(b)
							
							if (unit.flags[DEAD] == false) then
								valid = true
								
								for c,d in ipairs(ignorethese) do
									if (d == b) then
										valid = false
										break
									end
								end
								
								if valid then
									table.insert(result, unit)
								end
							end
						end
					end
				end
			else
				--table.insert(result, {2, v[2]})
			end
		end
	end
	
	return result
end

function getunitswithverb(rule2,ignorethese_,checkedconds)
	local group = {}
	local result = {}
	local ignorethese = ignorethese_ or {}
	
	if (featureindex[rule2] ~= nil) then
		for i,v in ipairs(featureindex[rule2]) do
			local rule = v[1]
			local conds = v[2]
			
			local name = rule[1]
			
			if (rule[2] == rule2) and (conds[1] ~= "never") and (findnoun(rule[1],nlist.brief) == false) and (string.sub(rule[3], 1, 4) ~= "not ") then
				if (group[name] == nil) then
					group[name] = {}
				end
				
				table.insert(group[name], {rule[3], conds})
			end
		end
		
		for i,v in pairs(group) do
			if (string.sub(i, 1, 4) ~= "not ") then
				if (i ~= "empty") then
					local name = i
					local fgroupmembers = unitlists[name]
					
					if (fgroupmembers ~= nil) and (#fgroupmembers > 0) then
						for c,d in ipairs(v) do
							table.insert(result, {d[1],{},name})
							local thisthisresult = result[#result][2]
							
							for a,b in ipairs(fgroupmembers) do
								if testcond(d[2],b,nil,nil,nil,nil,checkedconds) then
									local unit = mmf.newObject(b)
									
									if (unit.flags[DEAD] == false) then
										local valid = true
										for e,f in ipairs(ignorethese) do
											if (f == b) then
												valid = false
												break
											end
										end
										
										if valid then
											table.insert(result[#result][2], unit)
										end
									end
								end
							end
						end
					end
				else
					local name = i
					local empties = findempty()
					
					if (#empties > 0) then
						for c,d in ipairs(v) do
							table.insert(result, {d[1],{},name})
							
							for e,f in ipairs(empties) do
								local x = math.floor(f % roomsizex)
								local y = math.floor(f / roomsizex)
								
								if testcond(d[2],2,x,y,nil,nil,checkedconds) then
									local valid = true
									for g,h in ipairs(ignorethese) do
										if (f == h) then
											valid = false
											break
										end
									end
									
									if valid then
										table.insert(result[#result][2], f)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	return result
end

function getunitverbtargets(rule2,checkedconds)
	local group = {}
	local result = {}
	
	if (featureindex[rule2] ~= nil) then
		for i,v in ipairs(featureindex[rule2]) do
			local rule = v[1]
			local conds = v[2]
			
			local name = rule[1]
			
			local isnot = string.sub(rule[3], 1, 4)
			
			if (rule[2] == rule2) and (conds[1] ~= "never") and (findnoun(rule[1],nlist.brief) == false) and (isnot ~= "not ") then
				if (group[name] == nil) then
					group[name] = {}
				end
				
				table.insert(group[name], {rule[3], conds})
			end
		end
		
		for name,v in pairs(group) do
			if (string.sub(name, 1, 4) ~= "not ") then
				if (name ~= "empty") then
					local fgroupmembers = unitlists[name] or {}
					local finalgroup = {}
					
					for a,b in ipairs(fgroupmembers) do
						local myverbs = {}
						
						for c,d in ipairs(v) do
							if testcond(d[2],b,nil,nil,nil,nil,checkedconds) then
								local unit = mmf.newObject(b)
								
								if (unit.flags[DEAD] == false) then
									table.insert(myverbs, d[1])
								end
							end
						end
						
						table.insert(finalgroup, {b, myverbs})
					end
					
					table.insert(result, {name, finalgroup})
				else
					local empties = findempty()
					local finalgroup = {}
					
					if (#empties > 0) then
						for a,b in ipairs(empties) do
							local x = math.floor(b % roomsizex)
							local y = math.floor(b / roomsizex)
							local myverbs = {}
							
							for c,d in ipairs(v) do
								if testcond(d[2],2,x,y,nil,nil,checkedconds) then
									table.insert(myverbs, d[1])
								end
							end
							
							table.insert(finalgroup, {b, myverbs})
						end
						
						table.insert(result, {name, finalgroup})
					end
				end
			end
		end
	end
	
	return result
end

function hasfeature_count(rule1,rule2,rule3,unitid,x,y,checkedconds)
	local result = 0
	
	--MF_alert(tostring(rule1) .. ", " .. tostring(rule2) .. ", " .. tostring(rule3) .. ", " .. tostring(featureindex[rule1]) .. ", " .. tostring(featureindex[rule3]))
	
	if (featureindex[rule1] ~= nil) and (featureindex[rule3] ~= nil) and (rule2 ~= nil) then
		if (#featureindex[rule1] < #featureindex[rule3]) then
			for i,v in ipairs(featureindex[rule1]) do
				local rule = v[1]
				local conds = v[2]
				
				if (rule[1] == rule1) and ((rule[2] == rule2) or ((rule2 == "is") and (rule[2] == "feel"))) and (rule[3] == rule3) then
					if testcond(conds,unitid,x,y,nil,nil,checkedconds) then
						result = result + 1
					end
				end
			end
		else
			for i,v in ipairs(featureindex[rule3]) do
				local rule = v[1]
				local conds = v[2]
				
				if (rule[1] == rule1) and ((rule[2] == rule2) or ((rule2 == "is") and (rule[2] == "feel"))) and (rule[3] == rule3) then
					if testcond(conds,unitid,x,y,nil,nil,checkedconds) then
						result = result + 1
					end
				end
			end
		end
	end
	
	return result
end