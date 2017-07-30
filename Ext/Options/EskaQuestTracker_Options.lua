--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio                "EskaQuestTracker.Options"                        "1.1.5"
-- ========================================================================== --
namespace "EQT"                                                               --                                                          --
-- ========================================================================== --
_AceGUI = LibStub("AceGUI-3.0")
_AceConfig = LibStub("AceConfig-3.0")
_AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
_AceConfigDialog = LibStub("AceConfigDialog-3.0")
-- ========================[[ OptionBuilder ]]==================================
_OptionBuilder  = OptionBuilder()
-- =============================================================================
_Fonts          = _LibSharedMedia:List("font")
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
-- ========================================================================== --
GetFontIndex = function(font)
  for i, v in next, _Fonts do
    if v == font then return i end
  end
end
-- ========================================================================== --
local f

local function FillSpace(str, maxCharacter)
  local charDiff = maxCharacter - str:len()
  local finalStr = str
  for i = 1, maxCharacter do
    if i > str:len() then
      finalStr = finalStr .. " "
    end
  end

  return finalStr
end

CreateRowString = function(label, field, strColorLabel, strColorField, maxChar)
  local finalStr = ""

  label = FillSpace(label, maxChar or 12)
  if strColorLabel then
    label = string.format("|cff%s%s|r", strColorLabel, label)
  end

  if strColorField then
    field = string.format("|cff%s%s|r", strColorField, field)
  end

  finalStr = label.. " ".. field

  return finalStr
end

_Settings = {
  type = "group",
  name = "Eska Quest tracker - Options",
  args = {
    EQT = {
      type = "group",
      name = "Eska Quest Tracker",
      childGroups = "tree",
      args = {
        addonInfo = {
          type = "description",
          name = "|cffffd800Addon Info",
          order = 10,
          fontSize = "large",
        },
        addonVersion = {
          type = "description",
          name = CreateRowString("Version", _EQT_VERSION, "0094ff"),
          order = 11,
          fontSize = "medium",
        },
        addonStage = {
          type = "description",
          name = CreateRowString("Stage", _EQT_STAGE, "0094ff", nil, 13),
          order = 12,
          fontSize = "medium",
        },
        slashCommands = {
          type = "description",
          name = "\n\n|cffffd800Slash Commands",
          order = 20,
          fontSize = "large",
        },
        slashOpenOption = {
          type = "description",
          name = "|cffff6a00/eqt|r "..CreateRowString("open|config|option", "- open the options", "00ffff", nil, 28),
          order = 21,
        },
        slashShowObjectiveTracker = {
          type = "description",
          name = "|cffff6a00/eqt|r "..CreateRowString("show", "- show the objective tracker", "00ffff", nil, 40),
          order = 22,
        },
        slashHideObjectiveTracker = {
          type = "description",
          name = "|cffff6a00/eqt|r "..CreateRowString("hide", "- hide the objective tracker", "00ffff", nil, 42),
          order = 23,
        },
        slashDBReset = {
          type = "description",
          name = "|cffff6a00/eqt|r "..CreateRowString("dbreset", "- reset the settings", "00ffff", nil, 40),
          order = 24
        },
        slashPrintPLoopVersion = {
          type = "description",
          name = "|cffff6a00/eqt|r "..CreateRowString("ploop", "- print the PLoop version", "00ffff", nil, 40),
          order = 25,
        },
        slashPrintScorpioVersion = {
          type = "description",
          name = "|cffff6a00/eqt|r "..CreateRowString("scorpio", "- print the Scorpio version", "00ffff", nil, 39),
          order = 26,
        },
      dependencies = {
          type = "description",
          name = "\n\n" .."|cffff0000Dependencies|r",
          fontSize = "large",
          order = 30,
          width = "full"
        },

        ploop = {
          type = "description",
          fontSize = "medium",
          order = 31,
          name = "\n".. string.format("----- |cff0094ffPLoop|r   |cff00ff00v%d|r", _PLOOP_VERSION)
        },
        scorpio = {
          type = "description",
          fontSize = "medium",
          order = 32,
          name = string.format("----- |cffff6a00Scorpio|r |cff00ff00v%d|r", _SCORPIO_VERSION)
        }
      }
    }
  }
}

Category = _Settings.args.EQT.args -- @TODO Remove this line
_Categories = _Settings.args.EQT.args


-- Tracker Category

-- ========================================================================== --
-- == TRACKER CATEGORY
-- ========================================================================== --
_Categories.Tracker = {
  type = "group",
  name = "Tracker",
  order = 1,
  args = {
      lock = {
        type = "toggle",
        name = "Lock",
        order = 1,
        get = function() return ObjectiveTracker.locked end,
        set = function(_, locked) ObjectiveTracker.locked = locked end
      },
      show = {
        type = "execute",
        name = "Show/Hide",
        order = 2,
        func = function()
          if _Addon.ObjectiveTracker:IsShown() then
            _Addon.ObjectiveTracker:Hide()
          else
            _Addon.ObjectiveTracker:Show()
          end
        end,
      },
      size = {
        type = "group",
        name = "Size",
        order = 3,
        inline = true,
        args = {
          width = {
            type = "range",
            name = "Width",
            order = 1,
            step = 1,
            min = 270,
            max = 500,
            get = function() return ObjectiveTracker.width end,
            set = function(_, width) ObjectiveTracker.width = width end,
          },
          height = {
            type = "range",
            name = "Height",
            order = 2,
            step = 1,
            min = 64,
            max = 1024,
            get = function() return ObjectiveTracker.height end,
            set = function(_, height) ObjectiveTracker.height = height end,
          }
        }
      },
      bg = {
          type = "group",
          name = "",
          order = 4,
          inline = true,
          args = {
            backgroundColor = {
              type = "color",
              name = ThemeColor("background color"),
              order = 1,
              hasAlpha = true,
              get = function()
                  local color = API:GetThemeProperty("tracker", "background-color")
                  return color.r, color.g, color.b, color.a
              end,
              set = function(_, r, g, b, a) API:SetAndRefreshThemeProperty("tracker", "background-color", { r = r, g = g, b = b, a = a }) end,
            },
            borderColor = {
              type = "color",
              name = ThemeColor("border Color"),
              order = 2,
              hasAlpha = true,
              get = function()
                local color = API:GetThemeProperty("block", "background-color")
                return color.r, color.g, color.b, color.a
              end,
              set = function(_, r, g, b, a) API:SetAndRefreshThemeProperty("tracker", "border-color", { r = r, g = g, b = b, a = a }) end,
            }
          }
      },
      blizzardTracker = {
        type = "group",
        name = "Blizzard objective tracker",
        inline = true,
        order = 50,
        args = {
          replace = {
            type = "toggle",
            name = "Replace completely the blizzard objective tracker",
            width = "full",
            get = function() return _DB.replaceBlizzardObjectiveTracker end,
            set = function(_, value) _DB.replaceBlizzardObjectiveTracker = value ; _Addon.BLIZZARD_TRACKER_VISIBLITY_CHANGED(not value) end
          }
        }
      }
    }
  }
-- ========================================================================== --
-- == BLOCK CATEGORY
-- ========================================================================== --
--[[
_Categories.Blocks = {
  type = "group",
  name = "Blocks",
  order = 2,
  childGroups = "tab",
  args = {
    common = {
      type = "group",
      name = "Common",
      order = 1,
      childGroups = "tab",
      args = {
          general = {
            type = "group",
            name = "General",
            order = 1,
            args = {
              backgroundColor = {
                type = "color",
                name = "Background color",
                order = 1,
                hasAlpha = true,
                get = function()
                  local color = Block.backgroundColor
                  return color.r, color.g, color.b, color.a
                end,
                set = function(_, r, g, b, a) Block.backgroundColor = { r = r, g = g, b = b, a = a } end
              },
              borderColor = {
                type = "color",
                name = "Border Color",
                order = 2,
                hasAlpha = true,
                get = function()
                  local color = Block.borderColor
                  return color.r, color.g, color.b, color.a
                end,
                set = function(_, r, g, b, a) Block.borderColor = { r = r, g = g, b = b, a = a } end,
              }
            }
          },
          header = {
            type = "group",
            name = "Header",
            order = 2,
            args = {
              backdropColor = {
                type = "color",
                name = "Background color",
                order = 1,
                hasAlpha = true,
                get = function()
                  local color = Block.headerBackdropColor
                  return color.r, color.g, color.b, color.a
                end,
                set = function(_, r, g, b, a)
                  Block.headerBackdropColor = { r = r, g = g, b = b, a = a }
                end,
              },
              borderColor = {
                type = "color",
                name = "Border color",
                order = 2,
                hasAlpha = true,
                get = function()
                  local color = Block.headerBorderColor
                  return color.r, color.g, color.b, color.a
                end,
                set = function(_, r, g, b, a)
                  Block.headerBorderColor = { r = r, g = g, b = b, a = a }
                end
              },
              stripeColor = {
                type = "color",
                name = "Stripe color",
                order = 3,
                hasAlpha = true,
                get = function()
                  local color = Block.headerStripeColor
                  return color.r, color.g, color.b, color.a
                end,
                set = function(_, r, g, b, a)
                  Block.headerStripeColor = { r = r, g = g, b = b, a = a}
                end,
              },
              headerText = {
                type = "group",
                name = "Header text",
                inline = true,
                order = 4 ,
                args = {
                  textSize = {
                    type = "range",
                    name = "Text size",
                    order = 1,
                    step = 1,
                    min = 4,
                    max = 32,
                    get = function() return Block.headerTextSize end,
                    set = function(_, size) Block.headerTextSize = size end,
                  },
                  textFont = {
                    type = "select",
                    name = "Text font",
                    order = 2,
                    values = _Fonts,
                    itemControl = "DDI-Font",
                    get = function() return GetFontIndex(Block.headerTextFont) end,
                    set = function(_, font) Block.headerTextFont = _Fonts[font] end,
                  },
                  textColor = {
                    type = "color",
                    name = "Text color",
                    order = 3,
                    get = function()
                      local color = Block.headerTextColor
                      return color.r, color.g, color.g, color.a
                    end,
                    set = function(_, r, g, b, a)
                      Block.headerTextColor = { r = r, g = g, b = b, a = a }
                    end,
                  },
                  textTransform = {
                    type = "select",
                    name = "Text transform",
                    values = _TextTransforms,
                    order = 4,
                    get = function() return Block.headerTextTransform end,
                    set = function(_, transform) Block.headerTextTransform = transform end,
                  },
                  textOffsetX = {
                    type = "range",
                    name = "Text offset X",
                    order = 5,
                    step = 1,
                    min = -200,
                    max = 200,
                    get = function() return Block.headerTextOffsetX end,
                    set = function(_, offsetX) Block.headerTextOffsetX = offsetX end,
                  },
                  textOffsetY = {
                    type = "range",
                    name = "Text offset Y",
                    order = 6,
                    step = 1,
                    min = -100,
                    max = 100,
                    get = function() return Block.headerTextOffsetY end,
                    set = function(_, offsetY) Block.headerTextOffsetY = offsetY end,
                  },
                  textLocation = {
                    type = "select",
                    name = "Text Location",
                    values = _AnchorPoints,
                    get = function() return Block.headerTextLocation end,
                    set = function(_, anchorPoint) Block.headerTextLocation  = anchorPoint end,
                  },

                }
              }
            }
          }
      },
    },
    customBlockConfigs = {
      type = "group",
      name = "Custom block configurations",
      order = 2,
      childGroups = "select",
      args = {}
    }
  }
}

_CustomBlockConfigurations = _Categories.Blocks.args.customBlockConfigs.args
--]]


function OnEnable(self)
  _AceConfig:RegisterOptionsTable("EskaQuestTracker", _Settings)
  -- self:Open()
end

function OnDisable(self)

end

__SlashCmd__ "eqt" "config" "- open the options"
__SlashCmd__ "eqt" "open" "- open the options"
__SlashCmd__ "eqt" "option" "- open the options"
function Open(self)
  if not f then
      f = _AceGUI:Create("Frame")
  end
  _AceConfigDialog:Open("EskaQuestTracker", f)
end
