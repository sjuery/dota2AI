require(GetScriptDirectory() .. "../utility")

function RetreatPriority(bot)
	if bot.retreat > GameTime() then
		return {100, bot.retreat}
	end

	local allied_creeps = bot.ref:GetNearbyLaneCreeps(1600, false)
	local enemy_towers = bot.ref:GetNearbyTowers(1600, true)

	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(500, true)
	local allied_heroes = bot.ref:GetNearbyHeroes(500, true, BOT_MODE_NONE)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1000, true, BOT_MODE_NONE)

	local other_creeps = bot.ref:GetNearbyCreeps(800, false)
	for i = 1, #other_creeps do
		table.insert(allied_creeps, other_creeps[i])
	end

	local meatshield_creeps = {}
	if #allied_creeps > 0 and #enemy_towers > 0 then
		-- Search for nearby allied creeps to take tower hits
		for i = 1, #allied_creeps do
			for i = 1, #enemy_towers do
				if GetUnitToUnitDistance(allied_creeps[i], enemy_towers[i]) < 700 then
					table.insert(meatshield_creeps, allied_creeps[i])
				end
			end
		end
	end

	-- Tower not safe
	if bot.ref:WasRecentlyDamagedByTower(1.0) and #enemy_towers > 0
		and GetUnitToUnitDistance(bot.ref, enemy_towers[1]) < 900
	then
		return {70, DotaTime() + 5}
	end

	if #enemy_towers > 0
		and (#meatshield_creeps <= 2)
		and GetUnitToUnitDistance(enemy_towers[1], bot.ref) < 920
	then
		return {60, DotaTime() + 5}
	end

	if #enemy_heroes > #allied_heroes + 1 then
		return {60, DotaTime() + 5}
	end

	-- Low health
	if bot.hp_percent < 0.4 then
		local enemy_heroes_small = bot.ref:GetNearbyHeroes(500, true, BOT_MODE_NONE)
		-- Don't run away if we can probably kill them
		if not (#enemy_heroes_small < #allied_heroes 
			and (GetUnitHealthPercentage(enemy_heroes_small[1]) * 1.1 < bot.hp_percent) 
		then
			if bot.hp_percent < 0.33 then
				return {70, DotaTime() + 10}
			end
			return {55, DotaTime() + 7}
		end
	end

	-- Recently damaged
	if bot.ref:WasRecentlyDamagedByCreep(1.0)
		and bot.hp_percent < 0.9
	then
		return {40, DotaTime() + 6}
	end

	return {0, 0}
end

function Retreat(bot, retreat_time)
	bot.retreat = retreat_time
	bot.ref:Action_MoveToLocation(RetreatLocation(bot))
end