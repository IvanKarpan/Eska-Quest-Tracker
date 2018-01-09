--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio        "EskaQuestTracker.Widgets.ObjectiveTrackerFrame"               ""
--============================================================================--
namespace "EQT"
--============================================================================--
class "ObjectiveTracker" inherit "BorderFrame"
  _Obj = {}
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function SetContentHeight(self, new, old, prop)
    -- Update the content size
    self.content:SetHeight(new)

    -- Update the scroll bar visibility
    self:UpdateScrollbarVisibility()
  end

  local function ObjectiveTracker_OnScrollRangeChanged(self, xrange, yrange)
  	local name = self:GetName();
  	local scrollbar = self.ScrollBar or _G[name.."ScrollBar"];
  	if ( not yrange ) then
  		yrange = self:GetVerticalScrollRange();
  	end

  	-- Accounting for very small ranges
  	yrange = floor(yrange);

  	local value = min(scrollbar:GetValue(), yrange);
  	scrollbar:SetMinMaxValues(0, yrange);
  	scrollbar:SetValue(value);

  	local scrollDownButton = scrollbar.ScrollDownButton or _G[scrollbar:GetName().."ScrollDownButton"];
  	local scrollUpButton = scrollbar.ScrollUpButton or _G[scrollbar:GetName().."ScrollUpButton"];
  	local thumbTexture = scrollbar.ThumbTexture or _G[scrollbar:GetName().."ThumbTexture"];

  	if ( yrange == 0 ) then
  		if ( self.scrollBarHideable ) then
  			scrollbar:Hide();
  			scrollDownButton:Hide();
  			scrollUpButton:Hide();
  			thumbTexture:Hide();
  		else
  			scrollDownButton:Disable();
  			scrollUpButton:Disable();
  			scrollDownButton:Show();
  			scrollUpButton:Show();
  			if ( not self.noScrollThumb ) then
  				thumbTexture:Show();
  			end
  		end
  	else
  		scrollDownButton:Show();
  		scrollUpButton:Show();
  		--scrollbar:Show();
  		if ( not self.noScrollThumb ) then
  			thumbTexture:Show();
  		end
  		-- The 0.005 is to account for precision errors
  		if ( yrange - value > 0.005 ) then
  			scrollDownButton:Enable();
  		else
  			scrollDownButton:Disable();
  		end
  	end

  	-- Hide/show scrollframe borders
  	local top = self.Top or name and _G[name.."Top"];
  	local bottom = self.Bottom or name and _G[name.."Bottom"];
  	local middle = self.Middle or name and _G[name.."Middle"];
  	if ( top and bottom and self.scrollBarHideable ) then
  		if ( self:GetVerticalScrollRange() == 0 ) then
  			top:Hide();
  			bottom:Hide();
  		else
  			top:Show();
  			bottom:Show();
  		end
  	end
  	if ( middle and self.scrollBarHideable ) then
  		if ( self:GetVerticalScrollRange() == 0 ) then
  			middle:Hide();
  		else
  			middle:Show();
  		end
  	end
  end
  ------------------------------------------------------------------------------
  --                         Global Handlers                                  --
  --      Some frames can need to get theses handler in order to Tracker      --
  --      moving works.                                                       --
  ------------------------------------------------------------------------------
  _Addon.ObjectiveTrackerMouseDown = function(f, button)
    if button == "LeftButton" and not Options:Get("tracker-locked") and _Obj then
      if not Frame:MustBeInteractive(f) then
        return
      end

        _Obj:GetFrameContainer():StartMoving()
    end
  end

  _Addon.ObjectiveTrackerMouseUp = function(f, button)
    if button == "LeftButton" and not Options:Get("tracker-locked") and _Obj then
      if not Frame:MustBeInteractive(f) then
        return
      end

      _Obj:GetFrameContainer():StopMovingOrSizing()

      local x = _Obj:GetFrameContainer():GetLeft()
      local y = _Obj:GetFrameContainer():GetBottom()

      if _Obj then
        _Obj:SetPosition(x, y)
      end
      _Obj:GetFrameContainer():SetUserPlaced(false)
    end
  end

  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  __Arguments__ { Boolean }
  function SetLocked(self, locked)
    self:GetFrameContainer():EnableMouse(not locked)
    self:GetFrameContainer():SetMovable(not locked)
  end

  __Arguments__ { Number, Number, Argument(Boolean, true, true, "saveInDB")}
  function SetPosition(self, x, y, saveInDB)
    --self.frame:ClearAllPoints()
    --self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
    self:ClearAllPoints()
    self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
    if saveInDB then
      Options:Set("tracker-xPos", x, false)
      Options:Set("tracker-yPos", y, false)
    end
  end


  function SetScrollbarVisible(self, visible)
    --self.scrollFrame:ClearAllPoints()
    self.scrollFrame:SetPoint("TOP")
    self.scrollFrame:SetPoint("LEFT")
    self.scrollFrame:SetPoint("BOTTOM")

    if visible then
      self.scrollbar:Show()
      self.scrollFrame:SetPoint("RIGHT", self.scrollbar, "LEFT")
    else
      self.scrollbar:Hide()
      self.scrollFrame:SetPoint("RIGHT")
    end

    -- Update the content size
    self.content:SetWidth(self.scrollFrame:GetWidth())
  end


  function UpdateScrollbarVisibility(self)
    -- check if the scrollbar is needed or not
    local parentHeight = self.scrollFrame:GetHeight()
    local isNeeded = self.contentHeight >= parentHeight
    if isNeeded and Options:Get("tracker-show-scrollbar") then
      self:SetScrollbarVisible(true)
    else
      self:SetScrollbarVisible(false)
    end
  end

  __Arguments__ { Argument(Theme.SkinFlags, true, Theme.SkinFlags.ALL), Argument(Boolean, true, true) }
  function Refresh(self, skinFlags, callSuper)
    Theme:SkinFrame(self.frame, nil, nil, skinFlags)
    Theme:SkinFrame(self.scrollbar, nil, nil, skinFlags)
    Theme:SkinTexture(self.scrollbar.thumb, nil, skinFlags)
    self:ExtraSkinFeatures()
  end

  __Arguments__ { Argument(Theme.SkinFlags, true, Theme.SkinFlags.ALL) }
  __Static__() function RefreshAll(skinFlags)
    if _Obj then
      _Obj:Refresh(skinFlags)
    end
  end

  function RegisterFramesForThemeAPI(self)
    Theme:RegisterFrame("tracker.frame", self.frame)
    Theme:RegisterFrame("tracker.scrollbar", self.scrollbar)
    Theme:RegisterTexture("tracker.scrollbar.thumb", self.scrollbar.thumb)
  end

  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "contentHeight" { TYPE = Number, DEFAULT = 50, HANDLER = SetContentHeight }
  property "tID" { DEFAULT = "tracker" }
  __Static__() property "_prefix" { DEFAULT = "tracker" }

  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function ObjectiveTracker(self)
    Super(self)

    self:SetSize(Options:Get("tracker-width"), Options:Get("tracker-height"))
    self:SetParent(UIParent)
    self.frame = CreateFrame("Frame", "EQT-TrackerFrame")
    self.frame:SetBackdrop(_Backdrops.Common)
    self.frame:SetBackdropColor(0, 1, 0, 0)
    self.frame:SetBackdropBorderColor(0, 0, 0, 0)
    self:GetFrameContainer():SetClampedToScreen(true)

    -- Restore the position contained in the DB if exists
    if Options:Exists("tracker-xPos") and Options:Exists("tracker-yPos") then
      self:SetPosition(Options:Get("tracker-xPos"), Options:Get("tracker-yPos"), false)
    else
      self:SetPoint("CENTER")
    end
    self:SetLocked(Options:Get("tracker-locked"))

    -- Drag and move functions
    self:GetFrameContainer():SetScript("OnMouseDown", _Addon.ObjectiveTrackerMouseDown)
    self:GetFrameContainer():SetScript("OnMouseUp", _Addon.ObjectiveTrackerMouseUp)

    local scrollFrame = CreateFrame("ScrollFrame", "EQT-ObjectiveTrackerFrameScrollFrame", self.frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOP")
    scrollFrame:SetPoint("LEFT")
    scrollFrame:SetPoint("RIGHT")
    scrollFrame:SetPoint("BOTTOM")
    scrollFrame:SetBackdrop(_Backdrops.Common)
    scrollFrame:SetBackdropColor(1, 1, 0, 0)
    scrollFrame:SetBackdropBorderColor(0, 0, 0, 0)
    scrollFrame:SetScript("OnScrollRangeChanged", ObjectiveTracker_OnScrollRangeChanged)

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
    scrollbar:SetBackdrop(_Backdrops.Common)
    scrollbar:ClearAllPoints()
    scrollbar:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT")
    scrollbar:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT")
    -- customize the scroll bar thumb
    local thumb = scrollbar:GetThumbTexture()
    thumb:SetTexture(_Backdrops.Common.bgFile)
    thumb:SetHeight(40)
    thumb:SetWidth(8)

    local content = CreateFrame("Frame", "EQT-ObjectiveTrackerFrameContent")
    --content:SetBackdrop(_Backdrops.Common)

    --content:SetBackdropBorderColor(0, 0, 0, 0)
    --content:SetBackdropColor(1, 0, 0, 1)
    scrollFrame:SetScrollChild(content)
    --content:SetBackdropColor(0, 1, 1, 1)
    content:SetParent(scrollFrame)
    content:SetPoint("LEFT")
    content:SetPoint("RIGHT")
    content:SetPoint("TOP")
    content:SetHeight(self.contentHeight)

    self.content = content
    self.scrollFrame = scrollFrame
    self.scrollbar = scrollbar
    self.scrollbar.thumb = thumb

    This.RegisterFramesForThemeAPI(self)
    self:Refresh()

    _Obj = self

    function self:OnWidthChanged(new, old)
      self:UpdateScrollbarVisibility()
      Scorpio.FireSystemEvent("EQT_CONTENT_SIZE_CHANGED")
    end

    -- OnHeightChanged event hander
    function self:OnHeightChanged(new, old)
      self:GetFrameContainer():SetHeight(new)

      -- Update the scroll bar visibility
      self:UpdateScrollbarVisibility()
    end

    -- OnBorderWidthChanged
    function self:OnBorderWidthChanged()
      self:UpdateScrollbarVisibility()

      Scorpio.FireSystemEvent("EQT_CONTENT_SIZE_CHANGED")
    end
  end

endclass "ObjectiveTracker"

function OnLoad(self)
  -- Options
  Options:Register("tracker-height", 300, "tracker/setHeight")
  Options:Register("tracker-width", 325, "tracker/setWidth")
  Options:Register("tracker-locked", false, "tracker/setLocked")
  Options:Register("tracker-show-scrollbar", true, "tracker/showScrollbar")

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
  CallbackHandlers:Register("tracker/showScrollbar", CallbackObjectHandler(tracker, ObjectiveTracker.UpdateScrollbarVisibility))
end
-- frame:SetClipsChildren(true) TODO: Replace Frame:MustBeInteractive by that
