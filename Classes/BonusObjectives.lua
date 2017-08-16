--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio             "EskaQuestTracker.Classes.BonusObjective"                 ""
--============================================================================--
namespace "EQT"                                                               --                                                           --
--============================================================================--
class "BonusQuest" inherit "Quest"
  _BonusQuestCache = setmetatable( {}, { __mode = "k" })
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  __Arguments__{}
  function Draw(self)
    Super.Draw(self)
  end

  __Static__() function RefreshAll()
    for obj in pairs(_BonusQuestCache) do
      obj:Refresh()
    end
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
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  __Static__() property "_THEME_CLASS_ID" { DEFAULT = "bonusQuest"}
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function BonusQuest(self)
    Super(self)
    _BonusQuestCache[self] = true
  end
endclass "BonusQuest"
BonusQuest:InstallOptions()
Theme.RegisterRefreshHandler("bonusQuest", BonusQuest.RefreshAll)


class "BonusObjectives" inherit "Block"
  _BonusObjectivesCache = setmetatable( {}, { __mode = "k" } )
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  __Arguments__ { BonusQuest }
  function AddBonusQuest(self, bonusQuest)
    if not self.bonusQuests:Contains(bonusQuest) then
      self.bonusQuests:Insert(bonusQuest)
      bonusQuest:SetParent(self.frame)

      bonusQuest.OnHeightChanged = function(bq, new, old)
        self.height = self.height + (new - old)
      end

      self.OnDrawRequest()
    end
  end

  __Arguments__ { Number }
  function RemoveBonusQuest(self, bonusQuestID)
    local bonusQuest = self:GetBonusQuest(bonusQuestID)
    if bonusQuest then
      self:RemoveBonusQuest(bonusQuest)
    end
  end

  __Arguments__ { BonusQuest }
  function RemoveBonusQuest(self, bonusQuest)
    local found = self.bonusQuests:Remove(bonusQuest)
    if found then
      bonusQuest.OnHeightChanged = nil
      bonusQuest.isReusable = true

      self.OnDrawRequest()
    end
  end

  __Arguments__ { Number }
  function GetBonusQuest(self, bonusQuestID)
    for _, bonusQuest in self.bonusQuests:GetIterator() do
      if bonusQuest.id == bonusQuestID then
        return bonusQuest
      end
    end
  end

  __Arguments__()
  function Draw(self)
    local previousFrame
    local height = 0

    for index, bonusQuest in self.bonusQuests:GetIterator() do
      bonusQuest:ClearAllPoints()
      bonusQuest:Show()
      bonusQuest:Draw()

      if index == 1 then
        bonusQuest.frame:SetPoint("TOPLEFT", 0, -40)
        bonusQuest.frame:SetPoint("TOPRIGHT", 20, -40)
      else
        bonusQuest.frame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -5)
        bonusQuest.frame:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
      end

      height = height + bonusQuest.height
      previousFrame = bonusQuest.frame
    end

    self.height = self.baseHeight + height
  end

  __Static__()
  function RefreshAll()
    for obj in pairs(_BonusOjectivesCache) do
      obj:Refresh()
    end
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  -- Theme
  __Static__() property "_THEME_CLASS_ID" { DEFAULT = "block.bonusObjectives" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function BonusObjectives(self)
    Super(self, "bonusObjectives", 12)
    self.text = "Bonus Objectives"

    self.bonusQuests = ObjectArray(BonusQuest)

    _BonusObjectivesCache[self] = true
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
endclass "BonusObjectives"
BonusObjectives:InstallOptions()


function OnLoad(self)
  _ObjectManager:Register(BonusQuest)
end
