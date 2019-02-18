local function FarmDesire(bot)
	return {10, nil}
end

local function Farm(bot, value)
	print("farm plz")
	front = GetLaneFrontAmount(GetTeam(), bot.lane, false)
	enemyfront = GetLaneFrontAmount(GetEnemyTeam(), bot.lane, false)
	front = Min(front, enemyfront)
	dest = GetLocationAlongLane(bot.lane, Min(1.0, front))
	bot.ref:Action_MoveToLocation(dest)
end


local function RetreatDesire(bot)
	return {0, nil}
end

local function Retreat(bot, value)
	print("am retreat")
end


local function PushDesire(bot)
	return {0, nil}
end

local function Push(bot, value)
	print("am push")
end


local function FightDesire(bot)
	return {0, nil}
end

local function Fight(bot, value)
	print("am fight")
end


local function RuneDesire(bot)
	if DotaTime() <= 0.3 then
		return {20, 1}
	end
	return {0, nil}
end

local function Rune(bot, value)
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


local function MemeDesire(bot)
	return {0, nil}
end

local function Meme(bot, value)
	print("am meme")
end

local function UpKeep(bot)
	print("upkeeping")
end

local function HealDesire(bot)
	if bot.hp_percent > 0.95 or 
		bot.ref:HasModifier("modifier_fountain_aura_buff") or bot.ref:HasModifier("modifier_filler_heal") 
	then
		return {0, nil}
	end

	local items = GetItems(bot)



	local salve = items["item_flask"]
	if salve ~= nil and not bot.ref:HasModifier("modifier_flask_healing") and 
		(bot.hp_max - bot.hp_current > 400 or bot.hp_percent < 0.33)
	then
		return {50, {salve, bot.ref}}
	end

	local tango = nil
	if items["item_tango_single"] ~= nil then
		tango = items["item_tango_single"]
	elseif items["item_tango"] then
		tango = items["item_tango"]
	end
	if tango ~= nil and bot.hp_percent < 0.9 and not bot.ref:HasModifier("modifier_tango_heal") and tango:IsFullyCastable() then
		print("wanna heal")
		local trees = bot:GetNearbyTrees(600)
		if #trees > 0 then
			local tree_pos = GetTreeLocation(trees[1])
			if IsLocationVisible(tree_pos) or IsLocationPassable(tree_pos) then
				bot:Action_UseAbilityOnTree(tango, trees[1])
				return {40, {tango, trees[1]}}
			end
		end
	end
end

local function Heal(bot, params)
	local heal_item, heal_target = unpack(params)
	local name = heal_item:GetName()
	if string.find(name, "tango") ~= nil then
		bot.ref:Action_UseAbilityOnTree(heal_item, heal_target)
	elseif name == "item_flask" then
		bot.ref:Action_UseAbilityOnEntity(heal_item, heal_target)
	end
end

generic_desires = {
	["farm"] = {FarmDesire, Farm},
	["retreat"] = {RetreatDesire, Retreat},
	["heal"] = {HealDesire, Heal},
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
