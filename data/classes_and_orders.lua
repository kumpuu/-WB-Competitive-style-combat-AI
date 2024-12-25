--orders--
function get_movement_order(team, group)
	return game.team_get_movement_order(0, team, group)
end

--classes
function get_class(agent)
	return game.agent_get_class(0, agent)
end

function get_team(agent)
	return game.agent_get_team(0, agent)
end