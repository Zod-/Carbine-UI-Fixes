require "Apollo"
require "GameLib"

local GAME_VERSION = GameLib.GetVersionInfo()
local CarbineUIFixes = {
  uiMapperLib = "uiMapper:0.9.2",
  version = "1.5.4.13938.0.5.0",
  author = "Zod Bain@Jabbit",
  allFixes = {
    "WhisperFix",
    "ContextMenuPlayerFix",
    "BGContextMenuPlayerFix",
    "ActiveChatTabFix",
    "QueuePopDisappearFix"
  },
  fixes = rawget(_G, "CarbineUIFixes") or {}
}

function CarbineUIFixes:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function CarbineUIFixes:ExecOnFix(fix, funcName, ...)
  if fix[funcName] then
    return pcall(fix[funcName], fix, ...)
  end
end

function CarbineUIFixes:ExecOnFixes(funcName, ...)
  local result = {}
  for key, fix in pairs(self.fixes) do
    if fix[funcName] then
      local err, res = pcall(fix[funcName], fix, ...)
      result[key] = res
    end
  end
  return result
end

function CarbineUIFixes:IsVersionEqual(compVersion)
  local result = true
  for key, val in pairs(compVersion) do
    result = result and GAME_VERSION[key] == val
  end
  return result
end

function CarbineUIFixes:SetFixesActive()
  for key, fix in pairs(self.fixes) do
    if fix.lastActiveVersion then
      fix.active = self:IsVersionEqual(fix.lastActiveVersion)
    else
      fix.active = true
    end
  end
end

function CarbineUIFixes:InitFixes()
  self:SetFixesActive()
  self:ExecOnFixes("Init", self)
end

function CarbineUIFixes:Init()
  self:InitFixes()
  Apollo.RegisterAddon(self, true, "Carbine UI Fixes", {self.uiMapperLib})
  self:RegisterFixesAsAddons()
end

function CarbineUIFixes:RegisterFixesAsAddons()
  for key, fix in pairs(self.fixes) do
    if fix.active then
      Apollo.RegisterAddon(
        fix,
        fix.configEnabled or false,
        fix.configTitle or "",
        fix.dependencies or {}
      )
    end
  end
end

function CarbineUIFixes:OnLoad()
  local uiMapper = Apollo.GetPackage(self.uiMapperLib).tPackage
  Apollo.RegisterSlashCommand("cf", "OnConfigure", self)
  Apollo.RegisterSlashCommand("carbinefixes", "OnConfigure", self)

  self.ui = uiMapper:new({
    container = self.config,
    defaults  = self.defaults,
    name      = "Carbine UI Fixes",
    author    = self.author,
    version   = self.version
  })
  self.ui:build(function(ui)
    self:BuildConfig(ui)
  end)
end

function CarbineUIFixes:OnConfigure()
  if self.ui then
    self.ui.wndMain:Show(true,true)
  end
end

local CarbineUIFixesInst = CarbineUIFixes:new()
CarbineUIFixesInst:Init()
