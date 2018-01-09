--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio           "EskaQuestTracker.Classes.QuestHeader"                      ""
--============================================================================--
namespace "EQT"
--============================================================================--
class "QuestHeader" inherit "Frame" extend "IReusable"
  _QuestHeaderCache = setmetatable( {}, { __mode = "k" } )
  event "OnQuestDistanceChanged"
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function SetName(self, new, old, prop)
    Theme:SkinText(self.frame.name, new)
  end
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
    __Arguments__{ Quest }
    function AddQuest(self, quest)
      if not self.quests:Contains(quest) then
        quest._sortIndex = nil
        self.quests:Insert(quest)
        quest:SetParent(self.frame)

        quest.OnHeightChanged = function(quest, new, old)
          self.height = self.height + (new - old)
        end

        quest.OnDistanceChanged = function()
          self.OnDrawRequest()
          self.OnQuestDistanceChanged()
         end

        self.OnDrawRequest()
      end
    end

    __Arguments__{ Quest }
    function RemoveQuest(self, quest)
      local found = self.quests:Remove(quest)
      if found then
        quest.OnHeightChanged = nil
        quest.OnDistanceChanged = nil
        self.OnDrawRequest()
      end
    end

  __Arguments__{}
  function GetQuestNum(self)
    return self.quests.Count
  end

  __Arguments__{}
  function Draw(self)
    local previousFrame
    local height = 0

    -- Quest compare function (Priorty : Distance > ID > Name)
    local function QuestSortMethod(a, b)
      if a.distance ~= b.distance then
        return a.distance < b.distance
      end

      if a.id ~= b.id then
        return a.id < b.id
      end
      return a.name < b.name
    end

    local mustBeAnchored = false
    for index, quest in self.quests:Sort(QuestSortMethod):GetIterator() do
      -- if the sort index don't existant (the quest is new in the quest header )
      -- or the quest has changed position, it need to be redrawn
      if index == 1 then
        self.nearestQuest = quest
      end

      if (not quest._sortIndex) or (quest._sortIndex ~= index) then
        mustBeAnchored = true
      end

      if mustBeAnchored then
        if not quest:IsShown() then
          quest:Show()
        end

        if index == 1 then
          quest.frame:SetPoint("TOPLEFT", 0, -36)
          quest.frame:SetPoint("TOPRIGHT", 0, -36)
        else
          quest.frame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -10)
          quest.frame:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
        end
      end
      quest._sortIndex = index

      previousFrame = quest.frame
      height = height + quest.height + 10
    end
    self.height = self.baseHeight + height
  end


  __Arguments__{}
  function Reset(self)
    self.name = nil
    self:ClearAllPoints()
    self:SetParent(nil)
    self:Hide()
  end


  __Arguments__ { Argument(Theme.SkinInfo, true, Theme.SkinInfo()), Argument(Boolean, true, true) }
  function SkinFeatures(self, info, alreadyInit)
    if alreadyInit then
      Super.SkinFeatures(self, info)
    end

    Theme:SkinFrame(self.frame, nil, nil, skinFlags)
    Theme:SkinText(self.frame.name, self.name, nil, skinFlags)
  end

  __Arguments__ { Argument(Theme.SkinInfo, true, Theme.SKIN_INFO_ALL_FLAGS) }
  __Static__() function RefreshAll(skinInfo)
    for obj in pairs(_QuestHeaderCache) do
      obj:Refresh(skinInfo)
    end
  end

  __Arguments__ {}
  function RegisterFramesForThemeAPI(self)
    local class = System.Reflector.GetObjectClass(self)

    Theme:RegisterFrame(class._prefix..".frame", self.frame)
    Theme:RegisterText(class._prefix..".name", self.frame.name)
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "name" { TYPE = String, DEFAULT = "Misc", HANDLER = SetName }
  property "isActive" { TYPE = Boolean, DEFAULT = true }
  property "nearestQuestDistance" {
      GET = function(self)
        if self.nearestQuest then
          return self.nearestQuest.distance
        else
          return 99999
        end
      end
  }
  __Static__() property "_prefix" { DEFAULT = "questHeader" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function QuestHeader(self, name)
    Super(self)
    local frame = CreateFrame("Frame")
    frame:SetBackdrop(_Backdrops.Common)
    frame:SetBackdropBorderColor(0,0,0,0)

    local name = frame:CreateFontString(nil, "OVERLAY")
    name:SetHeight(29) -- 20
    name:SetPoint("TOPLEFT", 10, 0)
    frame.name = name

    self.frame = frame
    self.height = 29
    self.baseHeight = self.height
    self.quests = ObjectArray(Quest)

    -- Keep it in the cache for later.
    _QuestHeaderCache[self] = true
    -- Important: Always use 'This' to avoid issues when this class is inherited by
    -- other classes.
    This.RegisterFramesForThemeAPI(self)
    -- Important: Don't forgot 'This' as argument to this method !
    self:InitRefresh(This)
  end
endclass "QuestHeader"
--============================================================================--
-- OnLoad Handler
--============================================================================--
function OnLoad(self)
  -- Register this class in the object manager
  _ObjectManager:Register(QuestHeader)

  CallbackHandlers:Register("questHeader/refresher", CallbackHandler(QuestHeader.RefreshAll), "refresher")
end
