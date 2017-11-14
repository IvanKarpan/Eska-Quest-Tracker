-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                "EskaQuestTracker.Options.Dungeon"                     ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
function OnLoad(self)
  self:AddDungeonBlockRecipes()
end

function AddDungeonBlockRecipes(self)
  OptionBuilder:AddRecipe(TreeItemRecipe("Dungeon", "Dungeon/Children"):SetPath("blocks"):SetID("block-dungeon"):SetOrder(60), "RootTree")
  self:CreateBlockRecipes("block.dungeon", "Dungeon/Children")

  -- Dungeon Name
  OptionBuilder:AddRecipe(TabItemRecipe("Name", "Dungeon/Name"):SetID("name"):SetOrder(4), "Dungeon/Tabs")
  OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("block.dungeon.name"):SetRefresher("dungeon/refresher"):SetFlags(ThemeElementRecipe.ALL_TEXT_OPTIONS), "Dungeon/Name")
  -- Dungeon Icon
  OptionBuilder:AddRecipe(TabItemRecipe("Icon", "Dungeon/Icon"):SetID("icon"):SetOrder(4), "Dungeon/Tabs")
  OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("block.dungeon.icon"):SetRefresher("dungeon/refresher"):SetFlags(ThemeElementRecipe.ALL_FRAME_OPTIONS + ThemeElementRecipe.ALL_TEXTURE_OPTIONS), "Dungeon/Icon")
end
