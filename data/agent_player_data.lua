function is_alive_human_agent(agent)
	if game.agent_is_active(agent) and game.agent_is_alive(agent) and game.agent_is_human(agent) then
		return true
	else
		return false
	end
end

function agent_is_non_player(agent)
	if game.agent_is_non_player(agent) then
		return true
	else
		return false
	end
end

function get_look_target(agent)
	return game.agent_ai_get_look_target(0, agent)
end

function get_troop(agent)
	return game.agent_get_troop_id(0, agent)
end

function get_simple_behavior(agent)
	return game.agent_get_simple_behavior(0, agent)
end

function get_character_level(agent)
	return game.store_character_level(0, get_troop(agent))
end

function clear_scripted_mode(agent)
	game.agent_clear_scripted_mode(agent)
end

function force_rethink(agent)
	game.agent_force_rethink(agent)
end

function get_target_agent_is_moving_to(agent)
	return game.agent_ai_get_move_target(0, agent)
end