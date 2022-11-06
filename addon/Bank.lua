---@type LibInventory
local _, addon = ...

---@class LibInventoryBank Manage banks which are not containers
local lib = addon.bank
lib.addon = addon

function lib:scanGuildBank()
    local guildName = _G.GetGuildInfo('player');
    self.addon.main:clearLocation('guildBank', guildName)
    local numTabs = _G.GetNumGuildBankTabs()

    for tab = 1, numTabs do
        for i = 1, 14 * 7 do
            local _, itemCount = _G.GetGuildBankItemInfo(tab, i);
            if itemCount > 0 then
                local link = _G.GetGuildBankItemLink(tab, i)
                local itemID = self.addon.utils:ItemIdFromLink(link)
                assert(itemID, ('Unable to get item id for slot %d'):format(i))
                self.addon.main:saveItemLocation(itemID, 'guildBank', itemCount, guildName)
            end
        end
    end
end