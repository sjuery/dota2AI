require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local desires = DeepCopy(generic_desires)

SKILL_Q = "terrorblade_reflection"
SKILL_W = "terrorblade_conjure_image"
SKILL_E = "terrorblade_metamorphosis"
SKILL_R = "terrorblade_sunder"

TALENT_1 = "special_bonus_movement_speed_20"
TALENT_2 = "special_bonus_evasion_10"
TALENT_3 = "special_bonus_hp_250"
TALENT_4 = "special_bonus_attack_speed_25"
TALENT_5 = "special_bonus_all_stats_10"
TALENT_6 = "special_bonus_unique_terrorblade_2"
TALENT_7 = "special_bonus_unique_terrorblade"
TALENT_8 = "special_bonus_unique_terrorblade_3"

local abilityPriority = {
	SKILL_E, SKILL_Q, SKILL_W, SKILL_Q, SKILL_Q, SKILL_R, SKILL_Q, SKILL_E, SKILL_E, TALENT_2, SKILL_E, SKILL_R, SKILL_W, SKILL_W, TALENT_4, SKILL_W, SKILL_R, TALENT_6, TALENT_7
}

local bot = {
	["ref"] = GetBot(),
	["lane"] = GetStartingLane(0),
	["retreat"] = 0
}

function UpgradeAbility(bot)
	while bot.ref:GetAbilityPoints() > 0 do
		local ability = bot.ref:GetAbilityByName(abilityPriority[1])

		if (ability:CanAbilityBeUpgraded() and ability:GetLevel() < ability:GetMaxLevel()) then
			bot.ref:ActionImmediate_LevelAbility(abilityPriority[1])
			table.remove(abilityPriority, 1)
		end
	end
end

function Think()
	print(bot.lane)
	UpgradeAbility(bot)
	UpdateBot(bot)
	Thonk(bot, desires)
end
