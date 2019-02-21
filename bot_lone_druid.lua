require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local desires = DeepCopy(generic_desires)

local bear_items = {
	"item_stout_shield",
	"item_boots",
	"item_orb_of_venom",
	"item_blight_stone"
}

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
	["buy_order"] = buy_order,
	["ability_order"] = ability_order
}

local bear = {
	["ref"] = GetBot(),
	["lane"] = LANE_MID,
	["retreat"] = 0,
	["ability_order"] = ability_order
}

function desireQ(bot)
	local abilityQ = bot.ref:GetAbilityByName(SKILL_Q)

	if bot.ref:IsChanneling() or bot.ref:IsUsingAbility() or abilityQ:GetManaCost() >= bot.mp_current or abilityQ:IsCooldownReady() == false then
		return
	end
	bot.ref:Action_UseAbility(abilityQ)
end

function Think()
	UpdateBot(bot)
	Thonk(bot, desires)
	desireQ(bot)
end

function MinionThink(hMinionUnit)
	print("Tonking")
	-- hMinionUnit:Action_MoveToLocation(bot.ref:GetLocation())
	bear.ref = hMinionUnit
	print(bear.ref)
	UpdateBot(bear)
	Thonk(bear, desires)
end