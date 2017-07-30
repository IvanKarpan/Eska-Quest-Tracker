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
      Theme.SkinText(self.frame.name, new)
    elseif prop == "texture" then
      self.frame.ftex.texture:SetTexture(new)
    end
  end
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  __Arguments__ {}
  function Draw(self)
    if self.numObjectives > 0 then
      local obj = self.objectives[1]
      if obj then
        obj.frame:SetPoint("TOPLEFT", self.frame.ftex, "TOPRIGHT")
        obj.frame:SetPoint("TOPRIGHT", self.frame.header, "BOTTOMRIGHT")
        self:DrawObjectives(self.frame, true)
        self.height = self.height + 5
      end
    else
      self.height = self.baseHeight + 92 + 8
    end

    if self.height < self.baseHeight + 92 then
      self.height = self.baseHeight + 92 + 8
    end
  end

  __Arguments__{ Argument(Boolean, true, true)}
  function Refresh(self, callSuper)
    if callSuper then
      Super.Refresh(self)
    end

    Theme.SkinFrame(self.frame.ftex)
    Theme.SkinText(self.frame.name, self.name)
  end

  __Static__()
  function RefreshAll()
    for obj in pairs(_DungeonCache) do
      obj:Refresh()
    end
  end

  __Arguments__ {}
  function RegisterFramesForThemeAPI(self)
    Theme.RegisterFrame(self.tID..".icon", self.frame.ftex)
    Theme.RegisterText(self.tID..".name", self.frame.name)
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "name" { TYPE = String, DEFAULT = "", HANDLER = UpdateProps}
  property "texture" { TYPE = String + Number, DEFAULT = nil, HANDLER = UpdateProps }
  -- Theme
  property "tID" { DEFAULT = "block.dungeon"}
  __Static__() property "_THEME_CLASS_ID" { DEFAULT = "block.dungeon" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function Dungeon(self)
    Super(self, "dungeon", 10)
    self.text = "Dungeon"

    local header = self.frame.header
    local headerText = header.text

  --  self.frame:SetBackdropColor(0, 0, 0, 0.3)
    self.frame:SetBackdropBorderColor(0, 0, 0, 1)

    -- Dungeon name
    local name = header:CreateFontString(nil, "OVERLAY")
    name:SetPoint("TOPRIGHT")
    name:SetPoint("BOTTOMRIGHT")
    name:SetPoint("LEFT", headerText, "RIGHT")
    name:SetJustifyH("CENTER")
    self.frame.name = name

    -- Set the headerText to left
    headerText:SetPoint("LEFT")
    headerText:SetJustifyH("LEFT")
    headerText:SetWidth(75)

    -- Dungeon Texture
    local ftex = CreateFrame("Frame", nil, self.frame)
    ftex:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
    ftex:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 4, -4)
    ftex:SetHeight(92)
    ftex:SetWidth(92)
    self.frame.ftex = ftex

    local texture = ftex:CreateTexture()
    texture:SetPoint("CENTER")
    texture:SetHeight(90)
    texture:SetWidth(90)
    texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    ftex.texture = texture

    self.baseHeight = self.height

    -- Important : Always use 'This' to avoid issues when this class is inherited
    -- by other classes.
    This.RegisterFramesForThemeAPI(self)
    -- Here the false boolean say to refresh function to not call the refresh super function
    -- because it's already done by the super constructor
    This.Refresh(self, false)

    _DungeonCache[self] = true
  end

  __Static__()
  function InstallOptions(self, child)
    local class = child or self
    local prefix = class._THEME_CLASS_ID and class._THEME_CLASS_ID or ""
    local superClass = System.Reflector.GetSuperClass(self)
    if superClass.InstallOptions then
      superClass:InstallOptions(class)
    end

    Options.AddAvailableThemeKeywords(
      Options.ThemeKeyword(prefix..".icon", Options.ThemeKeywordType.FRAME),
      Options.ThemeKeyword(prefix..".name", Options.ThemeKeywordType.TEXT)
    )
  end

endclass "Dungeon"
Dungeon:InstallOptions()
