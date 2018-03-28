-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio           "EskaQuestTracker.Options.OptionBuilder"                    ""
--============================================================================--
namespace "EQT"
ValidateFlags = Enum.ValidateFlags
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


  function Build(self, parent, info) end


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


  --[[__Arguments__ { Table, Table }
  function SetInfo(self, widget, recipe)
    self.info = setmetatable({}, { __mode = "v"})
    self.info["parent-recipe"] = recipe
    self.info["parent-widget"] = widget
  end

  function Build(self, parent, info)
    info.parentRecipe
    info.parentWidget
    info.i
    info.rebuild() = function() self:Build()
  end --]]

  property "order" { TYPE = Number, DEFAULT = 50 }
  property "recipeGroup" { TYPE = String, DEFAULT = nil }
  property "id" { TYPE = String, DEFAULT = nil }
  property "text" { TYPE = String, DEFAULT = "" }

  __Arguments__ { String, String }
  function OptionRecipe(self, text, recipeGroup)
    this(self)

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

class "HeadingRecipe" inherit "OptionRecipe"
  function Build(self, parent, info)

    local heading = _AceGUI:Create("Heading")
    heading:SetRelativeWidth(1.0)
    heading:SetText(self.text)
    parent:AddChild(heading)
  end

endclass "HeadingRecipe"



class "TreeItemRecipe" inherit "OptionRecipe"

  function Build(self, parent, info)
    if not self.recipeGroup then
      return
    end

    local data = {
      parentWidget = parent,
      parentRecipe = self,
      rebuild = function() parent:ReleaseChildren() ; self:Build(parent, info) end,
      i = 0,
    }

    local recipes = OptionBuilder:GetRecipes(self.recipeGroup)
    if recipes then
      for index, recipe in recipes:GetIterator() do
        data.i = data.i + 1
        recipe:Build(parent, data)
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

  function Build(self, parent, info)
      parent:ReleaseChildren()

      local themeSelected = OptionBuilder:GetVariable("theme-selected")

      local themeList = {}
      for _, theme in Themes:GetIterator() do
        themeList[theme.name] = theme.name
      end

      local selectTheme = _AceGUI:Create("DropdownGroup")
      selectTheme:SetTitle("Choose the Theme where the appearance properties changes will be saved")
      selectTheme:SetLayout("Flow")
      selectTheme:SetFullWidth(true)
      --selectTheme:SetFullHeight(true)
      selectTheme:SetGroupList(themeList)
      selectTheme:SetGroup(themeSelected)

      local function BuildChildren()
        if not self.recipeGroup then
          return
        end

        local data = {
          parentWidget = parent,
          parentRecipe = self,
          rebuild = function() self:Build(parent, info) end,
          i = 0
        }

        local recipes = OptionBuilder:GetRecipes(self.recipeGroup)
        if recipes then
          for index, recipe in recipes:GetIterator() do
            data.i = data.i + 1
            recipe:Build(selectTheme, data)
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

  function Build(self, parent, info)
      if not self.recipeGroup then
        return
      end

      -- Prepare the info table to pass to children
      local data = {}
      data.i = 1
      data.parentRecipe = self
      data.rebuild = function() self:Build(parent, info) end

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
            recipe:Build(frame, data)
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
  function Build(self, parent, info)


    if not self.recipeGroup then
      return
    end

    local data = {}
    data.parentRecipe = self
    data.i = 1
    data.rebuild = function() parent:ReleaseChildren() ; self:Build(parent, info) end


    local recipes = OptionBuilder:GetRecipes(self.recipeGroup)
    if recipes then
      for index, recipe in recipes:GetIterator() do
        recipe:Build(parent, data)
        data.i = data.i + 1
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
    super(self)
    self.width = width

  end--]]

endclass "CheckBoxRecipe"

class "ButtonRecipe" inherit "OptionRecipe"
  function Build(self, parent, info)
    local button = _AceGUI:Create("Button")
    button:SetText(self.text)

    button:SetCallback("OnClick", function() if self.onClick then self.onClick(parent, info) end end)

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
    "FRAME_BORDER_WIDTH",
    -- TEXT Optons
    "TEXT_SIZE",
    "TEXT_COLOR",
    "TEXT_FONT",
    "TEXT_TRANSFORM",
    -- TEXTURE Options
    "TEXTURE_COLOR"
  }

  __Static__() property "ALL_FRAME_OPTIONS" {
    DEFAULT = OptionFlags.FRAME_BACKGROUND_COLOR + OptionFlags.FRAME_BORDER_COLOR + OptionFlags.FRAME_BORDER_WIDTH,
    SET = false
  }

  __Static__() property "DEFAULT_FRAME_OPTIONS" {
    DEFAULT = OptionFlags.FRAME_BACKGROUND_COLOR,
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
    local stateSelected = OptionBuilder:GetVariable("state-selected")

    local elementID = self.elementID
    if stateSelected and stateSelected ~= "none" then
      elementID = string.format("%s[%s]", elementID, stateSelected)
    end

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

      if theme.lua then
        local reset = _AceGUI:Create("Button")
        reset:SetWidth(75)
        reset:SetText("Reset")
      end

      return layout
    end

    local function ShowReset(layout, property, refresh)
      if not theme.lua then return end

      local reset = layout:GetUserData("reset")
      if not reset then
        reset = _AceGUI:Create("Button")
        reset:SetWidth(75)
        reset:SetText("Reset")
        reset:SetCallback("OnClick", function(reset)
          reset.frame:Hide()
          theme:SetElementPropertyToDB(elementID, property, nil)
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
      local hasFrameBorderWidth = ValidateFlags(self.flags, OptionFlags.FRAME_BORDER_WIDTH)
      -- If there is a frame option, create the group
      if hasFrameBackgroundColor or hasFrameBorderColor or hasFrameBorderWidth then
        local group = CreateGroup("Frame properties")
        parent:AddChild(group)

        if hasFrameBackgroundColor then
          local backgroundColor = _AceGUI:Create("ColorPicker")
          backgroundColor:SetHasAlpha(true)

          local color = theme:GetElementProperty(elementID, "background-color", self.inheritedFromElement)
          backgroundColor:SetColor(color.r, color.g, color.b, color.a)

          local row = CreateRow("Background Color", backgroundColor)
          group:AddChild(row)

          local function refresh()
            local color = theme:GetElementProperty(elementID, "background-color", self.inheritedFromElement)
            backgroundColor:SetColor(color.r, color.g, color.b, color.a)
            self:RefreshElements(Theme.SkinInfo(Theme.SkinFrameFlags.FRAME_BACKGROUND_COLOR, 0, 0))
          end

          if theme:GetElementPropertyFromDB(elementID, "background-color") then
            ShowReset(row, "background-color", refresh)
          end

          backgroundColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
            ShowReset(row, "background-color", refresh)
            theme:SetElementPropertyToDB(elementID, "background-color", { r = r, g = g, b = b, a = a})
            self:RefreshElements(Theme.SkinInfo(Theme.SkinFrameFlags.FRAME_BACKGROUND_COLOR, 0, 0))
          end)

          backgroundColor:SetCallback("OnValueConfirmed", function(_, _, r, g, b, a)
            ShowReset(row, "background-color", refresh)
            theme:SetElementPropertyToDB(elementID, "background-color", { r = r, g = g, b = b, a = a})
            self:RefreshElements(Theme.SkinInfo(Theme.SkinFrameFlags.FRAME_BACKGROUND_COLOR, 0, 0))
          end)
        end

        if hasFrameBorderColor then
          local borderColor = _AceGUI:Create("ColorPicker")
          borderColor:SetHasAlpha(true)

          local color = theme:GetElementProperty(elementID, "border-color", self.inheritedFromElement)
          borderColor:SetColor(color.r, color.g, color.b, color.a)

          local row = CreateRow("Border Color", borderColor)
          group:AddChild(row)

          local function refresh()
            local color = theme:GetElementProperty(elementID, "border-color", self.inheritedFromElement)
            borderColor:SetColor(color.r, color.g, color.b, color.a)
            self:RefreshElements(Theme.SkinInfo(Theme.SkinFrameFlags.FRAME_BORDER_COLOR, 0, 0))
          end

          if theme:GetElementPropertyFromDB(elementID, "border-color") then
            ShowReset(row, "border-color", refresh)
          end

          borderColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
            ShowReset(row, "border-color", refresh)
            theme:SetElementPropertyToDB(elementID, "border-color", { r = r, g = g, b = b, a = a})
            self:RefreshElements(Theme.SkinInfo(Theme.SkinFrameFlags.FRAME_BORDER_COLOR, 0, 0))
          end)

          borderColor:SetCallback("OnValueConfirmed", function(_, _, r, g, b, a)
            ShowReset(row, "border-color", refresh)
            theme:SetElementPropertyToDB(elementID, "border-color", { r = r, g = g, b = b, a = a})
            self:RefreshElements(Theme.SkinInfo(Theme.SkinFrameFlags.FRAME_BORDER_COLOR, 0, 0))
          end)
        end

        -- TODO: Change the Refresh Element for FRAME_BORDER_WIDTH
        if hasFrameBorderWidth then
          local borderWidth = _AceGUI:Create("Slider")

          local width = theme:GetElementProperty(elementID, "border-width", self.inheritedFromElement)
          borderWidth:SetValue(width or 10)

          local row = CreateRow("Border Width", borderWidth)
          group:AddChild(row)

          local function refresh()
            local width = theme:GetElementProperty(elementID, "border-width", self.inheritedFromElement)
            borderWidth:SetValue(width or 10)
            self:RefreshElements(Theme.SkinInfo(Theme.SkinFrameFlags.FRAME_BORDER_COLOR, 0, 0))
          end

          if theme:GetElementPropertyFromDB(elementID, "border-width") then
            ShowReset(row, "border-width", refresh)
          end

          borderWidth:SetCallback("OnValueChanged", function(_, _, width)
            ShowReset(row, "border-width", refresh)
            theme:SetElementPropertyToDB(elementID, "border-width", width)
            self:RefreshElements(Theme.SkinInfo(Theme.SkinFrameFlags.FRAME_BORDER_COLOR, 0, 0))
          end)

          borderWidth:SetCallback("OnMouseUp", function(_, _, width)
            ShowReset(row, "border-width", refresh)
            theme:SetElementPropertyToDB(elementID, "border-width", width)
            self:RefreshElements(Theme.SkinInfo(Theme.SkinFrameFlags.FRAME_BORDER_COLOR, 0, 0))
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

          local color = theme:GetElementProperty(elementID, "text-color", self.inheritedFromElement)
          textColor:SetColor(color.r, color.g, color.b, color.a)

          local row = CreateRow("Text Color", textColor)
          group:AddChild(row)

          local function refresh()
            local color = theme:GetElementProperty(elementID, "text-color", self.inheritedFromElement)
            textColor:SetColor(color.r, color.g, color.b, color.a)
            self:RefreshElements(Theme.SkinInfo(0, Theme.SkinTextFlags.TEXT_COLOR, 0))
          end
          if theme:GetElementPropertyFromDB(elementID, "text-color") then
            ShowReset(row, "text-color", refresh)
          end

          textColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
            ShowReset(row, "text-color", refresh)
            theme:SetElementPropertyToDB(elementID, "text-color", { r = r, g = g, b = b, a = a})
            self:RefreshElements(Theme.SkinInfo(0, Theme.SkinTextFlags.TEXT_COLOR, 0))
          end)

          textColor:SetCallback("OnValueConfirmed", function(_, _, r, g, b, a)
            ShowReset(row, "text-color", refresh)
            theme:SetElementPropertyToDB(elementID, "text-color", { r = r, g = g, b = b, a = a})
            self:RefreshElements(Theme.SkinInfo(0, Theme.SkinTextFlags.TEXT_COLOR, 0))
          end)
        end

        if hasTextSize then

          local textSize = _AceGUI:Create("Slider")
          textSize:SetRelativeWidth(0.3)
          textSize:SetSliderValues(6, 32, 1)
          textSize:SetValue(theme:GetElementProperty(elementID, "text-size", self.inheritedFromElement))

          local row = CreateRow("Text Size", textSize)
          group:AddChild(row)
          local function refresh()
            textSize:SetValue(theme:GetElementProperty(elementID, "text-size", self.inheritedFromElement))
            self:RefreshElements(Theme.SkinInfo(0, Theme.SkinTextFlags.TEXT_SIZE, 0))
          end

          if theme:GetElementPropertyFromDB(elementID, "text-size") then
            ShowReset(row, "text-size", refresh)
          end

          textSize:SetCallback("OnValueChanged", function(_, _, size)
            ShowReset(row, "text-size", refresh)
            theme:SetElementPropertyToDB(elementID, "text-size", size)
            self:RefreshElements(Theme.SkinInfo(0, Theme.SkinTextFlags.TEXT_SIZE, 0))
           end)
           textSize:SetCallback("OnValueConfirmed", function(_, _, size)
             ShowReset(row, "text-size", refresh)
             theme:SetElementPropertyToDB(elementID, "text-size", size)
             self:RefreshElements(Theme.SkinInfo(0, Theme.SkinTextFlags.TEXT_SIZE, 0))
            end)
        end

        if hasTextFont then
          local textFont = _AceGUI:Create("Dropdown")
          textFont:SetList(_Fonts, nil, "DDI-Font")
          textFont:SetValue(GetFontIndex(theme:GetElementProperty(elementID, "text-font", self.inheritedFromElement)))

          local row = CreateRow("Text Font", textFont)
          group:AddChild(row)

          local function refresh() textFont:SetValue(GetFontIndex(theme:GetElementProperty(elementID, "text-font", self.inheritedFromElement))) ; self:RefreshElements(Theme.SkinInfo(0, Theme.SkinTextFlags.TEXT_FONT, 0)) end

          if theme:GetElementPropertyFromDB(elementID, "text-font") then
            ShowReset(row, "text-font", refresh)
          end

          textFont:SetCallback("OnValueChanged", function(_, _, value)
            ShowReset(row, "text-font", refresh)
            theme:SetElementPropertyToDB(elementID, "text-font", _Fonts[value])
            self:RefreshElements(Theme.SkinInfo(0, Theme.SkinTextFlags.TEXT_FONT, 0))
          end)
        end

        if hasTextTransform then
          local textTransform = _AceGUI:Create("Dropdown")
          textTransform:SetList(_TextTransforms)
          textTransform:SetValue(theme:GetElementProperty(elementID, "text-transform", self.inheritedFromElement))

          local row = CreateRow("Text Transform", textTransform)
          group:AddChild(row)

          local function refresh() textTransform:SetValue(theme:GetElementProperty(elementID, "text-transform", self.inheritedFromElement)) ; self:RefreshElements(Theme.SkinInfo(0, Theme.SkinTextFlags.TEXT_TRANSFORM, 0)) end

          if theme:GetElementPropertyFromDB(elementID, "text-transform") then
            ShowReset(row, "text-transform", refresh)
          end

          textTransform:SetCallback("OnValueChanged", function(_, _, transform)
            ShowReset(row, "text-transform", refresh)
            theme:SetElementPropertyToDB(elementID, "text-transform", transform)
            self:RefreshElements(Theme.SkinInfo(0, Theme.SkinTextFlags.TEXT_TRANSFORM, 0))
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

        local color = theme:GetElementProperty(elementID, "texture-color", self.inheritedFromElement)
        textureColor:SetColor(color.r, color.g, color.b, color.a)

        local row = CreateRow("Texture Color", textureColor)
        group:AddChild(row)

        local function refresh()
          local color = theme:GetElementProperty(elementID, "texture-color", self.inheritedFromElement)
          textureColor:SetColor(color.r, color.g, color.b, color.a)
          self:RefreshElements(Theme.SkinInfo(0, 0, Theme.SkinTextureFlags.TEXTURE_COLOR))
        end

        if theme:GetElementPropertyFromDB(elementID, "texture-color") then
          ShowReset(row, "texture-color", refresh)
        end

        textureColor:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
          ShowReset(row, "texture-color", refresh)
          theme:SetElementPropertyToDB(elementID, "texture-color", { r = r, g = g, b = b, a = a})
          self:RefreshElements(Theme.SkinInfo(0, 0, Theme.SkinTextureFlags.TEXTURE_COLOR))
        end)

        textureColor:SetCallback("OnValueConfirmed", function(_, _, r, g, b, a)
          ShowReset(row, "texture-color", refresh)
          theme:SetElementPropertyToDB(elementID, "texture-color", { r = r, g = g, b = b, a = a})
          self:RefreshElements(Theme.SkinInfo(0, 0, Theme.SkinTextureFlags.TEXTURE_COLOR))
        end)
      end
    end
  end
  __Arguments__ { String, Variable.Optional(String) }
  function BindElement(self, elementID, inheritFrom)
    self.elementID = elementID
    self.inheritedFromElement = inheritFrom

    return self
  end

  __Arguments__ { String, Variable.Optional(Boolean, false)}
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

  __Arguments__ { Variable.Optional(Theme.SkinInfo, Theme.SkinInfo())}
  function RefreshElements(self, skinInfo)
    if self.refresherIsGroup then
      Continue(function()
        local startTime = debugprofilestop()
        CallbackHandlers:CallGroup(self.refresher)
         --print(format("myFunction executed in %f ms", debugprofilestop()-startTime))
      end)
    else
      Continue(function()
        --   local startTime = debugprofilestop()
        CallbackHandlers:Call(self.refresher, skinInfo)
        --print(format("myFunction executed in %f ms", debugprofilestop()-startTime))
      end)
    end
  end



  property "elementID" { TYPE = String }
  property "inheritedFromElement" { TYPE = String }
  property "flags" { TYPE = OptionFlags, DEFAULT = function() return ThemeElementRecipe.DEFAULT_FRAME_OPTIONS end }
  property "refresher" { TYPE = String, DEFAULT = "refresher"}
  property "refresherIsGroup" { TYPE = Boolean, DEFAULT = true }




endclass "ThemeElementRecipe"


class "SelectRecipe" inherit "OptionRecipe" extend "InstallOptionHandler"

  function Build(self, parent, info)
    local select = _AceGUI:Create("Dropdown")
    select:SetLabel(self.text)
    select:SetList(self:GetList())
    parent:AddChild(select)

    if self.width then
      if self.width > 0  and  self.width <= 1 then
        select:SetRelativeWidth(self.width)
      else
        select:SetWidth(self.width)
      end
    end

    if self.option then
      select:SetText(self:GetList()[self:GetOption()])
    else
      if type(self.value) == "function" then
        select:SetText(self:GetList()[self.value()])
      else
        select:SetText(self:GetList()[self.value])
      end
    end

    select:SetCallback("OnValueChanged", function(_, _, value)
      if self.option then
        self:SetOption(value)
      else
        self.onValueChanged(value, self, info)
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

  function GetList(self)
    if type(self.list) == "table" then
      return self.list
    else
      return self.list()
    end
  end

  function OnValueChanged(self, callback)
    self.onValueChanged = callback
    return self
  end

function SetWidth(self, width)
  self.width = width
  return self
end




endclass "SelectRecipe"


class "EditBoxRecipe" inherit "OptionRecipe" extend "InstallOptionHandler"
  function Build(self, parent)
    local editbox = _AceGUI:Create("EditBox")
    editbox:SetLabel(self.text)
    editbox:SetText(self:GetOption())
    parent:AddChild(editbox)
  end
endclass "EditBoxRecipe"

class "NotImplementedRecipe" inherit "OptionRecipe"

  function Build(self, parent)
    local heading = _AceGUI:Create("Heading")
    heading:SetRelativeWidth(1.0)
    heading:SetText("|cffff0000Options Not Implemented|r")
    parent:AddChild(heading)


    local label = _AceGUI:Create("Label")
    label:SetRelativeWidth(1.0)
    label:SetText("\n\n"..self.text)
    label:SetFont([[Interface\AddOns\EskaQuestTracker\Media\Fonts\PTSans-Caption-Bold.ttf]], 13)
    label:SetColor(1.0, 106/255, 0)
    parent:AddChild(label)
  end

endclass "NotImplementedRecipe"

class "ThemeInformationRecipe" inherit "OptionRecipe"
  function Build(self, parent)
    local function CreateRow(name, value)
      local layout = _AceGUI:Create("SimpleGroup")
      layout:SetRelativeWidth(1.0)
      layout:SetLayout("Flow")
      --layout.frame:SetBackdropBorderColor(0, 0, 0, 0)

      local label = _AceGUI:Create("Label")
      label:SetRelativeWidth(0.2)
      label:SetFontObject(GameFontHighlight)
      label:SetText(name)
      layout:AddChild(label)

      local valueFrame = _AceGUI:Create("Label")
      valueFrame:SetRelativeWidth(0.3)
      valueFrame:SetText(value)

      layout:AddChild(valueFrame)
      return layout
    end

    local theme = Themes:GetSelected()

    parent:AddChild(CreateRow("Name", theme.name))
    parent:AddChild(CreateRow("Author", theme.author))
    parent:AddChild(CreateRow("Version", theme.version))
    parent:AddChild(CreateRow("Stage", theme.stage))
  end
endclass "ThemeInformationRecipe"

class "CreateThemeRecipe" inherit "OptionRecipe"
  function Build(self, parent, info)
    -- Set the default values
    local defaultAuthor = UnitName("player")
    local defaultStage = "Release"
    local defaultVersion = "1.0.0"
    local defaultCopyFrom = "none"
    local defaultIncludeDBValues = OptionBuilder:GetVariable("create-theme-include-db-values") or true
    -----------------------------

    local name = _AceGUI:Create("EditBox")
    name:SetLabel("Name")
    name:SetRelativeWidth(0.2)
    parent:AddChild(name)

    local author = _AceGUI:Create("EditBox")
    author:SetLabel("Author")
    author:SetRelativeWidth(0.19)
    author:SetText(defaultAuthor)
    parent:AddChild(author)

    local version = _AceGUI:Create("EditBox")
    version:SetLabel("Version")
    version:SetRelativeWidth(0.15)
    version:SetText(defaultVersion)
    parent:AddChild(version)

    local stage = _AceGUI:Create("Dropdown")
    stage:SetLabel("Stage")
    stage:SetText(defaultStage)
    stage:SetRelativeWidth(0.15)
    stage:SetList({
      ["Alpha"] = "Alpha",
      ["Beta"] = "Beta",
      ["Release"] = "Release",
    })
    stage:SetCallback("OnValueChanged", function(_, _, key) OptionBuilder:SetVariable("create-theme-stage", key) end)
    parent:AddChild(stage)

    local copyFrom = _AceGUI:Create("Dropdown")
    copyFrom:SetLabel("Copy From")
    copyFrom:SetRelativeWidth(0.2)
    parent:AddChild(copyFrom)


    local createButton = _AceGUI:Create("Button")
    createButton:SetText("Create")
    createButton:SetRelativeWidth(0.1)
    parent:AddChild(createButton)

    local includeDBValues = _AceGUI:Create("CheckBox")
    includeDBValues:SetLabel("Include database values")
    includeDBValues:SetValue(defaultIncludeDBValues)
    parent:AddChild(includeDBValues)

    createButton:SetCallback("OnClick", function()
      local themeToCopy = OptionBuilder:GetVariable("create-theme-copy-from") or defaultCopyFrom
      local themeName = name:GetText()
      local themeAuthor = author:GetText() or defaultAuthor
      local themeVersion = version:GetText() or defaultVersion
      local themeStage = OptionBuilder:GetVariable("create-theme-stage") or defaultStage
      local themeToCopy = OptionBuilder:GetVariable("create-theme-copy-from") or defaultCopyFrom
      local includeDBValues = OptionBuilder:GetVariable("create-theme-include-db-values") or defaultIncludeDBValues


      if themeToCopy and themeToCopy ~= "none" then
        Themes:CreateDBTheme(themeName, themeAuthor, themeVersion, themeStage, themeToCopy, includeDBValues)
        --local themeParent = Themes:Get(themeToCopy)
        --local theme = System.Toolset.clone(themeParent, true)
        --print("Child", theme:GetElementProperty("block.header", "text-size"), "Parent:", themeParent:GetElementProperty("block.header", "text-size"))
      else
        local theme = Themes:CreateDBTheme(themeName, themeAuthor, themeVersion, themeStage)
      end

      info.rebuild()
    end)

    local themeList = {}
    themeList["none"] = "None"
    for _, theme in Themes:GetIterator() do
      themeList[theme.name] = theme.name
    end
    copyFrom:SetList(themeList)
    copyFrom:SetText(themeList[defaultCopyFrom])
    copyFrom:SetCallback("OnValueChanged", function(_, _, key) OptionBuilder:SetVariable("create-theme-copy-from", key) end)

  end


endclass "CreateThemeRecipe"


class "TextRecipe" inherit "OptionRecipe"
  function Build(self, parent)
    local text = _AceGUI:Create("Label")
    text:SetText(self.text)
    text:SetRelativeWidth(1.0)
    text:SetFontObject(GameFontHighlight)
    parent:AddChild(text)
  end
endclass "TextRecipe"

class "ImportThemeRecipe" inherit "OptionRecipe"
  function Build(self, parent)
    -- local default values
    local defaultForceOverride = OptionBuilder:GetVariable("import-theme-force-override") or false


    local textBox = _AceGUI:Create("MultiLineEditBox")
    textBox:SetLabel("Paste text below to import the theme")
    textBox:SetRelativeWidth(1.0)
    textBox:DisableButton(true)
    textBox:SetNumLines(10)

    parent:AddChild(textBox)

    local headingThemeInfo = _AceGUI:Create("Heading")
    headingThemeInfo:SetText("Theme information")
    parent:AddChild(headingThemeInfo)

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

      valueFrame:SetRelativeWidth(0.5)
      layout:AddChild(valueFrame)

      return layout
    end

    local name = _AceGUI:Create("Label")
    name:SetText("")

    local author = _AceGUI:Create("Label")
    author:SetText("")

    local version = _AceGUI:Create("Label")
    version:SetText("")

    local stage = _AceGUI:Create("Label")
    stage:SetText("")

    parent:AddChild(CreateRow("Name:", name))
    parent:AddChild(CreateRow("Author:", author))
    parent:AddChild(CreateRow("Version:", version))
    parent:AddChild(CreateRow("Stage:", stage))

    local importFlags = _AceGUI:Create("Heading")
    importFlags:SetText("Import flags")
    parent:AddChild(importFlags)


    local override = _AceGUI:Create("CheckBox")
    override:SetLabel("Force override")
    override:SetValue(defaultForceOverride)
    override:SetCallback("OnValueChanged", function(_, _, value) OptionBuilder:SetVariable("import-theme-force-override", value) end)
    parent:AddChild(override)

    local separator = _AceGUI:Create("Heading")
    separator:SetText("")
    parent:AddChild(separator)

    local import = _AceGUI:Create("Button")
    import:SetText("Import")
    import:SetRelativeWidth(1.0)
    parent:AddChild(import)

    local function ValidateValue(value)
      if Themes:Get(value) then
        return false, "Name already taken"
      end

      return true, "Name is avalaible"
    end

    local function ConfirmValue(value)
      Themes:Import(textBox:GetText(), value)
    end

    import:SetCallback("OnClick", function()
      local forceOverride = override:GetValue()
      if not forceOverride then
        local themeName = OptionBuilder:GetVariable("import-theme-name")
        if ValidateValue(themeName) then
          Themes:Import(textBox:GetText())
        else
          local title = "Name already exists !"
          local  txt = "A theme with this name already exists.\nChoose an another one to continue."
          MessageBox:QuestionWithEditBox(parent.frame, title, txt, nil, ConfirmValue, ValidateValue)
        end
      else
        Themes:Override(textBox:GetText())
      end
    end)


    -- Callback
    textBox:SetCallback("OnTextChanged", function()
      local theme, msg = Theme:GetFromText(textBox:GetText())
      local successColor = "ff00ff00"
      local failedColor = "ffff0000"

      if theme then
        name:SetText(string.format("|c%s%s|r", successColor, theme.name))
        author:SetText(string.format("|c%s%s|r", successColor, theme.author))
        version:SetText(string.format("|c%s%s|r", successColor, theme.version))
        stage:SetText(string.format("|c%s%s|r", successColor, theme.stage))
        OptionBuilder:SetVariable("import-theme-name", theme.name)
      else
        name:SetText(string.format("|c%s%s|r", failedColor, msg))
        author:SetText(string.format("|c%s%s|r", failedColor, msg))
        version:SetText(string.format("|c%s%s|r", failedColor, msg))
        stage:SetText(string.format("|c%s%s|r", failedColor, msg))
      end

    end)

  end

endclass "ImportThemeRecipe"

class "ExportThemeRecipe" inherit "OptionRecipe"

  function Build(self, parent, info)
    -- Get the selected theme
    local theme = Themes:GetSelected()
    OptionBuilder:SetVariable("export-theme-selected", theme.name)
    -- default values
    local defaultIncludeDBValues = OptionBuilder:GetVariable("export-theme-include-db-values") or true

    local selectTheme = _AceGUI:Create("Dropdown")
    selectTheme:SetLabel("Select Theme to export")
    selectTheme:SetRelativeWidth(0.25)
    selectTheme:SetText(theme.name)
    parent:AddChild(selectTheme)

    local themeList = {}
    for _, theme in Themes:GetIterator() do
      themeList[theme.name] = theme.name
    end
    selectTheme:SetList(themeList)

    -- line
    local headingTop = _AceGUI:Create("Heading")
    headingTop:SetText("")
    parent:AddChild(headingTop)

    -- Export text
    local textBox = _AceGUI:Create("MultiLineEditBox")
    textBox:SetLabel("Theme text export")
    textBox:SetRelativeWidth(1.0)
    textBox:DisableButton(true)
    parent:AddChild(textBox)

    textBox:SetText(theme:ExportToText(defaultIncludeDBValues))
    textBox:SetNumLines(20)
    textBox:HighlightText()

    -- Export Flags line
    local headingFlags = _AceGUI:Create("Heading")
    headingFlags:SetText("Export flags")
    parent:AddChild(headingFlags)

    local includeDBValue = _AceGUI:Create("CheckBox")
    includeDBValue:SetLabel("Include database values")
    includeDBValue:SetValue(defaultIncludeDBValues)
    includeDBValue:SetCallback("OnValueChanged", function(_, _, value)
      OptionBuilder:SetVariable("export-theme-include-db-values", value)
      textBox:SetText(Themes:Get(OptionBuilder:GetVariable("export-theme-selected")):ExportToText(value))
      textBox:HighlightText()
    end)
    parent:AddChild(includeDBValue)

    -- Callbacks
    selectTheme:SetCallback("OnValueChanged", function(_, _, themeName)
      OptionBuilder:SetVariable("export-theme-selected", themeName)
      textBox:SetText(Themes:Get(themeName):ExportToText(OptionBuilder:GetVariable("export-theme-include-db-values")))
      textBox:HighlightText()
    end)

  end



--[[

  function Build(self, parent, info)
    local theme = Themes:GetSelected()

    -- defaut value
    local defaultIncludeDBValues = OptionBuilder:GetVariable("export-theme-include-db-values") or true

    local selectTheme = _AceGUI:Create("Dropdown")
    selectTheme:SetLabel("Select Theme to export")
    selectTheme:SetRelativeWidth(0.25)
    selectTheme:SetText(theme.name)
    parent:AddChild(selectTheme)

    local themeList = {}
    for _, theme in Themes:GetIterator() do
      themeList[theme.name] = theme.name
    end
    selectTheme:SetList(themeList)

    local headingTop = _AceGUI:Create("Heading")
    headingTop:SetText("")
    parent:AddChild(headingTop)

    local textBox = _AceGUI:Create("MultiLineEditBox")
    textBox:SetLabel("Theme text export")
    textBox:SetRelativeWidth(1.0)
    textBox:DisableButton(true)
    parent:AddChild(textBox)

    textBox:SetText(theme:ExportToText())
    textBox:SetNumLines(20)
    textBox:HighlightText()

    local headingFlags = _AceGUI:Create("Heading")
    headingFlags:SetText("Export flags")
    parent:AddChild(headingFlags)

    local includeDBValue = _AceGUI:Create("CheckBox")
    includeDBValue:SetLabel("Include database values")
    includeDBValue:SetValue(defaultIncludeDBValues)
    includeDBValue:SetCallback("OnValueChanged", function(_, _, value)
      OptionBuilder:SetVariable("export-theme-include-db-values", value)
      textBox:SetText(Themes:Get(themeName):ExportToText(value))
      textBox:HighlightText()
    end)
    parent:AddChild(includeDBValue)

    selectTheme:SetCallback("OnValueChanged", function(_, _, themeName)
      textBox:SetText(Themes:Get(themeName):ExportToText(OptionBuilder:GetVariable("export-theme-include-db-values")))
      textBox:HighlightText()
    end)

  end

  --]]

endclass "ExportThemeRecipe"


class "SelectStateRecipe" inherit "OptionRecipe"


  function Build(self, parent)
    local tabFrame = _AceGUI:Create("DropdownGroup")
    tabFrame:SetLayout("Flow")
    tabFrame:SetFullWidth(true)
    tabFrame:SetTitle(" ")
    parent:AddChild(tabFrame)



    local function RGBPercToHex(r, g, b)
    	r = r <= 1 and r >= 0 and r or 0
    	g = g <= 1 and g >= 0 and g or 0
    	b = b <= 1 and b >= 0 and b or 0
    	return string.format("%02x%02x%02x", r*255, g*255, b*255)
    end



    local index = 1
    local first
    local list = {}
    for stateID, state in pairs(self.states) do
      local colorString = RGBPercToHex(state.color.r, state.color.g, state.color.b)
      list[state.id] = string.format("|cff%s%s|r", colorString, state.text)
      if index == 1 then
        first = state.id
      end
      index = index + 1
    end
    tabFrame:SetGroupList(list)

    local selectedState = OptionBuilder:GetVariable("state-selected")
    if not selectedState or selectElement == "none" or not list[selectedState] then
      tabFrame:SetGroup(first)
      OptionBuilder:SetVariable("state-selected", first)
    else
      tabFrame:SetGroup(selectedState)
    end

    local function BuildChildren()
      if not self.recipeGroup then return end

      tabFrame:ReleaseChildren()

      local recipes = OptionBuilder:GetRecipes(self.recipeGroup)
      if recipes then
        for index, recipe in recipes:GetIterator() do
          recipe:Build(tabFrame)
        end
      end
    end

    tabFrame:SetCallback("OnGroupSelected", function(_, _, stateID)
      OptionBuilder:SetVariable("state-selected", stateID)
      BuildChildren()
    end)

    BuildChildren()


  end


  __Arguments__ { String }
  function SetState(self, stateID)
    return SetStates(self, stateID)
  end

  __Arguments__ { { Type = String, IsList = true} }
  function SetStates(self, ...)
      for i = 1, select("#", ...) do
        local stateID = select(i, ...)
        local state = States:Get(stateID)
        if state then
          self.states[stateID] = state
        end
      end
      return self
  end

  __Arguments__ {}
  function HasState(self)
    for k, v in pairs(self.states) do return true end
    return false
  end



  function SelectStateRecipe(self)
    super(self)
    self.states = setmetatable({}, { __mode = "v"} )
  end


endclass "SelectStateRecipe"






--------------------------------------------------------------------------------
--                        OptionBuilder                                       --                                --
--------------------------------------------------------------------------------
class "OptionBuilder"
  _RECIPES = List()
  _GROUP_RECIPES = Dictionary()

  _COMMON_VARIABLES = Dictionary()

  __Arguments__ { ClassType, String, Variable.Optional()}
  __Static__() function SetVariable(self, id, value)
    _COMMON_VARIABLES[id] = value
  end

  __Arguments__ { ClassType, String }
  __Static__() function GetVariable(self, id)
    return _COMMON_VARIABLES[id]
  end


  __Static__() __Arguments__ { ClassType, OptionRecipe, Variable.Optional(String) }
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

  __Static__() __Arguments__{ ClassType, Variable.Optional(String) }
  function GetRecipes(self, group)
    if group and _GROUP_RECIPES[group] then
      return _GROUP_RECIPES[group]:Sort("a,b=>a.order<b.order")
    else
      return _RECIPES:Sort("a,b=>a.order<b.order")
    end
  end

  -- Create ShortCuts
  __Static__() __Arguments__{ ClassType, OptionRecipe }
  function AddTrackerRecipe(self, recipe)
    self:AddRecipe(recipe, "Tracker")
  end

  __Static__() __Arguments__{ ClassType, OptionRecipe }
  function AddQuestRecipe(self, recipe)
    self:AddRecipe(recipe, "Quests")
  end

  __Static__() __Arguments__{ ClassType, OptionRecipe }
  function AddWorldQuestRecipe(self, recipe)
    self:AddRecipe(recipe, "Worldquests")
  end

  __Static__() __Arguments__{ ClassType, OptionRecipe }
  function AddAchievementRecipe(self, recipe)
    self:AddRecipe(recipe, "Achievements")
  end

  __Static__() __Arguments__{ Class, OptionRecipe }
  function AddDungeonRecipe(self, recipe)
    self:AddRecipe(recipe, "Dungeon")
  end

  __Static__() __Arguments__{ ClassType, OptionRecipe }
  function AddKeystoneRecipe(self, recipe)
    self:AddRecipe(recipe, "Keystone")
  end

  __Static__() __Arguments__{ ClassType, OptionRecipe }
  function AddGroupFinderRecipe(self, recipe)
    self:AddRecipe(recipe, "Groupfinders")
  end

  __Static__() __Arguments__{ ClassType, OptionRecipe}
  function AddThemeRecipe(self, recipe)
    self:AddRecipe(recipe, "Themes")
  end

  __Static__() __Arguments__{ ClassType, OptionRecipe }
  function AddThemeElementRecipe(self, recipe)
    self:AddRecipe(recipe, "Theme/Elements")
  end

endclass "OptionBuilder"
