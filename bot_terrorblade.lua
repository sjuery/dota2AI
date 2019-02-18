require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local desires = DeepCopy(generic_desires)

local buy_order = {
	"item_courier",
	"item_tango",
	"item_tango",
	"item_tango",
	"item_flask",
	"item_stout_shield",
	"item_quelling_blade",
	"item_circlet",
	"item_slippers",
	"item_recipe_wraith_band",
	"item_boots",
	"item_boots_of_elves",
	"item_gloves",
	"item_boots_of_elves",
	"item_boots_of_elves",
	"item_ogre_axe",
	"item_boots_of_elves",
	"item_blade_of_alacrity",
	"item_recipe_yasha",
	"item_ultimate_orb",
	"item_recipe_manta",
	"item_hyperstone",
	"item_hyperstone"
};

local bot = {
	["ref"] = GetBot(),
	["lane"] = LANE_MID,
	["retreat"] = 0,
	["buy_order"] = buy_order
}

function Think()
	UpdateBot(bot)
	Thonk(bot, desires)
end
