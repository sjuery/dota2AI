require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local priority = DeepCopy(generic_priority)

local buy_order = {
	"item_tango",
	"item_flask",
	"item_tango",
	-- Power Threads
	"item_boots",
	"item_gloves",
	"item_belt_of_strength",
	-- Dragon Lance
	"item_boots_of_elves",
	"item_boots_of_elves",
	"item_ogre_axe",
	-- Morbid Mask
	"item_lifesteal",
	-- Yasha
	"item_boots_of_elves",
	"item_blade_of_alacrity",
	"item_recipe_yasha",
	-- Manta Style
	"item_ultimate_orb",
	"item_recipe_manta",
	-- Crystalys
	"item_blades_of_attack",
	"item_broadsword",
	"item_recipe_lesser_crit",
	-- Daedalus
	"item_demon_edge",
	"item_recipe_greater_crit",
	-- Moonshard - Switch with Aghanim's when we have switching perfectly implemented
	"item_hyperstone",
	"item_hyperstone",
	-- Aghanim's Scepter
	"item_point_booster",
	"item_blade_of_alacrity",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	-- Satanic
	"item_claymore",
	"item_reaver"
}

SKILL_Q = "drow_ranger_frost_arrows"
SKILL_W = "drow_ranger_wave_of_silence"
SKILL_E = "drow_ranger_trueshot"
SKILL_R = "drow_ranger_marksmanship"

TALENT_1 = "special_bonus_movement_speed_20"
TALENT_2 = "special_bonus_all_stats_5"
TALENT_3 = "special_bonus_agility_10"
TALENT_4 = "special_bonus_unique_drow_ranger_2"
TALENT_5 = "special_bonus_evasion_25"
TALENT_6 = "special_bonus_unique_drow_ranger_4"
TALENT_7 = "special_bonus_unique_drow_ranger_1"
TALENT_8 = "special_bonus_cooldown_reduction_50"

local ability_order = {
	SKILL_E, SKILL_Q, SKILL_E, SKILL_Q, SKILL_W,
	SKILL_R, SKILL_E, SKILL_E, SKILL_Q, TALENT_1,
	SKILL_Q, SKILL_R, SKILL_W, SKILL_W, TALENT_3,
	SKILL_W, SKILL_R, TALENT_5, TALENT_8
}

local bot = {
	["ref"] = GetBot(),
	["lane"] = LANE_MID,
	["retreat"] = 0,
	["buy_order"] = buy_order,
	["ability_order"] = ability_order
}

function desireSilence(bot, silence)
	if not silence:IsTrained() or bot.mp_current < silence:GetManaCost()
		or not silence:IsFullyCastable() or bot.ref:IsChanneling() or bot.ref:IsUsingAbility() then
		return false
	end
end

function WaveOfSilence(bot)
	local silence = bot.ref:GetAbilityByName(SKILL_W)

	desireSilence(bot, silence)
end

function Think()
	UpdateBot(bot)
	Thonk(bot, priority)
end
