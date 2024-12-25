--lanes = require "lanes".configure()

local function sleep(n)
	local clock = os.clock
	t0 = clock()
	while (clock() - t0) <= n do end
end

--Positions ... "Nodes"
local function position(pos)
	x = 10*math.floor(pos.o.x + 0.5)
	y = 10*math.floor(pos.o.y + 0.5)
	return {x,y}
end

--Heuristic values!
local function dist (x1, y1, x2, y2)
	return math.sqrt(math.pow (x2 - x1, 2) + math.pow (y2 - y1, 2))
end

local function dist_between (pos1, pos2)
	return dist(pos1[1], pos1[2], pos2[1], pos2[2])
end

local function heuristic_cost_estimate(pos1, pos2)
	return dist(pos1[1], pos1[2], pos2[1], pos2[2])
end

local function lowest_f_score(lst, f_score)
	local lowest, best_pos = (1/0), nil
	for i=1,#lst do
		local score = f_score[lst[i]]
		if score < lowest then
			lowest, best_pos = score, lst[i]
		end
	end
	
	--print(best_pos[1] .. ":" .. best_pos[2])
	return {best_pos[1], best_pos[2]}
end

local function neighbour_positions(pos)
	local neighbours = {}
	for i=-1,1 do
		for u=-1,1 do
			if (i==0) and (u==0) then
			else
				x = (pos[1] + i)
				y = (pos[2] + u)
				table.insert(neighbours, {x,y})
			end
		end
	end
	--for i=1,#neighbours do
	--	print(neighbours[i][1] .. ":" .. neighbours[i][2])
	--end
	return neighbours
end

local function remove_pos(lst, pos)
	for i=1,#lst do
		if (lst[i][1] == pos[1]) and (lst[i][2] == pos[2]) then
			table.remove(lst, i)
			break
		end
	end
end

local function not_in(lst, pos)
	for i=1, #lst do
		if (pos[1] == lst[i][1]) and (pos[2] == lst[i][2]) then
			return false
		end
	end
	return true
end

local function table_get_value(lst, pos)
	target_pos = nil
	for k,v in pairs(lst) do
		if k[1] == pos[1] and k[2] == pos[2] then
			target_pos = k
		end
	end
	return lst[target_pos]
end

local function path_unwinder(lst, pos)
	for k,v in pairs(lst) do
		if k[1] == pos[1] and k[2] == pos[2] then
			return v
		end
	end
	return nil
end

local function unwind_path(flat_path, came_from, pos)
	temp_pos = path_unwinder(came_from, pos)
	if temp_pos then
		table.insert(flat_path, temp_pos)
		return unwind_path(flat_path, came_from, temp_pos)
	else
		return flat_path
	end
end

local function get_objects_positions()
	objectLst = {}
	for prop in game.propInstI() do
		if game.prop_instance_is_valid(prop) then
			openLst = {}
			closedLst = {}
			game.prop_instance_get_position(1, prop)
			pos = position(game.preg[1])
			
			table.insert(openLst, pos)
			
			while #openLst > 0 do
				cur_pos = openLst[1]
				
				remove_pos(openLst, cur_pos)
				table.insert(closedLst, cur_pos)
				
				neighbours = neighbour_positions(cur_pos)
				for i=1,#neighbours do
					temp_pos = game.preg[1]
					temp_pos.o.x, temp_pos.o.y, temp_pos.o.z = neighbours[i][1], neighbours[i][2], (temp_pos.o.z - 10000)
					
					temp_pos:rotate({x=0})
					
					game.preg[1] = temp_pos
					
					ray = game.cast_ray(0, 2, 1, 100000)
					if not_in(closedLst, position(game.preg[2])) and ray == true then
						if not_in(openLst, position(game.preg[2])) then
							table.insert(openLst, position(game.preg[2]))
						end
					end
				end
			end
			for i=1,#closedLst do
				if not_in(objectLst, closedLst[i]) then
					table.insert(objectLst, closedLst[i])
				end
			end
		end
	end
	return objectLst
end

local function astar(agent, target, blocked_positions)
	g = dofile("get_agent_data.lua")
	print(agent)
	--start&goal positions
	start_pos, goal_pos = position(get_agent_position(agent)), position(get_agent_position(target))
	print(start_pos[1] .. ":" .. start_pos[2])
	print(goal_pos[1] .. ":" .. goal_pos[2])
	
	--THE lists
	openLst, closedLst, came_from = {}, {}, {}
	
	for i=1,#blocked_positions do
		table.insert(closedLst, blocked_positions[i])
	end
	
	table.insert(openLst, start_pos)
	
	--g_score, f_score
	g_score, f_score = {}, {}
	g_score[start_pos] = 0
	f_score[start_pos] = g_score[start_pos] + heuristic_cost_estimate(start_pos, goal_pos)
	
	while #openLst > 0 do
		--get the fastest position to the target
		cur_pos = lowest_f_score(openLst, f_score)
		print("open lst: " .. #openLst .. ", closed lst: " .. #closedLst)
		if (cur_pos[1] == goal_pos[1]) and (cur_pos[2] == goal_pos[2]) then
			path = unwind_path({}, came_from, goal_pos)
			return_path, y = {}, 1
			for i=#path,1,-1 do
				return_path[y] = path[i]
				y = y + 1
			end
			--for i=1,#path,10 do
			--	print(path[i][1] .. " : " .. path[i][2])
			--end
			return return_path
		end
		
		--Don't re-check a checked position...
		remove_pos(openLst, cur_pos)
		table.insert(closedLst, cur_pos)
		
		neighbours = neighbour_positions(cur_pos)
		for i=1, #neighbours do
			if not_in(closedLst, neighbours[i]) then
				tentative_g = table_get_value(g_score, cur_pos) + dist_between(cur_pos, neighbours[i])
				if not_in(openLst, neighbours[i]) or tentative_g < table_get_value(g_score, neighbours[i]) then
					-- add the chosen position to the lists
					came_from[neighbours[i]] = cur_pos
					g_score[neighbours[i]] = tentative_g
					f_score[neighbours[i]] = g_score[neighbours[i]] + heuristic_cost_estimate(neighbours[i], goal_pos)
					if not_in(openLst, neighbours[i]) then
						table.insert(openLst, neighbours[i])
					end
				end
			end
		end
	end
end

local function get_agent_targets()
	local target_lst = {}
	for agent in game.agentsI() do
		if is_alive_human_agent(agent) then
			target = get_look_target(agent)
			if target > 0 then
				table.insert(target_lst, {agent, target})
			end
		end
	end
	return target_lst
end

local function run_astar(agent)
	dofile("get_agent_data.lua")
	dofile("targeting.lua")
	gettarget()
	blocked_positions = get_objects_positions() -- only get the blocked object's positions once
	co_list = {} -- all coroutines to be stored here
	sleep(3) -- make sure all agents has time to compute enough to get a target...
	targets = get_agent_targets() -- all agents and their current targets...
	--Initiate all the coroutines for all the targets....
	print("here")
	for i=1,#targets do
		travel_guide(targets[i][1], astar(targets[i][1], targets[i][2], blocked_positions))
		print("Called script")
	end
	print("done")
end

function pathingalgorithm()
	--f()
end

--f = lanes.gen("*", run_astar)