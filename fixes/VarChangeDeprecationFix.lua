require "Apollo"
_G.CarbineUIFixes = rawget(_G, "CarbineUIFixes") or {}

local VarChangeDeprecationFix = {
  url = "https://forums.wildstar-online.com/forums/index.php?/topic/153645-ptr-pt2-breaks-a-lot-of-addons-api-changes-or-did-smth-break/",
  description = {
    "Carbine quietly deprecated the VarChange_FrameCount event which was used as a next frame event for many older addons.",
  }
}

function VarChangeDeprecationFix:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function VarChangeDeprecationFix:Init()
  self:UnloadVarChangeDeprecationFix()
end

function VarChangeDeprecationFix:UnloadVarChangeDeprecationFix()
  local wf = Apollo.GetAddon("VarChangeDeprecationFix")
  if wf then
    wf.OnLoad = function () end
  end
end

function VarChangeDeprecationFix:OnLoad()
  self:UnloadVarChangeDeprecationFix()
  Apollo.RegisterEventHandler("NextFrame", "OnNextFrame", self)
end

function VarChangeDeprecationFix:OnNextFrame()
  Event_FireGenericEvent("VarChange_FrameCount")
end

_G.CarbineUIFixes.VarChangeDeprecationFix = VarChangeDeprecationFix:new()
