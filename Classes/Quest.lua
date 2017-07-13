-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio                "EskaQuestTracker.Classes.Quest"                       ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
__DBTextOptions__(function() return _DB.Quest end)
class "Quest" inherit "Frame" extend "IReusable" "IObjectiveHolder"
  _QuestCache = setmetatable( {}, { __mode = "k" } )
  _Elements = {["name"] = "headerName", ["level"] = "headerLevel"}

  event "OnDistanceChanged"
  event "IsOnMapChanged"
  -- ======================================================================== --
  -- Handlers
  -- ======================================================================== --
  local function SetName(self, new, old, prop)
    if Quest.showID then
      self.frame.headerName:SetText(string.format("%s [%d]", new, self.id))
    else
      self.frame.headerName:SetText(new)
    end
  end

  local function SetLevel(self, new)
    self.frame.headerLevel:SetText(tostring(new))
  end

  local function UpdateDistance(self, new)
    --self.frame.headerLevel:SetText(tostring(ceil(new)))

    self.OnDistanceChanged(self, new)
  end
  -- ======================================================================== --
  -- Methods
  -- ======================================================================== --
  __Arguments__{}
  function GetQuestItem(self)
    if not self.questItem then
      self.questItem = _ObjectManager:GetQuestItem()
      self.questItem:SetParent(self.frame)
      -- self:Show()
    end

    return self.questItem
  end

  --[[
  __Arguments__{}
  function Draw(self)
    if self.questItem then
      local obj = self.objectives[1]
      if obj then
        -- questItem
        -- self.questItem:ClearAllPoints()
        self.questItem:Show()
        self.questItem.frame:SetPoint("TOPLEFT", self.frame.header, "BOTTOMLEFT", 5, -5)
        --self.questItem:SetParent(self.frame)

        -- objective
        obj.frame:SetPoint("TOPLEFT", self.questItem.frame, "TOPRIGHT")
        obj.frame:SetPoint("TOPRIGHT", self.frame.header, "BOTTOMRIGHT")

        self:DrawObjectives(self.frame.header, true)
        if self.height < self.questItem.height + self.baseHeight + 10 then
          self.height = self.baseHeight + self.questItem.height + 10
        end
      end
    else
        self:DrawObjectives(self.frame.header)
    end

  end
  --]]

  __Arguments__{}
  function Draw(self)
    if not self:IsShown() then
      self:Show()
    end

    if self.questItem then
      if not self.questItem:IsShown() then
        self.questItem:Show()
      end

      local obj = self.objectives[1]
      if obj then
        self.questItem:Show()
        self.questItem.frame:SetPoint("TOPLEFT", self.frame.header, "BOTTOMLEFT", 5, -5)

        obj.frame:SetPoint("TOPLEFT", self.questItem.frame, "TOPRIGHT")
        obj.frame:SetPoint("TOPRIGHT", self.frame.header, "BOTTOMRIGHT")

        self:DrawObjectives(self.frame.header, true)
        if self.height < self.questItem.height + self.baseHeight + 10 then
          self.height = self.baseHeight + self.questItem.height + 10
        end
      end
    else
      self:DrawObjectives(self.frame.header)
    end
  end

  function ShowLevel(self)
    self.frame.headerLevel:Show()
  end

  function HideLevel(self)
    self.frame.headerLevel:Hide()
  end


  function Refresh(self)
    Theme.SkinFrame(self.frame)
    Theme.SkinFrame(self.frame.header)

    Theme.SkinText(self.frame.headerName, self.name)
    Theme.SkinText(self.frame.headerLevel, self.level)

    if Quest.showLevel then
      self:ShowLevel()
    else
      self:HideLevel()
    end

  end

--[[
  function Refresh(self)
    local theme = _CURRENT_THEME

    for elementName, elementIndex in pairs(_Elements) do
      local elementFrame = self.frame[elementIndex]
      local tID = "quest."..elementName

      local font = _LibSharedMedia:Fetch("font", theme:GetProperty(tID, "text-font"))
      local size = theme:GetProperty(tID, "text-size")
      local color = theme:GetProperty(tID, "text-color")

      elementFrame:SetFont(font, size, "OUTLINE")
      elementFrame:SetTextColor(color.r, color.g, color.b)
    end

    if Quest.showID then
      self.frame.headerName:SetText(string.format("%s [%d]", self.name, self.id))
    else
      self.frame.headerName:SetText(self.name)
    end

    if Quest.showLevel then
      self:ShowLevel()
    else
      self:HideLevel()
    end
  end
  --]]

  function Reset(self)
    --for _, objective in self.objectives:GetIterator() do
      --objective.isReusable = true
    --end

    self:ClearAllPoints()
    self:SetParent(nil)
    self:Hide()

    -- Reset properties
    self.numObjectives = nil
    self.id = nil
    self.name = nil
    self.level = nil
    self.header = nil
    self.distance = nil
    self.isBounty = nil
    self.isTask = nil
    self.isHidden = nil
    self.isOnMap = nil


    if self.questItem then
      self.questItem.isReusable = true
      self.questItem = nil
    end


    -- Reset variables
    --self.objectives =  ObjectArray(Objective)
    --self:ClearObjectives()

  end

  __Static__() function RefreshAll()
    for obj in pairs(_QuestCache) do
      obj:Refresh()
    end
  end

  __Static__() property "showID" {
    GET = function(self) return _DB.Quest.showID end,
    SET = function(self, showID) _DB.Quest.showID = showID ; Quest:RefreshAll() end
  }

  __Static__() property "showLevel" {
    GET = function() return _DB.Quest.showLevel end,
    SET = function(self, showLevel) _DB.Quest.showLevel = showLevel ; Quest:RefreshAll() end
  }

  __Static__() property "showOnlyQuestsInZone" {
    GET = function() return _DB.Quest.showOnlyQuestsInZone end,
    SET = function(self, showInZone) _DB.Quest.showOnlyInQuestsInZone = showInZone end,
  }


  function RegisterFramesForThemeAPI(self)
    local classPrefix = self.tID.."."

    Theme.RegisterFrame(classPrefix, self.frame)
    Theme.RegisterFrame(classPrefix.."header", self.frame.header)

    Theme.RegisterText(classPrefix.."name", self.frame.headerName)
    Theme.RegisterText(classPrefix.."level", self.frame.headerLevel)


  end


  -- ======================================================================== --
  -- Properties
  -- ======================================================================== --
  property "id" { TYPE= Number, DEFAULT = -1 }
  property "name" { TYPE = String, HANDLER = SetName, DEFAULT = ""}
  property "level" { TYPE = Number, DEFAULT = 0, HANDLER = SetLevel }
  property "header" { TYPE = String, DEFAULT = "Misc"}
  property "distance" { TYPE = Number, DEFAULT = -1, HANDLER = UpdateDistance }
  property "isBounty" { TYPE = Boolean, DEFAULT = false }
  property "isTask" { TYPE = Boolean, DEFAULT = false }
  property "isHidden" { TYPE = Boolean, DEFAULT = false }
  property "isOnMap" { TYPE = Boolean, DEFAULT = false, EVENT = "IsOnMapChanged" }
  -- Theme system
  property "tID" { DEFAULT = "quest"}
  -- ======================================================================== --
  -- Constructors
  -- ======================================================================== --
  function Quest(self)
    Super(self)

    local frame = CreateFrame("Frame")
    frame:SetBackdrop(_Backdrops.Common)
    frame:SetBackdropColor(0, 0, 0, 0.3) -- 0.2
    frame:SetBackdropBorderColor(0, 0, 0, 0)

    local headerFrame = CreateFrame("Button", nil, frame)
    headerFrame:SetBackdrop(_Backdrops.Common)
    headerFrame:SetBackdropColor(0, 0, 0, 0.4)
    headerFrame:SetBackdropBorderColor(0, 0, 0)
    headerFrame:SetPoint("TOPRIGHT")
    headerFrame:SetPoint("TOPLEFT")
    headerFrame:SetHeight(21) -- 14

    -- script
    headerFrame:SetScript("OnEnter", function()
      headerFrame:SetBackdropColor(0, 148/255, 1, 0.4)
    end)

    headerFrame:SetScript("OnLeave", function()
      headerFrame:SetBackdropColor(0, 0, 0, 0.4)
    end)

    headerFrame:SetScript("OnClick", function()
      QuestLogPopupDetailFrame_Show(GetQuestLogIndexByID(self.id))
    end)

    local headerText = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    headerText:GetFontObject():SetShadowOffset(0.5, 0)
    headerText:GetFontObject():SetShadowColor(0, 0, 0, 0.4)
    headerText:SetPoint("LEFT", 10, 0)
    headerText:SetPoint("RIGHT")
    headerText:SetPoint("TOP")
    headerText:SetPoint("BOTTOM")

    local headerLevel = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    headerLevel:GetFontObject():SetShadowOffset(0.5, 0)
    headerLevel:GetFontObject():SetShadowColor(0, 0, 0, 0.4)
    headerLevel:SetPoint("RIGHT", -2)



    frame.headerName = headerText
    frame.headerLevel = headerLevel
    frame.header = headerFrame

    self.frame = frame
    self.height = 21
    self.baseHeight = self.height

    --self.objectives = ObjectArray(Objective)
    _QuestCache[self] = true

    This.RegisterFramesForThemeAPI(self)
    self:Refresh()
  end

endclass "Quest"
-- Register it in the Theme system.
Theme:_RegisterClass("quest", Quest)
-- ========================================================================== --
-- == OnLoad Handler
-- ========================================================================== --
function OnLoad(self)
  -- DB
  _DB:SetDefault("Quest", {
    showID = false,
    ShowLevel = true,
    textSizes = {
      name = 10,
      level = 10
    },
    textFonts = {
      name = "DejaVuSansCondensed Bold",
      level = "DejaVuSansCondensed Bold"
    },
    textTransforms = {
      name = "none",
      level = "none"
    },
    textColors = {
      name = { r = 1.0, g = 191/255, b = 0},
      level = { r = 1.0, g = 191/255, b = 0}
    }
  })

  -- Register this class in the object manager
  _ObjectManager:Register(Quest)
end
