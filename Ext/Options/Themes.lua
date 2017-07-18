-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio            "EskaQuestTracker.Options.Themes"                          ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
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


function CreateThemeOption(self, theme)
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
        properties = {
          type = "group",
          name = "Properties",
          order = 2,
          args = {

          }
        }
      }
    }

end

-- ThemeKeyword("block", ThemeKeywordType.FRAME + ThemeKeywordType.TEXTURE, "blockInherit")
