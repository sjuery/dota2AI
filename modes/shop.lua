require(GetScriptDirectory() .. "../utility")

function ShopPriority(bot)
	local buy_order = {}
	if bot.buy_order ~= nil then
		buy_order = bot.buy_order
	end

	if #buy_order == 0 or bot.ref:GetGold() < GetItemCost(buy_order[1]) - 10 then
		return 0, nil
	end
	local item = buy_order[1]

	local side_shop_pos = nil
	if bot.lane == LANE_TOP then
		side_shop_pos = SIDE_SHOP_TOP
	else
		side_shop_pos = SIDE_SHOP_BOT
	end

	local secret_shop_pos = nil
	if GetUnitToLocationDistance(bot.ref, SECRET_SHOP_RADIANT) < GetUnitToLocationDistance(bot.ref, SECRET_SHOP_DIRE) then
		secret_shop_pos = SECRET_SHOP_RADIANT
	else
		secret_shop_pos = SECRET_SHOP_DIRE
	end

	if IsItemPurchasedFromSideShop(item) and GetUnitToLocationDistance(bot.ref, side_shop_pos) < 3000
		and IsLocationPassable(side_shop_pos)
	then
		return 40, side_shop_pos
	elseif IsItemPurchasedFromSecretShop(item) and GetUnitToLocationDistance(bot.ref, secret_shop_pos) < 6000
		and IsLocationPassable(secret_shop_pos)
	then
		return 40, secret_shop_pos
	end

	return 0, nil
end

function Shop(bot, shop_pos)
	local buy_order = {}
	if bot.buy_order ~= nil then
		buy_order = bot.buy_order
	end
	local item = buy_order[1]
	bot.ref:Action_MoveToLocation(shop_pos)
	if GetUnitToLocationDistance(bot.ref, shop_pos) < SHOP_USE_DISTANCE then
		local buy_res = bot.ref:ActionImmediate_PurchaseItem(item)
		if buy_res == PURCHASE_ITEM_SUCCESS then
			print("Buying: " .. item .. "from shop")
			table.remove(buy_order, 1)
		end
	end
end
