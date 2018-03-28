-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio            "EskaQuestTracker.Interfaces.IReusable"               "1.0.0"
-- ========================================================================== --
namespace "EQT"

-- ========================================================================== --
interface "IReusable"
  -- ======================================================================== --
  -- Handlers                                                                 --
  -- ======================================================================== --
  local function IsReusableChanged(self, new, old, prop)
    if new == true then
      if self.Reset then
        self:Reset()
      end
      if Class.IsSubType(getmetatable(self), Frame) then
        self.needToBeRedraw = nil
      end

      _ObjectManager:Recycle(self)

    end
  end
  -- ======================================================================== --
  -- Properties
  -- ======================================================================== --
  property "isReusable" { TYPE = Boolean, DEFAULT = false, HANDLER = IsReusableChanged }

endinterface "IReusable"
