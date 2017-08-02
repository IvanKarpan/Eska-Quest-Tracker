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

    --[[
    -- @TODO Do the directionnal growth
    local directionGrowth = ItemBar.directionGrowth
    if directionGrowth == "DOWN" or directionGrowth == "UP" then

    elseif directionGrowth == "LEFT" or directionGrowth == "RIGHT" then

    end
    --]]

      for id, questItem in self.items:GetIterator() do
        index = index + 1

        questItem:ClearAllPoints()
        questItem:SetParent(self.frame)
        questItem.frame:Show()
        if index == 1 then
          questItem.frame:SetPoint("TOP")
          questItem.height = self.width - 2
          questItem.width = self.width - 2
        else
          questItem.frame:SetPoint("TOP", previousFrame, "BOTTOM", 0, -2)
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
    Super(self)

    local frame = CreateFrame("Frame", "EQT-ItemBar", UIParent)
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

function OnLoad(self)
  local itemBar = ItemBar()
  _Addon.ItemBar = itemBar

  -- _Addon.ItemBar.frame:SetPoint("TOPRIGHT", _Addon.ObjectiveTracker, "TOPLEFT")

end

function OnEnable(self)
  _Addon.ItemBar.frame:SetPoint("TOPRIGHT", _Addon.ObjectiveTracker.frame, "TOPLEFT", -5, -20)
end
