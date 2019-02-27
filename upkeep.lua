require(GetScriptDirectory() .. "/utility")

function UseItems(bot)
	local allies = bot.ref:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
	local items = GetItems(bot)

	-- Use mana boots
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
		and (bot.priority_name == "retreat" or bot.priority_name == "fight") and bot.priority > 50
	then
		print("Using phase boots..")
		bot.ref:Action_UseAbility(phase_boots)
		return
	end

	-- Use blade mail
	local blade_mail = items["item_blade_mail"]
	if blade_mail ~= nil and blade_mail:GetManaCost() <= bot.mp_current and blade_mail:IsFullyCastable()
		and bot.ref:WasRecentlyDamagedByAnyHero(0.2)
	then
		print("Using blade mail..")
		bot.ref:Action_UseAbility(blade_mail)
		return
	end

	-- Use soul ring if hp > 60% and we need mana
	local soul_ring = items["item_soul_ring"]
	if soul_ring ~= nil and soul_ring:IsFullyCastable()
		and bot.hp_percent > 0.6 and (bot.mp_max - bot.mp_current) > 150 and bot.mp_percent < 0.7
	then
		bot.ref:Action_UseAbility(soul_ring)
		return
	end

	-- Use moonshard to gain buff if we have no slots
	local moonshard = items["item_moon_shard"]
	if moonshard ~= nil and moonshard:IsFullyCastable()
		and GetItemsCount(bot) > 6
	then
		bot.ref:Action_UseAbility(moonshard)
	end

	-- Use manta style if fighting
	local manta_style = items["item_manta"]
	if manta_style ~= nil and bot.priority_name == "fight" and manta_style:GetManaCost() <= bot.mp_current and manta_style:IsFullyCastable() then
		bot.ref:Action_UseAbility(manta_style)
	end

	local power_treads = items["item_power_treads"]

	if power_treads ~= nil then
		local power_stat = {
			[0] = ATTRIBUTE_STRENGTH,
			[1] = ATTRIBUTE_INTELLECT,
			[2] = ATTRIBUTE_AGILITY
		}
		local tread_stat = power_stat[power_treads:GetPowerTreadsStat()]
		if bot.ref:HasModifier("modifier_flask_healing") or bot.ref:HasModifier("modifier_filler_heal")
			and tread_stat == ATTRIBUTE_STRENGTH
		then
			bot.ref:Action_UseAbility(power_treads)
			return
		else
			local primary_attribute = bot.ref:GetPrimaryAttribute()
			if tread_stat ~= primary_attribute then
				bot.ref:Action_UseAbility(power_treads)
			end
		end
	end
end

function UpKeep(bot)
	if GetGlyphCooldown() == 0 then
		local tower = GetLaneTower(bot)
		if tower and tower:TimeSinceDamagedByAnyHero() < 3 then
			bot.ref:ActionImmediate_Glyph()
			return
		end
	end

	-- Upgrade abilities
	if bot.ability_order then
		if bot.ref:GetAbilityPoints() > 0 then
			local ability = bot.ref:GetAbilityByName(bot.ability_order[1])
			if (ability:CanAbilityBeUpgraded() and ability:GetLevel() < ability:GetMaxLevel()) then
				bot.ref:ActionImmediate_LevelAbility(bot.ability_order[1])
				table.remove(bot.ability_order, 1)
				return
			end
		end
	end

	-- Buy items
	local buy_order = {}
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

	-- Add TP scrolls to buy order if needed
	local slot = bot.ref:FindItemSlot("item_tpscroll")
	local tp_scroll = bot.ref:GetItemInSlot(slot)
	if not tp_scroll then
		if bot.buy_order and bot.buy_order[1] ~= "item_tpscroll" then
			table.insert(bot.buy_order, 1, "item_tpscroll")
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

	-- Use courier
	if GetNumCouriers() ~= 0 then
		local courier = GetCourier(0)
		local state = GetCourierState(courier)
		if bot.ref:IsAlive()
			and state ~= COURIER_STATE_DEAD
			and state ~= COURIER_STATE_DELIVERING_ITEMS
			and (bot.ref:GetStashValue() > 500 or bot.ref:GetCourierValue() > 0 or important_item or bot.lane == "mid")
		then
			bot.ref:ActionImmediate_Courier(courier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS)
			return
		end
	end

	-- Generic sell order
	local sell_order = {
		"item_quelling_blade",
		"item_stout_shield"
	}

	if bot.sell_order ~= nil then
		sell_order = bot.sell_order
	end

	local items = GetItems(bot)
	-- Sell old items
	if DotaTime() > 800 and empty_slot == nil and #sell_order > 0
		and bot.ref:DistanceFromFountain() < SHOP_USE_DISTANCE
		or GetUnitToLocationDistance(bot.ref, SIDE_SHOP_TOP) < SHOP_USE_DISTANCE
		or GetUnitToLocationDistance(bot.ref, SIDE_SHOP_BOT) < SHOP_USE_DISTANCE
		or GetUnitToLocationDistance(bot.ref, SECRET_SHOP_RADIANT) < SHOP_USE_DISTANCE
		or GetUnitToLocationDistance(bot.ref, SECRET_SHOP_DIRE) < SHOP_USE_DISTANCE
	then
		if items[sell_order[1]] ~= nil then
			bot.ref:ActionImmediate_SellItem(items[sell_order[1]])
			return
		end
		table.remove(sell_order, 1)
	end

	UseItems(bot)
end