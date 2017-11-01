-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio            "EskaQuestTracker.Options.Achievements"                     ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
--[[_Categories.Achievements = {
  type = "group",
  name = "Achievements",
  order = 3,
  childGroups = "tab",
  args = {

    hideCriteriaCompleted = {
      type = "toggle",
      name = "Hide completed criteria",
      order = 1,
      width = "full",
      get = function() return Options:Get("achievement-hide-criteria-completed") end,
      set = function(_, value) Options:Set("achievement-hide-criteria-completed", value) end
    },
    maxCriteriaDisplayed = {
      type = "range",
      name = "Max criteria displayed",
      order = 2,
      step = 1,
      softMax = 10,
      desc = "0: means no limit",
      get = function() return Options:Get("achievement-max-criteria-displayed") end,
      set = function(_, value) Options:Set("achievement-max-criteria-displayed", value) end
    },
    showDesc = {
      type = "toggle",
      name = "Show description",
      order = 3,
      width = "full",
      get = function() return Options:Get("achievement-show-description") end,
      set = function(_, value) Options:Set("achievement-show-description", value) end
    },
  }
} --]]

function OnLoad(self)
  self:RegisterCategory("Achievements", "Achievements", 30, BuildAchievementsCategory)
end

function BuildAchievementsCategory(content)
  -- [OPTIONS] Hide Criteria completed
  local hideCriteriaCompleted = _AceGUI:Create("CheckBox")
  hideCriteriaCompleted:SetLabel("Hide completed Criteria")
  hideCriteriaCompleted:SetValue(Options:Get("achievement-hide-criteria-completed"))
  hideCriteriaCompleted:SetCallback("OnValueChanged", function(_, _, hide) Options:Set("achievement-hide-criteria-completed", hide) end)
  content:AddChild(hideCriteriaCompleted)

  -- [OPTIONS] Max Criteria displayed
  local maxCriteriaDisplayed = _AceGUI:Create("Slider")
  maxCriteriaDisplayed:SetLabel("Max criteria displayed")
  maxCriteriaDisplayed:SetValue(Options:Get("achievement-max-criteria-displayed"))
  maxCriteriaDisplayed:SetSliderValues(0, 20, 1)
  maxCriteriaDisplayed:SetCallback("OnValueChanged", function(_, _, amount) Options:Set("achievement-max-criteria-displayed", amount) end)
  content:AddChild(maxCriteriaDisplayed)

  -- [OPTIONS] Show description
  local showDesc = _AceGUI:Create("CheckBox")
  showDesc:SetLabel("Show Description")
  showDesc:SetValue(Options:Get("achievement-show-description"))
  showDesc:SetCallback("OnValueChanged", function(_, _, show) Options:Set("achievement-show-description", show) end)
  content:AddChild(showDesc)
end
