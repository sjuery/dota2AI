require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local g = require(GetScriptDirectory() .. "/global")

local priority = DeepCopy(generic_priority)

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
	-- Blade mail
	"item_chainmail",
	"item_robe",
	"item_broadsword",
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

table.insert(g, bot)

local function SummonImage()
	local summon_image = bot.ref:GetAbilityByName(SKILL_W)
	if not summon_image:IsTrained() or bot.ref:IsChanneling() or bot.ref:IsUsingAbility() or summon_image:GetManaCost() >= bot.mp_current 
		or not summon_image:IsFullyCastable()
	then
		return false
	end

	bot.ref:Action_UseAbility(summon_image)
	return true
end

local function SummonReflection(bot)
	local summon_reflection = bot.ref:GetAbilityByName(SKILL_Q)
	local enemy_heroes = bot.ref:GetNearbyHeroes(900, true, BOT_MODE_NONE)

	if not summon_reflection:IsTrained() or bot.ref:IsChanneling() or bot.ref:IsUsingAbility() or summon_reflection:GetManaCost() >= bot.mp_current
		or #enemy_heroes >= 2 or not summon_reflection:IsFullyCastable()
	then
		return false
	end

	bot.ref:Action_UseAbility(summon_reflection)
	return true
end

local function Metamorphosis(bot, enemy)
	local metamorphosis = bot.ref:GetAbilityByName(SKILL_E)
	if not metamorphosis:IsTrained() or bot.ref:IsChanneling() or bot.ref:IsUsingAbility() or metamorphosis:GetManaCost() >= bot.mp_current
		or not metamorphosis:IsFullyCastable()
	then
		return false
	end

	if GetUnitHealthPercentage(enemy) < 0.5 then
		bot.ref:Action_UseAbility(metamorphosis)
		return true
	end

	return false
end

local function CustomFight(bot, enemies)
	if SummonReflection(bot) or SummonImage(bot) or Metamorphosis(bot, enemies) then
		return
	end
	AttackUnit(bot, enemies)
end

priority["fight"][2] = CustomFight

function Think()
	UpdateBot(bot)
	Thonk(bot, priority)
end
