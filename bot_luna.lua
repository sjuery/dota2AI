require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local g = require(GetScriptDirectory() .. "/global")

local priority = DeepCopy(generic_priority)

local buy_order = {
	"item_tango",
	"item_flask",
	"item_tango",
	-- Wraith band
	"item_circlet",
	"item_slippers",
	"item_recipe_wraith_band",
	-- Power Treads
	"item_boots",
	"item_gloves",
	"item_boots_of_elves",
	-- dragon lance
	"item_boots_of_elves",
	"item_boots_of_elves",
	"item_ogre_axe",
	-- start satanic
	"item_lifesteal",
	-- Yasha
	"item_boots_of_elves",
	"item_blade_of_alacrity",
	"item_recipe_yasha",
	-- Manta Style
	"item_ultimate_orb",
	"item_recipe_manta",
	-- finish satanic
	"item_reaver",
	"item_claymore",
	-- butterfly
	"item_eagle",
	"item_talisman_of_evasion",
	"item_quarterstaff",
	-- moon shard
	"item_hyperstone",
	"item_hyperstone",
	-- eye of skadi
	"item_ultimate_orb",
	"item_ultimate_orb",
	"item_point_booster"
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

-- local ability_order = {
-- 	SKILL_Q, SKILL_E, SKILL_Q, SKILL_W, SKILL_Q,
-- 	SKILL_R, SKILL_Q, SKILL_E, SKILL_E, SKILL_E,
-- 	TALENT_1, SKILL_R, SKILL_W, SKILL_W, SKILL_W,
-- 	TALENT_4, SKILL_R, TALENT_5, TALENT_7
-- }

-- Alt right click build
local ability_order = {
	SKILL_E, SKILL_W, SKILL_E, SKILL_W, SKILL_E,
	SKILL_W, SKILL_W, SKILL_E, SKILL_Q, SKILL_Q,
	TALENT_1, SKILL_Q, SKILL_Q, SKILL_R, SKILL_R,
	TALENT_4, SKILL_R, TALENT_5, TALENT_7
}

local bot = {
	["ref"] = GetBot(),
	["lane"] = GetStartingLane(0),
	["retreat"] = 0,
	["buy_order"] = buy_order,
	["sell_order"] = {"item_wraith_band"},
	["ability_order"] = ability_order
}

table.insert(g, bot)

local function LucentBeam(bot, enemy)
	local lucent_beam = bot.ref:GetAbilityByName(SKILL_Q)

	if not lucent_beam:IsTrained() or not CanCast(bot, lucent_beam) then
		return false
	end

	local cast_range = lucent_beam:GetCastRange()

	if enemy:GetHealth() <= enemy:GetMaxHealth() then
		bot.ref:Action_UseAbilityOnEntity(lucent_beam, enemy)
		return true
	end
	return false
end

local function Eclipse(bot, enemy)
	local eclipse = bot.ref:GetAbilityByName(SKILL_R)

	if not eclipse:IsTrained() or not CanCast(bot, eclipse)
		then
		return false
	else
		local cast_range = eclipse:GetCastRange()
	end

	if GetUnitHealthPercentage(enemy) < 0.7 then
		bot.ref:Action_UseAbility(eclipse)
		return true
	end

	return false
end

local function CustomFight(bot, enemies)
	if Eclipse(bot, enemies) or LucentBeam(bot, enemies) then
		return
	end
	AttackUnit(bot, enemies)
end

priority["fight"][2] = CustomFight

function Think()
	UpdateBot(bot)
	Thonk(bot, priority)
end
