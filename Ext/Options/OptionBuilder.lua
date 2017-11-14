-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio           "EskaQuestTracker.Options.OptionBuilder"                    ""
--============================================================================--
namespace "EQT"
import "System.Reflector"
--============================================================================--
__Flags__()
enum "TextOptionFlags" {
  TEXT_FONT_OPTION = 1,
  TEXT_SIZE_OPTION = 2,
  TEXT_COLOR_OPTION = 4,
  TEXT_TRANSFORM_OPTION = 8,
}


--------------------------------------------------------------------------------
--                        Recipe                                              --
--------------------------------------------------------------------------------
__Abstract__()
class "OptionRecipe"


  __Require__()
  function Build(self, optTable) end

  __Arguments__ { Number }
  function SetOrder(self, order)
    self.order = order
    return self
  end

  __Arguments__ { String }
  function SetID(self, id)
    self.id = id
    return self
  end

  __Arguments__ { String}
  function SetRecipeGroup(self, recipeGroup)
    self.recipeGroup = recipeGroup
    return self
  end

  __Arguments__ { String }
  function SetText(self, text)
    self.text = text
    return self
  end

  property "order" { TYPE = Number, DEFAULT = 50 }
  property "recipeGroup" { TYPE = String, DEFAULT = nil }
  property "id" { TYPE = String, DEFAULT = nil }
  property "text" { TYPE = String, DEFAULT = "" }

  __Arguments__ { String, String }
  function OptionRecipe(self, text, recipeGroup)
    self.text = text
    self.recipeGroup = recipeGroup
  end

  __Arguments__ {}
  function OptionRecipe(self)

  end

endclass "OptionRecipe"

--[[
class "OptionTableRecipe"
  function Build(self) end

  property "optionTable" { TYPE = Table, }

  function OptionTableRecipe(self, optTable, order)
    self.order = order
  end


endclass "OptionTableRecipe"
--]]

class "TreeItemRecipe" inherit "OptionRecipe"

  function Build(self, parent)
    if not self.recipeGroup then
      return
    end

    local recipes = OptionBuilder:GetRecipes(self.recipeGroup)
    if recipes then
      for index, recipe in recipes:GetIterator() do
        recipe:Build(parent)
      end
    end

  end

  function SetPath(self, path)
    self.path = path
    return self
  end

  property "path" { TYPE = String }

endclass "TreeItemRecipe"

class "ThemeDropDownRecipe" inherit "OptionRecipe"

  function Build(self, parent)
      parent:ReleaseChildren()

      local themeSelected = OptionBuilder:GetVariable("theme-selected")

      local themeList = {}
      for _, theme in Themes:GetIterator() do
        themeList[theme.name] = theme.name
      end

      local selectTheme = _AceGUI:Create("DropdownGroup")
      selectTheme:SetTitle("Select a theme to edit")
      selectTheme:SetLayout("Flow")
      selectTheme:SetFullWidth(true)
      --selectTheme:SetFullHeight(true)
      selectTheme:SetGroupList(themeList)
      selectTheme:SetGroup(themeSelected)

      local function BuildChildren()
        if not self.recipeGroup then
          return
        end

        local recipes = OptionBuilder:GetRecipes(self.recipeGroup)
        if recipes then
          for index, recipe in recipes:GetIterator() do
            recipe:Build(selectTheme)
          end
        end
      end

      selectTheme:SetCallback("OnGroupSelected", function(_, _, theme)
        OptionBuilder:SetVariable("theme-selected", theme)
        selectTheme:ReleaseChildren()
        BuildChildren()
      end)

      BuildChildren()

      parent:AddChild(selectTheme)

  end

endclass "ThemeDropDownRecipe"

class "TabRecipe" inherit "OptionRecipe"

  function Build(self, parent)
      if not self.recipeGroup then
        return
      end

      local frame = _AceGUI:Create("TabGroup")
      frame:SetLayout("Flow")
      frame:SetFullWidth(true)
      --frame:SetFullHeight(true)

      local recipeCache = setmetatable({}, {__mode = "v"})
      local firstRecipe

      local recipes = OptionBuilder:GetRecipes(self.recipeGroup)
      if recipes then
        local tabs = {}
        for index, recipe in recipes:GetIterator() do
          if index == 1 then
            firstRecipe = recipe
          end

          tinsert(tabs, {
            value = recipe.id,
            text = recipe.text
          })
          recipeCache[recipe.id] = recipe
        end
        frame:SetTabs(tabs)

        local function SelectTab(id)
          local recipe = recipeCache[id]
          if recipe then
            frame:ReleaseChildren()
            recipe:Build(frame)
            parent:DoLayout()
          end
        end

        frame:SetCallback("OnGroupSelected", function(_, _, group)
          SelectTab(group)
        end)

        if firstRecipe then
          frame:SelectTab(firstRecipe.id)
        end
      end

      parent:AddChild(frame)
  end

endclass "TabRecipe"

class "TabItemRecipe" inherit "OptionRecipe"
  function Build(self, parent)
    parent:ReleaseChildren()

    if not self.recipeGroup then
      return
    end

    local recipes = OptionBuilder:GetRecipes(self.recipeGroup)
    if recipes then
      for index, recipe in recipes:GetIterator() do
        recipe:Build(parent)
      end
    end
  end

  function TabItemRecipe(self, text, recipeGroup)
    self.text = text
    self.recipeGroup = recipeGroup
  end

endclass "TabItemRecipe"

interface "InstallOptionHandler"

  function SetOption(self, value)
    if self.option then
      Options:Set(self.option, value, nil, self.passArg)
    end
  end

  function GetOption(self)
    if self.option then
      return Options:Get(self.option)
    end
  end

  function BindOption(self, option, passArg)
    self.option = option
    self.passArg = passArg
    return self
  end

  property "option" { String }

endinterface "InstallOptionHandler"

interface "InstallFrameRecipe"
  function SetWidth(self, width)
    self.width = width
    return self
  end

  function GetWidth(self)
    return self.width
  end

endinterface "InstallFrameRecipe"

class "CheckBoxRecipe" inherit "OptionRecipe" extend "InstallOptionHandler"
  function Build(self, parent)
    local checkbox = _AceGUI:Create("CheckBox")
    checkbox:SetLabel(self.text)
    checkbox:SetValue(self:GetOption())

    checkbox:SetCallback("OnValueChanged", function(_, _, value) self:SetOption(value) end)

    if self.width then
      if self.width > 0  and  self.width <= 1 then
        checkbox:SetRelativeWidth(self.width)
      else
        checkbox:SetWidth(self.width)
      end
    end

    parent:AddChild(checkbox)
  end

  function SetWidth(self, width)
    self.width = width
    return self
  end

  --[[__Arguments__ { Argument(Number, true) }
  function CheckBoxRecipe(self, width)
    Super(self)
    self.width = width

  end--]]

endclass "CheckBoxRecipe"

class "ButtonRecipe" inherit "OptionRecipe"
  function Build(self, parent)
    local button = _AceGUI:Create("Button")
    button:SetText(self.text)

    button:SetCallback("OnClick", function() if self.onClick then self.onClick() end end)

    parent:AddChild(button)
  end

  function OnClick(self, handler)
    self.onClick = handler
    return self
  end

endclass "ButtonRecipe"

class "InlineGroupRecipe" inherit "OptionRecipe"
  function Build(self, parent)
    local group = _AceGUI:Create("InlineGroup")
    group:SetTitle(self.text)
    group:SetLayout("Flow")
    group:SetFullWidth(true)
    parent:AddChild(group)

    if not self.recipeGroup then
      return
    end

    local recipes = OptionBuilder:GetRecipes(self.recipeGroup)
    if recipes then
      for index, recipe in recipes:GetIterator() do
        recipe:Build(group)
      end
    end
  end

endclass "InlineGroupRecipe"

class "RangeGroupRecipe" inherit "OptionRecipe" extend "InstallOptionHandler"
  function Build(self, parent)
    local range = _AceGUI:Create("Slider")
    range:SetSliderValues(self.min, self.max, self.step)
    range:SetLabel(self.text)
    range:SetValue(self:GetOption() or 0)
    range:SetCallback("OnValueChanged", function(_, _, value) self:SetOption(value) end)

    parent:AddChild(range)
  end

  function SetRange(self, min, max)
    self.min = min
    self.max = max
    return self
  end

  function SetStep(self, step)
    self.step = step
    return self
  end

  property "min" { TYPE = Number, DEFAULT = 0 }
  property "max" { TYPE = Number, DEFAULT = 100 }
  property "step" { TYPE = Number, DEFAULT = 1 }


endclass "RangeGroupRecipe"

class "SimpleGroupRecipe" inherit "OptionRecipe"
  function Build(self, parent)
    local group = _AceGUI:Create("SimpleGroup")
    --group:SetTitle("")
    group:SetFullWidth(true)
    group:SetLayout("Flow")

    --group.content:SetPoint("TOPLEFT", 8, 2)
    --group.content:SetPoint("BOTTOMRIGHT", -2, -2)
    --group.frame:SetBackdropBorderColor(0, 0, 0, 0)

    parent:AddChild(group)

    if not self.recipeGroup then
      return
    end

    local recipes = OptionBuilder:GetRecipes(self.recipeGroup)
    if recipes then
      for index, recipe in recipes:GetIterator() do
        recipe:Build(group)
      end
    end
  end

endclass "SimpleGroupRecipe"


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

  function Build(self, parent)
    -- Get the theme selected
    local themeSelected = OptionBuilder:GetVariable("theme-selected")
    local theme = Themes:Get(themeSelected)

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
      --layout.frame:SetBackdropBorderColor(0, 0, 0, 0)

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
      local hasFrameBackgroundColor = ValidateFlags(self.flags, OptionFlags.FRAME_BACKGROUND_COLOR)
      local hasFrameBorderColor = ValidateFlags(self.flags, OptionFlags.FRAME_BORDER_COLOR)
      -- If there is a frame option, create the group
      if hasFrameBackgroundColor or hasFrameBorderColor then
        local group = CreateGroup("Frame properties")
        parent:AddChild(group)

        if hasFrameBackgroundColor then
          local backgroundColor = _AceGUI:Create("ColorPicker")
          backgroundColor:SetHasAlpha(true)

          local color = theme:GetElementProperty(self.elementID, "background-color", self.inheritedFromElement)
          backgroundColor:SetColor(color.r, color.g, color.b, color.a)

          local row = CreateRow("Background Color", backgroundColor)
          group:AddChild(row)

          local function refresh()
            local color = theme:GetElementProperty(self.elementID, "background-color", self.inheritedFromElement)
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

          local color = theme:GetElementProperty(self.elementID, "border-color", self.inheritedFromElement)
          borderColor:SetColor(color.r, color.g, color.b, color.a)

          local row = CreateRow("Border Color", borderColor)
          group:AddChild(row)

          local function refresh()
            local color = theme:GetElementProperty(self.elementID, "border-color", self.inheritedFromElement)
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
      local hasTextSize = ValidateFlags(self.flags, OptionFlags.TEXT_SIZE)
      local hasTextColor = ValidateFlags(self.flags, OptionFlags.TEXT_COLOR)
      local hasTextFont = ValidateFlags(self.flags, OptionFlags.TEXT_FONT)
      local hasTextTransform = ValidateFlags(self.flags, OptionFlags.TEXT_TRANSFORM)
      if hasTextSize or hasTextColor or hasTextFont or hasTextTransform then
        local group = CreateGroup("Text properties")
        parent:AddChild(group)

        if hasTextColor then
          local textColor = _AceGUI:Create("ColorPicker")
          textColor:SetHasAlpha(true)

          local color = theme:GetElementProperty(self.elementID, "text-color", self.inheritedFromElement)
          textColor:SetColor(color.r, color.g, color.b, color.a)

          local row = CreateRow("Text Color", textColor)
          group:AddChild(row)

          local function refresh()
            local color = theme:GetElementProperty(self.elementID, "text-color", self.inheritedFromElement)
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
          textSize:SetValue(theme:GetElementProperty(self.elementID, "text-size", self.inheritedFromElement))

          local row = CreateRow("Text Size", textSize)
          group:AddChild(row)
          local function refresh()
            textSize:SetValue(theme:GetElementProperty(self.elementID, "text-size", self.inheritedFromElement))
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
          textFont:SetValue(GetFontIndex(theme:GetElementProperty(self.elementID, "text-font", self.inheritedFromElement)))

          local row = CreateRow("Text Font", textFont)
          group:AddChild(row)

          local function refresh() textFont:SetValue(GetFontIndex(theme:GetElementProperty(self.elementID, "text-font", self.inheritedFromElement))) ; self:RefreshElements(Theme.SkinFlags.TEXT_FONT) end

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
          textTransform:SetValue(theme:GetElementProperty(self.elementID, "text-transform", self.inheritedFromElement))

          local row = CreateRow("Text Transform", textTransform)
          group:AddChild(row)

          local function refresh() textTransform:SetValue(theme:GetElementProperty(self.elementID, "text-transform", self.inheritedFromElement)) ; self:RefreshElements(Theme.SkinFlags.TEXT_TRANSFORM) end

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
    do
      local hasTextureColor = ValidateFlags(self.flags, OptionFlags.TEXTURE_COLOR)
      if hasTextureColor then
        local group = CreateGroup("Texture properties")
        parent:AddChild(group)

        local textureColor = _AceGUI:Create("ColorPicker")
        textureColor:SetHasAlpha(true)

        local color = theme:GetElementProperty(self.elementID, "texture-color", self.inheritedFromElement)
        textureColor:SetColor(color.r, color.g, color.b, color.a)

        local row = CreateRow("Texture Color", textureColor)
        group:AddChild(row)

        local function refresh()
          local color = theme:GetElementProperty(self.elementID, "texture-color", self.inheritedFromElement)
          textureColor:SetColor(color.r, color.g, color.b, color.a)
          self:RefreshElements(Theme.SkinFlags.TEXTURE_COLOR)
        end

        if theme:GetElementPropertyFromDB(self.elementID, "texture-color") then
          ShowReset(row, "texture-color", refresh)
        end

        textureColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
          ShowReset(row, "texture-color", refresh)
          theme:SetElementPropertyToDB(self.elementID, "texture-color", { r = r, g = g, b = b, a = a})
          self:RefreshElements(Theme.SkinFlags.TEXTURE_COLOR)
        end)

        textureColor:SetCallback("OnValueConfirmed", function(_, _, r, g, b, a)
          ShowReset(row, "texture-color", refresh)
          theme:SetElementPropertyToDB(self.elementID, "texture-color", { r = r, g = g, b = b, a = a})
          self:RefreshElements(Theme.SkinFlags.TEXTURE_COLOR)
        end)
      end
    end
  end
  __Arguments__ { String, Argument(String, true)}
  function BindElement(self, elementID, inheritFrom)
    self.elementID = elementID
    self.inheritedFromElement = inheritFrom

    return self
  end

  __Arguments__ { String, Argument(Boolean, true, false)}
  function SetRefresher(self, refresher, isGroup)
    self.refresher = refresher
    self.refresherIsGroup = isGroup

    return self
  end

  __Arguments__ { OptionFlags }
  function SetFlags(self, flags)
    self.flags = flags

    return self
  end

  __Arguments__ {  Argument(Theme.SkinFlags, true, 127) }
  function RefreshElements(self, flags)
    if self.refresherIsGroup then
      Continue(function()
        local startTime = debugprofilestop()
        CallbackHandlers:CallGroup(self.refresher)
         --print(format("myFunction executed in %f ms", debugprofilestop()-startTime))
      end)
    else
      Continue(function()
        --   local startTime = debugprofilestop()
        CallbackHandlers:Call(self.refresher, flags)
        --print(format("myFunction executed in %f ms", debugprofilestop()-startTime))
      end)
    end
  end



  property "elementID" { TYPE = String }
  property "inheritedFromElement" { TYPE = String }
  property "flags" { TYPE = OptionFlags, DEFAULT = function() return ThemeElementRecipe.ALL_FRAME_OPTIONS end }
  property "refresher" { TYPE = String, DEFAULT = "refresher"}
  property "refresherIsGroup" { TYPE = Boolean, DEFAULT = true }




endclass "ThemeElementRecipe"


class "SelectRecipe" inherit "OptionRecipe" extend "InstallOptionHandler"

  function Build(self, parent)
    local select = _AceGUI:Create("Dropdown")
    select:SetLabel(self.text)
    select:SetList(self.list)
    parent:AddChild(select)


    if self.option then
      select:SetText(self.list[self:GetOption()])
    else
      if type(self.value) == "function" then
        select:SetText(self.list[self.value()])
      else
        select:SetText(self.list[self.value])
      end
    end

    select:SetCallback("OnValueChanged", function(_, _, value)
      if self.option then
        self:SetOption(value)
      else
        self.onValueChanged(value)
      end
    end)


  end

  function SetList(self, list)
    self.list = list
    return self
  end

  function SetValue(self, value)
    self.value = value
    return self
  end

  function OnValueChanged(self, callback)
    self.onValueChanged = callback
    return self
  end



endclass "SelectRecipe"

class "NotImplementedRecipe" inherit "OptionRecipe"

  function Build(self, parent)
    local heading = _AceGUI:Create("Heading")
    heading:SetRelativeWidth(1.0)
    heading:SetText("|cffff0000Option Not Implemented|r")
    parent:AddChild(heading)


    local label = _AceGUI:Create("Label")
    label:SetRelativeWidth(1.0)
    label:SetText("\n\n"..self.text)
    label:SetFont([[Interface\AddOns\EskaQuestTracker\Media\Fonts\PTSans-Caption-Bold.ttf]], 13)
    label:SetColor(1.0, 106/255, 0)
    parent:AddChild(label)
  end

endclass "NotImplementedRecipe"




--------------------------------------------------------------------------------
--                        OptionBuilder                                       --                                --
--------------------------------------------------------------------------------
class "OptionBuilder"
  _RECIPES = List()
  _GROUP_RECIPES = Dictionary()

  _COMMON_VARIABLES = Dictionary()

  __Arguments__ { Class, String, Argument(Any, true) }
  __Static__() function SetVariable(self, id, value)
    _COMMON_VARIABLES[id] = value
  end

  __Arguments__ { Class, String }
  __Static__() function GetVariable(self, id)
    return _COMMON_VARIABLES[id]
  end



  __Static__() __Arguments__{ Class, OptionRecipe, Argument(String, true) }
  function AddRecipe(self, recipe, group)
    -- If the group is availaible, add into _GROUP_RECIPES container
    if group then
      local groupRecipes = _GROUP_RECIPES[group]
      if not groupRecipes then
        groupRecipes = List()
        _GROUP_RECIPES[group] = groupRecipes
      end
      groupRecipes:Insert(recipe)
    else
      _RECIPES:Insert(recipe)
    end
  end

  __Static__() __Arguments__{ Class, Argument(String, true) }
  function GetRecipes(self, group)
    if group and _GROUP_RECIPES[group] then
      return _GROUP_RECIPES[group]:Sort("a,b=>a.order<b.order")
    else
      return _RECIPES:Sort("a,b=>a.order<b.order")
    end
  end

  -- Create ShortCuts
  __Static__() __Arguments__{ Class, OptionRecipe }
  function AddTrackerRecipe(self, recipe)
    self:AddRecipe(recipe, "Tracker")
  end

  __Static__() __Arguments__{ Class, OptionRecipe }
  function AddQuestRecipe(self, recipe)
    self:AddRecipe(recipe, "Quests")
  end

  __Static__() __Arguments__{ Class, OptionRecipe }
  function AddWorldQuestRecipe(self, recipe)
    self:AddRecipe(recipe, "Worldquests")
  end

  __Static__() __Arguments__{ Class, OptionRecipe }
  function AddAchievementRecipe(self, recipe)
    self:AddRecipe(recipe, "Achievements")
  end

  __Static__() __Arguments__{ Class, OptionRecipe }
  function AddDungeonRecipe(self, recipe)
    self:AddRecipe(recipe, "Dungeon")
  end

  __Static__() __Arguments__{ Class, OptionRecipe }
  function AddKeystoneRecipe(self, recipe)
    self:AddRecipe(recipe, "Keystone")
  end

  __Static__() __Arguments__{ Class, OptionRecipe }
  function AddGroupFinderRecipe(self, recipe)
    self:AddRecipe(recipe, "Groupfinders")
  end

  __Static__() __Arguments__{ Class, OptionRecipe}
  function AddThemeRecipe(self, recipe)
    self:AddRecipe(recipe, "Themes")
  end

  __Static__() __Arguments__{ Class, OptionRecipe }
  function AddThemeElementRecipe(self, recipe)
    self:AddRecipe(recipe, "Theme/Elements")
  end

endclass "OptionBuilder"
