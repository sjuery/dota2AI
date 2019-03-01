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
  -- echo saber
  "item_quarterstaff",
  "item_robe",
  "item_sobi_mask",
  "item_ogre_axe",
	-- Yasha
	"item_boots_of_elves",
	"item_blade_of_alacrity",
	"item_recipe_yasha",
  -- Sange
  "item_belt_of_strength",
  "item_ogre_axe",
  "item_recipe_sange",
  -- Monkey
  "item_demon_edge",
  "item_javelin",
  "item_quarterstaff",
  -- Crystalys
  "item_blades_of_attack",
  "item_broadsword",
  "item_recipe_lesser_crit",
  -- Daedalus
  "item_demon_edge",
  "item_recipe_greater_crit",
	-- finish satanic
	"item_reaver",
	"item_claymore",
	-- moon shard
	"item_hyperstone",
	"item_hyperstone",
	-- Hammer time
}

SKILL_Q = "sven_storm_bolt"
SKILL_W = "sven_great_cleave"
SKILL_E = "sven_warcry"
SKILL_R = "sven_gods_streng"

TALENT_1 = "special_bonus_strength_6"
TALENT_2 = "special_bonus_mp_200"
TALENT_3 = "special_bonus_movement_speed_20"
TALENT_4 = "special_bonus_all_stats_8"
TALENT_5 = "special_bonus_attack_speed_30"
TALENT_6 = "special_bonus_evasion_15"
TALENT_7 = "special_bonus_attack_damage_65"
TALENT_8 = "special_bonus_unique_sven"

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

function StormBolt(bot, enemy)

end

function WarCry(bot, enemy)
end



local function CustomFight(bot, enemies)

	bot.ref:Action_AttackUnit(enemies, true)
end

priority["fight"] = CustomFight

function Think()
	UpdateBot(bot)
	Thonk(bot, priority)
end
