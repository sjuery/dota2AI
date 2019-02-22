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

SKILL_Q = "luna_lucent_beam"
SKILL_W = "luna_moon_glaive"
SKILL_E = "luna_lunar_blessing"
SKILL_R = "luna_eclipse"

TALENT_1 = "special_bonus_attack_speed_15"
TALENT_2 = "special_bonus_cast_range_300"
TALENT_3 = "special_bonus_unique_luna_2"
TALENT_4 = "special_bonus_movement_speed_30"
TALENT_5 = "special_bonus_all_stats_8"
TALENT_6 = "special_bonus_unique_luna_1"
TALENT_7 = "special_bonus_lifesteal_25"
TALENT_8 = "special_bonus_unique_luna_5"

local ability_order = {
	SKILL_E, SKILL_Q, SKILL_Q, SKILL_W, SKILL_Q,
	SKILL_R, SKILL_Q, SKILL_W, SKILL_W, SKILL_W,
	TALENT_1, SKILL_R, SKILL_E, SKILL_E, SKILL_E,
	TALENT_4, SKILL_R, TALENT_5, TALENT_7
}

local bot = {
	["ref"] = GetBot(),
	["lane"] = GetStartingLane(0),
	["retreat"] = 0,
	["buy_order"] = buy_order,
	["ability_order"] = ability_order
}

function Think()
	UpdateBot(bot)
	Thonk(bot, desires)
end