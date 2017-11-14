-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                "EskaQuestTracker.Options.Scenario"                    ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
function OnLoad(self)
  self:AddScenarioBlockRecipes()
end

function AddScenarioBlockRecipes(self)
  OptionBuilder:AddRecipe(TreeItemRecipe("Scenario", "Scenario/Children"):SetID("block-scenario"):SetPath("blocks"):SetOrder(50), "RootTree")
  _Parent:CreateBlockRecipes("block.scenario", "Scenario/Children")

  OptionBuilder:AddRecipe(TabItemRecipe("Name", "Scenario/Name"):SetID("name"):SetOrder(4), "Scenario/Tabs")
  OptionBuilder:AddRecipe(TabItemRecipe("Stage", "Scenario/Stage"):SetID("stage"):SetOrder(5), "Scenario/Tabs")
  OptionBuilder:AddRecipe(TabItemRecipe("Stage Name", "Scenario/StageName"):SetID("stage-name"):SetOrder(6), "Scenario/Tabs")
  OptionBuilder:AddRecipe(TabItemRecipe("Stage Counter", "Scenario/StageCounter"):SetID("stage-counter"):SetOrder(7), "Scenario/Tabs")
  -- name
  OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("block.scenario.name"):SetRefresher("scenario/refresher"):SetFlags(ThemeElementRecipe.ALL_TEXT_OPTIONS), "Scenario/Name")
  -- Stage
  OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("block.scenario.stage"):SetRefresher("scenario/refresher"), "Scenario/Stage")
  -- stage Name
  OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("block.scenario.stageName"):SetRefresher("scenario/refresher"):SetFlags(ThemeElementRecipe.ALL_TEXT_OPTIONS), "Scenario/StageName")
  -- Stage Count
  OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("block.scenario.stageCounter"):SetRefresher("scenario/refresher"):SetFlags(ThemeElementRecipe.ALL_TEXT_OPTIONS), "Scenario/StageCounter")

end
