-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio         "EskaQuestTracker.Interfaces.IObjectiveHolder"           "1.0.0"
-- ========================================================================== --
namespace "EQT"
import "System.Reflector"
-- ========================================================================== --
interface "IObjectiveHolder"
  -- ======================================================================== --
  -- Handlers                                                                 --
  -- ======================================================================== --
  local function SetNumObjectives(self, new, old)
    if new > old then
      for i = 1, new - old do
        local objective = _ObjectManager:GetObjective()
        self:AddObjective(objective)
      end
    elseif new < old then
      for i = 1, old - new do
        local objective = self:GetObjective(new + 1)
        if objective then
          self.objectives:Remove(objective)
          objective.OnHeightChanged = nil
          objective.isReusable = true
        end
      end
      --if self.Draw then
        --self:Draw()
      --end
    end
    if ObjectIsClass(self, Frame) then
      self.OnDrawRequest()
    end
  end
  -- ======================================================================== --
  -- Methods
  -- ======================================================================== --
  function AddObjective(self, objective)
    self.objectives:Insert(objective)
    objective:SetParent(self.frame)

    objective.OnHeightChanged = function(obj, new, old)
      self.height = self.height + (new - old)
    end
  end

  function GetObjective(self, index)
    return self.objectives[index]
  end

  function ShowDotted(self)
    if not self.dotted then
      self.dotted = _ObjectManager:Get(DottedObjective)
    end

    if self.numObjectives > 0 then
      local obj = self.objectives[self.numObjectives]
      self.dotted:SetParent(self.frame)
      self.dotted.frame:SetPoint("TOPLEFT", obj.frame, "BOTTOMLEFT")
      self.dotted.frame:SetPoint("TOPRIGHT", obj.frame, "BOTTOMRIGHT")
    end

      self.dotted:Show()
      self.height = self.height + self.dotted.height
  end

  function HideDotted(self)
    if not self.dotted then
      return
    end

    if not self.dotted:IsShown() then
      return
    end


    self.dotted:Hide()
    self.height = self.height - self.dotted.height
    self.dotted.isReusable = true
    self.dotted = nil
  end

function DrawObjectives(self, f, custom)
    if not f then return end

    local previousFrame
    local height = 0

    for index, objective in self.objectives:GetIterator() do
      if not objective:IsShown() then
        objective:Show()
      end

      if index == 1 and not custom then
        objective.frame:SetPoint("TOPLEFT", f, "BOTTOMLEFT")
        objective.frame:SetPoint("TOPRIGHT", f, "BOTTOMRIGHT")
      elseif index > 1 then
        objective.frame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT")
        objective.frame:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
      end
      height = height + objective.height
      previousFrame = objective.frame
    end
    if self.dotted and self.dotted:IsShown() then
      height = height + self.dotted.height
    end

    self.height = self.baseHeight + height -- +  5
end

  function ClearObjectives(self)
    while(self.objectives.Count > 0) do self.objectives:RemoveByIndex(list.Count) end
  end


  -- ======================================================================== --
  -- Properties
  -- ======================================================================== --
  property "numObjectives" { TYPE = Number, DEFAULT = 0, HANDLER = SetNumObjectives }
  -- ======================================================================== --
  -- Constructors
  -- ======================================================================== --
  function IObjectiveHolder(self)
    self.objectives = ObjectArray(Objective)
  end

endinterface "IObjectiveHolder"
