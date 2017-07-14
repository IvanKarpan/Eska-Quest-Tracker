--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio             "EskaQuestTracker.Classes.WorldQuest"                     ""
--============================================================================--
namespace "EQT"
--============================================================================--
class "WorldQuest" inherit "Quest"
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  __Arguments__{}
  function Draw(self)
    Super.Draw(self)
  end
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function WorldQuest(self)
      Super(self)
  end
endclass "WorldQuest"

function OnLoad(self)
  _ObjectManager:Register(WorldQuest)
end
