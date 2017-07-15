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
EskaTheme.version = "1.0.0"
EskaTheme.stage   = "Alpha"
_Addon:RegisterTheme(EskaTheme)
-- ========================================================================== --
-- == Set Default properties
-- ========================================================================== --
EskaTheme:SetProperty("text-size", 10)
EskaTheme:SetProperty("text-offsetX", 0)
EskaTheme:SetProperty("text-offsetY", 0)
EskaTheme:SetProperty("text-location", "CENTER")
EskaTheme:SetProperty("background-color", { r = 0, g = 0, b = 0, a = 0})
-- ========================================================================== --
-- == Tracker properties
-- ========================================================================== --
EskaTheme:SetProperty("tracker", "background-color", { r = 0, g = 0, b = 0, a = 0.5 })
EskaTheme:SetProperty("tracker", "border-color", { r = 0, g = 0, b = 0})
-- ========================================================================== --
-- == Set Default block properties
-- ========================================================================== --
EskaTheme:SetProperty("block.*", "background-color", { r = 0, g = 0, b = 0, a = 0})
EskaTheme:SetProperty("block.*", "border-color", { r = 0, g = 0, b = 0, a = 0 })
-- Header properties
EskaTheme:SetProperty("block.header", "background-color", { r = 0, g = 0, b = 0, a = 0.5 })
EskaTheme:SetProperty("block.header", "border-color", { r = 0, g = 0, b = 0, a = 1})
EskaTheme:SetProperty("block.header", "text-size", 17)
EskaTheme:SetProperty("block.header", "text-color", { r = 0, g = 199/255, b = 1})
EskaTheme:SetProperty("block.header", "text-font", "PT Sans Narrow Bold")
EskaTheme:SetProperty("block.header", "text-transform", "uppercase")
EskaTheme:SetProperty("block.header", "text-location", "CENTER")
-- Stripe properties
EskaTheme:SetProperty("block.stripe", "vertex-color", { r = 0, g = 0, b = 0, a = 0.5})
-- ========================================================================== --
-- == Blocks properties
-- ========================================================================== --
-- Dungeon & Keystone
EskaTheme:SetProperty("block.dungeon", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
EskaTheme:SetProperty("block.dungeon.header", "text-location", "LEFT")
EskaTheme:SetProperty("block.dungeon.name", "text-font", "PT Sans Narrow Bold")
EskaTheme:SetProperty("block.dungeon.name", "text-size", 17)
EskaTheme:SetProperty("block.dungeon.name", "text-color", { r = 1, g = 0.5, b = 0})
EskaTheme:SetProperty("block.dungeon.name", "text-transform", "none")
EskaTheme:SetProperty("block.dungeon.name", "text-location", "CENTER")
EskaTheme:SetProperty("block.dungeon.icon", "border-color", { r = 0, g = 0, b = 0 })

EskaTheme:SetProperty("block.keystone", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
EskaTheme:SetProperty("block.keystone.header", "text-location", "LEFT")
EskaTheme:SetProperty("block.keystone.name", "text-font", "PT Sans Narrow Bold")
EskaTheme:SetProperty("block.keystone.name", "text-size", 17)
EskaTheme:SetProperty("block.keystone.name", "text-color", { r = 1, g = 0.5, b = 0})
EskaTheme:SetProperty("block.keystone.name", "text-transform", "none")
EskaTheme:SetProperty("block.keystone.name", "text-location", "CENTER")
EskaTheme:SetProperty("block.keystone.icon", "border-color", { r = 0, g = 0, b = 0})
EskaTheme:SetProperty("block.keystone.level", "text-font", "PT Sans Narrow Bold")
EskaTheme:SetProperty("block.keystone.level", "text-size", 14)
EskaTheme:SetProperty("block.keystone.level", "text-color", { r = 1, g = 215/255, b = 0 })

-- Scenario
EskaTheme:SetProperty("block.scenario", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
--EskaTheme:SetProperty("block.scenario", "border-color", { r = 0, g = 0, b = 0, a = 0.4})
EskaTheme:SetProperty("block.scenario.*", "text-font", "PT Sans Bold")
EskaTheme:SetProperty("block.scenario.*", "text-transform", "none")

   -- Name
   EskaTheme:SetProperty("block.scenario.name", "text-size", 13)
   EskaTheme:SetProperty("block.scenario.name", "text-transform", "uppercase")
   EskaTheme:SetProperty("block.scenario.name", "text-color", { r = 1, g = 0.5, b = 0 })
   -- Stage frame
   EskaTheme:SetProperty("block.scenario.stage", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
   EskaTheme:SetProperty("block.scenario.stage", "border-color", { r = 0, g = 0, b = 0, a = 0.4})
   -- Stage name
   EskaTheme:SetProperty("block.scenario.stageName", "text-size", 11)
   EskaTheme:SetProperty("block.scenario.stageName", "text-color", { r = 1, g = 1, b = 0 })
   -- Stage counter
   EskaTheme:SetProperty("block.scenario.stageCounter", "text-size", 12)
   EskaTheme:SetProperty("block.scenario.stageCounter", "text-font", "PT Sans Narrow Bold")
   EskaTheme:SetProperty("block.scenario.stageCounter", "text-color", { r = 1, g = 1, b = 1 })
-- ========================================================================== --
-- == Quest properties
-- ========================================================================== --
EskaTheme:SetProperty("quest.*", "text-font", "DejaVuSansCondensed Bold")
EskaTheme:SetProperty("quest.*", "text-size", 10)
EskaTheme:SetProperty("quest.*", "text-transform", "none")
EskaTheme:SetProperty("quest.*", "text-color", { r = 1.0, g = 191/255, b = 0})
EskaTheme:SetProperty("quest", "background-color", { r = 0, g = 0, b = 0, a = 0.3})
EskaTheme:SetProperty("quest.header", "background-color", { r = 0, g = 0, b = 0, a = 0.4 })
EskaTheme:SetProperty("quest.header[@hover]", "background-color", { r = 0, g = 148/255, b = 1, a = 0.4 })

-- EskaTheme:SetProperty("quest.header[@hover,completed]")
-- EskaTheme:SetProperty("quest.header[@enter||@completed]")
-- ========================================================================== --
-- == Objective properties
-- ========================================================================== --
EskaTheme:SetProperty("objective.*", "border-color", { r = 0, g = 0, b = 0, a = 0})
EskaTheme:SetProperty("objective.*", "text-size", 13)
EskaTheme:SetProperty("objective.*", "text-font", "PT Sans Narrow Bold")
EskaTheme:SetProperty("objective.*", "text-transform", "none")
EskaTheme:SetProperty("objective.*", "text-location", "LEFT")
EskaTheme:SetProperty("objective.*", "text-offsetX", 5)
  -- completed color
  EskaTheme:SetProperty("objective.*[@completed]", "text-color", { r = 0, g = 1, b = 0})
  EskaTheme:SetProperty("objective.square[@completed]", "background-color", { r = 0, g = 1, b = 0})
  -- in progress color
  EskaTheme:SetProperty("objective.*[@inprogress]", "text-color", { r = 148/255, g = 148/255, b = 148/255 })
    EskaTheme:SetProperty("objective.square[@inprogress]", "background-color", { r = 148/255, g = 148/255, b = 148/255 })
-- ========================================================================== --
-- == Quest header properties
-- ========================================================================== --
EskaTheme:SetProperty("questHeader.name", "text-size", 12)
EskaTheme:SetProperty("questHeader.name", "text-font", "PT Sans Narrow Bold")
EskaTheme:SetProperty("questHeader.name", "text-color", { r = 1, g = 0.38, b = 0 })
EskaTheme:SetProperty("questHeader.name", "text-transform", "uppercase")
EskaTheme:SetProperty("questHeader.name", "text-offsetX", 10)
-- EskaTheme:SetScript("questHeader.*", "OnEnter", [[
-- function(f)
--   f:SetBackdropColor(0.35, 0.89, 0.6)
--end
-- ]])