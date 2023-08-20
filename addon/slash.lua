---@type LibInventoryContainer
local inventory = _G['LibInventoryAce']:GetModule('LibInventoryContainer')

_G.SLASH_SCANBAGS1 = "/scanbags"
_G.SlashCmdList["SCANBAGS"] = function()
    inventory:scanBags()
end
