---A library to handle mails
_G['LibInventoryMail'] = {}
_G['LibInventoryMail-@project-version@'] = _G['LibInventoryMail']
local mail = _G['LibInventoryMail']

mail.mail_open = false
mail.attachment_key = 0

---Set mail recipient
---@param recipient string Mail recipient
function mail:recipient(recipient)
    local character, realm = addon.utils:SplitCharacterString(recipient)
    if realm == _G.GetRealmName() then
        recipient = character
    end
    _G.SendMailNameEditBox:SetText(recipient)
end

--- Add money to a mail
---@param amount number Copper amount to be added
function mail:money(amount)
    _G.SetSendMailMoney(amount)
end


---Set cash on delivery
---@param amount number COD copper amount
function mail:cod(amount)
    _G.SetSendMailCOD(amount)
end

function mail:send(target, subject, body)
    --https://wowwiki.fandom.com/wiki/API_SendMail
    _G.SendMail(target, _G.SendMailSubjectEditBox:GetText() or subject or "", body or "")
end

---Add item as attachment to the current mail
---@param bag number Bag id
---@param slot number Slot inside the bag (top left slot is 1, slot to the right of it is 2)
---@param key number The index of the item (1-ATTACHMENTS_MAX_SEND(12))
function mail:AddAttachment(bag, slot, key)
    addon.utils:sprintf('Attach item from container %d slot %d to %d', bag, slot, key or self.attachment_key)
    -- https://wow.gamepedia.com/API_PickupContainerItem
    _G.PickupContainerItem(bag, slot)
    _G.ClickSendMailItemButton(key or self.attachment_key)
    self.attachment_key = self.attachment_key + 1
end

function mail:NumMails()
    local numItems, totalItems = _G.GetInboxNumItems()
    return numItems, totalItems
end

--/dump LibInventoryMail:GetMailItems(2)
function mail:GetMailItems(mailIndex)
    local mailItems = {}
    local hasItem = select(8, _G.GetInboxHeaderInfo(mailIndex))

    if hasItem == nil then
        return {}
    end
    local itemInfo, itemLink
    for itemIndex=1, _G.ATTACHMENTS_MAX_RECEIVE, 1 do
        local _, itemID, itemTexture, count, quality, _ = _G.GetInboxItem(mailIndex, itemIndex)
        if itemID then

            itemLink = _G.GetInboxItemLink(mailIndex, itemIndex)
            itemInfo = { ["icon"] = itemTexture, ["itemCount"] = count, ["quality"] = quality,
                         ["itemLink"] = itemLink, ["itemID"] = itemID }
            table.insert(mailItems, itemInfo)
        end
    end
    return mailItems
end


--/dump LibInventoryMail:GetItem(1081, "Quadduo")
function mail:GetItem(itemID, character)
    character = self.utils:GetCharacterString(character)
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
            self.utils:printf('Attach itemID %s as attachment %d from container %d slot %d', itemID, key, position["bag"], position["slot"])
            --@end-debug@
            _G.PickupContainerItem(position["bag"], position["slot"])
            _G.ClickSendMailItemButton(key)
        end
    end
end

--Initialize events
local frame = _G.CreateFrame("FRAME");
frame:RegisterEvent("ADDON_LOADED");


function mail:eventHandler(event, arg1)
    -- https://wowwiki.fandom.com/wiki/Events/Mail
    if event == "ADDON_LOADED" and arg1 == addonName then
        frame:RegisterEvent("MAIL_SEND_SUCCESS")
        frame:RegisterEvent("MAIL_SHOW")
        frame:RegisterEvent("MAIL_FAILED")
        frame:RegisterEvent("MAIL_CLOSED")
    elseif event == "MAIL_SHOW" then
        self.mail_open = true
    elseif event == "MAIL_CLOSED" then
        self.mail_open = false
        _G.ClearCursor()
    elseif event == "MAIL_SEND_SUCCESS" then
        self.attachment_key = 0
    end
end
frame:SetScript("OnEvent", mail.eventHandler);