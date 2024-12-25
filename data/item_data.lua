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