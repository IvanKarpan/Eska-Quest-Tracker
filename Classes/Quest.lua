--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio                "EskaQuestTracker.Classes.Quest"                       ""
--============================================================================--
namespace "EQT"
--============================================================================--
class "Quest" inherit "Frame" extend "IReusable" "IObjectiveHolder"
  _QuestCache = setmetatable( {}, { __mode = "v" } )
  event "OnDistanceChanged"
  event "IsOnMapChanged"
  event "IsCompletedChanged"
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function UpdateProps(self, new, old, prop)
    if prop == "name" then
      Theme:NewSkinText(self.frame.headerName, Theme.SkinTextFlags.TEXT_TRANSFORM, new)
    elseif prop == "level" then
      Theme:NewSkinText(self.frame.headerLevel, Theme.SkinTextFlags.TEXT_TRANSFORM, new > 0 and new or "")
      if Options:Get("quest-color-level-by-difficulty") then
        local color = GetQuestDifficultyColor(new)
        self.frame.headerLevel:SetTextColor(color.r, color.g, color.b)
      end
    elseif prop == "distance" then
      self.OnDistanceChanged(self, new)
    elseif prop == "isTracked" then
      if new then
        Theme:NewSkinFrame(self.frame, "tracked")
      else
        Theme:NewSkinFrame(self.frame)
      end
    end
  end
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  __Arguments__{}
  function GetQuestItem(self)
    if not self.questItem then
      self.questItem = _ObjectManager:GetQuestItem()
      self.questItem:SetParent(self.frame)
    end

    return self.questItem
  end

  function Draw(self)
    if not self:IsShown() then
      self:Show()
    end

    if self.questItem and not self.questItem:IsShown() then
      self.questItem:Show()
    end

    local previousFrame
    for index, obj in self.objectives:GetIterator() do
      obj:Show()
      obj:ClearAllPoints()
      if index == 1 then
        obj:SetPoint("TOP", 0, -21)
        if self.questItem then
          self.questItem.frame:SetPoint("TOPLEFT", self.frame.header, "BOTTOMLEFT", 5, -2)
          obj:SetPoint("LEFT", self.questItem.frame, "RIGHT")
        else
          obj:SetPoint("LEFT")
        end

        obj:SetPoint("RIGHT")
      else
        obj:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT")
        obj:SetPoint("RIGHT")
      end
      obj:CalculateHeight()
      previousFrame = obj.frame
    end
    self:CalculateHeight()
  end

  function CalculateHeight(self)
    local height = self.baseHeight

    local objectivesHeight = self:GetObjectivesHeight()

    if self.questItem then
      local itemHeight = self.questItem.height
      if objectivesHeight > itemHeight + 2 then
        height = height + objectivesHeight
      else
        height = height + itemHeight + 2
      end
    else
      height = height + objectivesHeight
    end

    -- offset
    height = height + 2


    self.height = height
  end

  function ShowLevel(self)
    self.frame.headerLevel:Show()
    self.frame.headerName:SetPoint("RIGHT", self.frame.headerLevel, "LEFT")
  end

  function HideLevel(self)
    self.frame.headerLevel:Hide()
    self.frame.headerName:SetPoint("RIGHT")
  end


  __Arguments__ { Argument(Theme.SkinInfo, true, Theme.SkinInfo()), Argument(Boolean, true, true) }
  function SkinFeatures(self, info, alreadyInit)
    -- In orter to avoid useless function calls, this is important to call not the super
    -- when the object has not finished its intialization.
    -- So put always this check in Refresh, SkinFeature, ExtraSkinFeatures Methods.
    if alreadyInit then
      Super.SkinFeatures(self, skinInfo)
    end

    local state = nil
    if self.isTracked then state = "tracked" end

    Theme:NewSkinFrame(self.frame, info)
    Theme:NewSkinFrame(self.frame.header, info)
    Theme:NewSkinText(self.frame.headerName, info, self.name, state)

    if Options:Get("quest-show-level") then
      self:ShowLevel()
      --Theme:SkinText(self.frame.headerLevel, self.level > 0 and self.level or "", state, skinFlags)
      Theme:NewSkinText(self.frame.headerLevel, info, self.level > 0 and self.level or "", state)

      if Options:Get("quest-color-level-by-difficulty") then
        local color = GetQuestDifficultyColor(self.level)
        self.frame.headerLevel:SetTextColor(color.r, color.g, color.b)
      end
    else
      self:HideLevel()
    end
  end

  __Arguments__ { Argument(Theme.SkinInfo, true, Theme.SkinInfo()), Argument(Boolean, true, true) }
  function ExtraSkinFeatures(self, info, alreadyInit)
    -- In orter to avoid useless function calls, this is important to call not the super
    -- when the object has not finished its intialization.
    -- So put always this check in Refresh, SkinFeature, ExtraSkinFeatures Methods.
    if alreadyInit then
      Super.SkinFeatures(self, skinInfo)
    end

    local theme = Themes:GetSelected()
    if not theme then return end

    if System.Reflector.ValidateFlags(info.textFlags, Theme.SkinTextFlags.TEXT_LOCATION) then
      local headerName = self.frame.headerName
      local elementID = headerName.elementID
      local inheritElementID = headerName.inheritElementID
      if elementID then
        local location = theme:GetElementProperty(elementID, "text-location", inheritElementID)
        local offsetX = theme:GetElementProperty(elementID, "text-offsetX", inheritElementID)
        local offsetY = theme:GetElementProperty(elementID, "text-offsetY", inheritElementID)
        headerName:SetPoint("TOPLEFT", offsetX, offsetY)

        headerName:SetJustifyV(_JUSTIFY_V_FROM_ANCHOR[location])
        headerName:SetJustifyH(_JUSTIFY_H_FROM_ANCHOR[location])
      end
    end
  end


  function Reset(self)
    --for _, objective in self.objectives:GetIterator() do
      --objective.isReusable = true
    --end

    self:ClearAllPoints()
    self:SetParent(nil)
    self:Hide()

    -- Reset properties
    self.numObjectives = nil
    self.id = nil
    self.name = nil
    self.level = nil
    self.header = nil
    self.distance = nil
    self.isBounty = nil
    self.isTask = nil
    self.isHidden = nil
    self.isOnMap = nil
    self.isTracked = nil
    self.isInArea = nil


    if self.questItem then
      self.questItem.isReusable = true
      self.questItem = nil
    end

    self.IsCompletedChanged = nil

    -- Reset variables
    --self.objectives =  ObjectArray(Objective)
    --self:ClearObjectives()

  end

  __Arguments__ { Argument(Theme.SkinInfo, true, Theme.SKIN_INFO_ALL_FLAGS) }
  __Static__() function RefreshAll(skinInfo)
    for obj in pairs(_QuestCache) do
      obj:Refresh(skinInfo)
    end
  end

  function RegisterFramesForThemeAPI(self)
    local class = System.Reflector.GetObjectClass(self)

    Theme:RegisterFrame(class._prefix..".frame", self.frame, "quest.frame")
    Theme:RegisterFrame(class._prefix..".header", self.frame.header, "quest.header")

    Theme:RegisterText(class._prefix..".name", self.frame.headerName, "quest.name")
    Theme:RegisterText(class._prefix..".level", self.frame.headerLevel, "quest.level")
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "id" { TYPE= Number, DEFAULT = -1 }
  property "name" { TYPE = String, HANDLER = UpdateProps, DEFAULT = ""}
  property "level" { TYPE = Number, DEFAULT = 0, HANDLER = UpdateProps }
  property "header" { TYPE = String, DEFAULT = "Misc"}
  property "distance" { TYPE = Number, DEFAULT = -1, HANDLER = UpdateProps }
  property "isBounty" { TYPE = Boolean, DEFAULT = false }
  property "isTask" { TYPE = Boolean, DEFAULT = false }
  property "isHidden" { TYPE = Boolean, DEFAULT = false }
  property "isOnMap" { TYPE = Boolean, DEFAULT = false, EVENT = "IsOnMapChanged" }
  property "isInArea" { TYPE = Boolean, DEFAULT = false }
  property "isTracked" { TYPE = Boolean, DEFAULT = false, HANDLER = UpdateProps }
  property "isCompleted" { TYPE = Boolean, DEFAULT = false, EVENT = "IsCompletedChanged"}

  __Static__() property "_prefix" { DEFAULT = "quest" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Quest(self)
    Super(self)

    local frame = CreateFrame("Frame")
    frame:SetBackdrop(_Backdrops.Common)
    frame:SetBackdropBorderColor(0,0,0,0)




    local headerFrame = CreateFrame("Button", nil, frame)
    headerFrame:SetBackdrop(_Backdrops.Common)
    headerFrame:SetBackdropBorderColor(0,0,0,0)
    headerFrame:SetPoint("TOPRIGHT")
    headerFrame:SetPoint("TOPLEFT")
    headerFrame:SetHeight(21) -- 14
    headerFrame:RegisterForClicks("RightButtonUp", "LeftButtonUp")

    -- Script
    headerFrame:SetScript("OnClick", function(_, button, down)
      if not Frame:MustBeInteractive(headerFrame) then
        return
      end

      if button == "LeftButton" then
        if ChatEdit_TryInsertQuestLinkForQuestID(self.id) then
          return
        end
        local behavior = Options:Get("quest-left-click-behavior")
        if behavior or behavior ~= "none" then
            if behavior == "create-a-group" then
              GroupFinder:CreateGroup(self.id)
            elseif behavior == "join-a-group" then
              GroupFinder:JoinGroup(self.id)
            elseif behavior == "show-details" then
              local questLogIndex = GetQuestLogIndexByID(self.id);
              if ( IsQuestComplete(self.id) and GetQuestLogIsAutoComplete(questLogIndex) ) then
                ShowQuestComplete(questLogIndex);
              else
                QuestLogPopupDetailFrame_Show(questLogIndex)
              end
            elseif behavior == "show-details-with-map" then
              ShowQuestLog()
              QuestMapFrame_ShowQuestDetails(self.id)
            elseif behavior == "toggle-tracking" then
              if not QuestUtils_IsQuestWorldQuest(self.id) then
                if GetSuperTrackedQuestID() == self.id then
                  SetSuperTrackedQuestID(0)
                  QuestSuperTracking_ChooseClosestQuest()
                else
                  SetSuperTrackedQuestID(self.id)
                end
              end
            end
        end
      elseif button == "RightButton" then
        if _Addon.MenuContext:IsShown() then
          _Addon.MenuContext:Hide()
        else
          _Addon.MenuContext:Show()
          _Addon.MenuContext:ClearAnchorFrames():AnchorTo(headerFrame):UpdateAnchorPoint()
          _Addon.MenuContext:Clear()
          _Addon.MenuContext:AddItem("Create a group", nil, function() GroupFinder:CreateGroup(self.id) end)
          _Addon.MenuContext:AddItem("Join a group", nil, function() GroupFinder:JoinGroup(self.id) end)
          _Addon.MenuContext:AddItem(MenuItemSeparator())
          _Addon.MenuContext:AddItem("Leave the group", nil, GroupFinder.LeaveGroup)
          _Addon.MenuContext:AddItem(MenuItemSeparator())
          if not QuestUtils_IsQuestWorldQuest(self.id) then
            if GetSuperTrackedQuestID() == self.id then
              _Addon.MenuContext:AddItem("Stop tracking", nil, function() SetSuperTrackedQuestID(0); QuestSuperTracking_ChooseClosestQuest() end)
            else
              _Addon.MenuContext:AddItem("Track", nil, function() SetSuperTrackedQuestID(self.id) end)
            end
          end
          _Addon.MenuContext:AddItem("Show details", nil, function()
            local questLogIndex = GetQuestLogIndexByID(self.id);
            if ( IsQuestComplete(self.id) and GetQuestLogIsAutoComplete(questLogIndex) ) then
              ShowQuestComplete(questLogIndex);
            else
              QuestLogPopupDetailFrame_Show(questLogIndex)
            end
          end)
          _Addon.MenuContext:AddItem("Link to chat", nil, function() ChatFrame_OpenChat(GetQuestLink(self.id)) end)
          _Addon.MenuContext:AddItem(MenuItemSeparator())
          _Addon.MenuContext:AddItem("Help", nil, function() print("Put a Help handler here !") end).disabled = true
        end
      end
    end)

    local headerText = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    headerText:GetFontObject():SetShadowOffset(0.5, 0)
    headerText:GetFontObject():SetShadowColor(0, 0, 0, 0.4)
    headerText:SetPoint("LEFT", 10, 0)
    headerText:SetPoint("RIGHT")
    headerText:SetPoint("TOP")
    headerText:SetPoint("BOTTOM")

    local headerLevel = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    headerLevel:GetFontObject():SetShadowOffset(0.5, 0)
    headerLevel:GetFontObject():SetShadowColor(0, 0, 0, 0.4)
    headerLevel:SetPoint("RIGHT", -2)

    frame.headerName = headerText
    frame.headerLevel = headerLevel
    frame.header = headerFrame

    self.frame = frame
    self.height = 21
    self.baseHeight = self.height

    -- Keep it in the cache for later.
    _QuestCache[self] = true
    -- Important: Always use 'This' to avoid issues when this class is inherited by
    -- other classes.
    This.RegisterFramesForThemeAPI(self)
    -- Important: Don't forgot 'This' as argument to this method !
    self:InitRefresh(This)
  end
endclass "Quest"
--============================================================================--
-- OnLoad Handler
--============================================================================--
function OnLoad(self)
  Options:Register("quest-show-id", false)
  Options:Register("quest-show-level", true, "quest/refresher")
  Options:Register("quest-color-level-by-difficulty", true, "quest/refresher")
  Options:Register("quest-left-click-behavior", "show-details-with-map")


  CallbackHandlers:Register("quest/refresher", CallbackHandler(Quest.RefreshAll), "refresher")

  -- Register this class in the object manager
  _ObjectManager:Register(Quest)
end
