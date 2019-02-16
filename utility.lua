
-- Item reference or nil
function IsItemAvailable(bot, item_name)
    for i = 0, 5 do
        local item = bot:GetItemInSlot(i)
        if (item ~= nil) then
            if (item:GetName() == item_name) then
                return item
            end
        end
    end
    return nil
end