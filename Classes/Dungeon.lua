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
  __Arguments__ {}
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
  end

  __Arguments__ { Argument(Theme.SkinFlags, true, 127), Argument(Boolean, true, true)}
  function Refresh(self, skinFlags, callSuper)
    if callSuper then
      Super.Refresh(self, skinFlags)
    end

    Theme:SkinFrame(self.frame.ftex, nil, nil, skinFlags)
    Theme:SkinText(self.frame.name, self.name, nil, skinFlags)
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

  __Arguments__ { Argument(Theme.SkinFlags, true, 127) }
  __Static__() function RefreshAll(skinFlags)
    for obj in pairs(_DungeonCache) do
      obj:Refresh(skinFlags)
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

    -- Important : Always use 'This' to avoid issues when this class is inherited
    -- by other classes.
    This.RegisterFramesForThemeAPI(self)
    -- Here the false boolean say to refresh function to not call the refresh super function
    -- because it's already done by the super constructor
    This.Refresh(self, nil, false)

    _DungeonCache[self] = true
  end
endclass "Dungeon"

function OnLoad(self)
  CallbackHandlers:Register("dungeon/refresher", CallbackHandler(Dungeon.RefreshAll))
  CallbackHandlers:Register("dungeon/refreshIconSize", CallbackHandler(Dungeon.RefreshAllIconSize))

  Options:Register("dungeon-icon-height", 92, "dungeon/refreshIconSize")
  Options:Register("dungeon-icon-width", 92, "dungeon/refreshIconSize")
end
