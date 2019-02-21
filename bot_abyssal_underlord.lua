require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local desires = DeepCopy(generic_desires)

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
	SKILL_Q, SKILL_E, SKILL_Q, SKILL_W, SKILL_Q,
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

function desireQ(bot)
	local abilityQ = bot.ref:GetAbilityByName(SKILL_Q)
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1200, true)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

	if bot.ref:IsChanneling() or bot.ref:IsUsingAbility() then
		return
	end

	if #enemy_creeps + #enemy_heroes >= 2 then
		if #enemy_creeps > 2 then
			bot.ref:Action_UseAbilityOnLocation(abilityQ, enemy_creeps[1]:GetLocation())
		elseif #enemy_heroes > 0 then
			bot.ref:Action_UseAbilityOnLocation(abilityQ, enemy_heroes[1]:GetLocation())
		end
	end
end

function desireW(bot)
	local abilityW = bot.ref:GetAbilityByName(SKILL_W)
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1200, true)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

	if bot.ref:IsChanneling() or bot.ref:IsUsingAbility() then
		return
	end

	if #enemy_creeps + #enemy_heroes >= 1 then
		if #enemy_creeps > 2 then
			bot.ref:Action_UseAbilityOnLocation(abilityW, enemy_creeps[1]:GetLocation())
		elseif #enemy_heroes > 0 then
			bot.ref:Action_UseAbilityOnLocation(abilityW, enemy_heroes[1]:GetLocation())
		end
	end
end

function customFarm(bot, creep)
	front = GetLaneFrontAmount(GetTeam(), bot.lane, false)
	enemyfront = GetLaneFrontAmount(GetEnemyTeam(), bot.lane, false)
	front = Min(front, enemyfront)
	dest = GetLocationAlongLane(bot.lane, Min(1.0, front))
	bot.ref:Action_MoveToLocation(dest)
	bot.ref:Action_AttackUnit(creep, true)
	desireQ(bot)
	desireW(bot)
end

desires["farm"][2] = customFarm

function Think()
	UpdateBot(bot)
	Thonk(bot, desires)
end
