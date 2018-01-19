-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio           "EskaQuestTracker.Theme.Eska"                               ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
EskaTheme = Theme()
EskaTheme.name    = "Eska"
EskaTheme.author  = "Skamer"
EskaTheme.version = "1.6.6"
EskaTheme.stage   = "Release"
Themes:Register(EskaTheme)
-- ========================================================================== --
-- == Set Default properties
-- ========================================================================== --
EskaTheme:SetElementProperty("text-size", 10)
EskaTheme:SetElementProperty("text-offsetX", 0)
EskaTheme:SetElementProperty("text-offsetY", 0)
EskaTheme:SetElementProperty("text-location", "CENTER")
EskaTheme:SetElementProperty("background-color", { r = 0, g = 0, b = 0, a = 0})
-- ========================================================================== --
-- == Tracker properties
-- ========================================================================== --
EskaTheme:SetElementProperty("tracker.frame", "background-color", { r = 125/255, g = 125/255, b = 125/255, a = 0.25 })
EskaTheme:SetElementProperty("tracker.frame", "border-color", { r = 0.1, g = 0.1, b = 0.1})
  -- Scrollbar
  EskaTheme:SetElementProperty("tracker.scrollbar", "background-color", { r = 0, g = 0, b = 0, a = 0.5})
  EskaTheme:SetElementProperty("tracker.scrollbar", "border-color", { r = 0, g = 0, b = 0 })
  -- Scrollbar thumb
  EskaTheme:SetElementProperty("tracker.scrollbar.thumb", "texture-color", { r = 1, g = 199/255, b = 0, a = 1})
-- ========================================================================== --
-- == Set Default block properties
-- ========================================================================== --
-- EskaTheme:SetElementProperty("block.*", "background-color", { r = 0, g = 0, b = 0, a = 0})
EskaTheme:SetElementProperty("block.*", "border-color", { r = 0, g = 0, b = 0, a = 0 })
-- Header properties
EskaTheme:SetElementProperty("block.header", "background-color", { r = 0, g = 0, b = 0, a = 0.5 })
EskaTheme:SetElementProperty("block.header", "border-color", { r = 0, g = 0, b = 0, a = 1})
EskaTheme:SetElementProperty("block.header", "text-size", 14)
EskaTheme:SetElementProperty("block.header", "text-color", { r = 0, g = 199/255, b = 1})
EskaTheme:SetElementProperty("block.header", "text-font", "PT Sans Narrow Bold")
EskaTheme:SetElementProperty("block.header", "text-transform", "none")
EskaTheme:SetElementProperty("block.header", "text-location", "CENTER")
-- Stripe properties
EskaTheme:SetElementProperty("block.stripe", "texture-color", { r = 0, g = 0, b = 0, a = 0.5})
-- ========================================================================== --
-- == Blocks properties
-- ========================================================================== --
-- Dungeon & Keystone
EskaTheme:SetElementProperty("block.dungeon.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
EskaTheme:SetElementProperty("block.dungeon.header", "text-size", 14)
EskaTheme:SetElementProperty("block.dungeon.header", "text-offsetY", 17)
EskaTheme:SetElementProperty("block.dungeon.name", "text-size", 12)
EskaTheme:SetElementProperty("block.dungeon.name", "text-font", "PT Sans Caption Bold")
EskaTheme:SetElementProperty("block.dungeon.name", "text-offsetY", -13)
EskaTheme:SetElementProperty("block.dungeon.name", "text-color", { r = 1, g = 0.42, b = 0})
EskaTheme:SetElementProperty("block.dungeon.name", "text-transform", "uppercase")
EskaTheme:SetElementProperty("block.dungeon.icon", "border-color", { r = 0, g = 0, b = 0 })

EskaTheme:SetElementProperty("block.keystone.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
EskaTheme:SetElementProperty("block.keystone.header", "text-size", 14)
EskaTheme:SetElementProperty("block.keystone.header", "text-offsetY", 17)
EskaTheme:SetElementProperty("block.keystone.level", "text-font", "PT Sans Narrow Bold")
EskaTheme:SetElementProperty("block.keystone.level", "text-size", 14)
EskaTheme:SetElementProperty("block.keystone.level", "text-color", { r = 1, g = 215/255, b = 0 })

-- Scenario
EskaTheme:SetElementProperty("block.scenario.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})

-- Scenario
EskaTheme:SetElementProperty("block.scenario.header", "text-size", 14)
EskaTheme:SetElementProperty("block.scenario.header", "text-offsetY", 17)
EskaTheme:SetElementProperty("block.scenario.name", "text-size", 12)
EskaTheme:SetElementProperty("block.scenario.name", "text-font", "PT Sans Caption Bold")
EskaTheme:SetElementProperty("block.scenario.name", "text-offsetY", -13)
EskaTheme:SetElementProperty("block.scenario.name", "text-color", { r = 1, g = 0.42, b = 0})
EskaTheme:SetElementProperty("block.scenario.name", "text-transform", "uppercase")

   -- Stage frame
   EskaTheme:SetElementProperty("block.scenario.stage", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
   EskaTheme:SetElementProperty("block.scenario.stage", "border-color", { r = 0, g = 0, b = 0, a = 0.4})
   -- Stage name
   EskaTheme:SetElementProperty("block.scenario.stageName", "text-size", 11)
   EskaTheme:SetElementProperty("block.scenario.stageName", "text-color", { r = 1, g = 1, b = 0 })
   -- Stage counter
   EskaTheme:SetElementProperty("block.scenario.stageCounter", "text-size", 12)
   EskaTheme:SetElementProperty("block.scenario.stageCounter", "text-font", "PT Sans Narrow Bold")
   EskaTheme:SetElementProperty("block.scenario.stageCounter", "text-color", { r = 1, g = 1, b = 1 })
-- ========================================================================== --
-- == Quest properties
-- ========================================================================== --
EskaTheme:SetElementProperty("quest.*", "text-font", "DejaVuSansCondensed Bold")
EskaTheme:SetElementProperty("quest.*", "text-size", 10)
EskaTheme:SetElementProperty("quest.*", "text-transform", "none")
EskaTheme:SetElementProperty("quest.*", "text-color", { r = 1.0, g = 191/255, b = 0})
EskaTheme:SetElementProperty("quest.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
EskaTheme:SetElementProperty("quest.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
EskaTheme:SetElementProperty("quest.header[hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
-- ========================================================================== --
-- == World Quest properties
-- ========================================================================== --
EskaTheme:SetElementProperty("worldQuest.frame[tracked]", "background-color", { r = 0.22, g = 0, b = 0, a = 0.58})

-- ========================================================================== --
-- == Bonus Quest properties
-- ========================================================================== --
EskaTheme:SetElementProperty("bonusQuest.*", "text-font", "DejaVuSansCondensed Bold")
EskaTheme:SetElementProperty("bonusQuest.*", "text-size", 10)
EskaTheme:SetElementProperty("bonusQuest.*", "text-transform", "none")
EskaTheme:SetElementProperty("bonusQuest.*", "text-color", { r = 1.0, g = 106/255, b = 0})
EskaTheme:SetElementProperty("bonusQuest.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
EskaTheme:SetElementProperty("bonusQuest.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
EskaTheme:SetElementProperty("bonusQuest.header[hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
-- ========================================================================== --
-- == Objective properties
-- ========================================================================== --
EskaTheme:SetElementProperty("objective.*", "border-color", { r = 0, g = 0, b = 0, a = 0})
EskaTheme:SetElementProperty("objective.*", "text-size", 13)
EskaTheme:SetElementProperty("objective.*", "text-font", "PT Sans Narrow Bold")
EskaTheme:SetElementProperty("objective.*", "text-transform", "none")
EskaTheme:SetElementProperty("objective.*", "text-location", "LEFT")
EskaTheme:SetElementProperty("objective.*", "text-offsetX", 5)
  -- completed color
  EskaTheme:SetElementProperty("objective.frame[completed]", "text-color", { r = 0, g = 1, b = 0})
  EskaTheme:SetElementProperty("objective.square[completed]", "background-color", { r = 0, g = 1, b = 0})
  -- in progress color
  EskaTheme:SetElementProperty("objective.frame[progress]", "text-color", { r = 148/255, g = 148/255, b = 148/255 })
  EskaTheme:SetElementProperty("objective.square[progress]", "background-color", { r = 148/255, g = 148/255, b = 148/255 })
  -- faied color
  EskaTheme:SetElementProperty("objective.frame[failed]", "text-color", { r = 1, g = 0, b = 0 })
  EskaTheme:SetElementProperty("objective.square[failed]", "background-color", { r = 1, g = 0, b = 0 })
-- ========================================================================== --
-- == Quest header properties
-- ========================================================================== --
EskaTheme:SetElementProperty("questHeader.name", "text-size", 12)
EskaTheme:SetElementProperty("questHeader.name", "text-font", "PT Sans Narrow Bold")
EskaTheme:SetElementProperty("questHeader.name", "text-color", { r = 1, g = 0.38, b = 0 })
EskaTheme:SetElementProperty("questHeader.name", "text-transform", "uppercase")
EskaTheme:SetElementProperty("questHeader.name", "text-offsetX", 10)
-- ========================================================================== --
-- == Achievement properties
-- ========================================================================== --
EskaTheme:SetElementProperty("achievement.*", "text-font", "DejaVuSansCondensed Bold")
EskaTheme:SetElementProperty("achievement.*", "text-size", 10)
EskaTheme:SetElementProperty("achievement.*", "text-transform", "none")
EskaTheme:SetElementProperty("achievement.*", "text-color", { r = 1.0, g = 191/255, b = 0})
EskaTheme:SetElementProperty("achievement.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
EskaTheme:SetElementProperty("achievement.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
EskaTheme:SetElementProperty("achievement.header[hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
EskaTheme:SetElementProperty("achievement.icon", "background-color", { r = 0, g = 0, b = 0})
EskaTheme:SetElementProperty("achievement.description", "text-size", 11)
EskaTheme:SetElementProperty("achievement.description", "text-font", "PT Sans Bold")
EskaTheme:SetElementProperty("achievement.description", "text-color", { r = 1, g = 1, b = 1, a = 1 })
EskaTheme:SetElementProperty("achievement.description", "text-location", "LEFT")
-- change the description color when failed
EskaTheme:SetElementProperty("achievement.description[failed]", "text-color", { r = 1, g = 0, b = 0, a = 1})
