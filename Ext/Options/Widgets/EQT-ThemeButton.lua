--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio      "EskaQuestTracker.Options.widgets.ThemeButton"                   ""
--============================================================================--

local Type, Version = "EQT-ThemeButton", 1

local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

--------------------------------------------------------------------------------
-------------------------------  SCRIPTS  --------------------------------------
--------------------------------------------------------------------------------
local function Button_OnClick(frame, ...)
  AceGUI:ClearFocus()
  frame.obj:Fire("OnClick", ...)
end

local function Button_OnEnter(frame)
  frame.obj:Fire("OnEnter")
end

local function Button_OnLeave(frame)
  frame.obj:Fire("OnLeave")
end


local methods = {
  ["OnAcquire"] = function(self)
    self:SetHeight(50)
    self:SetWidth(200)
  end,
  ["SetAuthor"] = function(self, Author)

  end,
  ["SetName"] = function(self, name)

  end,
}

local function Constructor()
  local frame = CreateFrame("Button")
  frame:SetBackdrop(_Backdrops.Common)
  frame:SetBackdropColor(0.75, 0.75, 0.75, 0.35)
  frame:SetBackdropBorderColor(0, 0, 0, 0)
  frame:EnableMouse(true)

  frame:SetScript("OnClick", Button_OnClick)
  frame:SetScript("OnEnter", Button_OnEnter)
  frame:SetScript("OnLeave", Button_OnLeave)

  local name = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  name:SetPoint("TOP")
  name:SetText("Theme name")
  name:SetTextColor(0.9, 0.9, 0.9)

  local author = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  author:SetPoint("BOTTOMLEFT")
  author:SetText("By Skamer")
  author:SetTextColor(1, 0, 0)

  local version = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  version:SetPoint("BOTTOMRIGHT")
  version:SetText("1.0.1 |cfff000ff(alpha)|r")
  version:SetTextColor(1, 1, 0)


  local widget = {
    frame = frame,
    name = name,
    type = Type
  }


  for method, func in pairs(methods) do
    widget[method] = func
  end

  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
