-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio             "EskaQuestTracker.Keystone"                               ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
GetPowerLevelDamageHealthMod = C_ChallengeMode.GetPowerLevelDamageHealthMod
GetActiveKeystoneInfo        = C_ChallengeMode.GetActiveKeystoneInfo
GetAffixInfo                 = C_ChallengeMode.GetAffixInfo
GetMapInfo                   = C_ChallengeMode.GetMapInfo
GetActiveChallengeMapID      = C_ChallengeMode.GetActiveChallengeMapID
GetWorldElapsedTimers        = GetWorldElapsedTimers
GetWorldElapsedTime          = GetWorldElapsedTime
EJ_GetCurrentInstance        = EJ_GetCurrentInstance
EJ_GetInstanceInfo           = EJ_GetInstanceInfo
GetInfo                      = C_Scenario.GetInfo
GetStepInfo                  = C_Scenario.GetStepInfo
GetCriteriaInfo              = C_Scenario.GetCriteriaInfo
-- ========================================================================== --
function OnLoad(self)
   self._Enabled = false
end

function OnEnable(self)
  Debug("Keystone module is enabled")
  if not _Keystone then
    _Keystone = Keystone()
    _Addon:RegisterBlock(_Keystone)
  end

  _Keystone.isActive = true

  local level, affixes, wasEnergized = GetActiveKeystoneInfo()
  local mapID = GetActiveChallengeMapID()
  if mapID then
    local _, _, timeLimit = GetMapInfo(mapID)
    _Keystone.timeLimit = timeLimit
  end

  _Keystone.level = level
  _Keystone.wasEnergized = wasEnergized
  _Keystone.numAffixes = #affixes

  for i = 1, _Keystone.numAffixes do
    local affix = _Keystone:GetAffix(i)
    affix.id = affixes[i]

    local name, desc, texture = GetAffixInfo(affix.id)
    affix.name = name
    affix.texture = texture
    affix.desc = desc
  end


  UpdateObjectives()
  --WORLD_MAP_UPDATE()
  SetMapToCurrentZone()
  self:UpdateTimer()
end

function OnDisable(self)
  Debug("Keystone module is disabled")
  if _Keystone then
    _Keystone.isActive = false
  end
end

__EnableAndDisableOnCondition__ "PLAYER_ENTERING_WORLD" "CHALLENGE_MODE_START"
function EnableAndDisableOn(self)
  return GetActiveKeystoneInfo() > 0
end

__Thread__()
__SystemEvent__ "SCENARIO_CRITERIA_UPDATE" "CRITERIA_UPDATE" "SCENARIO_UPDATE"
function UpdateObjectives()
    local dungeonName, _, numObjectives = GetStepInfo()
    local completed = select(7, GetInfo())


    _Keystone.name = dungeonName
    _Keystone.numObjectives = numObjectives
    _Keystone.isCompleted = completed

    for index = 1, numObjectives do
      local description, criteriaType, completed, quantity, totalQuantity,
      flags, assetID, quantityString, criteriaID, duration, elapsed,
      failed, isWeightProgress = GetCriteriaInfo(index)

      local objective = _Keystone:GetObjective(index)
      objective.isCompleted = completed
      objective.text = description

      if isWeightProgress then
        objective:ShowProgress()
        objective:SetMinMaxProgress(0, 100)
        objective:SetProgress(quantity)
        objective:SetTextProgress(string.format("%i%%", quantity))
      else
        objective:HideProgress()
      end
    end

    _Keystone:Draw()
end

__Thread__()
__SystemEvent__()
function CHALLENGE_MODE_START(timerID)
  _Keystone.timer = 0
  Delay(10)

  -- _Keystone.startTime = GetTime() @TODO work on the ms precision
  _M:UpdateTimer()
end

__SystemEvent__()
function WORLD_MAP_UPDATE()
   --SetMapToCurrentZone()
  _Keystone.texture = select(6, EJ_GetInstanceInfo(EJ_GetCurrentInstance()))
end

__Thread__()
function UpdateTimer(self)
    while not _Keystone.isCompleted do
       local _, elapsedTime = GetWorldElapsedTime(1)
      _Keystone.timer = elapsedTime
      Continue()
    end
end
