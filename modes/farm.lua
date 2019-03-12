require(GetScriptDirectory() .. "../utility")

function FarmPriority(bot)
	local allied_creeps = bot.ref:GetNearbyLaneCreeps(1600, false)
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1600, true)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1000, true, BOT_MODE_NONE)

	if #allied_creeps == 0 and #enemy_creeps == 0 then
		return 10, nil
	end

	local weakest_friendly_creep = nil
	local lowest_friendly_hp = 10000000
	for i = 1, #allied_creeps do
		local hp = allied_creeps[i]:GetHealth()
		if hp > 0 and hp < lowest_friendly_hp then
			weakest_friendly_creep = allied_creeps[i]
			lowest_friendly_hp = hp
		end
	end

	local weakest_enemy_creep = nil
	local lowest_enemy_hp = 10000000
	for i = 1, #enemy_creeps do
		local hp = enemy_creeps[i]:GetHealth()
		if hp > 0 and hp < lowest_enemy_hp then
			weakest_enemy_creep = enemy_creeps[i]
			lowest_enemy_hp = hp
		end
	end

	if #enemy_creeps ~= 0
		and lowest_enemy_hp < bot.ref:GetEstimatedDamageToTarget(true, weakest_enemy_creep, bot.ref:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) - 5
		and bot.role ~= "support"
	then
		return 50, weakest_enemy_creep
	elseif #allied_creeps ~= 0
		and lowest_friendly_hp < bot.ref:GetEstimatedDamageToTarget(true, weakest_friendly_creep, bot.ref:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) - 5
	then
		return 35, weakest_friendly_creep
	elseif #enemy_creeps ~= 0 and #enemy_heroes == 0 and bot.level >= 4 then
		return 30, enemy_creeps[1]
	end

	-- Move towards the front of the lane

	return 10, nil
end

function Farm(bot, creep)
	front = GetLaneFrontAmount(GetTeam(), bot.lane, false)
	enemyfront = GetLaneFrontAmount(GetOpposingTeam(), bot.lane, false)
	front = Min(front, enemyfront)
	dest = GetLocationAlongLane(bot.lane, Min(1.0, front))

	local enemy_towers = GetNearbyVisibleTowers(bot, 1200, true)
	if #enemy_towers > 0 then
		local dist = GetUnitToUnitDistance(bot.ref, enemy_towers[1])
		if dist < 900 then
			away_from_tower = Normalize(bot.location - enemy_towers[1]:GetLocation()) * (900 - dist)
			bot.ref:Action_MoveToLocation(bot.location + away_from_tower)
			return
		end
	end

	if creep == nil then
		bot.dest = dest
		bot.ref:Action_MoveToLocation(dest)
	else
		AttackUnit(bot, creep, true)
	end
end
