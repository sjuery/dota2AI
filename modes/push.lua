require(GetScriptDirectory() .. "../utility")

function PushPriority(bot)
	local enemy_towers = GetNearbyVisibleTowers(bot, 1600, true)
	local allied_creeps = bot.ref:GetNearbyLaneCreeps(500, false)
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1600, true)
	local enemy_barracks = GetNearbyVisibleBarracks(bot, 1600, true)
	local base = GetAncient(GetEnemyTeam())

	if (#enemy_towers == 0 and #enemy_barracks == 0)
		or (#enemy_towers > 0 and enemy_towers[1]:HasModifier("modifier_fountain_glyph"))
		or (#enemy_barracks > 0 and enemy_barracks[1]:HasModifier("modifier_fountain_glyph"))
		or base:HasModifier("modifier_fountain_glyph")
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

	if not base:IsAttackImmune() and GetUnitToUnitDistance(bot.ref, base) < 1600 then
		return {50, base}
	end

	return {0, nil}
end

function Push(bot, enemy_tower)
	if GetUnitToUnitDistance(bot.ref, enemy_tower) > bot.ref:GetBoundingRadius() + bot.ref:GetAttackRange() then
		bot.ref:Action_MoveToUnit(enemy_tower)
	end
	bot.ref:Action_AttackUnit(enemy_tower, true)
end
