--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio             "EskaQuestTracker.Classes.Scenario"                       ""
--============================================================================--
namespace "EQT"
--============================================================================--
class "Scenario" inherit "Block" extend "IObjectiveHolder"
  _ScenarioCache = setmetatable( {}, { __mode = "k" } )
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function UpdateProps(self, new, old, prop)
    if prop == "name" then
      print("Set Name", new, old)
      Theme.SkinText(self.frame.name, new)
    elseif prop == "currentStage" or prop == "numStages" then
      Theme.SkinText(self.frame.stageCounter, string.format("%i/%i", self.currentStage, self.numStages))
    elseif prop == "stageName" then
      Theme.SkinText(self.frame.stageName, new)
    end
  end
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  __Arguments__{ Argument(Boolean, true, true)}
  function Refresh(self, callSuper)
    if callSuper then
      Super.Refresh(self)
    end
    Theme.SkinFrame(self.frame.stage)

    -- Text
    Theme.SkinText(self.frame.name, self.name)
    Theme.SkinText(self.frame.stageName, self.stageName)
    Theme.SkinText(self.frame.stageCounter, string.format("%i/%i", self.currentStage, self.numStages))
  end

  function GetBonusObjective(self, index)

  end

  __Arguments__ {}
  function Draw(self)
    local stage = self.frame.stage
    self:DrawObjectives(stage)
  end

  __Arguments__ {}
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

  __Arguments__ {}
  function RegisterFramesForThemeAPI(self)
    Theme.RegisterFrame(self.tID..".stage", self.frame.stage)
    -- Text
    Theme.RegisterText(self.tID..".name", self.frame.name)
    Theme.RegisterText(self.tID..".stageName", self.frame.stageName)
    Theme.RegisterText(self.tID..".stageCounter", self.frame.stageCounter)
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "name" { TYPE = Stirng, DEFAULT = "", HANDLER = UpdateProps}
  property "currentStage" { TYPE = Number, DEFAULT = 1, HANDLER = UpdateProps }
  property "numStages" { TYPE = Number, DEFAULT = 1, HANDLER = UpdateProps }
  property "stageName" { TYPE = String, DEFAULT = "", HANDLER = UpdateProps }
  property "numBonusObjectives" { TYPE = Number, DEFAULT = 0 }
  -- Theme
  property "tID" { DEFAULT = "block.scenario"}
  __Static__() property "_THEME_CLASS_ID" { DEFAULT = "block.scenario" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Scenario(self)
    Super(self, "scenario", 10)
    self.text = "Scenario"

    local header = self.frame.header
    local headerText = header.text

    -- Scenario name
    local name = header:CreateFontString(nil, "OVERLAY")
    name:SetPoint("TOPRIGHT")
    name:SetPoint("BOTTOMLEFT")
    -- name:SetPoint("LEFT", headerText, "RIGHT")
    name:SetJustifyH("CENTER")
    self.frame.name = name

    -- Set the headerText to Left
    --headerText:SetPoint("LEFT")
    --headerText:SetPoint("LEFT")
    --headerText:SetJustifyH("LEFT")
    --headerText:SetWidth(75)

    -- Stage frame
    local stage = CreateFrame("Frame", nil, self.frame)
    stage:SetPoint("TOPLEFT", header, "BOTTOMLEFT")
    stage:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT")
    stage:SetBackdrop(_Backdrops.Common)
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

    -- Important : Always use 'This' to avoid issues when this class is inherited
    -- by other classes.
    This.RegisterFramesForThemeAPI(self)
    -- Here the false boolean say to refresh function to not call the refresh super function
    -- because it's already done by the super constructor
    This.Refresh(self, false)

    _ScenarioCache[self] = true

  end

  __Static__()
  function InstallOptions(self, child)
    local class = child or self
    local prefix = class._THEME_CLASS_ID and class._THEME_CLASS_ID or ""
    local superClass = System.Reflector.GetSuperClass(self)
    if superClass.InstallOptions then
      superClass:InstallOptions(class)
    end

    Options.AddAvailableThemeKeywords(
      Options.ThemeKeyword(prefix..".stage", Options.ThemeKeywordType.FRAME),
      Options.ThemeKeyword(prefix..".name", Options.ThemeKeywordType.TEXT),
      Options.ThemeKeyword(prefix..".stageName", Options.ThemeKeywordType.TEXT),
      Options.ThemeKeyword(prefix..".stageCounter", Options.ThemeKeywordType.TEXT)
    )
  end
endclass "Scenario"
Scenario:InstallOptions()
