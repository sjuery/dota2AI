function FarmDesire(bot)
	return {100, nil}
end

function Farm(bot, value)
	print("am farm")
end


function RetreatDesire(bot)
	return {0, nil}
end

function Retreat(bot, value)
	print("am retreat")
end


function PushDesire(bot)
	return {0, nil}
end

function Push(bot, value)
	print("am push")
end


function FightDesire(bot)
	return {0, nil}
end

function Fight(bot, value)
	print("am fight")
end


function RuneDesire(bot)
	return {0, nil}
end

function Rune(bot, value)
	print("am rune")
end


function MemeDesire(bot)
	return {0, nil}
end

function Meme(bot, value)
	print("am meme")
end

local function UpKeep(bot)
	local max_hp = bot:GetMaxHealth()
	local current_hp = bot:GetHealth()

	local hp_percent = current_hp / max_hp
	local items = GetItems(bot)

	local tango = nil
	if items["item_tango_single"] ~= nil then
		tango = items["item_tango_single"]
	elseif items["item_tango"] then
		tango = items["item_tango"]
	end

	if hp_percent < 0.8 and tango ~= nil and not bot:HasModifier("modifier_tango_heal") and tango:IsFullyCastable() then
		local trees = bot:GetNearbyTrees(600)
		if #trees > 0 then
			local tree_pos = GetTreeLocation(trees[1])
			if IsLocationVisible(tree_pos) or IsLocationPassable(tree_pos) then
				bot:Action_UseAbilityOnTree(tango, trees[1])
			end
		end
	end

	local flask = items["item_flask"]
	if hp_percent < 0.33 and flask ~= nil and flask:IsFullyCastable() then
		bot:Action_UseAbilityOnEntity(flask, bot)
	end
end

generic_desires = {
	["farm"] = {FarmDesire, Farm},
	["retreat"] = {RetreatDesire, Retreat},
	["push"] = {PushDesire, Push},
	["fight"] = {FightDesire, Fight},
	["rune"] = {RuneDesire, Rune},
	["meme"] = {MemeDesire, Meme}
}

function Thonk(bot, desires)
	UpKeep(bot)
	local desire_best = -1
	local desire_value = nil
	local desire_mode = nil

	for name, thonkage in pairs(desires) do
		local thonk_result = thonkage[1](bot)
		local desire = thonk_result[1]
		local value = thonk_result[2]
		if desire > desire_best then
			desire_best = desire
			desire_value = value
			desire_mode = thonkage[2]
		end
	end
	desire_mode(bot, desire_value)
end