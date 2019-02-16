function Start(npcBot)
	if GetTeam() == TEAM_RADIANT then
        if npcBot:GetPlayerID() == 2 or npcBot:GetPlayerID() == 7 then
            npcBot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_2))
            npcBot:Action_PickUpRune(RUNE_BOUNTY_2)
        elseif npcBot:GetPlayerID() == 5 or npcBot:GetPlayerID() == 6 or npcBot:GetPlayerID() == 10 or npcBot:GetPlayerID() == 11 then
            npcBot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_2)+Vector(-250, 1000))
            npcBot:Action_PickUpRune(RUNE_BOUNTY_2)
        elseif npcBot:GetPlayerID() == 3 or npcBot:GetPlayerID() == 4 or npcBot:GetPlayerID() == 8 or npcBot:GetPlayerID() == 9 then
            npcBot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_1))
            npcBot:Action_PickUpRune(RUNE_BOUNTY_1)
        end
    else
        if npcBot:GetPlayerID() == 2 or npcBot:GetPlayerID() == 7 then
            npcBot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_4))
            npcBot:Action_PickUpRune(RUNE_BOUNTY_4)
        elseif npcBot:GetPlayerID() == 5 or npcBot:GetPlayerID() == 6 or npcBot:GetPlayerID() == 10 or npcBot:GetPlayerID() == 11 then
            npcBot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_4)+Vector(-350, -600))
            npcBot:Action_PickUpRune(RUNE_BOUNTY_4)
        elseif npcBot:GetPlayerID() == 3 or npcBot:GetPlayerID() == 4 or npcBot:GetPlayerID() == 8 or npcBot:GetPlayerID() == 9 then
            npcBot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_3))
            npcBot:Action_PickUpRune(RUNE_BOUNTY_3)
        end
    end
end

function AttackEnemyCreep(npcBot)
	local desire = 1
	local listEnemyCreep = npcBot:GetNearbyCreeps(1200, true)
    if #listEnemyCreep == 0 then
        return desire, nil
    end

    local weakestCreep = nil
    local lowestHealth = 100000
    for _,creep in pairs(listEnemyCreep) do
    	if creep:GetHealth() then
    		if lowestHealth > creep:GetHealth() then
    			weakestCreep = creep
    			lowestHealth = creep:GetHealth()
    		end
    	end
    end

    if lowestHealth <= npcBot:GetAttackDamage() then
    	desire = 100
    elseif lowestHealth <= npcBot:GetAttackDamage() * 2 then
    	desire = 0
    else
    	desire = 80
    end
    return desire, weakestCreep
end

function DenyAlliedCreep(npcBot)
	local desire = 1
	local listAlliedCreep = npcBot:GetNearbyCreeps(1200, false)
    if #listAlliedCreep == 0 then
        return desire, nil
    end

    local weakestCreep = nil
    local lowestHealth = 100000
    for _,creep in pairs(listAlliedCreep) do
    	if creep:GetHealth() then
	    	if lowestHealth > creep:GetHealth() then
	    		weakestCreep = creep
	    		lowestHealth = creep:GetHealth()
	    	end
	    end
    end

    if lowestHealth <= npcBot:GetAttackDamage() then
    	desire = 90
    end
    return desire, weakestCreep
end

function Think()
	local npcBot = GetBot()
	local desire_scores = {}
	local highest_score = 0
	local highest_task = nil

	if DotaTime() <= 0.3 then
		Start(npcBot)
		return
	end

	--create a function for each desire_score that will assign needed variables (such as enemy to hit, vec3 to relocate...) and desire score.
	desire_scores['hit_enemy_tower'] = 1
	desire_scores['hit_enemy_hero'] = 1
	desire_scores['hit_enemy_creep'], creepToHit = AttackEnemyCreep(npcBot)
	desire_scores['deny_ally_creep'], creepToDeny = DenyAlliedCreep(npcBot)
	desire_scores['change_position'] = 1
	desire_scores['retreat'] = 1
	desire_scores['return_to_base'] = 1
	desire_scores['secret_rush'] = 1
	desire_scores['secret_immobile'] = 1

	for task, desire in pairs(desire_scores) do
		if desire > highest_score then
			highest_task = task
			highest_score = desire
		end
	end

	if npcBot:GetPlayerID() == 2 or npcBot:GetPlayerID() == 7 then
		npcBot:Action_MoveToLocation(GetLaneFrontLocation(GetTeam(), LANE_MID, 300.0))
	elseif npcBot:GetPlayerID() == 3 or npcBot:GetPlayerID() == 4 or npcBot:GetPlayerID() == 8 or npcBot:GetPlayerID() == 9 then
		npcBot:Action_MoveToLocation(GetLaneFrontLocation(GetTeam(), LANE_BOT, 300.0))
	elseif npcBot:GetPlayerID() == 5 or npcBot:GetPlayerID() == 6 or npcBot:GetPlayerID() == 10 or npcBot:GetPlayerID() == 11 then
		npcBot:Action_MoveToLocation(GetLaneFrontLocation(GetTeam(), LANE_TOP, 300.0))
	end

	if highest_task == 'hit_enemy_tower' then
		npcBot:Action_AttackUnit(towerToHit, true)
		return
	end
	
	if highest_task == 'hit_enemy_hero' then
		--Hit Enemy Hero
		return
	end

	if highest_task == 'hit_enemy_creep' then
		npcBot:Action_AttackUnit(creepToHit, true)
		return
	end

	if highest_task == 'deny_ally_creep' then
		npcBot:Action_AttackUnit(creepToDeny, true)
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
	return
end