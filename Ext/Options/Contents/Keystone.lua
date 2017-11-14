-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                "EskaQuestTracker.Options.Keystone"                     ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
function OnLoad(self)
  self:AddKeystoneBlockRecipes()
end

function AddKeystoneBlockRecipes(self)
  OptionBuilder:AddRecipe(TreeItemRecipe("Keystone", "Keystone/Children"):SetPath("blocks"):SetID("block-keystone"):SetOrder(70), "RootTree")
  self:CreateBlockRecipes("block.keystone", "Keystone/Children")

  -- Dungeon Name
  OptionBuilder:AddRecipe(TabItemRecipe("Name", "Dungeon/Name"):SetID("name"):SetOrder(4), "Keystone/Tabs")
  OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("block.keystone.name", "block.dungeon.name"):SetRefresher("keystone/refresher"):SetFlags(ThemeElementRecipe.ALL_TEXT_OPTIONS), "Keystone/Name")
  -- Dungeon Icon
  OptionBuilder:AddRecipe(TabItemRecipe("Icon", "Dungeon/Icon"):SetID("icon"):SetOrder(5), "Keystone/Tabs")
  OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("block.keystone.icon", "block.dungeon.icon"):SetRefresher("keystone/refresher"):SetFlags(ThemeElementRecipe.ALL_FRAME_OPTIONS + ThemeElementRecipe.ALL_TEXTURE_OPTIONS), "Keystone/Icon")
  -- Keystone Level
  OptionBuilder:AddRecipe(TabItemRecipe("Level", "Keystone/Level"):SetID("level"):SetOrder(6), "Keystone/Tabs")
  OptionBuilder:AddRecipe(ThemeElementRecipe():BindElement("block.keystone.level"):SetRefresher("keystone/refresher"):SetFlags(ThemeElementRecipe.ALL_TEXT_OPTIONS), "Keystone/Level")
end
