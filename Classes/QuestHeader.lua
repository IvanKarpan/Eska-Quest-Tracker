-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio           "EskaQuestTracker.Classes.QuestHeader"                      ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
__DBTextOptions__( function() return _DB.Quest.header end, false)
class "QuestHeader" inherit "Frame" extend "IReusable"
  _QuestHeaderCache = setmetatable( {}, { __mode = "k" } )

  event "OnQuestDistanceChanged"
  -- ======================================================================== --
  -- Handlers
  -- ======================================================================== --
  local function SetName(self, new, old, prop)
    local textTransform = QuestHeader.textTransform
    local txt = new

    if textTransform == "uppercase" then
      txt = txt:upper()
    elseif textTransform == "lowercase" then
      txt =  txt:lower()
    end
    self.frame.name:SetText(txt)
  end

  -- ======================================================================== --
  -- Methods                                                                  --
  -- ======================================================================== --
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

--[[
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

    for index, quest in self.quests:Sort(QuestSortMethod):GetIterator() do
      --quest:ClearAllPoints()
      quest:Show()
      quest:Draw()
      if index == 1 then
        quest.frame:SetPoint("TOPLEFT", 0, -36)
        quest.frame:SetPoint("TOPRIGHT", 0, -36)
      else
        quest.frame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -10)
        quest.frame:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
      end
      previousFrame = quest.frame
      height = height + quest.height + 10
    end
    self.height = self.baseHeight + height
  end
--]]
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

    --

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


  function Refresh(self)
    Theme.SkinFrame(self.frame)

    Theme.SkinText(self.frame.name, self.name)

  end


--[[  __Arguments__{}
  function Refresh(self)
    local theme = _CURRENT_THEME

    local name = self.frame.name
    local font = _LibSharedMedia:Fetch("font", theme:GetProperty("questHeader.name", "text-font"))
    local size = theme:GetProperty("questHeader.name", "text-size")
    local color = theme:GetProperty("questHeader.name", "text-color")
    local transform = theme:GetProperty("questHeader.name", "text-transform")

    name:SetFont(font, size, "OUTLINE")
    name:SetTextColor(color.r, color.g, color.b)

    local txt = self.name
    if transform == "uppercase" then
      txt = txt:upper()
    elseif transform == "lowercase" then
      txt = txt:lower()
    end
    name:SetText(txt)
  end

  __Static__() function RefreshAll()
    for obj in pairs(_QuestHeaderCache) do
      obj:Refresh()
    end
  end
  --]]


  function RegisterFramesForThemeAPI(self)
    local classPrefix = "questHeader."

    Theme.RegisterFrame(classPrefix, self.frame)
    Theme.RegisterText(classPrefix.."name", self.frame.name)
  end


  -- ======================================================================== --
  -- Properties
  -- ======================================================================== --
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
  -- ======================================================================== --
  -- Contructor
  -- ======================================================================== --
  function QuestHeader(self, name)
    Super(self)
    local frame = CreateFrame("Frame")
    --frame:SetBackdrop(_Backdrops.Common)
    --frame:SetBackdropColor(0, 1, 0, 1) -- 0.2
    --frame:SetBackdropBorderColor(0, 0, 0, 0)

    local name = frame:CreateFontString(nil, "OVERLAY")
    --local font = _LibSharedMedia:Fetch("font", QuestHeader.textFont)
    --local color = QuestHeader.textColor

    --local scriptFunc = _CURRENT_THEME:GetScript("questHeader.*", "OnEnter")

    --frame:SetScript("OnEnter", _CURRENT_THEME:GetScript("questHeader.*", "OnEnter"))
    --frame:SetScript("OnEnter", function(self) print("OnHover") ; self:SetBackdropColor(0.35, 0.89, 0.6, 1) end)

    --name:SetFont(font, QuestHeader.textSize, "OUTLINE")
    --name:SetText(self.name)
    --name:SetTextColor(color.r, color.g, color.b)
    name:SetHeight(29) -- 20
    name:SetPoint("TOPLEFT", 10, 0)
    frame.name = name

    self.frame = frame
    self.height = 29
    self.baseHeight = self.height
    self.quests = ObjectArray(Quest)

    _QuestHeaderCache[self] = true

    This.RegisterFramesForThemeAPI(self)
    self:Refresh()
  end

endclass "QuestHeader"
-- Register it in the Theme system.
Theme:_RegisterClass("questHeader",  questHeader)
-- ========================================================================== --
-- == OnLoad Handler
-- ========================================================================== --
function OnLoad(self)
  _DB:SetDefault("Quest", {
    header = {
      textColor = { r = 1, g = 0.38, b = 0 },
      textSize = 12,
      textFont = "PT Sans Narrow Bold",
      textTransform = "uppercase", -- none, lowercase
    }
  })

  -- Register this class in the object manager
  _ObjectManager:Register(QuestHeader)
end
