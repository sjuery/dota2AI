require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local desires = DeepCopy(generic_desires)

SKILL_Q = "lone_druid_spirit_bear"
SKILL_W = "lone_druid_spirit_link"
SKILL_E = "lone_druid_savage_roar"
SKILL_R = "lone_druid_true_form"

TALENT_1 = "special_bonus_hp_250"
TALENT_2 = "special_bonus_attack_range_125"
TALENT_3 = "special_bonus_unique_lone_druid_4"
TALENT_4 = "special_bonus_unique_lone_druid_2"
TALENT_5 = "special_bonus_unique_lone_druid_8"
TALENT_6 = "special_bonus_unique_lone_druid_9"
TALENT_7 = "special_bonus_unique_lone_druid_10"
TALENT_8 = "special_bonus_unique_lone_druid_7"

local ability_order = {
	SKILL_Q, SKILL_W, SKILL_Q, SKILL_W, SKILL_Q,
	SKILL_W, SKILL_Q, SKILL_W, SKILL_E, TALENT_1,
	SKILL_E, SKILL_E, SKILL_E, SKILL_R, TALENT_4,
	SKILL_R, SKILL_R, TALENT_6, TALENT_8
}

local bot = {
	["ref"] = GetBot(),
	["lane"] = LANE_MID,
	["retreat"] = 0,
	["ability_order"] = ability_order
}

function Think()
	UpdateBot(bot)
	Thonk(bot, desires)
end
