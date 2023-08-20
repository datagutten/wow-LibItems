local num_slots = {
    [0] = 20,
    [1] = 16,
    [2] = 16,
    [3] = 16,
    [4] = 18,
}

function _G.C_Container.GetContainerNumSlots(slot)
    return num_slots[slot]
end

function _G.C_Container.GetContainerItemInfo(containerIndex, slotIndex)
    local item = {
        hasLoot = false,
        hyperlink = "|cffffffff|Hitem:19316::::::::49:253:::::|h[Ice Threaded Arrow]|h|r",
        iconFileID = 135855,
        hasNoValue = true,
        isLocked = false,
        itemID = 19316,
        isBound = false,
        stackCount = 1,
        isFiltered = false,
        isReadable = false,
        quality = 1,
    }
    if containerIndex == 4 and slotIndex == 1 then
        item['stackCount'] = 196
    elseif containerIndex == 4 or containerIndex == 1 then
        item['stackCount'] = 200
    elseif containerIndex == 2 and slotIndex >= 1 and slotIndex <= 3 then
        item['stackCount'] = 200
    else
        item = nil
    end
    return item
end

--return C_Container