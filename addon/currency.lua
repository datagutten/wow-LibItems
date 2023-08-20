---@type LibInventoryAce
local addon = _G['LibInventoryAce']

---@class LibInventoryCurrency
local lib = _G['LibInventoryAce']:NewModule("LibInventoryCurrency", "AceEvent-3.0")

function lib:OnInitialize()
    self.db = addon.db:RegisterNamespace("Currency")
end

function lib:OnEnable()
    self:RegisterEvent('PLAYER_MONEY')
    self.name = _G.UnitName("player")
    --@debug@
    print(('Loaded money %d'):format(self.db.factionrealm[self.name]))
    --@end-debug@
    --[[    if _G['LibInventoryCurrencyDB'] == nil then
            print('nil set OnEnable')
            _G['LibInventoryCurrencyDB'] = { 'test' }
        else
            print('Dump OnEnable')
            DevTools_Dump(_G['LibInventoryCurrencyDB'])
        end]]
end

function lib:PLAYER_MONEY()
    self.db.factionrealm[self.name] = _G.GetMoney()
    self.db.char['money'] = _G.GetMoney()
    --@debug@
    print(('Save money %d for %s'):format(_G.GetMoney(), self.name))
    --@end-debug@
end