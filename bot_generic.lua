local players = GetTeamPlayers(GetTeam())
local botPlayers = {};

for _,id in pairs(players) do
	table.insert(botPlayers, id)
end

function Think()
	local npcBot = GetBot()

	if npcBot:GetNearbyHeroes(1599, true, BOT_MODE_NONE) then
		npcBot:Action_AttackUnit(npcBot:GetNearbyHeroes(1599, true, BOT_MODE_NONE)[1], false)
	end
	if npcBot:GetPlayerID() == 2 or npcBot:GetPlayerID() == 7 then
		npcBot:Action_MoveToLocation(GetLaneFrontLocation(GetTeam(), LANE_MID, 0.0))
	elseif npcBot:GetPlayerID() == 3 or npcBot:GetPlayerID() == 4 or npcBot:GetPlayerID() == 8 or npcBot:GetPlayerID() == 9 then
		npcBot:Action_MoveToLocation(GetLaneFrontLocation(GetTeam(), LANE_BOT, 0.0))
	elseif npcBot:GetPlayerID() == 5 or npcBot:GetPlayerID() == 6 or npcBot:GetPlayerID() == 10 or npcBot:GetPlayerID() == 11 then
		npcBot:Action_MoveToLocation(GetLaneFrontLocation(GetTeam(), LANE_TOP, 0.0))
	end
end