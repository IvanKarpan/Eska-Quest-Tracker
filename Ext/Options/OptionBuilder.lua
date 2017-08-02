-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                "EskaQuestTracker.Options.OptionBuilder"               ""
-- ========================================================================== --
namespace "EQT"                                                               --
import "System.Reflector"                                                             --
-- ========================================================================== --
__Flags__()
enum "TextOptionFlags" {
  TEXT_FONT_OPTION = 1,
  TEXT_SIZE_OPTION = 2,
  TEXT_COLOR_OPTION = 4,
  TEXT_TRANSFORM_OPTION = 8,
}

__Unique__()
class "OptionBuilder"

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

__Arguments__{ Class, String }
function CreateBlockOptions(self, childBlock, name)
  _CustomBlockConfigurations[name] = {
    type = "group",
    name = name,
    childGroups = "tab",
    args = {
      enable = {
        type = "toggle",
        name = "Enable custom config",
        order = 1,
        get = function() return childBlock.customConfigEnabled end,
        set = function(_, enabled) childBlock.customConfigEnabled = enabled end,

      },
      general = {
        type = "group",
        name = "General",
        order = 2,
        disabled = function() return not childBlock.customConfigEnabled end,
        args = {
          backdropColor = {
            type = "group",
            name = "",
            inline = true,
            order = 1,
            args = self:CreateBlockPropertyOptions(childBlock, "Background color", "backdropColor", "color")
          },
          borderColor = {
            type = "group",
            name = "",
            inline = true,
            order = 2,
            args = self:CreateBlockPropertyOptions(childBlock, "Border color", "borderColor", "color")
          }
        }
      },
      header = {
        type = "group",
        name = "Header",
        order = 3,
        disabled = function() return not childBlock.customConfigEnabled end,
        args = {
          backdropColor = {
            type = "group",
            name = "",
            inline = true,
            order = 1,
            args = self:CreateBlockPropertyOptions(childBlock, "Background color", "headerBackdropColor", "color")
          },
          border =  {
            type = "group",
            name = "",
            inline = true,
            order = 2,
            args = self:CreateBlockPropertyOptions(childBlock, "Border color", "headerBorderColor", "color")
          },
          stripeColor = {
            type = "group",
            name = "",
            inline = true,
            order = 3,
            args = self:CreateBlockPropertyOptions(childBlock, "Stripe color", "headerStripeColor", "color")
          },
          headerText = {
            type = "group",
            name = "Header text",
            inline = true,
            order = 4,
            args = {
              text = {
                type = "group",
                name = "",
                inline = true,
                order = 1,
                args = self:CreateBlockPropertyOptions(childBlock, "Text", "headerText", "input")
              },
              textSize = {
                type = "group",
                name = "",
                inline = true,
                order = 2,
                args = self:CreateBlockPropertyOptions(childBlock, "Text size", "headerTextSize", "range", { step = 1, min = 4, max = 32 })
              },
              textFont = {
                type = "group",
                name = "",
                inline = true,
                order = 3,
                args = self:CreateBlockPropertyOptions(childBlock, "Text font", "headerTextFont", "selectFont")
              },
              textColor = {
                type = "group",
                name = "",
                inline = true,
                order = 4,
                args = self:CreateBlockPropertyOptions(childBlock, "Text color", "headerTextColor", "color")
              },
              textTransforms = {
                type = "group",
                name = "",
                inline = true,
                order = 5,
                args = self:CreateBlockPropertyOptions(childBlock, "Text transform", "headerTextTransform", "select", { values = _TextTransforms} )
              },
              textOffsetX = {
                type = "group",
                name = "",
                inline = true,
                order = 6,
                args = self:CreateBlockPropertyOptions(childBlock, "Text offset X", "headerTextOffsetX", "range", { step = 1, min = -200, max = 200 }),
              },
              textOffsetY = {
                type = "group",
                name = "",
                inline = true,
                order = 7,
                args = self:CreateBlockPropertyOptions(childBlock, "Text offset Y", "headerTextOffsetY", "range", { step = 1, min = -200, max = 200}),
              },
              textLocation = {
                type = "group",
                name = "",
                inline = true,
                order = 8,
                args = self:CreateBlockPropertyOptions(childBlock, "Text location", "headerTextLocation", "select", { values = _AnchorPoints })
              }
            }
          }
        }
      }
    }
  }

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





function CreateBlockPropertyOptions(self, class, nameDisplayed, property, optionType, customOptionArgs)
  local t = {}

  t.enable = {
    type = "toggle",
    name = nameDisplayed,
    order = 1,
    get = function() return class:IsBlockPropertyEnabled(property) end,
    set = function(_, enabled) class:SetBlockPropertyEnabled(property, enabled) end,
  }

  t.option = {
    type = optionType,
    name = "",
    order = 2,
    disabled = function() return not class:IsBlockPropertyEnabled(property) end,
  }

  if optionType == "color" then
    t.option.hasAlpha = true
    t.option.get = function()
      local color = class:GetBlockProperty(property)
      return color.r, color.g, color.b, color.a
    end
    t.option.set = function(_, r, g, b, a)
      class:SetBlockPropertyValue(property, {
        r = r, g = g, b = b, a = a
      })
    end
  elseif optionType == "selectFont" then
    t.option.type = "select"
    t.option.values = _Fonts
    t.option.itemControl = "DDI-Font"
    t.option.get = function() return GetFontIndex(class:GetBlockProperty(property)) end
    t.option.set = function(_, font) class:SetBlockPropertyValue(property, _Fonts[font]) end
  else
    t.option.get = function() return class:GetBlockProperty(property) end
    t.option.set = function(_, value) return class:SetBlockPropertyValue(property, value) end
  end

  if customOptionArgs then
    for k, v in pairs(customOptionArgs) do
      t.option[k] = v
    end
  end
  return t
end


endclass "OptionBuilder"
