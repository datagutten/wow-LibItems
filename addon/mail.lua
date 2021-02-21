---A library to handle mails
_G['LibInventoryMail'] = {}
_G['LibInventoryMail-@project-version@'] = _G['LibInventoryMail']
local mail = _G['LibInventoryMail']

mail.mail_open = false
local addonName = ...

---Set mail recipient
---@param recipient string Mail recipient
function mail:recipient(recipient) --TODO: Remove realm name if it is the current realm, maybe realm should be argument?
    SendMailNameEditBox:SetText(recipient)
end

--- Add money to a mail
---@param amount number Copper amount to be added
function mail:money(amount)
    SetSendMailMoney(amount)
end


---Set cash on delivery
---@param amount number COD copper amount
function mail:cod(amount)
    SetSendMailCOD(amount)
end

function mail:send(target, subject, body)
    --https://wowwiki.fandom.com/wiki/API_SendMail
    SendMail(target, SendMailSubjectEditBox:GetText() or subject or "", body or "")
end

---Add item as attachment to the current mail
---@param bag number Bag id
---@param slot number Slot inside the bag (top left slot is 1, slot to the right of it is 2)
---@param key number The index of the item (1-ATTACHMENTS_MAX_SEND(12))
function mail:AddAttachment(bag, slot, key)
    -- https://wow.gamepedia.com/API_PickupContainerItem
    PickupContainerItem(bag, slot)
    ClickSendMailItemButton(key)
end

function mail:NumMails()
    local numItems, totalItems = GetInboxNumItems()
    return numItems, totalItems
end

--/dump LibInventoryMail:GetMailItems(2)
function mail:GetMailItems(mailIndex)
    local mailItems = {}
    local hasItem = select(8, GetInboxHeaderInfo(mailIndex))

    if hasItem == nil then
        return {}
    end
    local itemInfo, itemLink
    for itemIndex=1, ATTACHMENTS_MAX_RECEIVE, 1 do
        local _, itemID, itemTexture, count, quality, _ = GetInboxItem(mailIndex, itemIndex)
        if itemID then

            itemLink = GetInboxItemLink(mailIndex, itemIndex)
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
    if MailItems[character][itemID] ~= nil and MailItems[character][itemID] > 0 then
        return MailItems[character][itemID]
    end
end


function mail:attachments(attachments, positions)
    local position
    for key, itemID in ipairs(attachments) do
        position = positions[itemID]
        if position then
            --@debug@
            print(item["itemID"], key, position["bag"], position["slot"])
            --@end-debug@
            PickupContainerItem(position["bag"], position["slot"])
            ClickSendMailItemButton(key)
        end
    end
end

--Initialize events
local frame = CreateFrame("FRAME");
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
        ClearCursor()
    end
end
frame:SetScript("OnEvent", mail.eventHandler);