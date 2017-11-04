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
  _WorldQuestCache = setmetatable( {}, { __mode = "k" })
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  __Arguments__ { Argument(Theme.SkinFlags, true, 127) }
  __Static__() function RefreshAll(skinFlags)
    for obj in pairs(_WorldQuestCache) do
      obj:Refresh(skinFlags)
    end
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  __Static__() property "_prefix" { DEFAULT = "worldQuest" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function WorldQuest(self)
      Super(self)
      _WorldQuestCache[self] = true
  end

endclass "WorldQuest"

function OnLoad(self)
  _ObjectManager:Register(WorldQuest)

  CallbackHandlers:Register("worldQuest/refresher", CallbackHandler(WorldQuest.RefreshAll))
end
