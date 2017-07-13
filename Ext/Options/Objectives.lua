-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio            "EskaQuestTracker.Options.Objectives"                      ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
_Categories.Objectives = {
  type = "group",
  name = "Objectives",
  order = 3,
  childGroups = "tab",
  args = {
    color = {
      type = "group",
      name = "Colors",
      inline = true,
      order = 1,
      args = {
        completed = {
          type = "color",
          name = "Completed",
          get = function()
            local color = Objective.fontColorCompleted
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b, a)
            Objective.fontColorCompleted = {
              r = r, g = g, b = b
            }
          end
        },
        inProgress = {
          type = "color",
          name = "In progress",
          get = function()
            local color = Objective.fontColorInProgress
            return color.r, color.g, color.b
          end,
          set = function(_, r, g, b, a)
            Objective.fontColorInProgress = {
              r = r, g = g, b = b,
            }
          end,
        }
      }
    },
    textProperties = {
      type = "group",
      name = "Font properties",
      inline = true,
      order = 2,
      args = _OptionBuilder:CreateTextOptions(Objective, nil, 11),
    }
  }
}
