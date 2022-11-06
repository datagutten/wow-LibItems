---@type LibInventory
local _, addon = ...
---@class LibInventoryEvents Inventory event handler
local events = addon.events

local frame = _G.CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, ...)
    if events[event] == nil then
        error(('No event handler for %s'):format(event))
    end
    events[event](self, ...)
end)
frame.addon = addon

function events:ADDON_LOADED(addonName)
    if addonName == self.addon.name then
        --@debug@
        self.addon.utils:printf("%s loaded with debug output", self.addon.name)
        --@end-debug@

        ---Item locations indexed by location
        if _G['ItemLocations'] == nil then
            _G['ItemLocations'] = {}
        end
        addon.main.locations = _G['ItemLocations']
        ---Item locations indexed by item ID
        if _G['LocationItems'] == nil then
            _G['LocationItems'] = {}
        end
        addon.main.items = _G['LocationItems']

        if _G['ContainerSlot'] == nil then
            _G['ContainerSlot'] = {}
        end

        self:RegisterEvent('MAIL_INBOX_UPDATE')
        self:RegisterEvent('BAG_UPDATE')
        self:RegisterEvent('GUILD_ROSTER_UPDATE')
        self:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
        self:RegisterEvent('BANKFRAME_OPENED')
        self:RegisterEvent('BANKFRAME_CLOSED')
        self:RegisterEvent('PLAYERBANKSLOTS_CHANGED')

        self:RegisterEvent('PLAYER_REGEN_DISABLED')
        self:RegisterEvent('PLAYER_REGEN_ENABLED')

        --if _G['CanUseVoidStorage'] then
        --    self:RegisterEvent('VOID_STORAGE_OPEN')
        --    self:RegisterEvent('VOID_STORAGE_CLOSE')
        --end

        if _G['CanGuildBankRepair'] ~= nil then
            --TODO: Find better variable to check
            self:RegisterEvent('GUILDBANKFRAME_OPENED')
            self:RegisterEvent('GUILDBANKFRAME_CLOSED')
            self:RegisterEvent('GUILDBANKBAGSLOTS_CHANGED')
        end

        if _G['REAGENTBANK_CONTAINER'] ~= nil then
            self:RegisterEvent('PLAYERREAGENTBANKSLOTS_CHANGED')
        end
    end
end

---This event is fired when the inbox changes in any way.
---https://wow.gamepedia.com/MAIL_INBOX_UPDATE
function events:MAIL_INBOX_UPDATE()
    --@debug@
    self.addon.utils:printf('Mail inbox updated')
    --@end-debug@
    self.addon.mailInventory:scanMail()
end

---Fired when a bags inventory changes.
---https://wow.gamepedia.com/BAG_UPDATE
function events:BAG_UPDATE(bag)
    --@debug@
    self.addon.utils:printf('Bag %d updated, scan all bags', bag)
    --@end-debug@

    self.addon.container:scanBags()
    if self.atBank then
        self.addon.container:scanBank()
    end
end

---Fired when the client's guild info cache has been updated after a call to GuildRoster
---or after any data change in any of the guild's data, excluding the Guild Information window.
---https://wow.gamepedia.com/GUILD_ROSTER_UPDATE
function events:GUILD_ROSTER_UPDATE()
    if self.addon.utils:IsWoWClassic(false) then
        return
    end
end

function events:BANKFRAME_OPENED()
    self.atBank = true
end

function events:BANKFRAME_CLOSED()
    if self.atBank then
        addon.container:scanBank()
        self.atBank = false
    end
end

function events:PLAYERBANKSLOTS_CHANGED(slot)
    --@debug@
    self.addon.utils:sprintf('Bank slot %d changed', slot)
    --@end-debug@
    self.addon.container:scanBank()
end

function events:PLAYERREAGENTBANKSLOTS_CHANGED(slot)
    --@debug@
    self.addon.utils:sprintf('Reagent Bank slot %d changed', slot)
    --@end-debug@
    self.addon.container:scanBank()
end

function events:PLAYER_EQUIPMENT_CHANGED()
    self.addon.equipment:scanEquipment()
end

function events:GUILDBANKFRAME_OPENED()
    self.atGuildBank = true
end

function events:GUILDBANKBAGSLOTS_CHANGED(slot)
    --@debug@
    self.addon.utils:sprintf('Guild Bank slot %d changed', slot)
    --@end-debug@
    self.addon.bank:scanGuildBank()
end

function events:GUILDBANKFRAME_CLOSED()
    self.addon.bank:scanGuildBank()
    self.atGuildBank = false
end

--[[
function events:VOID_STORAGE_OPEN()

end

function events:VOID_STORAGE_CLOSE()

end]]

function events:PLAYER_REGEN_DISABLED()
    --Do not scan bags in combat, every hunter ammo usage is a bag update
    self:UnregisterEvent('BAG_UPDATE')
end

function events:PLAYER_REGEN_ENABLED()
    self:RegisterEvent('BAG_UPDATE')
end