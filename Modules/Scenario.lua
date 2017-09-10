-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                   "EskaQuestTracker.Scenario"                    "1.0.0"
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
IsInScenario          = C_Scenario.IsInScenario
GetInfo               = C_Scenario.GetInfo
GetStepInfo           = C_Scenario.GetStepInfo
GetCriteriaInfo       = C_Scenario.GetCriteriaInfo
GetBonusSteps         = C_Scenario.GetBonusSteps
GetCriteriaInfoByStep = C_Scenario.GetCriteriaInfoByStep
IsInInstance          = IsInInstance
-- ========================================================================== --
HasTimer = false

function OnLoad(self)
  self._Enabled = false
end

function OnEnable(self)
  Debug("Scenario module is enabled")
  if not _Scenario then
    _Scenario = Scenario()
    _Addon:RegisterBlock(_Scenario)
  end

  _Scenario.isActive = true

  self:UpdateScenario()
  self:UpdateObjectives()
end

function OnDisable(self)
  Debug("Scenario module is disabled")
  if _Scenario then
    _Scenario.isActive = false
    _Scenario:Reset()
  end
end

__EnableAndDisableOnCondition__ "PLAYER_ENTERING_WORLD" "SCENARIO_POI_UPDATE" "SCENARIO_UPDATE"
function EnableAndDisableOn(self)
  -- Prevent the scenario module to be loaded in dungeon
  local inInstance, type = IsInInstance()
  if inInstance and (type == "party") then
    return false
  end

  return IsInScenario()
end


-- Events : SCENARIO_POI_UPDATE SCENARIO_CRITERIA_UPDATE CRITERIA_COMPLETE SCENARIO_UPDATE SCENARIO_COMPLETED
function UpdateObjectives(self)
  local stageName, stageDescription, numObjectives,  _, _, _, numSpells, spellInfo, weightedProgress = GetStepInfo()
  local needRunTimer = false

  _Scenario.stageName = stageName


  if weightedProgress then
    -- @NOTE : Some scenario (e.g : 7.2 Broken shode indroduction, invasion scenario)
    -- can have a objective progress even if it say numObjectives == 0 so we need to check if the
    -- step info has weightedProgress.
    -- If the stage has a weightedProgress, show only this one even if the numObjectives say >= 1.
    _Scenario.numObjectives = 1 -- Say to block there is 1 objective only (even if the game say 0)

    local objective = _Scenario:GetObjective(1) -- get the first objective

    objective.isCompleted = false
    objective.text = stageDescription

    -- progress
    objective:ShowProgress()
    objective:SetMinMaxProgress(0, 100)
    objective:SetProgress(weightedProgress)
    objective:SetTextProgress(PERCENTAGE_STRING:format(weightedProgress))

  else
    local tblBonusSteps = GetBonusSteps()
    local numBonusObjectives = #tblBonusSteps

    _Scenario.numObjectives = numObjectives + numBonusObjectives

    for index = 1, numObjectives do
      local description, criteriaType, completed, quantity, totalQuantity,
      flags, assetID, quantityString, criteriaID, duration, elapsed,
      failed, isWeightProgress = GetCriteriaInfo(index)


      local objective = _Scenario:GetObjective(index)
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

      if elapsed == 0 or duration == 0 then
        objective:HideTimer()
      end

    end

    -- Update the bonus objective
    -- @TODO Improve it later
    for index = 1, numBonusObjectives do
      local bonusStepIndex = tblBonusSteps[index];
      local name, description, numCriteria, stepFailed, isBonusStep, isForCurrentStepOnly = GetStepInfo(bonusStepIndex);
      local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, criteriaFailed = C_Scenario.GetCriteriaInfoByStep(bonusStepIndex, 1);

      local objective = _Scenario:GetObjective(numObjectives + index)
      if objective then
        objective.text = criteriaString
        objective.completed = criteriaCompleted

        if duration > 0 then
          objective:ShowTimer()
          objective:SetTimer(duration, elapsed)
          needRunTimer = true

        else
          objective:HideTimer()
        end
      end
    end
  end

  if needRunTimer then
    if not HasTimer then
      HasTimer = true
      self:RunTimer()
    end
  else
    HasTimer = false
  end
  --_Scenario:Draw()
end

__Thread__()
function RunTimer(self)
  while HasTimer do
    self:UpdateObjectives()
    Delay(0.33)
  end
end

function UpdateScenario()
  if not IsInScenario() then return end

  local title, currentStage, numStages, flags, _, _, _, xp, money = GetInfo();
  _Scenario.name = title
  _Scenario.currentStage = currentStage
  _Scenario.numStages = numStages
end


__SystemEvent__ "SCENARIO_POI_UPDATE" "SCENARIO_CRITERIA_UPDATE" "CRITERIA_COMPLETE" "SCENARIO_UPDATE" "SCENARIO_COMPLETED"
function OBJECTIVES_UPDATE()
  _M:UpdateObjectives()
end

__SystemEvent__()
function SCENARIO_UPDATE()
  _M:UpdateScenario()
  _M:UpdateObjectives()
end

-- ========================================================================== --
--  !!DEBUG PART!!                                                            --
-- ========================================================================== --
-- /debugsce start : create the scenario block
-- /debugsce end : hide the scenario block
-- /debugsce setstage : set the stage number
-- /debugsce setmaxstage : set the maxStage
-- /debugsce setname : set the name
-- /debugsce setstagename : set the stage name
-- /debugsce addobj : add an objective
-- /debugsce remobj : remove an objective

__SlashCmd__ "debugsce" "start"
function DebugStart()
  if not _Scenario then
    _Scenario = Scenario()
    _Addon:RegisterBlock(_Scenario)
    _Addon:DrawBlocks()
  end
end

__SlashCmd__ "debugsce" "end"
function DebugEnd()
  _Scenario.isActive = false
end

__SlashCmd__ "debugsce" "setstage"
function DebugSetStage(stage)
  _Scenario.currentStage = tonumber(stage)
end

__SlashCmd__ "debugsce" "setmaxstage"
function DebugSetMaxStage(maxStage)
  _Scenario.numStages = maxStage
end

__SlashCmd__ "debugsce" "setname"
function DebugSetName(name)
  _Scenario.name = name
end

__SlashCmd__ "debugsce" "setstagename"
function DebugSetStageName(name)
  _Scenario.stageName = name
end

local debugObjectivesText = {
  [1] = "Kill all demons",
  [2] = "Rescue your friends",
  [3] = "Find a myterious object",
  [4] = "Go to the next waypoint",
}

__SlashCmd__ "debugsce" "numobj"
function DebugNumObjective(num)
  _Scenario.numObjectives = tonumber(num)
end

__SlashCmd__ "debugsce" "addobj"
function DebugAddObjective()
  _Scenario.numObjectives = _Scenario.numObjectives + 1
  print(_Scenario.numObjectives)

  local completed = math.random(1, 2) == 1 and true or false
  local text = debugObjectivesText[_Scenario.numObjectives]

  local objective = _Scenario:GetObjective(_Scenario.numObjectives)

  objective.isCompleted = completed
  objective.text = text
  objective:ShowProgress()
  _Scenario:Draw()
end

__SlashCmd__ "debugsce" "remobj"
function DebugRemoveObjective()
  if _Scenario.numObjectives > 0 then
    _Scenario.numObjectives = _Scenario.numObjectives - 1
  end
end


--[[function OnLoad(self)
  local block = Scenario()

  local block2 = Block("Expedition", 5)

  local block3 = Block("Mythic+", 3)
  local block4 = Block("Quest", 4)


  local title, currentStage, numStages, flags, _, _, _, xp, money = C_Scenario.GetInfo();
  block.text = "Scenario"
  block.name = title
  block.currentStage = currentStage
  block.numStages = numStages


  local stageName, stageDescription, numObjectives = C_Scenario.GetStepInfo();
  block.stageName = stageName


  --block4.isActive = false

  _Addon:RegisterBlock(block)
  --_Addon:RegisterBlock(block2)
  --_Addon:RegisterBlock(block3)
  --_Addon:RegisterBlock(block4)

  _Addon:DrawBlocks()

  --_Addon.ObjectiveTrackerFrame.content:SetHeight(block.frame:GetHeight() + 300)
  block.frame:SetParent(_Addon.ObjectiveTrackerFrame.content)
  block.frame:SetPoint("TOPLEFT", _Addon.ObjectiveTrackerFrame.content, "TOPLEFT")
  block.frame:SetPoint("TOPRIGHT", _Addon.ObjectiveTrackerFrame.content, "TOPRIGHT")
end--]]
