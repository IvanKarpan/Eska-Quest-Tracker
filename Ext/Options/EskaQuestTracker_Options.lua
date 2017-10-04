--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio                "EskaQuestTracker.Options"                             ""
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
        },
        optSeparator = {
          type = "description",
          name = "\n" .. "|cffffd800Global options|r",
          fontSize = "large",
          order = 40,
          width = "full",
        },
        enableMinimap = {
          type = "toggle",
          name = "Enable minimap icon",
          order = 41,
          get = function() return not _DB.minimap.hide end,
          set = function(_, enable)
            if enable then
              _LibDBIcon:Show("EskaQuestTracker")
            else
              _LibDBIcon:Hide("EskaQuestTracker")
            end
            _DB.minimap.hide = not enable
          end
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
        get = function() return Options:Get("tracker-locked") end,
        set = function(_, locked) Options:Set("tracker-locked", locked) end
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
            get = function() return Options:Get("tracker-width") end,
            set = function(_, width) Options:Set("tracker-width", width) end,
          },
          height = {
            type = "range",
            name = "Height",
            order = 2,
            step = 1,
            min = 64,
            max = 1024,
            get = function() return Options:Get("tracker-height") end,
            set = function(_, height) Options:Set("tracker-height", height) end,
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
      showScrollbar = {
          type = "toggle",
          name = "Show scrollbar",
          order = 5,
          get = function() return Options:Get("tracker-show-scrollbar") end,
          set = function(_, value) Options:Set("tracker-show-scrollbar", value) end,
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
            get = function() return Options:Get("replace-blizzard-objective-tracker") end,
            set = function(_, value) Options:Set("replace-blizzard-objective-tracker", value) ; _Addon.BLIZZARD_TRACKER_VISIBLITY_CHANGED(not value) end
          }
        }
      }
    }
  }

-- ========================================================================== --
-- == MENU CONTEXT CATEGORY
-- ========================================================================== --
_Categories.MenuContext = {
  type = "group",
  name = "Menu context",
  order = 4,
  args = {
    menuContext = {
      type = "select",
      name = "Orientation",
      values = function()
        local t = {
          ["RIGHT"] = "RIGHT",
          ["LEFT"] = "LEFT"
         }
         return t
      end,
      get = function() return Options:Get("menu-context-orientation") end,
      set = function(_, value) Options:Set("menu-context-orientation", value) end,
    }
  }
}

-- ========================================================================== --
-- == ITEM BAR CATEGORY
-- ========================================================================== --
_Categories.ItemBar = {
  type = "group",
  name = "Item bar",
  order = 3,
  args = {
    position = {
      type = "select",
      name = "Position",
      order = 1,
      values = function()
        local t = {
          ["TOPLEFT"] = "Top Left",
          ["TOPRIGHT"] = "Top Right",
          ["BOTTOMLEFT"] = "Bottom Left",
          ["BOTTOMRIGHT"] = "Bottom Right"
        }
        return t
      end,
      get = function() return Options:Get("item-bar-position") end,
      set = function(_, value) Options:Set("item-bar-position", value) end
    },
    directionGrowth = {
      type = "select",
      name = "Direction growth",
      order = 2,
      values = function()
        local t = {
          ["RIGHT"] = "Left",
          ["LEFT"] = "Right",
          ["UP"] = "Up",
          ["DOWN"] = "Down",
        }
        return t
      end,
      get = function() return Options:Get("item-bar-direction-growth") end,
      set = function(_, value) Options:Set("item-bar-direction-growth", value) end
    },
    offsetPos = {
      type = "group",
      name = "Position offset",
      inline = true,
      order = 3,
      args = {
        x = {
          type = "range",
          name = "x",
          min = -200,
          max = 200,
          step = 1,
          get = function() return Options:Get("item-bar-offset-x") end,
          set = function(_, value) Options:Set("item-bar-offset-x", value) end
        },
        y = {
          type = "range",
          name = "y",
          min = -200,
          max = 200,
          step = 1,
          get = function() return Options:Get("item-bar-offset-y") end,
          set = function(_, value) Options:Set("item-bar-offset-y", value) end,
        }
      }
    }
  }
}

-- ========================================================================== --
-- == GROUP FINDER CATEGORY
-- ========================================================================== --
_Categories.GroupFinders = {
  type = "group",
  name = "Group finders",
  order = 5,
  args = {
    groupFinders = {
      type = "select",
      name = "Select a group finder",
      values = function()
        local t = {}
        for name in GroupFinderAddon:GetIterator() do
          t[name] = name
        end
        return t
      end,
      get = function()
        local _, name = GroupFinderAddon:GetSelected()
        return name
      end,
      set = function(_, value)
        GroupFinderAddon:SetSelected(value)
      end
    }
  }
}

function OnEnable(self)
  _AceConfig:RegisterOptionsTable("EskaQuestTracker", _Settings)
end

function Open(self)
  if not f then
      f = _AceGUI:Create("Frame")
  end
  _AceConfigDialog:Open("EskaQuestTracker", f)
end
