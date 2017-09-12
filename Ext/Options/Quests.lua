-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                "EskaQuestTracker.Options.Quests"                      ""
-- ========================================================================== --
namespace "EQT"

_Categories.Quests = {
  type = "group",
  name = "Quests",
  order = 2,
  childGroups = "tab",
  args = {
    general = {
      type = "group",
      name = "General",
      order = 1,
      args = {
        showQuestLevel = {
          type = "toggle",
          name = "Show quest level",
          order = 2,
          get = function() return Quest.showLevel end,
          set = function(_, value) Quest.showLevel = value end,
        },
        showOnlyQuestsInZone = {
          type = "toggle",
          name = "Show only the quests in the current zone",
          order = 3,
          width = "full",
          get = function() return QuestBlock.showOnlyQuestsInZone end,
          set = function(_, filteringByZone) QuestBlock.showOnlyQuestsInZone = filteringByZone end,
        },
        sortQuestsByDistance = {
          type = "toggle",
          name = "Sort the quests by distance",
          order = 4,
          width = "full",
          get = function() return Options:Get("sort-quests-by-distance") end,
          set = function(_, value) Options:Set("sort-quests-by-distance", value) end,
        }
      }
    }
  }
}
