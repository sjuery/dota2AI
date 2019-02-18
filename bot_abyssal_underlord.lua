require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local desires = DeepCopy(generic_desires)

SKILL_Q = "abyssal_underlord_firestorm"
SKILL_W = "abyssal_underlord_pit_of_malice"
SKILL_E = "abyssal_underlord_atrophy_aura"
SKILL_R = "abyssal_underlord_dark_rift"

TALENT_1 = "special_bonus_unique_underlord_2"
TALENT_2 = "special_bonus_movement_speed_25"
TALENT_3 = "special_bonus_cast_range_100"
TALENT_4 = "special_bonus_unique_underlord_3"
TALENT_5 = "special_bonus_attack_speed_70"
TALENT_6 = "special_bonus_hp_regen_25"
TALENT_7 = "special_bonus_unique_underlord"
TALENT_8 = "special_bonus_unique_underlord_4"

local abilityPriority = {
	SKILL_Q, SKILL_E, SKILL_Q, SKILL_W, SKILL_Q, SKILL_R, SKILL_Q, SKILL_W, SKILL_W, TALENT_1, SKILL_W, SKILL_R, SKILL_E, SKILL_E, TALENT_4, SKILL_E, SKILL_R, TALENT_6, TALENT_8
}

local bot = {
	["ref"] = GetBot(),
	["lane"] = GetStartingLane(1),
	["retreat"] = 0
}

function UpgradeAbility(bot)
	while bot.ref:GetAbilityPoints() > 0 do
		local ability = bot.ref:GetAbilityByName(abilityPriority[1])
		print("Upgrading")
		if (ability:CanAbilityBeUpgraded() and ability:GetLevel() < ability:GetMaxLevel()) then
			bot.ref:ActionImmediate_LevelAbility(abilityPriority[1])
			table.remove(abilityPriority, 1)
		end
	end
end

function Think()
	UpgradeAbility(bot)
	UpdateBot(bot)
	Thonk(bot, desires)
end
