local inv = LibStub:NewLibrary("LibInventory-0.1", 1)
local NUM_EQUIPMENT_SLOTS = 19
local addonName, addon = ...
inv.items = inv.items or {}
inv.inventory = inv.inventory or {}
inv.locations = inv.locations or {}


--/dump LibStub("LibInventories-1.0").locations
--/dump LibStub("LibInventories-1.0").locations[2140][1]


function inv:ScanBag(bag)
    --@debug@
    print('Scan bag', bag)
    --@end-debug@
    local slots = GetContainerNumSlots(bag)
    self.inventory[bag] = {}

    for itemID, locations in pairs(self.locations) do
        for key, location in ipairs(locations) do
            if location["bag"] == bag then
                table.remove(self.locations[itemID], key)
            end
        end
    end

    for slot=1, slots, 1 do
        --local itemId = GetContainerItemID(bag, slot);
        --local itemLink = GetContainerItemLink(bag, slot)
        local item
        local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)
        if itemID ~= nil then
            item = {["bag"]=bag, ["slot"]=slot, ["icon"]=icon, ["itemCount"]=itemCount, ["locked"]=locked, ["quality"]=quality, ["readable"]=readable, ["lootable"]=lootable, ["itemLink"]=itemLink, ["isFiltered"]=isFiltered, ["noValue"]=noValue, ["itemID"]=itemID}
            self.items[itemID] = item --TODO: Remove this and replace usages with inventory
            self.inventory[bag][slot] = item
            if not self.locations[itemID] then
                self.locations[itemID] = {}
            end
            table.insert(self.locations[itemID], {["bag"]=bag, ["slot"]=slot})
        end
    end
end

--/dump LibStub("LibInventories-1.0"):ScanAllBags()
function inv:ScanAllBags()
    self.locations = {}
    for bag=0, 4, 1 do
        self:ScanBag(bag)
    end
    return self.inventory
end

--/dump LibStub("LibInventories-1.0"):FindItemStacks(765)
function inv:FindItemStacks(itemID)
    if not self.inventory then
        self:ScanAllBags()
    end
    local locations = self.locations[itemID]
    if not locations then
        return
    end
    local stacks = {}
    for _, location in ipairs(locations) do
        --@debug@
        print(string.format("item %d is at bag %d slot %d", itemID, location["bag"], location["slot"]))
        --@end-debug@
        table.insert(stacks, self.inventory[location["bag"]][location["slot"]])
    end
    return stacks
end

--Wool cloth:
--/dump LibStub("LibInventories-1.0"):FindItem(2592)
--/dump LibStub("LibInventories-1.0").locations["2592"]
--/run print(LibStub("LibInventories-1.0").locations["2592"])
function inv:FindItem(itemID)
    local stacks = self:FindItemStacks(itemID)
    if stacks then
        return stacks[1]
    end
end

--/run LibStub("LibInventories-1.0"):ListBag(0)
function inv:ListBag(bag)
    for _, slot in pairs(self.inventory[bag]) do
        if self.inventory[bag][slot] then
            print(string.format("Bag %s slot %s: %s", bag, slot, self.inventory[bag][slot]["itemLink"]))
        end
    end
end

inv.frame = CreateFrame("FRAME"); -- Need a frame to respond to events
inv.frame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded

function inv:eventHandler(event, arg1)
    --https://wowwiki.fandom.com/wiki/Events/Item
    if event == "ADDON_LOADED" and arg1 == addonName then
        inv.frame:RegisterEvent("BAG_UPDATE")
    elseif event == "BAG_UPDATE" then
        --print(event, arg1)
        inv:ScanBag(arg1)
    end
end
inv.frame:SetScript("OnEvent", inv.eventHandler);