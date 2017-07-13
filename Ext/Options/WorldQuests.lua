-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio            "EskaQuestTracker.Options.WorldQuests"                "1.0.0"
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
--[[_Categories.WorldQuests = {
  type = "group",
  name = "World Quests",
  order = 6,
  childGroups = "tab",
  args = {

  }
}--]]
_OptionBuilder:CreateBlockOptions(WorldQuestBlock, "World Quests")
