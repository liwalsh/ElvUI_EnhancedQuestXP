local E, L, V, P, G = unpack(ElvUI)
local EQX = E:GetModule("EnhancedQuestXP")

---@diagnostic disable
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
---@diagnostic enable

function EQX.Utils:ColorizeText(text, color)
    color = color or "ff8000"
    return format("|cff%s%s|r", color, text)
end

function EQX.Utils.IsMaxLevel(player)
	return UnitLevel(player) >= 80
end

EQX.Utils.xpDisabledCache = nil

function EQX.Utils.IsXPDisabled()
	if IsXPUserDisabled then
		return IsXPUserDisabled()
	end
	return false
end

function EQX.Utils:UpdateXPDisabledState()
	local wasDisabled = self.xpDisabledCache
	local isDisabled = self.IsXPDisabled()
	self.xpDisabledCache = isDisabled
	return isDisabled, wasDisabled
end

function EQX.Utils:GetXPDisabledState()
	if self.xpDisabledCache == nil then
		self:UpdateXPDisabledState()
	end
	return self.xpDisabledCache
end

function EQX.Utils:NotifyXPStatus(isDisabled, isInitial)
	local prefix = "|cff1784d1[Enhanced Quest XP]|r "

	if isDisabled then
		local msg = isInitial and L["XP_DISABLED_DETECTED"] or L["XP_DISABLED_CHANGED"]
		print(prefix .. "|cffff6666" .. msg .. "|r")
	else
		if not isInitial then
			print(prefix .. "|cff66ff66" .. L["XP_ENABLED_CHANGED"] .. "|r")
		end
	end
end

function EQX.Utils:HasBuffById(unit, searchSpellId)
    local i = 1
    while true do
        local name, _, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, i)
        if not name then return false, nil end
        if spellId == searchSpellId then return true, i end
        i = i + 1
    end
end

function EQX.Utils:HasDebuffById(unit, searchSpellId)
    local i = 1
    while true do
        local name, _, _, _, _, _, _, _, _, _, spellId = UnitDebuff(unit, i)
        if not name then return false, nil end
        if spellId == searchSpellId then return true, i end
        i = i + 1
    end
end

function EQX.Utils:ParseBuffPercentage(unit, buffIndex)
    if not buffIndex then return 0 end

    if not EQX.ScanTooltip then
        EQX.ScanTooltip = CreateFrame("GameTooltip", "EQXScanTooltip", nil, "GameTooltipTemplate")
        EQX.ScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end

    local tooltip = EQX.ScanTooltip
    tooltip:ClearLines()
    tooltip:SetUnitBuff(unit, buffIndex)

    for i = 1, tooltip:NumLines() do
        local line = _G["EQXScanTooltipTextLeft" .. i]
        if line then
            local text = line:GetText()
            if text then
                for _, pattern in ipairs(EQX.Constants.Patterns.ExpBonus) do
                    local percent = text:match(pattern)
                    if percent then
                        return tonumber(percent) or 0
                    end
                end
            end
        end
    end

    return 0
end

function EQX.Utils:ParseDebuffPercentage(unit, debuffIndex)
    if not debuffIndex then return 0 end

    if not EQX.ScanTooltip then
        EQX.ScanTooltip = CreateFrame("GameTooltip", "EQXScanTooltip", nil, "GameTooltipTemplate")
        EQX.ScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end

    local tooltip = EQX.ScanTooltip
    tooltip:ClearLines()
    tooltip:SetUnitDebuff(unit, debuffIndex)

    for i = 1, tooltip:NumLines() do
        local line = _G["EQXScanTooltipTextLeft" .. i]
        if line then
            local text = line:GetText()
            if text then
                for _, pattern in ipairs(EQX.Constants.Patterns.ExpBonus) do
                    local percent = text:match(pattern)
                    if percent then
                        return tonumber(percent) or 0
                    end
                end
            end
        end
    end

    return 0
end

function EQX.Utils:ParseServerMultiplier()
    local realmName = GetRealmName() or ""
    local multiplier = realmName:match(EQX.Constants.Patterns.ServerMultiplier)
    return tonumber(multiplier) or EQX.Constants.Defaults.ServerMultiplier
end

function EQX.Utils:GetEquippedItemId(slot)
    local itemLink = GetInventoryItemLink("player", slot)
    if itemLink then
        local itemId = itemLink:match("item:(%d+)")
        return tonumber(itemId)
    end
    return nil
end

function EQX.Utils:Round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function EQX.Utils:Debug(...)
    if E.db.enhanceQuestXP and E.db.enhanceQuestXP.debugMode then
        print("|cff1784d1[EQX Debug]|r", ...)
    end
end