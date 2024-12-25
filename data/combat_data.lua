function get_combat_state(agent)
	return game.agent_get_combat_state(0, agent)
end

function get_attack_direction(agent)
	return game.agent_get_action_dir(0, agent)
end

function get_defend_action(agent)
	return game.agent_get_defend_action(0, agent)
end

function get_attack_action(agent)
	return game.agent_get_attack_action(0, agent)
end

function get_defend_action(agent)
	return game.agent_get_defend_action(0, agent)
end

function get_num_cached_enemies(agent)
	return game.agent_ai_get_num_cached_enemies(0, agent)
end

function get_cached_enemy(val, agent)
	return game.agent_ai_get_cached_enemy(val, agent)
end

function set_attack_action(agent, dir)
	game.agent_set_attack_action(agent, dir, 0)
end

function set_defend_action(agent, target, delay, fail_block)
	dir = get_attack_direction(target)
	if fail_block then
		fail_dir = math.random(0,3)
		while dir == fail_dir do fail_dir = math.random(0,3) end
		game.agent_set_defend_action(agent, fail_dir, delay)
	else
		game.agent_set_defend_action(agent, dir, delay)
	end
end