require "Apollo"
_G.CarbineUIFixes = rawget(_G, "CarbineUIFixes") or {}

local WhisperFix = {
  url = "https://forums.wildstar-online.com/forums/index.php?/topic/152665-whisper-and-account-whisper-issues/",
  description = {
    "When responding to an account whisper and then trying to send another message will tell you the user does not exist since the name gets cutoff.",
    "\nFurthermore names with accented characters also get cut off when whispering them more than once."
  }
}

function WhisperFix:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function WhisperFix:Init()
  self:UnloadWhisperFix()
end

function WhisperFix:UnloadWhisperFix()
  local wf = Apollo.GetAddon("WhisperFix")
  if wf then
    wf.OnLoad = function () end
  end
end

function WhisperFix:OnLoad()
  self:UnloadWhisperFix()
  Apollo.GetPackage("Gemini:Hook-1.0").tPackage:Embed(self)
  self:BindHooks(Apollo.GetAddon("ChatLog"))
end

function WhisperFix:BindHooks(addon)
  if not addon then return end
  self:Hook(addon, "OnDocumentReady")
end

function WhisperFix:OnDocumentReady()
  --for some reason gotta delay the RawHook
  self:RawHook(Apollo.GetAddon("ChatLog"), "VerifyChannelVisibility")
end

--Copying carbines function and fixing the issues
function WhisperFix:VerifyChannelVisibility(self, channelChecking, tInput, wndChat)
  local bNewChannel = self.channelLastChannel ~= channelChecking
  self.channelLastChannel = channelChecking
  if self.tAllViewedChannels[channelChecking:GetUniqueId()] ~= nil then
    local strMessage = tInput.strMessage

    if tInput.strCommand ~= "" or bNewChannel then
      self.strLastTarget = ""
    end

    local strSend
    if self.strLastTarget and self.strLastTarget ~= "" then
      strSend = self.strLastTarget.." "..strMessage
    else
      strSend = strMessage

      local strPattern = ""
      if channelChecking:GetType() == ChatSystemLib.ChatChannel_Whisper then
        strPattern = "[^%s]+%s[^%s]+"
      elseif channelChecking:GetType() == ChatSystemLib.ChatChannel_AccountWhisper then
        local fields = {}
        strSend:gsub("([^%s]+)", function(c) fields[#fields+1] = c end)
        if fields[2] and string.match(fields[2], "^[^@]+@%a+$") then
          strPattern = "@%a+"
        else
          strPattern = "%s"
        end
      end
      local _, nSubstringStop = string.find(strSend, strPattern)

      if not nSubstringStop then
        nSubstringStop = Apollo.StringLength(strSend)
      end

      if strPattern ~= "" then
        self.strLastTarget = string.sub(strSend, 0, nSubstringStop)--gets the name of the target
      end
    end

    channelChecking:Send(strSend)
    return true
  else
    local wndInput = wndChat:FindChild("Input")

    local strMessage = String_GetWeaselString(Apollo.GetString("CRB_Message_not_sent_you_are_not_viewing"), channelChecking:GetName())
    ChatSystemLib.PostOnChannel( ChatSystemLib.ChatChannel_Command, strMessage, "" )
    wndInput:SetText(String_GetWeaselString(Apollo.GetString("ChatLog_MessageToPlayer"), tInput.strCommand, tInput.strMessage))
    wndInput:SetFocus()
    local strSubmitted = wndInput:GetText()
    wndInput:SetSel(strSubmitted:len(), -1)
    return false
  end
end

_G.CarbineUIFixes.WhisperFix = WhisperFix:new()
