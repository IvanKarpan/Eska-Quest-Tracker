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


	function Refresh(self)
		local state = self.isCompleted and "completed" or "progress"

		Theme.SkinFrame(self.frame, nil, state)
		Theme.SkinFrame(self.frame.square, nil, state)


		-- @HACK Fix to position
		self.frame.text:ClearAllPoints()
		self.frame.text:SetPoint("TOPLEFT", self.frame.square, "TOPRIGHT", 5, 0)
		self.frame.text:SetPoint("RIGHT")
	end

	--[[
	function Refresh(self, ...)
		local theme = _CURRENT_THEME
		local color, font, size, transform
		if self.isCompleted then
			color     = theme:GetProperty("objective.text[completed]", "text-color")
			font      = _LibSharedMedia:Fetch("font", theme:GetProperty("objective.text[completed]", "text-font"))
			size      = theme:GetProperty("objective.text[completed]", "text-size")
			transform = theme:GetProperty("objective.text[completed]", "text-transform")

		else
			color     = theme:GetProperty("objective.text[inprogress]", "text-color")
			font      = _LibSharedMedia:Fetch("font", theme:GetProperty("objective.text[inprogress]", "text-font"))
			size      = theme:GetProperty("objective.text[inprogress]", "text-size")
			transform = theme:GetProperty("objective.text[inprogress]", "text-transform")
		end
		self.frame.square:SetBackdropColor(color.r, color.g, color.b)
		self.frame.text:SetTextColor(color.r, color.g, color.b)

		--local font = _LibSharedMedia:Fetch("font", Objective.textFont)
		--local size = Objective.textSize
		--local transform = Objective.textTransform

		self.frame.text:SetFont(font, size, "OUTLINE")

		local txt = self.text
		if transform == "uppercase" then
			txt = txt:upper()
		elseif transform == "lowercase" then
			txt = txt:lower()
		end

		self.frame.text:SetText(txt)
	end--]]



	__Static__() function RefreshAll()
		for obj in pairs(_ObjectiveCache) do
			obj:Refresh()
			--print("RefreshAlll")
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
		-- self.frame.text:SetText(new)
		Theme.SkinText(self.frame.text, new, self.isCompleted and "completed" or "progress")
	end

	local function SetCompleted(self, new, old, prop)
		if new then
			--self.frame.square:SetBackdropColor(0, 1, 0)
			--self.frame.text:SetTextColor(0, 1, 0)

		else
			--self.frame.square:SetBackdropColor(0.5, 0.5, 0.5)
			--self.frame.text:SetTextColor(148/255, 148/255, 148/255)
		end

		local state = new and "completed" or "progress"
		Theme.SkinFrame(self.frame, self.text, state)
		Theme.SkinFrame(self.frame.square, nil, state)
	end

	function RegisterFramesForThemeAPI(self)
		local classPrefix = "objective"

		Theme.RegisterFrame(classPrefix, self.frame)
		Theme.RegisterFrame(classPrefix..".square", self.frame.square)
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

	-- Say to option the keyword available
	Options.AddAvailableThemeKeywords(
		-- Global
		-- Options.ThemeKeyword("objective", Options.ThemeKeywordType.FRAME + Options.ThemeKeywordType.TEXT),
		-- Completed objectives
		Options.ThemeKeyword("objective[@completed]", Options.ThemeKeywordType.FRAME + Options.ThemeKeywordType.TEXT),
		Options.ThemeKeyword("objective.square[@completed]", Options.ThemeKeywordType.FRAME, "00ff00"),
		-- progress objective
		Options.ThemeKeyword("objective[@progress]", Options.ThemeKeywordType.FRAME + Options.ThemeKeywordType.TEXT),
		Options.ThemeKeyword("objective.square[@progress]", Options.ThemeKeywordType.FRAME, "808080")
	)
endclass "Objective"
Theme.RegisterRefreshHandler("objective", Objective.RefreshAll)

--============================================================================--
-- OnLoad Handler
--============================================================================--
function OnLoad(self)
	--[[_DB:SetDefault("Objective", {
		colors = {
			completed = { r = 0, g = 1, b = 0},
			inProgress = { r = 148/255, g = 148/255, b = 148/255 }
		},
		textSize = 13,
		textFont = "PT Sans Narrow Bold",
		textTransform = "none",
	})--]]

	-- Register this class in the object manager
	_ObjectManager:Register(Objective)
end
