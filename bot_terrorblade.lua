require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local desires = DeepCopy(generic_desires)

local bot = {
	["ref"] = GetBot(),
	["lane"] = LANE_MID
}

function Think()
	UpdateBot(bot)
	Thonk(bot, desires)
end
