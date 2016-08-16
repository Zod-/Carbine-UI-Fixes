_G.CarbineUIFixes = rawget(_G, "CarbineUIFixes") or {}

local BGContextMenuPlayerFix = {
  active = false,
  url = "https://forums.wildstar-online.com/forums/index.php?/topic/152682-contextmenuplayer-in-battlegrounds/",
  description = {
    "When joining a battleground your faction changes but ContextMenuPlayer would not detect this change.",
    "\nBecause of this every player was considered hostile and the menu did not include options for friendly players",
    " like inspect, whisper, etc. and you had to /reloadui everytime"
  }
}

function BGContextMenuPlayerFix:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

_G.CarbineUIFixes.BGContextMenuPlayerFix = BGContextMenuPlayerFix:new()
