-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio               "EskaQuestTracker.Achievements"                         ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
GetTrackedAchievements    = GetTrackedAchievements
GetAchievementInfo        = GetAchievementInfo
GetAchievementNumCriteria = GetAchievementNumCriteria
-- ========================================================================== --
function OnLoad(self)
  _Enabled = self:HasAchievement()

  -- Register achievement options
  Options:Register("achievement-max-criteria-displayed", 0, "achievements/updateAll")
  Options:Register("achievement-hide-criteria-completed", false, "achievements/updateAll")
  Options:Register("achievement-show-description", true, "achievements/updateAll")

  -- Callback
  CallbackHandlers:Register("achievements/updateAll", CallbackHandler(function()
    local trackedAchievements = { GetTrackedAchievements() }
    for i = 1, #trackedAchievements do
      local achievementID = trackedAchievements[i]
      _M:UpdateAll()
    end
  end))
end

function OnEnable(self)
  Debug("Achievements module is enabled")
  if not _AchievementBlock then
    _AchievementBlock = AchievementBlock()
    _Addon:RegisterBlock(_AchievementBlock)
    self:LoadAchievements()
  end

  _AchievementBlock.isActive = true
end

function OnDisable(self)
  Debug("Achievements module is disabled")
  if _AchievementBlock then
    _AchievementBlock.isActive = false
  end
end

__EnablingOnCondition__ "TRACKED_ACHIEVEMENT_LIST_CHANGED"
function EnablingOn(self, event, ...)
  return self:HasAchievement()
end

__SystemEvent__()
function TRACKED_ACHIEVEMENT_UPDATE(achievementID)
  if not _AchievementBlock then
    return
  end

  local achievement = _AchievementBlock:GetAchievement(achievementID)
  if achievement then
    _M:UpdateAchievement(achievement)
  end
end

__SystemEvent__()
function PLAYER_ENTERING_WORLD()
  _M:UpdateAll()
end

__SystemEvent__()
function TRACKED_ACHIEVEMENT_LIST_CHANGED(achievementID, isAdded)
  if isAdded and not _AchievementBlock:GetAchievement(achievementID) then
    local achievement = _ObjectManager:Get(Achievement)
    achievement.id =  achievementID
    _M:UpdateAchievement(achievement)
    _AchievementBlock:AddAchievement(achievement)
  elseif not isAdded then
    _AchievementBlock:RemoveAchievement(achievementID)
  end
end

__Thread__()
function LoadAchievements(self)
  local trackedAchievements = { GetTrackedAchievements() }
  for i = 1, #trackedAchievements do
    local achievementID = trackedAchievements[i]
    TRACKED_ACHIEVEMENT_LIST_CHANGED(achievementID, true)
  end
end

function UpdateAll(self)
  if not _AchievementBlock then
    return
  end

  local trackedAchievements = { GetTrackedAchievements() }
  for i = 1, #trackedAchievements do
    local achievementID = trackedAchievements[i]
    local achievement = _AchievementBlock:GetAchievement(achievementID)
    if achievement then
      _M:UpdateAchievement(achievement)
    end
  end
end

function UpdateAchievement(self, achievement)
  local _, achievementName, _, completed, _, _, _, description, _, icon, _, _, wasEarnedByMe = GetAchievementInfo(achievement.id)
  achievement.name = achievementName
  achievement.icon = icon
  achievement.desc = description
  achievement.showDesc = Options:Get("achievement-show-description")
  local numObjectives = GetAchievementNumCriteria(achievement.id)
  if numObjectives > 0 then
    local numShownCriteria = 0
    local maxCriteriaDisplayed = Options:Get("achievement-max-criteria-displayed")
    for index = 1, numObjectives do
      local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, name, flags, assetID, quantityString, criteriaID, eligible, duration, elapsed = GetAchievementCriteriaInfo(achievement.id, index)
      local mustBeShown = true
      if criteriaCompleted and Options:Get("achievement-hide-criteria-completed") then
        break
      end
      if maxCriteriaDisplayed > 0 and numShownCriteria == maxCriteriaDisplayed then
        mustBeShown = false
      end

      if mustBeShown then
        numShownCriteria = numShownCriteria + 1
        achievement.numObjectives = numShownCriteria

        local objective = achievement:GetObjective(numShownCriteria)
        objective.isCompleted = criteriaCompleted
        objective.text = criteriaString
        if ( description and bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR ) then
          objective:ShowProgress()
          objective.text = description
          achievement.showDesc = false
          objective:SetMinMaxProgress(0, totalQuantity)
          objective:SetProgress(quantity)
          objective:SetTextProgress(quantityString)
        end
      end
    end
    if maxCriteriaDisplayed > 0 and numObjectives > maxCriteriaDisplayed then
      achievement:ShowDotted()
    else
      achievement:HideDotted()
    end
  end
end

function HasAchievement(self)
  local achievement = GetTrackedAchievements()
  if achievement ~= nil then
    return true
  else
    return false
  end
end
