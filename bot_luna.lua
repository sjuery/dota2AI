require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/luna_desires")

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


function focus_target(enemy_heroes)
	local lowest_health = 100000
	local lowest_enemy = nil

	for i = 1, #enemy_heroes do
		if lowest_health > enemy_heroes[i]:GetHealth() then
			lowest_health = enemy_heroes[i]:GetHealth()
			lowest_enemy = enemy_heroes[i]
		end
	end
	return lowest_enemy
end

function LucentBeam(bot)
	local cast_range = nil
	local enemy_heroes = nil
	local lowest_enemy = nil

	local cast_beam = bot.ref:GetAbilityByName(SKILL_Q)
	-- print("Hello cast_beam = "..cast_beam)
	if cast_beam == nil then
		return false
	else
		cast_range = cast_beam:GetCastRange()
		enemy_heroes = bot.ref:GetNearbyHeroes(cast_range, true, BOT_MODE_NONE)
	end

	if enemy_heroes == nil then
		return false
	end
	lowest_enemy = focus_target(enemy_heroes)
	if lowest_enemy:GetHealth() <=  (lowest_enemy:GetMaxHealth() / 2) then

		print("Casting LucentBeam")
		bot.ref:Action_UseAbilityOnEntity(cast_beam,lowest_enemy)
		return true
	end
	return false
end

function Eclipse(bot)
	local cast_eclipse = bot.ref:GetAbilityByName(SKILL_R)

	if cast_eclipse == nil then
		return false
	end

	local cast_range = cast_eclipse:GetCastRange()
	local enemy_hero = bot.ref:GetNearbyHeroes(cast_range, true, BOT_MODE_NONE)


	if #enemy_hero > 0 then
	-- while GetCurrentActiveAbility() == SKILL_R
	-- 	increase the desire to fight
		print("Casting Eclipse")
		bot.ref:Action_UseAbility(SKILL_R)
		if bot.ref:FindItemSlot("item_manta") ~= 0 then
			print("Casting Manta")
			bot.ref:Action_UseAbility("item_manta")
			return true
		end
	end 
	return false
end

local function FightDesire(bot)
	local enemy_heroes = bot.ref:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	local heroes = bot.ref:GetNearbyHeroes(600, false, BOT_MODE_NONE)

	local allied_creeps = bot.ref:GetNearbyLaneCreeps(1000, false)
	local enemy_creeps = bot.ref:GetNearbyLaneCreeps(1000, true)

	local target = nil

	local desire = 0
	if #enemy_heroes > 0 then
		local towers = GetNearbyVisibleTowers(bot, 1600, true)

		-- Search for nearby enemy heroes (Not under enemy towers)
		for i = 1, #enemy_heroes do
			local pos = enemy_heroes[i]:GetLocation()
			if IsLocationVisible(pos) or IsLocationPassable(pos) then
				for i = 1, #towers do
					if GetDistance(pos, towers[i]:GetLocation()) > 900 then
						target = enemy_heroes[i]
						break
					end
				end
				if #towers == 0 then
					target = enemy_heroes[1]
				end
			end
			if target then
				break
			end
		end
	end

	if not target then
		return {desire, nil}
	end
-- Checking buffs of enemy and friendly heroes.

	-- Plus one to count ourself
	local target_hp_percent = (target:GetHealth() / target:GetMaxHealth())
	if #heroes + 1 >= #enemy_heroes 
		and target_hp_percent < 0.33
		and bot.hp_current > target_hp_percent * 1.4
	then
		desire = desire + 40
	end
	if #heroes + 1 == #enemy_heroes and #allied_creeps + 1 >= #enemy_creeps then
		desire = desire + 25
	end
	if #heroes + 1 > #enemy_heroes then
		desire = desire + 30
	end
	if #heroes > 0 then		
		desire = desire + GetTeamBuffs(heroes)
	end

	return {desire, target}
end

local function Fight(bot, enemy)
	if Eclipse(bot) then
		return
	end
	if LucentBeam(bot) then
		return
	end
	bot.ref:Action_AttackUnit(value, true)
end

priority["fight"] = {FightDesire, Fight}

function Think()
	UpdateBot(bot)
	Thonk(bot, priority)
end
