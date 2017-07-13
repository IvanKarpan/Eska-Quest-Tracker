-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio             "EskaQuestTracker.Classes.WorldQuestBlock"                ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
__InitChildBlockDB__()
class "WorldQuestBlock" inherit "Block"
  _WorldQuestBlockCache = setmetatable( {}, { __mode = "k" } )
  -- ======================================================================== --
  -- Methods
  -- ======================================================================== --
  __Arguments__ { WorldQuest }
  function AddWorldQuest(self, worldQuest)
    if not self.worldQuests:Contains(worldQuest) then
      self.worldQuests:Insert(worldQuest)
      worldQuest:SetParent(self.frame)

      worldQuest.OnHeightChanged = function(wq, new, old)
        self.height = self.height + (new - old)
      end

      self.OnDrawRequest()
    end
  end

  __Arguments__ { Number }
  function RemoveWorldQuest(self, worldQuestID)
    local worldQuest = self:GetWorldQuest(worldQuestID)
    if worldQuest then
      self:RemoveWorldQuest(worldQuest)
    end
  end


  __Arguments__ { WorldQuest }
  function RemoveWorldQuest(self, worldQuest)
    local found = self.worldQuests:Remove(worldQuest)
    if found then
      worldQuest.OnHeightChanged = nil
      worldQuest.isReusable = true

      self.OnDrawRequest()
    end
  end

  __Arguments__ { Number }
  function GetWorldQuest(self, worldQuestID)
    for _, worldQuest in self.worldQuests:GetIterator() do
      if worldQuest.id == worldQuestID then
        return worldQuest
      end
    end
  end

  __Arguments__()
  function Draw(self)
    local previousFrame
    local height = 0

    for index, worldQuest in self.worldQuests:GetIterator() do
      worldQuest:ClearAllPoints()
      worldQuest:Show()
      worldQuest:Draw()

      if index == 1 then
        worldQuest.frame:SetPoint("TOPLEFT", 0, -40)
        worldQuest.frame:SetPoint("TOPRIGHT", 20, -40)
      else
        worldQuest.frame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -5)
        worldQuest.frame:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
      end

      height = height + worldQuest.height
      previousFrame = worldQuest.frame
    end

    self.height = self.baseHeight + height
  end

  __Static__()
  function RefreshAll()
    for obj in pairs(_WorldQuestBlockCache) do
      obj:Refresh()
    end
  end

  property "text" { TYPE = String, DEFAULT = "World Quests", HANDLER = SetText}
  -- Theme
  property "tID" { DEFAULT = "block.worldQuests" }

  function WorldQuestBlock(self)
    Super(self, "worldQuests", 15)
    self.text = "World Quests"

    self.worldQuests = ObjectArray(WorldQuest)

    -- self:RegisterFramesForThemeAPI()
    self:Refresh()

    _WorldQuestBlockCache[self] = true
  end


endclass "WorldQuestBlock"
