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
TransparenceTheme.version  = "1.1.2"
TransparenceTheme.stage    = "Alpha"
_Addon:RegisterTheme(TransparenceTheme)
-- ========================================================================== --
-- == Set Default properties
-- ========================================================================== --
TransparenceTheme:SetProperty("text-size", 10)
TransparenceTheme:SetProperty("text-offsetX", 0)
TransparenceTheme:SetProperty("text-offsetY", 0)
TransparenceTheme:SetProperty("text-location", "CENTER")
TransparenceTheme:SetProperty("background-color", { r = 0, g = 0, b = 0, a = 0})
