if _G['LibInventory'] ~= nil then
    error('There should only be one instance of LibInventory')
end
---@type LibInventory
local addonName, addon = ...

---@class LibInventory
_G['LibInventory'] = addon

addon.version = '@project-version@'
addon.major, addon.minor = _G['BMUtils-Version'].parse_version(addon.version)
addon.name = addonName

---@type BMUtils
local utils, minor = _G.LibStub('BM-utils-2')
--assert(minor >= 8, ('BMUtils 1.9 or higher is required, found 1.%d'):format(minor))
--@debug@
print(('LibInventory %s loaded with BMUtils 2.%s'):format(addon.version, minor))
--@end-debug@

---@type LibInventoryMain
addon.main = {}
---@type LibInventoryCharacter
addon.characters = {}
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

---@type BMUtils
addon.utils = utils