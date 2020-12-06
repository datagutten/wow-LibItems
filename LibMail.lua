---A library to handle mails
_G['LibMail'] = {}
local lib = _G['LibMail']
lib.utils = _G['BMUtils']
lib.version = '@project-version@'

if LibStub then
	lib.utils = LibStub('BM-utils-1.0')
    lib = LibStub:NewLibrary("LibMail-0.2", 1)
    if not lib then
        return	-- already loaded and no upgrade necessary
    end
end

lib.mail_open = false
local addonName = ...

---Set mail recipient
---@param recipient string Mail recipient
function lib:recipient(recipient) --TODO: Remove realm name if it is the current realm, maybe realm should be argument?
    SendMailNameEditBox:SetText(recipient)
end

--- Add money to a mail
---@param amount number Copper amount to be added
function lib:money(amount)
    SetSendMailMoney(amount)
end


---Set cash on delivery
---@param amount number COD copper amount
function lib:cod(amount)
    SetSendMailCOD(amount)
end

function lib:send(target, subject, body)
    --https://wowwiki.fandom.com/wiki/API_SendMail
    SendMail(target, SendMailSubjectEditBox:GetText() or subject or "", body or "")
end

---Add item as attachment to the current mail
---@param bag number Bag id
---@param slot number Slot inside the bag (top left slot is 1, slot to the right of it is 2)
---@param key number The index of the item (1-ATTACHMENTS_MAX_SEND(12))
function lib:AddAttachment(bag, slot, key)
    -- https://wow.gamepedia.com/API_PickupContainerItem
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