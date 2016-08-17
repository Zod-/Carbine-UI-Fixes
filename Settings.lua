local CarbineUIFixes = Apollo.GetAddon("CarbineUIFixes")

function CarbineUIFixes:BuildConfig(ui)
  --Active
  ui:category("Active Fixes")
  self:BuildUIFixes(true)

  --Patched
  ui:category("Patched Fixes")
  self:BuildUIFixes(false)

  -- Config and Credits
  ui:navdivider()
  self:BuildUIConfig()
  self:BuildUICredits()
end

function CarbineUIFixes:BuildUIFixes(active)
  for name, fix in pairs(self.fixes) do
    if fix.active == active then
      self:BuildUIHelper(name, fix.description, fix.url)
    end
  end
end

function CarbineUIFixes:BuildUIConfig()
  self.ui:category("Config")
  :header("Configuration")
  :check({
      label = "Debug",
      map = "debug",
      onchange = { handler = self.OnLoadDebug, context = self }
    }
  )
end

function CarbineUIFixes:BuildUICredits()
  local credits = {
    "This addon is developed by Zod Bain@Jabbit",
    "\nSpecial thanks to the developers of _uiMapper and GeminiHook which made it a lot easier to create this addon."
  }
  self.ui:category("Credits"):header("Developer Credits"):note(table.concat(credits, ""))
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
