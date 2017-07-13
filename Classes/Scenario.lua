-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio             "EskaQuestTracker.Classes.Scenario"                       ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
__DBTextOptions__( function() return _DB.Scenario end)
__InitChildBlockDB__()
class "Scenario" inherit "Block" extend "IObjectiveHolder"
  _ScenarioCache = setmetatable( {}, { __mode = "k" } )
  -- [DBElement] => [IndexFrame]
  _Elements = { ["name"] = "name", ["stageName"] = "stageName", ["stageCounter"] = "stageCounter"}
  -- ======================================================================== --
  -- Handlers
  -- ======================================================================== --
  local function SetName(self, new)
    local transform = Scenario:GetTextTransform("name")
    local txt = new
    if transform == "uppercase" then
      txt = txt:upper()
    elseif transform == "lowercase" then
      txt = txt:lower()
    end
    self.frame.name:SetText(txt)
  end

  local function SetStageName(self, new)
    self.frame.stageName:SetText(new)
  end

  local function SetCurrentStage(self, new)
    local txt = string.format("%i/%i", self.currentStage, self.numStages)
    self.frame.stageCounter:SetText(txt)
  end
  -- ======================================================================== --
  -- Methods                                                                  --
  -- ======================================================================== --
  --[[
  function Refresh(self)
    Super.Refresh(self)

    for elementDBName, elementFrameIndex in pairs(_Elements) do
      local elementFrame = self.frame[elementFrameIndex]

      local font = _LibSharedMedia:Fetch("font", Scenario:GetTextFont(elementDBName))
      local size = Scenario:GetTextSize(elementDBName)
      local color = Scenario:GetTextColor(elementDBName)
      local transform = Scenario:GetTextTransform(elementDBName)

      elementFrame:SetFont(font, size, "OUTLINE")
      elementFrame:SetTextColor(color.r, color.g, color.b)

      local txt = ""
      if elementFrameIndex == "name" then txt = self.name
      elseif elementFrameIndex == "stageName" then txt = self.stageName
      elseif elementFrameIndex == "stageCounter" then txt = string.format("%i/%i", self.currentStage, self.numStages) end

      if transform == "uppercase" then
        txt = txt:upper()
      elseif transform == "lowercase" then
        txt = txt:lower()
      end

      elementFrame:SetText(txt)
    end

  end
  --]]
  function Refresh(self)
    -- Frame
    Theme.SkinFrame(self.frame)

    -- Text
    Theme.SkinText(self.frame.name)
    Theme.SkinText(self.frame.stageName)
    Theme.SkinText(self.frame.stageCounter)
  end



  function GetBonusObjective(self, index)

  end

  __Arguments__{}
  function Draw(self)
    local stage = self.frame.stage
    self:DrawObjectives(stage)
  end

  function Reset(self)
    self.name = nil
    self.currentStage = nil
    self.numStages = nil
    self.stageName = nil
    self.numObjectives = nil
  end

  __Static__() function RefreshAll()
    for obj in pairs(_ScenarioCache) do
      obj:Refresh()
    end
  end

  __Arguments__{}
  function RegisterFramesForThemeAPI(self)
    -- local classPrefix = "block." .. self.id

    Theme.RegisterFrame(self.tID, self.frame)

    Theme.RegisterText(self.tID..".name", self.frame.name)
    Theme.RegisterText(self.tID..".stageName", self.frame.stageName)
    Theme.RegisterText(self.tID..".stageCounter", self.frame.stageCounter)
  end
  -- ======================================================================== --
  -- Properties
  -- ======================================================================== --
  property "name" { TYPE = Stirng, DEFAULT = "", HANDLER = SetName}
  property "currentStage" { TYPE = Number, DEFAULT = 1, HANDLER = SetCurrentStage }
  property "numStages" { TYPE = Number, DEFAULT = 1, HANDLER = SetCurrentStage }
  property "stageName" { TYPE = String, DEFAULT = "", HANDLER = SetStageName }
  property "text" { TYPE = String, DEFAULT = "Scenario", HANDLER = "SetText"}

  property "numBonusObjectives" { TYPE = Number, DEFAULT = 0 }

  -- Theme
  property "tID" { DEFAULT = "block.scenario"}
  -- ======================================================================== --
  -- Constructor
  -- ======================================================================== --
  function Scenario(self)
    Super(self, "scenario", 10)
    self.text = "Scenario"

    local header = self.frame.header
    local headerText = header.text

    self.frame:SetBackdropColor(0, 0, 0, 0.3) -- 0.3

    -- Scenario name
    local name = header:CreateFontString(nil, "OVERLAY")
    name:SetPoint("TOPRIGHT")
    name:SetPoint("BOTTOMLEFT")
    name:SetPoint("LEFT", headerText, "RIGHT")
    name:SetJustifyH("CENTER")
    self.frame.name = name

    -- Set the headerText to Left
    headerText:SetPoint("LEFT")
    headerText:SetPoint("LEFT")
    headerText:SetJustifyH("LEFT")
    headerText:SetWidth(75)

    -- Stage frame
    local stage = CreateFrame("Frame", nil, self.frame)
    stage:SetPoint("TOPLEFT", header, "BOTTOMLEFT")
    stage:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT")
    stage:SetBackdrop(_Backdrops.Common)
    stage:SetBackdropBorderColor(0, 0, 0, 0.4)
    stage:SetBackdropColor(0, 0, 0, 0.4)
    stage:SetHeight(22) -- 22
    self.frame.stage = stage

    -- Stage counter
    local stageCounter = stage:CreateFontString(nil, "OVERLAY")
    stageCounter:SetPoint("TOPLEFT")
    stageCounter:SetPoint("BOTTOMLEFT")
    stageCounter:SetWidth(50)
    self.frame.stageCounter = stageCounter

    -- Stage name
    local stageName = stage:CreateFontString(nil, "OVERLAY")
    stageName:SetPoint("TOPRIGHT")
    stageName:SetPoint("TOPLEFT", stageCounter, "TOPRIGHT")
    stageName:SetPoint("BOTTOMRIGHT")
    stageName:SetPoint("BOTTOMLEFT", stageCounter, "BOTTOMRIGHT")
    self.frame.stageName = stageName

    self.height = self.height + stage:GetHeight()
    self.baseHeight = self.height

    This.RegisterFramesForThemeAPI(self)
    self:Refresh()

    _ScenarioCache[self] = true

  end
endclass "Scenario"
-- Register it in the Theme system.
Theme:_RegisterClass(Scenario._tid, Scenario)
-- ========================================================================== --
-- == OnLoad Handler
-- ========================================================================== --
function OnLoad(self)
  _DB:SetDefault("Scenario", {
    textSizes = {
      name = 13,
      stageName = 11,
      stageCounter = 12,
    },
    textFonts = {
      name = "PT Sans Bold",
      stageName = "PT Sans Bold",
      stageCounter = "PT Sans Narrow Bold"
    },
    textTransforms = {
      name = "uppercase",
      stageName = "none",
      stageCounter = "none",
    },
    textColors = {
      name = { r = 1, g = 0.5, b = 0 },
      stageName = { r = 1, g = 1, b = 0 },
      stageCounter = { r = 1, g = 1, b = 1 }
    }
  })

  -- @HACK This is a temporary fix in waiting to release the theme API
  Scenario.customConfigEnabled = true
  Scenario:SetBlockPropertyValue("headerTextLocation", "LEFT")
end
