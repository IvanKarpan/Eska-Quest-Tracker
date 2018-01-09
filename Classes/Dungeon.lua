--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio         "EskaQuestTracker.Classes.Dungeon"                            ""
--============================================================================--
namespace "EQT"
--============================================================================--
class "Dungeon" inherit "Block" extend "IObjectiveHolder"
  _DungeonCache = setmetatable( {}, { __mode = "k" } )
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function UpdateProps(self, new, old, prop)
    if prop == "name" then
      Theme:SkinText(self.frame.name, new)
    elseif prop == "texture" then
      self.frame.ftex.texture:SetTexture(new)
    end
  end
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  --[[__Arguments__ {}
  function Draw(self)
    local iconHeight = Options:Get("dungeon-icon-height")
    if self.numObjectives > 0 then
      local obj = self.objectives[1]
      if obj then
        obj.frame:SetPoint("TOPLEFT", self.frame.ftex, "TOPRIGHT")
        obj.frame:SetPoint("TOPRIGHT", self.frame.header, "BOTTOMRIGHT")
        self:DrawObjectives(self.frame, true)
        self.height = self.height + 5
      end
    else
      self.height = self.baseHeight + iconHeight + 8
    end

    if self.height < self.baseHeight + iconHeight then
      self.height = self.baseHeight + iconHeight + 8
    end
  end--]]

  function Draw(self)
    local previousFrame
    for index, obj in self.objectives:GetIterator() do
      obj:ClearAllPoints()
      if index == 1 then
        --obj:SetPoint("TOPLEFT", self.frame.ftex, "TOPRIGHT")
        --obj:SetPoint("TOPRIGHT", self.frame.header, "BOTTOMRIGHT")
        obj:SetPoint("TOP", self.frame.header, "BOTTOM")
        obj:SetPoint("LEFT", self.frame.ftex, "RIGHT")
        obj:SetPoint("RIGHT")
        --obj:SetPoint("TOPRIGHT", self.frame.header, "BOTTOMRIGHT")
      else
        obj:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT")
        obj:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT")
      end
      obj:CalculateHeight()
      previousFrame = obj.frame
    end

    self:CalculateHeight()
  end

  function CalculateHeight(self)
      local height = self.baseHeight

      -- Get the iconHeight
      local iconHeight = Options:Get("dungeon-icon-height")
      -- Get the height of objectives
      local objectivesHeight = self:GetObjectivesHeight()

      height = height + max(iconHeight, objectivesHeight) + 8

      self.height = height
  end

  __Arguments__ { Argument(Theme.SkinInfo, true, Theme.SkinInfo()), Argument(Boolean, true, true) }
  function SkinFeatures(self, info, alreadyInit)
    -- Call the parent if the object is already init.
    if alreadyInit then
      Super.SkinFeatures(self, info)
    end

    Theme:NewSkinFrame(self.frame.ftex, info)
    Theme:NewSkinText(self.frame.name, Theme.SKIN_TEXT_ALL_FLAGS, self.name)
  end

  __Arguments__ { Argument(Theme.SkinInfo, true, Theme.SkinInfo()), Argument(Boolean, true, true) }
  function ExtraSkinFeatures(self, info, alreadyInit)
      if alreadyInit then
        Super.ExtraSkinFeatures(self, info)
      end
      local theme = Themes:GetSelected()
      if not theme then return end

      if System.Reflector.ValidateFlags(info.textFlags, Theme.SkinTextFlags.TEXT_LOCATION) then
        local name = self.frame.name
        local elementID = name.elementID
        local inheritElementID = name.inheritElementID
        if elementID then
          local location = theme:GetElementProperty(elementID, "text-location", inheritElementID)
          local offsetX = theme:GetElementProperty(elementID, "text-offsetX", inheritElementID)
          local offsetY = theme:GetElementProperty(elementID, "text-offsetY", inheritElementID)

          name:SetPoint("TOPLEFT", offsetX, offsetY)

          name:SetJustifyV(_JUSTIFY_V_FROM_ANCHOR[location])
          name:SetJustifyH(_JUSTIFY_H_FROM_ANCHOR[location])
        end
      end
  end


  __Arguments__ { }
  function RefreshIconSize(self)
    local iconHeight = Options:Get("dungeon-icon-height")
    local iconWidth = Options:Get("dungeon-icon-width")

    self.frame.ftex:SetHeight(iconHeight)
    self.frame.ftex:SetWidth(iconWidth)
    self.frame.ftex.texture:SetHeight(iconHeight - 2)
    self.frame.ftex.texture:SetWidth(iconWidth - 2)

    self:Draw()
  end

  __Arguments__ { Argument(Theme.SkinInfo, true, Theme.SKIN_INFO_ALL_FLAGS) }
  __Static__() function RefreshAll(skinInfo)
    for obj in pairs(_DungeonCache) do
      obj:Refresh(skinInfo)
    end
  end

  __Arguments__ {}
  __Static__() function RefreshAllIconSize()
    for obj in pairs(_DungeonCache) do
      obj:RefreshIconSize()
    end
  end

  __Arguments__ {}
  function RegisterFramesForThemeAPI(self)
    local class = System.Reflector.GetObjectClass(self)

    Theme:RegisterFrame(class._prefix..".icon", self.frame.ftex, "block.dungeon.icon")
    Theme:RegisterText(class._prefix..".name", self.frame.name, "block.dungeon.name")
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "name" { TYPE = String, DEFAULT = "", HANDLER = UpdateProps}
  property "texture" { TYPE = String + Number, DEFAULT = nil, HANDLER = UpdateProps }

  __Static__() property "_prefix" { DEFAULT = "block.dungeon" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Dungeon(self)
    Super(self, "dungeon", 10)
    self.text = "Dungeon"

    local header = self.frame.header
    local headerText = header.text

    -- self.frame:SetBackdropColor(0, 0, 0, 0.3)
    -- self.frame:SetBackdropBorderColor(0, 0, 0, 1)

    -- Dungeon name
    local name = header:CreateFontString(nil, "OVERLAY")
    name:SetAllPoints()
    name:SetJustifyH("CENTER")
    self.frame.name = name

    local iconHeight = Options:Get("dungeon-icon-height")
    local iconWidth = Options:Get("dungeon-icon-width")

    -- Dungeon Texture
    local ftex = CreateFrame("Frame", nil, self.frame)
    ftex:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
    ftex:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 4, -4)
    ftex:SetHeight(iconHeight)
    ftex:SetWidth(iconWidth)
    self.frame.ftex = ftex

    local texture = ftex:CreateTexture()
    texture:SetPoint("CENTER")
    texture:SetHeight(iconHeight - 2)
    texture:SetWidth(iconWidth - 2)
    texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    ftex.texture = texture

    self.baseHeight = self.height

    -- Keep it in the cache for later.
    _DungeonCache[self] = true
    -- Important: Always use 'This' to avoid issues when this class is inherited by
    -- other classes.
    This.RegisterFramesForThemeAPI(self)
    -- Important: Don't forgot 'This' as argument to this method !
    self:InitRefresh(This)
  end
endclass "Dungeon"

function OnLoad(self)
  CallbackHandlers:Register("dungeon/refresher", CallbackHandler(Dungeon.RefreshAll))
  CallbackHandlers:Register("dungeon/refreshIconSize", CallbackHandler(Dungeon.RefreshAllIconSize))

  Options:Register("dungeon-icon-height", 92, "dungeon/refreshIconSize")
  Options:Register("dungeon-icon-width", 92, "dungeon/refreshIconSize")
end
