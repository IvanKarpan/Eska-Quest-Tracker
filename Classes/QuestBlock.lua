--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio               "EskaQuestTracker.Classes.QuestBlock"                   ""
--============================================================================--
namespace "EQT"
--============================================================================--
class "QuestBlock" inherit "Block"
  _QuestBlockCache = setmetatable( {}, { __mode = "k" } )
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  __Arguments__{ Quest }
  function AddQuest(self, quest)
    if not self.quests:Contains(quest) then
      local header = self:GetHeader(quest.header)
      if not header then
        header = self:NewHeader(quest.header)
      end
      header:AddQuest(quest)
      self.quests:Insert(quest)
      self.OnDrawRequest()
      _M:FireSystemEvent("EQT_QUESTBLOCK_QUEST_ADDED", quest)
    end
  end

  __Arguments__ { Number }
  function RemoveQuest(self, questID)
    local quest = self:GetQuest(questID)
    if quest then
      self:RemoveQuest(quest)
    end
  end

  __Arguments__{ Quest }
  function RemoveQuest(self, quest)
    self.quests:Remove(quest)
    local header = self:GetHeader(quest.header)
    if header then
      header:RemoveQuest(quest)
      if header:GetQuestNum() == 0 then
        header.OnHeightChanged = nil
        header.OnDrawRequest = nil

        self:RemoveHeader(quest.header)
        header.isReusable = true
        self.OnDrawRequest()
      end
    end
    _M:FireSystemEvent("EQT_QUESTBLOCK_QUEST_REMOVED", quest)
    quest.isReusable = true
  end

  __Arguments__ { Number }
  function GetQuest(self, questID)
    for _, quest in self.quests:GetIterator() do
      if quest.id == questID then
        return quest
      end
    end
  end

  __Arguments__ { String }
  function GetHeader(self, name)
    return self.headers[name]
  end

  __Arguments__ { String }
  function NewHeader(self, name)
    local header = _ObjectManager:GetQuestHeader()
    header.name = name
    header._sortIndex = nil
    header:SetParent(self.frame)

    header.OnHeightChanged = function(h, new, old)
      self.height = self.height + (new - old)
    end

    header.OnQuestDistanceChanged = function(h)
      self.OnDrawRequest()
    end

    self.headers[name] = header

    return header
  end

  __Arguments__ { String }
  function RemoveHeader(self, name)
    self.headers[name] = nil
  end

  __Arguments__()
  function Draw(self)

    local previousFrame
    local height = 0

    -- Header compare function
    local function HeaderSortMethod(a, b)
      if a.nearestQuestDistance ~= b.nearestQuestDistance then
        return a.nearestQuestDistance < b.nearestQuestDistance
      end
      return a.name < b.name
    end

    local mustBeAnchored = false
    for index, header in self.headers.Values:ToList():Sort(HeaderSortMethod):GetIterator() do

        if (not header._sortIndex) or (header._sortIndex ~= index) then
          mustBeAnchored = true
        end

        if mustBeAnchored then
          if not header:IsShown() then
            header:Show()
          end

          if index == 1 then
            header.frame:SetPoint("TOPLEFT", 0, -35)
            header.frame:SetPoint("TOPRIGHT", 0, -35)
            isFirst = false
          else
            header.frame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -2)
            header.frame:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
          end
        end
          header._sortIndex = index

          height = height + header.height
          previousFrame = header.frame

    end
    self.height = self.baseHeight + height + 10
  end

  __Arguments__{}
  function Refresh(self)
    Super.Refresh(self)
  end


  __Static__()
  function RefreshAll()
    for obj in pairs(_QuestBlockCache) do
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

  __Static__() property "showOnlyQuestsInZone" {
    TYPE = Boolean,
    SET = function(self, filteringByZone)
      _DB.Quests.filteringByZone = filteringByZone
      _M:FireSystemEvent("EQT_SHOW_ONLY_QUESTS_IN_ZONE", filteringByZone)
    end,
    GET = function(self) return _DB.Quests.filteringByZone end
  }
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  -- Theme
  __Static__() property "_THEME_CLASS_ID" { DEFAULT = "block.quests" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function QuestBlock(self)
    Super(self, "quests", 20)
    self.text = "Quests"


    self.quests = ObjectArray(Quest)
    self.headers = Dictionary()

    -- self:Refresh()
    _QuestBlockCache[self] = true
  end
endclass "QuestBlock"
QuestBlock:InstallOptions()
