require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/upkeep")
-- require(GetScriptDirectory() .. "/luna_desires")

local g = require(GetScriptDirectory() .. "/global")

local priority = DeepCopy(generic_priority)

local buy_order = {
	"item_tango",
	"item_flask",
	"item_quelling_blade",
	"item_tango",
	-- Power Treads
	"item_boots",
	"item_gloves",
	"item_boots_of_elves",
	-- start satanic
	"item_lifesteal",
	-- dragon lance
	"item_boots_of_elves",
	"item_boots_of_elves",
	"item_ogre_axe",
	-- Yasha
	"item_boots_of_elves",
	"item_blade_of_alacrity",
	"item_recipe_yasha",
	-- Manta Style
	"item_ultimate_orb",
	"item_recipe_manta",
	-- butterfly
	"item_eagle",
	"item_talisman_of_evasion",
	"item_quarterstaff",
	-- hurricane pike
	"item_staff_of_wizardry",
	"item_ring_of_regen",
	"item_recipe_force_staff",
	-- finish satanic
	"item_reaver",
	"item_claymore",
	-- moon shard
	"item_hyperstone",
	"item_hyperstone",
	-- eye of skadi
	"item_ultimate_orb",
	"item_ultimate_orb",
	"item_point_booster"
	-- Hammer time
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

local ability_order = {
	SKILL_Q, SKILL_E, SKILL_Q, SKILL_W, SKILL_Q,
	SKILL_R, SKILL_Q, SKILL_E, SKILL_E, SKILL_E,
	TALENT_1, SKILL_R, SKILL_W, SKILL_W, SKILL_W,
	TALENT_4, SKILL_R, TALENT_5, TALENT_7
}

local bot = {
	["ref"] = GetBot(),
	["lane"] = GetStartingLane(0),
	["retreat"] = 0,
	["buy_order"] = buy_order,
	["ability_order"] = ability_order
}

table.insert(g, bot)

-- function focus_target(enemy_heroes)
-- 	local lowest_health = 100000
-- 	local lowest_enemy = nil

-- 	for i = 1, #enemy_heroes do
-- 		if lowest_health > enemy_heroes[i]:GetHealth() then
-- 			lowest_health = enemy_heroes[i]:GetHealth()
-- 			lowest_enemy = enemy_heroes[i]
-- 		end
-- 	end
-- 	return lowest_enemy
-- end

function LucentBeam(bot, enemy)

	local cast_range = nil
	local lowest_enemy = nil

	local cast_beam = bot.ref:GetAbilityByName(SKILL_Q)

	if cast_beam == nil then
		return false
	elseif bot.mp_current < (cast_beam:GetManaCost() * 2)
		or not cast_beam:IsFullyCastable()
		or bot.ref:IsChanneling()
		or bot.ref:IsUsingAbility()
		then
		return false
	else
		cast_range = (cast_beam:GetCastRange() * 0.75)
		-- enemy_heroes = bot.ref:GetNearbyHeroes(cast_range, true, BOT_MODE_NONE)
	end

	-- if enemy_he== nil then
		-- return false
	-- end

	-- lowest_enemy = focus_target(enemy)
	if enemy ~= nil
		and enemy:GetHealth() <=  (enemy:GetMaxHealth() * 0.75) then
		print("Casting LucentBeam")
		bot.ref:Action_UseAbilityOnEntity(cast_beam, enemy)
		return true
	end
	return false
end

function Eclipse(bot, enemy)
	local cast_eclipse = bot.ref:GetAbilityByName(SKILL_R)

	if cast_eclipse == nil then
		return false
	elseif bot.mp_current < cast_eclipse:GetManaCost()
		or not cast_eclipse:IsFullyCastable()
		or bot.ref:IsChanneling()
		or bot.ref:IsUsingAbility()
		then
		return false
	else
		local cast_range = cast_eclipse:GetCastRange()
		-- local enemy_heroes = bot.ref:GetNearbyHeroes(cast_range, true, BOT_MODE_NONE)
	end

	-- if enemy_heroes == nil then
		-- return false
	-- end
	if enemy ~= nil then
		print("Casting Eclipse")
		bot.ref:Action_UseAbility(cast_eclipse)
		while enemy:IsAlive() do 
			Action_MoveToUnit(enemy)
		-- Use manta if UseItems is called..
		end
		return true
	end
	return false
end

-- local function FightDesire(bot)
-- 	local enemy_heroes = bot.ref:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
-- 	local heroes = bot.ref:GetNearbyHeroes(600, false, BOT_MODE_NONE)

-- 	local allied_creeps = bot.ref:GetNearbyLaneCreeps(1000, false)
-- 	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1000, true)

-- 	local target = nil

-- 	local desire = 0
-- 	if #enemy_heroes > 0 then
-- 		local towers = bot.ref:GetNearbyTowers(1600, true)

-- 		-- Search for nearby enemy heroes (Not under enemy towers)
-- 		for i = 1, #enemy_heroes do
-- 			local pos = enemy_heroes[i]:GetLocation()
-- 			if IsLocationVisible(pos) or IsLocationPassable(pos) then
-- 				for i = 1, #towers do
-- 					if GetDistance(pos, towers[i]:GetLocation()) > 900 then
-- 						target = enemy_heroes[i]
-- 						break
-- 					end
-- 				end
-- 				if #towers == 0 then
-- 					target = enemy_heroes[1]
-- 				end
-- 			end
-- 			if target then
-- 				break
-- 			end
-- 		end
-- 	end

-- 	if not target then
-- 		return {desire, nil}
-- 	end
-- -- Checking buffs of enemy and friendly heroes.

-- 	-- Plus one to count ourself
-- 	local target_hp_percent = (target:GetHealth() / target:GetMaxHealth())
-- 	if #heroes + 1 >= #enemy_heroes 
-- 		and target_hp_percent < 0.33
-- 		and bot.hp_current > target_hp_percent * 1.4
-- 	then
-- 		desire = desire + 40
-- 	end
-- 	if #heroes + 1 == #enemy_heroes and #allied_creeps + 1 >= #enemy_creeps then
-- 		desire = desire + 25
-- 	end
-- 	if #heroes + 1 > #enemy_heroes then
-- 		desire = desire + 30
-- 	end
-- 	if #heroes > 0 then		
-- 		desire = desire + GetTeamBuffs(heroes)
-- 	end

-- 	return {desire, target}
-- end

local function Fight(bot, enemy)
	if Eclipse(bot, enemy) then
		return
	end
	if LucentBeam(bot, enemy) then
		return
	end
	bot.ref:Action_AttackUnit(enemy, true)
end

priority["fight"][2] = Fight

function Think()
	UpdateBot(bot)
	Thonk(bot, priority)
end
