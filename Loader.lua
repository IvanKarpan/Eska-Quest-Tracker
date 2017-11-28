-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                 "EskaQuestTracker.Loader"                             ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
-- @TODO: Remove __EnableAndDisableOnCondition__, __EnablingOnCondition__,
--        __DisableOnCondition__ and __EnableOnCondition__
-- @TODO: Add the Hook and Secure Hook

__AttributeUsage__{ AttributeTarget = AttributeTargets.ObjectMethod, RunOnce = true, AllowMultiple = true }
  class "__EnableAndDisableOnCondition__" { __SystemEvent__ }
    local function RegisterModule(owner, cond, ...)
      while true do
        owner._Enabled = cond(owner, Wait(...))
      end
    end

    function __EnableAndDisableOnCondition__:ApplyAttribute(target, targetType, owner, name)
      if #self > 0 then
        ThreadCall(RegisterModule, owner, target, unpack(self))
      else
        ThreadCall(RegisterModule, owner, target, name)
      end
    end

__AttributeUsage__{ AttributeTarget = AttributeTargets.ObjectMethod, RunOnce = true, AllowMultiple = true }
  class "__EnablingOnCondition__"  (function(_ENV)
    inherit "__SystemEvent__"

  local function RegisterModule(owner, cond, ...)
    while true do
      local eventInfo = { Wait(...) }
      local enabled = cond(owner, unpack(eventInfo))
      if owner._Enabled and not enabled then
        local handler = owner:GetRegisteredEventHandler(eventInfo[1])
        handler(select(2, unpack(eventInfo)))
      end
      owner._Enabled = enabled
    end
  end
  function ApplyAttribute(self, target, targetType, owner, name)
    if #self > 0 then
      ThreadCall(RegisterModule, owner, target, unpack(self))
    else
      ThreadCall(RegisterModule, owner, target, name)
    end
  end
end)

__AttributeUsage__ { AttributeTarget = AttributeTargets.ObjectMethod, RunOnce = true, AllowMultiple = true }
  class "__EnableOnCondition__" { __SystemEvent__ }
    local function RegisterModule(owner, cond, ...)
      while true do
        if owner._Enabled then
          Next()
        else
          owner._Enabled = cond(owner, Wait(...))
        end
      end
    end

    function __EnableOnCondition__:ApplyAttribute(target, targetType, owner, name)
      if #self > 0 then
        ThreadCall(RegisterModule, owner, target, unpack(self))
      else
        ThreadCall(RegisterModule, owner, target, name)
      end
    end

__AttributeUsage__ { AttributeTarget = AttributeTargets.ObjectMethod, RunOnce = true, AllowMultiple = true }
  class "__DisableOnCondition__" { __SystemEvent__ }
    local function RegisterModule(owner, cond, ...)
      while true do
        if owner._Disabled then
          Next()
        else
          owner._Enabled = not cond(owner, Wait(...))
        end
      end
    end

    function __DisableOnCondition__:ApplyAttribute(target, targetType, owner, name)
      if #self > 0 then
        ThreadCall(RegisterModule, owner, target, unpack(self))
      else
        ThreadCall(RegisterModule, owner, target, name)
      end
    end

__AttributeUsage__ { AttributeTarget = AttributeTargets.ObjectMethod, RunOnce = true, AllowMultiple = true }
class "__EnablingOnEvent__" (function(_ENV)
  inherit "__SystemEvent__"

  local function RegisterModule(owner, cond, ...)
    while true do
      if owner._Enabled then
        Next()
      else
        owner._Enabled = cond(owner, Wait(...))
      end
    end
  end

  function ApplyAttribute(self, target, targetType, owner, name)
    if #self > 0 then
      ThreadCall(RegisterModule, owner, target, unpack(self))
    else
      ThreadCall(RegisterModule, owner, target, name)
    end
  end
end)

__AttributeUsage__ { AttributeTarget = AttributeTargets.ObjectMethod, RunOnce = true, AllowMultiple = true }
class "__DisablingOnEvent__" (function(_ENV)
  inherit "__SystemEvent__"

  local function RegisterModule(owner, cond, ...)
    while true do
      if owner._Disabled then
        Next()
      else
        owner._Enabled = not cond(owner, Wait(...))
      end
    end
  end

  function ApplyAttribute(self, target, targetType, owner, name)
    if #self > 0 then
      ThreadCall(RegisterModule, owner, target, unpack(self))
    else
      ThreadCall(RegisterModule, owner, target, name)
    end
  end
end)


__AttributeUsage__ { AttributeTarget = AttributeTargets.ObjectMethod, RunOnce = true, AllowMultiple = true }
class "__SafeDisablingOnEvent__" (function(_ENV)
  inherit "__SystemEvent__"

  local function RegisterModule(owner, cond, ...)
    while true do
      if owner._Disabled then
        Next()
      else
        local eventInfo = { Wait(...) }
        local disabled = cond(owner, unpack(eventInfo))
        if disabled then
          local handler = owner:GetRegisteredEventHandler(eventInfo[1])
          if handler then
            handler(select(2, unpack(eventInfo)))
          end
        end
        owner._Enabled = not disabled
      end
    end
  end

  function ApplyAttribute(self, target, targetType, owner, name)
    if #self > 0 then
      ThreadCall(RegisterModule, owner, target, unpack(self))
    else
      ThreadCall(RegisterModule, owner, target, name)
    end
  end
end)

__AttributeUsage__{ AttributeTarget = AttributeTargets.ObjectMethod, RunOnce = true, AllowMultiple = true }
  class "__SafeActivatingOnEvent__"  (function(_ENV)
    inherit "__SystemEvent__"

  local function RegisterModule(owner, cond, ...)
    while true do
      local eventInfo = { Wait(...) }
      local enabled = cond(owner, unpack(eventInfo))
      if owner._Enabled and not enabled then
        local handler = owner:GetRegisteredEventHandler(eventInfo[1])
        if handler then
          handler(select(2, unpack(eventInfo)))
        end
      end
      owner._Enabled = enabled
    end
  end
  function ApplyAttribute(self, target, targetType, owner, name)
    if #self > 0 then
      ThreadCall(RegisterModule, owner, target, unpack(self))
    else
      ThreadCall(RegisterModule, owner, target, name)
    end
  end
end)

__AttributeUsage__{ AttributeTarget = AttributeTargets.ObjectMethod, RunOnce = true, AllowMultiple = true }
  class "__ActivatingOnEvent__"  (function(_ENV)
    inherit "__SystemEvent__"

  local function RegisterModule(owner, cond, ...)
    while true do
      owner._Enabled = cond(owner, Wait(...))
    end
  end
  function ApplyAttribute(self, target, targetType, owner, name)
    if #self > 0 then
      ThreadCall(RegisterModule, owner, target, unpack(self))
    else
      ThreadCall(RegisterModule, owner, target, name)
    end
  end
end)
