---@type LibInventory
local _, addon = ...

---@class LibInventoryContainer
local lib = addon.container
lib.addon = addon

---Container items with slot numbers
lib.items = {}
lib.location = {}

---Scan bag content and save to self.location (indexed by itemID) and self.items (indexed by container and slot)
---@param container number Container ID
function lib:getContainerItems(container)
    --@debug@
    print('Scan bag', container)
    --@end-debug@
    local slots = _G.GetContainerNumSlots(container)

    self.items[container] = {}

    for slot = 1, slots, 1 do
        local _, itemCount, _, _, _, _, _, _, _, itemID = _G.GetContainerItemInfo(container, slot)
        if itemID ~= nil then
            self.addon.main.subTableCheck(self.items, container, slot)
            self.items[container][slot][itemID] = itemCount
            self.addon.main.subTableCheck(self.location, itemID)
            table.insert(self.location[itemID], { container = container, slot = slot })
        end
    end
    return self.items[container]
end

function lib:getMultiContainerItems(first, last)
    local itemCount = {}
    for container = first, last, 1 do
        local items = self:getContainerItems(container)
        for _, idCount in pairs(items) do
            for itemID, count in pairs(idCount) do
                itemCount[itemID] = count + (itemCount[itemID] or 0)
            end
        end
    end
    return itemCount
end

function lib:scanContainers(first, last, location)
    for itemID, count in pairs(self:getMultiContainerItems(first, last)) do
        self.addon.main:saveItemLocation(itemID, location, count)
    end
end

function lib:scanBags()
    self.addon.main:clearLocation('bags')
    self:scanContainers(0, 4, 'bags')
end

function lib:scanBank()
    self.addon.main:clearLocation('bank')
    --First bank bag slot is last character bag slot +1
    self:scanContainers(_G.NUM_BAG_SLOTS + 1, _G.NUM_BANKBAGSLOTS + _G.NUM_BAG_SLOTS, 'bank')
    self:scanContainers(_G.BANK_CONTAINER, _G.BANK_CONTAINER, 'bank')

    if _G['REAGENTBANK_CONTAINER'] ~= nil then
        self.addon.main:clearLocation('reagentBank')
        self:scanContainers(_G['REAGENTBANK_CONTAINER'], _G['REAGENTBANK_CONTAINER'], 'reagentBank')
    end
end

--/dump _G['LibInventoryItems'].container:getLocation(4304)
--/dump _G['LibInventoryItems'].container:getLocation(13444)
function lib:getLocation(itemID)
    return self.location[itemID] or {}
end