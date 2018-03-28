--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio                   "EskaQuestTracker.Classes.Objective"                ""
--============================================================================--
namespace "EQT"
--============================================================================--
-- TODO: Timer: Add the options related to it
-- TODO: Timer: Add the states: (<10%, <25%, <50%, normal)
-- TODO: Progress Bar: Add the options
-- TODO: Progress Bar Text: Add the options
-- XXX: Check Timer
-- NOTE: Some objectives (very rarely) have an incorrect height.
class "Objective" inherit "Frame" extend "IReusable"
  _ObjectiveCache = setmetatable({}, { __mode = "k"})

  local function CreateStatusBar(self)
    local bar = CreateFrame("StatusBar", nil, self.frame)
    bar:SetStatusBarTexture(_Backdrops.Common.bgFile)
    bar:SetStatusBarColor(0, 148/255, 1, 0.6)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0.6)

    local text = bar:CreateFontString(nil, "OVERLAY", GameFontHighlightSmall)
    local color = { r = 0, g = 148 / 255, b = 255 / 255 }
    local font = _LibSharedMedia:Fetch("font", "PT Sans Bold Italic")

    text:SetTextColor(1, 1, 1, 1)
    text:SetAllPoints()
    text:SetFont(font, 13) -- 9
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")
    bar.text = text

    local bgFrame = CreateFrame("Frame", nil, bar)
    bgFrame:SetPoint("TOPLEFT", -2, 2)
    bgFrame:SetPoint("BOTTOMRIGHT", 2, -2)
    bgFrame:SetFrameLevel(bgFrame:GetFrameLevel() - 1)

    bgFrame.background = bgFrame:CreateTexture(nil, "BACKGROUND")
    bgFrame.background:SetAllPoints(bgFrame)
    bgFrame.background:SetTexture([[Interface\AddOns\EskaQuestTracker\Media\Textures\Frame-Background-6]])
    bgFrame.background:SetVertexColor(0, 0, 0, 0.5)

    local borderB = bgFrame:CreateTexture(nil,"OVERLAY")
    borderB:SetColorTexture(0,0,0)
    borderB:SetPoint("BOTTOMLEFT")
    borderB:SetPoint("BOTTOMRIGHT")
    borderB:SetHeight(3)

    local borderT = bgFrame:CreateTexture(nil,"OVERLAY")
    borderT:SetColorTexture(0,0,0)
    borderT:SetPoint("TOPLEFT")
    borderT:SetPoint("TOPRIGHT")
    borderT:SetHeight(3)

    local borderL = bgFrame:CreateTexture(nil,"OVERLAY")
    borderL:SetColorTexture(0,0,0)
    borderL:SetPoint("TOPLEFT")
    borderL:SetPoint("BOTTOMLEFT")
    borderL:SetWidth(3)

    local borderR = bgFrame:CreateTexture(nil,"OVERLAY")
    borderR:SetColorTexture(0,0,0)
    borderR:SetPoint("TOPRIGHT")
    borderR:SetPoint("BOTTOMRIGHT")
    borderR:SetWidth(3)


    return bar
  end
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  -- Theme:SkinBackdrop
  -- Theme:SkinBorder
  -- Theme:RegisterFrame
  -- Theme:RegisterText
  -- Theme:Register
  -- Theme:SkinText()
  local function UpdateProps(self, new, old, prop)
    local state = self:GetCurrentState()
    if prop == "failed" then
      self:Refresh()
    end
  end

  local function SetText(self, new)
    Theme:NewSkinText(self.frame.text, Theme.SkinTextFlags.TEXT_TRANSFORM, new, self.isCompleted and "completed" or "progress")
    self:CalculateHeight()
  end

  local function SetCompleted(self, new)
    self:Refresh() -- When a state has changed, refresh all frame part
  end

  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  function ShowTimer(self)
      if not self.frame.timer then
        local timer = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        timer:SetText("14:35")
        timer:SetPoint("TOP", self.frame.text, "BOTTOM", 0, -5)
        timer:SetFont(timer:GetFont(), 18, "OUTLINE")
        timer:SetHeight(18)
        self.frame.timer = timer
      end

      self.frame.timer:Show()
      self:CalculateHeight()
  end

  function HasTimer(self)
    if self.frame.timer and self.frame.timer:IsShown() then
      return true
    else
      return false
    end
  end

  function HideTimer(self)
      if self.frame.timer then
        self.frame.timer:Hide()
      end
      self:CalculateHeight()
  end

  function SetTimer(self, duration, elapsed)
		local remainingDuration = duration - elapsed
		local remainingDurationPercent = remainingDuration * 100 / duration

		if remainingDurationPercent < 10 then
			self.frame.timer:SetTextColor(1, 0, 0)
		elseif remainingDurationPercent < 25 then
			self.frame.timer:SetTextColor(1, 106/255, 0)
		elseif remainingDurationPercent < 50 then
			self.frame.timer:SetTextColor(1, 216/255, 0)
		else
			self.frame.timer:SetTextColor(1, 1, 1)
		end

		self.frame.timer:SetText(GetTimeStringFromSeconds(remainingDuration, false, true))
	end

  function ShowProgress(self)
    if not self.frame.fbar then
      local fbar = CreateStatusBar(self)
      fbar:SetHeight(18)
      fbar:SetPoint("TOPLEFT", self.frame.text, "BOTTOMLEFT", 0, -4)
      fbar:SetPoint("TOPRIGHT", self.frame.text, "BOTTOMRIGHT", -35, 0) -- 25
      self.frame.fbar = fbar
    end

    self.frame.fbar:Show()
    self:CalculateHeight()
  end

  function HasProgress(self)
    if self.frame.fbar and self.frame.fbar:IsShown() then
      return true
    else
      return false
    end
  end

  function HideProgress(self)
    if self.frame.fbar then
      self.frame.fbar:Hide()
    end
    self:CalculateHeight()
  end

  __Arguments__{ String }
	function SetTextProgress(self, text)
		if self.frame.fbar then
			self.frame.fbar.text:SetText(text)
		end
	end

	__Arguments__{ Number }
	function SetProgress(self, progress)
		if self.frame.fbar then
			self.frame.fbar:SetValue(progress)
		end
	end

	__Arguments__{ Number, Number }
	function SetMinMaxProgress(self, min, max)
		if self.frame.fbar then
			self.frame.fbar:SetMinMaxValues(min, max)
		end
	end

  function GetCurrentState(self)
      if self.failed then
        return "failed"
      end

      if self.isCompleted then
        return "completed"
      end

      return "progress"
  end

  function CalculateHeight(self)
    local height = self.baseHeight

    self.frame.text:SetHeight(0) -- important ! This is needed

    --[[local textHeight = API:CalculateTextHeight(self.frame.text)
    print("textHeight", textHeight, self.text)
    if self.textHeight == 0 then
      self.textHeight = textHeight
    elseif self.textHeight > textHeight then
      textHeight = self.textHeight
    end--]]
    local textHeight = self.frame.text:GetHeight()

    local diff = (textHeight + 4) - self.baseHeight
    if diff < 0 then diff = 0 end
      height = height + diff

    -- if the objective has a progress
    if self:HasProgress() then
      height = height + 26
    end

    -- if the objective has a timer
    if self:HasTimer() then
      height = height + 23
    end

    self.height = height
  end

  __Arguments__  { Variable.Optional(Theme.SkinInfo, Theme.SkinInfo()) }
  function Refresh(self, skinFlags)
    self:SkinFeatures()

    self:CalculateHeight()
  end


  __Arguments__ { Variable.Optional(Theme.SkinInfo, Theme.SkinInfo()), Variable.Optional(Boolean, true) }
  function SkinFeatures(self, info)
    -- Call the parent if the object is already init.
    if alreadyInit then
      super.SkinFeatures(self, info)
    end

    local state = self:GetCurrentState()
    Theme:NewSkinFrame(self.frame, info, state)
    Theme:NewSkinFrame(self.frame.square, info, state)

    Theme:NewSkinText(self.frame.text, info, self.text, state)
  end


  __Arguments__ { Variable.Optional(Theme.SkinInfo, Theme.SKIN_INFO_ALL_FLAGS) }
  __Static__() function RefreshAll(skinInfo)
    for obj in pairs(_ObjectiveCache) do
      obj:Refresh(skinInfo)
    end
  end

  function Reset(self)
    self.text = nil
    self.type = nil
    self.isCompleted = nil

    self:ClearAllPoints()
    self:SetParent()
    self:Hide()
    self:HideProgress()
    self:HideTimer()
  end

  function RegisterFramesForThemeAPI(self)
		local classPrefix = "objective"

		Theme:RegisterFrame(classPrefix..".frame", self.frame)
		Theme:RegisterFrame(classPrefix..".square", self.frame.square)
	end

  __Static__() function UpdateSize()
    for obj in pairs(_ObjectiveCache) do
      obj:CalculateHeight()
    end
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "text" { TYPE = String, DEFAULT = "", HANDLER = SetText }
  property "type" { TYPE = String, DEFAULT = ""}
  property "isCompleted" { TYPE = Boolean, DEFAULT = false, HANDLER = SetCompleted }
  property "failed" { TYPE = Boolean, DEFAULT = false, HANDLER = UpdateProps }
  __Static__() property "_prefix" { DEFAULT = "objective"}
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Objective(self)
    super(self)

    self.frame = CreateFrame("Frame")
    self.frame:SetBackdrop(_Backdrops.Common)
    self.frame:SetBackdropColor(0.1, 1, 0.1, 0)
    self.frame:SetBackdropBorderColor(0, 0, 0, 0)

    local square = CreateFrame("Frame", nil, self.frame)
    square:SetBackdrop(_Backdrops.Common)
    square:SetPoint("TOP", 0, -4)
    square:SetPoint("LEFT", 10, 0)
    square:SetWidth(12)
    square:SetHeight(12)
    square:SetBackdropBorderColor(0, 0, 0)
    self.frame.square = square

    local text = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", 27, 0)
    text:SetPoint("RIGHT")
    text:SetPoint("TOP", 0, -4)
    text:SetJustifyH("LEFT")
    text:SetWordWrap(true)
    text:SetNonSpaceWrap(false)
    self.frame.text = text

    self.baseHeight = 20 -- 16
    self.height = self.baseHeight

    -- Keep it in the cache for later.
    _ObjectiveCache[self] = true
    -- Important: Always use 'This' to avoid issues when this class is inherited by
    -- other classes.
    RegisterFramesForThemeAPI(self)
    -- Important: Don't forgot 'This' as argument to this method !
    self:InitRefresh(Objective)
  end
endclass "Objective"

  class "DottedObjective" inherit "Frame" extend "IReusable"
  	_DottedObjectiveCache = setmetatable( {}, { __mode = "k"})
  	function DottedObjective(self)
  		super(self)

  		local frame = CreateFrame("Frame")
  		frame:SetHeight(8)

  		local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  		text:SetFont(text:GetFont(), 18)
  		text:SetText("...")
  		text:SetAllPoints()
  		text:SetJustifyH("CENTER")
  		text:SetJustifyV("BOTTOM")

  		frame.text = text

  		self.frame = frame
  		self.height = 8
  		self.baseHeight = self.height

  		_DottedObjectiveCache[self] = true
  	end

  	function Reset(self)
  		self:ClearAllPoints()
  		self:SetParent(nil)
  		self:Hide()
  	end
  endclass "DottedObjective"

  --============================================================================--
  -- OnLoad Handler
  --============================================================================--
  function OnLoad(self)
  	-- Register this class in the object manager
  	_ObjectManager:Register(Objective)
  	_ObjectManager:Register(DottedObjective)

  	-- Register the refresher
  	CallbackHandlers:Register("objective/refresher", CallbackHandler(Objective.RefreshAll), "refresher")
  end


  __SystemEvent__()
  function EQT_CONTENT_SIZE_CHANGED()
    Objective.UpdateSize()
  end

  __SystemEvent__()
  function EQT_SCROLLBAR_VISIBILITY_CHANDED()
    Objective.UpdateSize()
  end
