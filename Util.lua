--- @class (partial) AbilityIconsFramework
local AbilityIconsFramework = AbilityIconsFramework

--- Retrieves the base ability id of the skill with the specified ability id.
--- @param slotIndex number The index of a given skill in the action bar.
--- @param hotbarCategory number The category of the hotbar in question.
--- @return number? baseAbilityId The base ability id of the specified skill.
function AbilityIconsFramework.GetBaseAbilityId(slotIndex, hotbarCategory)
    local abilityId = AbilityIconsFramework.GetAbilityId(slotIndex, hotbarCategory)
    if not abilityId then return nil end

    local actionType = GetSlotType(slotIndex, hotbarCategory)
    if actionType == ACTION_TYPE_CRAFTED_ABILITY then
        return GetAbilityIdForCraftedAbilityId(abilityId)
    end

    local progressionData = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(abilityId)
    if not progressionData then return abilityId end

    local skillData = progressionData:GetSkillData()
    if not skillData.GetMorphData then return abilityId end

    local baseMorphData = skillData:GetMorphData(MORPH_SLOT_BASE)
    return baseMorphData and baseMorphData:GetAbilityId() or abilityId
end

--- Retrieves the ability id of the skill found in the specified slotIndex.
--- @param slotIndex number The index of a given skill in the action bar.
--- @param hotbarCategory number The category of the hotbar in question.
--- @return number? abilityId The ability id that corresponds to the skill in question.
function AbilityIconsFramework.GetAbilityId(slotIndex, hotbarCategory)
    local index = tonumber(slotIndex) or 0
    if index < AbilityIconsFramework.MIN_INDEX or index > AbilityIconsFramework.MAX_INDEX then
        return nil
    end
    return GetSlotBoundId(slotIndex, hotbarCategory)
end

--- Retrieves the path of the selected collectible icon for the skill found in the specified slotIndex.
--- @param slotIndex number The index of a given skill in the action bar.
--- @param hotbarCategory number The category of the hotbar in question.
--- @return string? collectibleIcon The path of the icon that corresponds to the selected skill style.
function AbilityIconsFramework.GetSkillStyleIcon(slotIndex, hotbarCategory)
    if not AbilityIconsFramework.GetSettings().showSkillStyleIcons then return nil end

    local abilityId = AbilityIconsFramework.GetAbilityId(slotIndex, hotbarCategory)
    if not abilityId then return nil end

    local baseAbilityId = AbilityIconsFramework.GetBaseAbilityId(slotIndex, hotbarCategory)
    local skillType, skillLineIndex, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(baseAbilityId)
    local progressionId = GetProgressionSkillProgressionId(skillType, skillLineIndex, skillIndex)
    local collectibleId = GetActiveProgressionSkillAbilityFxOverrideCollectibleId(progressionId)
    
    -- Return the collectible icon if available, otherwise return the default ability icon
    return collectibleId and GetCollectibleIcon(collectibleId) or AbilityIconsFramework.GetDefaultAbilityIcon(slotIndex, hotbarCategory)
end

--- Retrieves the custom made icons for crafted abilities.
--- @param slotIndex number The index of a given skill in the action bar.
--- @param hotbarCategory number The category of the hotbar in question.
--- @return string? abilityIcon The path of the icon to be applied to the skill in question.
function AbilityIconsFramework.GetCustomAbilityIcon(slotIndex, hotbarCategory)
    if not AbilityIconsFramework.GetSettings().showCustomScribeIcons then return nil end

    local abilityId = AbilityIconsFramework.GetAbilityId(slotIndex, hotbarCategory)
    if not abilityId then return nil end

    local primaryScriptId = GetCraftedAbilityActiveScriptIds(abilityId)
    if primaryScriptId == 0 then return nil end

    local scriptName = GetCraftedAbilityScriptDisplayName(primaryScriptId)
    local defaultIcon = AbilityIconsFramework.GetDefaultAbilityIcon(slotIndex, hotbarCategory)

    return MapScriptToIcon(scriptName, defaultIcon) or defaultIcon or nil
end

--- Retrieves the icon path of the skill found in the specified slotIndex.
--- @param slotIndex number The index of a given skill in the action bar.
--- @param hotbarCategory number The category of the hotbar in question.
--- @return string? abilityIcon The path of the icon that corresponds to the skill in question.
function AbilityIconsFramework.GetDefaultAbilityIcon(slotIndex, hotbarCategory)
    local abilityId = AbilityIconsFramework.GetAbilityId(slotIndex, hotbarCategory)
    if not abilityId then return nil end

    local actionType = GetSlotType(slotIndex, hotbarCategory)
    if actionType == ACTION_TYPE_CRAFTED_ABILITY then
        abilityId = GetAbilityIdForCraftedAbilityId(abilityId)
    end
    return GetAbilityIcon(abilityId)
end

--- Maps the given scriptName and defaultIcon to their corresponding custom icon.
--- @param scriptName string The name of the focus script based on which the custom icon will be applied.
--- @param defaultIcon string The path of the base game icon to be replaced with our own.
--- @return string? abilityIcon The path of the icon to be applied to the skill in question.
function MapScriptToIcon(scriptName, defaultIcon)
    local customIcons = AbilityIconsFramework.CUSTOM_ABILITY_ICONS[defaultIcon]
    if not customIcons then
         return nil
    end

    -- Get the current game language
    local currentLang = GetCVar("Language.2")
    
    -- Mapping of effect names in different languages
    local effectTranslations = {
        ["en"] = {
            ["flame"] = "flame",
            ["frost"] = "frost",
            ["shock"] = "shock",
            ["magic"] = "magic",
            ["heal"] = "heal",
            ["resources"] = "resources",
            ["ultimate"] = "ultimate",
            ["stun"] = "stun",
            ["immobilize"] = "immobilize",
            ["knockback"] = "knockback",
            ["dispel"] = "dispel",
            ["shield"] = "shield",
            ["physical"] = "physical",
            ["multi-target"] = "multi-target",
            ["bleed"] = "bleed",
            ["trauma"] = "trauma",
            ["poison"] = "poison",
            ["disease"] = "disease",
            ["mitigation"] = "mitigation",
            ["taunt"] = "taunt",
            ["pull"] = "pull"
        },
        ["de"] = {
            ["flame"] = "flammen",
            ["frost"] = "frost",
            ["shock"] = "schock",
            ["magic"] = "magie",
            ["heal"] = "heilung",
            ["resources"] = "ressourcen",
            ["ultimate"] = "ultimativ",
            ["stun"] = "betäubung",
            ["immobilize"] = "festhalten",
            ["knockback"] = "rückstoß",
            ["dispel"] = "bannen",
            ["shield"] = "schild",
            ["physical"] = "physisch",
            ["multi-target"] = "mehrere",
            ["bleed"] = "blutung",
            ["trauma"] = "trauma",
            ["poison"] = "gift",
            ["disease"] = "seuche",
            ["mitigation"] = "mitigation",
            ["taunt"] = "verspotten",
            ["pull"] = "ziehen"
        },
        ["fr"] = {
            ["flame"] = "flamme",
            ["frost"] = "givre",
            ["shock"] = "foudre",
            ["magic"] = "magique",
            ["heal"] = "soin",
            ["resources"] = "ressources",
            ["ultimate"] = "ultime",
            ["stun"] = "étourdissement",
            ["immobilize"] = "immobiliser",
            ["knockback"] = "repousse",
            ["dispel"] = "dissiper",
            ["shield"] = "bouclier",
            ["physical"] = "physique",
            ["multi-target"] = "cible multiple",
            ["bleed"] = "saignement",
            ["trauma"] = "trauma",
            ["poison"] = "poison",
            ["disease"] = "maladie",
            ["mitigation"] = "absorption",
            ["taunt"] = "provocation",
            ["pull"] = "attraction"
        },
        ["es"] = {
            ["flame"] = "fuego",
            ["frost"] = "escarcha",
            ["shock"] = "descarga",
            ["magic"] = "mágic",
            ["heal"] = "cura",
            ["resources"] = "recursos",
            ["ultimate"] = "habilidad máxima",
            ["stun"] = "aturdimiento",
            ["immobilize"] = "inmovilizar",
            ["knockback"] = "empuj",
            ["dispel"] = "disipar",
            ["shield"] = "escudo",
            ["physical"] = "físico",
            ["multi-target"] = "multiobjetivo",
            ["bleed"] = "sangrado",
            ["trauma"] = "trauma",
            ["poison"] = "veneno",
            ["disease"] = "enfermedad",
            ["mitigation"] = "mitigación",
            ["taunt"] = "provocar",
            ["pull"] = "atracción"
        },
        ["ru"] = {
            ["flame"] = "огненный",
            ["frost"] = "мороз",
            ["shock"] = "электричество",
            ["magic"] = "магический",
            ["heal"] = "исцеление",
            ["resources"] = "ресурс",
            ["ultimate"] = "суперспособности",
            ["stun"] = "оглушение",
            ["immobilize"] = "обездвиживание",
            ["knockback"] = "отбрасывание",
            ["dispel"] = "рассеивание",
            ["shield"] = "щит",
            ["physical"] = "физический",
            ["multi-target"] = "нескольким целям",
            ["bleed"] = "кровотечения",
            ["trauma"] = "рана",
            ["poison"] = "яд",
            ["disease"] = "болезнетворный",
            ["mitigation"] = "увеличение эффективности",
            ["taunt"] = "провоцирование",
            ["pull"] = "притяжение"
        }
    }

    scriptName = string.lower(scriptName)
    local translations = effectTranslations[currentLang] or effectTranslations["en"]
    
    for key, value in pairs(customIcons) do
        local translatedEffect = translations[key]
        if translatedEffect and string.find(scriptName, translatedEffect, 1, true) then
            return value
        end
    end
    return customIcons[AbilityIconsFramework.DEFAULT]
end

--- Applies the active skill style (if any) to the skill found in the specified slotIndex.
--- @param slotIndex number The index of a given skill in the action bar.
--- @param hotbarCategory number The category of the hotbar in question.
function AbilityIconsFramework.ApplySkillStyle(slotIndex, hotbarCategory)
    AbilityIconsFramework.ApplySkillStyleActive(slotIndex, hotbarCategory)

    local inactiveBar = hotbarCategory == HOTBAR_CATEGORY_PRIMARY and HOTBAR_CATEGORY_BACKUP or HOTBAR_CATEGORY_PRIMARY
    AbilityIconsFramework.ApplySkillStyleInactiveFAB(slotIndex, inactiveBar)
end

--- Retrieves the active skill style for the skill found in the specified slotIndex and applies it.
--- @param slotIndex number The index of a given skill in the action bar.
--- @param hotbarCategory number The category of the hotbar in question.
function AbilityIconsFramework.ApplySkillStyleActive(slotIndex, hotbarCategory)
    local icon = AbilityIconsFramework.GetSkillStyleIcon(slotIndex, hotbarCategory)
                 or AbilityIconsFramework.GetCustomAbilityIcon(slotIndex, hotbarCategory)
                 or AbilityIconsFramework.GetDefaultAbilityIcon(slotIndex, hotbarCategory)
    if icon then
        AbilityIconsFramework.ReplaceAbilityBarIcon(slotIndex, hotbarCategory, icon)
    end
end

--- Calls SetTexture to replace the icon of the skill found in the specified slotIndex.
--- @param slotIndex number The index of a given skill in the action bar.
--- @param hotbarCategory number The category of the hotbar in question.
--- @param icon string The path of the icon that will be assigned to the skill in question.
function AbilityIconsFramework.ReplaceAbilityBarIcon(slotIndex, hotbarCategory, icon)
    local btn = AbilityIconsFramework.GetInactiveBarButtonFAB(slotIndex) or ZO_ActionBar_GetButton(slotIndex, hotbarCategory)
    if btn and btn.icon then
        btn.icon:SetTexture(icon)
    end
end

--- Calls RedirectTexture to replace an existing skill icon with a different one.
function AbilityIconsFramework.ReplaceMismatchedIcons()
    AbilityIconsFramework.GenerateReplacementLists()

    for key, value in pairs(AbilityIconsFramework.BASE_GAME_ICONS_TO_REPLACE) do
        local iconName = string.match(key, "/([^/]+)$")
        if AbilityIconsFramework.GetSettings().replaceMismatchedBaseIcons and AbilityIconsFramework:GetSettings().mismatchedIcons[iconName] then
            RedirectTexture(key, value)
        else
            RedirectTexture(key, key)
        end
    end
end

function AbilityIconsFramework.UpdateDefaultScribingIcons()
    EffectsList = AbilityIconsFramework.GetEffectsList()
    if EffectsList == nil then return end

    for BaseIcon, IconList in pairs(AbilityIconsFramework.CUSTOM_ABILITY_ICONS) do
        local CustomDefaultIcon = IconList[EffectsList.DEFAULT]
        if CustomDefaultIcon ~= nil and AbilityIconsFramework.GetSettings().showCustomScribeIcons then
            RedirectTexture(BaseIcon, CustomDefaultIcon)
        else
            RedirectTexture(BaseIcon, BaseIcon)
        end
    end
end
