local buy_order = {
	"item_courier",
	"item_tango",
	"item_tango",
	"item_flask",
	"item_stout_shield",
	"item_quelling_blade",
-- Power treads
	"item_boots",
	"item_boots_of_elves",
	"item_gloves",
-- Armlet of Mordiggian
	"item_helm_of_iron_will",
	"item_boots_of_elves",
	"item_blades_of_attack",
	"item_recipe_armlet"
};

function ItemPurchaseThink()
	local bot = GetBot()
	if bot.buy_order then
		return -- Skip bots with custom implementations
	end

	if #buy_order == 0 then
		bot:SetNextItemPurchaseValue(0)
		return
	end

	local item = buy_order[1]
	local cost = GetItemCost(item)

	bot:SetNextItemPurchaseValue(cost)

	if bot:GetGold() >= cost then
		bot:ActionImmediate_PurchaseItem(item)
		table.remove(buy_order, 1)
	end
end