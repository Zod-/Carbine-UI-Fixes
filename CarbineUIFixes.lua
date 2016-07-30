require "Apollo"

local CarbineUIFixes = {
  uiMapperLib = "uiMapper:0.9.2",
  version = "1.5.4.13938.0.3.0",
  author = "Zod Bain@Jabbit",
  allFixes = {
    "WhisperFix",
    "ContextMenuPlayerFix",
    "BGContextMenuPlayerFix",
    "ContextWhisperFix"
  },
  fixes = rawget(_G, "CarbineUIFixes") or {}
}

function CarbineUIFixes:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function CarbineUIFixes:ExecOnFixes(funcName, ...)
  for _,fix in pairs(self.fixes) do
    if fix[funcName] then
      local err, res = pcall(fix[funcName], fix, ...)
    end
  end
end

function CarbineUIFixes:InitFixes()
  self:ExecOnFixes("Init", self)
end

function CarbineUIFixes:Init()
  self:InitFixes()
  self:GetDependencies()

  Apollo.RegisterAddon(self, true, "Carbine UI Fixes", self.dependencies)
end

function CarbineUIFixes:GetDependencies()
  self.dependencies = {self.uiMapperLib}
  local duplicate = {}
  for k,fix in pairs(self.fixes) do
    for _,v in ipairs(fix.dependencies) do
      if not duplicate[v] then
        table.insert(self.dependencies, v)
        duplicate[v] = true
      end
    end
  end
end

function CarbineUIFixes:OnLoadFixes()
  self:ExecOnFixes("OnLoad", self)
end

function CarbineUIFixes:OnLoad()
  self:OnLoadFixes()

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
