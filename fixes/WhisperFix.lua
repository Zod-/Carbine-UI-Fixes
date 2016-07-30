require "Apollo"
_G.CarbineUIFixes = rawget(_G, "CarbineUIFixes") or {}

local WhisperFix = {}

function WhisperFix:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function WhisperFix:Init()
  self.load = Apollo.GetAddon("WhisperFix") == nil
  self.dependencies = self.load and {"ChatLog"} or {}
end

function WhisperFix:OnLoad()
  if not self.load then
    return
  end
  Apollo.GetPackage("Gemini:Hook-1.0").tPackage:Embed(self)
  self:Hook(Apollo.GetAddon("ChatLog"), "OnDocumentReady")
end

function WhisperFix:OnDocumentReady()
  --for some reason gotta delay the RawHook
  self:RawHook(Apollo.GetAddon("ChatLog"), "VerifyChannelVisibility")
end

--Copying carbines function and fixing the issues
function WhisperFix:VerifyChannelVisibility(self, channelChecking, tInput, wndChat)
  local tChatData = wndChat:GetData()

  local bNewChannel = self.channelLastChannel ~= channelChecking
  self.channelLastChannel = channelChecking
  if self.tAllViewedChannels[channelChecking:GetUniqueId()] ~= nil then
    local strMessage = tInput.strMessage
    if channelChecking:GetType() == ChatSystemLib.ChatChannel_AccountWhisper then
      if self.tAccountWhisperContex then
        local strCharacterAndRealm = self.tAccountWhisperContex.strCharacterName .. "@" .. self.tAccountWhisperContex.strRealmName
        strMessage = string.gsub(strMessage, self.tAccountWhisperContex.strDisplayName, strCharacterAndRealm, 1)
      end
    end

    if tInput.strCommand ~= "" or bNewChannel then
      self.strLastTarget = ""
    end

    local strSend = ""
    if self.strLastTarget and self.strLastTarget ~= "" then
      strSend = self.strLastTarget.." "..strMessage
    else
      strSend = strMessage

      local strPattern = ""
      if channelChecking:GetType() == ChatSystemLib.ChatChannel_Whisper then
        --First fix to also include accented characters
        strPattern = "%s[^%s]*%s-"
      elseif channelChecking:GetType() == ChatSystemLib.ChatChannel_AccountWhisper then
        if self.tAccountWhisperContex then
          --Look for @Realm when it's a full character name
          strPattern = "@%a*"
        else
          local split = string.split(strSend, " ")
          if split[2] and string.match(split[2], "[^@]+@%a+") then
            strPattern = "@%a*"
          else
            strPattern = "%s"
          end
        end
      end
      local nPlaceHolder, nSubstringStop = string.find(strSend, strPattern)

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

    strMessage = String_GetWeaselString(Apollo.GetString("CRB_Message_not_sent_you_are_not_viewing"), channelChecking:GetName())
    ChatSystemLib.PostOnChannel( ChatSystemLib.ChatChannel_Command, strMessage, "" )
    wndInput:SetText(String_GetWeaselString(Apollo.GetString("ChatLog_MessageToPlayer"), tInput.strCommand, tInput.strMessage))
    wndInput:SetFocus()
    local strSubmitted = wndInput:GetText()
    wndInput:SetSel(strSubmitted:len(), -1)
    return false
  end
end

_G.CarbineUIFixes.WhisperFix = WhisperFix:new()
