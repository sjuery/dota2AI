require(GetScriptDirectory() .. "../utility")

function HealPriority(bot)
	if bot.hp_percent < 0.72
		and (bot.ref:HasModifier("modifier_fountain_aura") or bot.ref:HasModifier("modifier_fountain_aura_buff"))
	then
		return {40, {"fountain", nil}}
	end

	local items = GetItems(bot)

	local salve = items["item_flask"]
	if salve ~= nil 
		and not bot.ref:HasModifier("modifier_flask_healing")
		and not bot.ref:WasRecentlyDamagedByAnyHero(3.0) and not bot.ref:WasRecentlyDamagedByTower(3.0)
		and (bot.hp_max - bot.hp_current > 400 or bot.hp_percent < 0.40)
	then
		return {60, {salve, bot.ref}}
	end

	local tango = nil
	if items["item_tango_single"] ~= nil then
		tango = items["item_tango_single"]
	elseif items["item_tango"] then
		tango = items["item_tango"]
	end

	if tango ~= nil 
		and bot.hp_percent < 0.9
		and not bot.ref:HasModifier("modifier_tango_heal")
		and not bot.ref:WasRecentlyDamagedByTower(1.2)
		and tango:IsFullyCastable()
	then
		local trees = bot.ref:GetNearbyTrees(1000)
		if #trees > 0 then
			local towers = GetNearbyVisibleTowers(bot, 1600, true)

			local tree = nil
			-- Search for safe trees (Not under enemy towers)
			for i = 1, #trees do
				local tree_pos = GetTreeLocation(trees[i])
				if IsLocationVisible(tree_pos) or IsLocationPassable(tree_pos) then
					for i = 1, #towers do
						if GetDistance(tree_pos, towers[i]:GetLocation()) > 1200 then
							tree = trees[i]
							break
						end
					end
					if #towers == 0 then
						tree = trees[1]
					end
				end
				if tree then
					break
				end
			end
			if tree ~= nil then
				return {50, {tango, tree}}
			end
		end
	end

	local clarity = items["item_clarity"]
	if clarity ~= nil
		and not bot.ref:HasModifier("modifier_clarity_potion")
		and not bot.ref:WasRecentlyDamagedByAnyHero(3.0) and not bot.ref:WasRecentlyDamagedByTower(3.0)
		and (bot.mp_max - bot.mp_current > 225)
	then
		return {60, {clarity, bot.ref}}
	end

	local shrines = {
		SHRINE_JUNGLE_1,
		SHRINE_JUNGLE_2
	}
	local team = GetTeam()
	local shrine_dist = 100000
	for i = 1, #shrines do
		local shrine = GetShrine(team, shrines[i])
		local distance = GetUnitToUnitDistance(bot.ref, shrine)
		if shrine:GetHealth() > 0 then
			if (distance < 3000 and not (GetShrineCooldown(shrine) > 1)
				and (bot.mp_max - bot.mp_current > 250 or bot.hp_max - bot.hp_current > 400 or bot.hp_percent < 0.33))
				or (distance < 1000 and IsShrineHealing(shrine))
				and not bot.ref:HasModifier("modifier_flask_healing")
			then
				return {60, {"shrine", shrine}}
			end
		end
	end

	return {0, nil}
end

function Heal(bot, params)
	local heal_item, heal_target = unpack(params)

	if heal_item == "fountain" then
	local target = nil
		bot.ref:Action_MoveToLocation(GetFountain())
		return
	end

	if heal_item == "shrine" then
		if GetUnitToUnitDistance(bot.ref, heal_target) < 400 and not bot.ref:HasModifier("modifier_flask_healing")
		then
			bot.ref:Action_UseShrine(heal_target)
		else
			bot.ref:Action_MoveToLocation(heal_target:GetLocation())
		end
		return
	end

	local name = heal_item:GetName()
	if string.find(name, "tango") ~= nil then
		bot.ref:Action_UseAbilityOnTree(heal_item, heal_target)
	elseif name == "item_flask" or name == "item_clarity" then
		bot.ref:Action_UseAbilityOnEntity(heal_item, heal_target)
	end
end
