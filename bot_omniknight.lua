require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local desires = DeepCopy(generic_desires)

local buy_order = {
	"item_courier",
	"item_tango",
	"item_tango",
	"item_clarity",
	"item_clarity",
	"item_branches",
	"item_stout_shield",
	-- Soul Ring
	"item_gauntlets",
	"item_gauntlets",
	"item_ring_of_regen",
	"item_recipe_soul_ring",
	-- Mage boots
	"item_boots",
	"item_energy_booster",
	-- Headress
	"item_ring_of_regen",
	"item_recipe_headdress",
	-- Mekansm
	"item_buckler",
	"item_recipe_mekansm",
	"item_recipe_guardian_greaves"
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

function desireQ(bot)
	local abilityQ = bot.ref:GetAbilityByName(SKILL_Q)
	local friendlyHeroes = bot.ref:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local lowestHealth = 100000
	local lowestAlly = nil

	if bot.ref:IsChanneling() or bot.ref:IsUsingAbility() or abilityQ:GetManaCost() >= bot.mp_current or #friendlyHeroes == 0 or not abilityQ:IsFullyCastable()then
		return
	end

	for i = 1, #friendlyHeroes do
		if lowestHealth > friendlyHeroes[i]:GetHealth() then
			lowestHealth = friendlyHeroes[i]:GetHealth()
			lowestAlly = friendlyHeroes[i]
		end
	end

	if ((bot.hp_max - bot.hp_current) < 300) and (lowestAlly:GetMaxHealth() - lowestHealth) < 300 then
		return
	end

	if lowestAlly == nil then
		bot.ref:Action_UseAbilityOnEntity(abilityQ, bot.ref)
	end

	if GetUnitToUnitDistance(bot.ref, lowestAlly) >= 400 then
		bot.ref:Action_MoveToLocation(lowestAlly:GetLocation())
	end
	bot.ref:Action_UseAbilityOnEntity(abilityQ, lowestAlly)
end

function Think()
	-- print("am omni am going " .. bot.lane)
	UpdateBot(bot)
	Thonk(bot, desires)
	desireQ(bot)
end
