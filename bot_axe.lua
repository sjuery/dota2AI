require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local g = require(GetScriptDirectory() .. "/global")

local priority = DeepCopy(generic_priority)

local buy_order = {
	"item_tango",
	"item_flask",
	"item_tango",
	"item_boots",
	-- Vanguard
	"item_stout_shield",
	"item_ring_of_health",
	"item_vitality_booster",
	-- Tranquil Boots
	" item_ring_of_regen",
	"item_wind_lace",
	-- Blink Dagger
	"item_blink",
	-- Blade Mail
	"item_broadsword",
	"item_chainmail",
	"item_robe",
	-- Crimson Guard
	"item_buckler",
	"item_recipe_crimson_guard"
	-- -- Dragon Lance
	-- "item_boots_of_elves",
	-- "item_boots_of_elves",
	-- "item_ogre_axe",
	-- -- Morbid Mask
	-- "item_lifesteal",
	-- -- Yasha
	-- "item_boots_of_elves",
	-- "item_blade_of_alacrity",
	-- "item_recipe_yasha",
	-- -- Manta Style
	-- "item_ultimate_orb",
	-- "item_recipe_manta",
	-- -- Crystalys
	-- "item_blades_of_attack",
	-- "item_broadsword",
	-- "item_recipe_lesser_crit",
	-- -- Daedalus
	-- "item_demon_edge",
	-- "item_recipe_greater_crit",
	-- -- Moonshard - Switch with Aghanim's when we have switching perfectly implemented
	-- "item_hyperstone",
	-- "item_hyperstone",
	-- -- Aghanim's Scepter
	-- "item_point_booster",
	-- "item_blade_of_alacrity",
	-- "item_ogre_axe",
	-- "item_staff_of_wizardry",
	-- -- Satanic
	-- "item_claymore",
	-- "item_reaver"
}

SKILL_Q = "axe_berserkers_call"
SKILL_W = "axe_battle_hunger"
SKILL_E = "axe_counter_helix"
SKILL_R = "axe_culling_blade"

TALENT_1 = "special_bonus_strength_8"
TALENT_2 = "special_bonus_attack_speed_40"
TALENT_3 = "special_bonus_mp_regen_3"
TALENT_4 = "special_bonus_movement_speed_30"
TALENT_5 = "special_bonus_hp_regen_25"
TALENT_6 = "special_bonus_unique_axe_3"
TALENT_7 = "special_bonus_unique_axe_2"
TALENT_8 = "special_bonus_unique_axe"

local ability_order = {
	SKILL_E, SKILL_W, SKILL_E, SKILL_Q, SKILL_E,
	SKILL_R, SKILL_E, SKILL_Q, SKILL_Q, TALENT_1,
	SKILL_Q, SKILL_R, SKILL_W, SKILL_W, TALENT_3,
	SKILL_W, SKILL_R, TALENT_5, TALENT_7
}

table.insert(g, bot)

local bot = {
	["ref"] = GetBot(),
	["lane"] = GetStartingLane(1),
	["retreat"] = 0,
	["buy_order"] = buy_order,
	["ability_order"] = ability_order
}

function Think()
	UpdateBot(bot)
	Thonk(bot, priority)
end
