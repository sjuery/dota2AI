
-- Does not seem to work, may be because action queue is full?
function UseItems()
	local bot = GetBot()

	local max_hp = bot:GetMaxHealth()
	local current_hp = bot:GetHealth()

	local hp_percent = current_hp / max_hp
	local tango = IsItemAvailable(bot, "item_tango")
	if hp_percent < 0.9 and tango ~= nil then
		bot:Action_UseAbility(tango)
	end
end