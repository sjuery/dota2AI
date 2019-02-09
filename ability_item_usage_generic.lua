function CourierUsageThink()
	local npcBot = GetBot()

	npcBot:ActionImmediate_Courier(GetCourier(1), COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS)
end