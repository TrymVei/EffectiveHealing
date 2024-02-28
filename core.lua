-- Spells
local HealingTouch1 = 5185
local HealingTouch2 = 5186
local HealingTouch3 = 5187
local HealingTouch4 = 5188
local HealingTouch5 = 5189
local HealingTouch6 = 6678
local HealingTouch7 = 8903

local Rejuvenation1 = 417058

------------------------------------------------------------------------

local function getSpellCost(spellID)
  local cost = GetSpellPowerCost(spellID)
  if cost then
    return cost[1].cost
  else
    print("Error: No cost found for spellID: " .. spellID)
  end
end

------------------------------------------------------------------------

local function getHealingPower()
  local healingPower = UnitStat("player", 4)
  return healingPower
end

------------------------------------------------------------------------

local function getHealOverTime(spellID)
  local tooltip = CreateFrame("GameTooltip", "MyAddonTooltip", UIParent, "GameTooltipTemplate")
  tooltip:SetOwner(UIParent, "ANCHOR_NONE")
  tooltip:SetSpellByID(spellID)

  for i = 1, tooltip:NumLines() do
    local text = _G["MyAddonTooltipTextLeft" .. i]:GetText()
    if text and text:match("over (%d+)") then
      return tonumber(text:match("over (%d+)"))
    end
  end
  return nil
end

------------------------------------------------------------------------

local function getSpellHealAmount(spellID)
  local tooltip = CreateFrame("GameTooltip", "MyAddonTooltip", UIParent, "GameTooltipTemplate")
  tooltip:SetOwner(UIParent, "ANCHOR_NONE")
  tooltip:SetSpellByID(spellID)

  -- Search for healing text in tooltip
  for i = 1, tooltip:NumLines() do
    local text = _G["MyAddonTooltipTextLeft" .. i]:GetText()
    if text and text:match("to (%d+)") then
      local amount = tonumber(text:match("to (%d+)"))
      tooltip:Hide()
      return amount
    elseif text and text:match("for (%d+)") then
      local amount = tonumber(text:match("for (%d+)"))
      tooltip:Hide()
      return amount
    end
  end
  tooltip:Hide()
  return nil -- Return nil if healing amount not found
end

------------------------------------------------------------------------

local function getCastTime(spellID)
  name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(spellID)
  return castTime / 1000
end

------------------------------------------------------------------------

local function getHPS(spellID)
  local healAmount = getSpellHealAmount(spellID)
  local castTime = getCastTime(spellID)

  if healAmount and castTime > 0 then
    return healAmount / castTime
  else
    if getHealOverTime(spellID) then
      local hot = getHealOverTime(spellID)
      return healAmount / hot
    else
      return nil
    end
  end
end

------------------------------------------------------------------------

local function getHealingAmountWithCoefficient(spellID)
  local healAmount = getSpellHealAmount(spellID)
  local castTime = getCastTime(spellID)
  if castTime == 0 then
    castTime = 1
  end
  local coefficient = castTime / 3.5
  local healingPower = getHealingPower()

  return healAmount + (coefficient * healingPower)
end
------------------------------------------------------------------------

function getHealPerMana(spellID)
  local healAmount = getSpellHealAmount(spellID)
  local cost = getSpellCost(spellID)
  if healAmount and cost then
    return healAmount / cost
  else
    return nil
  end
end

------------------------------------------------------------------------

local function isAHealingSpell(spellID)
  local tooltip = CreateFrame("GameTooltip", "MyAddonTooltip", UIParent, "GameTooltipTemplate")
  tooltip:SetOwner(UIParent, "ANCHOR_NONE")
  tooltip:SetSpellByID(spellID)

  for i = 1, tooltip:NumLines() do
    local text = _G["MyAddonTooltipTextLeft" .. i]:GetText()
    if text and string.find(text:lower(), "heals") then
      return true
    end
  end
  return false
end

------------------------------------------------------------------------

function showHPSInTooltips()
  GameTooltip:HookScript("OnTooltipSetSpell", function(self)
    local spellName, spellID = GameTooltip:GetSpell()
    local hpm = getHealPerMana(spellID)
    local hps = getHPS(spellID)
    if isAHealingSpell(spellID) then
      if hps then
        self:AddLine("HPS: " .. string.format("%.2f", hps), 0, 255, 0)
      end
      if hpm then
        self:AddLine("HPM: " .. string.format("%.2f", hpm), 0, 125, 255)
      end
    end
  end)
end

------------------------------------------------------------------------

showHPSInTooltips()

-- Registering the chat command handler
SLASH_EH1 = "/eh"
SlashCmdList["EH"] = function(msg)
  if msg == "" then
    PrintHelloWorld()
  end
end

function PrintHelloWorld()
  print("Hello World!")
end
