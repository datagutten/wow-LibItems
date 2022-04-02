local major, minor = _G['BMUtils-Version'].parse_version('@project-version@')
---@class LibInventory
local addon = _G.LibStub:NewLibrary("LibInventory-" .. major, minor)
if not addon then
    -- luacov: disable
    return    -- already loaded and no upgrade necessary
    -- luacov: enable
end
_G['LibInventory-@project-version@'] = addon
addon.version = '@project-version@'

---@type BMUtils
addon.utils, minor = _G.LibStub('BM-utils-1')
assert(minor >= 6, ('BMUtils 1.6 or higher is required, found 1.%d'):format(minor))

---@type LibInventoryMain
addon.main = {}
---@type LibInventoryContainer
addon.container = {}

---@type LibInventoryMail
addon.mail = {}
---@type LibInventoryMailInventory
addon.mailInventory = {}
---@type LibInventoryEquipment
addon.equipment = {}
---@type LibInventoryBank
addon.bank = {}

---@type LibInventoryEvents
addon.events = {}

