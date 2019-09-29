local lib = LibStub:NewLibrary("LibMail-0.1", 1)
lib.mail_open = false
local addonName = ...

function lib:recipient(recipient)
    SendMailNameEditBox:SetText(recipient)
end

function lib:money(amount)
    SetSendMailMoney(amount)
end

function lib:cod(amount)
    SetSendMailCOD(amount)
end

function lib:send(target, subject, body)
    --https://wowwiki.fandom.com/wiki/API_SendMail
    SendMail(target, SendMailSubjectEditBox:GetText() or subject or "", body or "")
end

function lib:AddAttachment(bag, slot, key)
    PickupContainerItem(bag, slot)
    ClickSendMailItemButton(key)
end

function lib:attachments(attachments, positions)
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


function lib:eventHandler(event, arg1)
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
frame:SetScript("OnEvent", lib.eventHandler);