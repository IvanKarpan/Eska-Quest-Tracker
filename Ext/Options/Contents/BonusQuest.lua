-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                "EskaQuestTracker.Options.BonusQuest"                  ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
function OnLoad(self)
  self:AddBonusQuestRecipes()
  self:AddBonusObjectivesBlockRecipes()
end

function AddBonusQuestRecipes(self)
  -- Quests
  OptionBuilder:AddRecipe(TreeItemRecipe("Bonus Quest", "BonusQuest/Children"):SetID("bonus-quest"):SetPath("quest"):SetOrder(20), "RootTree")
   OptionBuilder:AddRecipe(ThemeDropDownRecipe("Select a theme", "BonusQuest/SelectThemeToEdit/Children"), "BonusQuest/Children")
   OptionBuilder:AddRecipe(TabRecipe("", "BonusQuest/Tabs"):SetOrder(1), "BonusQuest/SelectThemeToEdit/Children")
   OptionBuilder:AddRecipe(TabItemRecipe("General", "BonusQuest/General"):SetID("general"):SetOrder(1), "BonusQuest/Tabs")
   OptionBuilder:AddRecipe(TabItemRecipe("Header", "BonusQuest/Header"):SetID("header"):SetOrder(2), "BonusQuest/Tabs")
   OptionBuilder:AddRecipe(TabItemRecipe("Name", "BonusQuest/Name"):SetID("name"):SetOrder(3), "BonusQuest/Tabs")
   -- General
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("bonusQuest.frame", "quest.frame"):SetRefresher("bonusQuest/refresher"), "BonusQuest/General")
   -- Header
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("bonusQuest.header", "quest.header"):SetRefresher("bonusQuest/refresher"), "BonusQuest/Header")
   -- Name
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("bonusQuest.name", "quest.name"):SetRefresher("bonusQuest/refresher"):SetFlags(ThemeElementRecipe.ALL_TEXT_OPTIONS), "BonusQuest/Name")
end

function AddBonusObjectivesBlockRecipes(self)
  OptionBuilder:AddRecipe(TreeItemRecipe("Bonus Objectives", "BonusObjectives/Children"):SetID("block-bonusOjectives"):SetPath("blocks"):SetOrder(30), "RootTree")
  _Parent:CreateBlockRecipes("block.bonusObjectives", "BonusObjectives/Children")
end
