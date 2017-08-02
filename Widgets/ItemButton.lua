-- ************************************************************************** **
--                       EskaQuestTracker                                     **
--                  All Rights Reserved - Skamer                              **
-- *************************************************************************  **
local _, EQT = ...
-- ========================================================================== --
Scorpio        "EskaQuestTracker.Widgets.ItemButton"                     "1.0.0"
-- ========================================================================== --
namespace "EQT"
import "System"

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

    frame:SetScript("OnLeave", function(btn) GameTooltip:Hide() end)



  end
endclass "ItemButton"

function OnLoad(self)
  _ObjectManager:Register(ItemButton)
end
