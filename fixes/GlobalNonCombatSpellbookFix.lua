_G.CarbineUIFixes = rawget(_G, "CarbineUIFixes") or {}

local GlobalNonCombatSpellbookFix = {
  active = false,
  url = "https://forums.wildstar-online.com/forums/index.php?/topic/153100-crash-in-noncombatspellbook/",
  description = {
    "Due to a bug in both Carbines and atleast one 3rd party addon the Non-Combat Ability menu crashes when opening it.",
    "\nCarbine reads from a global variable by accident and 3rd party addons writes to the same global variable by accident.",
    "\nBoth mistakes combined cause the crash."
  }
}

function GlobalNonCombatSpellbookFix:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

_G.CarbineUIFixes.GlobalNonCombatSpellbookFix = GlobalNonCombatSpellbookFix:new()
