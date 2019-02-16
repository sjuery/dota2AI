function GetDistance(s, t)
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

function runAway(start, towards, distance)
    local facing = start - towards
    local direction = facing / GetDistance(facing, Vector(0,0)) --normalized
    return start + (direction * distance)
end

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
	local listAlliedCreep = npcBot:GetNearbyCreeps(1200, false)
    if #listEnemyCreep == 0 then
        return desire, nil
    end

    local listEnemyTowers = npcBot:GetNearbyTowers(1200, true)
    if #listEnemyTowers > 0 then
        local dist = GetUnitToUnitDistance(npcBot, listEnemyTowers[1])
        if dist < 750 then
            npcBot:Action_MoveToLocation(runAway(npcBot:GetLocation(), listEnemyTowers[1]:GetLocation(), 1000-dist))
            return
        end
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

    if lowestHealth <= npcBot:GetEstimatedDamageToTarget(true, weakestCreep, npcBot:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) then
    	desire = 100
    elseif lowestHealth <= npcBot:GetEstimatedDamageToTarget(true, weakestCreep, npcBot:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) * 1.5 then
    	desire = 70
    	weakestCreep = listEnemyCreep[1];
    else
    	desire = 80
    end
    return desire, weakestCreep
end

function AttackTower(npcBot)
	local listNearbyETowers = npcBot:GetNearbyTowers(1200, true)
	local listAlliedCreep = npcBot:GetNearbyCreeps(1200, false)
	if #listNearbyETowers <= 0 then
		return 0, nil
	end
	if #listAlliedCreep <= 2 then
		return 0, nil
	end
	return 111, listNearbyETowers[1]
end

function AttackEnemy(npcBot)
	local listNearbyEHeroes = npcBot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local listNearbyAHeroes = npcBot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
	if #listNearbyEHeroes > #listNearbyAHeroes then
		return 0, nil
	end
	return 95, listNearbyEHeroes[1]
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

    if lowestHealth <= npcBot:GetEstimatedDamageToTarget(true, weakestCreep, npcBot:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) then
    	desire = 90
    end
    return desire, weakestCreep
end

function Retreat(npcBot)
	local health = npcBot:GetHealth()
	local maxhealth = npcBot:GetMaxHealth()
	local healthPerc = health / maxhealth

	nearETowers = npcBot:GetNearbyTowers(1200, true)
	if healthPerc < 0.4 then
        return 80
    elseif healthPerc < 0.2 then
    	return 5000
    end

    if npcBot:WasRecentlyDamagedByCreep(1.0) then
        return 80
    end

    if #nearETowers > 0 then
        return 110
    end
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
	desire_scores['hit_enemy_hero'], heroToHit = AttackEnemy(npcBot)
	desire_scores['hit_enemy_creep'], creepToHit = AttackEnemyCreep(npcBot)
	desire_scores['deny_ally_creep'], creepToDeny = DenyAlliedCreep(npcBot)
	desire_scores['change_position'] = 1
	desire_scores['retreat'] = Retreat(npcBot)
	desire_scores['return_to_base'] = 1
	desire_scores['secret_rush'] = 1
	desire_scores['secret_immobile'] = 1

	for task, desire in pairs(desire_scores) do
		if desire > highest_score then
			highest_task = task
			highest_score = desire
		end
	end

	if GetTeam() == TEAM_RADIANT then
		enemyTeam = TEAM_DIRE
	else
		enemyTeam = TEAM_RADIANT
	end

	if npcBot:GetPlayerID() == 2 or npcBot:GetPlayerID() == 7 then
		front = GetLaneFrontAmount(GetTeam(), LANE_MID, false)
    	enemyfront = GetLaneFrontAmount(enemyTeam, LANE_MID, false)
    	front = Min(front, enemyfront)
    	dest = GetLocationAlongLane(LANE_MID, Min(1.0, front))
		npcBot:Action_MoveToLocation(dest)
	elseif npcBot:GetPlayerID() == 3 or npcBot:GetPlayerID() == 4 or npcBot:GetPlayerID() == 8 or npcBot:GetPlayerID() == 9 then
		front = GetLaneFrontAmount(GetTeam(), LANE_BOT, false)
    	enemyfront = GetLaneFrontAmount(enemyTeam, LANE_BOT, false)
    	front = Min(front, enemyfront)
    	dest = GetLocationAlongLane(LANE_BOT, Min(1.0, front))
		npcBot:Action_MoveToLocation(dest)
	elseif npcBot:GetPlayerID() == 5 or npcBot:GetPlayerID() == 6 or npcBot:GetPlayerID() == 10 or npcBot:GetPlayerID() == 11 then
		front = GetLaneFrontAmount(GetTeam(), LANE_TOP, false)
    	enemyfront = GetLaneFrontAmount(enemyTeam, LANE_TOP, false)
    	front = Min(front, enemyfront)
    	dest = GetLocationAlongLane(LANE_TOP, Min(1.0, front))
		npcBot:Action_MoveToLocation(dest)
	end

	if highest_task == 'hit_enemy_tower' then
		npcBot:Action_AttackUnit(towerToHit, true)
		return
	end
	
	if highest_task == 'hit_enemy_hero' then
		npcBot:Action_AttackUnit(heroToHit, true)
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
		if npcBot:GetPlayerID() == 2 or npcBot:GetPlayerID() == 7 then
			front = GetLaneFrontAmount(GetTeam(), LANE_MID, false)
	    	enemyfront = GetLaneFrontAmount(enemyTeam, LANE_MID, false)
	    	front = Min(front, enemyfront)
			pos = GetLocationAlongLane(LANE_MID, front - 0.05) + RandomVector(200)
		elseif npcBot:GetPlayerID() == 3 or npcBot:GetPlayerID() == 4 or npcBot:GetPlayerID() == 8 or npcBot:GetPlayerID() == 9 then
			front = GetLaneFrontAmount(GetTeam(), LANE_BOT, false)
	    	enemyfront = GetLaneFrontAmount(enemyTeam, LANE_BOT, false)
	    	front = Min(front, enemyfront)
			pos = GetLocationAlongLane(LANE_BOT, front - 0.05) + RandomVector(200)
		elseif npcBot:GetPlayerID() == 5 or npcBot:GetPlayerID() == 6 or npcBot:GetPlayerID() == 10 or npcBot:GetPlayerID() == 11 then
			front = GetLaneFrontAmount(GetTeam(), LANE_TOP, false)
	    	enemyfront = GetLaneFrontAmount(enemyTeam, LANE_TOP, false)
	    	front = Min(front, enemyfront)
	    	pos = GetLocationAlongLane(LANE_TOP, front - 0.05) + RandomVector(200)
		end
	    npcBot:Action_MoveToLocation(pos)
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