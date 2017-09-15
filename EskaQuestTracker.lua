-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                   "EskaQuestTracker"                             "1.3.7"
-- ========================================================================== --
import "EQT"
import "System.Collections"
-- ========================[[ Logger ]]========================================
Log                 = Logger("EskaQuestTracker")

Trace               = Log:SetPrefix(1, "|cffa9a9a9[EQT:Trace]|r", true)
Debug               = Log:SetPrefix(2, "|cff808080[EQT:Debug]|r", true)
Info                = Log:SetPrefix(3, "|cffffffff[EQT:Info]|r", true)
Warn                = Log:SetPrefix(4, "|cffffff00[EQT:Warn]|r", true)
Error               = Log:SetPrefix(5, "|cffff0000[EQT:Error]|r", true)
Fatal               = Log:SetPrefix(6, "|cff8b0000[EQT:Fatal]|r", true)

Log.LogLevel        = 3

Log:AddHandler(print)
-- =========================[[ ObjectManager ]]============================== --
_ObjectManager       = ObjectManager()
-- =========================[[ LibSharedMedia ]]============================= --
_LibSharedMedia      = LibStub("LibSharedMedia-3.0")
-- ========================[[ Addon version ]]------------------------------------ ==
_EQT_VERSION         = GetAddOnMetadata("EskaQuestTracker", "Version")
_EQT_STAGE           = GetAddOnMetadata("EskaQuestTracker", "X-Stage")
-- =========================[[ Dependencies Version ]]======================= --
_SCORPIO_VERSION     = tonumber(GetAddOnMetadata("Scorpio", "Version"):match("%d+$"))
_PLOOP_VERSION       = tonumber(GetAddOnMetadata("PLoop", "Version"):match("%d+$"))
-- ========================================================================== --
_DEFAULT_TRACKER_WIDTH = 270 -- @NOTE IMPORTANT : don't edit this value (could cause some ui size and position issues)
-- Values set by the users from options
_CURRENT_TRACKER_WIDTH = 270
_CURRENT_TRACKER_RATIO_WIDTH = _CURRENT_TRACKER_WIDTH / _DEFAULT_TRACKER_WIDTH
-- ========================================================================== --
_THEMES = ObjectArray(Theme)
-- _MenuContext = MenuContext()

-- !IMPORTANT
-- Don't set stuffs related to DB (this causes error if the user doesn't have the save variables created)
-- Set them to OnEnable instead.
function OnLoad(self)
  -- Create and init the DB
  _DB = SVManager("EskaQuestTrackerDB")

  Options:Register("replace-blizzard-objective-tracker", true)
  Options:Register("theme-selected", "Eska")

  self:CheckDBMigration()

  _DB:SetDefault{dbVersion = 1 }

  -- Create the blocks table in order to register them.
  self.blocks = Dictionary()

  self:SelectTheme(Options:Get("theme-selected"))

end

function OnEnable(self)
  BLIZZARD_TRACKER_VISIBLITY_CHANGED(not Options:Get("replace-blizzard-objective-tracker"))

  -- From now, all themes property changes will refresh the targeted frame.
  Theme.refreshOnPropertyChanged = true
end

function CheckDBMigration()
  if not _DB.dbVersion and _DB.replaceBlizzardObjectiveTracker then
    if _DB.Tracker then
      if _DB.Tracker.xPos  ~= nil then Options:Set("tracker-xPos", _DB.Tracker.xPos, false) end
      if _DB.Tracker.yPos ~= nil then Options:Set("tracker-yPos", _DB.Tracker.yPos, false)  end
      if _DB.Tracker.height ~= nil then Options:Set("tracker-height", _DB.Tracker.height, false) end
      if _DB.Tracker.width ~= nil then Options:Set("tracker-width", _DB.Tracker.width, false) end
      if _DB.Tracker.locked ~= nil then Options:Set("tracker-locked", _DB.Tracker.locked, false) end
      _DB.Tracker = nil
    end

    if _DB.Quest then
      if _DB.Quest.showID ~= nil then Options:Set("quest-show-id", _DB.Quest.showID, false) end
      if _DB.Quest.ShowLevel ~= nil then Options:Set("quest-show-level", _DB.Quest.ShowLevel, false) end
      _DB.Quest = nil
    end

    Options:Set("theme-selected", _DB.currentTheme, false) ; _DB.currentTheme = nil
    Options:Set("replace-blizzard-objective-tracker", _DB.replaceBlizzardObjectiveTracker, false) ; _DB.replaceBlizzardObjectiveTracker = nil
  end
end

function RegisterBlock(self, block)
    if not self.blocks[block.id] then
      self.blocks[block.id] = block
      block.frame:SetParent(self.ObjectiveTracker.content)

      block.OnActiveChanged = function (self, new, old, prop)
        if new then
          self.frame:Show()
          self.frame:SetHeight(self.height)
        else
          self.frame:Hide()
          --self.frame:ClearAllPoints()
        end

        _Addon:DrawBlocks()
      end

      if block.isActive then
        _Addon:DrawBlocks()
      end
    end

    block.OnHeightChanged = function(self, new, old, prop)
      if block.isActive then
        _Addon:DrawBlocks()
      end
    end
end

function SortBlocks(self)
  return self.blocks:Filter("k,v=>v.isActive")
                    .Values
                    :ToList()
                    :Sort("x,y=>x.priority<y.priority")
end

function DrawBlocks(self)
  local height = 0
  local previousBlock
  for index, obj in self:SortBlocks():GetIterator() do
    --print(index, obj.id, obj.priority)
    height = height + obj.height

    if index == 1 then
      obj.frame:SetPoint("TOPLEFT", self.ObjectiveTracker.content, "TOPLEFT")
      obj.frame:SetPoint("TOPRIGHT", self.ObjectiveTracker.content, "TOPRIGHT", 2, 0)
    else
      obj.frame:SetPoint("TOPLEFT", previousBlock.frame, "BOTTOMLEFT", 0, -15)
      obj.frame:SetPoint("TOPRIGHT", previousBlock.frame, "BOTTOMRIGHT")
    end
    previousBlock = obj
  end


  self.ObjectiveTracker.contentHeight = height + 5

end

__SystemEvent__()
function BLIZZARD_TRACKER_VISIBLITY_CHANGED(isVisible)
  if isVisible then
    ObjectiveTracker_Initialize(ObjectiveTrackerFrame)
    ObjectiveTrackerFrame:SetScript("OnEvent", ObjectiveTracker_OnEvent)
    ObjectiveTrackerFrame:Show()
    ObjectiveTracker_Update()
  else
    ObjectiveTrackerFrame:Hide()
    ObjectiveTrackerFrame:SetScript("OnEvent", nil)
  end
end

__SystemEvent__ "ZONE_CHANGED" "ZONE_CHANGED_NEW_AREA"
function UPDATE_PLAYER_MAP()
  if not WorldMapFrame:IsShown() then
    SetMapToCurrentZone()
  end
end

-- ==========================================================================
-- == THEMES
-- ==========================================================================
function RegisterTheme(self, theme)
  if not self:GetTheme(theme.name) then
    _THEMES:Insert(theme)
  end
end

function SelectTheme(self, name)
  local theme = self:GetTheme(name)

  if theme then
    _CURRENT_THEME = theme
    Options:Set("theme-selected", name)

    Theme.RefreshGroups()
  end
end

function GetTheme(self, name)
  for _, theme in _THEMES:GetIterator() do
    if theme.name == name then
      return theme
    end
  end
end

function GetThemes()
  return _THEMES
end

function GetCurrentTheme()
  return _CURRENT_THEME
end

-- ImportTheme(encoded)
-- ExportTheme(theme, )

__SlashCmd__ "eqt" "scorpio" "- return the current scorpio version"
function PrintScorpioVersion()
  Info("|cff00ff00Your Scorpio version is:|r |cffff0000%s|r", GetAddOnMetadata("Scorpio", "Version"))
end

__SlashCmd__ "eqt" "ploop" "- return the current ploop version"
function PrintPLoopVersion()
  Info("|cff00ff00Your PLoop version is:|r |cffff0000%s|r", GetAddOnMetadata("PLoop", "Version"))
end

__SlashCmd__ "eqt" "show" "- show the objective tracker"
function ShowObjectiveTracker()
  _Addon.ObjectiveTracker:Show()
end

__SlashCmd__ "eqt" "hide" "- hide the objective tracker"
function HideObjectiveTracker()
  _Addon.ObjectiveTracker:Hide()
end

__SlashCmd__ "eqt" "dbreset" "- reset the settings (need to reload to apply changes)"
function ResetDB()
  _DB:Reset()
  Info("The settings has been reset. |cff00ff00Do /reload to apply the changes.|r")
end

-- ========================================================================== --
-- == Register the fonts
-- ========================================================================== --
-- PT Sans Family Font
_LibSharedMedia:Register("font", "PT Sans", [[Interface\AddOns\EskaQuestTracker\Media\Fonts\PTSans-Regular.ttf]])
_LibSharedMedia:Register("font", "PT Sans Bold", [[Interface\AddOns\EskaQuestTracker\Media\Fonts\PTSans-Bold.ttf]])
_LibSharedMedia:Register("font", "PT Sans Bold Italic", [[Interface\AddOns\EskaQuestTracker\Media\Fonts\PTSans-Bold-Italic.ttf]])
_LibSharedMedia:Register("font", "PT Sans Narrow", [[Interface\AddOns\EskaQuestTracker\Media\Fonts\PTSans-Narrow.ttf]])
_LibSharedMedia:Register("font", "PT Sans Narrow Bold", [[Interface\AddOns\EskaQuestTracker\Media\Fonts\PTSans-Narrow-Bold.ttf]])
_LibSharedMedia:Register("font", "PT Sans Caption", [[Interface\AddOns\EskaQuestTracker\Media\Fonts\PTSans-Caption.ttf]])
_LibSharedMedia:Register("font", "PT Sans Caption Bold", [[Interface\AddOns\EskaQuestTracker\Media\Fonts\PTSans-Caption-Bold.ttf]])
-- DejaVuSans Family Font
_LibSharedMedia:Register("font", "Deja Vu Sans", [[Interface\AddOns\EskaQuestTracker\Media\Fonts\DejaVuSans.ttf]])
_LibSharedMedia:Register("font", "Deja Vu Sans Bold", [[Interface\AddOns\EskaQuestTracker\Media\Fonts\DejaVuSans-Bold.ttf]])
_LibSharedMedia:Register("font", "Deja Vu Sans Bold Italic", [[Interface\AddOns\EskaQuestTracker\Media\Fonts\DejaVuSans-BoldOblique.ttf]])
_LibSharedMedia:Register("font", "DejaVuSansCondensed", [[Interface\AddOns\EskaQuestTracker\Media\Fonts\DejaVuSansCondensed.ttf]])
_LibSharedMedia:Register("font", "DejaVuSansCondensed Bold", [[Interface\AddOns\EskaQuestTracker\Media\Fonts\DejaVuSansCondensed-Bold.ttf]])
_LibSharedMedia:Register("font", "DejaVuSansCondensed Bold Italic", [[Interface\AddOns\EskaQuestTracker\Media\Fonts\DejaVuSansCondensed-BoldOblique.ttf]])
_LibSharedMedia:Register("font", "DejaVuSansCondensed Italic", [[Interface\AddOns\EskaQuestTracker\Media\Fonts\DejaVuSansCondensed-Oblique.ttf]])
-- ========================================================================== --
-- Backdrops
-- ========================================================================== --
_Backdrops = {
  Common = {
    bgFile = [[Interface\AddOns\EskaQuestTracker\Media\Textures\Frame-Background]],
    edgeFile = [[Interface\AddOns\EskaQuestTracker\Media\Textures\Frame-Border]],
    tile = false, tileSize = 32, edgeSize = 3,
    insets = { left = 0, right = 0, top = 0, bottom = 0}
  },
  CommonWithBiggerBorder = {
    bgFile = [[Interface\AddOns\EskaQuestTracker\Media\Textures\Frame-Background]],
    edgeFile = [[Interface\AddOns\EskaQuestTracker\Media\Textures\Frame-Border]],
    tile = false, tileSize = 32, edgeSize = 6,
    insets = { left = 0, right = 0, top = 0, bottom = 0}
  }

}

_JUSTIFY_H_FROM_ANCHOR = {
  CENTER = "CENTER", TOP = "CENTER", BOTTOM = "CENTER", LEFT = "LEFT", RIGHT = "RIGHT",
  TOPLEFT = "LEFT", TOPRIGHT = "RIGHT", BOTTOMLEFT = "LEFT", BOTTOMRIGHT = "RIGHT"
}

_JUSTIFY_V_FROM_ANCHOR = {
  CENTER = "CENTER", TOP = "TOP", BOTTOM = "BOTTOM", LEFT = "CENTER", RIGHT = "CENTER",
  TOPLEFT = "TOP", TOPRIGHT = "TOP", BOTTOMLEFT = "BOTTOM", BOTTOMRIGHT = "BOTTOM"
}
