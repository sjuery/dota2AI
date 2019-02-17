require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local desires = DeepCopy(generic_desires)

function CustomMode(bot, value)
	print("am custom")
end

desires["farm"][2] = CustomMode

function Think()
	local bot = GetBot()
	Thonk(bot, desires)
end