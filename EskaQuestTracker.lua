-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                   "EskaQuestTracker"                             "1.6.11"
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
-- ======================[[ LibDataBroker & Minimap ]]======================= --
_LibDataBroker       = LibStub("LibDataBroker-1.1")
_LibDBIcon           = LibStub("LibDBIcon-1.0")
-- ========================[[ Addon version ]]------------------------------- ==
_EQT_VERSION         = GetAddOnMetadata("EskaQuestTracker", "Version")
_EQT_STAGE           = GetAddOnMetadata("EskaQuestTracker", "X-Stage")
-- =========================[[ Dependencies Version ]]======================= --
_SCORPIO_VERSION     = tonumber(GetAddOnMetadata("Scorpio", "Version"):match("%d+$"))
_PLOOP_VERSION       = tonumber(GetAddOnMetadata("PLoop", "Version"):match("%d+$"))
-- ========================================================================== --
_DEFAULT_TRACKER_WIDTH       = 270 -- @NOTE IMPORTANT : don't edit this value (could cause some ui size and position issues)
-- Values set by the users from options
_CURRENT_TRACKER_WIDTH       = 270
_CURRENT_TRACKER_RATIO_WIDTH = _CURRENT_TRACKER_WIDTH / _DEFAULT_TRACKER_WIDTH
_EQT_ICON                    = [[Interface\AddOns\EskaQuestTracker\Media\icon]]
-- ========================================================================== --
_THEMES = ObjectArray(Theme)
-- ========================================================================== --

-- !IMPORTANT
-- Don't set stuffs related to DB (this causes error if the user doesn't have the save variables created)
-- Set them to OnEnable instead.
function OnLoad(self)
  -- Create and init the DB
  _DB = SVManager("EskaQuestTrackerDB")

  Options:Register("replace-blizzard-objective-tracker", true, "Blizzard/UpdateTrackerVisibility")
  Options:Register("theme-selected", "Eska")

  CallbackHandlers:Register("Blizzard/UpdateTrackerVisibility", CallbackHandler(function(replace) _Addon.BLIZZARD_TRACKER_VISIBLITY_CHANGED(not replace) end))

  self:CheckDBMigration()

  _DB:SetDefault{dbVersion = 2 }
  _DB:SetDefault{ minimap = { hide = false }}

  -- Create the blocks table in order to register them.
  self.blocks = Dictionary()

  -- Setup the minimap button
  self:SetupMinimapButton()

  -- Theme Loading
  Themes:LoadFromDB()
  Themes:Select(Options:Get("theme-selected"))

  -- Check dependencies and print if they are deprecated or outdated
  Scorpio.Delay(2, function()
    self:CheckPLoopVersion()
    self:CheckScorpioVersion()
  end)
end

function OnEnable(self)
  BLIZZARD_TRACKER_VISIBLITY_CHANGED(not Options:Get("replace-blizzard-objective-tracker"))

  -- From now, all themes property changes will refresh the targeted frame.
  Theme.refreshOnPropertyChanged = true

end

function OnQuit(self)
  -- Do a clean in the Database (remove empty tables) when the player log out
  Database:Clean()
end

function SetupMinimapButton(self)
  -- Left click to hide/show the tracker
  local LDBTooltipLeftClickText = "|cff00ffffClick|r to show/hide the tracker"
  -- Right click to open configuration
  local LDBTooltipRightClickText = "|cff00ffffRight Click|r to open the configuration window"

  local LDBObject = _LibDataBroker:NewDataObject("EskaQuestTracker", {
    type = "launcher",
    icon = _EQT_ICON,
    OnClick = function(_, button, down)
      if button == "LeftButton" then
        if self.ObjectiveTracker:IsShown() then
          self.ObjectiveTracker:Hide()
        else
          self.ObjectiveTracker:Show()
        end
      elseif button == "RightButton" then
        OpenOptions()
      end
    end,
    OnTooltipShow = function(tooltip)
      tooltip:AddDoubleLine("Eska Quest Tracker", _EQT_VERSION, 1, 106/255, 0, 1, 1, 1)
      tooltip:AddLine(" ")
      tooltip:AddLine(LDBTooltipLeftClickText)
      tooltip:AddLine(LDBTooltipRightClickText)
    end,
  })

  _LibDBIcon:Register("EskaQuestTracker", LDBObject, _DB.minimap)
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

  -- @TODO Remove this migration hotfix in the 1.5 version
  if _DB.minimapPos then
    _DB.minimapPos = nil
  end
end

-- Register a Blocks (must be a class inherited of Block)
-- TODO: Make Blocks API: Blocks:Register()
function RegisterBlock(self, block)
  if not self.blocks[block.id] then
    self.blocks[block.id] = block

    -- Set the parent to block
    block:SetParent(self.ObjectiveTracker.content)

    -- Register block events
    block.OnActiveChanged = function(block, isActive)
      if isActive then
        block:Show()
      else
        block:Hide()
      end
      -- Call directly DrawBlocks because it uncommon two blocks changes its activty in short time.
      self:DrawBlocks()
      -- Need to recalculate height
      self:CalculateHeight()
    end

    block.OnHeightChanged = function(block, newHeight, oldHeight)
      -- Don't do that if the block is inactive
      if block.isActive then
        newHeight = math.ceil(newHeight)
        oldHeight = math.ceil(oldHeight)
        -- Not needed to call CalculateHeight, the diff is enought !
        self.ObjectiveTracker.contentHeight = self.ObjectiveTracker.contentHeight + (newHeight - oldHeight)
      end
    end

    -- IMPORTANT: Don't call DrawBlocks directly for avoid useless call.
    self:RequestDrawBlock()
  end
end


function CalculateHeight(self)
  local height = 0
  for index, obj in self.blocks:Filter("k,v=>v.isActive").Values:ToList():GetIterator() do
    height = obj.height

    if index > 1 then
      height = height + 4
    end
  end
  self.ObjectiveTracker.contentHeight = height
end

do
  local triggered = false
  __Thread__()
  function RequestDrawBlock(self, calculateHeight)
    if triggered then
      return
    else
      triggered = true
    end
    Delay(0.25)
    self:DrawBlocks()
    if calculateHeight then
      self:CalculateHeight()
    end

    triggered = false
  end
end

function SortBlocks(self)
  return self.blocks:Filter("k,v=>v.isActive")
                    .Values
                    :ToList()
                    :Sort("x,y=>x.priority<y.priority")
end

function DrawBlocks(self)
  for index, obj in self:SortBlocks():GetIterator() do
    obj:ClearAllPoints()

    if index == 1 then
      obj:SetPoint("TOP")
      obj:SetPoint("LEFT")
      obj:SetPoint("RIGHT")
    else
      obj:SetPoint("TOPLEFT", previousBlock.frame, "BOTTOMLEFT", 0, -4)
      obj:SetPoint("TOPRIGHT", previousBlock.frame, "BOTTOMRIGHT")
    end

    previousBlock = obj
  end
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

-- @NOTE Transform the two hooks to event for the World quest module. Remove it when the __EnableOnHook_ is implememented.
__SecureHook__()
function BonusObjectiveTracker_TrackWorldQuest(questID, hardWatch)
  if Options:Get("show-tracked-world-quests") then
    _M:FireSystemEvent("EQT_WORLDQUEST_TRACKED_LIST_CHANGED", questID, true, hardWatch)
  end
end

__SecureHook__()
function BonusObjectiveTracker_UntrackWorldQuest(questID)
  if Options:Get("show-tracked-world-quests") then
    _M:FireSystemEvent("EQT_WORLDQUEST_TRACKED_LIST_CHANGED", questID, false)
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


    --Theme.RefreshGroups()
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

-- ========================================================================== --
-- == Dependecies Checks
-- ========================================================================== --
enum "DependencyState" {
  "OK",         -- The addon works fine with the current dependency version.
  "DEPRECATED", -- The addon works fine with the current dependency version, but for the next addon version, the dependency must be updated in order to the addon works.
  "OUTDATED",   -- The addon doesn't work with the current dependency version, the dependency must be updated.
}

local deprecatedAlertText = "Your |cffFF6A00%s|r version is deprecated. That means in the next updates of |cff7FC9FFEska Quest Tracker|r, your version will no longer be enought in order to the addon works. Update your |cffFF6A00%s|r as soon as possible !"
local requiredAlertText = "Your |cffFF6A00%s|r version is too older for the addon works. Update it now !"

function CheckPLoopVersion(self, printCheck)
  local deprecatedVersion = 190 -- The version below will be considered as deprecated
  local requiredVersion = 190   -- The version below will be considered as outdated and not working with the current addon version.

  if printCheck == nil then
    printCheck = true
  end

  if _PLOOP_VERSION < requiredVersion then
    if printCheck then
      Error(requiredAlertText, "[Lib] PLoop")
    end
    return false, DependencyState.OUTDATED
  elseif _PLOOP_VERSION < deprecatedVersion then
    if printCheck then
      Warn(deprecatedAlertText, "[Lib] PLoop", "[Lib] PLoop")
    end
    return false, DependencyState.DEPRECATED
  end
  return true, DependencyState.OK
end

function CheckScorpioVersion(self, printCheck)
  local deprecatedVersion = 15 -- The version below will be considered as deprecated
  local requiredVersion = 13   -- The version below will be considered as outdated and not working with the current addon version.

  if printCheck == nil then
    printCheck = true
  end

  if _SCORPIO_VERSION < requiredVersion then
    if printCheck then
      Error(requiredAlertText, "[Lib] Scorpio")
    end
    return false, DependencyState.OUTDATED
  elseif _SCORPIO_VERSION < deprecatedVersion then
    if printCheck then
      Warn(deprecatedAlertText, "[Lib] Scorpio", "[Lib] Scorpio")
    end
    return false, DependencyState.DEPRECATED
  end
  return true, DependencyState.OK
end



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

__SlashCmd__ "eqt" "config" "- open the options"
__SlashCmd__ "eqt" "open" "- open the options"
__SlashCmd__ "eqt" "option" "- open the options"
function OpenOptions(self)
  if not IsAddOnLoaded("EskaQuestTracker_Options") then
    local loaded, reason = LoadAddOn("EskaQuestTracker_Options")
    if not loaded then return end
  end

    local options = _M:GetModule("Options")
    options:Open()
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
