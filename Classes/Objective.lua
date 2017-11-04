--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio                "EskaQuestTracker.Classes.Objective"              			""
--============================================================================--
namespace "EQT"                                                               --                                                           --
--============================================================================--
class "Objective" inherit "Frame" extend "IReusable"

	_ObjectiveCache = setmetatable( {}, { __mode = "k" } )

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

	local function CreateTimerText(self)
		local timer = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		timer:SetText("14:30")
		timer:SetPoint("LEFT", affixes, "RIGHT")
		timer:SetPoint("RIGHT", self.frame.header, "RIGHT")
		timer:SetFont(timer:GetFont(), 18, "OUTLINE")
		return timer
	end
	------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  function SetQuest(self, quest)
    self.quest = quest
  end


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
		self.height = self.baseHeight + 23
	end

	function HideTimer(self)
		if self.frame.timer then
			self.frame.timer:Hide()
		end
		self.height = self.baseHeight
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

	__Arguments__{}
  function ShowProgress(self)
		if not self.frame.fbar then
			local fbar = CreateStatusBar(self)
			fbar:SetHeight(18)
			fbar:SetPoint("TOPLEFT", self.frame.text, "BOTTOMLEFT", 0, -4)
			fbar:SetPoint("TOPRIGHT", self.frame.text, "BOTTOMRIGHT", -35, 0) -- 25
			self.frame.fbar = fbar
		end

		self.frame.fbar:Show()


		self.height = self.baseHeight + 22
  end

  function HideProgress(self)
		if self.frame.fbar then
			self.frame.fbar:Hide()
		end
		self.height = self.baseHeight
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

	__Arguments__ { Argument(Theme.SkinFlags, true, 127)}
	function Refresh(self, skinFlags)
		local state = self.isCompleted and "completed" or "progress"

		Theme:SkinFrame(self.frame, nil, state, skinFlags)
		Theme:SkinFrame(self.frame.square, nil, state, skinFlags)

		-- @HACK Fix to position
		self.frame.text:ClearAllPoints()
		self.frame.text:SetPoint("TOPLEFT", self.frame.square, "TOPRIGHT", 5, 0)
		self.frame.text:SetPoint("RIGHT")
	end


	__Arguments__ { Argument(Theme.SkinFlags, true, 127) }
	__Static__() function RefreshAll(skinFlags)
		for obj in pairs(_ObjectiveCache) do
			obj:Refresh(skinFlags)
		end
	end

	function Reset(self)
		self.text = nil
		self.type = nil
		self.isCompleted = nil

		self:ClearAllPoints()
		self:SetParent(nil)
		self:Hide()
		self:HideProgress()
		self:HideTimer()
	end
	------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
	local function SetText(self, new, old, prop)
		Theme:SkinText(self.frame.text, new, self.isCompleted and "completed" or "progress")
	end

	local function SetCompleted(self, new, old, prop)
		local state = new and "completed" or "progress"
		Theme:SkinFrame(self.frame, self.text, state)
		Theme:SkinFrame(self.frame.square, nil, state)
	end

	function RegisterFramesForThemeAPI(self)
		local classPrefix = "objective"

		Theme:RegisterFrame(classPrefix..".frame", self.frame)
		Theme:RegisterFrame(classPrefix..".square", self.frame.square)
	end
	------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
	property "text" { TYPE = String, DEFAULT = "DEFAULT", HANDLER = SetText }
	property "type" { TYPE = String, DEFAULT = "" }
	property "isCompleted" { TYPE = Boolean, DEFAULT = false, HANDLER = SetCompleted}

	-- the font color used when the objective has been completed
	__Static__() property "fontColorCompleted" {
		Set = function(self, color)
			_DB.Objective.colors.completed = color ; Objective:RefreshAll()
		end,
		Get = function(self) return _DB.Objective.colors.completed end,
	}
	-- the font color used when the objective is in progress
	__Static__() property "fontColorInProgress" {
		Set = function(self, color)
			_DB.Objective.colors.inProgress = color ; Objective:RefreshAll()
		end,
		Get = function(self) return _DB.Objective.colors.inProgress end,
	}

	__Static__() property "_prefix" { DEFAULT = "objective" }
	------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Objective(self)
		Super(self)

    local frame = CreateFrame("Frame")
    frame:SetBackdrop(_Backdrops.Common)
    frame:SetBackdropColor(0.1, 1, 0.1, 0)
    frame:SetBackdropBorderColor(0, 0, 0, 0)

    local square = CreateFrame("Frame", nil, frame)
    square:SetBackdrop(_Backdrops.Common)
    square:SetWidth(12) -- 8
    square:SetHeight(12) -- 8
    square:SetPoint("TOPLEFT", 10, -4)
    square:SetBackdropBorderColor(0, 0, 0)
    frame.square = square

    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		--local font = _LibSharedMedia:Fetch("font", "PT Sans Narrow Bold")

    text:SetPoint("TOPLEFT", square, "TOPRIGHT", 5, 0)
    text:SetPoint("TOPRIGHT")
    --text:SetFont(font, 13, "OUTLINE") -- 9
    text:SetJustifyH("LEFT")
    text:SetHeight(12) -- 10

    frame.text = text


		self.frame = frame
		self.height = 24
		self.baseHeight = self.height

		self:RegisterFramesForThemeAPI()

		self:Refresh()

		_ObjectiveCache[self] = true
  end
endclass "Objective"

class "DottedObjective" inherit "Frame" extend "IReusable"
	_DottedObjectiveCache = setmetatable( {}, { __mode = "k"})
	function DottedObjective(self)
		Super(self)

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
