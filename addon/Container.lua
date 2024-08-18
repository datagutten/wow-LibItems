---@class LibInventoryContainer
local lib = _G['LibInventoryAce']:NewModule('LibInventoryContainer', 'AceEvent-3.0')
---@type LibInventoryLocations
local inventory = _G['LibInventoryAce']:GetModule('LibInventoryLocations')

---@type BMUtilsBasic
local basic = _G.LibStub('BM-utils-2'):GetModule('BMUtilsBasic')
---@type BMUtils
local utils = _G.LibStub('BM-utils-2'):GetModule('BMUtils')

---@type C_Container
local C_Container
if _G.C_Container == nil or _G.C_Container.GetContainerNumSlots == nil then
    ---@type BMUtilsContainer
    C_Container = _G.LibStub('BM-utils-2'):GetModule('BMUtilsContainer')
else
    C_Container = _G.C_Container
end

function lib:OnEnable()
    --Bank scanning
    self:RegisterEvent('BANKFRAME_OPENED')
    self:RegisterEvent('BANKFRAME_CLOSED')
    self:RegisterEvent('PLAYERBANKSLOTS_CHANGED')
    if _G['REAGENTBANK_CONTAINER'] ~= nil then
        self:RegisterEvent('PLAYERREAGENTBANKSLOTS_CHANGED')
    end

    --Bag scanning
    self:RegisterEvent('BAG_UPDATE')
    self:RegisterEvent('PLAYER_REGEN_DISABLED')
    self:RegisterEvent('PLAYER_REGEN_ENABLED')
end

function lib:BANKFRAME_OPENED()
    self.atBank = true
    self:scanBank()
end

function lib:BANKFRAME_CLOSED()
    if self.atBank then
        self.atBank = false
    end
end

---Fired when a bags inventory changes.
---https://wow.gamepedia.com/BAG_UPDATE
function lib:BAG_UPDATE(_, bag)
    --@debug@
    basic.printf('Bag %d updated, scan all bags', bag)
    --@end-debug@

    self:scanBags()
    --self:scanContainers(bag, bag, 'bags')
    if self.atBank then
        self:scanBank()
    end
end

function lib:PLAYER_REGEN_DISABLED()
    --Do not scan bags in combat, every hunter ammo usage is a bag update
    self:UnregisterEvent('BAG_UPDATE')
end

function lib:PLAYER_REGEN_ENABLED()
    self:RegisterEvent('BAG_UPDATE')
    self:scanBags() --Scan for items used in combat
end

function lib:PLAYERBANKSLOTS_CHANGED(slot)
    --@debug@
    basic.printf('Bank slot %d changed', slot)
    --@end-debug@
    self:scanBank()
end

function lib:PLAYERREAGENTBANKSLOTS_CHANGED(slot)
    --@debug@
    basic.printf('Reagent Bank slot %d changed', slot)
    --@end-debug@
    self:scanBank()
end

---Get items in the given container
---@param container number Container ID
function lib.getContainerItems(container)
    local slots = C_Container.GetContainerNumSlots(container)
    local items = {}

    for slot = 1, slots, 1 do
        local item = C_Container.GetContainerItemInfo(container, slot)
        if item ~= nil and next(item) ~= nil then
            if item['stackCount'] == nil then
                --@debug@
                print('No count', item['link'])
                --@end-debug@
                item['stackCount'] = 1
            end
            if item['itemID'] == nil then
                --@debug@
                print(('Item in container %d slot %d has no itemID'):format(container, slots))
                --@end-debug@
                item['itemID'] = utils.itemIdFromLink(item['hyperlink'])
            end

            items[slot] = item
        end
    end
    return items
end

---Summarize multiple item stacks
function lib:getMultiContainerItems(first, last)
    local itemCount = {}
    local itemLocations = {}
    for container = first, last, 1 do
        local items = self.getContainerItems(container)
        for slot, item in pairs(items) do
            itemCount[item['itemID']] = item['stackCount'] + (itemCount[item['itemID']] or 0)
            if itemLocations[item['itemID']] == nil then
                itemLocations[item['itemID']] = {}
            end
            table.insert(itemLocations[item['itemID']], { container = container, slot = slot })
        end
    end
    return itemCount, itemLocations
end

function lib:scanContainers(first, last, location)
    for itemID, count in pairs(self:getMultiContainerItems(first, last)) do
        inventory:saveItemLocation(itemID, location, count)
    end
end

function lib:scanBags()
    inventory:clearLocation('bags')
    self:scanContainers(0, 4, 'bags')
end

function lib:scanBank()
    inventory:clearLocation('bank')
    --First bank bag slot is last character bag slot +1
    self:scanContainers(_G.NUM_BAG_SLOTS + 1, _G.NUM_BANKBAGSLOTS + _G.NUM_BAG_SLOTS, 'bank')
    self:scanContainers(_G.BANK_CONTAINER, _G.BANK_CONTAINER, 'bank')

    if _G['REAGENTBANK_CONTAINER'] ~= nil then
        inventory:clearLocation('reagentBank')
        self:scanContainers(_G['REAGENTBANK_CONTAINER'], _G['REAGENTBANK_CONTAINER'], 'reagentBank')
    end
end
