local buy_order = {
	"item_courier",
	"item_tango",
	"item_tango",
	"item_tango",
	"item_flask",
	"item_stout_shield",
	"item_quelling_blade",
	"item_circlet",
	"item_slippers",
	"item_recipe_wraith_band",
	"item_boots",
	"item_boots_of_elves",
	"item_gloves",
	"item_boots_of_elves",
	"item_boots_of_elves",
	"item_ogre_axe"
};

function ItemPurchaseThink()
	local bot = GetBot()

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