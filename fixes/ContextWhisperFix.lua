_G.CarbineUIFixes = rawget(_G, "CarbineUIFixes") or {}

local ContextWhisperFix = {}

function ContextWhisperFix:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function ContextWhisperFix:Init()
  self.dependencies = {"ChatLog"}
end

function ContextWhisperFix:OnLoad()
  Apollo.GetPackage("Gemini:Hook-1.0").tPackage:Embed(self)
  self:RawHook(Apollo.GetAddon("ChatLog"), "OnGenericEvent_ChatLogWhisper")
  self:RawHook(Apollo.GetAddon("ChatLog"), "HelperGetCurrentEditbox")
end

function ContextWhisperFix:HelperGetCurrentEditbox(self)
  local wndEdit
  -- find the last used chat window
  for idx, wndCurrent in pairs(self.tChatWindows) do
    local tData = wndCurrent:GetData()
    if tData and not tData.bCombatLog and wndCurrent:FindChild("Input"):GetData() and wndCurrent:IsShown() then
      wndEdit = wndCurrent:FindChild("Input")
      break
    end
  end

  -- if none found, use the first on our list
  if wndEdit == nil then
    for idx, wndCurrent in pairs(self.tChatWindows) do
      local tData = wndCurrent:GetData()
      if tData and not tData.bCombatLog and wndCurrent:IsShown() then
        wndEdit = wndCurrent:FindChild("Input")
        break
      end
    end
  end

  return wndEdit
end

function ContextWhisperFix:OnGenericEvent_ChatLogWhisper(self, strTarget)
  local wndParent = nil
  for idx, wndCurr in pairs(self.tChatWindows) do
    if wndCurr and wndCurr:IsValid() and wndCurr:GetData() and not wndCurr:GetData().bCombatLog then
      wndParent = wndCurr
      break
    end
  end

  if not wndParent then
    return
  end

  if not strTarget and self.tLastWhisperer and self.tLastWhisperer.strCharacterName then
    strTarget = self.tLastWhisperer.strCharacterName
  end

  local wndEdit = self:HelperGetCurrentEditbox()
  local strOutput = String_GetWeaselString(Apollo.GetString("ChatLog_MessageToPlayer"), Apollo.StringToLower(Apollo.GetString("ChatType_Tell")), strTarget)
  wndEdit:SetText(strOutput)
  wndEdit:SetFocus()
  wndEdit:SetSel(strOutput:len(), -1)
  self:OnInputChanged(nil, wndEdit, strOutput)
end

_G.CarbineUIFixes.ContextWhisperFix = ContextWhisperFix:new()
