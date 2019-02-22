require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local desires = DeepCopy(generic_desires)

local buy_order = {
	"item_tango",
	"item_tango",
	"item_tango",
	"item_flask",
	"item_stout_shield",
	"item_quelling_blade",
	-- Wraith band
	"item_circlet",
	"item_slippers",
	"item_recipe_wraith_band",
	-- Power Treads
	"item_boots",
	"item_boots_of_elves",
	"item_gloves",
	-- Dragon lance
	"item_boots_of_elves",
	"item_boots_of_elves",
	"item_ogre_axe",
	-- Yasha
	"item_boots_of_elves",
	"item_blade_of_alacrity",
	"item_recipe_yasha",
	-- Manta Style
	"item_ultimate_orb",
	"item_recipe_manta",
	-- Moonshard
	"item_hyperstone",
	"item_hyperstone"
}

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

local ability_order = {
	SKILL_E, SKILL_Q, SKILL_W, SKILL_Q, SKILL_Q,
	SKILL_R, SKILL_Q, SKILL_E, SKILL_E, TALENT_2,
	SKILL_E, SKILL_R, SKILL_W, SKILL_W, TALENT_4,
	SKILL_W, SKILL_R, TALENT_6, TALENT_7
}

local bot = {
	["ref"] = GetBot(),
	["lane"] = GetStartingLane(0),
	["retreat"] = 0,
	["buy_order"] = buy_order,
	["ability_order"] = ability_order
}

function desireQ(bot)
	local abilityQ = bot.ref:GetAbilityByName(SKILL_Q)
	local enemy_heroes = bot.ref:GetNearbyHeroes(900, true, BOT_MODE_NONE)

	if bot.ref:IsChanneling() or bot.ref:IsUsingAbility() or abilityQ:GetManaCost() >= bot.mp_current or #enemy_heroes == 0 or abilityQ:IsFullyCastable() == false then
		return
	end
	bot.ref:Action_UseAbility(abilityQ)
end

function Think()
	UpdateBot(bot)
	Thonk(bot, desires)
	desireQ(bot)
end
