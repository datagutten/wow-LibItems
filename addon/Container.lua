---@type LibInventory
local _, addon = ...

---@class LibInventoryContainer
local lib = addon.container
lib.addon = addon

---Container items with slot numbers
lib.items = {}
local is_classic = _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_MAINLINE

local C_Container
if is_classic then
    C_Container = addon.utils.container
else
    C_Container = _G.C_Container
end

---Scan bag content and save to self.location (indexed by itemID) and self.items (indexed by container and slot)
---@param container number Container ID
function lib:getContainerItems(container)
    local slots = C_Container.GetContainerNumSlots(container)

    if _G['ContainerSlot'][container] ~= nil then
        _G['ContainerSlot'][container] = nil
    end

    self.items[container] = {}

    for slot = 1, slots, 1 do
        local item = C_Container.GetContainerItemInfo(container, slot)
        if item ~= nil then
            self.addon.main.subTableCheck(self.items, container, slot)
            self.items[container][slot][item['itemID']] = item['stackCount']
            self.addon.main.subTableCheck(_G['ContainerSlot'], container, item['itemID'])
            table.insert(_G['ContainerSlot'][container][item['itemID']], slot)
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

--/dump _G['LibInventory-@project-version@'].container:getLocation(6948)
--/dump _G['LibInventory-@project-version@'].container:getLocation(13444)
---Get item container slots
function lib:getLocation(itemID)
    local locations = {}
    for container, items in pairs(_G['ContainerSlot']) do
        for item, slots in pairs(items) do
            if item == itemID then
                for _, slot in ipairs(slots) do
                    table.insert(locations, { container = container, slot = slot })
                end
            end
        end
    end
    return locations
end