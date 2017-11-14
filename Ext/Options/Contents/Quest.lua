-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                "EskaQuestTracker.Options.Quests"                      ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --

function OnLoad(self)
  self:AddQuestRecipes()
  self:AddQuestsBlockRecipes()
end

function AddQuestRecipes(self)
  -- Quests
  OptionBuilder:AddRecipe(TreeItemRecipe("Quest", "Quest/Children"):SetID("quest"):SetOrder(30), "RootTree")
   OptionBuilder:AddRecipe(ThemeDropDownRecipe("Select a theme", "Quest/SelectThemeToEdit/Children"), "Quest/Children")
   OptionBuilder:AddRecipe(TabRecipe("", "Quest/Tabs"):SetOrder(1), "Quest/SelectThemeToEdit/Children")
   OptionBuilder:AddRecipe(TabItemRecipe("General", "Quest/General"):SetID("general"):SetOrder(1), "Quest/Tabs")
   OptionBuilder:AddRecipe(TabItemRecipe("Header", "Quest/Header"):SetID("header"):SetOrder(2), "Quest/Tabs")
   OptionBuilder:AddRecipe(TabItemRecipe("Name", "Quest/Name"):SetID("name"):SetOrder(3), "Quest/Tabs")
   OptionBuilder:AddRecipe(TabItemRecipe("Level", "Quest/Level"):SetID("level"):SetOrder(4), "Quest/Tabs")
   OptionBuilder:AddRecipe(TabItemRecipe("Category", "Quest/Category"):SetID("category"):SetOrder(5), "Quest/Tabs")
   -- General
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("quest.frame"):SetRefresher("quest/refresher"), "Quest/General")
   -- Header
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("quest.header"):SetRefresher("quest/refresher"), "Quest/Header")
   -- Name
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("quest.name"):SetRefresher("quest/refresher"):SetFlags(ThemeElementRecipe.ALL_TEXT_OPTIONS), "Quest/Name")
   -- Level
   OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Show"):BindOption("quest-show-level", false), "Quest/Level")
   OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Use difficulty color"):BindOption("quest-color-level-by-difficulty", false), "Quest/Level")
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("quest.level"):SetRefresher("quest/refresher"):SetFlags(ThemeElementRecipe.ALL_TEXT_OPTIONS), "Quest/Level")
   -- Category
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("questHeader.frame"), "Quest/Category")
   OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("questHeader.name"):SetFlags(ThemeElementRecipe.ALL_TEXT_OPTIONS), "Quest/Category")
end


function AddQuestsBlockRecipes(self)
  OptionBuilder:AddRecipe(TreeItemRecipe("Quests", "Quests/Children"):SetID("block-quests"):SetPath("blocks"):SetOrder(10), "RootTree")
  _Parent:CreateBlockRecipes("block.quests", "Quests/Children")

  OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Show only the quests in the current zone"):SetWidth(1.0):BindOption("show-only-quests-in-zone"):SetOrder(5), "Quests/General")
  OptionBuilder:AddRecipe(CheckBoxRecipe():SetText("Sort the quests by distance"):SetWidth(1.0):BindOption("sort-quests-by-distance"):SetOrder(6), "Quests/General")

end
