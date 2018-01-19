-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio            "EskaQuestTracker.Options.Achievement"                     ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
function OnLoad(self)
  self:AddAchievementRecipes()
  self:AddAchievementsBlockRecipes()
end


function AddAchievementRecipes(self)
  OptionBuilder:AddRecipe(TreeItemRecipe("Achievement", "Achievement/Children"):SetID("achievement"):SetOrder(40), "RootTree")
    OptionBuilder:AddRecipe(ThemeDropDownRecipe("", "Achievement/SelectThemeToEdit/Children"), "Achievement/Children")
    OptionBuilder:AddRecipe(TabRecipe("", "Achievement/Tabs"):SetOrder(1), "Achievement/SelectThemeToEdit/Children")
    OptionBuilder:AddRecipe(TabItemRecipe("General", "Achievement/General"):SetID("general"):SetOrder(10), "Achievement/Tabs")
    OptionBuilder:AddRecipe(TabItemRecipe("Header", "Achievement/Header"):SetID("header"):SetOrder(20), "Achievement/Tabs")
    OptionBuilder:AddRecipe(TabItemRecipe("Name", "Achievement/Name"):SetID("name"):SetOrder(30), "Achievement/Tabs")
    OptionBuilder:AddRecipe(TabItemRecipe("Description", "Achievement/Description"):SetID("description"):SetOrder(40), "Achievement/Tabs")
    OptionBuilder:AddRecipe(TabItemRecipe("Icon", "Achievement/Icon"):SetID("icon"):SetOrder(50), "Achievement/Tabs")

    -- General
    OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Hide completed criteria"):BindOption("achievement-hide-criteria-completed"):SetOrder(10), "Achievement/General")
    OptionBuilder:AddRecipe(RangeGroupRecipe():SetText("Max criteria displayed"):BindOption("achievement-max-criteria-displayed"):SetRange(0, 20):SetOrder(30), "Achievement/General")
    OptionBuilder:AddRecipe(SelectStateRecipe():SetStates("none", "failed"):SetRecipeGroup("Achievement/General/States"), "Achievement/General")
    OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("achievement.frame"):SetRefresher("achievement/refresher"), "Achievement/General/States")
    -- Header
    OptionBuilder:AddRecipe(SelectStateRecipe():SetStates("none", "failed"):SetRecipeGroup("Achievement/Header/States"), "Achievement/Header")
    OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("achievement.header"):SetRefresher("achievement/refresher"), "Achievement/Header/States")
    -- Name
    OptionBuilder:AddRecipe(SelectStateRecipe():SetStates("none", "failed"):SetRecipeGroup("Achievement/Name/States"), "Achievement/Name")
    OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("achievement.name"):SetRefresher("achievement/refresher"):SetFlags(ThemeElementRecipe.ALL_TEXT_OPTIONS), "Achievement/Name/States")
    -- Description
        OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Show Description"):BindOption("achievement-show-description"):SetOrder(10), "Achievement/Description")
        OptionBuilder:AddRecipe(SelectStateRecipe():SetStates("none", "failed"):SetRecipeGroup("Achievement/Description/States"), "Achievement/Description")
        OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("achievement.description"):SetRefresher("achievement/refresher"):SetFlags(ThemeElementRecipe.ALL_TEXT_OPTIONS), "Achievement/Description/States")
    -- Icon
    OptionBuilder:AddRecipe(SelectStateRecipe():SetStates("none", "failed"):SetRecipeGroup("Achievement/Icon/States"), "Achievement/Icon")
    OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("achievement.icon"):SetRefresher("achievement/refresher"):SetFlags(ThemeElementRecipe.ALL_TEXTURE_OPTIONS), "Achievement/Icon/States")
end



function AddAchievementsBlockRecipes(self)
  OptionBuilder:AddRecipe(TreeItemRecipe("Achievements", "Achievements/Children"):SetID("block-achievements"):SetPath("blocks"):SetOrder(60), "RootTree")
  _Parent:CreateBlockRecipes("block.achievements", "Achievements/Children")
end
