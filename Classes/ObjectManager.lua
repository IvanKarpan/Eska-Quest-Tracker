-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio            "EskaQuestTracker.Classes.ObjectManager"                   ""
-- ========================================================================== --
namespace "EQT"
import "System"
import "System.Recycle"
import "System.Reflector"
-- ========================================================================== --

class "ObjectManager"

-- ========================================================================== --
-- Methods                                                                    --
-- ========================================================================== --
function GetQuest(self)
  return self:Get(Quest)
end

function GetObjective(self)
  return self:Get(Objective)
end

function GetQuestItem(self)
  return self:Get(QuestItem)
end

function GetQuestHeader(self)
  return self:Get(QuestHeader)
end

__Arguments__ { Class }
function Get(self, type)
  local obj
  if type == Quest then
    obj = self.questRecycler()
  elseif type == Objective then
    obj = self.objectiveRecycler()
  elseif type == QuestItem then
    obj = self.questItemRecycler()
  elseif type == QuestHeader then
    obj = self.questHeaderRecycler()
  else
    obj = self.recyclers[type]()
  end

  obj.isReusable = false
  return obj
end

__Arguments__ { IReusable }
function Recycle(self, obj)

  if ObjectIsClass(obj, Quest) then
    self.questRecycler(obj)
  elseif ObjectIsClass(obj, Objective) then
    self.objectiveRecycler(obj)
  elseif ObjectIsClass(obj, QuestItem) then
    self.questItemRecycler(obj)
  elseif ObjectIsClass(obj, QuestHeader) then
    self.questHeaderRecycler(obj)
  end
end

__Arguments__{ Class }
function Register(self, type)
  if not self.recyclers[type] then
    self.recyclers[type] = System.Recycle(type)
  end
end

-- ========================================================================== --
-- Properties                                                                 --
-- ========================================================================== --
-- Quest Recycler
property "questRecycler" { TYPE = Any }
-- Objective Recycler
property "objectiveRecycler" { TYPE = Any }
-- Quest Item Recycler
property "questItemRecycler" { TYPE = Any }
-- Quest Header Recycler
property "questHeaderRecycler" { TYPE = Any }

-- ========================================================================== --
-- Contructor                                                                 --
-- ========================================================================== --
function ObjectManager(self)
  --Debug("ObjectManager Constructor")
  self.questRecycler  = System.Recycle(Quest)
  self.objectiveRecycler = System.Recycle(Objective)
  self.questItemRecycler = System.Recycle(QuestItem)
  self.questHeaderRecycler = System.Recycle(QuestHeader)

  self.recyclers = Dictionary()
end

endclass "ObjectManager"
