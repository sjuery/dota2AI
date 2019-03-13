require(GetScriptDirectory() .. "../utility")

local enemy_modifiers = {
	["modifier_flask_healing"] = 25,
	["modifier_clarity_potion"] = 25,
	["modifier_stunned"] = 15,
	["modifier_item_blade_mail_reflect"] = -20,
	["modifier_bashed"] = 5,
	["modifier_rooted"] = 20,
	["modifier_silence"] = 10,
	["modifier_tower_armor_bonus"] = -20,
	["modifier_drow_ranger_frost_arrows_slow"] = 5,
	["modifier_orchid_malevolence_debuff"] = 25,
	["modifier_abyssal_underlord_firestorm_burn"] = 5,
	["modifier_abaddon_borrowed_time"] = -20
}

local ally_modifers = {
	["modifier_flask_healing"] = -10,
	["modifier_clarity_potion"] = -10,
	["modifier_omniknight_repel"] = 5,
	["modifier_luna_eclipse"] = 15,
	["modifier_omninight_guardian_angel"] = 15,
	["modifier_item_blade_mail_reflect"] = 10,
	["modifier_rune_doubledamage"] = 30,
	["modifier_rune_arcane"] = 5,
	["modifier_silence"] = -10,
	["modifier_manta_phase"] = 20,
	["modifier_manta"] = 20
}

local function TargetValue(bot, enemy)
	local value = 0

	local modifiers = enemy:GetModifierList()
	if modifiers then
		for i = 1, #modifiers do
			if enemy_modifiers[modifiers[i]] then
				value = value + enemy_modifiers[modifiers[i]]
			end
		end
		value = Clamp(value, -40, 40)
	end

	if (GetUnitToUnitDistance(bot.ref, enemy) - enemy:GetBoundingRadius()) < bot.range then
		value = value + 11
	end

	local enemy_level = GetHeroLevel(enemy:GetPlayerID())
	if bot.level > enemy_level then
		value = value + (bot.level - enemy_level) * 13
	end

	local hp = GetUnitHealthPercentage(enemy)
	if hp < 0.1 then
		value = value + 40
	elseif hp < 0.33 then
		value = value + 30
	elseif hp < 0.5 then
		value = value + 20
	elseif hp < 0.75 then
		value = value + 10
	end

	return value
end

local function CompareTargets(a, b)
	return a[1] > b[1]
end

function FightPriority(bot)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local allied_heroes = bot.ref:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

	if #enemy_heroes == 0 then
		return 0, nil
	end

	local value = 0
	local modifiers = bot.ref:GetModifierList()
	for i = 1, #modifiers do
		if ally_modifers[modifiers[i]] then
			value = value + ally_modifers[modifiers[i]]
		end
	end
	if bot.hp_percent < 0.33 then
		value = value - 10
	elseif bot.hp_percent < 0.5 then
		value = value - 5
	end
	value = Clamp(value, -40, 40)

	local targets = {}
	for i = 1, #enemy_heroes do
		if #enemy_heroes[i] ~= nil then
			table.insert(targets, {value + TargetValue(bot, enemy_heroes[i]), enemy_heroes[i]})
		end
	end
	table.sort(targets, CompareTargets)

	if #targets ~= 0 then
		--print(bot.name .. "best_target: " .. targets[1][1])
		return targets[1][1], targets[1][2]
	end

	return 0, nil
end

function Fight(bot, enemies)
	AttackUnit(bot, enemies)
end
