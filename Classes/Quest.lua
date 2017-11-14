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
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function UpdateProps(self, new, old, prop)
    if prop == "name" then
      Theme:SkinText(self.frame.headerName, new)
    elseif prop == "level" then
      Theme:SkinText(self.frame.headerLevel, new)
      if Options:Get("quest-color-level-by-difficulty") then
        local color = GetQuestDifficultyColor(new)
        self.frame.headerLevel:SetTextColor(color.r, color.g, color.b)
      end
    elseif prop == "distance" then
      self.OnDistanceChanged(self, new)
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
      -- self:Show()
    end

    return self.questItem
  end

  __Arguments__{}
  function Draw(self)
    if not self:IsShown() then
      self:Show()
    end

    if self.questItem then
      if not self.questItem:IsShown() then
        self.questItem:Show()
      end

      local obj = self.objectives[1]
      if obj then
        self.questItem:Show()
        self.questItem.frame:SetPoint("TOPLEFT", self.frame.header, "BOTTOMLEFT", 5, -5)

        obj.frame:SetPoint("TOPLEFT", self.questItem.frame, "TOPRIGHT")
        obj.frame:SetPoint("TOPRIGHT", self.frame.header, "BOTTOMRIGHT")

        self:DrawObjectives(self.frame.header, true)
        if self.height < self.questItem.height + self.baseHeight + 10 then
          self.height = self.baseHeight + self.questItem.height + 10
        end
      end
    else
      self:DrawObjectives(self.frame.header)
    end
  end

  function ShowLevel(self)
    self.frame.headerLevel:Show()
    self.frame.headerName:SetPoint("RIGHT", self.frame.headerLevel, "LEFT")
  end

  function HideLevel(self)
    self.frame.headerLevel:Hide()
    self.frame.headerName:SetPoint("RIGHT")
  end

  __Arguments__ { Argument(Theme.SkinFlags, true, 127), Argument(Boolean, true, true)}
  function Refresh(self, skinFlags, callSuper)
    Theme:SkinFrame(self.frame, nil, nil, skinFlags)
    Theme:SkinFrame(self.frame.header, nil, nil, skinFlags)
    Theme:SkinText(self.frame.headerName, self.name, nil, skinFlags)


    if Options:Get("quest-show-level") then
      self:ShowLevel()
      Theme:SkinText(self.frame.headerLevel, self.level, nil, skinFlags)

      if Options:Get("quest-color-level-by-difficulty") then
        local color = GetQuestDifficultyColor(self.level)
        self.frame.headerLevel:SetTextColor(color.r, color.g, color.b)
      end
    else
      self:HideLevel()
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


    if self.questItem then
      self.questItem.isReusable = true
      self.questItem = nil
    end


    -- Reset variables
    --self.objectives =  ObjectArray(Objective)
    --self:ClearObjectives()

  end

  __Arguments__ { Argument(Theme.SkinFlags, true, 127) }
  __Static__() function RefreshAll(skinFlags)
    for obj in pairs(_QuestCache) do
      obj:Refresh(skinFlags)
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

  __Static__() property "_prefix" { DEFAULT = "quest" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Quest(self)
    Super(self)

    local frame = CreateFrame("Frame")
    frame:SetBackdrop(_Backdrops.Common)

    local headerFrame = CreateFrame("Button", nil, frame)
    headerFrame:SetBackdrop(_Backdrops.Common)
    headerFrame:SetPoint("TOPRIGHT")
    headerFrame:SetPoint("TOPLEFT")
    headerFrame:SetHeight(21) -- 14
    headerFrame:RegisterForClicks("RightButtonUp", "LeftButtonUp")

    -- Script
    headerFrame:SetScript("OnClick", function(_, button, down)
      if not self:MustBeInteractive(headerFrame) then
        return
      end

      if button == "LeftButton" then
        ShowQuestLog();
        QuestMapFrame_ShowQuestDetails(self.id);
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

    -- Important : Always use 'This' to avoid issues when this class is inherited
    -- by other classes.
    This.RegisterFramesForThemeAPI(self)
    This.Refresh(self)

    _QuestCache[self] = true
  end
endclass "Quest"
--============================================================================--
-- OnLoad Handler
--============================================================================--
function OnLoad(self)
  Options:Register("quest-show-id", false)
  Options:Register("quest-show-level", true, "quest/refresher")
  Options:Register("quest-color-level-by-difficulty", true, "quest/refresher")


  CallbackHandlers:Register("quest/refresher", CallbackHandler(Quest.RefreshAll), "refresher")

  -- Register this class in the object manager
  _ObjectManager:Register(Quest)
end
