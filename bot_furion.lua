require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local priority = DeepCopy(generic_priority)

local buy_order = {
	"item_tango",
	"item_tango",
	"item_flask",
	"item_blight_stone",
	"item_boots",
	"item_blades_of_attack",
	"item_chainmail",
	-- Maelstrom
	"item_mithril_hammer",
	"item_javelin",
	-- Desolator
	"item_blades_of_attack",
	"item_mithril_hammer",
	"item_mithril_hammer",
	-- Vladmir's Offering
	"item_lifesteal",
	"item_sobi_mask",
	"item_recipe_vladmir",
	-- Assault Cuirass
	"item_hyperstone",
	"item_chainmail",
	"item_platemail",
	"item_recipe_assault",
	-- Moonstone
	"item_hyperstone",
	"item_hyperstone"
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
	SKILL_E, SKILL_W, SKILL_E, SKILL_Q, SKILL_E,
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

local function SpawnTrees(bot, enemy)
	local summon_trees = bot.ref:GetAbilityByName(SKILL_Q)
	local summon_treants = bot.ref:GetAbilityByName(SKILL_E)

	if not summon_trees:IsTrained() or not summon_treants:IsTrained() or bot.mp_current < summon_trees:GetManaCost()
		or not summon_trees:IsFullyCastable() or not summon_treants:IsFullyCastable() or bot.ref:IsChanneling() or bot.ref:IsUsingAbility() then
		return false
	end

	local range = summon_trees:GetCastRange()

	if GetUnitHealthPercentage(enemy) < 0.33 and GetUnitToUnitDistance(bot.ref, enemy) < range then
		bot.ref:Action_UseAbilityOnLocation(summon_trees, enemy:GetLocation())
		return true
	end

	return false
end

local function SummonTreants(bot)
	local trees = bot.ref:GetNearbyTrees(1000)
	local summon_treants = bot.ref:GetAbilityByName(SKILL_E)

	if not summon_treants:IsTrained() or #trees == 0 or bot.mp_current < summon_treants:GetManaCost()
		or not summon_treants:IsFullyCastable() or bot.ref:IsChanneling() or bot.ref:IsUsingAbility() then
		return false
	end

	radius = 75 + summon_treants:GetLevel() * 75
	max_trees = 1 + summon_treants:GetLevel()
	if bot.ref:GetAbilityByName(TALENT_4) ~= nil then
		max_trees = max_trees + 4
		radius = radius + 125
	end

	best_count = 0
	best_tree = nil

	local range = summon_treants:GetCastRange()

	for i = 1, #trees do
		trees[i] = GetTreeLocation(trees[i])
	end

	for i = 1, #trees do
		if GetUnitToLocationDistance(bot.ref, trees[i]) < range then
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
	end

	if best_count >= 2 then
		bot.ref:Action_UseAbilityOnLocation(summon_treants, best_tree)
		return true
	end

	return false
end

local function NaturesWrath(bot, enemy)
	local natures_wrath = bot.ref:GetAbilityByName(SKILL_R)

	if not natures_wrath:IsTrained() or bot.mp_current < natures_wrath:GetManaCost()
		or not natures_wrath:IsFullyCastable() or bot.ref:IsChanneling() or bot.ref:IsUsingAbility() then
		return false
	end

	if GetUnitHealthPercentage(enemy) < 0.7 then
		bot.ref:Action_UseAbilityOnLocation(natures_wrath, enemy:GetLocation())
		return true
	end

	return false
end

local function CustomFight(bot, enemy)
	if SpawnTrees(bot, enemy) or SummonTreants(bot) or NaturesWrath(bot, enemy) then
		return
	end
	bot.ref:Action_AttackUnit(value, true)
end

priority["fight"][2] = CustomFight

function Think()
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1600, true)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	UpdateBot(bot)
	Thonk(bot, priority)
	if bot.mp_percent > 0.5 and #enemy_creeps ~= 0 and #enemy_heroes ~= 0 then
		SummonTreants(bot)
	end
end

-- Treants

local treant = {
	["lane"] = GetStartingLane(1)
}

local function TreantFarmPriority(bot)
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1600, true)

	if #enemy_creeps == 0 then
		return {5, nil}
	end

	local target = enemy_creeps[1]
	-- Find weakest target in range
	for i = 1, #enemy_creeps do
		if GetUnitToUnitDistance(bot.ref, enemy_creeps[i]) < 300
			and enemy_creeps[i]:GetHealth() < target:GetHealth()
		then
			target = enemy_creeps[i]
		end
	end

	return {40, target}
end

local function TreantFightPriority(bot)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	if #enemy_heroes == 0 then
		return {0, nil}
	end

	local target = enemy_heroes[1]
	-- Find weakest target in range
	for i = 1, #enemy_heroes do
		local distance = GetUnitToUnitDistance(bot.ref, enemy_heroes[i])
		if enemy_heroes[i]:WasRecentlyDamagedByAnyHero(1.0) and distance < 500 then
			target = enemy_heroes[i]
			break
		elseif distance < 300
			and enemy_heroes[i]:GetHealth() < target:GetHealth()
		then
			target = enemy_heroes[i]
		end
	end

	return {60, target}
end

local function FollowPriority(bot)
	local allied_heroes = bot.ref:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	if #allied_heroes == 0 then
		return {0, nil}
	end

	return {10, allied_heroes[1]:GetLocation()}
end

local function Follow(bot, target)
	bot.ref:Action_MoveToLocation(target)
end

local treant_priority = {
	["farm"] = DeepCopy(generic_priority["farm"]),
	["fight"] = DeepCopy(generic_priority["fight"]),
	["push"] = DeepCopy(generic_priority["push"]),
	["follow"] = {FollowPriority, Follow}
}

treant_priority["farm"][1] = TreantFarmPriority
treant_priority["fight"][1] = TreantFightPriority

function MinionThink(treant_unit)
	treant.ref = treant_unit
	UpdateBot(treant)
	Thonk(treant, treant_priority)
end
