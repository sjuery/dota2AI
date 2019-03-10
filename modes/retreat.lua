require(GetScriptDirectory() .. "../utility")

function RetreatPriority(bot)
	if (bot.ref:HasModifier("modifier_fountain_aura") or bot.ref:HasModifier("modifier_fountain_aura_buff")) then
		bot.retreat = 0
	end

	local allied_creeps = bot.ref:GetNearbyLaneCreeps(1600, false)
	local enemy_towers = GetNearbyVisibleTowers(bot, 1600, true)

	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(500, true)
	local allied_heroes = bot.ref:GetNearbyHeroes(1400, true, BOT_MODE_NONE)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1400, true, BOT_MODE_NONE)

	if bot.retreat > GameTime() then
		-- Stop retreat if we are safe and were able to heal
		if #enemy_heroes == 0 and #enemy_creeps == 0 and #enemy_towers == 0 then
			return 15, bot.retreat
		end
		return 55, bot.retreat
	end

	local other_creeps = bot.ref:GetNearbyCreeps(1600, false)
	for i = 1, #other_creeps do
		table.insert(allied_creeps, other_creeps[i])
	end

	local meatshield_creeps = {}
	if #allied_creeps > 0 and #enemy_towers > 0 then
		-- Search for nearby allied creeps to take tower hits
		for i = 1, #allied_creeps do
			for i = 1, #enemy_towers do
				if GetUnitToUnitDistance(allied_creeps[i], enemy_towers[i]) < 900 then
					table.insert(meatshield_creeps, allied_creeps[i])
				end
			end
		end
	end

	-- Tower not safe
	if bot.ref:WasRecentlyDamagedByTower(1.0) and #enemy_towers > 0
		and GetUnitToUnitDistance(bot.ref, enemy_towers[1]) < 950
	then
		return 70, DotaTime() + 3
	end

	if #enemy_towers > 0
		and (#meatshield_creeps <= 2)
		and GetUnitToUnitDistance(enemy_towers[1], bot.ref) < 950
	then
		return 60, DotaTime() + 1
	end

	if #enemy_heroes > #allied_heroes + 1 then
		return 80, DotaTime() + 5
	end

	-- Low health
	if bot.hp_percent < 0.4 then
		if bot.hp_percent < 0.33 then
			return 70, DotaTime() + 100
		end
		return 55, DotaTime() + 7
	end

	-- Recently damaged
	if bot.ref:WasRecentlyDamagedByCreep(1.0)
		and bot.hp_percent < 0.9
	then
		return 40, DotaTime() + 1
	end

	return 0, 0
end

-- local enemies = bot.ref.GetNearbyEnemies(bot, 1200)
-- local allies  = bot.ref.GetNearbyAllies(bot, 1200)

-- local enemyDamage = 0
-- for _, enemy in pairs(enemies) do
-- 	if GetUnitHealthPercentage(enemy) > 0.25 then
-- 		local damage = enemy:GetEstimatedDamageToTarget(true, bot, MaxStun, DAMAGE_TYPE_ALL)
-- 		enemyDamage = enemyDamage + damage
-- 	end
-- end

-- if enemyDamage / #allies > bot:GetHealth() then
-- 	if #allies == 1 and bot.hp_percent > 0.6 then
-- 		--print("What to do... I'm almost at full health but can die to enemy burst!")
-- 	else
-- 		if bot.hp_percent < 0.5 then
-- 			bot.IsRetreating = true
-- 		end
-- 	end

-- 	return 0.9
-- end

-- if bot.hp_percent > 0.9 and bot.mp_percent > 0.9 then
-- 	bot.IsRetreating = false
-- 	return 0
-- end

-- if bot:DistanceFromFountain() > 6000
-- 	and (bot.hp_percent > 0.65 and bot.mp_percent > 0.6)
-- 	or (bot.hp_percent > 0.8 and bot.mp_percent > 0.36)
-- then
-- 	bot.IsRetreating = false
-- 	return 0
-- end

-- if bot.IsRetreating then
-- 	return 0.7
-- end

-- if bot.hp_percent < 0.25 and bot:GetHealthRegen() < 7.9 or 
-- 	(bot.mp_percent < 0.07 and bot.priority_name == "farming" and
-- 	bot:GetManaRegen() < 6.0
-- then
-- 	bot.IsRetreating = true
-- 	return 0.7
-- end
   
-- return 0, nil

function Retreat(bot, retreat_time)
	bot.retreat = retreat_time
	bot.ref:Action_MoveToLocation(RetreatLocation(bot))
end
