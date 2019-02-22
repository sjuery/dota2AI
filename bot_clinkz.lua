require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local desires = DeepCopy(generic_desires)

local buy_order = {
	"item_tango",
	"item_flask",
	"item_quelling_blade",
	"item_tango",
	"item_boots",
	"item_ring_of_regen",
	"item_wind_lace"
	-- Hammer time
}

SKILL_Q = "clinkz_strafe"
SKILL_W = "clinkz_searing_arrows"
SKILL_E = "clinkz_wind_walk"
SKILL_R = "clinkz_burning_army"

TALENT_1 = "special_bonus_magic_resistance_12"
TALENT_2 = "special_bonus_armor_5"
TALENT_3 = "special_bonus_strength_15"
TALENT_4 = "special_bonus_unique_clinkz_1"
TALENT_5 = "special_bonus_attack_range_125"
TALENT_6 = "special_bonus_hp_regen_16"
TALENT_7 = "special_bonus_unique_clinkz_2"
TALENT_8 = "special_bonus_unique_clinkz_3"

local ability_order = {
	SKILL_W, SKILL_Q, SKILL_W, SKILL_Q, SKILL_Q,
	SKILL_R, SKILL_Q, SKILL_E, SKILL_W, SKILL_W,
	SKILL_E, SKILL_R, SKILL_E, TALENT_2, TALENT_4,
	SKILL_E, SKILL_R, TALENT_5, TALENT_8
}

local bot = {
	["ref"] = GetBot(),
	["lane"] = LANE_MID,
	["retreat"] = 0,
	["buy_order"] = buy_order,
	["ability_order"] = ability_order
}

function Think()
	UpdateBot(bot)
	Thonk(bot, desires)
end