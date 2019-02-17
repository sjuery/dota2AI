function FarmDesire(botInfo)
	return {10, nil}
end

function Farm(botInfo, value)
	if botInfo["lane"] == "Middle" then
		front = GetLaneFrontAmount(botInfo["team"], LANE_MID, false)
		enemyfront = GetLaneFrontAmount(botInfo["eteam"], LANE_MID, false)
		front = Min(front, enemyfront)
		dest = GetLocationAlongLane(LANE_MID, Min(1.0, front))
		botInfo["bot"]:Action_MoveToLocation(dest)
	elseif botInfo["lane"] == "Bottom" then
		front = GetLaneFrontAmount(botInfo["team"], LANE_BOT, false)
		enemyfront = GetLaneFrontAmount(botInfo["eteam"], LANE_BOT, false)
		front = Min(front, enemyfront)
		dest = GetLocationAlongLane(LANE_BOT, Min(1.0, front))
		botInfo["bot"]:Action_MoveToLocation(dest)
	elseif botInfo["lane"] == "Top" then
		front = GetLaneFrontAmount(botInfo["team"], LANE_TOP, false)
		enemyfront = GetLaneFrontAmount(botInfo["eteam"], LANE_TOP, false)
		front = Min(front, enemyfront)
		dest = GetLocationAlongLane(LANE_TOP, Min(1.0, front))
		botInfo["bot"]:Action_MoveToLocation(dest)
	end
end


function RetreatDesire(botInfo)
	return {0, nil}
end

function Retreat(botInfo, value)
	print("am retreat")
end


function PushDesire(botInfo)
	return {0, nil}
end

function Push(botInfo, value)
	print("am push")
end


function FightDesire(botInfo)
	return {0, nil}
end

function Fight(botInfo, value)
	print("am fight")
end


function RuneDesire(botInfo)
	if DotaTime() <= 0.3 then
		return {20, 1}
	end
	return {0, nil}
end

function Rune(botInfo, value)
	if botInfo["lane"] == TEAM_RADIANT then
		if botInfo["lane"] == "Middle" then
			botInfo["bot"]:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_3))
			botInfo["bot"]:Action_PickUpRune(RUNE_BOUNTY_3)
		elseif botInfo["lane"] == "Top" then
			botInfo["bot"]:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_3)+Vector(-350, -600))
			botInfo["bot"]:Action_PickUpRune(RUNE_BOUNTY_3)
		elseif botInfo["lane"] == "Bottom" then
			botInfo["bot"]:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_1))
			botInfo["bot"]:Action_PickUpRune(RUNE_BOUNTY_1)
		end
	else
		if botInfo["lane"] == "Middle" then
			botInfo["bot"]:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_2))
			botInfo["bot"]:Action_PickUpRune(RUNE_BOUNTY_2)
		elseif botInfo["lane"] == "Top" then
			botInfo["bot"]:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_2)+Vector(-250, 1000))
			botInfo["bot"]:Action_PickUpRune(RUNE_BOUNTY_2)
		elseif botInfo["lane"] == "Bottom" then
			botInfo["bot"]:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_4))
			botInfo["bot"]:Action_PickUpRune(RUNE_BOUNTY_4)
		end
	end
	print("am rune")
end


function MemeDesire(botInfo)
	return {0, nil}
end

function Meme(botInfo, value)
	print("am meme")
end

local function UpKeep(botInfo)
end

generic_desires = {
	["farm"] = {FarmDesire, Farm},
	["retreat"] = {RetreatDesire, Retreat},
	["push"] = {PushDesire, Push},
	["fight"] = {FightDesire, Fight},
	["rune"] = {RuneDesire, Rune},
	["meme"] = {MemeDesire, Meme}
}

function Thonk(botInfo, desires)
	UpKeep(botInfo)
	local desire_best = -1
	local desire_value = nil
	local desire_mode = nil

	for name, thonkage in pairs(desires) do
		local thonk_result = thonkage[1](botInfo)
		local desire = thonk_result[1]
		local value = thonk_result[2]
		if desire > desire_best then
			desire_best = desire
			desire_value = value
			desire_mode = thonkage[2]
		end
	end
	desire_mode(botInfo, desire_value)
end