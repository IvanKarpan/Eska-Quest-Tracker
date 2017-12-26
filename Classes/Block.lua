--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio                   "EskaQuestTracker.Block"                            ""
--============================================================================--
namespace "EQT"
--============================================================================--
class "Block" inherit "Frame"
  event "OnActiveChanged"
  _BlockCache = setmetatable( {}, { __mode = "k"})
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  function SetText(self, new)
    Theme:SkinText(self.frame.header.text, new)
  end
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  __Arguments__ { Argument(Theme.SkinFlags, true, 127), Argument(Boolean, true, true)}
  function Refresh(self, skinFlags, callSuper)
    Theme:SkinFrame(self.frame, nil, nil, skinFlags)
    Theme:SkinFrame(self.frame.header, self.text, nil, skinFlags)
    Theme:SkinTexture(self.frame.header.stripe, nil, skinFlags)
  end


  __Arguments__ {}
  function RegisterFramesForThemeAPI(self)
    local class = System.Reflector.GetObjectClass(self)


    Theme:RegisterFrame(class._prefix..".frame", self.frame, "block.frame")
    Theme:RegisterFrame(class._prefix..".header", self.frame.header, "block.header")
    Theme:RegisterTexture(class._prefix..".stripe", self.frame.header.stripe, "block.stripe")
  end

  __Arguments__ { Argument(Theme.SkinFlags, true, 127) }
  __Static__() function RefreshAll(skinFlags)
    for obj in pairs(_BlockCache) do
      obj:Refresh(skinFlags)
    end
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "id" { TYPE = String }
  property "text" { TYPE = String, DEFAULT = "Default Header Text", HANDLER = SetText}
  property "isActive" { TYPE = Boolean, DEFAULT = true, EVENT = "OnActiveChanged" }
  property "priority" { TYPE = Number, DEFAULT = 100 }

  __Static__() property "_THEME_CLASS_ID" { DEFAULT = "block" }
  __Static__() property "_prefix" { DEFAULT = "block" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  __Arguments__ { }
  function Block(self)
    Super(self)

    local frame = CreateFrame("Frame")
    frame:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
    frame:SetBackdropBorderColor(0,0,0,0)

    local headerFrame = CreateFrame("Frame", nil, frame)
    headerFrame:SetPoint("TOPLEFT")
    headerFrame:SetPoint("TOPRIGHT")
    headerFrame:SetFrameStrata("HIGH")
    headerFrame:SetHeight(34) -- 24
    headerFrame:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
    frame.header = headerFrame

    local stripe = headerFrame:CreateTexture()
    stripe:SetAllPoints()
    stripe:SetTexture([[Interface\AddOns\EskaQuestTracker\Media\Textures\Stripe]])
    stripe:SetDrawLayer("ARTWORK", 2)
    stripe:SetBlendMode("ALPHAKEY")
    stripe:SetVertexColor(0, 0, 0, 0.5)
    headerFrame.stripe = stripe

    local headerText = headerFrame:CreateFontString(nil, "OVERLAY")
    headerText:SetAllPoints()
    --headerText:SetPoint("CENTER", -10, 20)
    headerText:SetShadowColor(0, 0, 0, 0.25)
    headerText:SetShadowOffset(1, -1)
    headerFrame.text = headerText

    self.frame = frame
    self.height = 34
    self.baseHeight = self.height

    -- Important : Always use 'This' to avoid issues when this class is inherited
    -- by other classes.
    This.RegisterFramesForThemeAPI(self)
    This.Refresh(self)

    _BlockCache[self] = true
  end

  __Arguments__{ String, Number }
  function Block(self, id, priority)
    self.id = id
    self.priority = priority

    This(self)
  end
endclass "Block"
-- ========================================================================== --
-- == OnLoad Handler
-- ========================================================================== --
function OnLoad(self)
  CallbackHandlers:Register("block/refresher", CallbackHandler(Block.RefreshAll), "refresher")
end
