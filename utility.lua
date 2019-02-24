SHOP_USE_DISTANCE = 200
SHOP_TYPE_NONE = 0
SHOP_TYPE_SECRET = 1
SHOP_TYPE_SIDE = 2
SIDE_SHOP_TOP = Vector(-7220, 4430)
SIDE_SHOP_BOT = Vector(7249, -4113)
SECRET_SHOP_RADIANT = Vector(-4472, 1328)
SECRET_SHOP_DIRE = Vector(4586, -1588)
FOUNTAIN_RADIANT = Vector(-7093, -6542)
FOUNTAIN_DIRE = Vector(7015, 6534)

function DeepCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
		end
		setmetatable(copy, DeepCopy(getmetatable(orig)))
	else
		copy = orig
	end
	return copy
end

-- Takes two vec2
-- Returns the euclidean distance
function GetDistance(a, b)
	local x = a[1] - b[1]
	local y = a[2] - b[2]
	return math.sqrt(x * x + y * y)
end

function UpdateBot(bot)
    name = bot.ref:GetUnitName()
	bot.name = string.sub(name, 15, string.len(name))
	bot.hp_max = bot.ref:GetMaxHealth()
	bot.hp_current =  bot.ref:GetHealth()
	bot.hp_percent = bot.hp_current / bot.hp_max
	bot.mp_max = bot.ref:GetMaxMana()
	bot.mp_current = bot.ref:GetMana()
	bot.mp_percent = bot.mp_current / bot.mp_max
	bot.location = bot.ref:GetLocation()
end

function GetEnemyTeam()
	if GetTeam() == TEAM_RADIANT then
		return TEAM_DIRE
	end
	return TEAM_RADIANT
end

-- Returns table of items indexed on item name
function GetItems(bot)
	local items = {}
	for i = 0, 5 do
		local item = bot.ref:GetItemInSlot(i)
		if (item ~= nil) then
			items[item:GetName()] = item
		end
	end
	return items
end

function GetItemsCount(bot)
	local count = 0
	for i = 0, 5 do
		local item = bot.ref:GetItemInSlot(i)
		if (item ~= nil) then
			count = count + 1
		end
	end
	return count
end

function GetStartingLane(lane)
    if GetTeam() == TEAM_RADIANT then
        if lane == 1 then
            return LANE_TOP
        else
            return LANE_BOT
        end
    end
    if lane == 1 then
        return LANE_BOT
    end
    return LANE_TOP
end

function GetLaneTower(bot)
	if GetTower(GetTeam(), ((bot.lane - 1) * 3) + 0) ~= nil then
		return GetTower(GetTeam(), ((bot.lane - 1) * 3) + 0)
	elseif GetTower(GetTeam(), ((bot.lane - 1) * 3) + 1) ~= nil then
		return GetTower(GetTeam(), ((bot.lane - 1) * 3) + 1)
	elseif GetTower(GetTeam(), ((bot.lane - 1) * 3) + 2) ~= nil then
		return GetTower(GetTeam(), ((bot.lane - 1) * 3) + 2)
	end
	return nil
end

function RetreatLocation(bot)
	if GetTower(GetTeam(), ((bot.lane - 1) * 3) + 0) ~= nil and bot.ref:DistanceFromFountain() > 11500 then
		return GetTower(GetTeam(), ((bot.lane - 1) * 3) + 0):GetLocation()
	elseif GetTower(GetTeam(), ((bot.lane - 1) * 3) + 1) ~= nil and bot.ref:DistanceFromFountain() > 7000 then
		return GetTower(GetTeam(), ((bot.lane - 1) * 3) + 1):GetLocation()
	elseif GetTower(GetTeam(), ((bot.lane - 1) * 3) + 2) ~= nil  and bot.ref:DistanceFromFountain() > 3000 then
		return GetTower(GetTeam(), ((bot.lane - 1) * 3) + 2):GetLocation()
	end

	if GetTeam() == TEAM_RADIANT then
		return FOUNTAIN_RADIANT
	end
	return FOUNTAIN_DIRE
end

function GetFountain()
	if GetTeam() == TEAM_RADIANT then
		return FOUNTAIN_RADIANT
	end
	return FOUNTAIN_DIRE
end

function GetUnitHealthPercentage(unit)
	return unit:GetHealth() / unit:GetMaxHealth()
end

-- GetNearbyVisibleTowers(bot, 1600, true)
-- GetNearbyVisibleBarracks(bot, 1600, true)

function GetNearbyVisibleTowers(bot, radius, enemy)
	local visible_towers = {}
	local towers = bot.ref:GetNearbyTowers(1600, enemy)
	for i = 1, #towers do
		if towers[i]:GetHealth() > 0 then
			table.insert(visible_towers, towers[i])
		end
	end
	return visible_towers
end

function GetNearbyVisibleBarracks(bot, radius, enemy)
	local visible_barracks = {}
	local barracks = bot.ref:GetNearbyBarracks(radius, enemy)
	for i = 1, #barracks do
		if barracks[i]:GetHealth() > 0 then
			table.insert(visible_barracks, barracks[i])
		end
	end
	return visible_barracks
end

function ShouldTrade(bot, target)
	if (bot.hp_current / bot.total_damage) > TimeToLive(target) then
		return 1
	end
	return 0
end

function TimeToLive(hero)
	return target:GetHealth() / TotalDamage(hero)
end

function TotalDamage(hero)
	local total_damage = 0
	local enemy_creeps = hero:GetNearbyCreeps(500, true)
	local enemy_towers = GetNearbyVisibleTowers(hero, 950, true)
	local enemy_heroes = hero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	if enemy_creeps ~= nil then
		for i = 1, #enemy_creeps do
			if enemy_creeps[i]:GetAttackTarget() == hero then
				total_damage = total_damage + enemy_creeps[i]:GetEstimatedDamageToTarget(true, hero, 100, DAMAGE_TYPE_ALL)
			end
		end
	end
	if enemy_towers ~= nil then
		for i = 1, #enemy_towers do
			if enemy_towers[i]:GetAttackTarget() == hero then
				total_damage = total_damage + nemy_towers[i]:GetEstimatedDamageToTarget(true, hero, 100, DAMAGE_TYPE_ALL)
			end
		end
	end
	if enemy_heroes ~= nil then
		for i = 1, #enemy_heroes do
			if enemy_heroes[i]:GetAttackTarget() == hero then
				total_damage = total_damage + enemy_heroes[i]:GetEstimatedDamageToTarget(true, hero, 100, DAMAGE_TYPE_ALL)
			end
		end
	end
	return total_damage / 100
end
