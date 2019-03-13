require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local g = require(GetScriptDirectory() .. "/global")

local priority = DeepCopy(generic_priority)

local buy_order = {
	"item_tango",
	"item_tango",
	"item_flask",
	"item_clarity",
	"item_stout_shield",
	-- Mage boots
	"item_boots",
	"item_energy_booster",
	-- Vanguard
	"item_ring_of_health",
	"item_vitality_booster",
	-- Vladmir's Offering
	"item_sobi_mask",
	"item_ring_of_protection",
	"item_lifesteal",
	"item_recipe_vladmir",
	-- Ring of Basilius
	"item_sobi_mask",
	"item_ring_of_protection",
	-- Scepter
	"item_ogre_axe",
	"item_point_booster",
	"item_blade_of_alacrity",
	"item_staff_of_wizardry",
	-- Crimson Guard
	"item_buckler",
	"item_recipe_crimson_guard"
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
	SKILL_Q, SKILL_E, SKILL_Q, SKILL_W, SKILL_Q,
	SKILL_R, SKILL_Q, SKILL_W, SKILL_W, TALENT_1,
	SKILL_W, SKILL_R, SKILL_E, SKILL_E, TALENT_4,
	SKILL_E, SKILL_R, TALENT_5, TALENT_8
}

local bot = {
	["ref"] = GetBot(),
	["lane"] = GetStartingLane(1),
	["retreat"] = 0,
	["ability_order"] = ability_order,
	["buy_order"] = buy_order
}

table.insert(g, bot)

local function FireStorm(bot, enemy)
	local fire_storm = bot.ref:GetAbilityByName(SKILL_Q)

	if not CanCast(bot, fire_storm) then
		return false
	end

	local aoe_heroes = bot.ref:FindAoELocation(true, true, bot.ref:GetLocation(),
		fire_storm:GetCastRange(), 400, fire_storm:GetSpecialValueFloat("delay_plus_castpoint_tooltip"), 0)
	local aoe_minions = bot.ref:FindAoELocation(true, false, bot.ref:GetLocation(),
		fire_storm:GetCastRange(), 400, fire_storm:GetSpecialValueFloat("delay_plus_castpoint_tooltip") + 0.5, 0)

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

	if enemy ~= nil and GetUnitHealthPercentage(enemy) < 0.3 and enemy:HasModifier("modifier_rooted") then
		bot.ref:Action_UseAbilityOnLocation(pit_of_malice, enemy:GetLocation())
		return true
	end

	return false
end

local function PitOfMalice(bot, enemy)
	local pit_of_malice = bot.ref:GetAbilityByName(SKILL_W)

	if not CanCast(bot, pit_of_malice) then
		return false
	end

	local aoe_heroes = bot.ref:FindAoELocation(true, true, bot.ref:GetLocation(),
		pit_of_malice:GetCastRange(), 375, pit_of_malice:GetSpecialValueFloat("delay_plus_castpoint_tooltip"), 0)

	if aoe_heroes.count > 2 then
		bot.ref:Action_UseAbilityOnLocation(pit_of_malice, aoe_heroes.targetloc)
		return true
	end

	if enemy ~= nil and GetUnitHealthPercentage(enemy) < 0.3 then
		bot.ref:Action_UseAbilityOnLocation(pit_of_malice, enemy:GetLocation())
		return true
	end

	return false
end

local function CustomFight(bot, enemy)
	if PitOfMalice(bot, enemy) or FireStorm(bot, enemy) then
		return
	end
	generic_priority["fight"][2](bot, enemy)
end

priority["fight"][2] = CustomFight

function Think()
	UpdateBot(bot)
	if PitOfMalice(bot, nil) or FireStorm(bot, nil) then
		return
	end
	Thonk(bot, priority)
end
