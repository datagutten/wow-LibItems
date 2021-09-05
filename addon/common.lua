---@class LibInventory
local addonName, addon = ...
addon.name = addonName
addon.version = '@version@'
_G['LibItems'] = addon
_G['LibInventoryItems'] = addon

local minor
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

