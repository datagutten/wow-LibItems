loadfile('build_utils/wow_api/frame.lua')()
loadfile('build_utils/wow_api/functions.lua')()
loadfile('build_utils/utils/load_toc.lua')('../LibInventory.toc')
---@type LibInventory
local addon = _G['AddonTable']

local lu = require('luaunit')
_G['test'] = {}
local test = _G['test']

function _G.UnitName()
    return 'Quadduo'
end

function _G.GetRealmName()
    return 'The Maelstrom'
end

function test.setUp()
    addon.main.locations = {}
    addon.main.items = {}
end

function test.testSaveLocation()
    lu.assertEquals(addon.main.locations, {})
    lu.assertEquals(addon.main.items, {})
    addon.main:saveItemLocation(123, 'Bag', 10, 'Quadduo', 'The Maelstrom')
    lu.assertNotNil(addon.main.items[123])
    lu.assertNotNil(addon.main.locations['Quadduo-The Maelstrom']['Bag'])
end

function test.testGetItemLocation()
    addon.main:saveItemLocation(123, 'Bag', 10, 'Quadduo', 'The Maelstrom')
    local location = addon.main:getItemLocation(123, 'Quadduo', 'The Maelstrom')
    lu.assertEquals(location, { Bag = 10 })
end

function test.testClear()
    addon.main:saveItemLocation(123, 'mail', 10, 'Quadduo', 'The Maelstrom')
    local location = addon.main:getItemLocation(123, 'Quadduo', 'The Maelstrom')
    lu.assertEquals(location, { mail = 10 })
    addon.main:saveItemLocation(123, 'bag', 10, 'Quadduo', 'The Maelstrom')
    addon.main:clearLocation('mail')
    location = addon.main:getItemLocation(123, 'Quadduo', 'The Maelstrom')
    lu.assertEquals(location, { bag = 10 })
end

os.exit(lu.LuaUnit.run())