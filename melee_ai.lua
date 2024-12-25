lanes = require "lanes".configure()

local function in_melee_range(agent, target)
	local pos_agent, pos_target = get_agent_position(agent), get_agent_position(target)
	local agent_weapon, distance = get_wielded_item(agent, 0), get_distance_between_positions(pos_agent, pos_target)
	if distance < (120 + get_weapon_length(agent_weapon)) then
		return true
	else
		return false
	end
end

local function value_in_table(list, val)
	for i=1,#list do
		if list[i] == val then
			return true
		end
	end
	return false
end

local function attack_allowed(agent, target)
	action_agent, defend_agent, action_target, defend_target,  state_target, state_agent = get_attack_action(agent), get_defend_action(agent), get_attack_action(target), get_defend_action(target), get_combat_state(target), get_combat_state(agent)
	
	if action_agent ~= 1 and action_agent ~= 2 and action_target ~= 3 then
		if action_target ~= 1 and action_target ~= 2 and (action_target == 6 or defend_target == 2 or action_agent == 3 or state_agent ~= 7 or state_agent ~= 2) then
			return true
		end
	end
	return false
end

local function block_allowed(agent, target)
	action_agent, action_target, state_agent = get_attack_action(agent), get_attack_action(target), get_combat_state(agent)
	if in_melee_range(target, agent) and (action_target == 2 or action_target == 3 or action_agent == 6 or state_agent == 7) and action_agent ~= 2 then
		return true
	else
		return false
	end
end

local function attack(agent, cancel)
	if cancel then
		set_attack_action(agent, -2)
	else
		set_attack_action(agent, math.random(0,3))
	end
end

local function block(agent, target, delay, block_fail)
	set_defend_action(agent, target, delay, block_fail)
end

local function event_randomiser(events)
	return math.random(1, #events)
end

local function execute_event(agent)
	level = get_character_level(agent)
	event_chance = (1 - (0.85^level)) --chance of event happening is based on character level
	chance = math.random()
	if chance > event_chance then
		return true
	else
		return false
	end
end

local function event_execution(agent, target, event)
	if in_melee_range(agent, target) then
		action_agent, action_target = get_attack_action(agent), get_attack_action(target)
		if event == 1 and ((action_agent == 1 or action_agent == 2) or (action_target == 0 or action_target == 1)) then
			local feint_delay = os.clock()
			local feint_amount = math.random(1,3)
			local feint_value = 1
			while feint_value < feint_amount do
				attack(agent, false)
				while (feint_delay + 0.5) > os.clock() do coroutine.yield() end
				attack(agent, true)
				feint_value = feint_value + 1
			end
			attack(agent, false)
		elseif event == 2 and (action_agent ~= 1 and action_agent ~= 2) then
			attack(agent, false)
		end
	elseif action_target == 1 or action_target == 2 and in_melee_range(target, agent) then
		block(agent, target, math.random(50,100), true)
	end
end

local function combat_ai(agent, target)
	local feint, spam, block_fail = 1, 2, 3
	local events = {feint, spam, block_fail}
	local event_check_cooldown = os.clock()
	local event_going_on = false
	local event = 0
	
	while agent > -1 and target > -1 do
		if in_melee_range(agent, target) and (event_check_cooldown + 2) < os.clock() then
			if execute_event(agent) then
				event_execution(agent, target, event_randomiser(events))
				event_check_cooldown = os.clock()
				event_going_on = true
			else
				event_check_cooldown = os.clock()
			end
		elseif event_going_on and (event_check_cooldown + 0.75) < os.clock() then
			event_going_on = false
		elseif block_allowed(agent, target) and not event_going_on and execute_event(agent) then
			block(agent, target, math.random(25, 50), false)
		--elseif attack_allowed(agent, target) and not event_going_on then
		--	attack(agent, false)
		end
		coroutine.yield()
	end
end

function start_combat_ai()
	--Load files needed
	dofile("data/position_data.lua")
	dofile("data/combat_data.lua")
	dofile("data/item_data.lua")
	dofile("data/agent_player_data.lua")
	dofile("data/mission_data.lua")
	
	local co_list = {}
	
	for agent in game.agentsI() do
		if is_alive_human_agent(agent) and agent_is_non_player(agent) then
			co, target = coroutine.create(combat_ai), get_look_target(agent)
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
			--gather data
			status = coroutine.status(co_list[i][1])
			agent = co_list[i][2]
			old_target = co_list[i][3]
			new_target = get_look_target(agent)
			if status == 'dead' and is_alive_human_agent(agent) then
				co = coroutine.create(combat_ai)
				coroutine.resume(co, agent, new_target)
				temp_list[i][1], temp_list[i][3] = co, new_target
			elseif not is_alive_human_agent(agent) then
				table.remove(temp_list, i)
				break
			elseif status == 'suspended' then
				if old_target == new_target then
					coroutine.resume(co_list[i][1])
				else
					co = coroutine.create(combat_ai)
					coroutine.resume(co, agent, new_target)
					temp_list[i][1], temp_list[i][3] = co, new_target
				end
			end
		end
		co_list = temp_list
		
		local cur_mission_timer = get_mission_timer()
		if stack == 50 then
			break
		elseif cur_mission_timer > prev_mission_timer then
			prev_mission_timer = cur_mission_timer
			stack = 0
		elseif cur_mission_timer == prev_mission_timer then
			stack = stack + 1
		end
		
		local wait_time = os.clock()
		while (wait_time + 0.0001) > os.clock() do end
	end
end

function melee()
	f()
end

f = lanes.gen("*", start_combat_ai)