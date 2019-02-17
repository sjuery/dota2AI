function FarmDesire(bot)
	return {100, nil}
end

function Farm(bot, value)
	print("am farm")
end


function RetreatDesire(bot)
	return {0, nil}
end

function Retreat(bot, value)
	print("am retreat")
end


function PushDesire(bot)
	return {0, nil}
end

function Push(bot, value)
	print("am push")
end


function FightDesire(bot)
	return {0, nil}
end

function Fight(bot, value)
	print("am fight")
end


function RuneDesire(bot)
	return {0, nil}
end

function Rune(bot, value)
	print("am rune")
end


function MemeDesire(bot)
	return {0, nil}
end

function Meme(bot, value)
	print("am meme")
end

function UpKeep(bot)
end

generic_desires = {
	["farm"] = {FarmDesire, Farm},
	["retreat"] = {RetreatDesire, Retreat},
	["push"] = {PushDesire, Push},
	["fight"] = {FightDesire, Fight},
	["rune"] = {RuneDesire, Rune},
	["meme"] = {MemeDesire, Meme}
}

function Thonk(bot, desires)
	UpKeep(bot)
	local desire_best = -1
	local desire_value = nil
	local desire_mode = nil

	for name, thonkage in pairs(desires) do
		local thonk_result = thonkage[1](bot)
		local desire = thonk_result[1]
		local value = thonk_result[2]
		if desire > desire_best then
			desire_best = desire
			desire_value = value
			desire_mode = thonkage[2]
		end
	end
	desire_mode(bot, desire_value)
end