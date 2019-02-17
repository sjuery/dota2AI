
-- Returns table of items indexed on item name
function GetItems(bot)
	local items = {}
	for i = 0, 5 do
		local item = bot:GetItemInSlot(i)
		if (item ~= nil) then
			items[item:GetName()] = item
		end
	end
	return items
end

function GetItemsCount(bot)
	local count = 0
	for i = 0, 5 do
		local item = bot:GetItemInSlot(i)
		if (item ~= nil) then
			count = count + 1
		end
	end
	return count
end

function DeepCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
		end
		setmetatable(copy, DeepCopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

-- Takes two vec2
-- Returns the euclidean distance
function GetDistance(a, b)
	local x = a[1] - b[1]
	local y = a[2] - b[2]
	return math.sqrt(x * x + y * y);
end
