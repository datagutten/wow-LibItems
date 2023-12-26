---@class LibInventoryMail Library to send and extract items from mail
local mail = _G['LibInventoryAce']:NewModule('LibInventoryMail', 'AceEvent-3.0')

---@type BMUtils
local utils = _G.LibStub('BM-utils-2')

mail.mail_open = false
mail.attachment_key = 0
mail.items = {}

local PickupContainerItem
if _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC then
    PickupContainerItem = _G.PickupContainerItem
else
    PickupContainerItem = _G.C_Container.PickupContainerItem
end

---Set mail recipient
---@param recipient string Mail recipient
function mail:recipient(recipient)
    local character, realm = utils.character.splitCharacterString(recipient)
    if realm == _G.GetRealmName() then
        recipient = character
    end
    _G.SendMailNameEditBox:SetText(recipient)
end

--- Add money to a mail
---@param amount number Copper amount to be added
function mail:money(amount)
    _G.SetSendMailMoney(amount)
    self.money = amount
end

---Set cash on delivery
---@param amount number COD copper amount
function mail:cod(amount)
    _G.SetSendMailCOD(amount)
    self.cod = amount
end

function mail:send(target, subject, body)
    --https://wowwiki.fandom.com/wiki/API_SendMail
    _G.SendMail(target, _G.SendMailSubjectEditBox:GetText() or subject or "", body or "")
    self.body = body
    self.subject = subject
end

---Add item as attachment to the current mail
---@param bag number Bag id
---@param slot number Slot inside the bag (top left slot is 1, slot to the right of it is 2)
---@param key number The index of the item (1-ATTACHMENTS_MAX_SEND(12))
function mail:AddAttachment(bag, slot, key)
    --utils.basic.printf('Attach item from container %d slot %d to %d', bag, slot, key or self.attachment_key)
    -- https://warcraft.wiki.gg/wiki/API_PickupContainerItem
    PickupContainerItem(bag, slot)
    _G.ClickSendMailItemButton(key or self.attachment_key)
    self.attachment_key = self.attachment_key + 1
end

function mail:NumMails()
    local numItems, totalItems = _G.GetInboxNumItems()
    self.mail_count = numItems
    self.mail_total = totalItems
    return numItems
end

--/dump LibInventoryMail:GetMailItems(2)
function mail:GetMailItems(mailIndex)
    local mailItems = {}
    local hasItem = select(8, _G.GetInboxHeaderInfo(mailIndex))

    if hasItem == nil then
        return {}
    end
    local itemInfo, itemLink
    for itemIndex = 1, _G.ATTACHMENTS_MAX_RECEIVE, 1 do
        local _, itemID, itemTexture, count, quality, _ = _G.GetInboxItem(mailIndex, itemIndex)
        if itemID then

            itemLink = _G.GetInboxItemLink(mailIndex, itemIndex)
            itemInfo = { ["icon"] = itemTexture, ["itemCount"] = count, ["quality"] = quality,
                         ["itemLink"] = itemLink, ["itemID"] = itemID }
            table.insert(mailItems, itemInfo)
        end
    end
    self.items[mailIndex] = mailItems
    return mailItems
end


--/dump LibInventoryMail:GetItem(1081, "Quadduo")
function mail:GetItem(itemID, character)
    character = utils.character.getCharacterString(character)
    if _G.MailItems[character][itemID] ~= nil and _G.MailItems[character][itemID] > 0 then
        return _G.MailItems[character][itemID]
    end
end

function mail:attachments(attachments, positions)
    local position
    for key, itemID in ipairs(attachments) do
        position = positions[itemID]
        if position then
            --@debug@
            utils.basic.printf('Attach itemID %s as attachment %d from container %d slot %d',
                    itemID, key, position["bag"], position["slot"])
            --@end-debug@
            PickupContainerItem(position["bag"], position["slot"])
            _G.ClickSendMailItemButton(key)
        end
    end
end

--Event handling
function mail:OnEnable()
    -- https://wowwiki.fandom.com/wiki/Events/Mail
    self:RegisterEvent("MAIL_SEND_SUCCESS")
    self:RegisterEvent("MAIL_SHOW")
    self:RegisterEvent("MAIL_CLOSED")
end

function mail:MAIL_SHOW()
    self.mail_open = true
end

function mail:MAIL_CLOSED()
    self.mail_open = false
    _G.ClearCursor()
end

function mail:MAIL_SEND_SUCCESS()
    self.attachment_key = 0
end
