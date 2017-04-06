_G.CarbineUIFixes = rawget(_G, "CarbineUIFixes") or {}

local BonusRewardTabFix = {
  active = false,
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

_G.CarbineUIFixes.BonusRewardTabFix = BonusRewardTabFix:new()
