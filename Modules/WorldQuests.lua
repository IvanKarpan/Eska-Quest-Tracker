-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                 "EskaQuestTracker.WorldQuests"                        ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
IsWorldQuest       = QuestUtils_IsQuestWorldQuest
GetTaskInfo        = GetTaskInfo
IsInInstance       = IsInInstance
-- ======================[[ DATA ]]========================================== --
-- The blacklist is used to hide the weekly world quest (e.g: 2v2, 3v3, rbg quest)
WORLD_QUESTS_BLACKLIST = {
  [44891] = true, -- 2v2 Weekly quest
  [44908] = true, -- 3v3 Weekly quest
  [44909] = true, -- RBG Weekly quest
}

function OnLoad(self)
  -- Check if the player is in a world quest zone
  self._Enabled = self:HasWorldQuest()
end

function OnEnable(self)
  Debug("World quests module is enabled")
  if not _WorldQuestBlock then
    _WorldQuestBlock = WorldQuestBlock()
    _Addon:RegisterBlock(_WorldQuestBlock)
  end

  _WorldQuestBlock.isActive = true
  self:LoadWorldQuests()
end

function OnDisable(self)
  Debug("World quests module is disabled")
  if _WorldQuestBlock then
    _WorldQuestBlock.isActive = false
  end
end

__EnableOnCondition__ "QUEST_ACCEPTED" "PLAYER_ENTERING_WORLD"
function EnableOn(self, event, ...)
  if event == "QUEST_ACCEPTED" then
    local _, questID = ...
    return IsWorldQuest(questID) and not WORLD_QUESTS_BLACKLIST[questID]
  elseif event == "PLAYER_ENTERING_WORLD" then
    local inInstance, type = IsInInstance()
    -- TODO check if the inInstance does the job
    if inInstance and type == "party" then
      return self:HasWorldQuest()
    end
  end
  return false
end

__DisableOnCondition__ "EQT_WORLDQUEST_REMOVED" "PLAYER_ENTERING_WORLD"
function DisableOn(self, event, ...)
  if event == "EQT_WORLDQUEST_REMOVED" then
    -- WorldQuestBlock.worldquests.Count
    if _WorldQuestBlock then
      return _WorldQuestBlock.worldQuests.Count == 0
    end
  elseif event == "PLAYER_ENTERING_WORLD" then
    return not self:HasWorldQuest()
  end
  return true
end

__SystemEvent__()
function QUEST_ACCEPTED(self, questID)
  -- Fix World Quest Group Finder
  if IsWorldQuest(questID) then
    ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_WORLD_QUEST_ADDED, questID)
  end
  --

  -- if the quest isn't world quest or is blacklisted, stop there.
  if not IsWorldQuest(questID) or WORLD_QUESTS_BLACKLIST[questID] or _WorldQuestBlock:GetWorldQuest(questID) then
    return
  end

  local worldQuest = _ObjectManager:Get(WorldQuest)
  worldQuest.id = questID

  _M:UpdateWorldQuest(worldQuest)

  _WorldQuestBlock:AddWorldQuest(worldQuest)
end

__SystemEvent__()
function QUEST_REMOVED(questID)
  -- if the quest isn't a world quest, don't continue
  if not IsWorldQuest then
    return
  end

  _WorldQuestBlock:RemoveWorldQuest(questID)
  _Addon.ItemBar:RemoveItem(questID)
  _M:FireSystemEvent("EQT_WORLDQUEST_REMOVED")
end

__Thread__()
function LoadWorldQuests(self)
  local numEntries, numQuests = GetNumQuestLogEntries()
  for i = 1, numEntries do
    local title, level, suggestedGroup, isHeader, isCollapsed, isComplete,
    frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI,
    isTask, isBounty, isStory, isHidden = GetQuestLogTitle(i)

    if isHidden then
      WORLD_QUESTS_BLACKLIST[questID] = true
    end

    if not isHidden and isTask and IsWorldQuest(questID) and not _WorldQuestBlock:GetWorldQuest(questID) then
      local worldQuest = _ObjectManager:Get(WorldQuest)
      worldQuest.id = questID
      worldQuest.name = title

      self:UpdateWorldQuest(worldQuest)

      _WorldQuestBlock:AddWorldQuest(worldQuest)
    end
  end
end


function UpdateWorldQuest(self, worldQuest)
  local isInArea, isOnMap, numObjectives, taskName, displayAsObjective = GetTaskInfo(worldQuest.id)
  worldQuest.isOnMap = true
  worldQuest.name = taskName

  local itemLink, itemTexture = GetQuestLogSpecialItemInfo(GetQuestLogIndexByID(worldQuest.id))
  if itemLink and itemTexture then
    local itemQuest  = worldQuest:GetQuestItem()
    itemQuest.link = itemLink
    itemQuest.texture = itemTexture
    _Addon.ItemBar:AddItem(worldQuest.id, itemLink, itemTexture)
  end

  if numObjectives then
    worldQuest.numObjectives = numObjectives
    for index = 1, numObjectives do
      local text, type, finished = GetQuestObjectiveInfo(worldQuest.id, index, false)
      local objective = worldQuest:GetObjective(index)

      objective.isCompleted = finished
      objective.text = text

      if type == "progressbar" then
        local progress = GetQuestProgressBarPercent(worldQuest.id)
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
  for _, worldQuest in _WorldQuestBlock.worldQuests:GetIterator() do
    _M:UpdateWorldQuest(worldQuest)
  end
end



function HasWorldQuest(self)
  for i = 1, GetNumQuestLogEntries() do

    if IsWorldQuest(select(8, GetQuestLogTitle(i))) then
      return true
    end
  end
  return false
end
