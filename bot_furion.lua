require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local priority = DeepCopy(generic_priority)

local buy_order = {
	"item_tango",
	"item_tango",
	"item_flask",
	"item_blight_stone",
	"item_boots",
	"item_chainmail",
	"item_blades_of_attack",
	"item_mithril_hammer",
	"item_mithril_hammer",
	-- Scepter
	"item_ogre_axe",
	"item_point_booster",
	"item_blade_of_alacrity",
	"item_staff_of_wizardry"
}

SKILL_Q = "furion_sprout"
SKILL_W = "furion_teleportation"
SKILL_E = "furion_force_of_nature"
SKILL_R = "furion_wrath_of_nature"

TALENT_1 = "special_bonus_attack_damage_30"
TALENT_2 = "special_bonus_movement_speed_25"
TALENT_3 = "special_bonus_armor_10"
TALENT_4 = "special_bonus_unique_furion_2"
TALENT_5 = "special_bonus_attack_speed_40"
TALENT_6 = "special_bonus_cooldown_reduction_25"
TALENT_7 = "special_bonus_unique_furion_3"
TALENT_8 = "special_bonus_unique_furion"

local ability_order = {
	SKILL_E, SKILL_Q, SKILL_E, SKILL_W, SKILL_E,
	SKILL_R, SKILL_E, SKILL_W, SKILL_W, TALENT_1,
	SKILL_W, SKILL_R, SKILL_Q, SKILL_Q, TALENT_4,
	SKILL_Q, SKILL_R, TALENT_5, TALENT_7
}

local bot = {
	["ref"] = GetBot(),
	["lane"] = GetStartingLane(1),
	["retreat"] = 0,
	["buy_order"] = buy_order,
	["ability_order"] = ability_order
}

function SpawnTrees(bot, enemy)
	local summon_trees = bot.ref:GetAbilityByName(SKILL_Q)
	local summon_treants = bot.ref:GetAbilityByName(SKILL_E)

	if not summon_trees or bot.mp_current < summon_trees:GetManaCost()
		or not summon_trees:IsFullyCastable() or bot.ref:IsChanneling() or bot.ref:IsUsingAbility() then
		return false
	end

	if (enemy:GetHealth() / enemy:GetMaxHealth()) < 0.33 then
		bot.ref:Action_UseAbilityOnLocation(summon_trees, best_tree)
		return true
	end

	return false
end

function SummonTreants(bot)
	local trees = bot.ref:GetNearbyTrees(1000)
	local summon_treants = bot.ref:GetAbilityByName(SKILL_E)
	local treant_talent = bot.ref:GetAbilityByName(TALENT_4) ~= nil

	if not summon_treants or #trees == 0 or bot.mp_current < summon_treants:GetManaCost()
		or not summon_treants:IsFullyCastable() or bot.ref:IsChanneling() or bot.ref:IsUsingAbility() then
		return false
	end

	radius = 150 + summon_treants:GetLevel() * 75
	max_trees = 1 + summon_treants:GetLevel()
	if treant_talent then
		max_trees = max_trees + 4
		radius = radius + 125
	end

	best_count = 0
	best_tree = nil

	for i = 1, #trees do
		trees[i] = GetTreeLocation(trees[i])
	end

	for i = 1, #trees do
		local count = 0
		for j = 1, #trees do
			if GetDistance(trees[i], trees[j]) < radius then
				count = count + 1
			end
		end
		if count > best_count then
			best_count = count
			best_tree = trees[i]
		end
	end

	if best_count >= 2 then
		bot.ref:Action_UseAbilityOnLocation(summon_treants, best_tree)
		return true
	end

	return false
end

local function Fight(bot, enemy)
	if SpawnTrees(bot, enemy) or SummonTreants(bot) then
		return
	end
	bot.ref:Action_AttackUnit(value, true)
end

priority["fight"][2] = Fight

function Think()
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1600, true)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	UpdateBot(bot)
	Thonk(bot, priority)
	if bot.mp_percent > 0.5 and #enemy_creeps ~= 0 and #enemy_heroes ~= 0 then
		SummonTreants(bot)
	end
end

local treant = {
	["lane"] = GetStartingLane(1)
}

local treant_priority = {
	["farm"] = DeepCopy(generic_priority["farm"]),
	["fight"] = DeepCopy(generic_priority["fight"]),
	["push"] = DeepCopy(generic_priority["push"])
}

function TreantFarmPriority(bot)
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1600, true)
	if #enemy_creeps > 0 then
		return {40, enemy_creeps[1]}
	end
	return {5, nil}
end

function TreantFightPriority(bot)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	if #enemy_heroes > 0 then
		return {60, enemy_heroes[1]}
	end
	return {0, nil}
end

treant_priority["farm"][1] = TreantFarmPriority
treant_priority["fight"][1] = TreantFightPriority

function MinionThink(treant_unit)
	treant.ref = treant_unit
	UpdateBot(treant)
	Thonk(treant, treant_priority)
end
