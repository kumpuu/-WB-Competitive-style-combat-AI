function position_get_x(pos)
	return game.position_get_x(0, pos)
end

function position_get_y(pos)
	return game.position_get_y(0, pos)
end

function position_get_z(pos)
	return game.position_get_z(0, pos)
end

function position_move_y(pos, val)
	game.position_move_y(pos, val, 0)
end

function position_move_x(pos, val)
	game.position_move_x(pos, val, 0)
end

function get_distance_between_positions(pos1, pos2)
	--x = (pos1.o.x - pos2.o.x)
	--y = (pos1.o.y - pos2.o.y)
	return game.get_distance_between_positions(0, pos1, pos2)
end

function is_behind_position(pos1, pos2)
	return game.position_is_behind_position(pos1, pos2)
end

function get_scene_boundaries(preg1, preg2)
	game.get_scene_boundaries(preg1, preg2)
	return {game.preg[preg1], game.preg[preg2]}
end

function get_agent_speed(agent)
	game.agent_get_speed(24, agent)
	return game.preg[24]
end

function get_rotation_z(pos)
	return game.position_get_rotation_around_z(0, pos)
end

function distance_to_ground(pos)
	return game.position_get_distance_to_ground_level(0, pos)
end

function get_agent_position(agent)
	game.agent_get_position(23,agent)
	return game.preg[23]
end

function get_bone_position(agent, bone)
	game.agent_get_bone_position(10, target, bone, 1) --Get bone position
	return game.preg[10]
end

function set_destination(agent, pos)
	game.agent_set_scripted_destination(agent, pos, 1)
end

function is_behind(pos1, pos2)
	return game.position_is_behind_position(pos1, pos2)
end

function rotation_difference(pos1, pos2)
	return game.get_angle_between_positions(0, pos1, pos2)
end