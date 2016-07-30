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
    if (self.fixes[v] ~= nil) == active then
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
