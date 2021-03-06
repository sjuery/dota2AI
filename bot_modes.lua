require(GetScriptDirectory() .. "/upkeep")

require(GetScriptDirectory() .. "/modes/farm")
require(GetScriptDirectory() .. "/modes/fight")
require(GetScriptDirectory() .. "/modes/heal")
require(GetScriptDirectory() .. "/modes/push")
require(GetScriptDirectory() .. "/modes/retreat")
require(GetScriptDirectory() .. "/modes/rune")
require(GetScriptDirectory() .. "/modes/shop")
require(GetScriptDirectory() .. "/modes/teleport")

generic_priority = {
	["farm"] = {FarmPriority, Farm},
	["retreat"] = {RetreatPriority, Retreat},
	["teleport"] = {TeleportPriority, Teleport},
	["heal"] = {HealPriority, Heal},
	["shop"] = {ShopPriority, Shop},
	["push"] = {PushPriority, Push},
	["fight"] = {FightPriority, Fight},
	["rune"] = {RunePriority, Rune}
}

function Thonk(bot, priority)
	if not bot.ref:IsAlive() then
		return
	end

	local priority_best = -1
	local priority_value = nil
	local priority_mode = nil
	local priority_name

	for name, thonkage in pairs(priority) do
		local priority, value = thonkage[1](bot)
		if priority > priority_best then
			priority_best = priority
			priority_value = value
			priority_mode = thonkage[2]
			priority_name = name
		end
	end
	if priority_name ~= bot.priority_name then
		local old = bot.priority_name or "start"
		local old_priority = bot.priority or 0
		print(
			bot.name .. ": " .. old .. "(" .. old_priority ..
			") -> " .. priority_name .. "(" .. priority_best .. ")"
		)
	end
	priority_mode(bot, priority_value)
	bot.priority_name = priority_name
	bot.priority = priority_best
	UpKeep(bot)
end
