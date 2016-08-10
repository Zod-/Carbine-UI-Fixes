local CarbineUIFixes = Apollo.GetAddon("CarbineUIFixes")

function CarbineUIFixes:BuildConfig(ui)
  --Active
  ui:category("Active Fixes")
  self:BuildUIFixes(true)

  --Patched
  ui:category("Patched Fixes")
  self:BuildUIFixes(false)

  -- Credits
  ui:navdivider():category("Credits")
  self:BuildUICredits()
end

function CarbineUIFixes:BuildUIFixes(active)
  for _,v in ipairs(self.allFixes) do
    local addonActive = self.fixes[v] and self.fixes[v].active or false
    if addonActive == active then
      self["BuildUI"..v](self)
    end
  end
end

function CarbineUIFixes:BuildUICredits()
  local credits = {
    "This addon is developed by Zod Bain@Jabbit",
    "\nSpecial thanks to the developers of _uiMapper and GeminiHook which made it a lot easier to create this addon."
  }
  self.ui:header("Developer Credits"):note(table.concat(credits, ""))
end

function CarbineUIFixes:BuildUIHelper(title, description, url)
  if type(description) == "table" then
    description = table.concat(description, "")
  end

  self.ui:header(title)
  :note(description)
  :confirmbutton({
      label = "Copy bug thread url",
      confirmButtonType = GameLib.CodeEnumConfirmButtonType.CopyToClipboard,
      actionData = url,
      onclick = function() end
    })
end

function CarbineUIFixes:BuildUIWhisperFix()
  local description = {
    "When responding to an account whisper and then trying to send another message will tell you the user does not exist since the name gets cutoff.",
    "\nFurthermore names with accented characters also get cut off when whispering them more than once."
  }
  self:BuildUIHelper(
    "WhisperResponseFix",
    description,
    "https://forums.wildstar-online.com/forums/index.php?/topic/152665-whisper-and-account-whisper-issues/"
  )
end

function CarbineUIFixes:BuildUIContextMenuPlayerFix()
  local description = {
    "ContextMenuPlayer tries to access unitTarget everytime but it is only set whenever you are close to somebody.",
    "\nThis means right clicking on anyone that is out of range e.g. in /Nexus chat or in guild list will cause the addon to throw errors."
  }
  self:BuildUIHelper(
    "ContextMenuPlayerFix",
    description,
    "https://forums.wildstar-online.com/forums/index.php?/topic/152970-new-bugs-introduced-after-the-recent-patch/"
  )
end

function CarbineUIFixes:BuildUIBGContextMenuPlayerFix()
  local description = {
    "When joining a battleground your faction changes but ContextMenuPlayer would not detect this change.",
    "\nBecause of this every player was considered hostile and the menu did not include options for friendly players",
    " like inspect, whisper, etc. and you had to /reloadui everytime"
  }
  self:BuildUIHelper(
    "BGContextMenuPlayerFix",
    description,
    "https://forums.wildstar-online.com/forums/index.php?/topic/152682-contextmenuplayer-in-battlegrounds/"
  )
end

function CarbineUIFixes:BuildUIActiveChatTabFix()
  local description = {
    "When linking something to chat or trying to whisper someone from the ContextMenu it will always go",
    "Into the last used chat tab instead of the one you are in right now."
  }
  self:BuildUIHelper(
    "ActiveChatTabFix",
    description,
    "https://forums.wildstar-online.com/forums/index.php?/topic/153024-contextmenuplayer-whisper/"
  )
end

function CarbineUIFixes:BuildUIQueuePopDisappearFix()
  local description = {
    "Reloading UI with a pending game window open will make it disappear permanently.",
    "\nThis causes you to get queue penalties when loosing the pvp window for example."
  }
  self:BuildUIHelper(
    "QueuePopDisappearFix",
    description,
    "https://forums.wildstar-online.com/forums/index.php?/topic/153043-pending-game-and-reloadui/"
  )
end

function CarbineUIFixes:BuildUIGlobalNonCombatSpellbookFix()
  local description = {
    "Due to a bug in both Carbines and atleast one 3rd party addon the Non-Combat Ability menu crashes when opening it.",
    "\nCarbine reads from a global variable by accident and 3rd party addons writes to the same global variable by accident.",
    "\nBoth mistakes combined cause the crash."
  }
  self:BuildUIHelper(
    "GlobalNonCombatSpellbookFix",
    description,
    "https://forums.wildstar-online.com/forums/index.php?/topic/153100-crash-in-noncombatspellbook/"
  )
end
