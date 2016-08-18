_G.CarbineUIFixes = rawget(_G, "CarbineUIFixes") or {}

require "MatchingGameLib"
local QueuePopDisappearFix = {
  url = "https://forums.wildstar-online.com/forums/index.php?/topic/153043-pending-game-and-reloadui/",
  description = {
    "Reloading UI with a pending game window open will make it disappear permanently.",
    "\nThis causes you to get queue penalties when loosing the pvp window for example."
  }
}

function QueuePopDisappearFix:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function QueuePopDisappearFix:Init()
  self.dependencies = {"MatchMaker"}
  self.inProgress = false
end

function QueuePopDisappearFix:OnLoad()
  Apollo.RegisterEventHandler("MatchingGameReady", "OnGameReady", self)
  Apollo.GetPackage("Gemini:Hook-1.0").tPackage:Embed(self)
  self:PostHook(Apollo.GetAddon("MatchMaker"), "OnDocumentReady")
end

function QueuePopDisappearFix:OnDocumentReady(MatchMaker)
  if MatchingGameLib.IsPendingGame() then
    MatchMaker:OnGameReady(self.inProgress)
  end
end

function QueuePopDisappearFix:OnGameReady(inProgress)
  self.inProgress = inProgress
end

function QueuePopDisappearFix:OnSave(saveLevel)
  if saveLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
    return nil
  end

  return {inProgress = self.inProgress}
end

function QueuePopDisappearFix:OnRestore(saveLevel, data)
  if saveLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
    return nil
  end

  self.inProgress = data.inProgress or false
end

_G.CarbineUIFixes.QueuePopDisappearFix = QueuePopDisappearFix:new()
