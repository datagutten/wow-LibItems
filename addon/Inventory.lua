---@type LibInventory
local _, addon = ...
if not addon.main then
    return
end

---@class LibInventoryMain
local lib = addon.main
lib.addon = addon

---Item locations indexed by location (saved variable ItemLocations)
lib.locations = {}
---Item locations indexed by item ID (saved variable LocationItems)
lib.items = {}

lib.location_names = {
    guildBank = _G.GUILD_BANK,
    bank = _G.BANK,
    reagentBank = _G.REAGENT_BANK,
    bags = _G.BAGSLOT,
    voidStorage = _G.VOID_STORAGE,
    mail = _G.MAIL_LABEL,
}

function lib.subTableCheck(tableData, ...)
    --https://stackoverflow.com/questions/7183998/in-lua-what-is-the-right-way-to-handle-varargs-which-contains-nil
    for _, value in ipairs { ... } do
        if type(tableData[value]) ~= 'table' then
            tableData[value] = {}
        end
        tableData = tableData[value]
    end
end

function lib:saveItemLocation(itemID, location, quantity, character, realm)
    assert(itemID, 'itemID is nil')
    ---Get character string, arguments are optional and falls back to current character and realm if not set
    character = self.addon.utils.getCharacterString(character, realm)

    self.subTableCheck(self.locations, character, location, itemID)
    self.locations[character][location][itemID] = quantity

    self.subTableCheck(self.items, itemID, character, location)
    self.items[itemID][character][location] = quantity

end

--/dump _G['LibInventory-@project-version@'].main:getItemLocation(7070, 'Luckydime', 'Mirage Raceway')
---Get item count and which container it is located in
function lib:getItemLocation(itemID, character, realm)
    if not self.items[itemID] then
        return {}
    end

    if character then
        character = self.addon.utils.getCharacterString(character, realm)
        return self.items[itemID][character] or {}
    else
        return self.items[itemID] or {}
    end
end

function lib:getLocationItems(location, character, realm)
    if character then
        character = self.addon.utils.getCharacterString(character, realm)
        if not self.locations[character] or not self.locations[character][location] then
            --@debug@
            self.addon.utils.basic.printf('No data for location %s on character %s', location, character)
            --@end-debug@
            return
        end

        return self.locations[character][location]
    else
        return self.locations
    end
end

---Clear all items from the given location
---/run LibInventoryItems.main:clearLocation('Bags')
function lib:clearLocation(location, character, realm)
    character = self.addon.utils.getCharacterString(character, realm)
    if self.locations[character] == nil then
        self.locations[character] = {}
    end
    self.locations[character][location] = {}
    for itemID, characters in pairs(self.items) do
        for character_iter, locations in pairs(characters) do
            for location_iter, _ in pairs(locations) do
                if location_iter == location and character_iter == character then
                    self.items[itemID][character_iter][location_iter] = nil
                end
            end
        end
    end
end

---Clear all location for the given item
function lib:clearItem(itemID, character, realm)
    character = self.addon.utils.getCharacterString(character, realm)
    self.items[itemID] = nil
    for character_iter, locations in pairs(self.locations) do
        for location_iter, item_iter in pairs(locations) do
            if item_iter == itemID and character_iter == character then
                self.locations[character_iter][location_iter] = nil
            end
        end
    end
end

---Get localized location name
---@param location string
function lib:locationName(location)
    return self.location_names[location] or location
end