-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                 "EskaQuestTracker.Loader"                             ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
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
