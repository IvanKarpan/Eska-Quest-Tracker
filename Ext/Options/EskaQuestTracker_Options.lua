--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio                 "EskaQuestTracker.Options"                            ""
--============================================================================--
namespace "EQT"
import "System.Serialization"
--============================================================================--
_AceGUI               = LibStub("AceGUI-3.0")
--============================================================================--
_Fonts                = _LibSharedMedia:List("font")
--============================================================================--
_OPTIONS_FRAME_WIDTH  = 1024
_OPTIONS_FRAME_HEIGHT = 600
--============================================================================--
_TextTransforms       = {
  ["none"] = "None",
  ["uppercase"] = "Upper case",
  ["lowercase"] = "Lower case",
}
--============================================================================--
_AnchorPoints         = {
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
--============================================================================--
GetFontIndex   =  function(font)
  for i, v in next, _Fonts do
    if v == font then
      return i
    end
  end
end
--============================================================================--
_ROOT_FRAME         = nil -- The frame containing the options
--============================================================================--
_CATEGORIES_BUILDER = Dictionary() -- We keeps the bulder function for the categories
_CATEGORIES_INFO = {}


function OnLoad(self)
  _ROOT_TREE = {
    {
      value = "EQT",
      text = "Eska Quest Tracker",
      icon = _EQT_ICON,
      children = {}
    }
  }
  -- [DEFAULT]
  OptionBuilder:SetVariable("state-selected", "none")
  OptionBuilder:SetVariable("theme-selected", Themes:GetSelected().name)

  _TREE_CATEGORIES = _ROOT_TREE[1].children

  -- We fire an event to say the options have been loaded
  self:FireSystemEvent("EQT_OPTIONS_LOADED")

   self:AddTrackerRecipes()
   self:AddBlockRecipes()
   self:AddObjectiveRecipes()
   self:AddItemBarRecipes()
   self:AddMenuContextRecipes()
   self:AddGroupFindersRecipes()
   self:AddProfilsRecipes()

end

function CreateBlockRecipes(self, prefix, recipeGroup)
    local elements =  { strsplit(".", prefix) }

    function firstToUpper(str)
      return (str:gsub("^%l", string.upper))
    end

    local refresherPrefix = elements[#elements]
    local lastElement = firstToUpper(elements[#elements])


    OptionBuilder:AddRecipe(ThemeDropDownRecipe("Select a theme", lastElement.."/SelectThemeToEdit/Children"), recipeGroup)
    OptionBuilder:AddRecipe(TabRecipe("", lastElement.."/Tabs"):SetOrder(1), lastElement.."/SelectThemeToEdit/Children")
    OptionBuilder:AddRecipe(TabItemRecipe("General", lastElement.."/General"):SetID("general"):SetOrder(1), lastElement.."/Tabs")
    OptionBuilder:AddRecipe(TabItemRecipe("Header", lastElement.."/Header"):SetID("scrollbar"):SetOrder(2), lastElement.."/Tabs")
    OptionBuilder:AddRecipe(TabItemRecipe("Stripe", lastElement.."/Stripe"):SetID("scrollbar-thumb"):SetOrder(3), lastElement.."/Tabs")

    OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement(prefix..".frame", "block.frame"):SetRefresher(refresherPrefix.."/refresher"):SetOrder(10), lastElement.."/General")


    OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement(prefix..".header", "block.header"):SetRefresher(refresherPrefix.."/refresher"):SetFlags(ThemeElementRecipe.ALL_FRAME_OPTIONS + ThemeElementRecipe.ALL_TEXT_OPTIONS), lastElement.."/Header")
    OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement(prefix..".stripe", "block.stripe"):SetRefresher(refresherPrefix.."/refresher"):SetFlags(ThemeElementRecipe.ALL_TEXTURE_OPTIONS), lastElement.."/Stripe")

end



function Open(self)
  if not _ROOT_FRAME then

    self:BuildRootTreeTable()
    table.sort(_TREE_CATEGORIES, function(a, b) return a.order < b.order end)

    _ROOT_FRAME = _AceGUI:Create("Frame")
    _ROOT_FRAME:SetWidth(_OPTIONS_FRAME_WIDTH)
    _ROOT_FRAME:SetHeight(_OPTIONS_FRAME_HEIGHT)
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
    _CONTENT:SetFullWidth(true)
    scrollContainer:AddChild(_CONTENT)

    _ROOT_TREE_FRAME:SetCallback("OnGroupSelected", function(_, _, uniquePath)
      local categories = { strsplit("\001", uniquePath) }
      local path = categories[#categories]
      self:SelectCategory(path)
    end)

    self:SelectCategory(nil)
  end

  _ROOT_FRAME:Show()
end

function BuildRootTreeTable(self)
  local categoriesTable = Dictionary()

  for index, info in ipairs(_CATEGORIES_INFO) do
      local list = categoriesTable[info.id]
      if not list then
        list = {}
      end

      list.value = info.id
      list.text = info.text
      list.order = info.order

      if info.path and info.path ~= "" then
        local parent = categoriesTable[info.path]
        if parent then
          if not parent.children then
            parent.children = {}
          end
        else
          parent = {
            value = info.path,
            text = info.path,
            order = info.order,
            children = {}
          }
          categoriesTable[info.path] = parent
        end
        list.isAdded = true
        tinsert(parent.children, list)

      else
        if not list.isAdded then
          list.isAdded = true
          tinsert(_TREE_CATEGORIES, list)
        end
      end

      if not categoriesTable[info.id] then
        categoriesTable[info.id] = list
      end
  end

  local recipes = OptionBuilder:GetRecipes("RootTree")
  if recipes then
    for index, recipe in recipes:GetIterator() do
        local list = categoriesTable[recipe.id]
        if not list then
          list = {}
        end

        list.value = recipe.id
        list.text = recipe.text
        list.order = recipe.order

        if recipe.path and recipe.path ~= "" then
          local parent = categoriesTable[recipe.path]
          if parent then
            if not parent.children then
              parent.children = {}
            end
          else
            parent = {
              value = recipe.path,
              text = recipe.path,
              order = recipe.order,
              children = {}
            }
            categoriesTable[recipe.path] = parent
          end
          list.isAdded = true
          tinsert(parent.children, list)

        else
          if not list.isAdded then
            list.isAdded = true
            tinsert(_TREE_CATEGORIES, list)
          end
        end

        if not categoriesTable[recipe.id] then
          categoriesTable[recipe.id] = list
        end

        if not _CATEGORIES_BUILDER[recipe.id] then
          _CATEGORIES_BUILDER[recipe.id] = recipe
        end
    end
  end

  -- Sort by order
  local function SortByOrder(t)
    table.sort(t, function(a, b) return a.order < b.order end)
    for index, child in ipairs(t) do
      if child.children then
        SortByOrder(child.children)
      end
    end
  end

  SortByOrder(_TREE_CATEGORIES)
end

--[[
RegisterCategory(text, id, order, path, builder)
TreeItemRecipe("Quests"):SetID("quests"):SetPath("quests"):SetOrder(1)
TreeItemRecipe("World Quest"):SetID("worldQuest"):SetPath("quests):SetOrder(2)

--]]

function RegisterCategory(self, id, text, order, path, builder)
  tinsert(_CATEGORIES_INFO, {
    id = id,
    text = text,
    order = order or 10,
    path = path
  })

  _CATEGORIES_BUILDER[id] = builder
end


function SelectCategory(self, category)
  _CONTENT:ReleaseChildren()

  if not category then
    self:BuildAddonInfoCategory(_CONTENT)
    return
  end

  local builder = _CATEGORIES_BUILDER[category]
  if builder then
    if type(builder) == "function" then
      builder(_CONTENT)
    else
      builder:Build(_CONTENT)
    end
    OptionBuilder:SetVariable("category-selected", category)
  else
    self:BuildAddonInfoCategory(_CONTENT)
  end
end

__SystemEvent__ "EQT_REFRESH_OPTIONS"
function RefreshOptions()
  print("REFRESH OPTIONS")
  local category = OptionBuilder:GetVariable("category-selected")
  _M:SelectCategory(category)
end


function BuildTrackerCategory(content)
  local selectTheme = _AceGUI:Create("DropdownGroup")
  selectTheme:SetTitle("Select a theme to edit")
  selectTheme:SetFullWidth(true)
  selectTheme:SetGroupList({
    ["Transparence 1"] = "Transparence",
    ["Eska 2"] = "Eska",
  })

  local selectElement = _AceGUI:Create("TabGroup")
  selectElement:SetTabs({
    { value = "general", text = "General"},
    { value = "scrollbar", text = "Scrollbar" },
    { value = "scrollbar-thumb", text = "Scrollbar Thumb"}
  })
  selectElement:SetFullWidth(true)

  selectTheme:AddChild(selectElement)

  content:AddChild(selectTheme)
end


-- ========================================================================== --
-- == ADDON INFO CATEGORY
-- ========================================================================== --
function BuildAddonInfoCategory(self, content)
  -- Clear the content
  content:ReleaseChildren()
  -- Resume the layout
  content:ResumeLayout()

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

    local dependencies = {
      ["PLoop"] = {
        displayText = "|cff0094ffPLoop|r",
        version = _PLOOP_VERSION,
        state = select(2, _Addon:CheckPLoopVersion(false))
      },
      ["Scorpio"] = {
        displayText = "|cffff6a00Scorpio|r",
        version = _SCORPIO_VERSION,
        state = select(2, _Addon:CheckScorpioVersion(false))
      }
    }

    for libName, lib in pairs(dependencies) do

      local versionColor = "ff00ff00"

      if lib.state == DependencyState.OUTDATED then
        versionColor = "ffff0000"
      elseif lib.state == DependencyState.DEPRECATED then
        versionColor = "ffffd800"
      end

      local label = _AceGUI:Create("Label")
      label:SetText(lib.displayText)
      label:SetFont(font, fontSize)
      label:SetWidth(100)
      group:AddChild(label)

      local labelValue = _AceGUI:Create("Label")
      labelValue:SetText(string.format("|c%sv%d|r", versionColor, lib.version))
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

function AddTrackerRecipes(self)
  OptionBuilder:AddRecipe(TreeItemRecipe("Tracker", "Tracker/Children"):SetID("tracker"):SetOrder(10), "RootTree")
   OptionBuilder:AddRecipe(ThemeDropDownRecipe("Select a theme", "Tracker/SelectThemeToEdit/Children"), "Tracker/Children")
   OptionBuilder:AddRecipe(TabRecipe("", "Tracker/Tabs"):SetOrder(1), "Tracker/SelectThemeToEdit/Children")
   OptionBuilder:AddRecipe(TabItemRecipe("General", "Tracker/General"):SetID("general"):SetOrder(1), "Tracker/Tabs")
   OptionBuilder:AddRecipe(TabItemRecipe("Scrollbar", "Tracker/Scrollbar"):SetID("scrollbar"):SetOrder(2), "Tracker/Tabs")
   OptionBuilder:AddRecipe(TabItemRecipe("Scrollbar Thumb", "Tracker/ScrollbarThumb"):SetID("scrollbar-thumb"):SetOrder(3), "Tracker/Tabs")


   OptionBuilder:AddRecipe(SimpleGroupRecipe():SetRecipeGroup("Tracker/General/TopOptions"):SetOrder(1), "Tracker/General")
   OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Lock"):BindOption("tracker-locked"), "Tracker/General/TopOptions")
   OptionBuilder:AddRecipe(ButtonRecipe():SetText("Show/Hide"):OnClick(function()
     if _Addon.ObjectiveTracker:IsShown() then
       _Addon.ObjectiveTracker:Hide()
     else
       _Addon.ObjectiveTracker:Show()
     end
   end), "Tracker/General/TopOptions")

   OptionBuilder:AddRecipe(InlineGroupRecipe("Size", "Tracker/Size"):SetOrder(2), "Tracker/General")
   OptionBuilder:AddRecipe(RangeGroupRecipe():SetText("Width"):BindOption("tracker-width"):SetRange(200, 500), "Tracker/Size")
   OptionBuilder:AddRecipe(RangeGroupRecipe():SetText("Height"):BindOption("tracker-height"):SetRange(64, 1024), "Tracker/Size")

   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("tracker.frame"):SetRefresher("tracker/refresher"):SetOrder(3), "Tracker/General")
   --OptionBuilder:AddRecipe(RangeGroupRecipe())
   OptionBuilder:AddRecipe(InlineGroupRecipe("Blizzard Objective Tracker", "Blizzard/ObjectiveTracker"), "Tracker/General")
   OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Replace completely the blizzard objective tracker"):SetWidth(1.0):BindOption("replace-blizzard-objective-tracker"):SetOrder(4), "Blizzard/ObjectiveTracker")


   -- Tracker Scrollbar
   OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Show"):BindOption("tracker-show-scrollbar"):SetOrder(1), "Tracker/Scrollbar")
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("tracker.scrollbar"):SetRefresher("tracker/refresher"):SetOrder(2), "Tracker/Scrollbar")

   -- Tracker Scrollbar Thumb
   local ALL_TEXTURE_OPTIONS = ThemeElementRecipe.ALL_TEXTURE_OPTIONS
   local ALL_TEXT_OPTIONS = ThemeElementRecipe.ALL_TEXT_OPTIONS
   local ALL_FRAME_OPTIONS = ThemeElementRecipe.ALL_FRAME_OPTIONS

   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("tracker.scrollbar.thumb"):SetRefresher("tracker/refresher"):SetFlags(ALL_TEXTURE_OPTIONS), "Tracker/ScrollbarThumb")
end

function AddBlockRecipes(self)
  local ALL_TEXTURE_OPTIONS = ThemeElementRecipe.ALL_TEXTURE_OPTIONS
  local ALL_TEXT_OPTIONS = ThemeElementRecipe.ALL_TEXT_OPTIONS
  local ALL_FRAME_OPTIONS = ThemeElementRecipe.ALL_FRAME_OPTIONS

  OptionBuilder:AddRecipe(TreeItemRecipe("Blocks", "Blocks/Children"):SetID("blocks"):SetOrder(20), "RootTree")
    OptionBuilder:AddRecipe(ThemeDropDownRecipe("Select a theme", "Blocks/SelectThemeToEdit/Children"), "Blocks/Children")
    OptionBuilder:AddRecipe(TabRecipe("", "Blocks/Tabs"):SetOrder(1), "Blocks/SelectThemeToEdit/Children")
    OptionBuilder:AddRecipe(TabItemRecipe("General", "Blocks/General"):SetID("general"):SetOrder(1), "Blocks/Tabs")
    OptionBuilder:AddRecipe(TabItemRecipe("Header", "Blocks/Header"):SetID("scrollbar"):SetOrder(2), "Blocks/Tabs")
    OptionBuilder:AddRecipe(TabItemRecipe("Stripe", "Blocks/Stripe"):SetID("scrollbar-thumb"):SetOrder(3), "Blocks/Tabs")

    OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("block.frame"):SetRefresher("block/refresher"), "Blocks/General")

    OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("block.header"):SetRefresher("block/refresher"):SetFlags(ALL_FRAME_OPTIONS + ALL_TEXT_OPTIONS), "Blocks/Header")
    OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("block.stripe"):SetRefresher("block/refresher"):SetFlags(ALL_TEXTURE_OPTIONS), "Blocks/Stripe")
end


function AddObjectiveRecipes(self)
  local ALL_TEXTURE_OPTIONS = ThemeElementRecipe.ALL_TEXTURE_OPTIONS
  local ALL_TEXT_OPTIONS = ThemeElementRecipe.ALL_TEXT_OPTIONS
  local ALL_FRAME_OPTIONS = ThemeElementRecipe.ALL_FRAME_OPTIONS

  -- Objective
  OptionBuilder:AddRecipe(TreeItemRecipe("Objective", "Objective/Children"):SetID("objective"):SetOrder(50), "RootTree")
    OptionBuilder:AddRecipe(ThemeDropDownRecipe("", "Objective/SelectThemeToEdit/Children"), "Objective/Children")
    OptionBuilder:AddRecipe(TabRecipe("", "Objective/Tabs"):SetOrder(1), "Objective/SelectThemeToEdit/Children")
    OptionBuilder:AddRecipe(TabItemRecipe("General", "Objective/General"):SetID("general"):SetOrder(10), "Objective/Tabs")
    OptionBuilder:AddRecipe(TabItemRecipe("Square", "Objective/Square"):SetID("square"):SetOrder(20), "Objective/Tabs")

    --OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Enable text wrapping"):BindOption("objective-text-wrapping"):SetOrder(1), "Objective/General")

    OptionBuilder:AddRecipe(SelectStateRecipe():SetStates("completed", "progress"):SetRecipeGroup("Objective/General/States"), "Objective/General")
    OptionBuilder:AddRecipe(SelectStateRecipe():SetStates("completed", "progress"):SetRecipeGroup("Objective/Square/States"), "Objective/Square")

    OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("objective.frame"):SetRefresher("objective/refresher"):SetFlags(ALL_FRAME_OPTIONS + ALL_TEXT_OPTIONS), "Objective/General/States")
    OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("objective.square"):SetRefresher("objective/refresher"):SetFlags(ALL_FRAME_OPTIONS + ALL_TEXTURE_OPTIONS), "Objective/Square/States")
end


function AddItemBarRecipes(self)
  OptionBuilder:AddRecipe(TreeItemRecipe("Item Bar", "ItemBar/Children"):SetID("itembar"):SetOrder(60), "RootTree")

  local positions = {
    ["TOPLEFT"] = "Top Left",
    ["TOPRIGHT"] = "Top Right",
    ["BOTTOMLEFT"] = "Bottom Left",
    ["BOTTOMRIGHT"] = "Bottom Right"
  }
  OptionBuilder:AddRecipe(SelectRecipe():SetText("Position"):SetList(positions):BindOption("item-bar-position"):SetOrder(10), "ItemBar/Children")

  local growth = {
    ["RIGHT"] = "Left",
    ["LEFT"] = "Right",
    ["UP"] = "Up",
    ["DOWN"] = "Down",
  }
  OptionBuilder:AddRecipe(SelectRecipe():SetText("Direction growth"):SetList(growth):BindOption("item-bar-direction-growth"):SetOrder(20), "ItemBar/Children")
end

function AddMenuContextRecipes(self)
    OptionBuilder:AddRecipe(TreeItemRecipe("Menu Context", "MenuContext/Children"):SetID("menu-context"):SetOrder(70), "RootTree")

    local orientations = {
      ["LEFT"] = "RIGHT",
      ["RIGHT"] = "LEFT",
    }

    OptionBuilder:AddRecipe(SelectRecipe():SetText("Location"):SetList(orientations):BindOption("menu-context-orientation"), "MenuContext/Children")
end


function AddGroupFindersRecipes(self)
  OptionBuilder:AddRecipe(TreeItemRecipe("Group Finders", "GroupFinders/Children"):SetID("group-finders"):SetOrder(80), "RootTree")

  local list = {}
  for name in GroupFinderAddon:GetIterator() do
    list[name] = name
  end
  local addonSelected = select(2, GroupFinderAddon:GetSelected())

  local function OnValueChanged(value)
    GroupFinderAddon:SetSelected(value)
  end

  OptionBuilder:AddRecipe(SelectRecipe():SetText("Select a group finder"):SetValue(addonSelected):SetList(list):OnValueChanged(OnValueChanged), "GroupFinders/Children")
end

function AddProfilsRecipes(self)
  local text = "The profils options are not implemented and this will be done in a future update."

  OptionBuilder:AddRecipe(TreeItemRecipe("Profils", "Profils/Children"):SetID("profils"):SetOrder(100), "RootTree")
  OptionBuilder:AddRecipe(NotImplementedRecipe():SetText(text), "Profils/Children")

end
