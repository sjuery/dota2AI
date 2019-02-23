-- Sub desire states
function GetTeamsHealth(enemy_heros, ally_heroes)
	local enemy_health = 0
	local ally_health = 0

	for i = 1, #enemy_heros do
		enemy_health = enemy_health + enemy_heros[i]:GetHealth()
	end

	for i = 1, #ally_heroes do
		ally_health = ally_health + ally_heroes[i]:GetHealth()
	end

	if ally_heath > enemy_health then
		return 5
	end
	return 0
end

function GetTeamBuffs(ally_heroes)
	local desire = 0
	local modifer_list = {
		["luna_lunar_blessing"] = 5,
		["modifier_luna_lunar_blessing_aura"] = 5,
		["modifier_luna_eclipse"] = 15
	}

	for i = 1, #ally_heroes do
		for name, priority in next, modifer_list do
			print("IN BUFFLOOP")
			print(name)
			print(ally_heroes[i]:HasModifier(name))
			if ally_heroes[i]:HasModifier(name) then
				print("priority: " .. priority)
				desire = desire + priority
			end
		end
	end
	return desire
end
