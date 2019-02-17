function FarmDesire(bot)
	local listAlliedCreeps = bot.ref:GetNearbyCreeps(1200, false)
	local listEnemyCreeps = bot.ref:GetNearbyCreeps(1200, true)
	local weakestFriendlyCreep, weakestEnemyCreep = unpack({nil, nil})
	local lowestFriendlyHealth, lowestEnemyHealth = unpack({10000, 10000})

	if #listAlliedCreeps == 0 and #listEnemyCreeps == 0 then
		return {10, nil}
	end

	for _, creep in pairs(listAlliedCreeps) do
		if creep:GetHealth() then
			if lowestFriendlyHealth > creep:GetHealth() then
				weakestFriendlyCreep = creep
				lowestFriendlyHealth = creep:GetHealth()
			end
		end
	end

	for _, creep in pairs(listEnemyCreeps) do
		if creep:GetHealth() then
			if lowestEnemyHealth > creep:GetHealth() then
				weakestEnemyCreep = creep
				lowestEnemyHealth = creep:GetHealth()
			end
		end
	end

	if #listEnemyCreeps ~= 0 and lowestEnemyHealth < bot.ref:GetEstimatedDamageToTarget(true, weakestEnemyCreep, bot.ref:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) - 5 then
		return {50, weakestEnemyCreep}
	elseif #listAlliedCreeps ~= 0 and lowestFriendlyHealth < bot.ref:GetEstimatedDamageToTarget(true, weakestFriendlyCreep, bot.ref:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) - 5 then
		return {40, weakestFriendlyCreep}
	elseif #listEnemyCreeps ~= 0 and lowestEnemyHealth < bot.ref:GetEstimatedDamageToTarget(true, weakestEnemyCreep, bot.ref:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) * 2 and lowestEnemyHealth > bot.ref:GetEstimatedDamageToTarget(true, weakestEnemyCreep, bot.ref:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) - 5 then
		return {10, listEnemyCreeps[1]}
	elseif #listEnemyCreeps ~= 0 then
		return {35, listEnemyCreeps[1]}
	end
	return {10, listEnemyCreeps[1]}
end

function Farm(bot, value)
	front = GetLaneFrontAmount(GetTeam(), bot.lane, false)
	enemyfront = GetLaneFrontAmount(GetEnemyTeam(), bot.lane, false)
	front = Min(front, enemyfront)
	dest = GetLocationAlongLane(bot.lane, Min(1.0, front))
	bot.ref:Action_MoveToLocation(dest)
	bot.ref:Action_AttackUnit(value, true)
end


function RetreatDesire(bot)
	if bot.retreat > GameTime() then
		return 100, 0
	else
		bot.retreat = 0;
	end
	nearAlliedCreep = bot.ref:GetNearbyCreeps(1200, false)
	nearETowers = bot.ref:GetNearbyTowers(1200, true)
	if bot.hp_percent < 0.4 then
		return {30, DotaTime() + 5}
	elseif bot.hp_percent < 0.2 then
		return {60, DotaTime() + 5}
	end

	if bot.ref:WasRecentlyDamagedByCreep(1.0) then
		return {20, DotaTime() + 5}
	end

	if #nearETowers > 0 and #nearAlliedCreep <= 2 then
		return {100, DotaTime() + 5}
	end
	return {0, nil}
end

function Retreat(bot, value)
	bot.retreat = bot.retreat + value
	front = GetLaneFrontAmount(GetTeam(), bot.lane, false)
	enemyfront = GetLaneFrontAmount(GetEnemyTeam(), bot.lane, false)
	front = Min(front, enemyfront)
	pos = GetLocationAlongLane(bot.lane, front - 0.05) + RandomVector(200)
	bot.ref:Action_MoveToLocation(pos)
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
		print(RUNE_BOUNTY_3)
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
		local trees = bot.ref:GetNearbyTrees(600)
		if #trees > 0 then
			local tree_pos = GetTreeLocation(trees[1])
			if IsLocationVisible(tree_pos) or IsLocationPassable(tree_pos) then
				bot.ref:Action_UseAbilityOnTree(tango, trees[1])
			end
		end
	end

	local flask = items["item_flask"]
	if bot.hp_percent < 0.33 and flask ~= nil and flask:IsFullyCastable() then
		print("wanna really heal")
		bot.ref:Action_UseAbilityOnEntity(flask, bot.ref)
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
