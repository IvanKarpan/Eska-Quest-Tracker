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
        showQuestID = {
          type = "toggle",
          name = "Show quest id",
          order = 1,
          get = function() return Quest.showID end,
          set = function(_, value) Quest.showID = value end,
        },
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
        }
      }
    },
    fonts = {
      type = "group",
      name = "Fonts",
      order = 2,
      args = {
        name = {
          type = "group",
          name = "Name",
          inline = true,
          order = 1,
          args = _OptionBuilder:CreateTextOptions(Quest, "name")
        },
        level = {
          type = "group",
          name = "Level",
          inline = true,
          order = 2,
          args = _OptionBuilder:CreateTextOptions(Quest, "level")
        },
        header = {
          type = "group",
          name = "Header",
          inline = true,
          order = 3,
          args = _OptionBuilder:CreateTextOptions(QuestHeader)
        }
      }
    }
  }
}

-- _OptionBuilder:CreateBlockOptions(QuestBlock, "Quests")
--[[
_CustomBlockConfigurations["Quests"] = {
  type = "group",
  name = "Quests",
  childGroups = "tab",
  args = {
    enableCustomConfig = {
      type = "toggle",
      name = "Enable custom config",
      order = 1,
    },
    headerBackground = {
      type = "group",
      name = "Header background",
      order = 2,
      args = {
        enable = {
          type = "toggle",
          name = "Enable custom background",
          width = "full",
          order = 1,
        }
      }
    },
    headerText = {
      type = "group",
      name = "Header text",
      order = 3,
      args = {
        enable = {
          type = "toggle",
          name = "Enable custom text",
          order = 2,
        }
      }
    }
  }
}
--]]
--[[_CustomBlockConfigurations["Quests"] = {
  type = "group",
  name = "Quests 1",
  order = 1,
  args = {
    enableCustomConfig = {
      type = "toggle",
      name = "Enable custom config",
      order = 1,
    },
    customConfig = {
      type = "group",
      name = "",
      inline = true,
      order = 2,
      args = {
        customColor = {
          type = "toggle",
          name = "CUSTOM color",
        }
      }
    }
  }
}--]]
