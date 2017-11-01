-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio          "EskaQuestTracker.Theme.Transparence"                        ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
TransparenceTheme = Theme()
TransparenceTheme.name     = "Transparence"
TransparenceTheme.author   = "Skamer"
TransparenceTheme.version  = "1.5.0"
TransparenceTheme.stage    = "Release"
Themes:Register(TransparenceTheme)
-- ========================================================================== --
-- == Set Default properties
-- ========================================================================== --
TransparenceTheme:SetElementProperty("text-size", 10)
TransparenceTheme:SetElementProperty("text-offsetX", 0)
TransparenceTheme:SetElementProperty("text-offsetY", 0)
TransparenceTheme:SetElementProperty("text-location", "CENTER")
TransparenceTheme:SetElementProperty("background-color", { r = 0, g = 0, b = 0, a = 0})
TransparenceTheme:SetElementProperty("border-color", { r = 0, g = 0, b = 0, a = 0})
-- ========================================================================== --
-- == Tracker properties
-- ========================================================================== --
  --TransparenceTheme:SetElementProperty("tracker", "background-color", { r = 0, g = 0, b = 0, a = 0.15})
  -- Scrollbar thumb
  TransparenceTheme:SetElementProperty("tracker.scrollbar.thumb", "vertex-color", { r = 1, g = 199/255, b = 0, a = 0})
-- ========================================================================== --
-- == Set Default block properties
-- ========================================================================== --
TransparenceTheme:SetElementProperty("block.header", "text-size", 14)
TransparenceTheme:SetElementProperty("block.header", "text-font", "PT Sans Narrow Bold")
TransparenceTheme:SetElementProperty("block.header", "background-color", { r = 0.11, g = 0.09, b = 0.11, a = 0.61})
TransparenceTheme:SetElementProperty("block.header", "border-color", { r = 0, g = 0, b = 0, a = 0.15})
TransparenceTheme:SetElementProperty("block.header", "text-color", { r = 0.18, g = 0.71, b = 1 })
TransparenceTheme:SetElementProperty("block.header", "text-location", "CENTER")
TransparenceTheme:SetElementProperty("block.header", "text-transform", "none")
-- Stripe properties
TransparenceTheme:SetElementProperty("block.stripe", "vertex-color", { r = 0, g = 0, b = 0, a = 0})
-- ========================================================================== --
-- == Blocks properties
-- ========================================================================== --
-- Dungeon
TransparenceTheme:SetElementProperty("block.dungeon", "background-color", { r = 0.2, g = 0.2, b = 0.2, a = 0.17})
TransparenceTheme:SetElementProperty("block.dungeon.header", "background-color", { r = 0, g = 0, b = 0, a = 0.5})
TransparenceTheme:SetElementProperty("block.dungeon.header", "text-size", 14)
TransparenceTheme:SetElementProperty("block.dungeon.header", "text-offsetY", 17)
TransparenceTheme:SetElementProperty("block.dungeon.name", "text-size", 12)
TransparenceTheme:SetElementProperty("block.dungeon.name", "text-font", "PT Sans Caption Bold")
TransparenceTheme:SetElementProperty("block.dungeon.name", "text-offsetY", -13)
TransparenceTheme:SetElementProperty("block.dungeon.name", "text-color", { r = 1, g = 0.42, b = 0})
TransparenceTheme:SetElementProperty("block.dungeon.name", "text-transform", "uppercase")
-- Keystone
TransparenceTheme:SetElementProperty("block.keystone", "background-color", { r = 0.2, g = 0.2, b = 0.2, a = 0.17})
TransparenceTheme:SetElementProperty("block.keystone.header", "background-color", { r = 0, g = 0, b = 0, a = 0.5})
TransparenceTheme:SetElementProperty("block.keystone.header", "text-size", 14)
TransparenceTheme:SetElementProperty("block.keystone.header", "text-offsetY", 17)
TransparenceTheme:SetElementProperty("block.keystone.name", "text-size", 12)
TransparenceTheme:SetElementProperty("block.keystone.name", "text-font", "PT Sans Caption Bold")
TransparenceTheme:SetElementProperty("block.keystone.name", "text-offsetY", -13)
TransparenceTheme:SetElementProperty("block.keystone.name", "text-color", { r = 1, g = 0.42, b = 0})
TransparenceTheme:SetElementProperty("block.keystone.name", "text-transform", "uppercase")
TransparenceTheme:SetElementProperty("block.keystone.icon", "border-color", { r = 0, g = 0, b = 0})
TransparenceTheme:SetElementProperty("block.keystone.level", "text-font", "PT Sans Narrow Bold")
TransparenceTheme:SetElementProperty("block.keystone.level", "text-size", 14)
TransparenceTheme:SetElementProperty("block.keystone.level", "text-color", { r = 1, g = 215/255, b = 0 })
-- Scenario
TransparenceTheme:SetElementProperty("block.scenario", "background-color", { r = 0.2, g = 0.2, b = 0.2, a = 0.17})
TransparenceTheme:SetElementProperty("block.scenario.header", "text-offsetY", 17)
TransparenceTheme:SetElementProperty("block.scenario.name", "text-size", 12)
TransparenceTheme:SetElementProperty("block.scenario.name", "text-font", "PT Sans Caption Bold")
TransparenceTheme:SetElementProperty("block.scenario.name", "text-offsetY", -13)
TransparenceTheme:SetElementProperty("block.scenario.name", "text-color", { r = 1, g = 0.42, b = 0})
TransparenceTheme:SetElementProperty("block.scenario.name", "text-transform", "uppercase")
  -- Stage frame
  TransparenceTheme:SetElementProperty("block.scenario.stage", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
  TransparenceTheme:SetElementProperty("block.scenario.stage", "border-color", { r = 0, g = 0, b = 0, a = 0.4})
  -- Stage name
  TransparenceTheme:SetElementProperty("block.scenario.stageName", "text-size", 11)
  TransparenceTheme:SetElementProperty("block.scenario.stageName", "text-color", { r = 1, g = 1, b = 0 })
  -- Stage counter
  TransparenceTheme:SetElementProperty("block.scenario.stageCounter", "text-size", 12)
  TransparenceTheme:SetElementProperty("block.scenario.stageCounter", "text-font", "PT Sans Narrow Bold")
  TransparenceTheme:SetElementProperty("block.scenario.stageCounter", "text-color", { r = 1, g = 1, b = 1 })
-- ========================================================================== --
-- == Quest properties
-- ========================================================================== --
TransparenceTheme:SetElementProperty("quest.*", "text-font", "DejaVuSansCondensed Bold")
TransparenceTheme:SetElementProperty("quest.*", "text-size", 10)
TransparenceTheme:SetElementProperty("quest.*", "text-transform", "none")
TransparenceTheme:SetElementProperty("quest.*", "text-color", { r = 1.0, g = 191/255, b = 0})
TransparenceTheme:SetElementProperty("quest.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
TransparenceTheme:SetElementProperty("quest.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
TransparenceTheme:SetElementProperty("quest.header[hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
-- ========================================================================== --
-- == World Quest properties
-- ========================================================================== --
TransparenceTheme:SetElementProperty("worldQuest.*", "text-font", "DejaVuSansCondensed Bold")
TransparenceTheme:SetElementProperty("worldQuest.*", "text-size", 10)
TransparenceTheme:SetElementProperty("worldQuest.*", "text-transform", "none")
TransparenceTheme:SetElementProperty("worldQuest.*", "text-color", { r = 1.0, g = 191/255, b = 0})
TransparenceTheme:SetElementProperty("worldQuest.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
TransparenceTheme:SetElementProperty("worldQuest.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
TransparenceTheme:SetElementProperty("worldQuest.header[hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
-- ========================================================================== --
-- == Bonus Quest properties
-- ========================================================================== --
TransparenceTheme:SetElementProperty("bonusQuest.*", "text-font", "DejaVuSansCondensed Bold")
TransparenceTheme:SetElementProperty("bonusQuest.*", "text-size", 10)
TransparenceTheme:SetElementProperty("bonusQuest.*", "text-transform", "none")
-- TransparenceTheme:SetElementProperty("bonusQuest.*", "text-color", { r = 1.0, g = 191/255, b = 0})
TransparenceTheme:SetElementProperty("bonusQuest.*", "text-color", { r = 1.0, g = 106/255, b = 0})
TransparenceTheme:SetElementProperty("bonusQuest.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
TransparenceTheme:SetElementProperty("bonusQuest.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
TransparenceTheme:SetElementProperty("bonusQuest.header[hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
-- ========================================================================== --
-- == Objective properties
-- ========================================================================== --
TransparenceTheme:SetElementProperty("objective.*", "border-color", { r = 0, g = 0, b = 0, a = 0})
TransparenceTheme:SetElementProperty("objective.*", "text-size", 13)
TransparenceTheme:SetElementProperty("objective.*", "text-font", "PT Sans Narrow Bold")
TransparenceTheme:SetElementProperty("objective.*", "text-transform", "none")
TransparenceTheme:SetElementProperty("objective.*", "text-location", "LEFT")
TransparenceTheme:SetElementProperty("objective.*", "text-offsetX", 5)
  -- completed color
  TransparenceTheme:SetElementProperty("objective.frame[completed]", "text-color", { r = 0, g = 1, b = 0})
  TransparenceTheme:SetElementProperty("objective.square[completed]", "background-color", { r = 0, g = 1, b = 0})
  -- in progress color
  TransparenceTheme:SetElementProperty("objective.frame[progress]", "text-color", { r = 148/255, g = 148/255, b = 148/255 })
  TransparenceTheme:SetElementProperty("objective.square[progress]", "background-color", { r = 148/255, g = 148/255, b = 148/255 })
-- ========================================================================== --
-- == Quest header properties
-- ========================================================================== --
TransparenceTheme:SetElementProperty("questHeader.name", "text-size", 12)
TransparenceTheme:SetElementProperty("questHeader.name", "text-font", "PT Sans Narrow Bold")
TransparenceTheme:SetElementProperty("questHeader.name", "text-color", { r = 1, g = 0.38, b = 0 })
TransparenceTheme:SetElementProperty("questHeader.name", "text-transform", "uppercase")
TransparenceTheme:SetElementProperty("questHeader.name", "text-offsetX", 10)
-- ========================================================================== --
-- == Achievement properties
-- ========================================================================== --
TransparenceTheme:SetElementProperty("achievement.*", "text-font", "DejaVuSansCondensed Bold")
TransparenceTheme:SetElementProperty("achievement.*", "text-size", 10)
TransparenceTheme:SetElementProperty("achievement.*", "text-transform", "none")
TransparenceTheme:SetElementProperty("achievement.*", "text-color", { r = 1.0, g = 191/255, b = 0})
TransparenceTheme:SetElementProperty("achievement.frame", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
TransparenceTheme:SetElementProperty("achievement.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
TransparenceTheme:SetElementProperty("achievement.header[hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
TransparenceTheme:SetElementProperty("achievement.icon", "background-color", { r = 1, g = 233/255, b = 127/255})
