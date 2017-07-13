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

class "ItemButton" extend "IReusable"

  function GetID(self)
    return self.__id
  end

  function SetID(self, id)
    self.__id = id
  end

  function SetLink(self, link)
    self.link = link
    frame:SetAttribute("item", link)

  end

  function SetTexture(self, texture)
    self.texture = texture
    self.frame.texture:SetTexture(texture)
  end


  __Static__() property "index" {
    Default = 1,
    Type = Number,
  }

  property "id" { TYPE = Number, DEFAULT = -1, Get="GetID", Set="SetID"}

  function ItemButton(self)
    local name = "EQT-ItemButton"..self.index
    local frame = CreateFrame("Button", name, nil, "SecureActionButtonTemplate")
    frame:SetSize(32, 32)
    frame:SetAttribute("type","item")
    self.frame = frame

    local texture = btn:CreateTexture()
    texture:SetAllPoints()
    texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    frame.texture = texture

    frame:SetScript("OnEnter", function(btn)
      GameTooltip:SetOwner(btn, "ANCHOR_LEFT")
      GameTooltip:SetHyperlink(self.link)
      GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function(btn)
      GameTooltip:Hide()

    end)



  end
endclass "ItemButton"
