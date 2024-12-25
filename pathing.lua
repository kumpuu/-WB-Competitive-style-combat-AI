local function get_melee_range(agent)
	return (80 + get_weapon_length(get_wielded_item(agent, 0)))
end

local function in_melee_range(agent, target)
	local pos_agent, pos_target = get_agent_position(agent), get_agent_position(target)
	local agent_weapon = get_wielded_item(agent, 0)
	local distance = get_distance_between_positions(pos_agent, pos_target)
	
	while distance == 0 do
		distance = get_distance_between_positions(get_agent_position(agent), get_agent_position(target))
	end
	
	if distance < (80 + get_weapon_length(agent_weapon)) then
		return true
	else
		return false
	end
end

local function is_charging(team, class)
	if get_movement_order(team, class) == 2 then
		return true
	else
		return false
	end
end

local function melee_pathing(agent, target)
	local pos_agent, pos_target = get_agent_position(agent), get_agent_position(target)
	local dist = get_distance_between_positions(pos_agent, pos_target)
	local melee_range = get_melee_range(agent)
	
	local side_motion = math.random(0,1)
	local forward_motion = math.random(0,1)
	
	local move_x = 0
	local move_y = 0
	
	if dist < 25 then
		if side_motion == 0 then move_x = math.random(-100, -75) else move_x = math.random(75, 100) end
		if forward_motion == 1 then move_y = math.random(50, 75) else move_y = math.random(-50, -75) end
	elseif dist >= 25 and dist <= melee_range then
		if side_motion == 0 then move_x = math.random(-250, -150) else move_x = math.random(150, 250) end
		if forward_motion == 1 then move_y = math.random(25, 75) else move_y = math.random(-5, -20) end
	end
	
	game.preg[25] = pos_agent
	position_move_y(25, move_y)
	position_move_x(25, move_x)
	pos_agent = game.preg[25]
	
	set_destination(agent, pos_agent)
end

local function pather(agent, target)
	local team, class = get_team(agent), get_class(agent)
	local order = get_movement_order(team, class)
	local charging = is_charging(team, class)
	local cleared = false
	local clear_timer = os.clock()
	
	while agent > -1 and target > -1 do
		charging = is_charging(team, class)
		if (clear_timer + 0.75) < os.clock() and cleared then
			clear_timer = os.clock()
			cleared = false
		end
		
		if charging then
			if in_melee_range(agent, target) and not cleared then
				melee_pathing(agent, target)
			elseif not in_melee_range(agent, target) and not cleared then
				set_destination(agent, get_agent_position(target))
				force_rethink(agent)
				clear_timer = os.clock()
				cleared = true
			end
		elseif not charging and not cleared then
			clear_scripted_mode(agent)
			force_rethink(agent)
			clear_timer = os.clock()
			cleared = true
		end
		coroutine.yield()
	end
end

function path_controller()
	dofile("data/position_data.lua")
	dofile("data/classes_and_orders.lua")
	dofile("data/item_data.lua")
	dofile("data/agent_player_data.lua")
	dofile("data/mission_data.lua")
	
	print("You are using the pathing script!")
	
	local co_list = {}
	
	for agent in game.agentsI() do
		if is_alive_human_agent(agent) and agent_is_non_player(agent) and get_class(agent) == 0 then
			target = get_look_target(agent)
			co = coroutine.create(pather)
			coroutine.resume(co, agent, target)
			table.insert(co_list, {co, agent, target})
		end
	end
	
	local wait_until_timer_starts = os.clock()
	while (wait_until_timer_starts + 2) > os.clock() do end
	
	local prev_mission_timer = get_mission_timer()
	local stack = 0
	while #co_list > 0 do
		local temp_list = co_list
		for i=1, #co_list do
			local status = coroutine.status(co_list[i][1])
			local agent = co_list[i][2]
			local old_target, new_target = co_list[i][3], get_look_target(co_list[i][2])
			
			if status == 'dead' and is_alive_human_agent(agent) then
				co = coroutine.create(pather)
				coroutine.resume(co, agent, target)
				temp_list[i][1] = co
			elseif not is_alive_human_agent(agent) then
				table.remove(temp_list, i)
				break
			elseif status == 'suspended' then
				if old_target == new_target then
					coroutine.resume(co_list[i][1])
				else
					co = coroutine.create(pather)
					coroutine.resume(co, agent, new_target)
					temp_list[i][1], temp_list[i][3] = co, new_target
				end
			end
		end
		
		local cur_mission_timer = get_mission_timer()
		if stack == 5 then
			print("Killing myself.")
			break
		elseif cur_mission_timer > prev_mission_timer then
			prev_mission_timer = cur_mission_timer
			stack = 0
		elseif cur_mission_timer == prev_mission_timer then
			stack = stack + 1
		end
		
		co_list = temp_list
		local wait_time = os.clock()
		while (wait_time + 0.25) > os.clock() do end
	end
end

function pathing()
	c()
end

c = lanes.gen("*", path_controller)