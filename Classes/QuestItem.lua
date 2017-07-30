--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio              "EskaQuestTracker.Classes.QuestItem"                     ""
--============================================================================--
namespace "EQT"
--============================================================================--
class "QuestItem" extend "IFrame" "IReusable"
  _QuestItemCount = 1
  ------------------------------------------------------------------------------
  --                                   Methods                                --
  ------------------------------------------------------------------------------
  function GetLink(self)
    return self.__link
  end

  function SetLink(self, link)
    self.__link = link
  end

  function GetTexture(self)
    return self.__texture
  end

  function SetTexture(self, texture)
    self.__texture = texture
    self.frame.tex:SetTexture(texture)
  end

  function UpdateTooltip(self)
    self.frame:SetScript("OnEnter", function(btn)
          GameTooltip:SetOwner(btn, "ANCHOR_LEFT")
          GameTooltip:SetHyperlink(self:GetLink())
          GameTooltip:Show()
    end)
  end

  function Reset(self)
    self:SetParent(nil)
    self:ClearAllPoints()
    self:Hide()
  end


  ------------------------------------------------------------------------------
  --                            Properties                                    --
  ------------------------------------------------------------------------------
  property "link" { Get="GetLink", Set="SetLink"}
  property "texture" { Get="GetTexture", Set="SetTexture"}
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function QuestItem(self)
    local index = _QuestItemCount
    local name = "EQTQuestItem" .. index

    --local btn = CreateFrame("Button", name, nil, "SecureActionButtonTemplate")
    local btn = CreateFrame("Frame")
    --btn:RegisterForClicks("AnyUp")
    --btn:SetAttribute("type","item")
    --btn:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    btn:SetHeight(26)
    btn:SetWidth(26)

    local tex = btn:CreateTexture()
    tex:SetAllPoints()
    --tex:SetSize(32, 32)
    tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    btn.tex = tex


    self.frame = btn
    --self:SetSize(32, 32)
    self.height = 26
    self.baseHeight = self.height

    _QuestItemCount = _QuestItemCount + 1

  end

endclass "QuestItem"
--============================================================================--
-- OnLoad Handler
--============================================================================--
function OnLoad(self)
  --[[_DB:SetDefault("Quest", {
     QuestItem = {
      textColor = { r = 1, g = 0.38, b = 0 },
      textSize = 12,
      textFont = "PT Sans Narrow Bold",
      textTransform = "uppercase", -- none, lowercase
    }
  })--]]
  -- Register this class in the object manager
  _ObjectManager:Register(QuestItem)
end
