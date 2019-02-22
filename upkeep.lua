function UseItems(bot)
	local allies = bot.ref:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
	local items = GetItems(bot)

	-- Use Mana boots
	local arcane_boots = items["item_arcane_boots"]
	if arcane_boots ~= nil and arcane_boots:IsFullyCastable()
		and bot.mp_max - bot.mp_current > 160 and #allies > 0
	then
		bot.ref:Action_UseAbility(arcane_boots)
		return
	end

	-- Use phase boots for retreating, maybe one day for attacking.
	local phase_boots = items["item_phase_boots"]
	if phase_boots ~= nil and phase_boots:IsFullyCastable()
		and bot.desire == "retreat" and bot.hp_percent < 0.33
	then
		bot.ref:Action_UseAbility(phase_boots)
		return
	end

	-- Use soul ring if hp > 60% and we need mana
	local soul_ring = items["item_soul_ring"]
	if soul_ring ~= nil and soul_ring:IsFullyCastable()
		and bot.hp_percent > 0.6 and (bot.mp_max - bot.mp_current) > 150
	then
		bot.ref:Action_UseAbility(soul_ring)
	end

	-- Use mekansm if allies in range, need to improve later
	local mekansm = items["item_mekansm"]
	if mekansm ~= nil and mekansm:IsFullyCastable() and #allies > 0 then
		bot.ref:Action_UseAbility(mekansm)
	end
end

local generic_buy_order = {
	"item_tango",
	"item_tango",
	"item_flask",
	"item_stout_shield",
	"item_quelling_blade",
-- Power treads
	"item_boots",
	"item_boots_of_elves",
	"item_gloves",
-- Armlet of Mordiggian
	"item_helm_of_iron_will",
	"item_boots_of_elves",
	"item_blades_of_attack",
	"item_recipe_armlet"
}

function UpKeep(bot)
	if GetGlyphCooldown() == 0 then
		if PotentialTowers(bot):TimeSinceDamagedByAnyHero() < 3 then
			bot.ref:ActionImmediate_Glyph()
		end
	end

	-- Upgrade abilities
	if bot.ability_order then
		if bot.ref:GetAbilityPoints() > 0 then
			local ability = bot.ref:GetAbilityByName(bot.ability_order[1])
			if (ability:CanAbilityBeUpgraded() and ability:GetLevel() < ability:GetMaxLevel()) then
				bot.ref:ActionImmediate_LevelAbility(bot.ability_order[1])
				table.remove(bot.ability_order, 1)
				-- print("Upgrading ability: " .. bot.ability_order[1])
				return
			end
		end
	end

	-- Buy items
	local buy_order = generic_buy_order
	if bot.buy_order ~= nil then
		buy_order = bot.buy_order
	end
	if buy_order and #buy_order ~= 0 then
		local item = buy_order[1]
		local cost = GetItemCost(item)

		local side_shop_pos = nil
		if bot.lane == LANE_TOP then
			side_shop_pos = SIDE_SHOP_TOP
		else
			side_shop_pos = SIDE_SHOP_BOT
		end

		if bot.ref:GetGold() >= cost
			and not IsItemPurchasedFromSecretShop(item)
			and not (IsItemPurchasedFromSideShop(item) and GetUnitToLocationDistance(bot.ref, side_shop_pos) < 3000)
		then
			local buy_res = bot.ref:ActionImmediate_PurchaseItem(item)
			if buy_res == PURCHASE_ITEM_SUCCESS then
				print("Buying: " .. item)
				table.remove(buy_order, 1)
			end
			return
		end
	end

	-- Move overflow items to main item slots
	overflow_slot = nil
	empty_slot = nil
	for i = 0, 8 do
		if empty_slot ~= nil and overflow_slot ~= nil then
			break
		end
		local slot_type = bot.ref:GetItemSlotType(i)
		local item = bot.ref:GetItemInSlot(i)
		if slot_type == ITEM_SLOT_TYPE_BACKPACK and item ~= nil then
			overflow_slot = i
		elseif slot_type == ITEM_SLOT_TYPE_MAIN and item == nil then
			empty_slot = i
		end
	end
	if overflow_slot and empty_slot then
		bot.ref:ActionImmediate_SwapItems(empty_slot, overflow_slot)
		return
	end

	-- Check for important items in stash
	local important_item = false
	for i = 9, 15 do
		local item = bot.ref:GetItemInSlot(i)
		if item ~= nil
			and string.find(item:GetName(), "recipe") ~= nil
		then
			important_item = true
			break
		end
	end

	-- Use Courier
	if GetNumCouriers() ~= 0 then
		local courier = GetCourier(0)
		local state = GetCourierState(courier)
		if bot.ref:IsAlive()
			and state ~= COURIER_STATE_DEAD
			and state ~= COURIER_STATE_DELIVERING_ITEMS
			and (bot.ref:GetStashValue() > 400 or bot.ref:GetCourierValue() > 0 or important_item)
		then
			bot.ref:ActionImmediate_Courier(courier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS)
			return
		end
	end

	items = GetItems(bot)
	-- Sell laning items
	if DotaTime() > 750 and empty_slot == nil
		and items["item_stout_shield"] or items["item_quelling_blade"]
		and bot.ref:DistanceFromFountain() < SHOP_USE_DISTANCE
		or GetUnitToLocationDistance(bot.ref, SIDE_SHOP_TOP) < SHOP_USE_DISTANCE
		or GetUnitToLocationDistance(bot.ref, SIDE_SHOP_BOT) < SHOP_USE_DISTANCE
		or GetUnitToLocationDistance(bot.ref, SECRET_SHOP_RADIANT) < SHOP_USE_DISTANCE
		or GetUnitToLocationDistance(bot.ref, SECRET_SHOP_DIRE) < SHOP_USE_DISTANCE
	then
		if items["item_quelling_blade"] then
			bot.ref:ActionImmediate_SellItem(items["item_quelling_blade"])
			return
		elseif items["item_stout_shield"] then
			bot.ref:ActionImmediate_SellItem(items["item_stout_shield"])
			return
		end
	end

	UseItems(bot)
end