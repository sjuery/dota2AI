require(GetScriptDirectory() .. "../utility")

function PushPriority(bot)
	local enemy_towers = bot.ref:GetNearbyTowers(1600, true)
	local allied_creeps = bot.ref:GetNearbyLaneCreeps(500, false)
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1600, true)
	local enemy_barracks = bot.ref:GetNearbyBarracks(1600, true)

	if (#enemy_towers == 0 and #enemy_barracks == 0)
		or (#enemy_towers > 0 and enemy_towers[1]:HasModifier("modifier_fountain_glyph"))
		or (#enemy_barracks > 0 and enemy_barracks[1]:HasModifier("modifier_fountain_glyph"))
	then
		return {0, nil}
	end

	if #enemy_towers > 0 and #allied_creeps - #enemy_creeps >= 2 then
		return {40, enemy_towers[1]}
	end
	if #enemy_towers > 0
		and enemy_towers[1]:GetHealth() < bot.ref:GetEstimatedDamageToTarget(true, enemy_towers[1], bot.ref:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL)
	then
		return {65, enemy_towers[1]}
	end
	if #enemy_towers == 0 and #enemy_barracks > 0 then
		return {50, enemy_barracks[1]}
	end
	return {10, enemy_towers[1]}
end

function Push(bot, enemy_tower)
	front = GetLaneFrontAmount(GetTeam(), bot.lane, false)
	enemyfront = GetLaneFrontAmount(GetEnemyTeam(), bot.lane, false)
	front = Min(front, enemyfront)
	dest = GetLocationAlongLane(bot.lane, Min(1.0, front))
	bot.ref:Action_MoveToLocation(dest)
	if enemy_tower ~= nil then
		bot.ref:Action_AttackUnit(enemy_tower, true)
	end
end