require(GetScriptDirectory() .. "../utility")

function TeleportPriority(bot)
	if DotaTime() < 120 then
		return {0, nil}
	end
	local slot = bot.ref:FindItemSlot("item_tpscroll")
	local tp_scroll = bot.ref:GetItemInSlot(slot)

	if bot.name == "furion" then
		tp = bot.ref:GetAbilityByName("furion_teleportation")
		if tp then
			tp_scroll = tp
		end
	end

	if not tp_scroll or bot.mp_current < tp_scroll:GetManaCost()
		or not tp_scroll:IsFullyCastable() or bot.ref:IsChanneling() or bot.ref:IsUsingAbility() then
		return {0, nil}
	end

	if tp_scroll:IsChanneling() then
		return {80, {nil, nil}}
	end

	local target = GetFountain()

	allied_towers = bot.ref:GetNearbyTowers(300, false)
	if #allied_towers > 0 and bot.hp_percent < 0.33 then
		return {80, {tp_scroll, target}}
	end

	return {0, nil}
end

function Teleport(bot, params)
	local tp_scroll, target = unpack(params)
	if tp_scroll then
		bot.ref:Action_UseAbilityOnLocation(tp_scroll, target)
	end
end