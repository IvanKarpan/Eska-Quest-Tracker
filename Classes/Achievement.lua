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
  _AchievementCache = setmetatable( {}, { __mode = "k" } )
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function UpdateProps(self, new, old, prop)
    if prop == "name" then
      Theme.SkinText(self.frame.headerName, new)
    elseif prop == "icon" then
      self.frame.ftex.texture:SetTexture(new)
    elseif prop == "desc" then
      self.frame.description:SetText(new)
    elseif prop == "showDesc" then
      if new then
        self:ShowDescription()
      else
        self:HideDescription()
      end
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
  __Arguments__{}
  function Draw(self)
    if self.numObjectives > 0 then
      local obj = self.objectives[1]
      if obj then
        if self.showDesc then
          obj.frame:SetPoint("TOPLEFT", self.frame.description, "BOTTOMLEFT")
          obj.frame:SetPoint("TOPRIGHT", self.frame.description, "BOTTOMRIGHT")
          self.frame.description:Show()
        else
          obj.frame:SetPoint("TOPLEFT", self.frame.header, "BOTTOMLEFT")
          obj.frame:SetPoint("TOPRIGHT", self.frame.header, "BOTTOMRIGHT")
          self.frame.description:Hide()
        end
        self:DrawObjectives(self.frame, true)
      end
    end
    if self.showDesc then
      self.height = self.height + self.frame.description:GetHeight() + 8
    end

    if self.height < 46 + 8 then
      self.height = 46 + 8
    end
  end




  __Arguments__{}
  function ShowDescription(self)
    if self.frame.description:IsShown() then
      return
    end

    if self.numObjectives > 0 then
      local obj = self.objectives[1]
      obj.frame:SetPoint("TOPLEFT", self.frame.description, "BOTTOMLEFT")
      obj.frame:SetPoint("TOPRIGHT", self.frame.description, "BOTTOMRIGHT")
    end

    self.frame.description:Show()
    self.height = self.height + self.frame.description:GetHeight()
  end

  __Arguments__{}
  function HideDescription(self)
    if not self.frame.description:IsShown() then
      return
    end

    if self.numObjectives > 0 then
      local obj = self.objectives[1]
      obj.frame:SetPoint("TOPLEFT", self.frame.header, "BOTTOMLEFT")
      obj.frame:SetPoint("TOPRIGHT", self.frame.header, "BOTTOMRIGHT")
    end
    self.frame.description:Hide()
    self.height = self.height - self.frame.description:GetHeight()
  end


  function Refresh(self)
    Theme.SkinFrame(self.frame)
    Theme.SkinFrame(self.frame.header)

    Theme.SkinText(self.frame.headerName, self.name)

    Theme.SkinFrame(self.frame.ftex)

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
  end

  function RegisterFramesForThemeAPI(self)
    local class = System.Reflector.GetObjectClass(self)

    Theme.RegisterFrame(class._THEME_CLASS_ID, self.frame)
    Theme.RegisterFrame(class._THEME_CLASS_ID..".header", self.frame.header)

    Theme.RegisterText(class._THEME_CLASS_ID..".name", self.frame.headerName)

    Theme.RegisterFrame(class._THEME_CLASS_ID..".icon", self.frame.ftex)
  end

  __Static__() function RefreshAll()
    for obj in pairs(_AchievementCache) do
      obj:Refresh()
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
  __Static__() property "_THEME_CLASS_ID" { DEFAULT = "achievement" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Achievement(self)
    Super(self)

    local frame = CreateFrame("Frame")
    frame:SetBackdrop(_Backdrops.Common)

    local ftex = CreateFrame("Frame", nil, frame)
    ftex:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
    ftex:SetPoint("TOPLEFT")
    ftex:SetHeight(46)
    ftex:SetWidth(46)
    frame.ftex = ftex

    local texture = ftex:CreateTexture()
    texture:SetPoint("CENTER")
    texture:SetHeight(44)
    texture:SetWidth(44)
    texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    ftex.texture = texture

    local headerFrame = CreateFrame("Button", nil, frame)
    headerFrame:SetBackdrop(_Backdrops.Common)
    headerFrame:SetPoint("TOPRIGHT")
    headerFrame:SetPoint("TOPLEFT", ftex, "TOPRIGHT")
    headerFrame:SetHeight(21)
    headerFrame:RegisterForClicks("RightButtonUp", "LeftButtonUp")
    headerFrame:SetScript("OnClick", function(_, button, down)
      if not self:MustBeInteractive(headerFrame) then
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

    local description = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    description:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT")
    description:SetPoint("TOPRIGHT", headerFrame, "BOTTOMRIGHT")
    description:SetText("")
    description:Hide()
    frame.description = description


    frame.headerName = headerText
    frame.header = headerFrame

    self.frame = frame
    self.height = 46
    self.baseHeight = 21

    -- Important : Always use 'This' to avoid issues when this class is inherited
    -- by other classes.
    This.RegisterFramesForThemeAPI(self)
    This.Refresh(self)

    _AchievementCache[self] = true
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

      self.OnDrawRequest()
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

      self.OnDrawRequest()
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
    local height = 0

    for index, achievement in self.achievements:GetIterator() do
      achievement:ClearAllPoints()
      achievement:Show()
      achievement:Draw()

      if index == 1 then
        achievement.frame:SetPoint("TOPLEFT", 0, -40)
        achievement.frame:SetPoint("TOPRIGHT", 0, -40)
      else
        achievement.frame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -5)
        achievement.frame:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
      end

      height = height + achievement.height
      previousFrame = achievement.frame
    end
    self.height = self.baseHeight + height + 10
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  __Static__() property "_THEME_CLASS_ID" { DEFAULT = "block.achievements" }

  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function AchievementBlock(self)
    Super(self, "achievements", 10)
    self.text = "Achievements"

    self.achievements = ObjectArray(Achievement)

    _AchievementBlockCache[self] = true
  end


endclass "AchievementBlock"

--============================================================================--
-- OnLoad Handler
--============================================================================--
function OnLoad(self)
  -- Register this class in the object manager
  _ObjectManager:Register(Achievement)
end
