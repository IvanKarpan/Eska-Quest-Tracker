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

        return API:RemoveThemePropertyFlags(val),
               API:GetThemePropertyFlags(val),
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
      set = function(_, value)  end,
    },
    themeInfo = {
      type = "description",
      name = "Theme info",
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


function GetThemeProp(self, target, property)
  if not target or not property then return end

  local val = API:GetThemeProperty(target, property, nil, false)

  if val then
    return val
  end

  val = API:GetThemeProperty(target..".*", property, nil, false)

  if val then
    return val
  end

end


function CreateKeywordOptions(self, name, flags, flagsColor, target, optionflags)

  if not optionflags then
    optionflags = Options.ThemeKeywordType.FRAME + Options.ThemeKeywordType.TEXT + Options.ThemeKeywordType.TEXTURE
  end

  local fstr = ""
  for _, flag in ipairs(flags) do
    fstr = fstr .. flag .. " "
  end


  local options = {
    type = "group",
    name = string.format("%s |cff%s%s|r", name, flagsColor, fstr),
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

   frameTab.args.backgroundColor = _OptionBuilder:CreateEnableBlockOption(1, "Background Color", "color", {
     get = function() local color = self:GetThemeProp(target, "background-color")
       if color then
         return color.r, color.g, color.b, color.a
       end
     end,
     set = function(_, r, g, b, a)
       API:SetAndRefreshThemeProperty(target, "background-color", { r = r, g = g, b = b, a = a})
     end
   })
   frameTab.args.borderColor = _OptionBuilder:CreateEnableBlockOption(2, "Border Color", "color", {
     get = function() local color = self:GetThemeProp(target, "border-color")
       if color then
         return color.r, color.g, color.b, color.a
       end
     end,
     set = function(_, r, g, b, a)
       API:SetAndRefreshThemeProperty(target, "background-color", { r = r, g = g, b = b, a = a})
     end
   })

   elementParentOpt.args.frame = frameTab
  end

  if ValidateFlags(optionflags, Options.ThemeKeywordType.TEXT) then
    local textTab = {
      type = "group",
      name = "Text",
      args = {}
    }

    textTab.args.textSize = _OptionBuilder:CreateEnableBlockOption(1, "Text Size", "range", {
      min = 6,
      max = 32,
      get = function() return self:GetThemeProp(target, "text-size") end,
    })
    textTab.args.textColor = _OptionBuilder:CreateEnableBlockOption(2, "Text Color", "color", {
      get = function() local color = self:GetThemeProp(target, "text-color")
        if color then
          return color.r, color.g, color.b, color.a
        end
      end,
      set = function(_, r, g, b)
        API:SetAndRefreshThemeProperty(target, "text-color", { r = r, g = g, b = b})
      end
    })
    textTab.args.textFont = _OptionBuilder:CreateEnableBlockOption(3, "Text Font", "selectFont", {
      get = function() return GetFontIndex(self:GetThemeProp(target, "text-font")) end
    })
    textTab.args.textTransform = _OptionBuilder:CreateEnableBlockOption(4, "Text Transform", "selectTransform", {
      get = function() return self:GetThemeProp(target, "text-transform") end
    })

    elementParentOpt.args.text = textTab
  end

  if ValidateFlags(optionflags, Options.ThemeKeywordType.TEXTURE) then
    local textureTab = {
      type = "group",
      name = "Texture",
      args = {}
    }

    textureTab.args.textureColor = _OptionBuilder:CreateEnableBlockOption(1, "Texture Color", "color", {
      get = function() local color = self:GetThemeProp(target, "vertex-color")
        if color then
          return color.r, color.g, color.b, color.a
        end
      end,
      set = function(_, r, g, b, a)
        API:SetAndRefreshThemeProperty(target, "vertex-color", { r = r, g = g, b = b, a = a })
      end,
    })

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
      _BUILD_OPTION_INFO[target].optionFlags = bit.bor(_BUILD_OPTION_INFO[target].optionFlags, optionFlags)
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


function CreateThemePropertiesOptions(self, properties, parent)
    local options = {
      type = "group",
      name = "Properties",
      order = 2,
      args = {},
    }

    for index, propInfo in _BUILD_OPTION_INFO:GetIterator() do
       local opt = self:CreateKeywordOptions(propInfo.name, propInfo.flags, propInfo.flagsColor, propInfo.target, propInfo.optionFlags)

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
        properties = self:CreateThemePropertiesOptions()
      }
    }

end
