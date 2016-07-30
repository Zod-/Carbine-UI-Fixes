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
