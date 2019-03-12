require(GetScriptDirectory() .. "../utility")

function PushPriority(bot)
	local enemy_towers = GetNearbyVisibleTowers(bot, 1600, true)
	local allied_creeps = bot.ref:GetNearbyLaneCreeps(800, false)
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1600, true)
	local enemy_barracks = GetNearbyVisibleBarracks(bot, 1600, true)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local base = GetAncient(GetOpposingTeam())

	if (#enemy_towers == 0 and #enemy_barracks == 0)
		or (#enemy_towers > 0 and enemy_towers[1]:HasModifier("modifier_fountain_glyph"))
		or (#enemy_barracks > 0 and enemy_barracks[1]:HasModifier("modifier_fountain_glyph"))
		or base:HasModifier("modifier_fountain_glyph")
	then
		return 0, nil
	end

	local other_creeps = bot.ref:GetNearbyCreeps(800, false)
	for i = 1, #other_creeps do
		table.insert(allied_creeps, other_creeps[i])
	end

	if #enemy_towers > 0 and #allied_creeps >= 2 and #enemy_heroes == 0 then
		return 40, enemy_towers[1]
	end

	if #enemy_towers > 0
		and enemy_towers[1]:GetHealth() < bot.ref:GetEstimatedDamageToTarget(true, enemy_towers[1], bot.ref:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL)
	then
		return 65, enemy_towers[1]
	end
	if #enemy_towers == 0 and #enemy_barracks > 0 then
		return 40, enemy_barracks[1]
	end

	if not base:IsAttackImmune() and GetUnitToUnitDistance(bot.ref, base) < 1600 then
		return 50, base
	end

	return 0, nil
end

function Push(bot, enemy_building)
	if DeAggroTower(bot) then
		return
	end
	AttackBuilding(bot, enemy_building)
end
