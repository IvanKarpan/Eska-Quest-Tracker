--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio        "EskaQuestTracker.Widgets.ItemBarFrame"                        ""
--============================================================================--
namespace "EQT"
--============================================================================--
class "ItemBar" inherit "Frame"
  _ItemBarCache = setmetatable( {}, { __mode = "k"})
  ------------------------------------------------------------------------------
  --                                Handlers                                  --
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  function AddItem(self, id, link, texture)
    if self.items[id] then return end

    NoCombat(function()
      -- local questItem = _ObjectManager:GetQuestItem()
      local questItem = _ObjectManager:Get(ItemButton)
      self.items[id] = questItem

      questItem:Show()

      questItem.link = link
      questItem.texture = texture

      self:Draw()

      if not self.frame:IsShown() then
        self:Show()
      end
    end)
  end

  function RemoveItem(self, id)
    if not self.items[id] then return end

    NoCombat(function()
        local questItem = self.items[id]
        questItem.isReusable = true
        self.items[id] = nil

        self:Draw()

        if self.items.Values:ToList().Count == 0 then
          self:Hide()
          self.height = 0
        end
    end)
  end

  function Draw(self)
    local previousFrame
    local height = 0
    local width = 0
    local index = 0

    local inversePoint = {
      ["TOP"] = "BOTTOM",
      ["BOTTOM"] = "TOP",
      ["RIGHT"] = "LEFT",
      ["LEFT"] = "RIGHT"
    }


    local directionGrowth = Options:Get("item-bar-direction-growth")
    if directionGrowth == "DOWN" then
      directionGrowth = "BOTTOM"
    elseif directionGrowth == "UP" then
      directionGrowth = "TOP"
    end

      for id, questItem in self.items:GetIterator() do
        index = index + 1

        questItem:ClearAllPoints()
        questItem:SetParent(self.frame)
        questItem.frame:Show()
        if index == 1 then
          questItem.frame:SetPoint(inversePoint[directionGrowth])
          questItem.height = self.width - 2
          questItem.width = self.width - 2
        else
          questItem.frame:SetPoint(inversePoint[directionGrowth], previousFrame, directionGrowth, 0, -2)
          questItem.height = self.width - 2
          questItem.width = self.width - 2
        end

        previousFrame = questItem.frame
        height = questItem.height + 2
      end

    self.height = self.baseHeight + height
  end


  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  -- DOWN, UP, LEFT, RIGHT
  __Static__() property "directionGrowth" { DEFAULT = "DOWN" }

  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function ItemBar(self)
    super(self)

    local frame = CreateFrame("Frame", "EQT-ItemBar", UIParent, "SecureFrameTemplate")
    frame:SetPoint("CENTER")
    frame:SetBackdrop(_Backdrops.Common)
    frame:SetBackdropColor(0, 0, 0, 0.5)
    frame:SetBackdropBorderColor(0, 0, 0, 0)


    self.frame = frame
    self.height = 0
    self.width = 32

    self.items = Dictionary()
    self.baseHeight = 0

    self:Hide()

  end


endclass "ItemBar"


local function GetAnchorPoint(position, directionGrowth)
  local anchorPoints = {
    ["TOPLEFT"] = {
      ["HORIZONTAL"] = "BOTTOMLEFT",
      ["VERTICAL"] = "TOPRIGHT",
    },
    ["TOPRIGHT"] = {
      ["HORIZONTAL"] = "BOTTOMRIGHT",
      ["VERTICAL"] = "TOPLEFT",
    },
    ["BOTTOMLEFT"] = {
      ["HORIZONTAL"] = "TOPLEFT",
      ["VERTICAL"] = "BOTTOMRIGHT",
    },
    ["BOTTOMRIGHT"] = {
      ["HORIZONTAL"] = "TOPRIGHT",
      ["VERTICAL"] = "BOTTOMLEFT",
    }
  }

  if directionGrowth == "UP" or directionGrowth == "DOWN" then
    return anchorPoints[position]["VERTICAL"]
  elseif directionGrowth == "RIGHT" or directionGrowth == "LEFT" then
    return anchorPoints[position]["HORIZONTAL"]
  end
end

function OnLoad(self)
  local itemBar = ItemBar()
  _Addon.ItemBar = itemBar


  Options:Register("item-bar-position", "TOPLEFT", "itemBar/UpdateAllPosition")
  Options:Register("item-bar-direction-growth", "DOWN", "itemBar/UpdateAllPosition")
  Options:Register("item-bar-offset-x", -5, "itemBar/UpdateAllPosition")
  Options:Register("item-bar-offset-y", -20, "itemBar/UpdateAllPosition")

  CallbackHandlers:Register("itemBar/UpdateAllPosition", CallbackHandler(function()
    local position = Options:Get("item-bar-position")
    local offsetX = Options:Get("item-bar-offset-x")
    local offsetY = Options:Get("item-bar-offset-y")
    local directionGrowth = Options:Get("item-bar-direction-growth")
    _Addon.ItemBar.frame:ClearAllPoints()
    _Addon.ItemBar.frame:SetPoint(GetAnchorPoint(position, directionGrowth), _Addon.ObjectiveTracker.frame, position, offsetX, offsetY)
    _Addon.ItemBar:Draw()
  end))

  -- _Addon.ItemBar.frame:SetPoint("TOPRIGHT", _Addon.ObjectiveTracker, "TOPLEFT")

end

function OnEnable(self)
  local position = Options:Get("item-bar-position")
  local offsetX = Options:Get("item-bar-offset-x")
  local offsetY = Options:Get("item-bar-offset-y")
  local directionGrowth = Options:Get("item-bar-direction-growth")
  --_Addon.ItemBar.frame:SetPoint("TOPRIGHT", _Addon.ObjectiveTracker.frame, "TOPLEFT", -5, -20)
  _Addon.ItemBar.frame:SetPoint(GetAnchorPoint(position, directionGrowth), _Addon.ObjectiveTracker:GetFrameContainer(), position, offsetX, offsetY)
end


-- Update the items cooldown
__SystemEvent__()
function BAG_UPDATE_COOLDOWN(...)
    if not _Addon.ItemBar then
      return
    end

    for questID, itemButton in _Addon.ItemBar.items:GetIterator() do
      local start, duration, enable = GetQuestLogSpecialItemCooldown(GetQuestLogIndexByID(questID))
      if start then
        CooldownFrame_Set(itemButton.frame.cooldown, start, duration, enable)
        if duration > 0 and enable == 0 then
          itemButton.frame.texture:SetVertexColor(0.4, 0.4, 0.4)
        else
          itemButton.frame.texture:SetVertexColor(1, 1, 1)
        end
      end
    end
end
