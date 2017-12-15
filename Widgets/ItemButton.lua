--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio        "EskaQuestTracker.Widgets.ItemButton"                          ""
--============================================================================--
namespace "EQT"
import "System"
--============================================================================--
class "ItemButton" inherit "Frame" extend "IReusable"

  function GetID(self)
    return self.__id
  end

  function SetID(self, id)
    self.__id = id
  end

  function SetLink(self, link)
    self.__link = link
    self.frame:SetAttribute("item", link)
    self:UpdateTooltip()

  end

  function GetLink(self)
    return self.__link
  end

  function UpdateTooltip(self)
    self.frame:SetScript("OnEnter", function(btn)
          GameTooltip:SetOwner(btn, "ANCHOR_LEFT")
          GameTooltip:SetHyperlink(self:GetLink())
          GameTooltip:Show()
    end)
  end

  function SetTexture(self, texture)
    self.__texture = texture
    self.frame.texture:SetTexture(texture)
  end

  function Reset(self)
    self:Hide()
    self.frame:ClearAllPoints()
  end

  function SetCooldown(self, start, duration)
    self.frame.cooldown:SetCooldown(start, duration)
  end

  __Thread__()
  function RefreshRange(self)
    local frame = self.frame
    while frame:IsShown() do
      if self.__link and IsItemInRange(self.__link, "target") == false then
        frame.texture:SetVertexColor(1, 0, 0)
      else
        frame.texture:SetVertexColor(1, 1, 1)
      end
      Delay(0.1)
    end
  end


  __Static__() property "index" {
    Default = 1,
    Type = Number,
  }
  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "id" { TYPE = Number, DEFAULT = -1, Get="GetID", Set="SetID"}
  property "link" { Get="GetLink", Set="SetLink"}
  property "texture" { Get="GetTexture", Set="SetTexture"}

  function ItemButton(self)
    local name = "EQT-ItemButton"..ItemButton.index
    local frame = CreateFrame("Button", name, nil, "SecureActionButtonTemplate")
    frame:SetSize(32, 32)
    frame:SetAttribute("type","item")
    self.frame = frame

    local texture = frame:CreateTexture()
    texture:SetAllPoints()
    texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    frame.texture = texture

    local cooldown = CreateFrame("cooldown", nil, frame, "CooldownFrameTemplate")
    cooldown:SetAllPoints(texture)
    frame.cooldown = cooldown

    frame:SetScript("OnLeave", function(btn) GameTooltip:Hide() end)
    frame:SetScript("OnShow", function(btn) RefreshRange(self) end)
    frame:Hide()

    ItemButton.index = ItemButton.index + 1
  end
endclass "ItemButton"


function OnLoad(self)
  _ObjectManager:Register(ItemButton)
end
