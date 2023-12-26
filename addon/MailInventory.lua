---@type LibInventoryAce
local addon = _G['LibInventoryAce']

---@class LibInventoryMailInventory
local lib = addon:NewModule("LibInventoryMailInventory", "AceEvent-3.0")

---@type LibInventoryMail
local mail = addon:GetModule('LibInventoryMail')

---@type LibInventoryLocations
local inventory = addon:GetModule('LibInventoryLocations')

function lib:OnEnable()
    self:RegisterEvent('MAIL_INBOX_UPDATE')
end

---This event is fired when the inbox changes in any way.
---https://warcraft.wiki.gg/wiki/MAIL_INBOX_UPDATE
function lib:MAIL_INBOX_UPDATE()
    --@debug@
    print('Mail inbox updated')
    --@end-debug@
    self:scanMail()
end

function lib:scanMail()
    inventory:clearLocation('mail')
    local mails = mail:NumMails()
    --@debug@
    print(('Scan %d mail(s)'):format(mails))
    --@end-debug@
    local items
    if mails == 0 then
        return
    end
    local mailItemCount = {}
    for mailIndex = 1, mails do
        items = mail:GetMailItems(mailIndex)
        for _, item in ipairs(items) do
            if mailItemCount[item["itemID"]] == nil then
                mailItemCount[item["itemID"]] = item["itemCount"]
            else
                mailItemCount[item["itemID"]] = mailItemCount[item["itemID"]] + item["itemCount"]
            end
        end
    end
    for itemID, itemCount in pairs(mailItemCount) do
        inventory:saveItemLocation(itemID, 'mail', itemCount)
    end
end