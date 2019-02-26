require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local g = require(GetScriptDirectory() .. "/global")

local priority = DeepCopy(generic_priority)

local buy_order = {
	"item_courier",
	"item_tango",
	"item_tango",
	"item_clarity",
	"item_clarity",
	"item_stout_shield",
	-- Soul Ring
	"item_gauntlets",
	"item_gauntlets",
	"item_ring_of_regen",
	"item_recipe_soul_ring",
	-- Mage boots
	"item_boots",
	"item_energy_booster",
	-- Echo Sabre
	"item_sobi_mask",
	"item_quarterstaff",
	"item_robe",
	"item_ogre_axe",
	-- Vanguard
	"item_vitality_booster",
	"item_ring_of_regen",
	-- Abyssal Blade
	"item_mithril_hammer",
	"item_belt_of_strength",
	"item_recipe_basher",
	"item_recipe_abyssal_blade"
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
	["sell_order"] = {},
	["ability_order"] = ability_order
}

table.insert(g, bot)

local function Purification(bot)
	local purification = bot.ref:GetAbilityByName(SKILL_Q)
	local allied_heroes = bot.ref:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local lowest_health = 10000000
	local lowest_ally = nil

	if bot.ref:IsChanneling() or bot.ref:IsUsingAbility() or purification:GetManaCost() >= bot.mp_current
		or #allied_heroes == 0 or not purification:IsFullyCastable()
	then
		return false
	end

	for i = 1, #allied_heroes do
		if lowest_health > allied_heroes[i]:GetHealth() then
			lowest_health = allied_heroes[i]:GetHealth()
			lowest_ally = allied_heroes[i]
		end
	end

	if bot.hp_max - bot.hp_current < 300 and lowest_ally:GetMaxHealth() - lowest_health < 300 then
		return false
	end

	if lowest_ally == nil then
		bot.ref:Action_UseAbilityOnEntity(purification, bot.ref)
	end

	if GetUnitToUnitDistance(bot.ref, lowest_ally) >= 400 then
		bot.ref:Action_MoveToLocation(lowest_ally:GetLocation())
	end

	bot.ref:Action_UseAbilityOnEntity(purification, lowest_ally)
	return true
end

local function Grace(bot)
	local grace = bot.ref:GetAbilityByName(SKILL_W)
	local allied_heroes = bot.ref:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local lowest_health = 10000000
	local lowest_ally = nil

	if not grace:IsTrained() or bot.ref:IsChanneling() or bot.ref:IsUsingAbility() or grace:GetManaCost() >= bot.mp_current
		or #allied_heroes == 0 or not grace:IsFullyCastable()
	then
		return false
	end

	for i = 1, #allied_heroes do
		if lowest_health > allied_heroes[i]:GetHealth() then
			lowest_health = allied_heroes[i]:GetHealth()
			lowest_ally = allied_heroes[i]
		end
	end

	if bot.hp_max - bot.hp_current < 300 and lowest_ally:GetMaxHealth() - lowest_health < 300 then
		return false
	end

	if lowest_ally == nil then
		bot.ref:Action_UseAbilityOnEntity(grace, bot.ref)
	end

	if GetUnitToUnitDistance(bot.ref, lowest_ally) >= 400 then
		bot.ref:Action_MoveToLocation(lowest_ally:GetLocation())
	end

	bot.ref:Action_UseAbilityOnEntity(grace, lowest_ally)
	return true
end

function Think()
	UpdateBot(bot)
	Thonk(bot, priority)
	if Purification(bot) or Grace(bot) then
		return
	end
end
