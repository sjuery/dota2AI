require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local desires = DeepCopy(generic_desires)

local buy_order = {
	"item_courier",
	"item_tango",
	"item_tango",
	"item_branches",
	"item_clarity",
	"item_stout_shield",
	"item_quelling_blade",
	"item_ring_of_protection",
	"item_sobi_mask",
	"item_boots",
	"item_energy_booster"
}

SKILL_Q = "omniknight_purification"
SKILL_W = "omniknight_repel"
SKILL_E = "omniknight_degen_aura"
SKILL_R = "omniknight_guardian_angel"

TALENT_1 = "special_bonus_gold_income_15"
TALENT_2 = "special_bonus_unique_omniknight_4"
TALENT_3 = "special_bonus_exp_boost_35"
TALENT_4 = "special_bonus_attack_damage_90"
TALENT_5 = "special_bonus_unique_omniknight_2"
TALENT_6 = "special_bonus_mp_regen_5"
TALENT_7 = "special_bonus_unique_omniknight_1"
TALENT_8 = "special_bonus_unique_omniknight_3"

local ability_order = {
	SKILL_Q, SKILL_E, SKILL_Q, SKILL_W, SKILL_Q,
	SKILL_R, SKILL_Q, SKILL_W, SKILL_W, TALENT_1,
	SKILL_W, SKILL_R, SKILL_E, SKILL_E, TALENT_4,
	SKILL_E, SKILL_R, TALENT_6, TALENT_7
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
