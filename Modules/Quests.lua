-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                "EskaQuestTracker.Quests"                              ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
GetNumQuestLogEntries      = GetNumQuestLogEntries
GetQuestLogTitle           = GetQuestLogTitle
GetNumQuestLogEntries      = GetNumQuestLogEntries
GetQuestLogTitle           = GetQuestLogTitle
GetQuestLogIndexByID       = GetQuestLogIndexByID
GetQuestWatchIndex         = GetQuestWatchIndex
GetQuestLogSpecialItemInfo = GetQuestLogSpecialItemInfo
GetQuestObjectiveInfo      = GetQuestObjectiveInfo
GetDistanceSqToQuest       = GetDistanceSqToQuest
AddQuestWatch              = AddQuestWatch
SelectQuestLogEntry        = SelectQuestLogEntry
IsWorldQuest               = QuestUtils_IsQuestWorldQuest
IsQuestBounty              = IsQuestBounty
-- ====================== [[ DATA ]]========================================= --
QUEST_HEADERS_CACHE = {}
QUESTS_CACHE  = {}
-- ========================================================================== --
function OnLoad(self)
  _DB:SetDefault("Quests", {
    filteringByZone = false,
  })
  -- Register the options
  Options:Register("sort-quests-by-distance", true, "quests/sortingByDistance")
  -- Register the callbacks for options
  CallbackHandlers:Register("quests/sortingByDistance", CallbackHandler(function(enabled) if enabled then self:UpdateDistance() end end))
end

__Thread__()
function OnEnable(self)
  if not _QuestBlock then
    _QuestBlock = QuestBlock()
    _Addon:RegisterBlock(_QuestBlock)
    Wait("QUEST_LOG_UPDATE") -- QUEST_LOG_UPDATE
  end
  Debug("Quests module is enabled")

  self:LoadQuests()
  self:UpdateDistance()
  EQT_SHOW_ONLY_QUESTS_IN_ZONE()
  UPDATE_BLOCK_VISIBILITY()

  -- [FIX] Super track the closest quest for the players having not the blizzad objective quest.
  if GetSuperTrackedQuestID() == 0 then
    QuestSuperTracking_ChooseClosestQuest()
  end
end

function OnDisable(self)
  if _QuestBlock then
    _QuestBlock.isActive = false
  end
end

__SystemEvent__  "EQT_QUESTBLOCK_QUEST_ADDED" "EQT_QUESTBLOCK_QUEST_REMOVED"
function UPDATE_BLOCK_VISIBILITY(quest)
  if _QuestBlock then
    _QuestBlock.isActive = _QuestBlock.quests.Count > 0
  end
end


__Thread__()
__SystemEvent__()
function QUEST_ACCEPTED(index, questID)
  -- Don't continue if the quest is a world quest or a emissary
  if IsWorldQuest(questID) or IsQuestBounty(questID) then return end

  -- @Hack : Set a little delay to get a valid quest item
  Delay(0.1)

  -- Add it in the quest watched
  AddQuestWatch(index)
end

__SystemEvent__ "QUEST_LOG_UPDATE" "ZONE_CHANGED" "EQT_SHOW_ONLY_QUESTS_IN_ZONE"
function QUESTS_UPDATE(...)
  for questID in pairs(QUESTS_CACHE) do
    _M:UpdateQuest(questID)
  end
end

__SystemEvent__()
function QUEST_LOG_UPDATE()
  for questID in pairs(QUESTS_CACHE) do
    _M:UpdateQuest(questID)
  end
end


do
  local alreadyHooked = false
  local needUpdate = false

  function RunQuestLogUpdate()
    if QuestBlock.showOnlyQuestsInZone then
      QUEST_LOG_UPDATE()
      needUpdate = false
    end
  end

  __SystemEvent__()
  function ZONE_CHANGED()
    -- @NOTE This seems that GetQuestWorldMapAreaID() uses SetMapToCurrentZone so we
    -- need to wait the WorldMapFrame is hidden to continue
    if QuestBlock.showOnlyQuestsInZone then
      if WorldMapFrame:IsShown() then
        needUpdate = true
      else
        QUEST_LOG_UPDATE()
      end
    end
  end

  __SystemEvent__()
  function EQT_SHOW_ONLY_QUESTS_IN_ZONE()
    if QuestBlock.showOnlyQuestsInZone then
      if not alreadyHooked then
        WorldMapFrame:HookScript("OnHide", RunQuestLogUpdate)
        alreadyHooked = true
      end

      if WorldMapFrame:IsShown() then
        needUpdate = true
        return
      end
    end

    QUEST_LOG_UPDATE()
  end
end


__SystemEvent__()
function QUEST_WATCH_LIST_CHANGED(questID, isAdded)
  if not questID then
    return
  end

  -- @NOTE: World Quest Group Finder addon adds the world quests as watched when you joins.
  -- Don't continue if the quest is a world quest or a emissary
  if IsWorldQuest(questID) or IsQuestBounty(questID) then return end

  if isAdded then
    QUESTS_CACHE[questID] = false
    _M:UpdateQuest(questID)

  else
    QUESTS_CACHE[questID] = nil
    _QuestBlock:RemoveQuest(questID)
    _Addon.ItemBar:RemoveItem(questID)
  end
end



function GetQuestHeader(self, qID)
    -- Check if the quest header is in the cache
    if QUEST_HEADERS_CACHE[qID] then
      return QUEST_HEADERS_CACHE[qID]
    end

    -- if no, fin the quest header
    local currentHeader = "Misc"
    local numEntries, numQuests = GetNumQuestLogEntries()

    for i = 1, numEntries do
      local title, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(i)
      if isHeader then
        currentHeader = title
      elseif questID == qID then
        QUEST_HEADERS_CACHE[qID] = currentHeader
        return currentHeader
      end
    end
    return currentHeader
end

function LoadQuests(self)
  local numEntries, numQuests = GetNumQuestLogEntries()
  local currentHeader = "Misc"

  for i = 1, numEntries do
    local title, level, suggestedGroup, isHeader, isCollapsed, isComplete,
    frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI,
    isTask, isBounty, isStory, isHidden = GetQuestLogTitle(i)

    if not isTask and not _QuestBlock:GetQuest(questID) then
      if isHeader then
        currentHeader = title
      elseif not isHeader and not isHidden and IsQuestWatched(i) then
        QUESTS_CACHE[questID] = false
        self:UpdateQuest(questID)
      end
    end
  end
end

function UpdateQuest(self, questID)
    local questLogIndex = GetQuestLogIndexByID(questID)
    local questWatchIndex = GetQuestWatchIndex(questLogIndex)

    if not questWatchIndex then
      Trace("questWatchIndex is nil")
      return
    end

    local qID, title, questLogIndex, numObjectives, requiredMoney,
    isComplete, startEvent, isAutoComplete, failureTime, timeElapsed,
    questType, isTask, isBounty, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(questWatchIndex)


    -- #######################################################################
    -- Is the player wants the quests are filered by zone ?
    if QuestBlock.showOnlyQuestsInZone then

      -- @NOTE This seems that GetQuestWorldMapAreaID() uses SetMapToCurrentZone so we
      -- need to wait the WorldMapFrame is hidden to continue
      if WorldMapFrame:IsShown() then
        return
      end

      local mapID = GetQuestWorldMapAreaID(questID)
      local currentMapID = GetCurrentMapAreaID()
      local isLocal = (((mapID ~= 0) and mapID == currentMapID) or (mapID == 0 and isOnMap))

      if not isLocal then
        _QuestBlock:RemoveQuest(questID)
        return
      end
    end
    -- #######################################################################

    local quest = _QuestBlock:GetQuest(questID)
    local isNew = false
    if not quest then
      quest = _ObjectManager:GetQuest()
      isNew = true
    end

    quest.id = questID
    quest.name = title
    quest.header = _M:GetQuestHeader(questID)
    quest.level = select(2, GetQuestLogTitle(questLogIndex))
    quest.isOnMap = isOnMap
    quest.isTask = isTask
    quest.isBounty = isBounty

    -- is the quest has an item quest ?
    local itemLink, itemTexture = GetQuestLogSpecialItemInfo(questLogIndex)
    if itemLink and itemTexture then
      local itemQuest = quest:GetQuestItem()
      itemQuest.link = itemLink
      itemQuest.texture = itemTexture
      _Addon.ItemBar:AddItem(questID, itemLink, itemTexture)
    end

    -- Update the objective
    if numObjectives > 0 then
      quest.numObjectives = numObjectives
      for index = 1, numObjectives do
        local text, type, finished = GetQuestObjectiveInfo(quest.id, index, false)
        local objective = quest:GetObjective(index)

        objective.isCompleted = finished
        objective.text = text

        if type == "progressbar" then
          local progress = GetQuestProgressBarPercent(quest.id)
          objective:ShowProgress()
          objective:SetMinMaxProgress(0, 100)
          objective:SetProgress(progress)
          objective:SetTextProgress(PERCENTAGE_STRING:format(progress))
        else
          objective:HideProgress()
        end
      end
    else
      quest.numObjectives = 1
      local objective = quest:GetObjective(1)
      SelectQuestLogEntry(questLogIndex)

      objective.text = GetQuestLogCompletionText()
      objective.isCompleted = false
    end

    if isNew then
      _QuestBlock:AddQuest(quest)
    end
end

do
  local function IsLegionAssaultQuest(questID)
    return (questID == 45812) -- Assault on Val'sharah
        or (questID == 45838) -- Assault on Azsuna
        or (questID == 45840) -- Assault on Highmountain
        or (questID == 45839) -- Assault on StormHeim
        or (questID == 45406) -- StomHeim : The Storm's Fury
        or (questID == 46110) -- StomHeim : Battle for Stormheim
  end


  __Thread__()
  function UpdateDistance()
    while Options:Get("sort-quests-by-distance") do
      for index, quest in _QuestBlock.quests:GetIterator() do
        -- If the quest is a legion assault, set it in first.
        if IsLegionAssaultQuest(quest.id) then
            quest.distance = 0
        else
            local questLogIndex = GetQuestLogIndexByID(quest.id)
            local distanceSq, onContinent = GetDistanceSqToQuest(questLogIndex)

            quest.distance = distanceSq and math.sqrt(distanceSq) or nil
        end
      end
      Delay(1) -- @TODO Create an option to change the refresh rate.
    end
  end

end

-- ========================================================================== --
-- == Quest Popup
-- ========================================================================== --
-- @TODO : Maybe move this class in an another file ?
class "QuestPopup" extend "IFrame"

  local function UpdateType(self, new)
    if new == "OFFER" then
      self.frame.topName:SetText(QUEST_WATCH_POPUP_QUEST_DISCOVERED:upper())
      self.frame.topName:SetTextColor(1, 106 / 255, 0)
      self.frame.icon:SetTexCoord(0.13476563, 0.17187500, 0.01562500, 0.53125000)

      self.frame.subName:SetText(QUEST_WATCH_POPUP_CLICK_TO_VIEW)
    elseif new == "COMPLETE" then
      self.frame.topName:SetText("QUEST COMPLETE")
      self.frame.topName:SetTextColor(0, 220/255, 0)
      self.frame.icon:SetTexCoord(0.17578125, 0.21289063, 0.01562500, 0.53125000)

      self.frame.subName:SetText(QUEST_WATCH_POPUP_CLICK_TO_COMPLETE)
    end
  end

  local function UpdateName(self, new)
    self.frame.name:SetText(new)
  end

  property "name" { TYPE = String, DEFAULT = "", HANDLER = UpdateName }
  property "type" { TYPE = String, DEFAULT = "", HANDLER = UpdateType }

  function QuestPopup(self)
    local frame = CreateFrame("Frame")
    frame:SetHeight(32)
    frame:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
    --frame:SetBackdropColor(1.0, 216/255, 0, 0.5)
    frame:SetBackdropColor(127/255, 0, 0, 0.5)
    frame:SetBackdropBorderColor(0, 0, 0)

    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetSize(19 * 0.85, 33 * 0.85)
    icon:SetPoint("TOPLEFT", 10, -2)
    icon:SetTexture([[Interface\QuestFrame\AutoQuest-Parts]])
    icon:SetTexCoord(0.13476563, 0.17187500, 0.01562500, 0.53125000)
    frame.icon = icon

    local stripe = frame:CreateTexture(nil, "ARTWORK")
    stripe:SetPoint("CENTER", icon, "CENTER")
    stripe:SetSize(32 * 0.85, 32 * 0.85)
    stripe:SetTexture([[Interface\AddOns\EskaQuestTracker\Media\Textures\Stripe]])
    stripe:SetVertexColor(0.25, 0.25, 0.25)
    icon.stripe = stripe

    local bgStripe = frame:CreateTexture(nil, "BORDER")
    bgStripe:SetAllPoints(stripe)
    bgStripe:SetColorTexture(0, 0, 0)
    icon.bg = bgStripe

    local name = frame:CreateFontString(nil, "OVERLAY")
    local fontName = _LibSharedMedia:Fetch("font", "PT Sans Bold")
    local fontSub = _LibSharedMedia:Fetch("font", "PT Sans Narrow Bold")

    name:SetPoint("LEFT", stripe, "RIGHT")
    name:SetPoint("RIGHT")
    name:SetJustifyH("CENTER")
    name:SetFont(fontName, 10)
    name:SetText("")
    --name:SetTextColor(1, 106 / 255, 0)
    name:SetTextColor(1, 216/255, 0)
    frame.name = name

    local topName = frame:CreateFontString(nil, "OVERLAY")
    topName:SetPoint("TOPLEFT", stripe, "TOPRIGHT")
    topName:SetPoint("BOTTOM", name, "TOP")
    topName:SetPoint("RIGHT")
    topName:SetJustifyH("CENTER")
    topName:SetFont(fontSub, 8)
    topName:SetText("QUEST DISCOVERED")
    topName:SetTextColor(0, 220/255, 0)
    --topName:SetTextColor(1, 106 / 255, 0)
    frame.topName = topName


    local subName = frame:CreateFontString(nil, "OVERLAY")
    subName:SetPoint("BOTTOMLEFT", stripe, "BOTTOMRIGHT")
    subName:SetPoint("RIGHT")
    subName:SetPoint("TOP", name, "BOTTOM")
    subName:SetJustifyH("CENTER")
    subName:SetFont(fontSub, 7)
    subName:SetText("Click to complete the quest")
    frame.subName = subName

    frame:SetScript("OnEnter", function(self)
      self:SetBackdropColor(180/255, 0, 0, 0.75)
    end)

    frame:SetScript("OnLeave", function(self)
      self:SetBackdropColor(127/255, 0, 0, 0.5)
    end)

    self.frame = frame

  end
endclass "QuestPopup"



function ShowPopup(self, questID, popupType)
  if not _M.popup then
    _M.popup = QuestPopup()
    _M.popup.frame:SetPoint("BOTTOMLEFT", _Addon.ObjectiveTracker.frame, "TOPLEFT")
    _M.popup.frame:SetPoint("BOTTOMRIGHT", _Addon.ObjectiveTracker.frame, "TOPRIGHT")
  else
    _M.popup:Show()
  end

  _M.popup.type = popupType
  _M.popup.name = GetQuestLogTitle(GetQuestLogIndexByID(questID))

  if popupType == "OFFER" then
    _M.popup.frame:SetScript("OnMouseDown", function()
      ShowQuestOffer(GetQuestLogIndexByID(questID))
      RemoveAutoQuestPopUp(questID)
      _M.popup:Hide()
    end)
  else
    _M.popup.frame:SetScript("OnMouseDown", function()
      ShowQuestComplete(GetQuestLogIndexByID(questID))
      RemoveAutoQuestPopUp(questID)
      _M.popup:Hide()
    end)
  end

end

function RefreshPopup(self)
  for i = 1, GetNumAutoQuestPopUps() do
		local questID, popUpType = GetAutoQuestPopUp(i)
    if ( not IsQuestBounty(questID) ) then
      self:ShowPopup(questID, popUpType)
    end
  end
end


__SecureHook__()
function AutoQuestPopupTracker_AddPopUp(questID, popupType)
  Wait(function() _M:ShowPopup(questID, popupType) end, "QUEST_WATCH_LIST_CHANGED", "QUEST_LOG_UPDATE")
end

__SecureHook__()
function AutoQuestPopupTracker_RemovePopUp(questID, popupType)
  if _M.popup then
    _M.popup:Hide()
  end
end

__SystemEvent__()
function QUEST_AUTOCOMPLETE(...)
  local questID = ...
  _M:ShowPopup(questID, "COMPLETE")
end

-- ========================================================================== --
-- == Debug part
-- ========================================================================== --
do
  local questCount = 1
  local quests = {}

  __SlashCmd__ "debugque" "init"
  function DebugAddQuest()
    local quest = _ObjectManager:GetQuest()
    quest.id = -1000 + questCount
    quest.name = "Quest debug title"
    quest.level = 10
    quest.header = "DEBUG"

    _QuestBlock:AddQuest(quest)

    quests[questCount] = quest
    questCount = questCount + 1
  end

  __SlashCmd__ "debugque" "rem"
  function DebugRemoveQuest()
    local quest = quests[questCount - 1]
    _QuestBlock:RemoveQuest(quest)

    questCount[questCount] = nil
    questCount = questCount - 1
  end

  local debugObjectivesText = {
      [1] = "Kill all demons",
      [2] = "Rescue your friends",
      [3] = "Find a myterious object",
      [4] = "Go to the next waypoint",
  }

  __SlashCmd__ "debugque" "addobj"
  function DebugAddObjective(self)
    local quest = quests[questCount - 1]
    quest.numObjectives =  quest.numObjectives + 1

    local completed = math.random(1, 2) == 1 and true or false
    local text = debugObjectivesText[quest.numObjectives]

    local objective =  quest:GetObjective(quest.numObjectives)

    objective.isCompleted = completed
    objective.text = text
  end

  __SlashCmd__ "debugque" "remobj"
  function DebugRemoveObjective(self)
    local quest = quests[questCount - 1]
    quest.numObjectives = quest.numObjectives - 1
  end

  __SlashCmd__ "debugque" "objprogress"
  function DebugAddObjectiveProgress(self)
    local quest = quests[1]
    local obj = quest:GetObjective(1)
    obj:ShowProgress()
    obj:SetMinMaxProgress(0, 100)
    obj:SetProgress(50)
    obj:SetTextProgress(PERCENTAGE_STRING:format(50))
  end

end
