--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio           "EskaQuestTracker.Widgets.MenuContext"                      ""
--============================================================================--
namespace "EQT"
--============================================================================--

class "BaseMenuItem" inherit "Frame" extend "IReusable"

  function Reset(self)
    self:Hide()
    self:ClearAllPoints()

  end


  function BaseMenuItem(self)
    local frame = CreateFrame("Frame")
    self.frame = frame

    frame:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
    --frame:SetBackdropColor(1, 1, 1, 0.15)
    frame:SetBackdropColor(0, 0, 0, 0)
    frame:SetBackdropBorderColor(0, 0, 0, 0)
  end


endclass "BaseMenuItem"

class "MenuItem" inherit "BaseMenuItem"
  local function UpdateProps(self, new, old, prop)
    if prop == "text" then
      self.label:SetText(new)
    elseif prop == "icon" then
    elseif prop == "onClick" then
      if old == nil then
        self.btn:RegisterForClicks("LeftButtonUp")
      end

      if new == nil then
        self.btn:RegisterForClicks(nil)
      end
      self.btn:SetScript("OnClick", function() if not self.disabled then new(); _Addon.MenuContext:Hide() end end)
    elseif prop == "disabled" then
      if not new then
        self.frame:SetTextColor(1, 1, 1)
        self.frame:SetBackdropColor(0, 0, 0, 0)
      else
        self.label:SetTextColor(0.4, 0.4, 0.4)
        --self.frame:SetBackdropColor(0.35, 0.35, 0.35, 0.5)
      end
    end
  end

  function ShowIcon(self)

  end

  function HideIcon(self)

  end

  function Reset(self)
    Super.Reset(self)

    self.icon = nil
    self.text = nil
    self.onClick = nil
  end

  property "icon" { TYPE = String, DEFAULT = "", HANDLER = UpdateProps }
  property "text" { TYPE = String, DEFAULT = "", HANDLER = UpdateProps }
  property "onClick" { TYPE = Callable, DEFAULT = nil, HANDLER = UpdateProps }
  property "disabled" { TYPE = Boolean, DEFAULT = false, HANDLER = UpdateProps }

  function MenuItem(self)
    Super(self)

    local btn = CreateFrame("button", nil, self.frame)
    btn:SetAllPoints()
    --btn:SetBackdrop(_Backdrops.Common)
    --btn:SetBackdropBorderColor(0, 0, 0, 0)
    --btn:SetBackdropColor(0, 0, 0, 0)
    self.btn = btn

    local font = _LibSharedMedia:Fetch("font", "PT Sans Narrow Bold")


    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetText("")
    label:SetPoint("TOP")
    label:SetPoint("BOTTOM")
    label:SetPoint("RIGHT", -10, 0)
    label:SetPoint("LEFT", 10, 0)
    label:SetFont(font, 12)
    label:SetJustifyH("LEFT")
    self.label = label

    btn:SetScript("OnEnter", function(btn)
      if not self.disabled then
        self.frame:SetBackdropColor(0, 148/255, 1, 0.5)
        label:SetTextColor(1, 216/255, 0)
      end
    end)
    btn:SetScript("OnLeave", function(btn)
      if not self.disabled then
        self.frame:SetBackdropColor(0, 0, 0, 0)
        label:SetTextColor(1, 1, 1)
      end
    end)

    self.baseHeight = 24
    self.height = self.baseHeight
  end


endclass "MenuItem"


class "MenuItemSeparator" inherit "BaseMenuItem"

    function MenuItemSeparator(self)
      Super(self)

      self.frame:SetBackdropColor(1, 1, 1, 0.15)

      self.baseHeight = 2
      self.height = self.baseHeight
    end
endclass "MenuItemSeparator"


class "MenuContext" inherit "Frame"

  _ARROW_TEX_COORDS = {
    ["RIGHT"] = { left = 0, right = 32/128, top = 0, bottom = 1 },
    ["BOTTOM"] = { left = 32/128, right = 64/128, top = 0, bottom = 1 },
    ["LEFT"] = { left = 64/128, right = 96/128, top = 0, bottom = 1 },
    ["TOP"] = { left = 96/128, right = 1, top = 0, bottom = 1 }
  }

  _ARROW_POINTS = {
    ["RIGHT"] = { fromPoint = "RIGHT", toPoint = "LEFT", offsetX = 5, offsetY = 0},
    ["BOTTOM"] = { fromPoint = "BOTTOM", toPoint = "TOP", offsetX = 0, offsetY = -5 },
    ["LEFT"] = { fromPoint = "LEFT", toPoint = "RIGHT", offsetX = -5, offsetY = 0},
    ["TOP"] = { fromPoint = "TOP", toPoint = "BOTTOM", offsetX = 0, offsetY = 5}
  }


  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------
  local function UpdateProps(self, new, old, prop)
    if prop == "orientation" then
      self:UpdateArrowOrientation()
    end
  end

  __Arguments__ {}
  function UpdateArrowOrientation(self)
    local coords = _ARROW_TEX_COORDS[self.orientation]
    self.arrow:SetTexCoord(coords.left, coords.right, coords.top, coords.bottom)

    local p = _ARROW_POINTS[self.orientation]
    self.frame:ClearAllPoints()
    self.frame:SetPoint(p.fromPoint, self.arrow, p.toPoint, p.offsetX, p.offsetY)

    if self.destFrame then
      self:AnchorTo(self.destFrame)
    end
  end

  function AnchorTo(self, frame)
    self.arrow:ClearAllPoints()

    local relativePoint = _ARROW_POINTS[self.orientation].toPoint

    self.arrow:SetPoint(self.orientation, frame, relativePoint)

    if not self.destFrame or self.destFrame ~= frame then
      self.destFrame = frame
    end
  end

  __Arguments__ { BaseMenuItem }
  function AddItem(self, item)
    self.items:Insert(item)

    self:Draw()
  end

  __Arguments__ { String, Argument(String, true), Argument(Callable, true)}
  function AddItem(self, text, icon, onClick)
    local item
    -- code specific to EQT
    if _ObjectManager then
      item = _ObjectManager:Get(MenuItem)
    else
      item = MenuItem()
    end

    item.text = text
    item.icon = icon
    item.onClick = onClick
    This.AddItem(self, item)

    return item
  end

  function GetItem(self, id)

  end

  __Arguments__ {}
  function Draw(self)
    local previousFrame
    local height = 0

    for index, menuItem in self.items:GetIterator() do
      menuItem:ClearAllPoints()
      menuItem:SetParent(self.frame)
      menuItem.frame:Show()

      if index == 1 then
        menuItem.frame:SetPoint("TOPLEFT")
      else
        menuItem.frame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, 0)
      end
      menuItem.width = self.width

      previousFrame = menuItem.frame
      height = height + menuItem.height + 0
    end

    if height < self.baseHeight then
      self.height = self.baseHeight
    else
      self.height = height
    end
  end

  function Show(self)
    self.frame:Show()
    self.arrow:Show()
  end

  function Hide(self)
    self.frame:Hide()
    self.arrow:Hide()
  end

  function Clear(self)
    for index, item in self.items:GetIterator() do
      item.isReusable = true
      self.items[index] = nil
    end
  end

  property "orientation" { TYPE = String, DEFAULT = "RIGHT",  HANDLER = UpdateProps }


  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function MenuContext(self)
    Super(self)

    local arrow = UIParent:CreateTexture()
    --arrow:SetTexture([[Interface\AddOns\EskaQuestTracker\Media\Textures\Arrow]])
    --arrow:SetPoint("TOP", frame, "BOTTOM", 0, 4)

    arrow:SetTexture([[Interface\AddOns\EskaQuestTracker\Media\Textures\MenuContext-Arrow]])
    -- arrow:SetPoint("LEFT", frame, "RIGHT", -5, 40)
    arrow:SetPoint("CENTER", UIParent, "CENTER", 350, 350)
    arrow:SetSize(24, 24)
    arrow:SetVertexColor(0, 0, 0, 0.6)


    --local coords = _ARROW_TEX_COORDS["BOTTOM"]
    --arrow:SetTexCoord(coords.left, coords.right, coords.top, coords.bottom)
    -- arrow:SetSize(32, 20)
    self.arrow = arrow




    local frame = CreateFrame("Frame", "EQT-MenuContext", UIParent)
    self.frame = frame
    frame:SetBackdrop(_Backdrops.CommonWithBiggerBorder)
    frame:SetBackdropColor(0, 0, 0, 0.6)
    frame:SetBackdropBorderColor(0, 0, 0, 0)
    frame:SetFrameStrata("HIGH")
    -- frame:SetSize(125, 150)
    frame:SetPoint("RIGHT", arrow, "LEFT")

    --frame:SetScript("OnLeave", function() print("OnLeave") end)
    --frame:SetScript("OnEnter", function() print("OnEnter") end)


    frame:SetScript("OnShow", function()
      frame:SetScript("OnUpdate", function()
        if not self.destFrame then return end

        local offsetLeft = 0
        local offsetRight = 0

        if self.orientation == "RIGHT" then
          offsetRight = self.destFrame:GetLeft() - frame:GetRight()
        elseif self.orientation == "LEFT" then
          offsetLeft = self.destFrame:GetRight() - frame:GetLeft()
        end

        local isParentMouseOver = false
        if self.destFrame:GetParent() then
          isParentMouseOver = self.destFrame:GetParent():IsMouseOver()
        end

        if not frame:IsMouseOver(0, 0, offsetLeft, offsetRight) and not self.destFrame:IsMouseOver() and not isParentMouseOver then
          self:Hide()
        end
      end)
     end)

     frame:SetScript("OnHide", function()
       frame:SetScript("OnUpdate", nil)
     end)

    --frame:SetMovable(true)
    --frame:EnableMouse(true)
    --frame:RegisterForDrag("LeftButton")
    --frame:SetScript("OnDragStart", frame.StartMoving)
    --frame:SetScript("OnDragStop", frame.StopMovingOrSizing)


    self.width = 125
    self.baseHeight = 75

    self.height = self.baseHeight

    self.items = List()

    self:UpdateArrowOrientation()
    self.orientation = Options:Get("menu-context-orientation")
  end


endclass "MenuContext"



function OnLoad()
  _ObjectManager:Register(MenuItem)
  _ObjectManager:Register(MenuItemSeparator)

  Options:Register("menu-context-orientation", "RIGHT", "menuContext/setOrientation")

  local mc = MenuContext()
  mc:Hide()

  _Addon.MenuContext = mc

  -- Callback handlers
  CallbackHandlers:Register("menuContext/setOrientation", CallbackPropertyHandler(mc, "orientation"))

end
