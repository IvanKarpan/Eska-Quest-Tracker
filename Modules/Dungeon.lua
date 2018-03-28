-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                "EskaQuestTracker.Dungeon"                             ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
IsInInstance          = IsInInstance
IsInScenario          = C_Scenario.IsInScenario
GetInfo               = C_Scenario.GetInfo
GetStepInfo           = C_Scenario.GetStepInfo
GetCriteriaInfo       = C_Scenario.GetCriteriaInfo
EJ_GetCurrentInstance = EJ_GetCurrentInstance
EJ_GetInstanceInfo    = EJ_GetInstanceInfo
GetActiveKeystoneInfo = C_ChallengeMode.GetActiveKeystoneInfo
-- ========================================================================== --
function OnLoad(self)
  self._Enabled = false
end

function OnEnable(self)
  Debug("Dungeon module is enabled")
  if not _Dungeon then
    _Dungeon = Dungeon()
    _Addon:RegisterBlock(_Dungeon)
  end

  _Dungeon.isActive = true
  UpdateObjectives()

  SetMapToCurrentZone() -- update the texture


end

function OnDisable(self)
  Debug("Dungeon module is disabled")
  if _Dungeon then
    _Dungeon.isActive = false
  end
end

-- SCENARIO_UPDATE args1 = newStage
__EnableAndDisableOnCondition__ "PLAYER_ENTERING_WORLD" "CHALLENGE_MODE_START" "SCENARIO_UPDATE"
function EnableAndDisableOn(self, ...)
  local inInstance, type = IsInInstance()
  return inInstance and (type == "party") and IsInScenario() and GetActiveKeystoneInfo() == 0
end

__Async__()
__SystemEvent__ "SCENARIO_CRITERIA_UPDATE" "CRITERIA_COMPLETE" "SCENARIO_UPDATE"
function UpdateObjectives()
  local dungeonName, _, numObjectives = GetStepInfo()
  _Dungeon.name = dungeonName
  _Dungeon.numObjectives = numObjectives


  for index = 1, numObjectives do
    local description, criteriaType, completed, quantity, totalQuantity,
    flags, assetID, quantityString, criteriaID, duration, elapsed,
    failed, isWeightProgress = GetCriteriaInfo(index)

    local objective = _Dungeon:GetObjective(index)
    objective.isCompleted = completed

    if isWeightProgress then
      objective.text = description
      objective:ShowProgress()
      objective:SetMinMaxProgress(0, 100)
      objective:SetProgress(quantity)
      objective:SetTextProgress(string.format("%i%%", quantity))
    else
      objective:HideProgress()
      objective.text = string.format("%i/%i %s", quantity, totalQuantity, description)
    end

  end

  _Dungeon:Draw()

end

__SystemEvent__()
function WORLD_MAP_UPDATE()
  _Dungeon.texture = select(6, EJ_GetInstanceInfo(EJ_GetCurrentInstance()))
end
