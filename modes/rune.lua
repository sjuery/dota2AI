require(GetScriptDirectory() .. "../utility")

function RunePriority(bot)
	if DotaTime() <= 0.3 then
		return 20, nil
	end

	local runes = {
		RUNE_POWERUP_1,
		RUNE_POWERUP_2,
		RUNE_BOUNTY_1,
		RUNE_BOUNTY_2,
		RUNE_BOUNTY_3,
		RUNE_BOUNTY_4
	}

	local closest_rune_dist = 10000000
	local closest_rune = nil
	for i = 1, #runes do
		rune_pos = GetRuneSpawnLocation(runes[i])
		local rune_dist = GetUnitToLocationDistance(bot.ref, rune_pos)
		if IsLocationPassable(rune_pos)
			and rune_dist < closest_rune_dist and rune_dist < 3000
			and GetRuneStatus(runes[i]) == RUNE_STATUS_AVAILABLE
		then
			closest_rune = runes[i]
			closest_rune_dist = rune_dist
		end
	end

	if not closest_rune then
		return 0, nil
	end

	if closest_rune_dist < 300 then
		return 75, closest_rune
	elseif closest_rune_dist < 800 then
		return 65, closest_rune
	end
	return 55, closest_rune
end

function Rune(bot, rune)
	if rune ~= nil then
		local pos = GetRuneSpawnLocation(rune)
		if GetUnitToLocationDistance(bot.ref, pos) > 100 then
			bot.ref:Action_MoveToLocation(pos)
		end
		bot.ref:Action_PickUpRune(rune)
		return
	end
	if GetTeam() == TEAM_RADIANT then
		if bot.lane == LANE_MID then
			bot.ref:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_1))
			bot.ref:Action_PickUpRune(RUNE_BOUNTY_1)
		elseif bot.lane == LANE_TOP then
			bot.ref:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_1) + Vector(-350, 1000))
			bot.ref:Action_PickUpRune(RUNE_BOUNTY_1)
		elseif bot.lane == LANE_BOT then
			bot.ref:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_3))
			bot.ref:Action_PickUpRune(RUNE_BOUNTY_3)
		end
	else
		if bot.lane == LANE_MID then
			bot.ref:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_4))
			bot.ref:Action_PickUpRune(RUNE_BOUNTY_4)
		elseif bot.lane == LANE_TOP then
			bot.ref:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_4) + Vector(-250, -600))
			bot.ref:Action_PickUpRune(RUNE_BOUNTY_4)
		elseif bot.lane == LANE_BOT then
			bot.ref:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_2))
			bot.ref:Action_PickUpRune(RUNE_BOUNTY_2)
		end
	end
end
