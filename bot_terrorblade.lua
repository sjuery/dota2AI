require(GetScriptDirectory() .. "/bot_modes")
require(GetScriptDirectory() .. "/utility")

local desires = DeepCopy(generic_desires)

if GetTeam() == TEAM_RADIANT then
    enemyTeam = TEAM_DIRE
else
    enemyTeam = TEAM_RADIANT
end

local botInfo = {
	['bot'] = GetBot(),
	['team'] = GetTeam(),
	['eteam'] = enemyTeam,
	['lane'] = "Middle"
}

function Think()
	Thonk(botInfo, desires)
end