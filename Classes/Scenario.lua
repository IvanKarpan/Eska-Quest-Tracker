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
      Theme:SkinText(self.frame.name, new)
    elseif prop == "currentStage" or prop == "numStages" then
      Theme:SkinText(self.frame.stageCounter, string.format("%i/%i", self.currentStage, self.numStages))
    elseif prop == "stageName" then
      Theme:SkinText(self.frame.stageName, new)
    end
  end
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  __Arguments__ { Variable.Optional(Theme.SkinInfo, Theme.SkinInfo()), Variable.Optional(Boolean, true) }
  function SkinFeatures(self, info, alreadyInit)
    if alreadyInit then
      super.SkinFeatures(self, info)
    end

    Theme:SkinFrame(self.frame.stage)

    -- Text
    Theme:SkinText(self.frame.name, self.name)
    Theme:SkinText(self.frame.stageName, self.stageName)
    Theme:SkinText(self.frame.stageCounter, string.format("%i/%i", self.currentStage, self.numStages))
  end

  __Arguments__ { Variable.Optional(Theme.SkinInfo, Theme.SkinInfo()), Variable.Optional(Boolean, true) }
  function ExtraSkinFeatures(self, info, alreadyInit)
      if alreadyInit then
        super.ExtraSkinFeatures(self, info)
      end
      local theme = Themes:GetSelected()
      if not theme then return end

      if Enum.ValidateFlags(info.textFlags, Theme.SkinTextFlags.TEXT_LOCATION) then
        local name = self.frame.name
        local elementID = name.elementID
        local inheritElementID = name.inheritElementID
        if elementID then
          local location = theme:GetElementProperty(elementID, "text-location", inheritElementID)
          local offsetX = theme:GetElementProperty(elementID, "text-offsetX", inheritElementID)
          local offsetY = theme:GetElementProperty(elementID, "text-offsetY", inheritElementID)

          name:SetPoint("TOPLEFT", offsetX, offsetY)

          name:SetJustifyV(_JUSTIFY_V_FROM_ANCHOR[location])
          name:SetJustifyH(_JUSTIFY_H_FROM_ANCHOR[location])
        end
      end
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

  __Arguments__ { Variable.Optional(Theme.SkinInfo, Theme.SKIN_INFO_ALL_FLAGS) }
  __Static__() function RefreshAll(skinInfo)
    for obj in pairs(_ScenarioCache) do
      obj:Refresh(skinInfo)
    end
  end

  __Arguments__ {}
  function RegisterFramesForThemeAPI(self)
    local class = Class.GetObjectClass(self)

    Theme:RegisterFrame(class._prefix..".stage", self.frame.stage)
    -- Text
    Theme:RegisterText(class._prefix..".name", self.frame.name)
    Theme:RegisterText(class._prefix..".stageName", self.frame.stageName)
    Theme:RegisterText(class._prefix..".stageCounter", self.frame.stageCounter)
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "name" { TYPE = Stirng, DEFAULT = "", HANDLER = UpdateProps}
  property "currentStage" { TYPE = Number, DEFAULT = 1, HANDLER = UpdateProps }
  property "numStages" { TYPE = Number, DEFAULT = 1, HANDLER = UpdateProps }
  property "stageName" { TYPE = String, DEFAULT = "", HANDLER = UpdateProps }
  property "numBonusObjectives" { TYPE = Number, DEFAULT = 0 }

  __Static__() property "_prefix" { DEFAULT = "block.scenario" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Scenario(self)
    super(self, "scenario", 10)
    self.text = "Scenario"

    local header = self.frame.header
    local headerText = header.text

    -- Scenario name
    local name = header:CreateFontString(nil, "OVERLAY")
    name:SetPoint("TOPRIGHT")
    name:SetPoint("BOTTOMLEFT")
    name:SetJustifyH("CENTER")
    self.frame.name = name

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

    -- Keep it in the cache for later.
    _ScenarioCache[self] = true
    -- Important: Always use 'This' to avoid issues when this class is inherited by
    -- other classes.
    RegisterFramesForThemeAPI(self)
    -- Important: Don't forgot 'This' as argument to this method !
    self:InitRefresh(Scenario)
  end
endclass "Scenario"

function OnLoad(self)
  CallbackHandlers:Register("scenario/refresher", CallbackHandler(Scenario.RefreshAll))
end
