---@type LibInventoryAce
local addon = _G['LibInventoryAce']

---@class LibInventoryCharacter
local lib = _G['LibInventoryAce']:NewModule("LibInventoryCharacter")
if not lib then
    return
end

local CharacterObject = addon:GetModule('LibInventoryCharacterObject')

---@type BMUtils
local utils = _G.LibStub('BM-utils-2')
local empty = utils.basic.empty

function lib:OnInitialize()
    self.db = addon.db:RegisterNamespace('Character', {})
end

function lib:OnEnable()
    self:save()
end

---Save information about the current character
function lib:save()
    local character = _G.UnitName("player")
    self.db.realm[character] = self.currentCharacterData()
end

---Get information about the specified character
---@param realm string Realm
---@param character string Character name
---@return LibInventoryCharacterObject
function lib:load(realm, character)
    if realm ~= _G.GetRealmName() then
        utils.text.error(('Requested realm %s is not current'):format(realm))
        return
    end

    if empty(self.db.realm[character]) then
        --TODO: Do not show error for guild bank
        --utils.text.error(('No data found for character %s'):format(character))
        return
    end

    return CharacterObject.construct(self.db.realm[character])
end

---Get a CharacterData object with information about the current character
---@return LibInventoryCharacterObject
function lib.current()
    return CharacterObject.construct(lib.currentCharacterData())
end

function lib.currentCharacterData()
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
    return o
end
