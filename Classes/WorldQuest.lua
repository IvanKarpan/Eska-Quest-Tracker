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
  __Arguments__{}
  function Draw(self)
    Super.Draw(self)
  end



  __Static__() function RefreshAll()
    for obj in pairs(_WorldQuestCache) do
      obj:Refresh()
    end
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  __Static__() property "_THEME_CLASS_ID" { DEFAULT = "worldQuest"}

  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function WorldQuest(self)
      Super(self)

      _WorldQuestCache[self] = true
  end


  __Static__()
  function InstallOptions(self, child)
    local class = child or self
    local prefix = class._THEME_CLASS_ID and class._THEME_CLASS_ID or ""
    local superClass = System.Reflector.GetSuperClass(self)
    if superClass.InstallOptions then
      superClass:InstallOptions(class)
    end
  end
endclass "WorldQuest"
WorldQuest:InstallOptions()
Theme.RegisterRefreshHandler("worldQuest", WorldQuest.RefreshAll)


function OnLoad(self)
  _ObjectManager:Register(WorldQuest)
end
