-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio           "EskaQuestTracker.Options.OptionBuilder"                    ""
--============================================================================--
namespace "EQT"
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

  property "order" { TYPE = Number, DEFAULT = 50 }

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

--------------------------------------------------------------------------------
--                        OptionBuilder                                       --                                --
--------------------------------------------------------------------------------
class "OptionBuilder"
  _RECIPES = List()
  _GROUP_RECIPES = Dictionary()

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

  __Arguments__ { Class,
  { Type = String, Nilable = true },
  { Type = TextOptionFlags, Nilable = true, Default = 15} }
  function CreateTextOptions(self, class, element, flags)
    local t = {}
    -- Text Size option part
    if ValidateFlags(flags, TextOptionFlags.TEXT_SIZE_OPTION) then
      t.textSize = {
        type = "range",
        name = "Text Size",
        order = 1,
        step = 1,
        min = 4,
        max = 32,
        get = function()
          if element then
            return class:GetTextSize(element)
          else
            return class.textSize
          end
        end,
        set = function(_, value)
          if element then
            class:SetTextSize(element, value)
          else
            class.textSize = value
          end
        end
      }
    end
    -- Text Font option part
    if ValidateFlags(flags, TextOptionFlags.TEXT_FONT_OPTION) then
      t.textFont = {
        type = "select",
        name = "Text Font",
        values = _Fonts,
        itemControl = "DDI-Font",
        get = function()
          if element then
            return GetFontIndex(class:GetTextFont(element))
          else
            return GetFontIndex(class.textFont)
          end
        end,
        set = function(_, value)
          if element then
            class:SetTextFont(element, _Fonts[value])
          else
            class.textFont = _Fonts[value]
          end
        end
      }
    end
    -- Text Color option part
    if ValidateFlags(flags, TextOptionFlags.TEXT_COLOR_OPTION) then
      t.textColor = {
        type = "color",
        name = "Text Color",
        get = function()
          local color
          if element then
            color = class:GetTextColor(element)
          else
            color = class.textColor
          end
          return color.r, color.g, color.b
        end,
        set = function(_, r, g, b, a)
          if element then
            class:SetTextColor(element, { r = r, g = g, b = b })
          else
            class.textColor = { r = r, g = g, b = b }
          end
        end
      }
    end
    -- Text Transform option part
    if ValidateFlags(flags, TextOptionFlags.TEXT_TRANSFORM_OPTION) then
      t.textTransform = {
        type = "select",
        name = "Text Transform",
        values = _TextTransforms,
        get = function()
          if element then
            return class:GetTextTransform(element)
          else
            return class.textTransform
          end
        end,
        set = function(_, value)
          if element then
            class:SetTextTransform(element, value)
          else
            class.textTransform = value
          end
        end
      }
    end
    return t
  end

  function CreateEnableBlockOption(self, order, nameDisplayed, optionType, customOptionArgs, customToggleArgs)
    local t = {
      type = "group",
      name = "",
      order = order or 0,
      inline = true,
      args = {}
    }
    t.args.enable = {
      type = "toggle",
      name = nameDisplayed,
      order = 1,
      width = "normal",
    }

    if customToggleArgs then
      for k, v in pairs(customToggleArgs) do
        t.args.enable[k] = v
      end
    end

    t.args.option = {
      type = optionType,
      name = "",
      order = 2,
      width = "normal",
    }

    if optionType == "color" then
      t.args.option.hasAlpha = true
    elseif optionType == "selectFont" then
      t.args.option.type = "select"
      t.args.option.values = _Fonts
      t.args.option.itemControl = "DDI-Font"
    elseif optionType == "selectTransform" then
      t.args.option.type = "select"
      t.args.option.values = _TextTransforms
    elseif optionType == "selectLocation" then
      t.args.option.type = "select"
      t.args.option.values = _AnchorPoints
    end

    if customOptionArgs then
      for k, v in pairs(customOptionArgs) do
        t.args.option[k] = v
      end
    end
    return t
  end

endclass "OptionBuilder"
