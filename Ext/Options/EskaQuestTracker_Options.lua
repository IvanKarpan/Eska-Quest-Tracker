--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio                "EskaQuestTracker.Options"                             ""
-- ===========================================================================--
namespace "EQT"
--============================================================================--
_AceGUI = LibStub("AceGUI-3.0")
--============================================================================--
_Fonts  = _LibSharedMedia:List("font")




_TextTransforms = {
  ["none"] = "None",
  ["uppercase"] = "Upper case",
  ["lowercase"] = "Lower case",
}

_AnchorPoints = {
  ["TOP"] = "TOP",
  ["TOPLEFT"] = "TOPLEFT",
  ["TOPRIGHT"] = "TOPRIGHT",
  ["BOTTOM"] = "BOTTOM",
  ["BOTTOMLEFT"] = "BOTTOMLEFT",
  ["BOTTOMRIGHT"] = "BOTTOMRIGHT",
  ["LEFT"] = "LEFT",
  ["RIGHT"] = "RIGHT",
  ["CENTER"] = "CENTER",
}

_SavedInThemeColor = "FF56C6FF"
ThemeColor = function(str) return string.format("|c%s%s|r", _SavedInThemeColor, str) end
GetFontIndex = function(font)
  for i, v in next, _Fonts do
    if v == font then
      return i
    end
  end
end
-- The frame containing the optiosn
_ROOT_FRAME = nil
-- We keeps the builder function for the categories.
_CATEGORIES_BUILDER = Dictionary()



function OnLoad(self)
  _ROOT_TREE = {
    {
      value = "EQT",
      text = "Eska Quest Tracker",
      icon = _EQT_ICON,
      children = {}
    }
  }

  _TREE_CATEGORIES = _ROOT_TREE[1].children

  self:RegisterCategory("Tracker", "Tracker", 10, BuildTrackerCategory)
  self:RegisterCategory("ItemBar", "Item bar", 60, BuildItemBarCategory)
  self:RegisterCategory("MenuContext", "Menu context", 70, BuildMenuContextCategory)
  self:RegisterCategory("Groupfinders", "Group finders", 80, BuildGroupFindersCategory)

  self:FireSystemEvent("EQT_OPTIONS_LOADED")

  --self:NewRootCategory("Tracker", "Tracker")
  --self:NewRootCategory("MenuContext", "Menu context")
  --self:NewRootCategory("Itembar", "Item bar")
  --self:NewRootCategory("Groupfinders", "Group finders")
end


function OnEnable(self)
end

function Open(self)
  if not _ROOT_FRAME then
    table.sort(_TREE_CATEGORIES, function(a,b) return a.order < b.order end)

    _ROOT_FRAME = _AceGUI:Create("Frame")
    _ROOT_FRAME:SetTitle("Eska Quest Tracker - Options")
    _ROOT_FRAME:SetLayout("Fill")

    _ROOT_TREE_FRAME = _AceGUI:Create("TreeGroup")

    _ROOT_TREE_FRAME:SetTree(_ROOT_TREE)
    _ROOT_TREE_FRAME:SelectByValue("EQT")
    _ROOT_TREE_FRAME:SetLayout("Flow")
    _ROOT_FRAME:AddChild(_ROOT_TREE_FRAME)

    local scrollContainer = _AceGUI:Create("SimpleGroup")
    scrollContainer:SetFullWidth(true)
    scrollContainer:SetFullHeight(true)
    scrollContainer:SetLayout("Fill")

    _ROOT_TREE_FRAME:AddChild(scrollContainer)

    _CONTENT = _AceGUI:Create("ScrollFrame")
    _CONTENT:SetLayout("List")
    scrollContainer:AddChild(_CONTENT)

    _ROOT_TREE_FRAME:SetCallback("OnGroupSelected", function(_, _, uniquePath)
      local _, category = strsplit("\001", uniquePath, 2)
      _M:SelectCategory(category)
    end)

    for i = 1, 2 do
      local label = _AceGUI:Create("EQT-ThemeButton")
      _CONTENT:AddChild(label)
    end
    self:SelectCategory(nil)
  end

  _ROOT_FRAME:Show()
end

function RegisterCategory(self, id, text, order, builder)
  tinsert(_TREE_CATEGORIES, {
    value = id,
    text = text,
    order = order or 10,
  })

  _CATEGORIES_BUILDER[id] = builder
end


-- ========================================================================== --
-- == ADDON INFO CATEGORY
-- ========================================================================== --
function BuildAddonInfoCategory(self, content)

  local headingFont = _LibSharedMedia:Fetch("font", "PT Sans Caption Bold")
  local headingSize = 15

  local font = _LibSharedMedia:Fetch("font", "PT Sans Narrow Bold")
  local fontSize = 14

  -- Info category
  local addonInfoHeading = _AceGUI:Create("Label")
  addonInfoHeading:SetText("Addon Info")
  addonInfoHeading:SetFont(headingFont, headingSize)
  addonInfoHeading:SetColor(1, 216/255, 0)
  content:AddChild(addonInfoHeading)
  do
    local group =  _AceGUI:Create("SimpleGroup")
    group:SetLayout("Flow")
    for key, value in pairs({ ["Version"] = _EQT_VERSION, ["Stage"] = _EQT_STAGE }) do
      local label = _AceGUI:Create("Label")
      label:SetText(key)
      label:SetFont(font, fontSize)
      label:SetWidth(100)
      label:SetColor(0, 148/255, 1)
      group:AddChild(label)

      local labelValue = _AceGUI:Create("Label")
      labelValue:SetText(value)
      labelValue:SetFont(font, fontSize)
      group:AddChild(labelValue)
    end
    content:AddChild(group)
  end

  -- Separator
  do
    local sep = _AceGUI:Create("Label")
    sep:SetText("\n\n")
    content:AddChild(sep)
  end

  -- Slash commands category
  local slashCommandsHeading = _AceGUI:Create("Label")
  slashCommandsHeading:SetText("Slash Commands")
  slashCommandsHeading:SetFont(headingFont, headingSize)
  slashCommandsHeading:SetColor(1, 216/255, 0)
  content:AddChild(slashCommandsHeading)
  -- Separator
  do
    local sep = _AceGUI:Create("Label")
    sep:SetText("\n")
    content:AddChild(sep)
  end
  do
    local slashCommands = {
      ["open|config|option"] = "Open the category",
      ["show"] = "Show the objective tracker",
      ["hide"] = "Hide the objective tracker",
      ["ploop"] = "Print the PLoop version",
      ["scorpio"] = "Print the Scorpio version"
    }

    local group = _AceGUI:Create("SimpleGroup")
    group:SetLayout("Flow")
    for command, desc in pairs(slashCommands) do
      local label = _AceGUI:Create("Label")
      label:SetText(string.format("|cffff6a00/eqt|r %s", command))
      label:SetFont(_LibSharedMedia:Fetch("font", "PT Sans Narrow Bold"), fontSize - 1)
      label:SetRelativeWidth(0.45)
      label:SetColor(0, 148/255, 1)
      group:AddChild(label)

      local labelValue = _AceGUI:Create("Label")
      labelValue:SetText("- "..desc)
      labelValue:SetFont(font, fontSize - 2)
      labelValue:SetRelativeWidth(0.55)
      group:AddChild(labelValue)
    end
    content:AddChild(group)
  end
  -- Separator
  do
    local sep = _AceGUI:Create("Label")
    sep:SetText("\n")
    content:AddChild(sep)
  end

  -- Dependencies category
  local dependenciesHeading = _AceGUI:Create("Label")
  dependenciesHeading:SetText("Dependencies")
  dependenciesHeading:SetFont(headingFont, headingSize)
  dependenciesHeading:SetColor(1, 0, 0)
  content:AddChild(dependenciesHeading)
  -- Separator
  do
    local sep = _AceGUI:Create("Label")
    sep:SetText("\n")
    content:AddChild(sep)
  end
  do
    local group =  _AceGUI:Create("SimpleGroup")
    group:SetLayout("Flow")
    for lib, version in pairs({ ["|cff0094ffPLoop|r"] = _PLOOP_VERSION, ["|cffff6a00Scorpio|r"] = _SCORPIO_VERSION }) do
      local label = _AceGUI:Create("Label")
      label:SetText(lib)
      label:SetFont(font, fontSize)
      label:SetWidth(100)
      group:AddChild(label)

      local labelValue = _AceGUI:Create("Label")
      labelValue:SetText(string.format("|cff00ff00v%d|r", version))
      labelValue:SetFont(font, fontSize)
      group:AddChild(labelValue)
    end
    content:AddChild(group)
  end


  -- Global options
  -- Separator
  do
    local sep = _AceGUI:Create("Label")
    sep:SetText("\n\n")
    content:AddChild(sep)
  end

  -- Slash commands category
  local globalOptionsHeading = _AceGUI:Create("Label")
  globalOptionsHeading:SetText("Global options")
  globalOptionsHeading:SetFont(headingFont, headingSize)
  globalOptionsHeading:SetColor(1, 216/255, 0)
  content:AddChild(globalOptionsHeading)

  -- Separator
  do
    local sep = _AceGUI:Create("Label")
    sep:SetText("\n")
    content:AddChild(sep)
  end

  -- [OPTION] Enable minimap icon
  local enableMinimapIcon = _AceGUI:Create("CheckBox")
  enableMinimapIcon:SetLabel("Enable minimap icon")
  enableMinimapIcon:SetValue(not _DB.minimap.hide)
  enableMinimapIcon:SetCallback("OnValueChanged", function(_, _, enable)
      if enable then
        _LibDBIcon:Show("EskaQuestTracker")
      else
        _LibDBIcon:Hide("EskaQuestTracker")
      end
      _DB.minimap.hide = not enable
  end)
  content:AddChild(enableMinimapIcon)

end

-- ========================================================================== --
-- == TRACKER CATEGORY
-- ========================================================================== --
function BuildTrackerCategory(content)
  local font = _LibSharedMedia:Fetch("font", "PT Sans Narrow Bold")
  local fontSize = 14

  do
    local group = _AceGUI:Create("SimpleGroup")
    group:SetLayout("Flow")

    -- [OPTION] Lock the tracker
    local lock = _AceGUI:Create("CheckBox")
    lock:SetLabel("Lock")
    lock:SetValue(Options:Get("tracker-locked"))
    lock:SetWidth(100)
    lock:SetCallback("OnValueChanged", function(_, _, locked)
      Options:Set("tracker-locked", locked)
    end)
    group:AddChild(lock)

    -- [OPTION] Show/Hide the tracker
    local show = _AceGUI:Create("Button")
    show:SetText("Show/Hide")
    show:SetCallback("OnClick", function()
      if _Addon.ObjectiveTracker:IsShown() then
        _Addon.ObjectiveTracker:Hide()
      else
        _Addon.ObjectiveTracker:Show()
      end
    end)
    group:AddChild(show)
    content:AddChild(group)
  end

  -- [OPTION] Group Size
  do
    local group = _AceGUI:Create("InlineGroup")
    group:SetTitle("Size")
    group:SetLayout("Flow")

    local width = _AceGUI:Create("Slider")
    width:SetLabel("Width")
    width:SetValue(Options:Get("tracker-width"))
    width:SetRelativeWidth(0.5)
    width:SetSliderValues(270, 500, 1)
    width:SetCallback("OnValueChanged", function(_, _, width) Options:Set("tracker-width", width) end)
    group:AddChild(width)

    local height = _AceGUI:Create("Slider")
    height:SetLabel("Height")
    height:SetRelativeWidth(0.5)
    height:SetValue(Options:Get("tracker-height"))
    height:SetSliderValues(64, 1024, 1)
    height:SetCallback("OnValueChanged", function(_, _, height) Options:Set("tracker-height", height) end)
    group:AddChild(height)

    content:AddChild(group)
  end

  do
    local group = _AceGUI:Create("SimpleGroup")
    group:SetLayout("Flow")

    -- [OPTION] Background color (theme shortcut)
    local color = Themes:GetSelected():GetElementProperty("tracker.frame", "background-color")
    local function TrackerSetBackgroundColor(r, g, b, a)
        Themes:GetSelected():SetElementPropertyToDB("tracker.frame", "background-color", { r = r, g = g, b = b, a = a })
        CallbackHandlers:Call("tracker/refresher")
    end

    local backgroundColor = _AceGUI:Create("ColorPicker")
    backgroundColor:SetLabel(ThemeColor("Background color"))
    backgroundColor:SetColor(color.r, color.g, color.b, color.a)
    backgroundColor:SetHasAlpha(true)
    backgroundColor:SetRelativeWidth(0.5)
    backgroundColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a) TrackerSetBackgroundColor(r, g, b, a) end)
    backgroundColor:SetCallback("OnValueConfirmed", function(_, _, r, g, b, a) TrackerSetBackgroundColor(r, g, b, a) end)
    group:AddChild(backgroundColor)

    -- [OPTION] Border color (theme shortcut)
    color = Themes:GetSelected():GetElementProperty("tracker.frame", "border-color")

    local function TrackerSetBorderColor(r, g, b, a)
      Themes:GetSelected():SetElementPropertyToDB("tracker.frame", "border-color", { r = r, g = g, b = b, a = a })
      CallbackHandlers:Call("tracker/refresher")
    end

    local borderColor = _AceGUI:Create("ColorPicker")
    borderColor:SetLabel(ThemeColor("Border color"))
    borderColor:SetColor(color.r, color.g, color.b, color.a)
    borderColor:SetHasAlpha(true)
    borderColor:SetRelativeWidth(0.5)
    borderColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a) TrackerSetBorderColor(r, g, b, a) end)
    borderColor:SetCallback("OnValueConfirmed", function(_, _, r, g, b, a) TrackerSetBorderColor(r, g, b, a) end)
    group:AddChild(borderColor)

    content:AddChild(group)
  end

  local showScrollbar = _AceGUI:Create("CheckBox")
  showScrollbar:SetLabel("Show scrollbar")
  showScrollbar:SetValue(Options:Get("tracker-show-scrollbar"))
  showScrollbar:SetCallback("OnValueChanged", function(_, _, show) Options:Set("tracker-show-scrollbar", show) end)
  content:AddChild(showScrollbar)

  -- [Options] Blizzard objective tracker group
  do
    local group = _AceGUI:Create("InlineGroup")
    group:SetTitle("Blizzard objective tracker")
    group:SetRelativeWidth(1.0)

    local replaceCompletely = _AceGUI:Create("CheckBox")
    replaceCompletely:SetLabel("Replace completely the blizzard objective tracker")
    replaceCompletely:SetRelativeWidth(1.0)
    replaceCompletely:SetValue(Options:Get("replace-blizzard-objective-tracker"))
    replaceCompletely:SetCallback("OnValueChanged", function(_, _, replace) Options:Set("replace-blizzard-objective-tracker", replace) ; _Addon.BLIZZARD_TRACKER_VISIBLITY_CHANGED(not replace) end)
    group:AddChild(replaceCompletely)

    content:AddChild(group)
  end

end

-- ========================================================================== --
-- == MENU CONTEXT CATEGORY
-- ========================================================================== --
function BuildMenuContextCategory(content)
  local selectOrientation = _AceGUI:Create("Dropdown")
  selectOrientation:SetLabel("Orientation")
  selectOrientation:SetText(Options:Get("menu-context-orientation"))
  selectOrientation:SetList({
    ["RIGHT"] = "RIGHT",
    ["LEFT"] = "LEFT"
  })
  selectOrientation:SetCallback("OnValueChanged", function(_, _, orientation) Options:Set("menu-context-orientation", orientation) end)

  content:AddChild(selectOrientation)

end

function BuildItemBarCategory(content)
  -- [OPTIONS] Select Position (item bar)
  local selectPosition = _AceGUI:Create("Dropdown")
  selectPosition:SetText(Options:Get("item-bar-position"))
  selectPosition:SetLabel("Position")
  selectPosition:SetList({
    ["TOPLEFT"] = "Top Left",
    ["TOPRIGHT"] = "Top Right",
    ["BOTTOMLEFT"] = "Bottom Left",
    ["BOTTOMRIGHT"] = "Bottom Right"
  })
  selectPosition:SetCallback("OnValueChanged", function(_, _, position) Options:Set("item-bar-position", position) end)

  -- [OPTIONS] Select Direction growth (item bar)
  local selectDirectionGrowth = _AceGUI:Create("Dropdown")
  selectDirectionGrowth:SetText(Options:Get("item-bar-direction-growth"))
  selectDirectionGrowth:SetLabel("Direction growth")
  selectDirectionGrowth:SetList({
    ["RIGHT"] = "Left",
    ["LEFT"] = "Right",
    ["UP"] = "Up",
    ["DOWN"] = "Down",
  })
  selectPosition:SetCallback("OnValueChanged", function(_, _, direction) Options:Set("item-bar-direction-growth", direction) end)

  content:AddChild(selectPosition)
  content:AddChild(selectDirectionGrowth)
end

function SelectCategory(self, category)
  _CONTENT:ReleaseChildren()

  if category then
    local handler = _CATEGORIES_BUILDER[category]
    if handler then
      handler(_CONTENT)
    end
  else
    self:BuildAddonInfoCategory(_CONTENT)
  end
end

-- ========================================================================== --
-- == GROUP FINDER CATEGORY
-- ========================================================================== --
function BuildGroupFindersCategory(content)
  local selectGroupFinder = _AceGUI:Create("Dropdown")
  local list = {}
  for name in GroupFinderAddon:GetIterator() do
    list[name] = name
  end

  -- [OPTIONS] Select a group finder
  selectGroupFinder:SetLabel("Select a group finder")
  selectGroupFinder:SetList(list)
  selectGroupFinder:SetValue(select(2, GroupFinderAddon:GetSelected()))
  selectGroupFinder:SetCallback("OnValueChanged", function(_, _, addon) GroupFinderAddon:SetSelected(addon) end )

  content:AddChild(selectGroupFinder)
end
