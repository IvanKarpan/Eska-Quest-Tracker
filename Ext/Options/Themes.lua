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

          }
        }
      }
    }

end
