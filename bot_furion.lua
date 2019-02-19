require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local desires = DeepCopy(generic_desires)

SKILL_Q = "furion_sprout"
SKILL_W = "furion_teleportation"
SKILL_E = "furion_force_of_nature"
SKILL_R = "furion_wrath_of_nature"

TALENT_1 = "special_bonus_attack_damage_30"
TALENT_2 = "special_bonus_movement_speed_25"
TALENT_3 = "special_bonus_armor_10"
TALENT_4 = "special_bonus_unique_furion_2"
TALENT_5 = "special_bonus_attack_speed_40"
TALENT_6 = "special_bonus_cooldown_reduction_25"
TALENT_7 = "special_bonus_unique_furion_3"
TALENT_8 = "special_bonus_unique_furion"

local ability_order = {
	SKILL_E, SKILL_W, SKILL_E, SKILL_Q, SKILL_E,
	SKILL_R, SKILL_E, SKILL_W, SKILL_W, TALENT_1,
	SKILL_W, SKILL_R, SKILL_Q, SKILL_Q, TALENT_4,
	SKILL_Q, SKILL_R, TALENT_5, TALENT_7
}

local bot = {
	["ref"] = GetBot(),
	["lane"] = GetStartingLane(1),
	["retreat"] = 0,
	["ability_order"] = ability_order
}

function Think()
	UpdateBot(bot)
	Thonk(bot, desires)
end
