-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio        "EskaQuestTracker.Widgets.ObjectiveTrackerFrame"               ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
class "ObjectiveTracker" extend "IFrame"
  _Obj = {}
  -- ======================================================================== --
  -- Handlers
  -- ======================================================================== --
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

  local function HandleFrameDragStop(frame)
    frame:StopMovingOrSizing()

    local x = frame:GetLeft()
    local y = frame:GetBottom()

    if _Obj then
      _Obj:SetPosition(x, y)
    end
    frame:SetUserPlaced(false)
  end

  -- ======================================================================== --
  -- Methods
  -- ======================================================================== --
  __Arguments__ { Boolean }
  function SetLocked(self, locked)
    self.frame:EnableMouse(not locked)
    self.frame:SetMovable(not locked)
  end

  __Arguments__ { Number, Number, Argument(Boolean, true, true, "saveInDB")}
  function SetPosition(self, x, y, saveInDB)
    self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
    if saveInDB then
      _DB.Tracker.xPos = x
      _DB.Tracker.yPos = y
    end
  end

  function Refresh(self)
    local theme = _CURRENT_THEME
    -- background color
    local color = theme:GetProperty("tracker", "background-color")
    --print("bg", color.r, color.g, color.b, color.a)
  --  self.frame:SetBackdropColor(color.r, color.g, color.b, color.a)
    -- border color
    color = theme:GetProperty("tracker", "border-color")
    --print("border", color.r, color.g, color.b, color.a)
    --self.frame:SetBackdropBorderColor(color.r, color.g, color.b, color.a)

  end


  __Static__() function GetBackgroundColor() end

  --__Arguments__{ Number, Number, Number, Argument(Number, true, 0) }
  --__Arguments__ { Number, Number, Number, Number }
  --__Static__() function SetBackdropColor(self, r, g, b, a) print(self, r, g, b, a) end

  -- ======================================================================== --
  -- Properties
  -- ======================================================================== --
  property "isScrollbarShown" { TYPE = Boolean, DEFAULT = true, HANDLER = SetScrollbarVisibility }
  property "contentHeight" { TYPE = Number, DEFAULT = 50, HANDLER = SetContentHeight }
  -- the width used by the tracker
  __Static__() property "width" {
    TYPE = Number,
    SET = function(self, width) _DB.Tracker.width = width ; _Obj.width = width
    end,
    GET = function(self) return _DB.Tracker.width end,
  }
  -- The height used by the tracker
  __Static__() property "height" {
    TYPE = Number,
    SET = function(self, height) _DB.Tracker.height = height ; _Obj.height = height end,
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
  }



  function ObjectiveTracker(self)
    local frame = CreateFrame("Frame", "EQT-TrackerFrame", UIParent)
    -- Register the frame
    self.frame = frame

    frame:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
    frame:SetBackdropColor(125/255, 125/255, 125/255, 0.25)
    frame:SetBackdropBorderColor(0.1, 0.1, 0.1)
    frame:SetFrameStrata("LOW")
    frame:SetSize(ObjectiveTracker.width, ObjectiveTracker.height)
    -- Restore the position contained in the DB if exists
    if _DB.Tracker.xPos and _DB.Tracker.yPos then
      self:SetPosition(_DB.Tracker.xPos, _DB.Tracker.yPos, false)
    else
      frame:SetPoint("CENTER")
    end
    -- Drag and move functions
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", HandleFrameDragStop)


    self:SetLocked(ObjectiveTracker.locked)

    local scrollFrame = CreateFrame("ScrollFrame", "EQT-ObjectiveTrackerFrameScrollFrame", frame, "UIPanelScrollFrameTemplate")
    --scrollFrame:SetPoint("TOPLEFT")
    --scrollFrame:SetPoint("BOTTOMRIGHT")
    scrollFrame:SetAllPoints()
    --scrollFrame:SetBackdrop(_Backdrops.Common)
    --scrollFrame:SetBackdropColor(0, 1, 1)



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
    scrollbar:SetBackdropColor(0, 0, 0, 0.5)
    scrollbar:SetBackdropBorderColor(0, 0, 0)
    scrollbar:ClearAllPoints()
    scrollbar:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
    scrollbar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    -- customize the scroll bar thumb
    local thumb = scrollbar:GetThumbTexture()
    thumb:SetTexture(_Backdrops.Common.bgFile)
    thumb:SetVertexColor(1, 199/255, 0)
    thumb:SetHeight(40)
    thumb:SetWidth(8)

    -- content
    local content = CreateFrame("Frame")
    content:SetBackdrop(_Backdrops.Common)
    content:SetBackdropBorderColor(0.1, 0.1, 0.1, 0)
    content:SetBackdropColor(0, 0, 0, 0.15)

    scrollFrame:SetScrollChild(content)
    content:SetHeight(self.contentHeight)
    content:SetWidth(scrollFrame:GetWidth())




    self.content = content
    self.scrollFrame = scrollFrame
    self.scrollbar = scrollbar

    _Obj = self
    self:Refresh()

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
endclass "ObjectiveTracker"
-- Set the default values for the DB
function OnLoad(self)
  _DB:SetDefault("Tracker", {
    width = 325,
    height = 300,
    locked = false,
    backdropColor = { r = 0, g = 0, b = 0, a = 0.5 },
    backdropBorderColor = { r = 0, g = 0, b = 0},
  })
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
end
