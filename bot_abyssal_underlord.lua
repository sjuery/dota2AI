require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local g = require(GetScriptDirectory() .. "/global")

local priority = DeepCopy(generic_priority)

local buy_order = {
	"item_tango",
	"item_tango",
	"item_flask",
	"item_stout_shield",
	"item_quelling_blade",
	-- Mage boots
	"item_boots",
	"item_energy_booster",
	-- Vanguard
	"item_ring_of_regen",
	"item_vitality_booster",
	-- Blade mail
	"item_chainmail",
	"item_robe",
	"item_broadsword",
	-- Scepter
	"item_ogre_axe",
	"item_point_booster",
	"item_blade_of_alacrity",
	"item_staff_of_wizardry"
}

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

local ability_order = {
	SKILL_Q, SKILL_W, SKILL_Q, SKILL_E, SKILL_Q,
	SKILL_R, SKILL_Q, SKILL_W, SKILL_W, TALENT_1,
	SKILL_W, SKILL_R, SKILL_E, SKILL_E, TALENT_4,
	SKILL_E, SKILL_R, TALENT_6, TALENT_8
}

local bot = {
	["ref"] = GetBot(),
	["lane"] = GetStartingLane(1),
	["retreat"] = 0,
	["ability_order"] = ability_order,
	["buy_order"] = buy_order
}

table.insert(g, bot)

local function FireStorm(bot)
	local fire_storm = bot.ref:GetAbilityByName(SKILL_Q)

	if bot.ref:IsChanneling() or bot.ref:IsUsingAbility() or fire_storm:GetManaCost() >= bot.mp_current or not fire_storm:IsFullyCastable() then
		return false
	end

	local aoe_heroes = bot.ref:FindAoELocation(true, true, bot.ref:GetLocation(),
		fire_storm:GetCastRange(), 400, fire_storm:GetSpecialValueFloat("delay_plus_castpoint_tooltip"), 0)
	local aoe_minions = bot.ref:FindAoELocation(true, false, bot.ref:GetLocation(),
		fire_storm:GetCastRange(), 400, fire_storm:GetSpecialValueFloat("delay_plus_castpoint_tooltip"), 0)

	if aoe_heroes.count >= 1 and aoe_minions.count > 2 then
		bot.ref:Action_UseAbilityOnLocation(fire_storm, aoe_heroes.targetloc)
		return true
	elseif aoe_heroes.count >= 2 then
		bot.ref:Action_UseAbilityOnLocation(fire_storm, aoe_heroes.targetloc)
		return true
	elseif aoe_minions.count > 3 then
		bot.ref:Action_UseAbilityOnLocation(fire_storm, aoe_minions.targetloc)
		return true
	end

	return false
end

local function PitOfMalice(bot)
	local pit_of_malice = bot.ref:GetAbilityByName(SKILL_W)

	if bot.ref:IsChanneling() or bot.ref:IsUsingAbility() or pit_of_malice:GetManaCost() >= bot.mp_current or not pit_of_malice:IsFullyCastable() then
		return false
	end

	local aoe_heroes = bot.ref:FindAoELocation(true, true, bot.ref:GetLocation(),
		pit_of_malice:GetCastRange(), 375, pit_of_malice:GetSpecialValueFloat("delay_plus_castpoint_tooltip"), 0)
	local aoe_minions = bot.ref:FindAoELocation(true, false, bot.ref:GetLocation(),
		pit_of_malice:GetCastRange(), 375, pit_of_malice:GetSpecialValueFloat("delay_plus_castpoint_tooltip"), 0)

	if aoe_heroes.count > 1 and aoe_minions.count > 2 then
		bot.ref:Action_UseAbilityOnLocation(pit_of_malice, aoe_heroes.targetloc)
		return true
	elseif aoe_heroes.count > 2 then
		bot.ref:Action_UseAbilityOnLocation(pit_of_malice, aoe_heroes.targetloc)
		return true
	elseif aoe_minions.count > 3 then
		bot.ref:Action_UseAbilityOnLocation(pit_of_malice, aoe_minions.targetloc)
		return true
	end

	return false
end

function Think()
	UpdateBot(bot)
	Thonk(bot, priority)
	if FireStorm(bot) or PitOfMalice(bot) then
		return
	end
end
