local function FarmDesire(bot)
	local listAlliedCreeps = bot.ref:GetNearbyLaneCreeps(1200, false)
	local listEnemyCreeps = bot.ref:GetNearbyLaneCreeps(1200, true)
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

	if #listEnemyCreeps ~= 0 and lowestEnemyHealth < bot.ref:GetEstimatedDamageToTarget(true, weakestEnemyCreep, bot.ref:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) - 4 then
		return {50, weakestEnemyCreep}
	elseif #listAlliedCreeps ~= 0 and lowestFriendlyHealth < bot.ref:GetEstimatedDamageToTarget(true, weakestFriendlyCreep, bot.ref:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) - 4 then
		return {35, weakestFriendlyCreep}
	elseif #listEnemyCreeps ~= 0 and lowestEnemyHealth < bot.ref:GetEstimatedDamageToTarget(true, weakestEnemyCreep, bot.ref:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) * 2 and lowestEnemyHealth > bot.ref:GetEstimatedDamageToTarget(true, weakestEnemyCreep, bot.ref:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) - 5 then
		return {10, listEnemyCreeps[1]}
	elseif #listEnemyCreeps ~= 0 then
		return {35, listEnemyCreeps[1]}
	end
	return {10, listEnemyCreeps[1]}
end

local function Farm(bot, value)
	front = GetLaneFrontAmount(GetTeam(), bot.lane, false)
	enemyfront = GetLaneFrontAmount(GetEnemyTeam(), bot.lane, false)
	front = Min(front, enemyfront)
	dest = GetLocationAlongLane(bot.lane, Min(1.0, front))
	bot.ref:Action_MoveToLocation(dest)
	bot.ref:Action_AttackUnit(value, true)
	print("am farm")
end


local function RetreatDesire(bot)
	if bot.retreat > GameTime() then
		return {100, 0}
	else
		bot.retreat = 0;
	end
	allied_creeps = bot.ref:GetNearbyLaneCreeps(1600, false)
	enemy_towers = bot.ref:GetNearbyTowers(1600, true)

	local meatshield_creeps = {}
	if #allied_creeps > 0 and #enemy_towers > 0 then
		-- Search for nearby enemy heroes (Not under enemy towers)
		for i = 1, #allied_creeps do
			for i = 1, #enemy_towers do
				if GetDistance(allied_creeps[i]:GetLocation(), enemy_towers[i]:GetLocation()) < 700 then
					table.insert(meatshield_creeps, allied_creeps[i])
				end
			end
		end
	end
	-- One day use meatshield creeps for tower aggro

	if bot.hp_percent < 0.4 then
		return {40, DotaTime() + 7}
	elseif bot.hp_percent < 0.2 then
		return {55, DotaTime() + 10}
	end

	if bot.ref:WasRecentlyDamagedByCreep(1.0) then
		return {40, DotaTime() + 3}
	end

	if bot.ref:WasRecentlyDamagedByTower(1.0) then
		return {70, DotaTime() + 5}
	end

	if #enemy_towers > 0
		and #meatshield_creeps <= 2
		and GetDistance(enemy_towers[1]:GetLocation(), bot.ref:GetLocation()) < 750
	then
		return {70, DotaTime() + 5}
	end
	return {0, nil}
end

local function Retreat(bot, value)
	bot.retreat = bot.retreat + value
	front = GetLaneFrontAmount(GetTeam(), bot.lane, false)
	enemyfront = GetLaneFrontAmount(GetEnemyTeam(), bot.lane, false)
	front = Min(front, enemyfront)
	pos = GetLocationAlongLane(bot.lane, front - 0.05) + RandomVector(50)
	bot.ref:Action_MoveToLocation(pos)
	print("am retreat")
end

local function PushDesire(bot)
	local enemy_towers = bot.ref:GetNearbyTowers(1600, true)
	local allied_creeps = bot.ref:GetNearbyLaneCreeps(500, false)
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1600, true)

	-- If help nearby or tower will die in two hits then we want to attack tower
	if #enemy_towers > 0 and ((#allied_creeps >= 3 and #enemy_creeps <= 2)
		or enemy_towers[1]:GetHealth() < bot.ref:GetEstimatedDamageToTarget(true, enemy_towers[1], bot.ref:GetAttackSpeed(), DAMAGE_TYPE_ALL) * 1.6)
	then
		return {40, enemy_towers[1]}
	end
	return {2, enemy_towers[1]}
end

local function Push(bot, enemy_tower)
	front = GetLaneFrontAmount(GetTeam(), bot.lane, false)
	enemyfront = GetLaneFrontAmount(GetEnemyTeam(), bot.lane, false)
	front = Min(front, enemyfront)
	dest = GetLocationAlongLane(bot.lane, Min(1.0, front))
	bot.ref:Action_MoveToLocation(dest)
	bot.ref:Action_AttackUnit(enemy_tower, true)
end


local function FightDesire(bot)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	local heroes = bot.ref:GetNearbyHeroes(600, false, BOT_MODE_NONE)

	local target = nil
	if #enemy_heroes > 0 then
		local towers = bot.ref:GetNearbyTowers(1600, true)

		-- Search for nearby enemy heroes (Not under enemy towers)
		for i = 1, #enemy_heroes do
			local pos = enemy_heroes[i]:GetLocation()
			if IsLocationVisible(pos) or IsLocationPassable(pos) then
				for i = 1, #towers do
					if GetDistance(pos, towers[i]:GetLocation()) > 900 then
						target = enemy_heroes[i]
						break
					end
				end
				if #towers == 0 then
					target = enemy_heroes[1]
					break
				end
			end
		end
	end

	if target and #enemy_heroes <= #heroes then
		return {30, target}
	elseif target then
		return {5, target}
	end
	return {0, nil}
end

local function Fight(bot, value)
	bot.ref:Action_AttackUnit(value, true)
end


local function RuneDesire(bot)
	if DotaTime() <= 0.3 then
		return {20, 1}
	end
	return {1, nil}
end

local function Rune(bot, value)
	if GetTeam() == TEAM_RADIANT then
		if bot.lane == LANE_MID then
			bot.ref:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_3))
			bot.ref:Action_PickUpRune(RUNE_BOUNTY_3)
		elseif bot.lane == LANE_TOP then
			bot.ref:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_3) + Vector(-350, 1000))
			bot.ref:Action_PickUpRune(RUNE_BOUNTY_3)
		elseif bot.lane == LANE_BOT then
			bot.ref:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_1))
			bot.ref:Action_PickUpRune(RUNE_BOUNTY_1)
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
	--print("am rune")
end


local function MemeDesire(bot)
	return {0, nil}
end

local function Meme(bot, value)
	print("am meme")
end


local function HealDesire(bot)
	if bot.hp_percent > 0.95
		or bot.ref:HasModifier("modifier_fountain_aura_buff")
		or bot.ref:HasModifier("modifier_filler_heal") 
	then
		return {0, nil}
	end

	local items = GetItems(bot)

	local salve = items["item_flask"]
	if salve ~= nil 
		and not bot.ref:HasModifier("modifier_flask_healing") 
		and not bot.ref:WasRecentlyDamagedByAnyHero(3.0)
		and (bot.hp_max - bot.hp_current > 400 or bot.hp_percent < 0.33)
	then
		return {60, {salve, bot.ref}}
	end

	local tango = nil
	if items["item_tango_single"] ~= nil then
		tango = items["item_tango_single"]
	elseif items["item_tango"] then
		tango = items["item_tango"]
	end

	if tango ~= nil 
		and bot.hp_percent < 0.9
		and not bot.ref:HasModifier("modifier_tango_heal")
		and not bot.ref:WasRecentlyDamagedByTower(1.2)
		and tango:IsFullyCastable()
	then
		local trees = bot.ref:GetNearbyTrees(1000)
		if #trees > 0 then
			local towers = bot.ref:GetNearbyTowers(1600, true)
			local tree = nil

			-- Search for safe trees (Not under enemy towers)
			for i = 1, #trees do
				local tree_pos = GetTreeLocation(trees[i])
				if IsLocationVisible(tree_pos) or IsLocationPassable(tree_pos) then
					for i = 1, #towers do
						if GetDistance(tree_pos, towers[i]:GetLocation()) > 1200 then
							tree = trees[i]
							break
						end
					end
					if #towers == 0 then
						tree = trees[1]
						break
					end
				end
			end
			if tree ~= nil then
				return {50, {tango, tree}}
			end
		end
	end

	local clarity = items["item_clarity"]
	if clarity ~= nil
		and not bot.ref:HasModifier("modifier_clarity_potion")
		and not bot.ref:WasRecentlyDamagedByAnyHero(3.0)
		and (bot.mp_max - bot.mp_current > 225)
	then
		return {60, {clarity, bot.ref}}
	end

	-- local shrines = {
	-- 	SHRINE_BASE_1,
	-- 	SHRINE_BASE_2,
	-- 	SHRINE_BASE_3,
	-- 	SHRINE_BASE_4,
	-- 	SHRINE_BASE_5,
	-- 	SHRINE_JUNGLE_1,
	-- 	SHRINE_JUNGLE_2
	-- }
	-- local team = GetTeam()
	-- local shrine_dist = 100000
	-- for i = 1, #shrines do
	-- 	local shrine = GetShrine(team, shrines[i])
	-- 	GetShrineCooldown()
	-- 	IsShrineHealing()
	-- end

	return {0, nil}
end

local function Heal(bot, params)
	local heal_item, heal_target = unpack(params)
	local name = heal_item:GetName()
	if string.find(name, "tango") ~= nil then
		print("Using tango..")
		bot.ref:Action_UseAbilityOnTree(heal_item, heal_target)
	elseif name == "item_flask" or name == "item_clarity" then
		print("Using.. " .. name)
		bot.ref:Action_UseAbilityOnEntity(heal_item, heal_target)
	end
end

local generic_buy_order = {
	"item_tango",
	"item_tango",
	"item_flask",
	"item_stout_shield",
	"item_quelling_blade",
-- Power treads
	"item_boots",
	"item_boots_of_elves",
	"item_gloves",
-- Armlet of Mordiggian
	"item_helm_of_iron_will",
	"item_boots_of_elves",
	"item_blades_of_attack",
	"item_recipe_armlet"
}

local function UpKeep(bot)
	-- Upgrade abilities
	if bot.ability_order then
		if bot.ref:GetAbilityPoints() > 0 then
			local ability = bot.ref:GetAbilityByName(bot.ability_order[1])
			print("Upgrading ability: " .. bot.ability_order[1])
			if (ability:CanAbilityBeUpgraded() and ability:GetLevel() < ability:GetMaxLevel()) then
				bot.ref:ActionImmediate_LevelAbility(bot.ability_order[1])
				table.remove(bot.ability_order, 1)
				return
			end
		end
	end

	-- Buy items
	local buy_order = generic_buy_order
	if bot.buy_order ~= nil then
		buy_order = bot.buy_order
	end
	if #buy_order ~= 0 then
		local item = buy_order[1]
		local cost = GetItemCost(item)

		if bot.ref:GetGold() >= cost and not IsItemPurchasedFromSecretShop(item) then
			print("Buying: " .. item)
			bot.ref:ActionImmediate_PurchaseItem(item)
			table.remove(buy_order, 1)
			return
		end
	end

	-- Use Courier
	if GetNumCouriers() ~= 0 then
		local courier = GetCourier(0)
		local state = GetCourierState(courier)
		if bot.ref:IsAlive()
			and state ~= COURIER_STATE_DEAD
			and state ~= COURIER_STATE_DELIVERING_ITEMS
			and (bot.ref:GetStashValue() > 500 or bot.ref:GetCourierValue() > 0)
		then
			bot.ref:ActionImmediate_Courier(courier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS)
			return
		end
	end
end


generic_desires = {
	["farm"] = {FarmDesire, Farm},
	["retreat"] = {RetreatDesire, Retreat},
	["heal"] = {HealDesire, Heal},
--	["shop"] = {ShopDesire, Shop},
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
		local desire, value = unpack(thonkage[1](bot))
		if desire > desire_best then
			desire_best = desire
			desire_value = value
			desire_mode = thonkage[2]
		end
	end
	desire_mode(bot, desire_value)
	UpKeep(bot)
end
