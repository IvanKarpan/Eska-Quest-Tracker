--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio         "EskaQuestTracker.Supports.GroupFinders"                      ""
--============================================================================--
namespace "EQT"
--============================================================================--
RemoveListing           = C_LFGList.RemoveListing
CreateListing           = C_LFGList.CreateListing
GetActivityIDForQuestID = C_LFGList.GetActivityIDForQuestID


class "GroupFinderAddon"

  _Addons = {}

  __Arguments__{ Number }
  function JoinGroup(self, questID)
    Debug("Join group for the quest #%i", questID)
  end

  __Arguments__ {}
  function LeaveGroup(self)
    Debug("Leave group for the quest")
    if IsInGroup() then
      LeaveParty()
    end
  end

  __Arguments__ { Number }
  function CreateGroup(self, questID)
    Debug("Create group for the quest #%i", questID)
  end

  __Arguments__ {}
  function DelistGroup()
    Debug("Delist the group")
    RemoveListing()
  end



  __Static__()
  function Register(self, name, addon)
    _Addons[name] = addon

    --if not _DB.currentGroupFinderAddon then
      --_DB.currentGroupFinderAddon = name
    --end

    Database:SelectRoot()
    if not Database:GetValue("currentGroupFinderAddon") then
      Database:SetValue("currentGroupFinderAddon", name)
    end
  end

  __Static__()
  function Get(self, name )
    return _Addons[name]
  end

  __Static__() __Arguments__{ Class }
  function GetIterator()
    return pairs(_Addons)
  end

  __Static__() __Arguments__ { Class }
  function GetSelected(self)
    Database:SelectRoot()
    local currentGFA = Database:GetValue("currentGroupFinderAddon")

    local firstName = ""
    local firstObject
    for name, groupFinder in self:GetIterator() do
      firstObject = groupFinder
      firstName = name
      if name == currentGFA then
        return groupFinder, name
      end
    end

    return firstObject, firstName
  end

  __Static__() __Arguments__ { Class, String }
  function SetSelected(self, name)
    Database:SelectRoot()
    Database:SetValue("currentGroupFinderAddon", name)
  end


  function GroupFinderAddon(self)

  end

endclass "GroupFinderAddon"

--------------------------------------------------------------------------------
--                         Extend the API                                     --
--------------------------------------------------------------------------------
__Final__()
interface "GroupFinder"

  -- Create a group for the id (e.g, quest id or world quest id)
  -- in using the current group finder.
  function CreateGroup(self, id)
    local addon = GroupFinderAddon:GetSelected()
    if addon then
      addon:CreateGroup(id)
    end
  end

  -- Leave the group for the id (e.g, quest id or world quest id)
  -- in using the current group finder.
  function LeaveGroup(self)
    local addon = GroupFinderAddon:GetSelected()
    if addon then
      addon:LeaveGroup()
    end
  end

  -- Join a group for the id (e.g, quest id or world quest id)
  -- in using the current group finder.
  function JoinGroup(self, id)
    local addon = GroupFinderAddon:GetSelected()
    if addon then
      addon:JoinGroup(id)
    end
  end

  -- Delist the group for the id (e.g, quest id or world quest id)
  -- in using the current group finder.
  function DelistGroup(self)
    local addon = GroupFinderAddon:GetSelected()
    if addon then
      addon:DelistGroup()
    end
  end

endinterface "GroupFinder"
--============================================================================--
--                      World Quest Group Finder
--        https://mods.curse.com/addons/wow/worldquestgroupfinder
--============================================================================--
class "WorldQuestGroupFinderAddon" inherit "GroupFinderAddon"

  __Arguments__ { Number }
  function JoinGroup(self, questID)
    Super.JoinGroup(self, questID)

    WorldQuestGroupFinder.InitSearchProcess(questID, false, false, true)
  end

  __Arguments__ { Number }
  function CreateGroup(self, questID)
    Super.CreateGroup(self, questID)

    WorldQuestGroupFinder.CreateGroup(questID)
  end

  function WorldQuestGroupFinderAddon(self)
    Super(self)
  end

endclass "WorldQuestGroupFinderAddon"

--============================================================================--
--                      World Quest Assistant
--        https://mods.curse.com/addons/wow/266373-worldquestassistant
--============================================================================--
class "WorldQuestAssistantAddon" inherit "GroupFinderAddon"

  __Arguments__ { Number }
  function JoinGroup(self, questID)
    WQA:FindQuestGroups(questID)
  end

  __Arguments__ { Number }
  function CreateGroup(self, questID)
    WQA:CreateQuestGroup(questID)
  end

  __Arguments__ { Number }
  function LeaveGroup()
    WQA:MaybeLeaveParty()
  end

  function WorldQuestAssistantAddon()
    Super(self)
  end

endclass "WorldQuestAssistantAddon"
--============================================================================--
--                      World Quest Tracker
--        https://mods.curse.com/addons/wow/266373-worldquestassistant
--============================================================================--
class "WorldQuestTrackerAddon" inherit "GroupFinderAddon"

  __Arguments__ { Number }
  function JoinGroup(self, questID)
    _G["WorldQuestTrackerAddon"].FindGroupForQuest(questID)
  end

  __Arguments__ { Number }
  function CreateGroup(self, questID)
    Super.JoinGroup(self, questID)
    -- @NOTE World Quest Tracker addon doesn't provide a function could be called to create the group
    -- I put here the local function content.
    local questName
    local rarity

    if QuestUtils_IsQuestWorldQuest(questID) then
      questName  = C_TaskQuest.GetQuestInfoByQuestID(questID)
      rarity = select(4, GetQuestTagInfo(questID))
    else
      questName = GetQuestLogTitle(GetQuestLogIndexByID(questID))
    end

    local pvpType = GetZonePVPInfo()
    local pvpTag
    if (pvpType == "contested") then
      pvpTag = "@PVP"
    else
      pvpTag = ""
    end

    local groupDesc = "Doing world quest " .. questName .. ". Group created with World Quest Tracker. @ID" .. questID .. pvpTag

    local itemLevelRequired = 0
    local honorLevelRequired = 0
    local isAutoAccept = true
    local isPrivate = false

    CreateListing(GetActivityIDForQuestID(questID) or 469, "", itemLevelRequired, honorLevelRequired, "", groupDesc, isAutoAccept, isPrivate, questID)

    --> if is an epic quest, converto to raid
    if rarity and rarity == LE_WORLD_QUEST_QUALITY_EPIC then
      C_Timer.After (2, function() ConvertToRaid(); end) --print ("party converted")
    end

  end

  function WorldQuestTrackerAddon()
    Super(self)
  end

endclass "WorldQuestTrackerAddon"

--------------------------------------------------------------------------------
--  Register the group finder addons when they are loaded                     --
--------------------------------------------------------------------------------
Scorpio.Continue(
    function()
        while Scorpio.Event("ADDON_LOADED") ~= "WorldQuestGroupFinder" do end
        GroupFinderAddon:Register("WorldQuestGroupFinder", WorldQuestGroupFinderAddon())
    end
)

Scorpio.Continue(
    function()
        while Scorpio.Event("ADDON_LOADED") ~= "WorldQuestAssistant" do end
        GroupFinderAddon:Register("WorldQuestAssistant", WorldQuestAssistantAddon())
    end
)

Scorpio.Continue(
    function()
        while Scorpio.Event("ADDON_LOADED") ~= "WorldQuestTracker" do end
        GroupFinderAddon:Register("WorldQuestTracker", WorldQuestTrackerAddon())
    end
)


--[[
__SlashCmd__ "debuggfs" "join"
function DebugJoinGroup()
  if _GroupFinder then
    _GroupFinder:JoinGroup(42177)
  end
end

__SlashCmd__ "debuggfs" "leave"
function DebugLeaveGroup()
  if _GroupFinder then
    _GroupFinder:LeaveGroup()
  end
end

__SlashCmd__ "debuggfs" "create"
function DebugCreateGroup()
  if _GroupFinder then
    _GroupFinder:CreateGroup(42177)
  end
end

__SlashCmd__ "debuggfs" "unlist"
function DebugUnlistGroup()
  if _GroupFinder then
    _GroupFinder:DelistGroup()
  end
end
--]]
