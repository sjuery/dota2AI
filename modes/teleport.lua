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

	if tp_scroll and bot.ref:HasModifier("modifier_teleporting") then
		return {100, {nil, nil}}
	end

	if not tp_scroll or bot.mp_current < tp_scroll:GetManaCost()
		or not tp_scroll:IsFullyCastable() or bot.ref:IsUsingAbility() then
		return {0, nil}
	end

	local target = GetLaneTower(bot)
	if target == nil then
		return {0, nil}
	else
		target = target:GetLocation() + RandomVector(150)
	end
	local fountain = GetFountain()

	--allied_towers = GetNearbyVisibleTowers(bot, 400, false)
	-- if #allied_towers > 0 and bot.hp_percent < 0.33 then

	if (bot.ref:HasModifier("modifier_fountain_aura") or bot.ref:HasModifier("modifier_fountain_aura_buff")) and bot.hp_percent > 0.7 then
		return {100, {tp_scroll, target}}
	end

	return {0, nil}
end

function Teleport(bot, params)
	local tp_scroll, target = unpack(params)
	if tp_scroll then
		bot.ref:Action_ClearActions(true)
		bot.ref:Action_UseAbilityOnLocation(tp_scroll, target)
	end
end
