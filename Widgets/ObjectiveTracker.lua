--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio        "EskaQuestTracker.Widgets.ObjectiveTrackerFrame"               ""
--============================================================================--
namespace "EQT"
--============================================================================--
class "ObjectiveTracker" inherit "Frame"
  _Obj = {}
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function SetContentHeight(self, new, old, prop)

    -- Update the content size
    self.content:SetHeight(new)

    -- check if the scrollbar is needed or not
    local parentHeight = self.scrollFrame:GetHeight()
    if new >= parentHeight then
      self.isScrollbarShown = true
    else
      self.isScrollbarShown = false
    end

  end

  local function SetScrollbarVisibility(self, new, old)
    self.scrollFrame:ClearAllPoints()
    self.scrollFrame:SetPoint("TOPLEFT")

    if new then
      self.scrollbar:Show()
      self.scrollFrame:SetPoint("BOTTOMRIGHT", self.scrollbar, "BOTTOMLEFT")
    else
      self.scrollbar:Hide()
      self.scrollFrame:SetPoint("BOTTOMRIGHT")
    end

    -- Update the content size
    self.content:SetWidth(self.scrollFrame:GetWidth())
  end
  ------------------------------------------------------------------------------
  --                         Global Handlers                                  --
  --      Some frames can need to get theses handler in order to Tracker      --
  --      moving works.                                                       --
  ------------------------------------------------------------------------------
  _Addon.ObjectiveTrackerMouseDown = function(_, button)
    if button == "LeftButton" and not Options:Get("tracker-locked") and _Obj then
        _Obj.frame:StartMoving()
    end
  end

  _Addon.ObjectiveTrackerMouseUp = function(_, button)
    if button == "LeftButton" and not Options:Get("tracker-locked") and _Obj then
      _Obj.frame:StopMovingOrSizing()

      local x = _Obj.frame:GetLeft()
      local y = _Obj.frame:GetBottom()

      if _Obj then
        _Obj:SetPosition(x, y)
      end
      _Obj.frame:SetUserPlaced(false)
    end
  end

  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  __Arguments__ { Boolean }
  function SetLocked(self, locked)
    self.frame:EnableMouse(not locked)
    self.frame:SetMovable(not locked)
  end

  __Arguments__ { Number, Number, Argument(Boolean, true, true, "saveInDB")}
  function SetPosition(self, x, y, saveInDB)
    self.frame:ClearAllPoints()
    self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
    if saveInDB then
      Options:Set("tracker-xPos", x, false)
      Options:Set("tracker-yPos", y, false)
    end
  end

  function Refresh(self)
    Theme.SkinFrame(self.frame)

    Theme.SkinFrame(self.scrollbar)
    Theme.SkinTexture(self.scrollbar.thumb)

  end

  __Static__()
  function RefreshAll()
    if _Obj then
      _Obj:Refresh()
    end
  end

  function RegisterFramesForThemeAPI(self)
    Theme.RegisterFrame(self.tID, self.frame)

    Theme.RegisterFrame(self.tID..".scrollbar", self.scrollbar)
    Theme.RegisterTexture(self.tID..".scrollbar.thumb", self.scrollbar.thumb)

    Theme.RegisterRefreshHandler(self.tID, function() self:Refresh() end)
  end

  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "isScrollbarShown" { TYPE = Boolean, DEFAULT = true, HANDLER = SetScrollbarVisibility }
  property "contentHeight" { TYPE = Number, DEFAULT = 50, HANDLER = SetContentHeight }
  -- the width used by the tracker
  --[[__Static__() property "width" {
    TYPE = Number,
    SET = function(self, width) _DB.Tracker.width = width ; _Obj.width = width
    end,
    GET = function(self) return _DB.Tracker.width end,
  }
  -- The height used by the tracker
  __Static__() property "height" {
    TYPE = Number,
    -- SET = function(self, height) _DB.Tracker.height = height ; _Obj.height = height end,
    SET = function(self, height) _Obj.height = height end,
    GET = function(self) return _DB.Tracker.height end,
  }

  __Static__() property "locked" {
    TYPE = Boolean,
    SET = function(self, locked) _DB.Tracker.locked = locked ; _Obj:SetLocked(locked) end,
    GET = function(self) return _DB.Tracker.locked end
  }

  __Static__() property "backgroundColor" {
    TYPE = Table,
    SET = function(self, color)  _DB.Tracker.backdropColor = color ; _Obj.frame:SetBackdropColor(color.r, color.g, color.b, color.a) end,
    GET = function() return _DB.Tracker.backdropColor end,
  }

  __Static__() property "borderColor" {
    TYPE = Table,
    SET = function(self, color) _DB.Tracker.backdropBorderColor = color ; _Obj.frame:SetBackdropBorderColor(color.r, color.g, color.b, color.a) end,
    GET = function() return _DB.Tracker.backdropBorderColor end,
  }--]]
  -- Theme
  property "tID" { DEFAULT = "tracker" }

  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function ObjectiveTracker(self)
    Super(self)

    local frame = CreateFrame("Frame", "EQT-TrackerFrame", UIParent)
    -- Register the frame
    self.frame = frame

    frame:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
    frame:SetFrameStrata("LOW")
    --frame:SetSize(ObjectiveTracker.width, ObjectiveTracker.height)
    frame:SetSize(Options:Get("tracker-width"), Options:Get("tracker-height"))
    -- Restore the position contained in the DB if exists
    if Options:Exists("tracker-xPos") and Options:Exists("tracker-yPos") then
      self:SetPosition(Options:Get("tracker-xPos"), Options:Get("tracker-yPos"), false)
    else
      frame:SetPoint("CENTER")
    end



    -- Restore the position contained in the DB if exists

    -- Drag and move functions
    frame:SetScript("OnMouseDown", _Addon.ObjectiveTrackerMouseDown)
    frame:SetScript("OnMouseUp", _Addon.ObjectiveTrackerMouseUp)


    self:SetLocked(Options:Get("tracker-locked"))

    local scrollFrame = CreateFrame("ScrollFrame", "EQT-ObjectiveTrackerFrameScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetAllPoints()

    -- Hide the scroll bar and its buttons
    local scrollbarName = scrollFrame:GetName()
    local scrollbar = _G[scrollFrame:GetName().."ScrollBar"];
    local scrollupbutton = _G[scrollbar:GetName().."ScrollUpButton"];
    local scrolldownbutton = _G[scrollbarName.."ScrollBarScrollDownButton"];

    scrollbar:Hide()
    scrollupbutton:Hide()
    scrollupbutton:ClearAllPoints()
    scrolldownbutton:Hide()
    scrolldownbutton:ClearAllPoints()

    -- customize the scroll bar
    scrollbar:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
    scrollbar:ClearAllPoints()
    scrollbar:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
    scrollbar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    -- customize the scroll bar thumb
    local thumb = scrollbar:GetThumbTexture()
    thumb:SetTexture(_Backdrops.Common.bgFile)
    thumb:SetHeight(40)
    thumb:SetWidth(8)

    -- content
    local content = CreateFrame("Frame")
    --content:SetBackdrop(_Backdrops.Common)
    --content:SetBackdropBorderColor(0.1, 0.1, 0.1, 0)
    --content:SetBackdropColor(0, 0, 0, 0.15)

    scrollFrame:SetScrollChild(content)
    content:SetHeight(self.contentHeight)
    content:SetWidth(scrollFrame:GetWidth())

    self.content = content
    self.scrollFrame = scrollFrame
    self.scrollbar = scrollbar
    self.scrollbar.thumb = thumb


    This.RegisterFramesForThemeAPI(self)
    self:Refresh()

    _Obj = self

    -- OnWidthChanged event handler
    function self:OnWidthChanged(new, old)
      self.frame:SetWidth(new)

      -- Update scroll frame Anchor
      self.scrollFrame:ClearAllPoints()
      self.scrollFrame:SetPoint("TOPLEFT")

      if self.isScrollbarShown then
        self.scrollFrame:SetPoint("BOTTOMRIGHT", self.scrollbar, "BOTTOMLEFT")
      else
        self.scrollFrame:SetPoint("BOTTOMRIGHT")
      end

      self.content:SetWidth(self.scrollFrame:GetWidth())
    end

    -- OnHeightChanged event hander
    function self:OnHeightChanged(new, old)
      self.frame:SetHeight(new)

      -- check if the scrollbar is needed or not
      local parentHeight = self.scrollFrame:GetHeight()
      if self.contentHeight >= parentHeight then
        self.isScrollbarShown = true
      else
        self.isScrollbarShown = false
      end
    end
  end

  -- Say to options the keywords availables
  Options.AddAvailableThemeKeywords(
    Options.ThemeKeyword("tracker", Options.ThemeKeywordType.FRAME),
    Options.ThemeKeyword("tracker.scrollbar", Options.ThemeKeywordType.FRAME),
    Options.ThemeKeyword("tracker.scrollbar.thumb", Options.ThemeKeywordType.TEXTURE)
  )

endclass "ObjectiveTracker"

function OnLoad(self)
  --_DB:SetDefault("Tracker", {
    --width = 325,
    --height = 300,
    --locked = false,
    --backdropColor = { r = 0, g = 0, b = 0, a = 0.5 },
    --backdropBorderColor = { r = 0, g = 0, b = 0},
  --})
  -- Options
  Options:Register("tracker-height", 300, "tracker/setHeight")
  Options:Register("tracker-width", 325, "tracker/setWidth")
  Options:Register("tracker-locked", false, "tracker/setLocked")

    -- Create and init the objetive tracker that will contains all the blocks (quests, scenario, keystone, ...)
  local tracker = ObjectiveTracker()
  -- Init some vars from db
  _CURRENT_TRACKER_WIDTH = ObjectiveTracker.width
  -- Handle the event of tracker
  tracker.OnWidthChanged = tracker.OnWidthChanged + function(self, width)
    Scorpio.FireSystemEvent("EQT_TRACKER_WIDTH_CHANGED", width)
  end

  -- Assign it as addon tracker
  _Addon.ObjectiveTracker = tracker

  -- Callback handlers
  CallbackHandlers:Register("tracker/refresher", CallbackHandler(ObjectiveTracker.RefreshAll), "refresher")
  CallbackHandlers:Register("tracker/setLocked", CallbackObjectHandler(tracker, ObjectiveTracker.SetLocked))
  CallbackHandlers:Register("tracker/setHeight", CallbackPropertyHandler(tracker, "height"))
  CallbackHandlers:Register("tracker/setWidth", CallbackPropertyHandler(tracker, "width"))
end
