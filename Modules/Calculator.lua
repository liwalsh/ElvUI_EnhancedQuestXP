local E, L, V, P, G = unpack(ElvUI)
local EQX = E:GetModule("EnhancedQuestXP")

function EQX.Calculator:CalculateRealXP(displayedXP)
    if not displayedXP or displayedXP <= 0 then
        return 0
    end

    local bonuses = EQX.Detection:GetBonuses()
    local totalAdditiveBonus = 100 + bonuses.christmasBonus + bonuses.potionBonus
    local baseXP = displayedXP / totalAdditiveBonus
    local resultXP = baseXP * 100 * bonuses.serverMultiplier

    if bonuses.christmasBonus > 0 then
        resultXP = resultXP * (1 + bonuses.christmasBonus / 100)
    end

    if bonuses.potionBonus > 0 then
        resultXP = resultXP * (1 + bonuses.potionBonus / 100)
    end

    if bonuses.familyBonus > 0 then
        resultXP = resultXP * (1 + bonuses.familyBonus / 100)
    end

    return math.floor(resultXP)
end

function EQX.Calculator:GetXPMultiplier()
    local bonuses = EQX.Detection:GetBonuses()

    local totalAdditiveBonus = 100 + bonuses.christmasBonus + bonuses.potionBonus

    local multiplier = 100 * bonuses.serverMultiplier / totalAdditiveBonus

    if bonuses.christmasBonus > 0 then
        multiplier = multiplier * (1 + bonuses.christmasBonus / 100)
    end

    if bonuses.potionBonus > 0 then
        multiplier = multiplier * (1 + bonuses.potionBonus / 100)
    end

    if bonuses.familyBonus > 0 then
        multiplier = multiplier * bonuses.familyBonus
    end

    return multiplier
end

function EQX.Calculator:GetBreakdown(displayedXP)
    local bonuses = EQX.Detection:GetBonuses()
    local realXP = self:CalculateRealXP(displayedXP)

    return {
        displayedXP = displayedXP,
        realXP = realXP,
        serverMultiplier = bonuses.serverMultiplier,
        christmasBonus = bonuses.christmasBonus,
        potionBonus = bonuses.potionBonus,
        familyBonus = bonuses.familyBonus,
        familyItemCount = bonuses.familyItemCount,
        multiplier = self:GetXPMultiplier(),
    }
end
