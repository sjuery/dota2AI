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
	bot.hp_current = bot.ref:GetHealth()
	bot.hp_percent = bot.hp_current / bot.hp_max
	bot.mp_max = bot.ref:GetMaxMana()
	bot.mp_current = bot.ref:GetMana()
	bot.mp_percent = bot.mp_current / bot.mp_max
	bot.location = bot.ref:GetLocation()
	bot.range = bot.ref:GetBoundingRadius() + bot.ref:GetAttackRange()
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

function GetItem(bot, name)
	local slot = bot.ref:FindItemSlot(name)
	return bot.ref:GetItemInSlot(slot)
end

function GetItemsCount(bot)
	local count = 0
	for i = 0, 5 do
		local item = bot.ref:GetItemInSlot(i)
		if item ~= nil then
			count = count + 1
		end
	end
	return count
end

function CanCast(bot, ability)
	if bot.ref:IsChanneling() or bot.ref:IsUsingAbility() or not ability:IsOwnersManaEnough() or not ability:IsFullyCastable() then
		return false
	end
	return true
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
	local team = GetTeam()

	if GetTower(team, ((bot.lane - 1) * 3) + 0) ~= nil then
		return GetTower(team, ((bot.lane - 1) * 3) + 0)
	elseif GetTower(team, ((bot.lane - 1) * 3) + 1) ~= nil then
		return GetTower(team, ((bot.lane - 1) * 3) + 1)
	elseif GetTower(team, ((bot.lane - 1) * 3) + 2) ~= nil then
		return GetTower(team, ((bot.lane - 1) * 3) + 2)
	end
	return nil
end

function RetreatLocation(bot)
	local team = GetTeam()
	if GetTower(team, ((bot.lane - 1) * 3) + 0) ~= nil and bot.ref:DistanceFromFountain() > 11500 then
		return GetTower(team, ((bot.lane - 1) * 3) + 0):GetLocation()
	elseif GetTower(team, ((bot.lane - 1) * 3) + 1) ~= nil and bot.ref:DistanceFromFountain() > 7000 then
		return GetTower(team, ((bot.lane - 1) * 3) + 1):GetLocation()
	elseif GetTower(team, ((bot.lane - 1) * 3) + 2) ~= nil  and bot.ref:DistanceFromFountain() > 3000 then
		return GetTower(team, ((bot.lane - 1) * 3) + 2):GetLocation()
	end

	if team == TEAM_RADIANT then
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

local function FilterAlive(units)
	local alive = {}
	for i = 1, #units do
		if units[i]:GetHealth() > 0 then
			table.insert(alive, units[i])
		end
	end
	return alive
end

function GetNearbyVisibleTowers(bot, radius, enemy)
	return FilterAlive(bot.ref:GetNearbyTowers(radius, enemy))
end

function GetNearbyVisibleBarracks(bot, radius, enemy)
	return FilterAlive(bot.ref:GetNearbyBarracks(radius, enemy))
end

function GetNearbyVisibleShrines(bot, radius)
	return FilterAlive(bot.ref:GetNearbyShrines(radius, enemy))
end

function IsMelee(unit)
	return unit:GetAttackRange() < 320.0
end

function IsImmune(unit)
	return unit:IsAttackImmune() 
		or unit:HasModifier("modifier_item_cyclone")
		or unit:HasModifier("modifier_ghost_state")
		or unit:HasModifier("modifier_item_ethereal_blade_ethereal")
		or unit:HasModifier("modifier_invulnerable")
		or unit:HasModifier("modifier_attack_immune") 
end

function GetDirectionVector(unit)
	local angle = math.rad(unit:GetFacing())
	return Vector(math.cos(angle), math.sin(angle))
end

function Normalize(vec)
	return vec / GetDistance(vec, Vector(0, 0))
end

function AttackUnit(bot, enemy)
	-- Range info
	local range = bot.ref:GetBoundingRadius() + bot.ref:GetAttackRange()
	local enemy_range = enemy:GetBoundingRadius() + enemy:GetAttackRange()
	local distance = GetUnitToUnitDistance(bot.ref, enemy)

	-- Basic attack info
	local attack_last = bot.ref:GetLastAttackTime()
	local attack_time = bot.ref:GetSecondsPerAttack()
	local attack_speed = bot.ref:GetAttackSpeed()

	local enemy_pos = enemy:GetLocation()
	local away = Normalize(bot.location - enemy_pos)

	if distance < range then
		if IsMelee(bot.ref) then
			-- Use attack cooldown time to maneuver
			if attack_time + attack_last > GameTime() and distance > 50 then
				bot.ref:Action_MoveToUnit(enemy)
			else
				bot.ref:Action_AttackUnit(enemy, true)
			end
		else
			local attack_dist = range - 10
			if enemy:IsHero() then
				attack_dist = range * 0.7
			end

			-- Use attack cooldown time to maneuver
			if attack_time + attack_last > GameTime() then
				-- Move closer to enemy
				if distance > attack_dist then
					bot.ref:Action_MoveToUnit(enemy)
				-- Move out of range if we can
				elseif enemy:IsHero() and enemy_range < range then
					bot.ref:Action_MoveToLocation(bot.location + away * 10.0)
				elseif bot.lane == mid and GetHeightLevel(bot.location) <= GetHeightLevel(enemy_pos) then
					local search_range = Min(range * 0.7, 500)
					local best_height = GetHeightLevel(bot.location)
					local best_pos = nil
					for i = 0, 8 do
						local angle = ((math.pi / 4.0) * i) + math.rad(bot.ref:GetFacing())
						local search_pos = enemy_pos + (Normalize(Vector(math.cos(angle), math.sin(angle))) * search_range)
						local height = GetHeightLevel(search_pos)
						if IsLocationPassable(search_pos) and height > best_height then
							best_height = height
							best_pos = search_pos
						end
					end
					if best_height > GetHeightLevel(bot.location) then
						print(bot.name .. ": moving to high ground")
						bot.ref:Action_MoveToLocation(best_pos)
					else
						print(bot.name .. ": no higher ground.. :(")
					end
				end
			else
				bot.ref:Action_AttackUnit(enemy, true)
			end
		end
	else
		bot.ref:Action_MoveToUnit(enemy)
	end
end

function AttackBuilding(bot, building)
	-- Range info
	local range = bot.ref:GetBoundingRadius() + bot.ref:GetAttackRange()
	local distance = GetUnitToUnitDistance(bot.ref, building)

	-- Basic attack info
	local attack_last = bot.ref:GetLastAttackTime()
	local attack_time = bot.ref:GetSecondsPerAttack()
	local attack_speed = bot.ref:GetAttackSpeed()

	local away = Normalize(RetreatLocation(bot) - bot.location)

	if distance < range then
		-- Use attack cooldown time to manuver away from building if ranged
		if attack_time + attack_last > GameTime() and distance < range - 10
			and not IsMelee(bot.ref)
		then
			-- Stay away from building.
			bot.ref:Action_MoveToLocation(bot.location + away * 5)
		else
			bot.ref:Action_AttackUnit(building, true)
		end
	else
		bot.ref:Action_MoveToUnit(building)
	end
end

-- Attacking tower unit or nil
local function GetAttackingTower(bot)
	local towers = {
		TOWER_TOP_1,
		TOWER_TOP_2,
		TOWER_TOP_3,
		TOWER_MID_1,
		TOWER_MID_2,
		TOWER_MID_3,
		TOWER_BOT_1,
		TOWER_BOT_2,
		TOWER_BOT_3,
		TOWER_BASE_1,
		TOWER_BASE_2
	}

	local attacking_tower = nil
	local other_team = GetEnemyTeam()

    for i = 1, #towers do
		if GetTowerAttackTarget(other_team, towers[i]) == bot.ref then
			attacking_tower = GetTower(other_team, towers[i])
			break
		end
    end

    return attacking_tower
end

function DeAggroTower(bot)
	if not bot.de_aggro then
		bot.de_aggro = DotaTime() - 1.0
	end

	if DotaTime() < bot.de_aggro + 1.0 then
		return false
	end

	local attacking_tower = GetAttackingTower(bot)
	if attacking_tower == nil then
		return false
	end

	local allied_creeps = bot.ref:GetNearbyLaneCreeps(1600, false)
	local other_creeps = bot.ref:GetNearbyCreeps(1600, false)
	for i = 1, #other_creeps do
		table.insert(allied_creeps, other_creeps[i])
	end

	local range = bot.ref:GetBoundingRadius() + bot.ref:GetAttackRange()

	local meatshield_creeps = {}
	if #allied_creeps > 0 and #enemy_towers > 0 then
		-- Search for nearby allied creeps to take tower hits
		for i = 1, #allied_creeps do
			for i = 1, #enemy_towers do
				if GetUnitToUnitDistance(allied_creeps[i], enemy_towers[i]) < 900
					and GetUnitToUnitDistance(bot.ref, allied_creeps[i]) < range
				then
					table.insert(meatshield_creeps, allied_creeps[i])
				end
			end
		end
	end

	if #meatshield_creeps == 0 then
		return false
	end

	AttackUnit(bot, meatshield_creeps[1], true)
	return true
end
