_G.CarbineUIFixes = rawget(_G, "CarbineUIFixes") or {}

local GlobalNonCombatSpellbookFix = {}
local karTabTypes = {
  Misc = 2,
  Cmd = 3
}

function GlobalNonCombatSpellbookFix:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function GlobalNonCombatSpellbookFix:Init()
  self.dependencies = {"NonCombatSpellbook"}
end

function GlobalNonCombatSpellbookFix:OnLoad()
  Apollo.GetPackage("Gemini:Hook-1.0").tPackage:Embed(self)
  self:RawHook(Apollo.GetAddon("NonCombatSpellbook"), "ShowTab")
end

function GlobalNonCombatSpellbookFix:ShowTab(self)
  self.wndEntryContainer:DestroyChildren()
  self.wndEntryContainerMisc:DestroyChildren()

  self.wndEntryContainer:Show(self.nSelectedTab == karTabTypes.Cmd)
  self.wndEntryContainerMisc:Show(self.nSelectedTab == karTabTypes.Misc)

  for idx, tData in pairs(self.arLists[self.nSelectedTab]) do
    if self.nSelectedTab == karTabTypes.Misc and tData.bIsActive then
      self:HelperCreateMiscEntry(tData)
    elseif self.nSelectedTab == karTabTypes.Cmd then
      self:HelperCreateGameCmdEntry(tData)
    end
  end

  local function SortFunction(a,b)
    local aData = a and a:GetData()
    local bData = b and b:GetData()
    if not aData and not bData then
      return true
    end
    return (aData.strName or aData.strName) < (bData.strName or bData.strName)
  end

  self.wndEntryContainer:ArrangeChildrenVert(Window.CodeEnumArrangeOrigin.LeftOrTop, SortFunction)
  self.wndEntryContainerMisc:ArrangeChildrenVert(Window.CodeEnumArrangeOrigin.LeftOrTop, SortFunction)
  self.wndEntryContainer:SetText(#self.wndEntryContainer:GetChildren() == 0 and Apollo.GetString("NCSpellbook_NoResultsAvailable") or "")
  self.wndEntryContainerMisc:SetText(#self.wndEntryContainerMisc:GetChildren() == 0 and Apollo.GetString("NCSpellbook_NoResultsAvailable") or "")


  for idx, wndTab in pairs(self.wndTabsContainer:GetChildren()) do
    wndTab:SetCheck(self.nSelectedTab == wndTab:GetData())
  end
end

_G.CarbineUIFixes.GlobalNonCombatSpellbookFix = GlobalNonCombatSpellbookFix:new()
