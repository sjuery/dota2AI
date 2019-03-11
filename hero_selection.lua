local hero_names = {
	"Wolverine",
	"SJuery",
	"Mr.Robot",
	"Steven from Sweden",
	"Theo St.George Walton"
}

local picked_pool = {};

local pick_pool = {
	"npc_dota_hero_luna",
	"npc_dota_hero_drow_ranger",
	"npc_dota_hero_abyssal_underlord",
	"npc_dota_hero_furion", -- Natures prophet
	"npc_dota_hero_omniknight",
	"npc_dota_hero_terrorblade",
	"npc_dota_hero_sven",
	"npc_dota_hero_axe"
}

local ban_pool = {
	'npc_dota_hero_sniper',
	'npc_dota_hero_treant',
	'npc_dota_hero_tusk',
	'npc_dota_hero_undying',
	'npc_dota_hero_vengefulspirit',
	'npc_dota_hero_venomancer',
	'npc_dota_hero_warlock',
	'npc_dota_hero_windrunner',
	'npc_dota_hero_witch_doctor',
	'npc_dota_hero_zuus',
	'npc_dota_hero_sven',
	'npc_dota_hero_slark'
}

function Think()
	if (GetGameState() ~= GAME_STATE_HERO_SELECTION) then
		return
	end

	if GetHeroPickState() == HEROPICK_STATE_CM_CAPTAINPICK then
		if GetTeam() == TEAM_RADIANT then
			SetCMCaptain(2)
		elseif GetTeam() == TEAM_DIRE then
			SetCMCaptain(7)
		end
	elseif GetHeroPickState() >= HEROPICK_STATE_CM_BAN1 and GetHeroPickState() <= 18 then
		BanHero()
	elseif GetHeroPickState() >= HEROPICK_STATE_CM_SELECT1 and GetHeroPickState() <= HEROPICK_STATE_CM_SELECT10 then
		PickHero()
	elseif GetHeroPickState() == HEROPICK_STATE_CM_PICK then
		SelectHeroes()
	end
end

function BanHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then
		return
	end

	while (IsCMPickedHero(GetTeam(), ban_pool[1]) or IsCMPickedHero(GetOpposingTeam(), ban_pool[1]) or IsCMBannedHero(ban_pool[1])) do
		table.remove(ban_pool, 1)
	end

	CMBanHero(ban_pool[1])
end

function PickHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then
		return
	end

	while (IsCMPickedHero(GetTeam(), pick_pool[1]) or IsCMPickedHero(GetOpposingTeam(), pick_pool[1]) or IsCMBannedHero(pick_pool[1])) do
		table.remove(pick_pool, 1)
	end
	table.insert(picked_pool, pick_pool[1])
	CMPickHero(pick_pool[1])
end

function SelectHeroes()
	local Bots = GetTeam()

	if (Bots == TEAM_RADIANT) then
		for pID = 2, 6  do
			SelectHero(pID, picked_pool[pID-1])
		end
	elseif (Bots == TEAM_DIRE) then
		for pID = 7, 11 do
			SelectHero(pID, picked_pool[pID-6])
		end
	end
end

function GetBotNames()
	return hero_names
end
