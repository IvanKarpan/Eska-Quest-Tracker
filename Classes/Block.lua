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
  event "OnPriorityChanged"

  _BlockCache = setmetatable( {}, { __mode = "k"})
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  function SetText(self, new)
    Theme:NewSkinText(self.frame.header.text, Theme.SkinTextFlags.TEXT_TRANSFORM, new)
  end
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  __Arguments__ { Variable.Optional(Theme.SkinInfo, Theme.SkinInfo()) }
  __Static__() function RefreshAll(skinInfo)
    for obj in pairs(_BlockCache) do
      obj:Refresh(skinInfo)
    end
  end

  __Arguments__ { Variable.Optional(Theme.SkinInfo, Theme.SkinInfo()), Variable.Optional(Boolean, true) }
  function SkinFeatures(self, info, alreadyInit)
    if alreadyInit then
      super.SkinFeatures(self, info)
    end

    Theme:NewSkinFrame(self.frame, info)
    Theme:NewSkinFrame(self.frame.header, info)
    Theme:NewSkinText(self.frame.header.text, info, self.text)
    Theme:NewSkinTexture(self.frame.header.stripe, info)
  end

  __Arguments__ { Variable.Optional(Theme.SkinInfo, Theme.SkinInfo()), Variable.Optional(Boolean, true) }
  function ExtraSkinFeatures(self, info, alreadyInit)
    if alreadyInit then
      super.ExtraSkinFeatures(self, info)
    end

    local theme = Themes:GetSelected()
    if not theme then return end

    if Enum.ValidateFlags(info.textFlags, Theme.SkinTextFlags.TEXT_LOCATION) then
      local headerText = self.frame.header.text
      local elementID = headerText.elementID
      local inheritElementID = headerText.inheritElementID
      if elementID then
        local location = theme:GetElementProperty(elementID, "text-location", inheritElementID)
        local offsetX = theme:GetElementProperty(elementID, "text-offsetX", inheritElementID)
        local offsetY = theme:GetElementProperty(elementID, "text-offsetY", inheritElementID)
        headerText:SetPoint("TOPLEFT", offsetX, offsetY)

        headerText:SetJustifyV(_JUSTIFY_V_FROM_ANCHOR[location])
        headerText:SetJustifyH(_JUSTIFY_H_FROM_ANCHOR[location])
      end
    end
  end

  __Arguments__ {}
  function RegisterFramesForThemeAPI(self)
    local class = Class.GetObjectClass(self)


    Theme:RegisterFrame(class._prefix..".frame", self.frame, "block.frame")
    Theme:RegisterFrame(class._prefix..".header", self.frame.header, "block.header")
    Theme:RegisterTexture(class._prefix..".stripe", self.frame.header.stripe, "block.stripe")
  end
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "id" { TYPE = String }
  property "text" { TYPE = String, DEFAULT = "Default Header Text", HANDLER = SetText}
  property "isActive" { TYPE = Boolean, DEFAULT = true, EVENT = "OnActiveChanged" }
  property "priority" { TYPE = Number, DEFAULT = 100, EVENT = "OnPriorityChanged" }

  __Static__() property "_THEME_CLASS_ID" { DEFAULT = "block" }
  __Static__() property "_prefix" { DEFAULT = "block" }
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  __Arguments__ { }
  function Block(self)
    super(self)

    local frame = CreateFrame("Frame")
    frame:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
    frame:SetBackdropBorderColor(0,0,0,0)

    local headerFrame = CreateFrame("Frame", nil, frame)
    headerFrame:SetPoint("TOPLEFT")
    headerFrame:SetPoint("TOPRIGHT")
    headerFrame:SetFrameStrata("HIGH")
    headerFrame:SetHeight(34) -- 24
    headerFrame:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
    headerFrame:SetBackdropBorderColor(0,0,0,0)
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

    -- Keep it in the cache for later.
    _BlockCache[self] = true
    -- Important: Always use 'This' to avoid issues when this class is inherited by
    -- other classes.
    RegisterFramesForThemeAPI(self)
    -- Important: Don't forgot 'This' as argument to this method !
    self:InitRefresh(Block)
  end

  __Arguments__{ String, Number }
  function Block(self, id, priority)
    self.id = id
    self.priority = priority

    this(self)
  end
endclass "Block"
-- ========================================================================== --
-- == OnLoad Handler
-- ========================================================================== --
function OnLoad(self)
  CallbackHandlers:Register("block/refresher", CallbackHandler(Block.RefreshAll), "refresher")
end
