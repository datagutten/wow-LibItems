---@type LibInventoryAce
local addon = _G['LibInventoryAce']

---@class LibInventorySkillList
local lib = _G['LibInventoryAce']:NewModule('LibInventorySkillList')

---@type LibInventorySkills
local skills = addon:GetModule('LibInventorySkills')

function lib:characters()
    local chars = {}
    for char, _ in pairs(skills.db_global) do
        table.insert(chars, char)
    end
    return chars
end

function lib:OnEnable()
    self.gui = _G.LibStub('AceGUI-3.0')
end

function lib:show()
    local AceGUI = self.gui
    local f = AceGUI:Create('Frame')
    self.frame = f
    f:SetCallback('OnClose', function(widget)
        AceGUI:Release(widget)
        lib.selectedChar = nil
    end)
    f:SetTitle('Character skills')
    f:SetStatusText('Status Bar')
    f:SetLayout('Flow')
    f:SetWidth(400)

    local dropdown = AceGUI:Create('Dropdown')
    for _, character in pairs(self:characters()) do
        local characterName, _ = string.match(character, '^(.-)%s-%s(.+)$')
        dropdown:AddItem(character, characterName)
    end
    self.skillFrames = {}
    dropdown:SetCallback('OnValueChanged', function(_, _, character)
        lib:show_skills(character)
    end)

    f:AddChild(dropdown)

end

function lib:group_skills(character)
    local count = 0
    local groups = {}
    local character_skills = skills:getCharacterSkills(character)
    for skillName, skill in pairs(character_skills) do
        if skill['category'] ~= nil then
            if groups[skill['category']] == nil then
                groups[skill['category']] = {}
            end
            groups[skill['category']][skillName] = skill
            count = count + 1
        end
    end
    return groups, count
end

function lib:show_skills(character)
    if self.selectedChar ~= nil then
        self.gui:Release(self.frame)
        self:show()
    end
    if self.skillFrames[character] == nil then
        self.skillFrames[character] = self.gui:Create('SimpleGroup')
        self.frame:AddChild(self.skillFrames[character])
    else
        self.skillFrames[character].frame:Show()
    end
    self.skillFrame = self.skillFrames[character]
    self.selectedChar = character

    local skill_groups, skill_count = self:group_skills(character)
    self.frame:SetHeight(30 * skill_count)
    for header, skills_iter in pairs(skill_groups) do
        local group = self.gui:Create('InlineGroup')
        group:SetTitle(header)
        --local header_obj = self.gui:Create('Heading')
        --header_obj:SetText(header)
        self.skillFrame:AddChild(group)

        for skillName, skill in pairs(skills_iter) do
            local label = self.gui:Create('Label')
            label:SetText(('%s: %d'):format(skillName, skill['skillRank']))
            if skill['spell'] then
                label:SetImage(skill['spell']['icon'])
            end
            group:AddChild(label)
        end
    end
end

function _G.skill_list()
    return lib:show()
end

function lib:add_tree()
    local tree = {
        {
            value = 'A',
            text = 'Alpha',
            icon = 'Interface\\Icons\\INV_Drink_05',
        },
        {
            value = 'B',
            text = 'Bravo',
            children = {
                {
                    value = 'C',
                    text = 'Charlie',
                },
                {
                    value = 'D',
                    text = 'Delta',
                    children = {
                        {
                            value = 'E',
                            text = 'Echo'
                        }
                    }
                }
            }
        },
        {
            value = 'F',
            text = 'Foxtrot',
            disabled = true,
        },
    }

    local container = self.gui:Create('TreeGroup')
    container:SetTree(tree)
    self.frame:AddChild(container)

end