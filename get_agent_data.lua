--active, alive, humans--

function is_alive_human_agent(agent)
	if game.agent_is_active(agent) and game.agent_is_alive(agent) and game.agent_is_human(agent) then
		return true
	else
		return false
	end
end


--teams--

function get_team(agent)
	return game.agent_get_team(0, agent)
end

--positions--

function position_get_x(pos)
	return game.position_get_x(0, pos)
end

function position_get_y(pos)
	return game.position_get_y(0, pos)
end

function position_get_z(pos)
	return game.position_get_z(0, pos)
end

function get_distance_between_positions(pos1, pos2)
	return game.get_distance_between_positions(0, pos1, pos2)
end

function get_look_target(agent)
	return game.agent_ai_get_look_target(0, agent)
end

function is_behind_position(pos1, pos2)
	return game.position_is_behind_position(pos1, pos2)
end

function get_position(preg, agent)
	game.agent_get_position(preg, agent)
end

function get_scene_boundaries(preg1, preg2)
	game.get_scene_boundaries(preg1, preg2)
end

function get_agent_speed(agent)
	game.agent_get_speed(3, agent)
	return game.preg[3]
end

function get_rotation_z(pos)
	return game.position_get_rotation_around_z(0, pos)
end

function distance_to_ground(pos)
	return game.position_get_distance_to_ground_level(0, pos)
end

function get_agent_position(agent)
	game.agent_get_position(10,agent)
	return game.preg[10]
end

function get_bone_position(agent, bone)
	game.agent_get_bone_position(1, target, bone, 1) --Get bone position
	return game.preg[1]
end

--nearby enemies

function get_num_cached_enemies(agent)
	return game.agent_ai_get_num_cached_enemies(0, agent)
end

function get_cached_enemy(val, agent)
	return game.agent_ai_get_cached_enemy(0, agent, val)
end

--combat--
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


--orders--
function get_movement_order(team, group)
	return game.team_get_movement_order(0, team, group)
end

--classes
function get_class(agent)
	return game.agent_get_class(0, agent)
end


--non getters--
function is_in_team(agent1, agent2)
	if (game.agent_get_team(0, agent1) == game.agent_get_team(0, agent2)) then
		return true
	end
end
--

--Horse
function get_horse(agent)
	horse = game.agent_get_horse(0, agent)
	return horse
end


-- items of all kinds --
function item_get_type(item)
	return game.item_get_type(0, item)
end

function get_wielded_item(agent, hand)
	val = game.agent_get_wielded_item(0, agent, hand)
	if val == -1 then
		return 0
	else
		return val
	end
end

function get_missile_speed(item)
	return game.item_get_missile_speed(0, item)
end

function get_weapon_length(item)
	return game.item_get_weapon_length(0, item)
end