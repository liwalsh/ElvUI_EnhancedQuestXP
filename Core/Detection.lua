local E, L, V, P, G = unpack(ElvUI)
local EQX = E:GetModule("EnhancedQuestXP")

EQX.Detection.Cache = {
    serverMultiplier = nil,
    christmasBonus = 0,
    potionBonus = 0,
    familyBonus = 0,
    familyItemCount = 0,
    lastUpdate = 0,
}

function EQX.Detection:DetectServerMultiplier()
    if self.Cache.serverMultiplier then
        return self.Cache.serverMultiplier
    end

    self.Cache.serverMultiplier = EQX.Utils:ParseServerMultiplier()
    EQX.Utils:Debug("Server multiplier detected:", self.Cache.serverMultiplier)
    return self.Cache.serverMultiplier
end

function EQX.Detection:DetectChristmasBonus()
    local buffId = EQX.Constants.Buffs.Christmas
    local hasBuff, buffIndex = EQX.Utils:HasBuffById("player", buffId)

    if hasBuff then
        local percent = EQX.Utils:ParseBuffPercentage("player", buffIndex)
        self.Cache.christmasBonus = percent
        EQX.Utils:Debug("Christmas buff detected:", percent .. "%")
        return percent
    end

    self.Cache.christmasBonus = 0
    return 0
end

function EQX.Detection:DetectPotionBonus()
    for spellId, bonus in pairs(EQX.Constants.Potions) do
        local hasBuff = EQX.Utils:HasBuffById("player", spellId)
        if hasBuff then
            self.Cache.potionBonus = bonus
            EQX.Utils:Debug("Potion buff detected:", bonus .. "%")
            return bonus
        end
    end

    self.Cache.potionBonus = 0
    return 0
end

function EQX.Detection:DetectFamilyItems()
    local totalBonus = 1
    local itemCount = 0

    for _, slot in ipairs(EQX.Constants.EquipmentSlots) do
        local itemId = EQX.Utils:GetEquippedItemId(slot)
        if itemId and EQX.Constants.FamilyItems[itemId] then
            local bonus = EQX.Constants.FamilyItems[itemId]
            totalBonus = totalBonus * (1 + bonus/100)
            itemCount = itemCount + 1
            EQX.Utils:Debug("Family item found in slot", slot, ":", itemId, "+", bonus .. "%")
        end
    end

    self.Cache.familyBonus = totalBonus
    self.Cache.familyItemCount = itemCount
    EQX.Utils:Debug("Total family bonus:", totalBonus .. "% from", itemCount, "items")
    return totalBonus, itemCount
end

function EQX.Detection:UpdateAll()
    local now = GetTime()
    if now - self.Cache.lastUpdate < 1 then
        return
    end
    self.Cache.lastUpdate = now

    self:DetectChristmasBonus()
    self:DetectPotionBonus()
    self:DetectFamilyItems()
end

function EQX.Detection:GetBonuses()
    local db = E.db.enhanceQuestXP

    local serverMult = db.serverMultiplierAuto and self:DetectServerMultiplier() or db.serverMultiplier

    local christmasBonus = 0
    local potionBonus = 0
    local familyBonus = 0
    local familyCount = 0

    if db.bonusTrackingEnabled then
        christmasBonus = self.Cache.christmasBonus
        potionBonus = self.Cache.potionBonus
        familyBonus = self.Cache.familyBonus
        familyCount = self.Cache.familyItemCount
    end

    return {
        serverMultiplier = serverMult,
        christmasBonus = christmasBonus,
        potionBonus = potionBonus,
        familyBonus = familyBonus,
        familyItemCount = familyCount,
    }
end

function EQX.Detection:GetStatusText()
    local bonuses = self:GetBonuses()
    local parts = {}

    table.insert(parts, format("x%d", bonuses.serverMultiplier))

    if bonuses.christmasBonus > 0 then
        table.insert(parts, format(L["STATUS_CHRISTMAS"], bonuses.christmasBonus))
    end
    if bonuses.potionBonus > 0 then
        table.insert(parts, format(L["STATUS_POTION"], bonuses.potionBonus))
    end
    if bonuses.familyBonus > 0 then
        table.insert(parts, format(L["STATUS_FAMILY"], bonuses.familyBonus, bonuses.familyItemCount))
    end

    return table.concat(parts, " | ")
end
