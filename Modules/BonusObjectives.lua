-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                 "EskaQuestTracker.BonusObjectives"                     ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
IsWorldQuest  = QuestUtils_IsQuestWorldQuest
IsQuestTask   = IsQuestTask
-- ========================================================================== --


function OnLoad(self)
  -- Check if the player is a bonus quest zone
  self._Enabled = self:HasBonusQuest()
end

function OnEnable(self)
  Debug("Bonus objectives module is enabled")
  if not _BonusObjectives then
    _BonusObjectives = BonusObjectives()
    _Addon:RegisterBlock(_BonusObjectives)
  end

  _BonusObjectives.isActive = true
  self:LoadBonusQuests()
end

function OnDisable(self)
  Debug("Bonus objectives module is disabled")
  if _BonusObjectives then
    _BonusObjectives.isActive = false
  end

end

__EnableOnCondition__ "QUEST_ACCEPTED" "PLAYER_ENTERING_WORLD"
function EnableOn(self, event, ...)
  if event == "QUEST_ACCEPTED" then
    local _, questID = ...
    return  IsQuestTask(questID) and not IsWorldQuest(questID)
  end
  return false
end

__DisableOnCondition__ "EQT_BONUSQUEST_REMOVED" "PLAYER_ENTERING_WORLD"
function DisableOn(self, event, ...)
  if event == "EQT_BONUSQUEST_REMOVED" then
    if _BonusObjectives then
      return _BonusObjectives.bonusQuests.Count == 0
    end
  elseif event == "PLAYER_ENTERING_WORLD" then
    return not self:HasBonusQuest()
  end
  return true
end

__SystemEvent__()
function QUEST_ACCEPTED(_, questID)
  if not IsQuestTask(questID) or IsWorldQuest(questID) or _BonusObjectives:GetBonusQuest(questID) then
    return
  end

  local bonusQuest = _ObjectManager:Get(BonusQuest)
  bonusQuest.id = questID

  _M:UpdateBonusQuest(bonusQuest)

  _BonusObjectives:AddBonusQuest(bonusQuest)
end

__SystemEvent__()
function QUEST_REMOVED(questID)
  _BonusObjectives:RemoveBonusQuest(questID)
  _M:FireSystemEvent("EQT_BONUSQUEST_REMOVED")
end

__Thread__()
function LoadBonusQuests(self)
  local numEntries, numQuests = GetNumQuestLogEntries()
  for i = 1, numEntries do
    local title, level, suggestedGroup, isHeader, isCollapsed, isComplete,
    frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI,
    isTask, isBounty, isStory, isHidden = GetQuestLogTitle(i)

    if not isHidden and isTask and not IsWorldQuest(questID) and not _BonusObjectives:GetBonusQuest(questID) then
      local bonusQuest = _ObjectManager:Get(BonusQuest)
      bonusQuest.id = questID
      bonusQuest.name = title

      self:UpdateBonusQuest(bonusQuest)

      _BonusObjectives:AddBonusQuest(bonusQuest)
    end
  end
end

-- 37779
function UpdateBonusQuest(self, bonusQuest)
  local isInArea, isOnMap, numObjectives, taskName, displayAsObjective = GetTaskInfo(bonusQuest.id)
  bonusQuest.isOnMap = true
  bonusQuest.name = taskName

  if numObjectives then
    bonusQuest.numObjectives = numObjectives
    for index = 1, numObjectives do
      local text, type, finished = GetQuestObjectiveInfo(bonusQuest.id, index, false)
      local objective = bonusQuest:GetObjective(index)

      objective.isCompleted = finished
      objective.text = text

      if type == "progressbar" then
        local progress = GetQuestProgressBarPercent(bonusQuest.id)
        objective:ShowProgress()
        objective:SetMinMaxProgress(0, 100)
        objective:SetProgress(progress)
        objective:SetTextProgress(string.format("%i%%", progress))
      else
        objective:HideProgress()
      end

    end

  end

end

__SystemEvent__()
function QUEST_LOG_UPDATE()
    for _, bonusQuest in _BonusObjectives.bonusQuests:GetIterator() do
      _M:UpdateBonusQuest(bonusQuest)
    end
end


function HasBonusQuest(self)
  for i = 1, GetNumQuestLogEntries() do
    local id = select(8, GetQuestLogTitle(i))
    if IsQuestTask(id) and not IsWorldQuest(id) then
      return true
    end
  end
  return false
end
