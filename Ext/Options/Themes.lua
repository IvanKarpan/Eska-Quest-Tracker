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

  local function GetThemeList()
    local themeList = {}
    for _, theme in Themes:GetIterator() do
      themeList[theme.name] = theme.name
    end
    return themeList
  end

  local function GetThemeSelected()
    return Themes:GetSelected().name
  end

  local function OnThemeChanged(themeName, recipe, info)
    Themes:Select(themeName)
    OptionBuilder:SetVariable("theme-selected", themeName)
    info.rebuild()

  end

  OptionBuilder:AddRecipe(TabRecipe("", "Themes/Tabs"), "Themes/Children")
  OptionBuilder:AddRecipe(TabItemRecipe("General", "Themes/General"):SetID("general"):SetOrder(10), "Themes/Tabs")
  OptionBuilder:AddRecipe(TabItemRecipe("Import", "Themes/Import"):SetID("import"):SetOrder(20), "Themes/Tabs")
  OptionBuilder:AddRecipe(TabItemRecipe("Export", "Themes/Export"):SetID("export"):SetOrder(30), "Themes/Tabs")

  OptionBuilder:AddRecipe(SelectRecipe():SetText("Select a theme"):SetValue(GetThemeSelected):SetList(GetThemeList):OnValueChanged(OnThemeChanged):SetOrder(10), "Themes/General")
  OptionBuilder:AddRecipe(HeadingRecipe():SetText("Theme Information"):SetOrder(11), "Themes/General")
  OptionBuilder:AddRecipe(ThemeInformationRecipe():SetOrder(12), "Themes/General")

  OptionBuilder:AddRecipe(HeadingRecipe():SetText("|cff00ff00Create a Theme|r"):SetOrder(20), "Themes/General")
  OptionBuilder:AddRecipe(CreateThemeRecipe():SetOrder(21), "Themes/General")
  --OptionBuilder:AddRecipe(EditBoxRecipe():SetText("Theme Name"):SetOrder(21), "Themes/General")
  --OptionBuilder:AddRecipe(EditBoxRecipe():SetText("Theme Author"):SetOrder(22), "Themes/General")
  --OptionBuilder:AddRecipe(EditBoxRecipe():SetText("Theme Stage"):SetOrder(23), "Themes/General")
  --OptionBuilder:AddRecipe(EditBoxRecipe():SetText("Theme Version"):SetOrder(24), "Themes/General")


  OptionBuilder:AddRecipe(HeadingRecipe():SetText("|cffff0000Delete a Theme|r"):SetOrder(30), "Themes/General")

  local deleteTextInfo = "|cff00ffffInfo:|r |cffffd800Only Themes that have been created from options or imported can be deleted.|r"
  OptionBuilder:AddRecipe(TextRecipe():SetText(deleteTextInfo):SetOrder(31), "Themes/General")

  local function GetDeletedThemeList()
    local themeList = {}
    for _, theme in Themes:GetIterator() do
      if not theme.lua then
        themeList[theme.name] = theme.name
      end
    end
    return themeList
  end

  local function DeleteThemeChanged(value)
    OptionBuilder:SetVariable("delete-theme-name", value)
  end

  local function DeleteThemeButtonOnClick(parent, info)
    local themeToDelete = OptionBuilder:GetVariable("delete-theme-name")
    if themeToDelete then
      if Themes:Delete(themeToDelete) then
        info.rebuild()
      end
    end
  end


  OptionBuilder:AddRecipe(SelectRecipe():SetText("Delete a theme"):SetList(GetDeletedThemeList):OnValueChanged(DeleteThemeChanged):SetOrder(32), "Themes/General")
  OptionBuilder:AddRecipe(ButtonRecipe():SetText("Delete"):OnClick(DeleteThemeButtonOnClick):SetOrder(33), "Themes/General")


  -- Import
  OptionBuilder:AddRecipe(ImportThemeRecipe():SetOrder(10), "Themes/Import")
  OptionBuilder:AddRecipe(ExportThemeRecipe():SetOrder(10), "Themes/Export")
end
