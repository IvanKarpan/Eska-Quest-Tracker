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
TransparenceTheme.version  = "1.1.10"
TransparenceTheme.stage    = "Release"
_Addon:RegisterTheme(TransparenceTheme)
-- ========================================================================== --
-- == Set Default properties
-- ========================================================================== --
TransparenceTheme:SetProperty("text-size", 10)
TransparenceTheme:SetProperty("text-offsetX", 0)
TransparenceTheme:SetProperty("text-offsetY", 0)
TransparenceTheme:SetProperty("text-location", "CENTER")
TransparenceTheme:SetProperty("background-color", { r = 0, g = 0, b = 0, a = 0})
TransparenceTheme:SetProperty("border-color", { r = 0, g = 0, b = 0, a = 0})
-- ========================================================================== --
-- == Tracker properties
-- ========================================================================== --
  --TransparenceTheme:SetProperty("tracker", "background-color", { r = 0, g = 0, b = 0, a = 0.15})
  -- Scrollbar thumb
  TransparenceTheme:SetProperty("tracker.scrollbar.thumb", "vertex-color", { r = 1, g = 199/255, b = 0, a = 0})
-- ========================================================================== --
-- == Set Default block properties
-- ========================================================================== --
TransparenceTheme:SetProperty("block.header", "text-size", 14)
TransparenceTheme:SetProperty("block.header", "text-font", "PT Sans Narrow Bold")
TransparenceTheme:SetProperty("block.header", "background-color", { r = 0.11, g = 0.09, b = 0.11, a = 0.61})
TransparenceTheme:SetProperty("block.header", "border-color", { r = 0, g = 0, b = 0, a = 0.15})
TransparenceTheme:SetProperty("block.header", "text-color", { r = 0.18, g = 0.71, b = 1 })
TransparenceTheme:SetProperty("block.header", "text-location", "CENTER")
TransparenceTheme:SetProperty("block.header", "text-transform", "none")
-- Stripe properties
TransparenceTheme:SetProperty("block.stripe", "vertex-color", { r = 0, g = 0, b = 0, a = 0})
-- ========================================================================== --
-- == Blocks properties
-- ========================================================================== --
-- Dungeon
TransparenceTheme:SetProperty("block.dungeon", "background-color", { r = 0.2, g = 0.2, b = 0.2, a = 0.17})
TransparenceTheme:SetProperty("block.dungeon.header", "background-color", { r = 0, g = 0, b = 0, a = 0.5})
TransparenceTheme:SetProperty("block.dungeon.header", "text-size", 14)
TransparenceTheme:SetProperty("block.dungeon.header", "text-offsetY", 17)
TransparenceTheme:SetProperty("block.dungeon.name", "text-size", 12)
TransparenceTheme:SetProperty("block.dungeon.name", "text-font", "PT Sans Caption Bold")
TransparenceTheme:SetProperty("block.dungeon.name", "text-offsetY", -13)
TransparenceTheme:SetProperty("block.dungeon.name", "text-color", { r = 1, g = 0.42, b = 0})
TransparenceTheme:SetProperty("block.dungeon.name", "text-transform", "uppercase")
-- Keystone
TransparenceTheme:SetProperty("block.keystone", "background-color", { r = 0.2, g = 0.2, b = 0.2, a = 0.17})
TransparenceTheme:SetProperty("block.keystone.header", "background-color", { r = 0, g = 0, b = 0, a = 0.5})
TransparenceTheme:SetProperty("block.keystone.header", "text-size", 14)
TransparenceTheme:SetProperty("block.keystone.header", "text-offsetY", 17)
TransparenceTheme:SetProperty("block.keystone.name", "text-size", 12)
TransparenceTheme:SetProperty("block.keystone.name", "text-font", "PT Sans Caption Bold")
TransparenceTheme:SetProperty("block.keystone.name", "text-offsetY", -13)
TransparenceTheme:SetProperty("block.keystone.name", "text-color", { r = 1, g = 0.42, b = 0})
TransparenceTheme:SetProperty("block.keystone.name", "text-transform", "uppercase")
TransparenceTheme:SetProperty("block.keystone.icon", "border-color", { r = 0, g = 0, b = 0})
TransparenceTheme:SetProperty("block.keystone.level", "text-font", "PT Sans Narrow Bold")
TransparenceTheme:SetProperty("block.keystone.level", "text-size", 14)
TransparenceTheme:SetProperty("block.keystone.level", "text-color", { r = 1, g = 215/255, b = 0 })
-- Scenario
TransparenceTheme:SetProperty("block.scenario", "background-color", { r = 0.2, g = 0.2, b = 0.2, a = 0.17})
TransparenceTheme:SetProperty("block.scenario.header", "text-offsetY", 17)
TransparenceTheme:SetProperty("block.scenario.name", "text-size", 12)
TransparenceTheme:SetProperty("block.scenario.name", "text-font", "PT Sans Caption Bold")
TransparenceTheme:SetProperty("block.scenario.name", "text-offsetY", -13)
TransparenceTheme:SetProperty("block.scenario.name", "text-color", { r = 1, g = 0.42, b = 0})
TransparenceTheme:SetProperty("block.scenario.name", "text-transform", "uppercase")
  -- Stage frame
  TransparenceTheme:SetProperty("block.scenario.stage", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
  TransparenceTheme:SetProperty("block.scenario.stage", "border-color", { r = 0, g = 0, b = 0, a = 0.4})
  -- Stage name
  TransparenceTheme:SetProperty("block.scenario.stageName", "text-size", 11)
  TransparenceTheme:SetProperty("block.scenario.stageName", "text-color", { r = 1, g = 1, b = 0 })
  -- Stage counter
  TransparenceTheme:SetProperty("block.scenario.stageCounter", "text-size", 12)
  TransparenceTheme:SetProperty("block.scenario.stageCounter", "text-font", "PT Sans Narrow Bold")
  TransparenceTheme:SetProperty("block.scenario.stageCounter", "text-color", { r = 1, g = 1, b = 1 })
-- ========================================================================== --
-- == Quest properties
-- ========================================================================== --
TransparenceTheme:SetProperty("quest.*", "text-font", "DejaVuSansCondensed Bold")
TransparenceTheme:SetProperty("quest.*", "text-size", 10)
TransparenceTheme:SetProperty("quest.*", "text-transform", "none")
TransparenceTheme:SetProperty("quest.*", "text-color", { r = 1.0, g = 191/255, b = 0})
TransparenceTheme:SetProperty("quest", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
TransparenceTheme:SetProperty("quest.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
TransparenceTheme:SetProperty("quest.header[@hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
-- ========================================================================== --
-- == World Quest properties
-- ========================================================================== --
TransparenceTheme:SetProperty("worldQuest.*", "text-font", "DejaVuSansCondensed Bold")
TransparenceTheme:SetProperty("worldQuest.*", "text-size", 10)
TransparenceTheme:SetProperty("worldQuest.*", "text-transform", "none")
TransparenceTheme:SetProperty("worldQuest.*", "text-color", { r = 1.0, g = 191/255, b = 0})
TransparenceTheme:SetProperty("worldQuest", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
TransparenceTheme:SetProperty("worldQuest.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
TransparenceTheme:SetProperty("worldQuest.header[@hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
-- ========================================================================== --
-- == Bonus Quest properties
-- ========================================================================== --
TransparenceTheme:SetProperty("bonusQuest.*", "text-font", "DejaVuSansCondensed Bold")
TransparenceTheme:SetProperty("bonusQuest.*", "text-size", 10)
TransparenceTheme:SetProperty("bonusQuest.*", "text-transform", "none")
-- TransparenceTheme:SetProperty("bonusQuest.*", "text-color", { r = 1.0, g = 191/255, b = 0})
TransparenceTheme:SetProperty("bonusQuest.*", "text-color", { r = 1.0, g = 106/255, b = 0})
TransparenceTheme:SetProperty("bonusQuest", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
TransparenceTheme:SetProperty("bonusQuest.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
TransparenceTheme:SetProperty("bonusQuest.header[@hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })
-- ========================================================================== --
-- == Objective properties
-- ========================================================================== --
TransparenceTheme:SetProperty("objective.*", "border-color", { r = 0, g = 0, b = 0, a = 0})
TransparenceTheme:SetProperty("objective.*", "text-size", 13)
TransparenceTheme:SetProperty("objective.*", "text-font", "PT Sans Narrow Bold")
TransparenceTheme:SetProperty("objective.*", "text-transform", "none")
TransparenceTheme:SetProperty("objective.*", "text-location", "LEFT")
TransparenceTheme:SetProperty("objective.*", "text-offsetX", 5)
  -- completed color
  TransparenceTheme:SetProperty("objective[@completed]", "text-color", { r = 0, g = 1, b = 0})
  TransparenceTheme:SetProperty("objective.square[@completed]", "background-color", { r = 0, g = 1, b = 0})
  -- in progress color
  TransparenceTheme:SetProperty("objective[@progress]", "text-color", { r = 148/255, g = 148/255, b = 148/255 })
  TransparenceTheme:SetProperty("objective.square[@progress]", "background-color", { r = 148/255, g = 148/255, b = 148/255 })
-- ========================================================================== --
-- == Quest header properties
-- ========================================================================== --
TransparenceTheme:SetProperty("questHeader.name", "text-size", 12)
TransparenceTheme:SetProperty("questHeader.name", "text-font", "PT Sans Narrow Bold")
TransparenceTheme:SetProperty("questHeader.name", "text-color", { r = 1, g = 0.38, b = 0 })
TransparenceTheme:SetProperty("questHeader.name", "text-transform", "uppercase")
TransparenceTheme:SetProperty("questHeader.name", "text-offsetX", 10)
