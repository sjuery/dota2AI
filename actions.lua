function HitEnemyTower()
	local desire = 1
	local towerToHit

	towerToHit = npcBot:GetNearbyTowers(1599, true)
	return desire, towerToHit
end

function Empty()
	
end