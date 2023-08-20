---@type LibInventoryAce
local addon = _G['LibInventoryAce']

---@class LibInventorySkills
local lib = _G['LibInventoryAce']:NewModule('LibInventorySkills', 'AceEvent-3.0')

---@type LibProfessionsCommon
local professions = _G.LibStub('LibProfessions-0')
local profession = professions.currentProfession
---@type BMUtils
local utils = _G.LibStub('BM-utils-2')

function lib:OnInitialize()
    self.db = addon.db:RegisterNamespace('Skills')
    self.db_global = _G['LibInventoryDB']['namespaces']['Skills']['char']
    _G['SkillDB'] = self.db_global
    self:saveSkills()
end

function lib:OnEnable()
    self:RegisterEvent('TRADE_SKILL_UPDATE')
    self:RegisterEvent('TRADE_SKILL_SHOW')
    self:RegisterEvent('TRADE_SKILL_CLOSE')
    self:RegisterEvent('NEW_RECIPE_LEARNED')
end

function lib:professionInfo()
    local skill = {}
    skill['professionName'],
    skill['skill'],
    skill['maxSkill'],
    skill['skillModifier'],
    skill['professionID'] = professions.api.GetInfo()
    return skill
end

function lib:saveRecipes()
    local recipes = profession:GetRecipes()

    local professionName, skill, maxSkill = professions.api.GetInfo()
    --[[    self.db.char[professionName]['skill'] = skill
        self.db.char[professionName]['maxSkill'] = maxSkill]]
    utils.table.subTableCheck(self.db.char, professionName, 'recipes')
    print(('Save recipes for %s'):format(professionName))
    for recipeID, recipe in pairs(recipes) do
        if recipeID ~= nil and recipe ~= nil then
            self.db.char[professionName]['recipes'][recipeID] = recipe['recipeId']
        end
    end
end

function lib:TRADE_SKILL_SHOW()
    self:saveRecipes()
end

function lib:TRADE_SKILL_CLOSE()
    --Update skill
    self:saveSkills()
end

function lib:TRADE_SKILL_UPDATE(_, arg1)
    print('TRADE SKILL UPDATE', arg1)
    self:saveRecipes()
end

function lib:NEW_RECIPE_LEARNED(event, arg1)
    local spellId = arg1
    self:saveRecipes()
end

function lib:saveSkills()
    local headerName
    local numSkills = _G.GetNumSkillLines();
    for skillIndex = 1, numSkills, 1 do
        local skillName, header, _, skillRank, numTempPoints,
        skillModifier, skillMaxRank = _G.GetSkillLineInfo(skillIndex);

        if (header) then
            headerName = skillName
        else
            self.db.char[skillName] = {
                skillName = skillName,
                skillRank = skillRank,
                numTempPoints = numTempPoints,
                skillModifier = skillModifier,
                skillMaxRank = skillMaxRank,
                category = headerName
            }
            if headerName .. ':' == _G.SECONDARY_SKILLS or headerName == _G.TRADE_SKILLS then
                local name, rank, icon, _, _, _, spellID, originalIcon = _G.GetSpellInfo(skillName)
                self.db.char[skillName]['spell'] = {
                    name = name,
                    rank = rank,
                    icon = icon,
                    spellID = spellID,
                    originalIcon = originalIcon,
                }
                self.db.char[skillName]['recipes'] = {}
            end
        end
    end
end

function lib:getSkills(category)
    local skills = {}
    for _, skill in pairs(self.db.char) do
        if category == nil or skill['category'] == category then
            table.insert(skills, skill)
        end
    end
    return skills
end

function lib:getCharacterSkills(character, realmKey)
    local character_temp, charKey
    if not character then
        return self.db.char
    else
        if not realmKey then
            character_temp, realmKey = string.match(character, '^(.-)%s-%s(.+)$')
            if not realmKey then
                realmKey = _G.GetRealmName()
            else
                charKey = character
                character = character_temp
            end
        else
            charKey = character .. " - " .. realmKey
        end

        if utils.basic.empty(self.db_global[charKey]) then
            --@debug@
            utils.text.error(('No skills found for character %s'):format(character))
            --@end-debug@
        end
        return self.db_global[charKey]
    end
end
