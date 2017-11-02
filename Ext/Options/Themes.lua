-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                "EskaQuestTracker.Options.Theme"                       ""
--============================================================================--
namespace "EQT"
import "System.Reflector"
--============================================================================--
_THEME_ELEMENTS_CATEGORY_SELECTED = "Tracker"
_THEME_ELEMENT_SELECTED = "Frame"
_THEME_SELECTED = ""

function BuildThemeCategory(content, ...)
  -- [OPTION] Select a them
  local selectTheme = _AceGUI:Create("Dropdown")
  selectTheme:SetText(Themes:GetSelected().name)
  selectTheme:SetLabel("Select a theme")
  selectTheme:SetCallback("OnValueChanged", function(_, _, themeName)  Themes:Select(themeName) end)
  local themeList = {}
  local themeCount = 0
  for _, theme in Themes:GetIterator() do
    themeList[theme.name] = theme.name
    themeCount = themeCount + 1
  end
  selectTheme:SetList(themeList)
  content:AddChild(selectTheme)

  do
    local group = _AceGUI:Create("InlineGroup")
    group:SetTitle(string.format("Installed themes (%i)", themeCount))
    group:SetLayout("Flow")


    local label = _AceGUI:Create("EQT-ThemeButton")
    label:SetRelativeWidth(1.0)
    label:SetCallback("OnClick", function(...)
      _THEME_SELECTED = "Eska"
     _M:BuildTheme(content)
    end)

    local label2 = _AceGUI:Create("EQT-ThemeButton")
    label2:SetRelativeWidth(1.0)
    group:AddChild(label)
    group:AddChild(label2)

    content:AddChild(group)
  end
end

function ConvertToCategoryPath(self, uniquePath)
  local categoryPath = ""
  local categories = { strsplit("\001", uniquePath)}
  for index, category in ipairs(categories) do
    if index > 1 then
      categoryPath = categoryPath .. "/" .. category
    else
      categoryPath = category
    end
  end

  return categoryPath
end


function BuildTheme(self, content, themeID)
  -- Clear the current content
  content:ReleaseChildren()
  --content:SetAutoAdjustHeight(true)
  --content:SetLayout("Fill")

  local layout = _AceGUI:Create("SimpleGroup")
  layout:SetLayout("Fill")
  layout:SetFullHeight(true)
  layout:SetFullWidth(true)
  layout.frame:SetAllPoints(content.frame)

  local elementCategoriesTree = _AceGUI:Create("TreeGroup")
  elementCategoriesTree:SetTree(self:GetElementCategoriesTable())
  elementCategoriesTree:SetLayout("Fill")
  elementCategoriesTree:SetFullWidth(true)
  elementCategoriesTree:SetFullHeight(true)

  layout:AddChild(elementCategoriesTree)


    elementCategoriesTree:SetCallback("OnGroupSelected", function(_, _, uniquePath)
      local categoryPath = self:ConvertToCategoryPath(uniquePath)
      _THEME_ELEMENTS_CATEGORY_SELECTED = categoryPath
      self:BuildThemeElements(elementCategoriesTree)
    end)


  content:AddChild(layout)

  -- Select the default category or the previous selected
    local categoryPath = self:ConvertToCategoryPath(_THEME_ELEMENTS_CATEGORY_SELECTED)
    elementCategoriesTree:Select(_THEME_ELEMENTS_CATEGORY_SELECTED)
    self:BuildThemeElements(elementCategoriesTree)

end

--[[
function BuildTheme(self, content, themeID)
  -- Clean the current content
  content:ReleaseChildren()
  --content:SetLayout("Fill")
  content.frame:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
  content.frame:SetBackdropColor(1, 1, 0, 1)
  content:SetAutoAdjustHeight(true)

  local elementCategoriesTree = _AceGUI:Create("TreeGroup")
  elementCategoriesTree:SetTree(self:GetElementCategoriesTable())
  elementCategoriesTree:SetLayout("Fill")
  elementCategoriesTree:SetFullWidth(true)
  elementCategoriesTree:SelectByValue("Blocks")
  elementCategoriesTree:SetAutoAdjustHeight(true)
  elementCategoriesTree.frame:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
  elementCategoriesTree.frame:SetBackdropColor(1, 0, 0, 1)


  elementCategoriesTree:SetCallback("OnGroupSelected", function(_, _, uniquePath)
    local categoryPath = self:ConvertToCategoryPath(uniquePath)
    _THEME_ELEMENTS_CATEGORY_SELECTED = categoryPath
    self:BuildThemeElements(elementCategoriesTree)
    elementCategoriesTree:DoLayout()
  end)

  local selectedElement = _AceGUI:Create("DropdownGroup")
  selectedElement:SetTitle("Select an element")
  selectedElement:SetLayout("Flow")
  selectedElement:SetList(self:GetElementsByCategory(THEME_ELEMENTS_CATEGORY_SELECTED))
  selectedElement:SetRelativeWidth(1.0)
  elementCategoriesTree:AddChild(selectedElement)

  local label2 = _AceGUI:Create("EQT-ThemeButton")
  label2:SetRelativeWidth(0.5)
  selectedElement:AddChild(label2)
  self:BuildThemeElements(elementCategoriesTree)


  content:AddChild(elementCategoriesTree)

end

--]]

function BuildThemeElements(self, parent)
  -- Clean the parent content
  parent:ReleaseChildren()

  local elementList = self:GetElementsByCategory(_THEME_ELEMENTS_CATEGORY_SELECTED)

  local function GetElementIDByCategory(category)
    for k, v in pairs(elementList) do
      if v == category then
        return k
      end
    end
  end

  local selectedElement = _AceGUI:Create("DropdownGroup")
  selectedElement:SetTitle("Select an element")
  selectedElement:SetLayout("Flow")
  selectedElement:SetGroupList(elementList)
  selectedElement:SetFullWidth(true)
  --selectedElement:SetFullHeight(true)
  selectedElement:SetGroup("block.frame")
  selectedElement:SetCallback("OnGroupSelected", function(_, _, elementID)
    _THEME_ELEMENT_SELECTED = elementList[elementID]
    local recipe = self:GetThemeElementRecipe(elementID)
    if recipe then
      recipe:Build(selectedElement)
    end
  end)

  parent:AddChild(selectedElement)

  -- Select the default element or the previous element
  local selected = "Frame"
  local elementID = GetElementIDByCategory(_THEME_ELEMENT_SELECTED)
  if elementID then
    selected = _THEME_ELEMENT_SELECTED
  else
    elementID = GetElementIDByCategory(selected)
  end

  local recipe = self:GetThemeElementRecipe(elementID)
  if recipe then
    recipe:Build(selectedElement)
    selectedElement:SetGroup(elementID)
  end
end


function GetThemeRecipe(self, themeID)
  local themeRecipes = OptionBuilder:GetRecipes("Themes")
  if themeRecipes then
    for _, recipe in themeRecipes:GetIterator() do
      if recipe.id == themeID then
        return recipe
      end
    end
  end
end

function GetThemeElementRecipe(self, elementID)
  local elementRecipes = OptionBuilder:GetRecipes("Theme/Elements")
  if elementRecipes then
    for _, recipe in elementRecipes:GetIterator() do
      if recipe.elementID == elementID then
        return  recipe
      end
    end
  end
end

function GetElementsByCategory(self, category)
  local elements = {}
  if category and category ~= "" then
    local elementRecipes = OptionBuilder:GetRecipes("Theme/Elements")
    if elementRecipes then
      for _, recipe in elementRecipes:GetIterator() do
        if recipe.category == category then
          elements[recipe.elementID] = recipe.text
        end
      end
    end
  end

  return elements
end



function GetElementCategoriesTable(self)
  local list = {}
  local elementsTable = Dictionary()
  local elementRecipes = OptionBuilder:GetRecipes("Theme/Elements")

  if not elementRecipes then
    return list
  end

  for _, recipe in elementRecipes:GetIterator() do
    -- Check if recipe has a category
    if recipe.category and recipe.category ~= "" then
      local categories = { strsplit("/", recipe.category) }
      local currentPath = ""
      for index, category in ipairs(categories) do
        if index == 1 then
          currentPath = category
          -- if the category not exists, create it
          if not elementsTable[currentPath] then
            local t = {
              value = category,
              text = category,
            }
            -- Add into elements table list
            elementsTable[currentPath] = t
            -- Don't forget to register to root
            tinsert(list, t)
          end
        else
          -- Get the parent category table
          local parentTable = elementsTable[currentPath]
          -- Update the current path
          currentPath = currentPath .. "/" .. category

          -- if the category not exists, create it
          if not elementsTable[currentPath] then
            local t = { value = category, text = category }
            -- Add into element table list
            elementsTable[currentPath] = t
            -- Don't forget to register to its parent category table
            if not parentTable.children then parentTable.children = {} end
            tinsert(parentTable.children, t)
          end
        end
      end
    else
      local t = elementsTable[recipe.text]
      -- Check if the category is already created or not
      if not t then
        t = {  value = recipe.text, text = recipe.text }

        elementsTable[t.text] = t
        tinsert(list, t)
      end
    end
  end

  return list
end



function OnLoad(self)
  self:RegisterCategory("Themes", "Themes", 100, BuildThemeCategory)
end


class "ThemeElementRecipe" inherit "OptionRecipe"

  __Flags__()
  enum "OptionFlags" {
    "FRAME_BACKGROUND_COLOR",
    "FRAME_BORDER_COLOR",
    -- TEXT Optons
    "TEXT_SIZE",
    "TEXT_COLOR",
    "TEXT_FONT",
    "TEXT_TRANSFORM",
    -- TEXTURE Options
    "TEXTURE_COLOR"
  }

  __Static__() property "ALL_FRAME_OPTIONS" {
    DEFAULT = OptionFlags.FRAME_BACKGROUND_COLOR + OptionFlags.FRAME_BORDER_COLOR,
    SET = false
  }

  __Static__() property "ALL_TEXT_OPTIONS" {
    DEFAULT = OptionFlags.TEXT_SIZE + OptionFlags.TEXT_COLOR + OptionFlags.TEXT_FONT + OptionFlags.TEXT_TRANSFORM,
    SET = false
  }

  __Static__() property "ALL_TEXTURE_OPTIONS" {
    DEFAULT = OptionFlags.TEXTURE_COLOR,
    SET = false
  }


  __Static__() property "ALL_OPTIONS" {
    DEFAULT = function() return ThemeElementRecipe.ALL_FRAME_OPTIONS + ThemeElementRecipe.ALL_TEXT_OPTIONS + ThemeElementRecipe.ALL_TEXTURE_OPTIONS end,
    SET = false
  }

  -- ALL_TEXT_OPTIONS = OptionFlags.TEXT_SIZE + OptionFlags.TEXT_COLOR
  function Build(self, parent)
    -- Clean the parent content
    parent:ReleaseChildren()

    -- Get the theme selected
    local theme = Themes:Get(_THEME_SELECTED)

    if not theme then return end


    local function CreateGroup(name)
      local g = _AceGUI:Create("InlineGroup")
      g:SetLayout("Flow")
      g:SetTitle(name)
      g:SetRelativeWidth(1.0)
      return g
    end

    local function CreateRow(name, valueFrame)
      local layout = _AceGUI:Create("SimpleGroup")
      layout:SetRelativeWidth(1.0)
      layout:SetLayout("Flow")

      local label = _AceGUI:Create("Label")
      label:SetRelativeWidth(0.3)
      label:SetFontObject(GameFontHighlight)
      label:SetText(name)
      layout:AddChild(label)

      valueFrame:SetRelativeWidth(0.3)
      layout:AddChild(valueFrame)

      local space = _AceGUI:Create("Label")
      space:SetRelativeWidth(0.1)
      space:SetText("")
      layout:AddChild(space)

      local reset = _AceGUI:Create("Button")
      reset:SetWidth(75)
      reset:SetText("Reset")

      return layout
    end

    local function ShowReset(layout, property, refresh)
      local reset = layout:GetUserData("reset")
      if not reset then
        reset = _AceGUI:Create("Button")
        reset:SetWidth(75)
        reset:SetText("Reset")
        reset:SetCallback("OnClick", function(reset)
          reset.frame:Hide()
          theme:SetElementPropertyToDB(self.elementID, property, nil)
          refresh()
        end)

        layout:AddChild(reset)
        layout:SetUserData("reset", reset)
      end
      reset.frame:Show()
      return reset
    end

    do
      local hasFrameBackgroundColor = ValidateFlags(self.options, OptionFlags.FRAME_BACKGROUND_COLOR)
      local hasFrameBorderColor = ValidateFlags(self.options, OptionFlags.FRAME_BORDER_COLOR)
      -- If there is a frame option, create the group
      if hasFrameBackgroundColor or hasFrameBorderColor then
        local group = CreateGroup("Frame properties")
        parent:AddChild(group)

        if hasFrameBackgroundColor then
          local backgroundColor = _AceGUI:Create("ColorPicker")
          backgroundColor:SetHasAlpha(true)

          local color = theme:GetElementProperty(self.elementID, "background-color", self.inheritElementID)
          backgroundColor:SetColor(color.r, color.g, color.b, color.a)

          local row = CreateRow("Background Color", backgroundColor)
          group:AddChild(row)

          local function refresh()
            local color = theme:GetElementProperty(self.elementID, "background-color", self.inheritElementID)
            backgroundColor:SetColor(color.r, color.g, color.b, color.a)
            self:RefreshElements(Theme.SkinFlags.FRAME_BACKGROUND_COLOR)
          end

          if theme:GetElementPropertyFromDB(self.elementID, "background-color") then
            ShowReset(row, "background-color", refresh)
          end

          backgroundColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
            ShowReset(row, "background-color", refresh)
            theme:SetElementPropertyToDB(self.elementID, "background-color", { r = r, g = g, b = b, a = a})
            self:RefreshElements(Theme.SkinFlags.FRAME_BACKGROUND_COLOR)
          end)

          backgroundColor:SetCallback("OnValueConfirmed", function(_, _, r, g, b, a)
            ShowReset(row, "background-color", refresh)
            theme:SetElementPropertyToDB(self.elementID, "background-color", { r = r, g = g, b = b, a = a})
            self:RefreshElements(Theme.SkinFlags.FRAME_BACKGROUND_COLOR)
          end)
        end

        if hasFrameBorderColor then
          local borderColor = _AceGUI:Create("ColorPicker")
          borderColor:SetHasAlpha(true)

          local color = theme:GetElementProperty(self.elementID, "border-color", self.inheritElementID)
          borderColor:SetColor(color.r, color.g, color.b, color.a)

          local row = CreateRow("Border Color", borderColor)
          group:AddChild(row)

          local function refresh()
            local color = theme:GetElementProperty(self.elementID, "border-color", self.inheritElementID)
            borderColor:SetColor(color.r, color.g, color.b, color.a)
            self:RefreshElements(Theme.SkinFlags.FRAME_BORDER_COLOR)
          end

          if theme:GetElementPropertyFromDB(self.elementID, "border-color") then
            ShowReset(row, "border-color", refresh)
          end

          borderColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
            ShowReset(row, "border-color", refresh)
            theme:SetElementPropertyToDB(self.elementID, "border-color", { r = r, g = g, b = b, a = a})
            self:RefreshElements(Theme.SkinFlags.FRAME_BORDER_COLOR)
          end)

          borderColor:SetCallback("OnValueConfirmed", function(_, _, r, g, b, a)
            ShowReset(row, "border-color", refresh)
            theme:SetElementPropertyToDB(self.elementID, "border-color", { r = r, g = g, b = b, a = a})
            self:RefreshElements(Theme.SkinFlags.FRAME_BORDER_COLOR)
          end)
        end
      end
    end

    do
      local hasTextSize = ValidateFlags(self.options, OptionFlags.TEXT_SIZE)
      local hasTextColor = ValidateFlags(self.options, OptionFlags.TEXT_COLOR)
      local hasTextFont = ValidateFlags(self.options, OptionFlags.TEXT_FONT)
      local hasTextTransform = ValidateFlags(self.options, OptionFlags.TEXT_TRANSFORM)
      if hasTextSize or hasTextColor or hasTextFont or hasTextTransform then
        local group = CreateGroup("Text properties")
        parent:AddChild(group)

        if hasTextColor then
          local textColor = _AceGUI:Create("ColorPicker")
          textColor:SetHasAlpha(true)

          local color = theme:GetElementProperty(self.elementID, "text-color", self.inheritElementID)
          textColor:SetColor(color.r, color.g, color.b, color.a)

          local row = CreateRow("Text Color", textColor)
          group:AddChild(row)

          local function refresh()
            local color = theme:GetElementProperty(self.elementID, "text-color", self.inheritElementID)
            textColor:SetColor(color.r, color.g, color.b, color.a)
            self:RefreshElements(Theme.SkinFlags.TEXT_COLOR)
          end
          if theme:GetElementPropertyFromDB(self.elementID, "text-color") then
            ShowReset(row, "text-color", refresh)
          end

          textColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
            ShowReset(row, "text-color", refresh)
            theme:SetElementPropertyToDB(self.elementID, "text-color", { r = r, g = g, b = b, a = a})
            self:RefreshElements(Theme.SkinFlags.TEXT_COLOR)
          end)

          textColor:SetCallback("OnValueConfirmed", function(_, _, r, g, b, a)
            ShowReset(row, "text-color", refresh)
            theme:SetElementPropertyToDB(self.elementID, "text-color", { r = r, g = g, b = b, a = a})
            self:RefreshElements(Theme.SkinFlags.TEXT_COLOR)
          end)
        end

        if hasTextSize then

          local textSize = _AceGUI:Create("Slider")
          textSize:SetRelativeWidth(0.3)
          textSize:SetSliderValues(6, 32, 1)
          textSize:SetValue(theme:GetElementProperty(self.elementID, "text-size", self.inheritElementID))

          local row = CreateRow("Text Size", textSize)
          group:AddChild(row)
          local function refresh()
            textSize:SetValue(theme:GetElementProperty(self.elementID, "text-size", self.inheritElementID))
            self:RefreshElements(Theme.SkinFlags.TEXT_SIZE)
          end

          if theme:GetElementPropertyFromDB(self.elementID, "text-size") then
            ShowReset(row, "text-size", refresh)
          end

          textSize:SetCallback("OnValueChanged", function(_, _, size)
            ShowReset(row, "text-size", refresh)
            theme:SetElementPropertyToDB(self.elementID, "text-size", size)
            self:RefreshElements(Theme.SkinFlags.TEXT_SIZE)
           end)
           textSize:SetCallback("OnValueConfirmed", function(_, _, size)
             ShowReset(row, "text-size", refresh)
             theme:SetElementPropertyToDB(self.elementID, "text-size", size)
             self:RefreshElements(Theme.SkinFlags.TEXT_SIZE)
            end)
        end

        if hasTextFont then
          local textFont = _AceGUI:Create("Dropdown")
          textFont:SetList(_Fonts, nil, "DDI-Font")
          textFont:SetValue(GetFontIndex(theme:GetElementProperty(self.elementID, "text-font", self.inheritElementID)))

          local row = CreateRow("Text Font", textFont)
          group:AddChild(row)

          local function refresh() textFont:SetValue(GetFontIndex(theme:GetElementProperty(self.elementID, "text-font", self.inheritElementID))) ; self:RefreshElements(Theme.SkinFlags.TEXT_FONT) end

          if theme:GetElementPropertyFromDB(self.elementID, "text-font") then
            ShowReset(row, "text-font", refresh)
          end

          textFont:SetCallback("OnValueChanged", function(_, _, value)
            ShowReset(row, "text-font", refresh)
            theme:SetElementPropertyToDB(self.elementID, "text-font", _Fonts[value])
            self:RefreshElements(Theme.SkinFlags.TEXT_FONT)
          end)
        end

        if hasTextTransform then
          local textTransform = _AceGUI:Create("Dropdown")
          textTransform:SetList(_TextTransforms)
          textTransform:SetValue(theme:GetElementProperty(self.elementID, "text-transform", self.inheritElementID))

          local row = CreateRow("Text Transform", textTransform)
          group:AddChild(row)

          local function refresh() textTransform:SetValue(theme:GetElementProperty(self.elementID, "text-transform", self.inheritElementID)) ; self:RefreshElements(Theme.SkinFlags.TEXT_TRANSFORM) end

          if theme:GetElementPropertyFromDB(self.elementID, "text-transform") then
            ShowReset(row, "text-transform", refresh)
          end

          textTransform:SetCallback("OnValueChanged", function(_, _, transform)
            ShowReset(row, "text-transform", refresh)
            theme:SetElementPropertyToDB(self.elementID, "text-transform", transform)
            self:RefreshElements(Theme.SkinFlags.TEXT_TRANSFORM)
          end)
        end
      end
    end
  end

--[[
  function Build(self, parent)
    print("[BUILD]", self.elementID)
    -- Clean the parent content
    parent:ReleaseChildren()

    local function CreateGroup(name)
      local g = _AceGUI:Create("InlineGroup")
      g:SetLayout("Flow")
      g:SetTitle(name)
      g:SetRelativeWidth(1.0)
      return g
    end

    do
      local hasFrameBackgroundColor = ValidateFlags(self.options, OptionFlags.FRAME_BACKGROUND_COLOR)
      local hasFrameBorderColor = ValidateFlags(self.options, OptionFlags.FRAME_BORDER_COLOR)
      -- If there is a frame option, create the group
      if hasFrameBackgroundColor or hasFrameBorderColor then
        local group = CreateGroup("Frame")
        parent:AddChild(group)

        if hasFrameBackgroundColor then
          local backgroundColor = _AceGUI:Create("ColorPicker")
          backgroundColor:SetHasAlpha(true)
          backgroundColor:SetRelativeWidth(1.0)
          backgroundColor:SetLabel("Background Color")
          group:AddChild(backgroundColor)
        end

        if hasFrameBorderColor then
          local borderColor = _AceGUI:Create("ColorPicker")
          borderColor:SetHasAlpha(true)
          borderColor:SetRelativeWidth(1.0)
          borderColor:SetLabel("Border Color")
          group:AddChild(borderColor)
        end

        if hasFrameBorderColor then
          local g = _AceGUI:Create("SimpleGroup")
          g:SetLayout("Flow")
          g:SetRelativeWidth(1.0)

          local toggle = _AceGUI:Create("CheckBox")
          toggle:SetLabel("Text Font")
          toggle:SetRelativeWidth(0.4)

          local textFont = _AceGUI:Create("Dropdown")
          textFont:SetRelativeWidth(0.6)
          textFont:SetList({
            ["Arial"] = "none",
            ["LOL"] = "uppercase",
            ["Lowercase"] = "lowercase",
          })
          --textFont:SetLabel("Text Font")
          group:AddChild(textFont)

          g:AddChild(toggle)
          g:AddChild(textFont)
          group:AddChild(g)
        end
      end
    end

    do
      local hasTextSize = ValidateFlags(self.options, OptionFlags.TEXT_SIZE)
      local hasTextColor = ValidateFlags(self.options, OptionFlags.TEXT_COLOR)
      local hasTextFont = ValidateFlags(self.options, OptionFlags.TEXT_FONT)
      local hasTextTransform = ValidateFlags(self.options, OptionFlags.TEXT_TRANSFORM)
      if hasTextSize or hasTextColor or hasTextFont or hasTextTransform then
        local group = CreateGroup("Text")
        parent:AddChild(group)

        if hasTextColor then
          local textColor = _AceGUI:Create("ColorPicker")
          textColor:SetHasAlpha(true)
          textColor:SetLabel("Text Color")
          group:AddChild(textColor)
        end

        if hasTextSize then
          local textSize = _AceGUI:Create("Slider")
          textSize:SetSliderValues(6, 32, 1)
          textSize:SetLabel("Text Size")
          group:AddChild(textSize)
        end

        if hasTextFont then
          local textFont = _AceGUI:Create("Dropdown")
          textFont:SetList({
            ["Arial"] = "none",
            ["LOL"] = "uppercase",
            ["Lowercase"] = "lowercase",
          })
          textFont:SetLabel("Text Font")
          group:AddChild(textFont)
        end
      end
    end
  end
  --]]

  __Arguments__ {  Argument(Theme.SkinFlags, true, 127) }
  function RefreshElements(self, flags)
    if self.refresherIsGroup then
      Continue(function()
        local startTime = debugprofilestop()
        CallbackHandlers:CallGroup(self.refresher)
         print(format("myFunction executed in %f ms", debugprofilestop()-startTime))
      end)
    else
      Continue(function()
        --   local startTime = debugprofilestop()
        CallbackHandlers:Call(self.refresher, flags)
        --print(format("myFunction executed in %f ms", debugprofilestop()-startTime))
      end)
    end
  end

  __Arguments__ { String, Argument(Boolean, true, false)}
  function SetRefresher(self, refresher, isGroup)
    self.refresher = refresher
    self.refresherIsGroup = isGroup

    return self
  end


  property "elementID" { TYPE = String }
  property "text" { TYPE = String }
  property "inheritedFromElement" { TYPE = String }
  property "category" { TYPE = String }
  property "options" { TYPE = OptionFlags, DEFAULT = function() return ThemeElementRecipe.ALL_FRAME_OPTIONS + ThemeElementRecipe.ALL_TEXT_OPTIONS end }
  property "refresher" { TYPE = String, DEFAULT = "refresher"}
  property "refresherIsGroup" { TYPE = Boolean, DEFAULT = true}

  __Arguments__{ String, String, Argument(String, true, "Frame"), Argument(String, true) }
  function ThemeElementRecipe(self, elementID, category, text, inheritedFromElement)
    self.elementID = elementID
    self.text = text
    self.category = category
    self.inheritedFromElement = inheritedFromElement
  end

  __Arguments__{}
  function ThemeElementRecipe()

  end

endclass "ThemeElementRecipe"


class "ThemeRecipe" inherit "OptionRecipe"
  function Build(self, parent)
    -- Clean the parent content
    parent:ReleaseChildren()
  end

  property "id" { TYPE = String }
  property "name" { TYPE = String }
  property "author" { TYPE = String }
  property "version" { TYPE = String }
  property "stage" { TYPE = String, DEFAULT = "Release" }

  function ThemeRecipe(self, id, name, author, version, stage)
    self.name = name
    self.id = id
    self.author = author
    self.version = version
  end
endclass "ThemeRecipe"


-- Tracker
--local trackerFrame = ThemeElementRecipe()
--trackerFrame.elementID = "tracker.frame"
--trackerFrame.text = "Frame"
--trackerFrame.category = "Tracker"
--trackerFrame:SetRefresher("tracker/refresher")
--strackerFrame.refresher = "tracker/refresher"
--trackerFrame.refresherIsGroup = false
--OptionBuilder:AddThemeElementRecipe(trackerFrame)

--[[
local trackerHeader = ThemeElementRecipe()
trackerHeader.elementID = "tracker.header"
trackerHeader.text = "Header"
trackerHeader.category = "Tracker"
OptionBuilder:AddThemeElementRecipe(trackerHeader)

local trackerStripe = ThemeElementRecipe()
trackerStripe.elementID = "tracker.stripe"
trackerStripe.text = "Stripe"
trackerStripe.category = "Tracker"
OptionBuilder:AddThemeElementRecipe(trackerStripe) --]]

-- Tracker
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("tracker.frame", "Tracker"):SetRefresher("tracker/refresher"))

-- Blocks
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("block.frame", "Blocks"):SetRefresher("block/refresher"))
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("block.header", "Blocks", "Header"):SetRefresher("block/refresher"))
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("block.stripe", "Blocks", "Stripe"):SetRefresher("block/refresher"))

-- Block scenario
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("block.scenario.frame", "Blocks/Scenario", "Frame"))
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("block.scenario.stage", "Blocks/Scenario", "Stage"))
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("block.scenario.stageName", "Blocks/Scenario", "Stage Name"))
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("block.scenario.stageCounter", "Blocks/Scenario", "Stage Counter"))

-- Block dungeon
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("block.dungeon.frame", "Blocks/Dungeon", "Frame"))
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("block.dungeon.name", "Blocks/Dungeon", "Name"))
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("block.dungeon.icon", "Blocks/Dungeon", "Icon"))

-- Block dungeon
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("block.keystone.frame", "Blocks/Keystone", "Frame"))
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("block.keystone.name", "Blocks/Keystone", "Name"))
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("block.keystone.icon", "Blocks/Keystone", "Icon"))
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("block.keystone.level", "Blocks/Keystone", "Level"))


-- Quest
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("quest.frame", "Quest"))
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("quest.header", "Quest", "Header"))

-- Objective
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("objective.frame", "Objectives"):SetRefresher("objective/refresher"))
OptionBuilder:AddThemeElementRecipe(ThemeElementRecipe("objective.square", "Objectives", "Square"):SetRefresher("objective/refresher"))



--[[
local element = ThemeElementRecipe()
element.elementID = "block.dungeon"
element.text = "Frame"
element.inheritedFromElement = "block"
element.category = "Blocks/Dungeon"

local elementTwo = ThemeElementRecipe()
elementTwo.elementID = "block.dungeon.header"
elementTwo.text = "Header"
elementTwo.inheritedFromElement = "blocK.header"
elementTwo.category = "Blocks/Dungeon"
elementTwo.options = elementTwo.options - ThemeElementRecipe.OptionFlags.TEXT_SIZE


local elementThree = ThemeElementRecipe()
elementThree.elementID = "block.frame"
elementThree.text = "Frame"
elementThree.inheritedFromElement = "block.header"
elementThree.category = "Blocks" --]]



--OptionBuilder:AddThemeElementRecipe(element)
--OptionBuilder:AddThemeElementRecipe(elementTwo)
--OptionBuilder:AddThemeElementRecipe(elementThree)
