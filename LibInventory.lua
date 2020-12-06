---A library to handle item inventory
_G['LibInventory'] = {}
_G['LibInventory-@project-version@'] = _G['LibInventory']
local inv = _G['LibInventory']
inv.version = '@project-version@'

if LibStub then
    local major, minor = string.match('@project-version@', 'v(%d+).(%d+)')
    major = tonumber(major)
    minor = tonumber(minor)
    inv = LibStub:NewLibrary("LibInventory-"..major, minor)
end

if not inv then
    return	-- already loaded and no upgrade necessary
end

local addonName, _ = ...
inv.items = inv.items or {}
---Item locations indexed by bag and slot
inv.inventory = inv.inventory or {}
---Item locations indexed by itemID
inv.locations = inv.locations or {}


--/dump LibStub("LibInventory-0.1").locations
--/dump LibStub("LibInventory-0.1").inventory
--/dump LibStub("LibInventory-0.1").locations[2140][1]

---Scan bag content and save to self.locations (indexed by itemID) and self.inventory (indexed by bag and slot)
---@param bag number
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
        local icon, itemCount, locked, quality, readable, lootable, itemLink,
        isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)
        if itemID ~= nil then
            item = {["bag"]=bag, ["slot"]=slot, ["icon"]=icon, ["itemCount"]=itemCount, ["locked"]=locked,
                    ["quality"]=quality, ["readable"]=readable, ["lootable"]=lootable, ["itemLink"]=itemLink,
                    ["isFiltered"]=isFiltered, ["noValue"]=noValue, ["itemID"]=itemID}
            self.items[itemID] = item --TODO: Remove this and replace usages with inventory
            self.inventory[bag][slot] = item
            if not self.locations[itemID] then
                self.locations[itemID] = {}
            end
            table.insert(self.locations[itemID], {["bag"]=bag, ["slot"]=slot})
        end
    end
end

--/dump LibStub("LibInventory-0.1"):ScanAllBags()
function inv:ScanAllBags()
    self.locations = {}
    for bag=0, 4, 1 do
        self:ScanBag(bag)
    end
    return self.inventory
end

--/dump LibStub("LibInventory-0.1"):FindItemStacks(765)
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
--/dump LibStub("LibInventory-0.1"):FindItem(2592)
--/dump LibStub("LibInventory-0.1").locations["2592"]
---Find the location of an item
---@param itemID number Item ID
function inv:FindItem(itemID)
    local stacks = self:FindItemStacks(itemID)
    if stacks then
        return stacks[1]
    end
end

--/run LibStub("LibInventory-0.1"):ListBag(0)
function inv:ListBag(bag)
    for _, slot in pairs(self.inventory[bag]) do
        if self.inventory[bag][slot] then
            print(string.format("Bag %s slot %s: %s", bag, slot, self.inventory[bag][slot]["itemLink"]))
        end
    end
end
