if _G['LibInventory'] ~= nil then
    error('There should only be one instance of LibInventory')
end

local addonName, addon = ...
local major, minor = _G['BMUtils-Version'].parse_version('@project-version@')
---@class LibInventory
_G['LibInventory'] = addon

addon.version = '@project-version@'
addon.name = addonName

---@type BMUtils
addon.utils, minor = _G.LibStub('BM-utils-1')
assert(minor >= 7, ('BMUtils 1.7 or higher is required, found 1.%d'):format(minor))

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

