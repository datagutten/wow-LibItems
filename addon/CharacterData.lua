---@type LibInventory
local _, addon = ...

---@class CharacterData
addon.CharacterData = {}
---@type CharacterData
local Character = addon.CharacterData

---Save character information
function Character:save()
    if not _G['Characters'] then
        _G['Characters'] = {}
    end
    if not _G['Characters'][self.realm] then
        _G['Characters'][self.realm] = {}
    end
    _G['Characters'][self.realm][self.name] = self.info
end

---Get character class color
---@return ColorMixin
function Character:color()
    return _G.RAID_CLASS_COLORS[self.class]
end

--[[function Character:banner()
    --if self.faction
    local ALLIANCE_BANNER = 'Interface/Icons/inv_bannerpvp_02'
    local HORDE_BANNER = 'Interface/Icons/inv_bannerpvp_01'
end]]

---Get gender as string
function Character:genderString()
    return addon.utils.character.genderString(self.gender)
end

---Get character race icon
function Character:icon()
    return addon.utils.character.raceIcon(self.raceFile, self:genderString())
end

function Character:iconString(size, x, y)
    if size == nil then
        size = 12
    end
    local atlas, coordinates = self:icon()
    local u, v, w, z = unpack(coordinates)
    return _G.CreateTextureMarkup(atlas, 128, 128, size, size, u, v, w, z, x, y)
end
