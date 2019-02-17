function FarmDesire(bot)
	return {10, nil}
end

function Farm(bot, value)
	print("farm plz")
	front = GetLaneFrontAmount(GetTeam(), bot.lane, false)
	enemyfront = GetLaneFrontAmount(GetEnemyTeam(), bot.lane, false)
	front = Min(front, enemyfront)
	dest = GetLocationAlongLane(bot.lane, Min(1.0, front))
	bot.ref:Action_MoveToLocation(dest)
end


function RetreatDesire(bot)
	return {0, nil}
end

function Retreat(bot, value)
	print("am retreat")
end


function PushDesire(bot)
	return {0, nil}
end

function Push(bot, value)
	print("am push")
end


function FightDesire(bot)
	return {0, nil}
end

function Fight(bot, value)
	print("am fight")
end


function RuneDesire(bot)
	if DotaTime() <= 0.3 then
		return {20, 1}
	end
	return {0, nil}
end

function Rune(bot, value)
	if GetTeam() == TEAM_RADIANT then
		if bot.lane == LANE_MID then
			bot.ref:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_3))
			bot.ref:Action_PickUpRune(RUNE_BOUNTY_3)
		elseif bot.lane == LANE_TOP then
			bot.ref:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_3) + Vector(-350, -600))
			bot.ref:Action_PickUpRune(RUNE_BOUNTY_3)
		elseif bot.lane == LANE_BOT then
			bot.ref:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_1))
			bot.ref:Action_PickUpRune(RUNE_BOUNTY_1)
		end
	else
		if bot.lane == LANE_MID then
			bot.ref:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_2))
			bot.ref:Action_PickUpRune(RUNE_BOUNTY_2)
		elseif bot.lane == LANE_TOP then
			bot.ref:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_2) + Vector(-250, 1000))
			bot.ref:Action_PickUpRune(RUNE_BOUNTY_2)
		elseif bot.lane == LANE_BOT then
			bot.ref:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_4))
			bot.ref:Action_PickUpRune(RUNE_BOUNTY_4)
		end
	end
	print("am rune")
end


function MemeDesire(bot)
	return {0, nil}
end

function Meme(bot, value)
	print("am meme")
end

local function UpKeep(bot)
	print("upkeeping")

	local items = GetItems(bot)

	local tango = nil
	if items["item_tango_single"] ~= nil then
		tango = items["item_tango_single"]
	elseif items["item_tango"] then
		tango = items["item_tango"]
	end

	if bot.hp_percent < 0.8 and tango ~= nil and not bot.ref:HasModifier("modifier_tango_heal") and tango:IsFullyCastable() then
		print("wanna heal")
		local trees = bot:GetNearbyTrees(600)
		if #trees > 0 then
			local tree_pos = GetTreeLocation(trees[1])
			if IsLocationVisible(tree_pos) or IsLocationPassable(tree_pos) then
				bot:Action_UseAbilityOnTree(tango, trees[1])
			end
		end
	end

	local flask = items["item_flask"]
	if bot.hp_percent < 0.33 and flask ~= nil and flask:IsFullyCastable() then
		print("wanna really heal")
		bot.ref:Action_UseAbilityOnEntity(flask, bot)
	end
end

generic_desires = {
	["farm"] = {FarmDesire, Farm},
	["retreat"] = {RetreatDesire, Retreat},
	["push"] = {PushDesire, Push},
	["fight"] = {FightDesire, Fight},
	["rune"] = {RuneDesire, Rune},
	["meme"] = {MemeDesire, Meme}
}

function Thonk(bot, desires)
	local desire_best = -1
	local desire_value = nil
	local desire_mode = nil

	for name, thonkage in pairs(desires) do
		local thonk_result = thonkage[1](bot)
		local desire = thonk_result[1]
		local value = thonk_result[2]
		if desire > desire_best then
			desire_best = desire
			desire_value = value
			desire_mode = thonkage[2]
		end
	end
	desire_mode(bot, desire_value)
	UpKeep(bot)
end
