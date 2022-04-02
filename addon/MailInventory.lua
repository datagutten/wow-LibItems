---@type LibInventory
local addon = _G['LibInventory-@project-version']
---@class LibInventoryMailInventory
local lib = addon.mailInventory
lib.addon = addon

function lib:scanMail()
    self.addon.main:clearLocation('mail')
    local mails = self.addon.mail:NumMails()
    --@debug@
    self.addon.utils:printf('Scan %d mail(s)', mails)
    --@end-debug@
    local items
    if mails == 0 then
        return
    end
    local mailItemCount = {}
    for mailIndex = 1, mails do
        items = self.addon.mail:GetMailItems(mailIndex)
        for _, item in ipairs(items) do
            if mailItemCount[item["itemID"]] == nil then
                mailItemCount[item["itemID"]] = item["itemCount"]
            else
                mailItemCount[item["itemID"]] = mailItemCount[item["itemID"]] + item["itemCount"]
            end
        end
    end
    for itemID, itemCount in pairs(mailItemCount) do
        self.addon.main:saveItemLocation(itemID, 'mail', itemCount)
    end
end