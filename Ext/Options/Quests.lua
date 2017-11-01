-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                "EskaQuestTracker.Options.Quests"                      ""
-- ========================================================================== --
namespace "EQT"

function BuildQuestsCategory(content)
  -- [OPTION] Show quest level
  local showQuestLevel = _AceGUI:Create("CheckBox")
  showQuestLevel:SetLabel("Show quest level")
  showQuestLevel:SetValue(Options:Get("quest-show-level"))
  showQuestLevel:SetCallback("OnValueChanged", function(_, _, show) Options:Set("quest-show-level", show) end)
  content:AddChild(showQuestLevel)

  -- [OPTION] Color quest level by difficulty
  local colorQuestLevelByDifficulty = _AceGUI:Create("CheckBox")
  colorQuestLevelByDifficulty:SetLabel("Use difficulty color for quest level")
  colorQuestLevelByDifficulty:SetValue(Options:Get("quest-color-level-by-difficulty"))
  colorQuestLevelByDifficulty:SetCallback("OnValueChanged", function(_, _, colorByDifficulty) Options:Set("quest-color-level-by-difficulty", colorByDifficulty) end)
  colorQuestLevelByDifficulty:SetRelativeWidth(1.0)
  content:AddChild(colorQuestLevelByDifficulty)

  -- [OPTION] Show only quests in the current zone
  local showOnlyQuestsInZone = _AceGUI:Create("CheckBox")
  showOnlyQuestsInZone:SetLabel("Show only the quests in the current zone")
  showOnlyQuestsInZone:SetValue(QuestBlock.showOnlyQuestsInZone)
  showOnlyQuestsInZone:SetCallback("OnValueChanged", function(_, _, filteringByZone) QuestBlock.showOnlyQuestsInZone = filteringByZone end)
  showOnlyQuestsInZone:SetRelativeWidth(1.0)
  content:AddChild(showOnlyQuestsInZone)

  -- [OPTION] Color quest level by difficulty
  local sortQuestsByDistance = _AceGUI:Create("CheckBox")
  sortQuestsByDistance:SetLabel("Sort the quests by distance")
  sortQuestsByDistance:SetValue(Options:Get("sort-quests-by-distance"))
  sortQuestsByDistance:SetCallback("OnValueChanged", function(_, _, sortByDistance)  Options:Set("sort-quests-by-distance", sortByDistance) end)
  sortQuestsByDistance:SetRelativeWidth(1.0)
  content:AddChild(sortQuestsByDistance)
end

function OnLoad(self)
  self:RegisterCategory("Quests", "Quests", 20, BuildQuestsCategory)
end

--[[
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
          order = 20,
          get = function() return Options:Get("quest-show-level") end,
          set = function(_, value) Options:Set("quest-show-level", value) end,
        },
        colorQuestLevelByDifficulty = {
          type = "toggle",
          order = 21,
          width = "full",
          name = "Use difficulty color for quest level",
          get = function() return Options:Get("quest-color-level-by-difficulty") end,
          set = function(_, value) Options:Set("quest-color-level-by-difficulty", value) end,
        },
        showOnlyQuestsInZone = {
          type = "toggle",
          name = "Show only the quests in the current zone",
          order = 30,
          width = "full",
          get = function() return QuestBlock.showOnlyQuestsInZone end,
          set = function(_, filteringByZone) QuestBlock.showOnlyQuestsInZone = filteringByZone end,
        },
        sortQuestsByDistance = {
          type = "toggle",
          name = "Sort the quests by distance",
          order = 40,
          width = "full",
          get = function() return Options:Get("sort-quests-by-distance") end,
          set = function(_, value) Options:Set("sort-quests-by-distance", value) end,
        }
      }
    }
  }
}
--]]
