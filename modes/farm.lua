require(GetScriptDirectory() .. "../utility")

function FarmPriority(bot)
	local allied_creeps = bot.ref:GetNearbyLaneCreeps(1600, false)
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1600, true)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1000, true, BOT_MODE_NONE)

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

function Farm(bot, creep)
	front = GetLaneFrontAmount(GetTeam(), bot.lane, false)
	enemyfront = GetLaneFrontAmount(GetEnemyTeam(), bot.lane, false)
	front = Min(front, enemyfront)
	dest = GetLocationAlongLane(bot.lane, Min(1.0, front))
	bot.ref:Action_MoveToLocation(dest)
	if creep ~= nil then
		bot.ref:Action_AttackUnit(creep, true)
	end
end