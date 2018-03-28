--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio             "EskaQuestTracker.Classes.Achievement"                    ""
--============================================================================--
namespace "EQT"
--============================================================================--

class "Achievement" inherit "Frame" extend "IReusable" "IObjectiveHolder"
  _AchievementCache = setmetatable( {}, { __mode = "k" })
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function UpdateProps(self, new, old, prop)
    local state = self:GetCurrentState()

    if prop == "name" then
      Theme:NewSkinText(self.frame.headerName, Theme.SkinTextFlags.TEXT_TRANSFORM, new, state)
    elseif prop == "icon" then
      self.frame.ftex.texture:SetTexture(new)
    elseif prop == "desc" then
      Theme:NewSkinText(self.frame.description, Theme.SkinTextFlags.TEXT_TRANSFORM, new, state)
      self:CalculateHeight()
    elseif prop == "showDesc" then
      if new then
        self:ShowDescription()
      else
        self:HideDescription()
      end
    elseif prop == "failed" then
      self:Refresh()
    end
  end

  local function SelectAchievement(achievementID)
    if not AchievementFrame then
      AchievementFrame_LoadUI()
    end
    if not AchievementFrame:IsShown() then
      AchievementFrame_ToggleAchievementFrame()
    end
    AchievementFrame_SelectAchievement(achievementID)
  end
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  function ShowDescription(self)
    if self.frame.description:IsShown() then
      return
    end

    self.frame.description:Show()
    self:Draw()
  end

  function HideDescription(self)
    if not self.frame.description:IsShown() then
      return
    end

    self.frame.description:Hide()
    self:Draw()
  end
  function Draw(self)
    if not self:IsShown() then
      self:Show()
    end

    local previousFrame
    for index, obj in self.objectives:GetIterator() do
      obj:ClearAllPoints()
      if not obj:IsShown() then
        obj:Show()
      end
      if index == 1 then
        if self.showDesc then
          obj:SetPoint("TOP", self.frame.description, "BOTTOM")
          obj:SetPoint("LEFT", self.frame.description, "LEFT")
          obj:SetPoint("RIGHT")
        else
          obj:SetPoint("TOP", self.frame.header, "BOTTOM")
          obj:SetPoint("LEFT", self.frame.ftex.texture, "RIGHT")
          obj:SetPoint("RIGHT")
        end
      else
        obj:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT")
        obj:SetPoint("RIGHT")
      end
      obj:CalculateHeight()
      previousFrame = obj.frame
    end

    self:CalculateHeight()
  end


  function GetCurrentState(self)
    return self.failed and "failed" or nil
  end


  function CalculateHeight(self)
    -- Reset the height to baseHeight
    local height = self.baseHeight
    -- Get the objectives height
    local objectivesHeight = self:GetObjectivesHeight()

    -- Get the description height if enabled
    if self.showDesc then
      -- Update the height (avoid a incorrect value by CalculateHeight)
      self.frame.description:SetHeight(0)
      height = max(height, self.frame.description:GetHeight() + objectivesHeight + 21)
    else
      height = max(height, objectivesHeight + 21)
    end

    self.height = height + 2
  end

  __Arguments__ { Variable.Optional(Theme.SkinInfo, Theme.SkinInfo()), Variable.Optional(Boolean, true) }
  function SkinFeatures(self, info, alreadyInit)
    -- Call the parent if the object is already init.
    if alreadyInit then
      super.SkinFeatures(self, info)
    end

    local state = self:GetCurrentState()

    Theme:NewSkinFrame(self.frame, info, state)
    Theme:NewSkinFrame(self.frame.header, info, state)
    Theme:NewSkinText(self.frame.headerName, info, self.name, state)
    Theme:NewSkinText(self.frame.description, info, self.desc, state)
    Theme:NewSkinFrame(self.frame.ftex, info, state)
    self:CalculateHeight()
  end

  function Reset(self)
    self:ClearAllPoints()
    self:SetParent(nil)
    self:Hide()

    -- Reset properties
    self.numObjectives = nil
    self.id = nil
    self.name = nil
    self.icon = nil
    self.desc = nil
    self.showDesc = nil
    self.failed = nil
  end

  function RegisterFramesForThemeAPI(self)
    local class = Class.GetObjectClass(self)

    Theme:RegisterFrame(class._prefix..".frame", self.frame)
    Theme:RegisterFrame(class._prefix..".header", self.frame.header)

    Theme:RegisterText(class._prefix..".name", self.frame.headerName)
    Theme:RegisterText(class._prefix..".description", self.frame.description)

    Theme:RegisterFrame(class._prefix..".icon", self.frame.ftex)
  end

  __Arguments__ { Variable.Optional(Theme.SkinInfo, Theme.SKIN_INFO_ALL_FLAGS) }
  __Static__() function RefreshAll(skinInfo)
    for obj in pairs(_AchievementCache) do
      obj:Refresh(skinInfo)
    end
  end

  __Static__() function UpdateSize()
    for obj in pairs(_AchievementCache) do
      obj:CalculateHeight()
    end
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "id" { TYPE = Number, DEFAULT = -1 }
  property "name" { TYPE = String, DEFAULT = "", HANDLER = UpdateProps }
  property "icon" { TYPE = String + Number, DEFAULT = nil, HANDLER = UpdateProps }
  property "desc" { TYPE = String, DEFAULT = "", HANDLER = UpdateProps }
  property "showDesc" { TYPE = Boolean, DEFAULT = true, HANDLER = UpdateProps }
  property "failed" { TYPE = Boolean, DEFAULT = false, HANDLER = UpdateProps }
  __Static__() property "_prefix" { DEFAULT = "achievement"}

  function Achievement(self)
    super(self)

    self.frame = CreateFrame("Frame")
    self.frame:SetBackdrop(_Backdrops.Common)

    local ftex = CreateFrame("Frame", nil, self.frame)
    ftex:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
    ftex:SetPoint("TOPLEFT")
    ftex:SetHeight(46)
    ftex:SetWidth(46)
    self.frame.ftex = ftex

    local texture = ftex:CreateTexture()
    texture:SetPoint("CENTER")
    texture:SetHeight(44)
    texture:SetWidth(44)
    texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    self.frame.ftex.texture = texture

    local headerFrame = CreateFrame("Button", nil, self.frame)
    headerFrame:SetBackdrop(_Backdrops.Common)
    headerFrame:SetPoint("TOPRIGHT")
    headerFrame:SetPoint("TOPLEFT", ftex, "TOPRIGHT")
    headerFrame:SetHeight(21)
    headerFrame:RegisterForClicks("RightButtonUp", "LeftButtonUp")
    self.frame.header = headerFrame

    headerFrame:SetScript("OnClick", function(_, button, down)
      if not Frame:MustBeInteractive(headerFrame) then
        return
      end
      if button == "LeftButton" then
        if not AchievementFrame or AchievementFrameAchievements.selection ~= self.id then
          SelectAchievement(self.id)
        else
          AchievementFrame_ToggleAchievementFrame()
        end
      elseif button == "RightButton" then
        if _Addon.MenuContext:IsShown() then
          _Addon.MenuContext:Hide()
        else
          _Addon.MenuContext:Show()
          _Addon.MenuContext:ClearAnchorFrames():AnchorTo(self.frame.ftex, headerFrame):UpdateAnchorPoint()
          _Addon.MenuContext:Clear()
          _Addon.MenuContext:AddItem("Open Achievement", nil, function() SelectAchievement(self.id) end)
          _Addon.MenuContext:AddItem("Stop Tracking", nil, function()
            RemoveTrackedAchievement(self.id);
            if AchievementFrame then
              AchievementFrameAchievements_ForceUpdate();
            end
          end)
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
    self.frame.headerName = headerText

    local description = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    description:SetPoint("TOP", 0, -21)
    description:SetPoint("LEFT", 51, 0)
    description:SetPoint("RIGHT")
    description:SetText("")
    description:SetJustifyH("LEFT")
    description:SetWordWrap(true)
    self.frame.description = description


    self.baseHeight = 46
    self.height = self.baseHeight

    -- Keep it in the cache for later.
    _AchievementCache[self] = true
    -- Important: Always use 'This' to avoid issues when this class is inherited by
    -- other classes.
    RegisterFramesForThemeAPI(self)
    -- Important: Don't forgot 'This' as argument to this method !
    self:InitRefresh(Achievement)
  end


endclass "Achievement"


--============================================================================--
class "AchievementBlock" inherit "Block"
  _AchievementBlockCache = setmetatable( {}, { __mode = "k" })
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  __Arguments__ { Achievement }
  function AddAchievement(self, achievement)
    if not self.achievements:Contains(achievement) then
      self.achievements:Insert(achievement)
      achievement:SetParent(self.frame)

      achievement.OnHeightChanged = function(ac, new, old)
        self.height = self.height + (new - old)
      end

      self:OnDrawRequest()
    end
  end


  __Arguments__ { Number }
  function RemoveAchievement(self, achievementID)
    local achievement = self:GetAchievement(achievementID)
    if achievement then
      self:RemoveAchievement(achievement)
    end
  end

  __Arguments__ { Achievement }
  function RemoveAchievement(self, achievement)
    local found = self.achievements:Remove(achievement)
    if found then
      achievement.OnHeightChanged = nil
      achievement.isReusable = true

      self:OnDrawRequest()
    end
  end

  __Arguments__ { Number }
  function GetAchievement(self, achievementID)
    for _, achievement in self.achievements:GetIterator() do
      if achievement.id == achievementID then
        return achievement
      end
    end
  end

  __Arguments__{}
  function Draw(self)
    local previousFrame
    for index, achievement in self.achievements:GetIterator() do
      achievement:ClearAllPoints()
      if not achievement:IsShown() then
        achievement:Show()
      end

      if index == 1 then
        achievement:SetPoint("TOP", 0, -36)
        achievement:SetPoint("LEFT")
        achievement:SetPoint("RIGHT")
      else
        achievement:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -5)
        achievement:SetPoint("RIGHT")
      end

      previousFrame = achievement.frame
    end

    self:CalculateHeight()
  end

  __Arguments__{}
  function CalculateHeight(self)
    local height = self.baseHeight
    local offset = 5

    for index, achievement in self.achievements:GetIterator() do
      height = height + achievement.height
      if index > 1 then
        height = height + offset
      end
    end

    self.height = height + 2
  end


  __Arguments__ { Variable.Optional(Theme.SkinInfo, Theme.SKIN_INFO_ALL_FLAGS) }
  __Static__() function RefreshAll(skinInfo)
    for obj in pairs(_AchievementBlockCache) do
      obj:Refresh(skinInfo)
    end
  end

  __Static__() function DrawAll()
    for obj in pairs(_AchievementBlockCache) do
      obj:Draw()
    end
  end

  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  __Static__() property "_prefix" { DEFAULT = "block.achievements" }

  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function AchievementBlock(self)
    super(self, "achievements", 10)
    self.text = "Achievements"

    self.achievements = Array[Achievement]()

    -- Keep it in the cache for later.
    _AchievementBlockCache[self] = true
  end


endclass "AchievementBlock"

--============================================================================--
-- OnLoad Handler
--============================================================================--
function OnLoad(self)
  -- Register this class in the object manager
  _ObjectManager:Register(Achievement)

  CallbackHandlers:Register("achievements/refresher", CallbackHandler(AchievementBlock.RefreshAll))
  CallbackHandlers:Register("achievement/refresher", CallbackHandler(Achievement.RefreshAll), "refresher")

end

__SystemEvent__()
function EQT_CONTENT_SIZE_CHANGED()
  Achievement.UpdateSize()
end

__SystemEvent__()
function EQT_SCROLLBAR_VISIBILITY_CHANDED()
  Achievement.UpdateSize()
end
