-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                "EskaQuestTracker.Options.worldQuest"                  ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
function OnLoad(self)
  self:AddWorldQuestRecipes()
  self:AddWorldQuestsBLockRecipes()
end


function AddWorldQuestRecipes(self)
  -- Quests
  OptionBuilder:AddRecipe(TreeItemRecipe("World Quest", "worldQuest/Children"):SetID("world-quest"):SetPath("quest"):SetOrder(10), "RootTree")
   OptionBuilder:AddRecipe(ThemeDropDownRecipe("Select a theme", "worldQuest/SelectThemeToEdit/Children"), "worldQuest/Children")
   OptionBuilder:AddRecipe(TabRecipe("", "worldQuest/Tabs"):SetOrder(1), "worldQuest/SelectThemeToEdit/Children")
   OptionBuilder:AddRecipe(TabItemRecipe("General", "worldQuest/General"):SetID("general"):SetOrder(1), "worldQuest/Tabs")
   OptionBuilder:AddRecipe(TabItemRecipe("Header", "worldQuest/Header"):SetID("header"):SetOrder(2), "worldQuest/Tabs")
   OptionBuilder:AddRecipe(TabItemRecipe("Name", "worldQuest/Name"):SetID("name"):SetOrder(3), "worldQuest/Tabs")
   -- General
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("worldQuest.frame", "quest.frame"):SetRefresher("worldQuest/refresher"), "worldQuest/General")
   -- Header
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("worldQuest.header", "quest.header"):SetRefresher("worldQuest/refresher"), "worldQuest/Header")
   -- Name
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("worldQuest.name", "quest.name"):SetRefresher("worldQuest/refresher"):SetFlags(ThemeElementRecipe.ALL_TEXT_OPTIONS), "worldQuest/Name")
end


function AddWorldQuestsBLockRecipes(self)
  OptionBuilder:AddRecipe(TreeItemRecipe("World Quests", "WorldQuests/Children"):SetID("block-worldQuests"):SetOrder(20):SetPath("blocks"), "RootTree")
  _Parent:CreateBlockRecipes("block.worldQuests", "WorldQuests/Children")
end
