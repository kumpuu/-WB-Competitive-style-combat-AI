local function table_has_value(t, val)
	for i, v in pairs(t) do
		if i == val then
			return true
		end
	end
	return false
end

function gettarget()
	g = dofile("get_agent_data.lua") -- Load file
	
	local target_table = {}
	for agent in game.agentsI() do
		if is_alive_human_agent(agent) then
			target = get_look_target(agent)
			if is_alive_human_agent(target) then
				if not table_has_value(target_table, agent) then
					target_table[agent] = 0
				end
				if table_has_value(target_table, target) then
					target_table[target] = target_table[target] + 1
				else
					target_table[target] = 1
				end
			end
		end
	end
	
	--print("Target table size: " .. #target_table)
	
	for agent in game.agentsI() do
		target = get_look_target(agent)
		enemy_amount = get_num_cached_enemies(agent)
		if #target_table > 0 then
			for x=1, enemy_amount do
				enemy = get_cached_enemy(x, agent)
				if (target_table[enemy] ~= nil) and (target_table[enemy] < 2) then
					game.agent_set_look_target_agent(agent, enemy)
					break
				end
			end
		end
	end
end