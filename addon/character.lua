---@type LibInventory
local _, addon = ...

---@class LibInventoryCharacter
addon.characters = {}
local lib = addon.characters

---Get information about the specified character
---@param realm string Realm
---@param character string Character name
function lib.characterInfo(realm, character)
    assert(_G['Characters'][realm][character], 'No data found for character')
    local char_data = _G['Characters'][realm][character]
    setmetatable(char_data, addon.CharacterData)
    addon.CharacterData.__index = addon.CharacterData
    return char_data
end

---Get information about the current character
---@return CharacterData
function lib.currentCharacterInfo()
    local o = {}

    o.money = (_G.GetMoney() or 0) - _G.GetCursorMoney() - _G.GetPlayerTradeMoney()
    o.class = select(2, _G.UnitClass('player'))
    o.race = select(2, _G.UnitRace('player'))

    --https://wow.gamepedia.com/API_UnitRace
    o.raceName, o.raceFile, o.raceID = _G.UnitRace('player')

    --https://wow.gamepedia.com/API_UnitClass
    o.className, o.classFilename, o.classId = _G.UnitClass('player')

    o.guild = _G.GetGuildInfo('player')
    o.gender = _G.UnitSex('player')
    o.name = _G.UnitName("player")
    o.realm = _G.GetRealmName()

    addon.CharacterData.info = o

    setmetatable(o, addon.CharacterData)
    addon.CharacterData.__index = addon.CharacterData
    return o
end
