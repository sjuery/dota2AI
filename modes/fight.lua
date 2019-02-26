require(GetScriptDirectory() .. "../utility")

function FightPriority(bot)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	local heroes = bot.ref:GetNearbyHeroes(600, false, BOT_MODE_NONE)

	local allied_creeps = bot.ref:GetNearbyLaneCreeps(1000, false)
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1000, true)

	local targets = {}
	if #enemy_heroes > 0 then
		local towers = GetNearbyVisibleTowers(bot, 1600, true)

		-- Search for nearby enemy heroes (Not under enemy towers)
		for i = 1, #enemy_heroes do
			local pos = enemy_heroes[i]:GetLocation()
			if IsLocationVisible(pos) or IsLocationPassable(pos) then
				for i = 1, #towers do
					if GetDistance(pos, towers[i]:GetLocation()) > 900
						or (enemy_heroes[i]:GetHealth() < 0.15
							and bot.ref:GetEstimatedDamageToTarget(true, bot.ref, 4, DAMAGE_TYPE_PHYSICAL) > bot.hp_current)
						or GetUnitToLocationDistance(bot.ref, pos) < bot.ref:GetAttackRange()
					then
						table.insert(targets, enemy_heroes[i])
					end
				end
				if #towers == 0 then
					table.insert(targets, enemy_heroes[i])
				end
			end
		end
	end

	if #targets == 0 then
		return {0, nil}
	end

	local target = targets[1]

	-- Find weakest target in range
	for i = 1, #targets do
		if GetUnitToUnitDistance(bot.ref, targets[i]) < bot.ref:GetAttackRange()
			and targets[i]:GetHealth() < target:GetHealth()
		then
			target = targets[i]
		end
	end

	local target_hp_percent = GetUnitHealthPercentage(target)
	if target_hp_percent < 0.2 then
		return {60, target}
	elseif #heroes + 1 >= #enemy_heroes 
		and target_hp_percent < 0.33
		and bot.hp_current >= target_hp_percent * 1.2
	then
		return {50, target}
	elseif #heroes + 1 == #enemy_heroes and #allied_creeps + 1 >= #enemy_creeps then
		return {30, target}
	elseif #heroes + 1 > #enemy_heroes then
		return {55, target}
	end

	return {0, target}
end

-- local enemy_modifiers = {
-- 	["modifier_flask_healing"] = 15,
-- 	["modifier_clarity_potion"] = 15,
-- 	["modifier_stunned"] = 15,
-- 	["modifier_item_blade_mail_reflect"] = -40,
-- 	["modifier_bashed"] = 5,
-- 	["modifier_rooted"] = 5
--  ["modifier_silence"] = 10
--	["modifier_tower_armor_bonus"] = -10
-- }

-- local allie_modifers = {
-- 	["modifier_flask_healing"] = -10,
-- 	["modifier_clarity_potion"] = -10,
-- 	["luna_lunar_blessing"] = 5,
-- 	["modifier_luna_lunar_blessing_aura"] = 5,
-- 	["modifier_omniknight_repel"] = 5,
-- 	["modifier_luna_eclipse"] = 15,
-- 	["modifier_omninight_guardian_angel"] = 15,
-- 	["modifier_item_blade_mail_reflect"] = 10,
-- 	["modifier_rune_regen"] = 5,
-- 	["modifier_rune_doubledamage"] = 15,
-- 	["modifier_rune_arcane"] = 5,
--  ["modifier_silence"] = -10,
--  ["modifier_rooted"] = 5,
-- }

-- function FightPriority(bot)
-- 	local enemy_heroes = bot.ref:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
-- 	local allied_heroes = bot.ref:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

-- 	bot.target = target
-- end

function Fight(bot, enemy)
	AttackUnit(bot, enemy)
end
