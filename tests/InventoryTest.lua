loadfile('build_utils/wow_api/frame.lua')()
loadfile('build_utils/wow_api/functions.lua')()
loadfile('build_utils/utils/load_toc.lua')('../LibInventory.toc')
---@type LibInventory
local addon = _G['AddonTable']

local lu = require('luaunit')
_G['test'] = {}
local test = _G['test']

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

os.exit(lu.LuaUnit.run())