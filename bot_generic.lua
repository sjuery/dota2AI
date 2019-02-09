local players = GetTeamPlayers(GetTeam())
local botPlayers = {};

for _,id in pairs(players) do
	table.insert(botPlayers, id)
end

function HitEnemyTower()
	local desire = 1
	local towerToHit

	towerToHit = npcBot:GetNearbyTowers(1599, true)
	return desire, towerToHit
end

function Think()
	npcBot = GetBot()
	local desire_scores = {}
	local highest_score = 0

	--create a function for each desire_score that will assign needed variables (such as enemy to hit, vec3 to relocate...) and desire score.
	desire_scores['hit_enemy_tower'], towerToHit = HitEnemyTower()
	desire_scores['hit_enemy_hero'] = 1
	desire_scores['hit_enemy_creep'] = 1
	desire_scores['deny_ally_creep'] = 1
	desire_scores['change_position'] = 1
	desire_scores['retreat'] = 1
	desire_scores['return_to_base'] = 1
	desire_scores['secret_rush'] = 1
	desire_scores['secret_immobile'] = 1

	for task, desire_score in pairs(desire_scores) do
		if desire_score > highest_score then
			highest_task = task
		end
	end

	if highest_task == 'hit_enemy_tower' then
		--Hit Enemy Tower Code
		return
	end
	
	if highest_task == 'hit_enemy_hero' then
		--Hit Enemy Hero
		return
	end

	if highest_task == 'hit_enemy_creep' then
		--Hit Enemy Creep
		return
	end

	if highest_task == 'deny_ally_creep' then
		--Deny Ally Creep
		return
	end

	if highest_task == 'change_position' then
		--Change Position
		return
	end

	if highest_task == 'retreat' then
		--Go back to base
		return
	end

	if highest_task == 'return_to_base' then
		--Return to base
		return
	end

	if highest_task == 'secret_rush' then
		--Use 'Do you even move bro'
		return
	end

	if highest_task == 'secret_immobile' then
		--Use 'ur base lol'
		return
	end

	if npcBot:GetPlayerID() == 2 or npcBot:GetPlayerID() == 7 then
		npcBot:Action_MoveToLocation(GetLaneFrontLocation(GetTeam(), LANE_MID, 0.0))
	elseif npcBot:GetPlayerID() == 3 or npcBot:GetPlayerID() == 4 or npcBot:GetPlayerID() == 8 or npcBot:GetPlayerID() == 9 then
		npcBot:Action_MoveToLocation(GetLaneFrontLocation(GetTeam(), LANE_BOT, 0.0))
	elseif npcBot:GetPlayerID() == 5 or npcBot:GetPlayerID() == 6 or npcBot:GetPlayerID() == 10 or npcBot:GetPlayerID() == 11 then
		npcBot:Action_MoveToLocation(GetLaneFrontLocation(GetTeam(), LANE_TOP, 0.0))
	end
end