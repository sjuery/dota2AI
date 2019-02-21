require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local desires = DeepCopy(generic_desires)

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
	"item_blight_stone"
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

function DesireSummonTrees(bot, value)
	local trees = bot.ref:GetNearbyTrees(1000)
	if #trees > 0 then
		local towers = bot.ref:GetNearbyTowers(1600, true)
		local tree = nil

		safe_trees = {}
		-- Search for safe trees (Not under enemy towers)
		for i = 1, #trees do
			local tree_pos = GetTreeLocation(trees[i])
			if IsLocationVisible(tree_pos) or IsLocationPassable(tree_pos) then

				if #towers == 0 then
					table.insert(safe_trees, trees[i])
				else
					for i = 1, #towers do
						if GetDistance(tree_pos, towers[i]:GetLocation()) > 1200 then
							table.insert(safe_trees, trees[i])
							break
						end
					end
				end
			end
		end
	end

	return {0, nil}
end

function SummonTrees(bot, value)
end

desires["summon_trees"] = {DesireSummonTrees, SummonTrees}

function Think()
	UpdateBot(bot)
	Thonk(bot, desires)
end

-- Active item usage
-- Null Talisman?
-- Bear Stuff
-- Mode code into folder of files.