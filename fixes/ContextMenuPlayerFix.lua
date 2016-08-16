_G.CarbineUIFixes = rawget(_G, "CarbineUIFixes") or {}

local ContextMenuPlayerFix = {
  active = false,
  url = "https://forums.wildstar-online.com/forums/index.php?/topic/152970-new-bugs-introduced-after-the-recent-patch/",
  description = {
    "ContextMenuPlayer tries to access unitTarget everytime but it is only set whenever you are close to somebody.",
    "\nThis means right clicking on anyone that is out of range e.g. in /Nexus chat or in guild list will cause the addon to throw errors."
  }
}

function ContextMenuPlayerFix:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

_G.CarbineUIFixes.ContextMenuPlayerFix = ContextMenuPlayerFix:new()
