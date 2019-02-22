require(GetScriptDirectory() .. "/upkeep")
require(GetScriptDirectory() .. "/utility")

local function FarmDesire(bot)
	local allied_creeps = bot.ref:GetNearbyLaneCreeps(1000, false)
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1000, true)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

	if #allied_creeps == 0 and #enemy_creeps == 0 then
		return {10, nil}
	end

	local weakest_friendly_creep = nil
	local lowest_friendly_hp = 10000000
	for i = 1, #allied_creeps do
		local hp = allied_creeps[i]:GetHealth()
		if hp and hp < lowest_friendly_hp then
			weakest_friendly_creep = allied_creeps[i]
			lowest_friendly_hp = hp
		end
	end

	local weakest_enemy_creep = nil
	local lowest_enemy_hp    = 10000000
	for i = 1, #enemy_creeps do
		local hp = enemy_creeps[i]:GetHealth()
		if hp and hp < lowest_enemy_hp then
			weakest_enemy_creep = enemy_creeps[i]
			lowest_enemy_hp = hp
		end
	end

	if #enemy_creeps ~= 0
		and lowest_enemy_hp < bot.ref:GetEstimatedDamageToTarget(true, weakest_enemy_creep, bot.ref:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) - 5
	then
		return {50, weakest_enemy_creep}
	elseif #allied_creeps ~= 0
		and lowest_friendly_hp < bot.ref:GetEstimatedDamageToTarget(true, weakest_friendly_creep, bot.ref:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) - 5
	then
		return {35, weakest_friendly_creep}
	elseif #enemy_creeps ~= 0 and #enemy_heroes == 0 then
		return {35, enemy_creeps[1]}
	end
	return {10, enemy_creeps[1]}
end

local function Farm(bot, creep)
	front = GetLaneFrontAmount(GetTeam(), bot.lane, false)
	enemyfront = GetLaneFrontAmount(GetEnemyTeam(), bot.lane, false)
	front = Min(front, enemyfront)
	dest = GetLocationAlongLane(bot.lane, Min(1.0, front))
	bot.ref:Action_MoveToLocation(dest)
	if creep ~= nil then
		bot.ref:Action_AttackUnit(creep, true)
	end
end


local function RetreatDesire(bot)
	if bot.retreat > GameTime() then
		return {100, 0}
	end

	allied_creeps = bot.ref:GetNearbyLaneCreeps(1600, false)
	enemy_creeps = bot.ref:GetNearbyLaneCreeps(800, false)
	enemy_towers = bot.ref:GetNearbyTowers(1600, true)

	local meatshield_creeps = {}
	if #allied_creeps > 0 and #enemy_towers > 0 then
		-- Search for nearby enemy heroes (Not under enemy towers)
		for i = 1, #allied_creeps do
			for i = 1, #enemy_towers do
				if GetUnitToUnitDistance(allied_creeps[i], enemy_towers[i]) < 700 then
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

	if bot.ref:WasRecentlyDamagedByCreep(1.0) and #enemy_creeps > 1 then
		return {40, DotaTime() + 6}
	end

	if bot.ref:WasRecentlyDamagedByTower(1.0) then
		return {70, DotaTime() + 5}
	end

	if #enemy_towers > 0
		and #meatshield_creeps <= 2
		and GetUnitToUnitDistance(enemy_towers[1], bot.ref) < 850
	then
		return {70, DotaTime() + 5}
	end
	return {0, 0}
end

local function Retreat(bot, retreat_time)
	bot.retreat = retreat_time
	bot.ref:Action_MoveToLocation(ClosestRetreatTower(bot):GetLocation())
end

local function PushDesire(bot)
	local enemy_towers = bot.ref:GetNearbyTowers(1600, true)
	local allied_creeps = bot.ref:GetNearbyLaneCreeps(500, false)
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1600, true)

	-- If help nearby or tower will die in two hits then we want to attack tower
	if #enemy_towers > 0 and #allied_creeps >= 3 and #enemy_creeps <= 2 then
		return {40, enemy_towers[1]}
	end
	if #enemy_towers > 0 and not enemy_towers[1]:IsAttackImmune() 
		and enemy_towers[1]:GetHealth() < bot.ref:GetEstimatedDamageToTarget(true, enemy_towers[1], bot.ref:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) then
		return {60, enemy_towers[1]}
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

	local allied_creeps = bot.ref:GetNearbyLaneCreeps(1000, false)
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1000, true)

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
				end
			end
			if target then
				break
			end
		end
	end

	if not target then
		return {0, nil}
	end

	-- Plus one to count ourself
	local target_hp_percent = (target:GetHealth() / target:GetMaxHealth())
	if #heroes + 1 >= #enemy_heroes 
		and target_hp_percent < 0.33
		and bot.hp_current > target_hp_percent * 1.4
	then
		return {50, target}
	elseif #heroes + 1 == #enemy_heroes and #allied_creeps + 1 >= #enemy_creeps then
		return {30, target}
	elseif #heroes + 1 > #enemy_heroes then
		return {45, target}
	end

	return {0, nil}
end

local function Fight(bot, value)
	bot.ref:Action_AttackUnit(value, true)
end


local function RuneDesire(bot)
	if DotaTime() <= 0.3 then
		return {20, nil}
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
	if closest_rune_dist < 800 then
		return {65, closest_rune}
	elseif closest_rune then
		return {55, closest_rune}
	end
	return {1, nil}
end

local function Rune(bot, rune)
	if rune ~= nil then
		--bot.ref:Action_MoveDirectly(GetRuneSpawnLocation(rune))
		bot.ref:Action_PickUpRune(rune)
		--print("Trying to get bounty rune..")
		return
	end
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
		and not bot.ref:WasRecentlyDamagedByAnyHero(3.0) and not bot.ref:WasRecentlyDamagedByTower(3.0)
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
					end
				end
				if tree then
					break
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
		and not bot.ref:WasRecentlyDamagedByAnyHero(3.0) and not bot.ref:WasRecentlyDamagedByTower(3.0)
		and (bot.mp_max - bot.mp_current > 225)
	then
		return {60, {clarity, bot.ref}}
	end

	local shrines = {
		SHRINE_JUNGLE_1,
		SHRINE_JUNGLE_2
	}
	local team = GetTeam()
	local shrine_dist = 100000
	for i = 1, #shrines do
		local shrine = GetShrine(team, shrines[i])
		local distance = GetUnitToUnitDistance(bot.ref, shrine)
		if shrine:GetHealth() > 0 then
			if (distance < 3000 and not (GetShrineCooldown(shrine) > 1)
				and (bot.mp_max - bot.mp_current > 250 or bot.hp_max - bot.hp_current > 400 or bot.hp_percent < 0.33))
				or (distance < 1000 and IsShrineHealing(shrine))
			then
				return {60, {"shrine", shrine}}
			end
		end
	end

	return {0, nil}
end

local function Heal(bot, params)
	local heal_item, heal_target = unpack(params)
	if heal_item == "shrine" then
		bot.ref:Action_MoveToLocation(heal_target:GetLocation())
		if GetUnitToUnitDistance(bot.ref, heal_target) < 400 then
			print("Using to shrine to restore..")
			bot.ref:Action_UseShrine(heal_target)
		end
		return
	end

	local name = heal_item:GetName()
	if string.find(name, "tango") ~= nil then
		bot.ref:Action_UseAbilityOnTree(heal_item, heal_target)
	elseif name == "item_flask" or name == "item_clarity" then
		bot.ref:Action_UseAbilityOnEntity(heal_item, heal_target)
	end
end

local function ShopDesire(bot)
	local buy_order = generic_buy_order
	if bot.buy_order ~= nil then
		buy_order = bot.buy_order
	end

	if #buy_order == 0 or bot.ref:GetGold() < GetItemCost(buy_order[1]) - 10 then
		return {0, nil}
	end
	local item = buy_order[1]

	local side_shop_pos = nil
	if bot.lane == LANE_TOP then
		side_shop_pos = SIDE_SHOP_TOP
	else
		side_shop_pos = SIDE_SHOP_BOT
	end

	local secret_shop_pos = nil
	if GetUnitToLocationDistance(bot.ref, SECRET_SHOP_RADIANT) < GetUnitToLocationDistance(bot.ref, SECRET_SHOP_DIRE) then
		secret_shop_pos = SECRET_SHOP_RADIANT
	else
		secret_shop_pos = SECRET_SHOP_DIRE
	end

	if IsItemPurchasedFromSideShop(item) and GetUnitToLocationDistance(bot.ref, side_shop_pos) < 3000
		and IsLocationPassable(side_shop_pos)
	then
		return {45, side_shop_pos}
	elseif IsItemPurchasedFromSecretShop(item) and GetUnitToLocationDistance(bot.ref, secret_shop_pos) < 6000
		and IsLocationPassable(secret_shop_pos)
	then
		return {45, secret_shop_pos}
	end

	return {0, nil}
end

local function Shop(bot, shop_pos)
	local buy_order = generic_buy_order
	if bot.buy_order ~= nil then
		buy_order = bot.buy_order
	end
	local item = buy_order[1]
	bot.ref:Action_MoveToLocation(shop_pos)
	if GetUnitToLocationDistance(bot.ref, shop_pos) < SHOP_USE_DISTANCE then
		local buy_res = bot.ref:ActionImmediate_PurchaseItem(item)
		if buy_res == PURCHASE_ITEM_SUCCESS then
			print("Buying: " .. item .. "from shop")
			table.remove(buy_order, 1)
		end
	end
end

generic_desires = {
	["farm"] = {FarmDesire, Farm},
	["retreat"] = {RetreatDesire, Retreat},
	["heal"] = {HealDesire, Heal},
	["shop"] = {ShopDesire, Shop},
	["push"] = {PushDesire, Push},
	["fight"] = {FightDesire, Fight},
	["rune"] = {RuneDesire, Rune},
	["meme"] = {MemeDesire, Meme}
}

function Thonk(bot, desires)
	local desire_best = -1
	local desire_value = nil
	local desire_mode = nil
	local desire_name

	for name, thonkage in pairs(desires) do
		local desire, value = unpack(thonkage[1](bot))
		if desire > desire_best then
			desire_best = desire
			desire_value = value
			desire_mode = thonkage[2]
			desire_name = name
		end
	end
	if desire_name ~= bot.desire then
		print(bot.ref:GetUnitName() .. ": " .. desire_name)
	end
	desire_mode(bot, desire_value)
	bot.desire = desire_name
	UpKeep(bot)
end
