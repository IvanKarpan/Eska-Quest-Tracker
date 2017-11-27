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
  OptionBuilder:AddRecipe(TreeItemRecipe("World Quest", "WorldQuest/Children"):SetID("world-quest"):SetPath("quest"):SetOrder(10), "RootTree")
   OptionBuilder:AddRecipe(ThemeDropDownRecipe("Select a theme", "WorldQuest/SelectThemeToEdit/Children"), "WorldQuest/Children")
   OptionBuilder:AddRecipe(TabRecipe("", "WorldQuest/Tabs"):SetOrder(1), "WorldQuest/SelectThemeToEdit/Children")
   OptionBuilder:AddRecipe(TabItemRecipe("General", "WorldQuest/General"):SetID("general"):SetOrder(1), "WorldQuest/Tabs")
   OptionBuilder:AddRecipe(TabItemRecipe("Header", "WorldQuest/Header"):SetID("header"):SetOrder(2), "WorldQuest/Tabs")
   OptionBuilder:AddRecipe(TabItemRecipe("Name", "WorldQuest/Name"):SetID("name"):SetOrder(3), "WorldQuest/Tabs")
   -- General
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("worldQuest.frame", "quest.frame"):SetRefresher("worldQuest/refresher"), "WorldQuest/General")
   -- Header
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("worldQuest.header", "quest.header"):SetRefresher("worldQuest/refresher"), "WorldQuest/Header")
   -- Name
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("worldQuest.name", "quest.name"):SetRefresher("worldQuest/refresher"):SetFlags(ThemeElementRecipe.ALL_TEXT_OPTIONS), "WorldQuest/Name")
end


function AddWorldQuestsBLockRecipes(self)
  OptionBuilder:AddRecipe(TreeItemRecipe("World Quests", "WorldQuests/Children"):SetID("block-worldQuests"):SetOrder(20):SetPath("blocks"), "RootTree")
  OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Show tracked world quests"):BindOption("show-tracked-world-quests", false):SetOrder(5), "WorldQuests/General")
  _Parent:CreateBlockRecipes("block.worldQuests", "WorldQuests/Children")
end
