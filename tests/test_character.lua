local lu = require('luaunit')
loadfile('build_utils/wow_api/functions.lua')()
---@type LibInventory
local addon = {}
loadfile('../addon/CharacterData.lua')('', addon)
loadfile('../addon/character.lua')('', addon)

function testCurrentCharacter()
    ---@type CharacterData
    local char = addon.character.currentCharacterInfo()
    lu.assertEquals(char.money, 62993)
    lu.assertEquals(char.guild, 'The Wasnots')
    lu.assertEquals(char.name, 'Quadduo')
    lu.assertEquals(char.realm, 'Mirage Raceway')
end

--[[function testSaveCharacter()
    lu.assertNil(_G['Characters'])
    local char = addon.character:current()
    char:save()
    lu.assertNotNil(_G['Characters']['Mirage Raceway'])
end]]

function testLoadCharacter()
    _G['Characters'] = {
        ["Mirage Raceway"] = {
            Quadduo = {
                class = "HUNTER",
                classFilename = "HUNTER",
                classId = 3,
                className = "Hunter",
                gender = 3,
                guild = "The Wasnots",
                money = 62993,
                name = "Quadduo",
                race = "NightElf",
                raceFile = "NightElf",
                raceID = 4,
                raceName = "Night Elf",
                realm = "Mirage Raceway"
            }
        }
    }

    local character_obj = addon.character.characterInfo('Mirage Raceway', 'Quadduo')
    lu.assertEquals(character_obj.money, 62993)
    lu.assertEquals(character_obj.guild, 'The Wasnots')
    lu.assertEquals(character_obj.name, 'Quadduo')
    lu.assertEquals(character_obj.realm, 'Mirage Raceway')
end

os.exit(lu.LuaUnit.run())