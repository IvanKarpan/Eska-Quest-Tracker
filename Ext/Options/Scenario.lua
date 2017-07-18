-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio              "EskaQuestTracker.Options.Scenario"                      ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
_Parent.Category.Scenario = {
  type = "group",
  name = "Scenario",
  order = 3,
  childGroups = "tab",
  args = {
    header = {
      type = "group",
      name = "Header",
      order = 2,
      args = _OptionBuilder:CreateTextOptions(Scenario, "name")
    },
    stage = {
      type = "group",
      name = "Stage",
      args = {
        name = {
          type = "group",
          name = "Name",
          inline = true,
          order = 1,
          args = _OptionBuilder:CreateTextOptions(Scenario, "stageName")
        },
        counter = {
            type = "group",
            name = "Counter",
            inline = true,
            order = 2,
            args = _OptionBuilder:CreateTextOptions(Scenario, "stageCounter")
        }
      }
    }
  }
}

-- Class:GetDBValue("backdropColor")
-- Class:IsCustomProperty()
-- Class:SetEnableCustom
--Class:GetCustomDBProperty()
-- Class:IsCustomDBPropertyEnabled()
-- class:SetCustomDBPropertyEnabled()

-- _OptionBuilder:CreateBlockOptions(Scenario, "Scenario")
