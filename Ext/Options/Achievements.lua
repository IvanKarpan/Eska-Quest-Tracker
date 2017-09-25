-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio            "EskaQuestTracker.Options.Achievements"                     ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
_Categories.Achievements = {
  type = "group",
  name = "Achievements",
  order = 3,
  childGroups = "tab",
  args = {

    hideCriteriaCompleted = {
      type = "toggle",
      name = "Hide completed criteria",
      order = 1,
      width = "full",
      get = function() return Options:Get("achievement-hide-criteria-completed") end,
      set = function(_, value) Options:Set("achievement-hide-criteria-completed", value) end
    },
    maxCriteriaDisplayed = {
      type = "range",
      name = "Max criteria displayed",
      order = 2,
      step = 1,
      softMax = 10,
      desc = "0: means no limit",
      get = function() return Options:Get("achievement-max-criteria-displayed") end,
      set = function(_, value) Options:Set("achievement-max-criteria-displayed", value) end
    },
    showDesc = {
      type = "toggle",
      name = "Show description",
      order = 3,
      width = "full",
      get = function() return Options:Get("achievement-show-description") end,
      set = function(_, value) Options:Set("achievement-show-description", value) end
    },
  }
}
