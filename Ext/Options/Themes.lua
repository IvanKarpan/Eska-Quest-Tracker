-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                "EskaQuestTracker.Options.Themes"                      ""
--============================================================================--
namespace "EQT"
--============================================================================--
function OnLoad(self)
  self:AddThemesRecipes()
end

function AddThemesRecipes(self)

  OptionBuilder:AddRecipe(TreeItemRecipe("Themes", "Themes/Children"):SetID("themes"):SetOrder(90), "RootTree")

  local themeList = {}
  for _, theme in Themes:GetIterator() do
    themeList[theme.name] = theme.name
  end

  local function GetThemeSelected()
    return Themes:GetSelected().name
  end

  local function OnThemeChanged(themeName)
    Themes:Select(themeName)
    OptionBuilder:SetVariable("theme-selected", themeName)
  end

  OptionBuilder:AddRecipe(SelectRecipe():SetText("Select a theme"):SetValue(GetThemeSelected):SetList(themeList):OnValueChanged(OnThemeChanged), "Themes/Children")
end
