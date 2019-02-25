require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local g = require(GetScriptDirectory() .. "/global")

local priority = DeepCopy(generic_priority)

local buy_order = {
	"item_tango",
	"item_tango",
	"item_tango",
	"item_stout_shield",
	-- Mage boots
	"item_boots",
	"item_energy_booster",
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

function priorityQ(bot)
	local abilityQ = bot.ref:GetAbilityByName(SKILL_Q)
	local aoe_heroes = bot.ref:FindAoELocation(true, true, bot.ref:GetLocation(), abilityQ:GetCastRange(), 400, abilityQ:GetSpecialValueFloat("delay_plus_castpoint_tooltip"), 0)
	local aoe_minions = bot.ref:FindAoELocation(true, false, bot.ref:GetLocation(), abilityQ:GetCastRange(), 400, abilityQ:GetSpecialValueFloat("delay_plus_castpoint_tooltip"), 0)

	if bot.ref:IsChanneling() or bot.ref:IsUsingAbility() or abilityQ:GetManaCost() >= bot.mp_current or abilityQ:IsFullyCastable() == false then
		return
	end

	if aoe_heroes.count > 1 and aoe_minions.count > 2 then
		bot.ref:Action_UseAbilityOnLocation(abilityQ, aoe_heroes.targetloc)
	elseif aoe_heroes.count > 2 then
		bot.ref:Action_UseAbilityOnLocation(abilityQ, aoe_heroes.targetloc)
	elseif aoe_minions.count > 3 then
		bot.ref:Action_UseAbilityOnLocation(abilityQ, aoe_minions.targetloc)
	end
end

function priorityW(bot)
	local abilityW = bot.ref:GetAbilityByName(SKILL_W)
	local aoe_heroes = bot.ref:FindAoELocation(true, true, bot.ref:GetLocation(), abilityW:GetCastRange(), 375, abilityW:GetSpecialValueFloat("delay_plus_castpoint_tooltip"), 0)
	local aoe_minions = bot.ref:FindAoELocation(true, false, bot.ref:GetLocation(), abilityW:GetCastRange(), 375, abilityW:GetSpecialValueFloat("delay_plus_castpoint_tooltip"), 0)

	if bot.ref:IsChanneling() or bot.ref:IsUsingAbility() or abilityW:GetManaCost() >= bot.mp_current or abilityW:IsFullyCastable() == false then
		return
	end

	if aoe_heroes.count > 1 and aoe_minions.count > 2 then
		bot.ref:Action_UseAbilityOnLocation(abilityW, aoe_heroes.targetloc)
	elseif aoe_heroes.count > 2 then
		bot.ref:Action_UseAbilityOnLocation(abilityW, aoe_heroes.targetloc)
	elseif aoe_minions.count > 3 then
		bot.ref:Action_UseAbilityOnLocation(abilityW, aoe_minions.targetloc)
	end
end

function customFarm(bot, creep)
	front = GetLaneFrontAmount(GetTeam(), bot.lane, false)
	enemyfront = GetLaneFrontAmount(GetEnemyTeam(), bot.lane, false)
	front = Min(front, enemyfront)
	dest = GetLocationAlongLane(bot.lane, Min(1.0, front))
	bot.ref:Action_MoveToLocation(dest)
	bot.ref:Action_AttackUnit(creep, true)
	priorityQ(bot)
	priorityW(bot)
end

priority["farm"][2] = customFarm

function Think()
	UpdateBot(bot)
	Thonk(bot, priority)
end
