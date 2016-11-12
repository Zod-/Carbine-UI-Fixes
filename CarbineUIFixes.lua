require "Apollo"
require "GameLib"

local GAME_VERSION = GameLib.GetVersionInfo()
local CarbineUIFixes = {
  uiMapperLib = "uiMapper:0.9.3",
  uiMapperPath = "libs/_uiMapper/",
  version = "1.6.2.14545.0.6.2",
  author = "Zod Bain@Jabbit",
  fixes = rawget(_G, "CarbineUIFixes") or {},
  saveDataVersion = 1,
  defaults = {},
  config = {},
}
_G.CarbineUIFixes = nil --Cleanup global

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
      if not err then
        Print(res)
      else
        result[key] = res
      end
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
  for _, fix in next, self.fixes do
    if fix.lastActiveVersion then
      fix.active = self:IsVersionEqual(fix.lastActiveVersion)
    elseif fix.active ~= false then
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
  for _, fix in next, self.fixes do
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

  self.defaults = self:GetDefaults()
  self.config = self:GetDefaults()

  self.ui = uiMapper:new({
      container = self.config,
      defaults = self.defaults,
      name = "Carbine UI Fixes",
      author = self.author,
      version = self.version,
      path = self.uiMapperPath,
    }
  ):build(self.BuildConfig, self)
end

function CarbineUIFixes:GetDefaults()
  return {
    debug = false,
  }
end

function CarbineUIFixes:OnSave(eType)
  if eType ~= GameLib.CodeEnumAddonSaveLevel.General then
    return nil
  end

  local saveData = {
    config = self.config,
    saveDataVersion = self.saveDataVersion,
  }

  return saveData
end

function CarbineUIFixes:OnRestore(eType, saveData)
  if eType ~= GameLib.CodeEnumAddonSaveLevel.General then
    return
  end

  for k, _ in next, self.config do
    if saveData.config[k] ~= nil then
      self.config[k] = saveData.config[k]
    end
  end

  self:OnLoadDebug()
end

function CarbineUIFixes:Print(message)
  if type(message) ~= "string" then
    message = tostring(message)
  end
  Print("[CarbineUIFixes]: " .. message) --Change to proper logs
end

function CarbineUIFixes:OnLoadDebug()
  if not self.config.debug then
    return
  end

  if not SendVarToRover then
    self:Print("Could not find Rover.")
    return
  end

  SendVarToRover("CarbineUIFixes", self)
  for name, fix in pairs(self.fixes) do
    SendVarToRover(name, fix)
  end
end

function CarbineUIFixes:OnConfigure()
  if self.ui then
    self.ui:OnSlashCommand()
  end
end

local CarbineUIFixesInst = CarbineUIFixes:new()
CarbineUIFixesInst:Init()
