_G.CarbineUIFixes = rawget(_G, "CarbineUIFixes") or {}

local BonusRewardTabFix = {
  url = "https://forums.wildstar-online.com/forums/index.php?/topic/155157-matchmaker-errors-from-featuredtab/",
  description = {
    "When being in the bonus reward tab the MatchMaker addon throws several errors when trying to queue or joining a group."
  }
}

function BonusRewardTabFix:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function BonusRewardTabFix:OnLoad()
  Apollo.GetPackage("Gemini:Hook-1.0").tPackage:Embed(self)
  self:BindHooks(Apollo.GetAddon("MatchMaker"))
end

function BonusRewardTabFix:BindHooks(addon)
  if not addon then return end
  self:PostHook(addon, "OnPvETabSelected")
  self:PostHook(addon, "OnPvPTabSelected")
  self:PostHook(addon, "OnFeaturedTabSelected")
end

function BonusRewardTabFix:OnPvETabSelected(MatchMaker)
  BonusRewardTabFix.eSelectedMasterType = MatchMaker.eSelectedMasterType
end

function BonusRewardTabFix:OnPvPTabSelected(MatchMaker)
  BonusRewardTabFix.eSelectedMasterType = MatchMaker.eSelectedMasterType
end

function BonusRewardTabFix:OnFeaturedTabSelected(MatchMaker)
  MatchMaker.eSelectedMasterType = BonusRewardTabFix.eSelectedMasterType
end

_G.CarbineUIFixes.BonusRewardTabFix = BonusRewardTabFix:new()
