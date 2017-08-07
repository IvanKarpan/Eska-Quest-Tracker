-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio            "EskaQuestTracker.Options.Themes"                          ""
-- ========================================================================== --
namespace "EQT"
import "System.Reflector"
-- ========================================================================== --
_KEYWORDS_OPTIONS = {}

-- RETURN NAME without flags, flags list, parent with flags
PROPERTY_INFO = function(target)
  local function UnpackTargets(...)
    local count = select("#", ...)
    local currentParent = ""

    for i = 1, count do
      local val = select(i, ...)
      if i == count then
        return API:RemoveThemePropertyFlags(val), API:GetThemePropertyFlags(val),
        currentParent ~= "" and string.format("%s%s", currentParent, val:match("%[.*%]") or "") or nil
      elseif i == 1 then
        currentParent = val
      else
        currentParent = currentParent .. "." .. val
      end
    end
  end
  return UnpackTargets(strsplit(".", target))
end

_Categories.Themes = {
  type = "group",
  name = "Themes",
  order = -1,
  args = {
    selectTheme = {
      type = "select",
      name = "Select a theme",
      values = function()
        local list = {}
        for _, theme in _Addon:GetThemes():GetIterator() do
          list[theme.name] = theme.name
        end
        return list
      end,
      get = function() return _DB.currentTheme end,
      set = function(_, value)
        _Addon:SelectTheme(value)
      end,
    },
    themeInfo = {
      type = "description",
      name = "",
      order = 10,
      fontSize = "large",
    }
  }
}

local themesGroup = _Categories.Themes.args


function OnLoad(self)
  for _, theme in _Addon:GetThemes():GetIterator() do
    self:CreateThemeOption(theme)
  end
end




function GetThemeProperty(self, themeName, target, property)
  local theme = _Addon:GetTheme(themeName)
  if theme then
    return theme:GetProperty(target, property)
  end
end

function GetThemeDBProperty(self, themeName, target, property)
  local theme = _Addon:GetTheme(themeName)
  if theme then
    return theme:GetDBProperty(target, property)
  end
end


function SetThemeDBProperty(self, themeName, target, property, value)
  local theme = _Addon:GetTheme(themeName)
  if theme then
    theme:SetProperty(target, property, value, true)
    if theme.name == _Addon:GetCurrentTheme().name then
      local firstClass = strsplit(".", API:RemoveThemePropertyFlags(target), 2)
      Theme.RefreshGroup(firstClass)
    end
  end
end


function CreateKeywordOptions(self, themeName, name, flags, flagsColor, target, optionflags)

  if not optionflags then
    optionflags = Options.ThemeKeywordType.FRAME + Options.ThemeKeywordType.TEXT + Options.ThemeKeywordType.TEXTURE
  end

  local fstr = ""
  for _, flag in ipairs(flags) do
    fstr = fstr .. flag .. " "
  end


  local options = {
    type = "group",
    name = string.format("%s |cff%s%s|r", name:gsub("^%l", string.upper), flagsColor, fstr),
    args = {}
  }

  --[[
  options.args["title"] = {
    type = "description",
    order = 1,
    fontSize = "large",
    name = string.format("-- %s |cff%s%s|r", name, flagsColor, fstr)
  }--]]

  options.args["2"] = {
    type = "group",
    order = 2,
    name = "",
    inline = true,
    args = {}
  }


  local elementParentOpt = options.args["2"]

  if ValidateFlags(optionflags, Options.ThemeKeywordType.FRAME) then
    local frameTab = {
      type = "group",
      name = "Frame",
      args = {}
    }

    ----------------------------------------------------------------------------
    --                     FRAME TAB / Background color                       --
    ----------------------------------------------------------------------------
   frameTab.args.backgroundColor = _OptionBuilder:CreateEnableBlockOption(1, "Background Color", "color",
    -- # Value control
     {
       get = function() local color = self:GetThemeProperty(themeName, target, "background-color")
         if color then
           return color.r, color.g, color.b, color.a
         end
       end,
       set = function(_, r, g, b, a)
         self:SetThemeDBProperty(themeName, target, "background-color", { r = r, g = g, b = b, a = a})
       end
     },
    -- # Enable control
     {
       get = function() return self:GetThemeDBProperty(themeName, target, "background-color") end,
       set = function(_, enable) if not enable then self:SetThemeDBProperty(themeName, target, "background-color", nil)  end end
     }
   )
    ----------------------------------------------------------------------------
    --                     FRAME TAB / Border color                           --
    ----------------------------------------------------------------------------
   frameTab.args.borderColor = _OptionBuilder:CreateEnableBlockOption(2, "Border Color", "color",
    -- # Value control
     {
       get = function() local color = self:GetThemeProperty(themeName, target, "border-color")
         if color then
           return color.r, color.g, color.b, color.a
         end
       end,
       set = function(_, r, g, b, a) self:SetThemeDBProperty(themeName, target, "border-color", { r = r, g = g, b = b, a = a}) end
     },
     -- # Enable control
     {
       get = function() return self:GetThemeDBProperty(themeName, target, "border-color") end,
       set = function(_, enable) if not enable then self:SetThemeDBProperty(themeName, target, "border-color", nil)  end end
     }
   )

   elementParentOpt.args.frame = frameTab
  end

  if ValidateFlags(optionflags, Options.ThemeKeywordType.TEXT) then
    local textTab = {
      type = "group",
      name = "Text",
      args = {}
    }
    ----------------------------------------------------------------------------
    --                        TEXT TAB / Text Size                            --
    ----------------------------------------------------------------------------
    textTab.args.textSize = _OptionBuilder:CreateEnableBlockOption(1, "Text Size", "range",
    -- # Value control
      {
        min = 6,
        max = 32,
        step = 1,
        get = function() return self:GetThemeProperty(themeName, target, "text-size") end,
        set = function(_, size) self:SetThemeDBProperty(themeName, target, "text-size", size) end,
      },
     -- # Enable control
     {
       get = function() return self:GetThemeDBProperty(themeName, target, "text-size") end,
       set = function(_, size) if not enable then self:SetThemeDBProperty(themeName, target, "text-size", nil) end end
     }
    )
    ----------------------------------------------------------------------------
    --                        TEXT TAB / Text Color                           --
    ----------------------------------------------------------------------------
    textTab.args.textColor = _OptionBuilder:CreateEnableBlockOption(2, "Text Color", "color",
    -- # Value control
      {
        get = function() local color = self:GetThemeProperty(themeName, target, "text-color")
          if color then
            return color.r, color.g, color.b, color.a
          end
        end,
        set = function(_, r, g, b)
          self:SetThemeDBProperty(themeName, target, "text-color", { r = r, g = g, b = b})
        end
      },
    -- # Enable control
      {
        get = function() return self:GetThemeDBProperty(themeName, target, "text-color") end,
        set = function(_, enable) if not enable then self:SetThemeDBProperty(themeName, target, "text-color", nil)  end end
      }
    )
    ----------------------------------------------------------------------------
    --                        TEXT TAB / Text Font                            --
    ----------------------------------------------------------------------------
    textTab.args.textFont = _OptionBuilder:CreateEnableBlockOption(3, "Text Font", "selectFont",
    -- # Value control
      {
        get = function() return GetFontIndex(self:GetThemeProperty(themeName, target, "text-font")) end,
        set = function(_, font) self:SetThemeDBProperty(themeName, target, "text-font", _Fonts[font]) end,
      },
    -- # Enable control
      {
        get = function() return self:GetThemeDBProperty(themeName, target, "text-font") end,
        set = function(_, enable) if not enable then self:SetThemeDBProperty(themeName, target, "text-font", nil) end end
      }
    )
    ----------------------------------------------------------------------------
    --                        TEXT TAB / Text Transform                       --
    ----------------------------------------------------------------------------
    textTab.args.textTransform = _OptionBuilder:CreateEnableBlockOption(4, "Text Transform", "selectTransform",
    -- # Value control
      {
        get = function() return self:GetThemeProperty(themeName, target, "text-transform") end,
        set = function(_, textTransform) self:SetThemeDBProperty(themeName, target, "text-transform", textTransform) end
      },
    -- # Enable control
      {
        get = function() return self:GetThemeDBProperty(themeName, target, "text-transform")  end,
        set = function(_, enable) if not enable then self:SetThemeDBProperty(themeName, target, "text-transform", nil) end end,
      })

    ----------------------------------------------------------------------------
    --                        TEXT TAB / Text Location                        --
    ----------------------------------------------------------------------------
    -- location
    -- offsetX
    -- offsetY
    textTab.args.textLocation = _OptionBuilder:CreateEnableBlockOption(5, "Text Location", "selectLocation",
      -- # Value control
        {
          get = function() return self:GetThemeProperty(themeName, target, "text-location") end,
          set = function(_, textLocation) self:SetThemeDBProperty(themeName, target, "text-location", textLocation) end
        },
      -- # Enable control
        {
          get = function() return self:GetThemeDBProperty(themeName, target, "text-location")  end,
          set = function(_, enable) if not enable then self:SetThemeDBProperty(themeName, target, "text-location", nil) end end,
        })
    ----------------------------------------------------------------------------
    --                        TEXT TAB / Text offsetX                         --
    ----------------------------------------------------------------------------
    textTab.args.textOffsetX = _OptionBuilder:CreateEnableBlockOption(6, "Text Offset X", "range",
      -- # Value control
        {
          min = -256,
          max = 256,
          step = 1,
          get = function() return self:GetThemeProperty(themeName, target, "text-offsetX") end,
          set = function(_, textOffsetX) self:SetThemeDBProperty(themeName, target, "text-offsetX", textOffsetX) end
        },
      -- # Enable control
        {
          get = function() return self:GetThemeDBProperty(themeName, target, "text-offsetX")  end,
          set = function(_, enable) if not enable then self:SetThemeDBProperty(themeName, target, "text-offsetX", nil) end end,
        })

    ----------------------------------------------------------------------------
    --                        TEXT TAB / Text offsetY                         --
    ----------------------------------------------------------------------------
    textTab.args.textOffsetY = _OptionBuilder:CreateEnableBlockOption(7, "Text Offset Y", "range",
      -- # Value control
        {
          min = -256,
          max = 256,
          step = 1,
          get = function() return self:GetThemeProperty(themeName, target, "text-offsetY") end,
          set = function(_, textOffsetY) self:SetThemeDBProperty(themeName, target, "text-offsetY", textOffsetY) end
        },
      -- # Enable control
        {
          get = function() return self:GetThemeDBProperty(themeName, target, "text-offsetY")  end,
          set = function(_, enable) if not enable then self:SetThemeDBProperty(themeName, target, "text-offsetY", nil) end end,
        })

    elementParentOpt.args.text = textTab
  end

  if ValidateFlags(optionflags, Options.ThemeKeywordType.TEXTURE) then
    local textureTab = {
      type = "group",
      name = "Texture",
      args = {}
    }
    ----------------------------------------------------------------------------
    --                     TEXTURE TAB /  Vertex Color                        --
    ----------------------------------------------------------------------------
    textureTab.args.textureColor = _OptionBuilder:CreateEnableBlockOption(1, "Texture Color", "color",
    -- # Value control
       {
         get = function() local color = self:GetThemeProperty(themeName, target, "vertex-color")
           if color then
             return color.r, color.g, color.b, color.a
           end
         end,
         set = function(_, r, g, b, a) self:SetThemeDBProperty(themeName, target, "vertex-color", { r = r, g = g, b = b, a = a}) end
       },
    -- # Enable control
       {
         get = function() return self:GetThemeDBProperty(themeName, target, "vertex-color") end,
         set = function(_, enable) if not enable then self:SetThemeDBProperty(themeName, target, "vertex-color", nil)  end end
       }
     )

    elementParentOpt.args.texture = textureTab
  end

  return options
end



function CreateOptionBuildTable()
  _BUILD_OPTION_INFO = Collections.Dictionary()

  local function ID(name, flags)
    local fStr = ""
    for _, flag in ipairs(flags) do
      fStr = fStr .. flag .. " "
    end

    return string.format("%s  %s", name, fStr)
  end

  local function CreateAndUpdateProperty(target, flagsColor, optionFlags)
    local propName, propFlags, parentTarget = PROPERTY_INFO(target)

    if _BUILD_OPTION_INFO[target] then
      --_BUILD_OPTION_INFO[target].optionFlags = bit.bor(_BUILD_OPTION_INFO[target].optionFlags, optionFlags)
      _BUILD_OPTION_INFO[target].optionFlags = optionFlags
    else
      _BUILD_OPTION_INFO[target] = {
        id = ID(API:RemoveThemePropertyFlags(target), propFlags),
        name = propName,
        flags = propFlags,
        target = target,
        parentTarget = parentTarget,
        optionFlags = optionFlags,
        flagsColor = flagsColor
      }
    end

    if parentTarget then
      CreateAndUpdateProperty(parentTarget, flagsColor, optionFlags)
    end
  end

  for _, themeProperty in Options.GetAvailableThemeKeywords() do
    CreateAndUpdateProperty(themeProperty.target, themeProperty.flagColorStr, themeProperty.type)

  end

  _BUILD_OPTION_INFO = _BUILD_OPTION_INFO.Values:ToList():Sort("a,b=>a.id<b.id")

end

function CreateThemeDefaultPropertiesOption(self, theme)
  return self:CreateKeywordOptions(theme.name, "Default properties", {}, "ffffff", "*")
end



function CreateThemePropertiesOptions(self, theme, properties, parent)
  local options = {
    type = "group",
    name = "Properties",
    order = 2,
    args = {}
  }

  for index, propInfo in _BUILD_OPTION_INFO:GetIterator() do
    local opt = self:CreateKeywordOptions(theme.name, propInfo.name, propInfo.flags, propInfo.flagsColor, propInfo.target, propInfo.optionFlags)
    if propInfo.parentTarget then
      _KEYWORDS_OPTIONS[propInfo.parentTarget].args[propInfo.target] = opt
    else
      options.args[propInfo.target] = opt
    end
   _KEYWORDS_OPTIONS[propInfo.target] = opt
  end
 _BUILD_OPTION_INFO = nil
  return options
 end

function CreateThemeOption(self, theme)
  self:CreateOptionBuildTable()

    themesGroup[theme.name] = {
      type = "group",
      name = theme.name,
      childGroups = "tab",
      args = {
        info = {
          type = "group",
          name = "Info",
          order = 1,
          args = {
              name = {
                type = "description",
                name = CreateRowString("Name", theme.name, "0094ff", "ff6a00", 30),
                order = 1,
                fontSize = "medium"
              },
              author = {
                type = "description",
                name = CreateRowString("Author", theme.author, "0094ff", "ff6a00", 30),
                order = 2,
                fontSize = "medium"
              },
              version = {
                type = "description",
                name = CreateRowString("Version", theme.version, "0094ff", "ff6a00", 30),
                order = 3,
                fontSize = "medium"
              },
              stage = {
                type = "description",
                name = CreateRowString("Stage", theme.stage, "0094ff", "ff6a00", 31),
                order = 4,
                fontSize = "medium"
              }
          }
        },
        defaultProperties = self:CreateThemeDefaultPropertiesOption(theme),
        properties = self:CreateThemePropertiesOptions(theme)
      }
    }

end
