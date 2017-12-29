--============================================================================--
--                          Eska Quest Tracker                                --
-- @Author  : Skamer <https://mods.curse.com/members/DevSkamer>               --
-- @Website : https://wow.curseforge.com/projects/eska-quest-tracker          --
--============================================================================--
Scorpio                   "EskaQuestTracker.API"                              ""
--============================================================================--
namespace "EQT"
--============================================================================--
import "System.Serialization"
import "System.Collections"
import "System.Reflector"
--============================================================================--
_COMPRESSER = LibStub:GetLibrary("LibCompress")
_ENCODER    = _COMPRESSER:GetAddonEncodeTable()

bit_band   = bit.band
bit_lshift = bit.lshift
bit_rshift = bit.rshift
--============================================================================--

--------------------------------------------------------------------------------
--                       Callbakc Handler Classes                             --
--------------------------------------------------------------------------------

class "CallbackHandler"
  property "func" { TYPE = Callable + String }

  function __call(self, ...)
    self.func(...)
  end

  __Arguments__ { Callable + String }
  function CallbackHandler(self, func)
    self.func = func
  end

endclass "CallbackHandler"

class "CallbackObjectHandler" inherit "CallbackHandler"
  property "obj" { TYPE = Class + Table}

  function __call(self, ...)
    if type(self.func) == "string" then
      local f = self.obj[self.func]
      if f then
        f(self, ...)
      end
    else
      self.func(self.obj, ...)
    end
  end

  __Arguments__ { Class + Table, Callable + String }
  function CallbackObjectHandler(self, obj, func)
    self.obj = obj

    Super(self, func)
  end

endclass "CallbackObjectHandler"

class "CallbackPropertyHandler" inherit "CallbackObjectHandler"
  function __call(self, value)
    if self.obj[self.func] then
      self.obj[self.func] = value
    end
  end

  __Arguments__ { Class + Table, String }
  function CallbackPropertyHandler(self, obj, property)
    Super(self, obj, property)
  end
endclass "CallbackPropertyHandler"


class "CallbackHandlers"
  CALLBACK_HANDLERS = Dictionary()
  CALLBACK_HANDLERS_GROUPS = Dictionary()

  __Static__() __Arguments__ { Class, String, CallbackHandler, { Type = String, Nilable = true, IsList = true }}
  function Register(self, id, handler, ...)
    local numGroup = select("#", ...)
    for i = 1, numGroup do
      local groupName = select(i, ...)
      if not CALLBACK_HANDLERS_GROUPS[groupName] then
        local handlers = setmetatable( {}, { __mode = "v" })
        handlers[id] = handler
        CALLBACK_HANDLERS_GROUPS[groupName] = handlers
      else
        CALLBACK_HANDLERS_GROUPS[groupName][id] = handler
      end
    end

    CALLBACK_HANDLERS[id] = handler
  end


  __Static__() __Arguments__ { Class, { Type = String, Nilable = true, IsList = true } }
  function CallGroup(self, ...)
    local numGroup = select("#", ...)
    for i = 1, numGroup do
      local groupName = select(i, ...)
      local handlers = CALLBACK_HANDLERS_GROUPS[groupName]
      if handlers then
        for id, handler in pairs(handlers) do
          handler()
        end
      end
    end
  end

  function CallAll(self)

  end

  __Static__() __Arguments__ { Class, String, { Type = Any, Nilable = true, IsList = true } }
  function Call(self, id, ...)
    local handler = CALLBACK_HANDLERS[id]
    if handler then
      handler(...)
    end
  end

endclass "CallbackHandlers"

--------------------------------------------------------------------------------
--                         Database                                           --
--------------------------------------------------------------------------------



class "Database"

  CURRENT_TABLE = nil
  CURRENT_PARENT_TABLE = nil
  CURRENT_LEVEL = 0
  CURRENT_TABLE_NAME = nil


  class "Migration"
        function Up(self)
            -- Migrate the DB to version 8 (>=1.0.1)
        end

        function Down(self)
            -- Downgrade the DB to version
        end

  endclass "Migration"

  __Static__() __Arguments__{ Class, Any, Argument(Any, true) }
  function SetValue(self, index, value)
    CURRENT_TABLE[index] = value

  end

  __Static__() __Arguments__ { Class, Any }
  function GetValue(self, index)
    return CURRENT_TABLE[index]
  end


  __Arguments__ { Class }
  __Static__() function IterateTable(self)
    return pairs(CURRENT_TABLE)
  end

  __Arguments__ { Class }
  __Static__() function Clean()
    local function ClearEmptyTables(t)
      for k,v in pairs(t) do
        if type(v) == "table" then
          ClearEmptyTables(v)
          if next(v) == nil then
            t[k] = nil
          end
        end
      end
    end

      ClearEmptyTables(EskaQuestTrackerDB)
  end

  __Static__() __Arguments__ { Class, { Type = String, Nilable = true, IsList = true } }
  function MoveTable(self, ...)
    local function deepcopy(orig)
      local orig_type = type(orig)
      local copy
      if orig_type == 'table' then
          copy = {}
          for orig_key, orig_value in next, orig, nil do
              copy[deepcopy(orig_key)] = deepcopy(orig_value)
          end
          setmetatable(copy, deepcopy(getmetatable(orig)))
      else -- number, string, boolean, etc
          copy = orig
      end
      return copy
    end

    local copy = deepcopy(CURRENT_TABLE)
    local oldTable = CURRENT_TABLE
    local tables = { ... }
    local destName = tables[#tables]
    tables[#tables] = nil

    self:SelectRoot()

    if #tables > 0 then
      if self:SelectTable(true, unpack(tables)) then
        Database:SetValue(destName, copy)
        wipe(oldTable)
      end
    end
  end

  __Static__() __Arguments__ { Class, { Type = String, Nilable = true, IsList = true } }
  function CopyTable(self, ...)
    local function deepcopy(orig)
      local orig_type = type(orig)
      local copy
      if orig_type == 'table' then
          copy = {}
          for orig_key, orig_value in next, orig, nil do
              copy[deepcopy(orig_key)] = deepcopy(orig_value)
          end
          setmetatable(copy, deepcopy(getmetatable(orig)))
      else -- number, string, boolean, etc
          copy = orig
      end
      return copy
    end

    local copy = deepcopy(CURRENT_TABLE)
    local tables = { ... }
    local destName = tables[#tables]
    tables[#tables] = nil

    self:SelectRoot()
    if #tables > 0 then
      if self:SelectTable(true, unpack(tables)) then
        Database:SetValue(destName, copy)
      end
    end
  end

__Arguments__ { Class }
__Static__() function DeleteTable(self)
  wipe(CURRENT_TABLE)
  self:SelectRoot()
end

  __Static__() __Arguments__{ Class, { Type = String, Nilable = true, IsList = true } }
  function SelectTable(self, ...)
    return self:SelectTable(true, ...)
  end

  __Static__() __Arguments__ { Class, Boolean, { Type = String, Nilable = true, IsList = true } }
  function SelectTable(self, mustCreateTables, ...)
    local count = select("#", ...)

    if not CURRENT_TABLE then
      CURRENT_TABLE = self:Get()
    end
    local tb = CURRENT_TABLE
    for i = 1, count do
      local indexTable = select(i, ...)
        if not tb[indexTable] then
          if mustCreateTables then
            tb[indexTable] = {}
          else
            return false
          end
        end

        if i > 1 then
          CURRENT_PARENT_TABLE = tb
        end

        tb = tb[indexTable]
        CURRENT_LEVEL = CURRENT_LEVEL + 1
        CURRENT_TABLE_NAME = indexTable
    end
    CURRENT_TABLE = tb

    return true
  end

  __Static__() __Arguments__{ Class }
  function SelectRoot(self)
    CURRENT_TABLE = self:Get()
    CURRENT_LEVEL = 0
  end

  __Static__() __Arguments__{ Class }
  function SelectRootChar(self)
    CURRENT_TABLE = self:GetChar()
    CURRENT_LEVEL = 0
  end

  __Static__() __Arguments__ { Class }
  function SelectRootSpec(self)
    CURRENT_TABLE = self:GetSpec()
    CURRENT_LEVEL = 0
  end

  __Static__() __Arguments__ { Class, Number }
  function SetVersion(self, version)
    if self:Get() then
      self:Get().dbVersion = version
    end
  end

  __Static__() __Arguments__ { Class }
  function GetVersion(self)
    if self:Get() then return self:Get().dbVersion end
  end

  __Static__() __Arguments__ { Class }
  function Get(self)
    return _DB
  end

  __Static__() __Arguments__ { Class }
  function GetChar(self)
    return _DB.Char
  end

  __Static__() __Arguments__ { Class }
  function GetSpec(self)
    return _DB.Char.Spec
  end


endclass "Database"

--------------------------------------------------------------------------------
--                         Options                                            --
--------------------------------------------------------------------------------
class "Option"
  property "id" { Type = String }
  property "default" { Type = Any }
  property "func" { Type = Callable + String }

  function __call(self, ...)
    if self.func then
      if type(self.func) == "string" then
        CallbackHandlers:Call(self.func, ...)
      else
        self.func(...)
      end
    end
  end

  __Arguments__ { String,  Any, Argument(Callable + String, true, nil) }
  function Option(self, id,  default, func)
    self.id = id
    self.default = default
    self.func = func
  end

endclass "Option"


class "Options"
OPTIONS = Dictionary()

__Static__() __Arguments__ { Class }
function SelectCurrentProfile(self)
  -- Get the current profile for this character
  local dbUsed = self:GetCurrentProfile()

  if dbUsed == "spec" then
    Database:SelectRootSpec()
  elseif dbUsed == "char" then
    Database:SelectRootChar()
  else
    Database:SelectRoot()
  end
end


__Static__() __Arguments__ { Class, String }
function Get(self, option)
  -- select the current profile (global, char or spec)
  self:SelectCurrentProfile()

  if Database:SelectTable(false, "options") then
    local value = Database:GetValue(option)
    if value ~= nil then
      return value
    end
  end

  if OPTIONS[option] then
    return OPTIONS[option].default
  end
end

__Static__() __Arguments__ { Class, String }
function Exists(self, option)
    -- select the current profile (global, char or spec)
    self:SelectCurrentProfile()

    if Database:SelectTable(false, "options") then
      local value = Database:GetValue(option)
      if value then
        return true
      end
    end
    return false
end

__Static__() __Arguments__ { Class, String, Argument(Any, true, nil), Argument(Boolean, true, true), Argument(Boolean, true, true)}
function Set(self, option, value, useHandler, passValue)
  -- select the current profile (global, char or spec)
  self:SelectCurrentProfile()

  Database:SelectTable("options")
  Database:SetValue(option, value)

  -- Call the handler if needed
  if useHandler then
    local opt = OPTIONS[option]
    if opt then
      if passValue then
        opt(value)
      else
        opt()
      end
    end
  end
end


__Static__() __Arguments__ { Class, String, Any, Argument(Callable + String, true, nil) }
function Register(self, option, default, func)
  self:Register(Option(option, default, func))
end

__Static__() __Arguments__ { Class, Option }
function Register(self, option)
    OPTIONS[option.id] = option
end

__Static__() __Arguments__ { Class, Argument(String, true, "global") }
function SelectProfile(self, profile)
  Database:SelectRoot()
  Database:SelectTable("dbUsed")

  local name, realm = UnitFullName("player")
  name = realm .. "-" .. name

  Database:SetValue(name, profile)
end

__Static__() __Arguments__ { Class }
function GetCurrentProfile(self)
  Database:SelectRoot()
  if Database:SelectTable(false, "dbUsed") then
    local name  = UnitFullName("player")
    local realm = GetRealmName()
    name = realm .. "-" .. name
    local dbUsed = Database:GetValue(name)
    if dbUsed then
      return dbUsed
    end
  end
  return "global"
end


__Arguments__ { Class, String }
function ResetOption(self, id)
    self:Set(id, nil)
end

function ResetAllOptions(self)

end


endclass "Options"

--------------------------------------------------------------------------------
--                   Serializable container                                   --
--    Credit goes to Kurapice on the SList,SDictionnary and Stack code        --
--------------------------------------------------------------------------------
__SimpleClass__() __Serializable__()
class "SList" inherit "List" extend "ISerializable"

  function Serialize(self, info)
    for i, v in ipairs(self) do
      info:SetValue(i, v)
    end
  end

  __Arguments__{ SerializationInfo }
    function SList(self, info)
      local i = 1
      local v = info:GetValue(i)
      while v ~= nil do
        rawset(self, i, v)
        i = i + 1
        v = info:GetValue(i)
      end
    end

  endclass "SList"

  __SimpleClass__() __Serializable__()
  class "SDictionary" inherit "Dictionary" extend "ISerializable"

    function Serialize(self, info)
      local keys = SList()
      local vals = SList()

      for k, v in pairs(self) do
        keys:Insert(k)
        vals:Insert(v)
      end

      info:SetValue(1, keys, SList)
      info:SetValue(2, vals, SList)
    end

    __Arguments__{ SerializationInfo }
    function SDictionary(self, info)
      local keys = info:GetValue(1, SList)
      local vals = info:GetValue(2, SList)

      This(self, keys, vals)
    end

  endclass "SDictionary"
  class "Stack" (function (_ENV)
      extend "Iterable"

      function Push(self, item)
          table.insert(self, item)
      end

      function Pop(self, item)
          return table.remove(self)
      end

      function GetIterator(self)
          return ipairs(self)
      end
  end)
--------------------------------------------------------------------------------
--                              API                                           --
--                    Contains some useful functions                          --
--------------------------------------------------------------------------------
__Final__()
interface "API"
  do

    function Trim(self, str)
      return str:gsub("%s+", "")
    end


    -- The below code is based on the Encode7Bit and encodeB64 from LibCompress
    -- and WeakAuras 2
    -- Credits go to Golmok (galmok@gmail.com) and WeakAuras author.
    local byteToBase64 = {
      [0]="A","B","C","D","E","F","G","H",
      "I","J","K","L","M","N","O","P",
      "Q","R","S","T","U","V","W","X",
      "Y","Z","a","b","c","d","e","f",
      "g","h","i","j","k","l","m","n",
      "o","p","q","r","s","t","u","v",
      "w","x","y","z","0","1","2","3",
      "4","5","6","7","8","9","-","_"
    }

    local base64ToByte = {
      A =  0,  B =  1,  C =  2,  D =  3,  E =  4,  F =  5,  G =  6,  H =  7,
      I =  8,  J =  9,  K = 10,  L = 11,  M = 12,  N = 13,  O = 14,  P = 15,
      Q = 16,  R = 17,  S = 18,  T = 19,  U = 20,  V = 21,  W = 22,  X = 23,
      Y = 24,  Z = 25,  a = 26,  b = 27,  c = 28,  d = 29,  e = 30,  f = 31,
      g = 32,  h = 33,  i = 34,  j = 35,  k = 36,  l = 37,  m = 38,  n = 39,
      o = 40,  p = 41,  q = 42,  r = 43,  s = 44,  t = 45,  u = 46,  v = 47,
      w = 48,  x = 49,  y = 50,  z = 51,["0"]=52,["1"]=53,["2"]=54,["3"]=55,
      ["4"]=56,["5"]=57,["6"]=58,["7"]=59,["8"]=60,["9"]=61,["-"]=62,["_"]=63
    }
    local encodeBase64Table = {}

    function EncodeToBase64(self, data)
      local base64 = encodeBase64Table
      local remainder = 0
      local remainderLength = 0
      local encodedSize = 0
      local lengh = #data

      for i = 1, lengh do
        local code = string.byte(data, i)
        remainder = remainder + bit_lshift(code, remainderLength)
        remainderLength = remainderLength + 8
        while remainderLength >= 6 do
          encodedSize = encodedSize + 1
          base64[encodedSize] = byteToBase64[bit_band(remainder, 63)]
          remainder = bit_rshift(remainder, 6)
          remainderLength = remainderLength - 6
        end
      end

      if remainderLength > 0 then
        encodedSize = encodedSize + 1
        base64[encodedSize] = byteToBase64[remainder]
      end
      return table.concat(base64, "", 1, encodedSize)
    end

    local decodeBase64Table = {}

    function DecodeFromBase64(self, data)
      local bit8 = decodeBase64Table
      local decodedSize = 0
      local ch
      local i = 1
      local bitfieldLenght = 0
      local bitfield = 0
      local lenght = #data

      while true do
        if bitfieldLenght >= 8 then
          decodedSize = decodedSize + 1
          bit8[decodedSize] = decodedSize + 1
          bit8[decodedSize] = string.char(bit_band(bitfield, 255))
          bitfield = bit_rshift(bitfield, 8)
          bitfieldLenght = bitfieldLenght - 8
        end
        ch = base64ToByte[data:sub(i, i)]
        bitfield = bitfield + bit_lshift(ch or 0, bitfieldLenght)
        bitfieldLenght = bitfieldLenght + 6

        if i > lenght then
          break
        end
        i = i + 1
      end
      return table.concat(bit8, "", 1, decodedSize)
    end

  end

  function Encode(self, data, forChat)
    if forChat then
      return self:EncodeToBase64(data)
    else
      return _ENCODER:Encode(data)
    end
  end

  function Decode(self, data, fromChat)
    if fromChat then
      return self:DecodeFromBase64(data)
    else
      return _ENCODER:Decode(data)
    end
  end

  function Compress(self, data)
    return _COMPRESSER:CompressHuffman(data)
  end

  function Decompress(self, data)
    return _COMPRESSER:Decompress(data)
  end
  -- End encoding and compressing code

  -- Copy functions
  function DeepCopy(self, orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:DeepCopy(orig_key)] = self:DeepCopy(orig_value)
        end
        setmetatable(copy, self:DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
  end

  function ShallowCopy(self, orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
  end

endinterface "API"
--------------------------------------------------------------------------------
--                   Base Frame class                                         --
--        All the frames must inherit from this class                         --
--------------------------------------------------------------------------------
class "Frame"
  _FrameCache = setmetatable({}, { __mode = "k" })
  event "OnDrawRequest"
  event "OnWidthChanged"
  event "OnHeightChanged"
  event "OnSizeChanged"
  ------------------------------------------------------------------------------
  --                             Handlers                                     --
  ------------------------------------------------------------------------------
  local function UpdateHeight(self, new, old)
    local frame = self:GetFrameContainer()
    if frame then
      frame:SetHeight(new)
    end
    return OnHeightChanged(self, new, old)
  end

  local function UpdateWidth(self, new, old)
    local frame = self:GetFrameContainer()
    if frame then
      frame:SetWidth(new)
    end
    return OnWidthChanged(self, new, old)
  end

  local function OnDrawRequestHandler(self)
    if not self.needToBeRedraw then
      self.needToBeRedraw = true
      Scorpio.Delay(0.25, function()
          local aborted = false
          if ObjectIsInterface(self, IReusable) and self.isReusable then
            aborted = true
          end

          if self.Draw and not aborted then self:Draw()  end
          self.needToBeRedraw = false
      end)
    end
  end

  ------------------------------------------------------------------------------
  --                        Size Methods                                      --
  ------------------------------------------------------------------------------
  __Arguments__ { Number }
  function SetWidth(self, width)
    self.width = width
    return OnSizeChanged(self, width, self.height)
  end

  __Arguments__ { Number }
  function SetHeight(self, height)
    self.height = height
    return OnSizeChanged(self, self.width, height)
  end

  __Arguments__ { Number, Number }
  function SetSize(self, width, height)
    self.width = width
    self.height = height
    return OnSizeChanged(self, width, height)
  end

  ------------------------------------------------------------------------------
  --                        SetPoint Methods                                  --
  ------------------------------------------------------------------------------
  -- It's highly advised to use these functions for anchoring frames
  __Arguments__ { String, Table, String, Argument(Number, true), Argument(Number, true)}
  function SetPoint(self, point, relativeTo, relativePoint, xOffset, yOffset)
    self:GetFrameContainer():SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
  end

  __Arguments__ { String, Frame, String, Argument(Number, true), Argument(Number, true)}
  function SetPoint(self, point, relativeTo, relativePoint, xOffset, yOffset)
    This.SetPoint(self, point, relativeTo:GetFrameContainer(), relativePoint, xOffset, yOffset)
  end

  __Arguments__ { String }
  function SetPoint(self, point)
    self:GetFrameContainer():SetPoint(point)
  end

  function ClearAllPoints(self)
    self:GetFrameContainer():ClearAllPoints()
  end

  ------------------------------------------------------------------------------
  --                 Visibility Methods                                       --
  ------------------------------------------------------------------------------
  function Show(self)
    self:GetFrameContainer():Show()
  end

  function Hide(self)
    self:GetFrameContainer():Hide()
  end

  function IsShown(self)
    return self:GetFrameContainer():IsShown()
  end

  function Toggle(self)
    if self:IsShown() then
      self:Hide()
    else
      self:Show()
    end
  end

  ------------------------------------------------------------------------------
  --                    SetParent Methods                                     --
  ------------------------------------------------------------------------------
  __Arguments__ { Argument(Table, true) }
  function SetParent(self, parent)
    self:GetFrameContainer():SetParent(parent)
  end

  __Arguments__ { Frame }
  function SetParent(self, parent)
    This.SetParent(parent:GetFrameContainer())
  end

  ------------------------------------------------------------------------------
  --                   Refresh & Skin Methods                                 --
  ------------------------------------------------------------------------------
  --function Refresh(self)
    --self:ExtraSkinFeatures()
  --end

  -- This function make some extra stuff that isn't not implemented in the skin
  -- system
  function ExtraSkinFeatures(self)
    -- Insert here extra skn feature if you need it
  end


  ------------------------------------------------------------------------------
  --                   Other Methods                                          --
  ------------------------------------------------------------------------------
  -- Return the frame which must be used for anchor/show features
  -- May be overrided to change the frame
  function GetFrameContainer(self)
    return self.frame
  end

  ------------------------------------------------------------------------------
  --                   Static Functions                                       --
  ------------------------------------------------------------------------------
  -- This function return if the frame must be interactive (i.e, answer to click events)
  -- NOTE: This function is used to prevent the button can be clicked outside of scrolling.
  __Arguments__ { Class, Argument(Table) }
  __Static__() function MustBeInteractive(self, frame)

    local yTop = frame:GetTop()
    local yBot = frame:GetBottom()

    if yTop == nil or yBot == nil then
      return false
    end

    local scrollFrame = _G["EQT-ObjectiveTrackerFrameScrollFrame"]

    if not scrollFrame or not frame then
      return false
    end

    -- if the frame is completely included in the tracker, it can be interactive
    if yTop <= scrollFrame:GetTop() and yBot >= scrollFrame:GetBottom() then
      return true
    end

    -- if the frame is completely out of tracker, it can't be interactive
    if (yTop > scrollFrame:GetTop() and yBot > scrollFrame:GetTop()) or (yTop < scrollFrame:GetBottom() and yBot < scrollFrame:GetBottom()) then
      return false
    end

    local offsetTop = 0
    local offsetBot = 0

    -- Top check & compute
    if yTop > scrollFrame:GetTop() and (yBot <= scrollFrame:GetTop() and yBot >= scrollFrame:GetBottom()) then
      offsetTop =  scrollFrame:GetTop() - yTop
    end

    -- Bottom check & compute
    if yBot < scrollFrame:GetBottom() and (yTop >= scrollFrame:GetBottom() and yTop <= scrollFrame:GetTop()) then
      offsetBot = scrollFrame:GetBottom() - yBot
    end


    return frame:IsMouseOver(offsetTop, offsetBot, 0, 0)
  end

  -- Static functin that refresh and reskin all frames.
  -- NOTE: Don't call it too often and only if really needed
  --- (e.g, the user select an another theme)
  __Static__() function RefreshAll()
    for obj in pairs(_FrameWithBorderCache) do
      if obj.Refresh then
        obj:Refresh()
      end
    end
  end

  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  property "frame" {TYPE = Table }
  property "width" { TYPE = Number, HANDLER = UpdateWidth }
  property "height" { TYPE = Number, HANDLER = UpdateHeight }
  property "baseHeight" { TYPE = Number, DEFAULT = 0 }
  property "baseWidth" { TYPE = Number, DEFAULT = 0 }
  property "needToBeRedraw" { TYPE = Boolean, DEFAULT = false } -- use internally
  ------------------------------------------------------------------------------
  --                       Constructors                                       --
  ------------------------------------------------------------------------------
  function Frame(self)
    self.OnDrawRequest = self.OnDrawRequest + OnDrawRequestHandler
    _FrameCache[self] = true
  end

endclass "Frame"

class "BorderFrame" inherit "Frame"
  _BorderFrameCache = setmetatable({}, { __mode = "k" })
  event "OnBorderWidthChanged"
  ------------------------------------------------------------------------------
  --                          Handlers                                        --
  ------------------------------------------------------------------------------
  local function UpdateFrame(self, new, old)
    self:UninstallBorders(old)
    self:InstallBorders(new)


    local container = self:GetFrameContainer()
    new:SetParent(container)
    new:Show()
    self:UpdateBorderAnchors()
  end

  local function UpdateBorderVisibility(self, new, old)
    if not self.borders then return end

    if new then
      self:ShowBorder()
    else
      self:HideBorder()
    end
    self:UpdateBorderAnchors()
  end

  local function UpdateBorderWidth(self, new, old)
    if not self.borders then return end


    self:SetBorderWidth(new)
    OnBorderWidthChanged(self, new, old)

  end

  local function UpdateBorderColor(self, new, old)
    if not self.borders then return end

    self:SetBorderColor(new)
  end

  function GetFrameContainer(self)
    return self.containerFrame
  end

  ------------------------------------------------------------------------------
  --                    Border Methods                                        --
  ------------------------------------------------------------------------------
  function CreateBorders(self)
    if not self.borders then
      local container = self:GetFrameContainer()
      self.borders = {}

      local borderLeft = container:CreateTexture(nil , "BORDER")
      borderLeft:SetColorTexture(0, 0, 0)
      borderLeft:SetWidth(self.borderWidth)
      borderLeft:Show()
      self.borders.left = borderLeft

      local borderTop = container:CreateTexture(nil , "BORDER")
      borderTop:SetColorTexture(0, 0, 0)
      borderTop:SetHeight(self.borderWidth)
      borderTop:Show()
      self.borders.top = borderTop

      local borderRight = container:CreateTexture(nil, "BORDER")
      borderRight:SetColorTexture(0, 0, 0)
      borderRight:SetWidth(self.borderWidth)
      borderRight:Show()
      self.borders.right = borderRight

      local borderBot = container:CreateTexture(nil, "BORDER")
      borderBot:SetColorTexture(0, 0, 0)
      borderBot:SetHeight(self.borderWidth)
      borderBot:Show()
      self.borders.bottom = borderBot

      -- Set Anchor Points
      borderLeft:SetPoint("TOPLEFT")
      borderLeft:SetPoint("BOTTOMLEFT")

      borderRight:SetPoint("TOPRIGHT")
      borderRight:SetPoint("BOTTOMRIGHT")

      borderTop:SetPoint("TOPLEFT", borderLeft, "TOPRIGHT")
      borderTop:SetPoint("TOPRIGHT", borderRight, "TOPLEFT")

      borderBot:SetPoint("BOTTOMLEFT", borderLeft, "BOTTOMRIGHT")
      borderBot:SetPoint("BOTTOMRIGHT", borderRight, "BOTTOMLEFT")

    end
  end

  -- The function will install the borders in the frame give.
  -- The border can be retrieved in doing: frame.borders
  -- e.g: frame.borders.left will return the border left frame
  function InstallBorders(self, frame)
    if self.borders then
      frame.borders = setmetatable({}, { __mode = "v" } )
      frame.borders.left = self.borders.left
      frame.borders.top = self.borders.top
      frame.borders.right = self.borders.right
      frame.borders.bottom = self.borders.bottom
    end
  end

  -- This method will uninstall the borders from frame given.
  -- It simply remove metatable containing references to border frames.
  function UninstallBorders(self, frame)
    if frame and frame.borders then
      frame.borders = nil -- @TODO: Check that
    end
  end

  function ShowBorder(self)
    if self.borders then
      self.borders.top:Show()
      self.borders.left:Show()
      self.borders.bottom:Show()
      self.borders.right:Show()
    end
  end

  function HideBorder(self)
    if self.borders then
      self.borders.top:Hide()
      self.borders.left:Hide()
      self.borders.bottom:Hide()
      self.borders.right:Hide()
    end
  end

  function SetBorderWidth(self, width)
    if self.borders then
      self.borders.left:SetWidth(width)
      self.borders.top:SetHeight(width)
      self.borders.right:SetWidth(width)
      self.borders.bottom:SetHeight(width)

      self:UpdateBorderAnchors ()
    end
  end

  function SetBorderColor(self, color)
    if self.borders then
      self.borders.top:SetColorTexture(color.r, color.g, color.g, color.a)
      self.borders.left:SetColorTexture(color.r, color.g, color.g, color.a)
      self.borders.bottom:SetColorTexture(color.r, color.g, color.g, color.a)
      self.borders.right:SetColorTexture(color.r, color.g, color.g, color.a)
    end
  end

  function UpdateBorderAnchors(self)
    if self.showBorder then
      self.frame:ClearAllPoints()
      self.frame:SetPoint("TOP", self.borders.top, "BOTTOM")
      self.frame:SetPoint("LEFT", self.borders.left, "RIGHT")
      self.frame:SetPoint("RIGHT", self.borders.right, "LEFT")
      self.frame:SetPoint("BOTTOM", self.borders.bottom, "TOP")
    else
      self.frame:ClearAllPoints()
      self.frame:SetAllPoints(self:GetFrameContainer())
    end
  end

  ------------------------------------------------------------------------------
  --                   Refresh & Skin Methods                                 --
  ------------------------------------------------------------------------------
  --__Arguments__ { Argument(Theme.SkinFlags, true, ALL) }
  function ExtraSkinFeatures(self, skinFlags)
    -- Call the super function
    Super.ExtraSkinFeatures(self)

    -- Get the selected theme by user
    local theme = Themes:GetSelected()

    -- Get the element id and inherit element id if exists
    local elementID = self.frame.elementID
    local inheritElementID = self.frame.inheritElementID

    -- If the element ID is nil, don't continue
    if not elementID then
      return
    end

    -- Border width
    --if System.Reflector.ValidateFlags(skinFlags, )
    self.borderWidth = theme:GetElementProperty(elementID, "border-width", inheritElementID)

    -- Border color
    self.borderColor = theme:GetElementProperty(elementID, "border-color", inheritElementID)

  end
  ------------------------------------------------------------------------------
  --                        Static Functions                                  --
  ------------------------------------------------------------------------------
  __Static__() function RefreshAll()
    for obj in pairs(_BorderFrameCache) do
      if obj.Refresh then
        obj:Refresh()
      end
    end
  end

  ------------------------------------------------------------------------------
  --                         Properties                                       --
  ------------------------------------------------------------------------------
  property "frame"{ TYPE = Table, HANDLER = UpdateFrame }
  property "containerFrame" { TYPE = Table } -- contains the borders and the content frame
  property "showBorder" { TYPE = Boolean, DEFAULT = true, HANDLER = UpdateBorderVisibility }
  property "borderWidth" { TYPE = Number, DEFAULT = 0, HANDLER = UpdateBorderWidth }
  property "borderColor" { TYPE = Table, DEFAULT = { r = 0, g = 0, b = 0, a = 1}, HANDLER = UpdateBorderColor }
  ------------------------------------------------------------------------------
  --                         Constructors                                     --
  ------------------------------------------------------------------------------
  function BorderFrame(self)
    Super(self)

    _BorderFrameCache[self] = true

    self.containerFrame = CreateFrame("Frame")
    self:CreateBorders()
  end


endclass "BorderFrame"
--------------------------------------------------------------------------------
--                          THEME SYSTEM                                      --
--------------------------------------------------------------------------------
__Serializable__() class "Theme" extend "ISerializable"
_REGISTERED_FRAMES = {}
  ------------------------------------------------------------------------------
  --                       Register Methods                                   --
  ------------------------------------------------------------------------------
  __Arguments__ { Class, String, Table, Argument(String, true), Argument(String, true, "FRAME")}
  __Static__() function RegisterFrame(self, elementID, frame, inheritElementID, type)
    if not frame then
      return
    end

    local frames = _REGISTERED_FRAMES[elementID]
    if not frames then
      frames = setmetatable({}, { __mode = "k"})
      _REGISTERED_FRAMES[elementID] = frames
    end

    if frames[frame] then return end

    frames[frame] = true
    frame.elementID = elementID
    frame.type = type

    if inheritElementID then
      frame.inheritElementID = inheritElementID
    end

    if frame.text then
      frame.text.elementID = elementID
      frame.text.type = "TEXT"
      if inheritElementID then
        frame.text.inheritElementID = inheritElementID
      end
    end

    if frame.texture then
      frame.texture.elementID = elementID
      frame.texture.type = "TEXTURE"
      if inherit then
        frame.texture.inheritElementID = inheritElementID
      end
    end

    Theme:InstallScript(frame)
  end

  __Arguments__ { Class, String, Table, Argument(String, true) }
  __Static__() function RegisterTexture(self, elementID, frame, inheritElementID)
    Theme:RegisterFrame(elementID, frame, inheritElementID, "TEXTURE")
  end

  __Arguments__ { Class, String, Table, Argument(String, true)}
  __Static__() function RegisterText(self, elementID, frame, inheritElementID)
    Theme:RegisterFrame(elementID, frame, inheritElementID, "TEXT")
  end

  __Arguments__ { Class, String, String }
  __Static__() function RegisterFont(self, fontID, fontFile)
    if _LibSharedMedia then
      _LibSharedMedia:Register("font", fontID, fontFile)
    end
  end

  ------------------------------------------------------------------------------
  --                     Skin Methods                                         --
  ------------------------------------------------------------------------------
  __Flags__()
  enum "SkinFlags" {
    ALL = 1,
    FRAME_BACKGROUND_COLOR = 2,
    FRAME_BORDER_COLOR = 4,
    FRAME_BORDER_WIDTH = 8,
    TEXT_SIZE = 16,
    TEXT_COLOR = 32,
    TEXT_FONT = 64,
    TEXT_TRANSFORM = 128,
    TEXTURE_COLOR = 256,
  }

  __Arguments__ { Class, Table, Argument(String, true), Argument(String, true), Argument(SkinFlags, true, ALL) }
  __Static__() function SkinFrame(self, frame, originText, state, flags)
    -- Get the selected theme
    local theme = Themes:GetSelected()

    if not theme then return end -- TODO Add error msg
    if not frame then return end -- TODO Add error msg
    if not frame.elementID then return end -- TODO Add error msg

    local elementID = frame.elementID
    local inheritElementID = frame.inheritElementID

    if state then
      elementID = elementID.."["..state.."]"
    end

    -- The frame is a normal frame
    if frame.type == "FRAME" then
      -- Backgorund color
      local color
      if frame.SetBackdropColor and (ValidateFlags(flags, SkinFlags.ALL) or ValidateFlags(flags, SkinFlags.FRAME_BACKGROUND_COLOR)) then
        color = theme:GetElementProperty(elementID, "background-color", inheritElementID)
        frame:SetBackdropColor(color.r, color.g, color.b, color.a)
      end

      if frame.SetBackdropBorderColor and (ValidateFlags(flags, SkinFlags.ALL) or ValidateFlags(flags, SkinFlags.FRAME_BORDER_COLOR)) then
        --color = theme:GetElementProperty(elementID, "border-color", inheritElementID)
        frame:SetBackdropBorderColor(0, 0, 0, 0)
      end

      if frame.text then
        Theme:SkinText(frame.text, originText, state, flags)
      end

      if frame.texture then
        Theme:SkinTexture(frame.texture, state, flags)
      end
    end
  end

  __Arguments__ { Class, Table, Argument(String + Number, true), Argument(String, true), Argument(SkinFlags, true, ALL) }
  __Static__() function SkinText(self, fontstring, originText, state, flags)
    local theme = Themes:GetSelected()

    if not theme  then return end -- TODO add error msg
    if not fontstring then return end  -- TODO add error msg

    local elementID = fontstring.elementID
    local inheritElementID = fontstring.inheritElementID

    if not elementID then return end

    if state then
      elementID = elementID.."["..state.."]"
    end


    local font, size = fontstring:GetFont()
    local textColor = {}
    textColor.r, textColor.g, textColor.b, textColor.a = fontstring:GetTextColor()
    if ValidateFlags(flags, SkinFlags.ALL) or ValidateFlags(flags, SkinFlags.TEXT_SIZE) then
      size = theme:GetElementProperty(elementID, "text-size", inheritElementID)
    end

    if ValidateFlags(flags, SkinFlags.ALL) or ValidateFlags(flags, SkinFlags.TEXT_FONT) then
      font = _LibSharedMedia:Fetch("font", theme:GetElementProperty(elementID, "text-font", inheritElementID))
    end
    fontstring:SetFont(font, size, "OUTLINE")

    if ValidateFlags(flags, SkinFlags.ALL) or ValidateFlags(flags, SkinFlags.TEXT_COLOR) then
      textColor = theme:GetElementProperty(elementID, "text-color", inheritElementID)
    end
    fontstring:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)

    local location = theme:GetElementProperty(elementID, "text-location", inheritElementID)
    local offsetX = theme:GetElementProperty(elementID, "text-offsetX", inheritElementID)
    local offsetY = theme:GetElementProperty(elementID, "text-offsetY", inheritElementID)

    for i = 1, fontstring:GetNumPoints() do
      local point, relativeTo, relativePoint, xOffset, yOffset = fontstring:GetPoint(i)
      if i == 1 then
        fontstring:SetPoint(point, relativeTo, relativePoint, offsetX or xOffset, offsetY or yOffset)
        break
      end
    end

    fontstring:SetJustifyV(_JUSTIFY_V_FROM_ANCHOR[location])
    fontstring:SetJustifyH(_JUSTIFY_H_FROM_ANCHOR[location])

    local txt = ""
    if originText then
      txt = originText
    elseif fontstring:GetText() then
      txt = fontstring:GetText()
    end

    local transform = theme:GetElementProperty(elementID, "text-transform", inheritElementID)
    if transform == "uppercase" then
      txt = txt:upper()
    elseif transform == "lowercase" then
      txt = txt:lower()
    end
    fontstring:SetText(txt)
  end

  __Arguments__{ Class, Table, Argument(String, true), Argument(SkinFlags, true, ALL) }
  __Static__() function SkinTexture(self, texture, state, flags)
    local theme = Themes:GetSelected()

    if not theme then return end -- TODO add error msg
    if not texture then return end  -- TODO add error msg

    local elementID = texture.elementID
    local inheritElementID = texture.inheritElementID

    if not elementID then return end

    if state then
      elementID = elementID.."["..state.."]"
    end

    if ValidateFlags(flags, SkinFlags.ALL) or ValidateFlags(flags, SkinFlags.TEXTURE_COLOR) then
      local color = theme:GetElementProperty(elementID, "texture-color", inheritElementID)
      texture:SetVertexColor(color.r, color.g, color.b, color.a)
    end
  end



  ------------------------------------------------------------------------------
  --              Element Property Methods                                    --
  ------------------------------------------------------------------------------
  __Flags__()
  enum "ElementFlags" {
    INCLUDE_PARENT = 1,
    INCLUDE_DATABASE = 2,
    INCLUDE_DEFAULT_VALUES = 4,
    INCLUDE_STATE = 8,
    IGNORE_WITHOUT_STATE = 16
  }

  __Arguments__ { String, String , String }
  function SetElementLink(self, elementID, property, destElementID)
    local links = self.links[elementID] or SDictionary()
    links[property] = destElementID

    if not self.links[elementID] then
      self.links[elementID] = links
    end
  end

  __Arguments__ { String, String }
  function GetElementLink(self, elementID, property)
    return  self.links[elementID] and self.links[elementID][property]
  end

  __Arguments__ { String }
  function ClearElementLinks(self, elementID)
    local links = self.links[elementID]
    if links then
      for k,v in links:GetIterator() do links[k] = nil end
      self.links[elementID] = nil
      links = nil
    end
  end

  __Arguments__ {}
  function ClearAllElementLinks(self)
    for elementID, links in self.links:GetIterator() do
      for k,v in links:GetIterator() do links[k] = nil end
      self.links[elementID] = nil
      links = nil
    end
  end


  function SetElementPropertyLink(self, elementID, property, destElementID)
    elementID = elementID:gsub("%s+", "") -- Remove the space
      -- Get the possible element Ids
      local IDs =  { Theme:GetPossibleElementIDs(elementID) }
      for _, id in ipairs(IDs) do
        local elementProps = self.properties[id] or SDictionary()
        elementProps[property] = value

        if not self.properties[id] then
          self.properties[id] = elementProps
        end
      end

  end

  __Arguments__ { String, String, Argument(String, true), Argument(ElementFlags, true, 15) }
  function GetElementProperty(self, elementID, property, inheritElementID, flags)
      elementID = elementID:gsub("%s+", "") -- Remove the space

      local value
      if ValidateFlags(flags, ElementFlags.INCLUDE_DATABASE) then
        value = self:GetElementPropertyFromDB(elementID, property)
        if value then
          return value
        end
      end

      value = self.properties[elementID] and self.properties[elementID][property]
      if value then
        return value
      end

      if not ValidateFlags(flags, ElementFlags.INCLUDE_PARENT) then
        if ValidateFlags(flags,ElementFlags.INCLUDE_DEFAULT_VALUES) then
          return Theme:GetDefaultProperty(property)
        end
        return value
      end

      local elementLink = self:GetElementLink(elementID, property)
      if elementLink then
        value = self:GetElementPropertyFromDB(elementLink, property)
        if value then
          return value
        end

        value = self.properties[elementLink] and self.properties[elementLink][property]
        if value then
          return value
        end
      else
        for _, id in Theme:GetReadingIDList(elementID, inheritElementID, flags):GetIterator() do
            if ValidateFlags(flags, ElementFlags.INCLUDE_DATABASE) then
              value = self:GetElementPropertyFromDB(id, property)
              if value then
                self:SetElementLink(elementID, property, id)
                return value
              end
            end

            value = self.properties[id] and self.properties[id][property]
            if value then
              self:SetElementLink(elementID, property, id)
              return value
            end
        end
      end

      if ValidateFlags(flags, ElementFlags.INCLUDE_DEFAULT_VALUES) then
        return Theme:GetDefaultProperty(property)
      end
  end

  __Arguments__{ String, String, Argument(Any, true) }
  function SetElementProperty(self, elementID, property, value)
    -- NOTE Make the *
    elementID = elementID:gsub("%s+", "") -- Remove the space
      -- Get the possible element Ids
      local IDs =  { Theme:GetPossibleElementIDs(elementID) }
      for _, id in ipairs(IDs) do
        local elementProps = self.properties[id] or SDictionary()
        elementProps[property] = value

        if not self.properties[id] then
          self.properties[id] = elementProps
        end
      end

      self:ClearAllElementLinks()
  end

  __Arguments__ { String, Any }
  function SetElementProperty(self, property, value)
    This.SetElementProperty(self, "*", property, value)
  end



  -- ElementFlags (3) = INCLUDE_PARENT (1) + INCLUDE_DATABASE (2)
  __Arguments__{ String, String, Argument(String, true), Argument(ElementFlags, true, 3)}
  function ElementHasState(self, elementID, state, inheritElementID, flags)
    flags = flags + ElementFlags.IGNORE_WITHOUT_STATE + ElementFlags.INCLUDE_STATE
    elementID = string.format("%s[%s]", elementID, state)

    --print("ElementHasState", elementID, state, inheritElementID)

    for _, id in Theme:GetReadingIDList(elementID, inheritElementID, flags):GetIterator() do
      if ValidateFlags(flags, INCLUDE_DATABASE) and self:ElementExistsFromDB(id) then
        return true
      end

      if self.properties[id] then return true end
    end

    return false
  end

  __Arguments__ { Class, String }
  __Static__() function GetDefaultProperty(self, property)
      local defaults = {
        ["background-color"] = { r = 0, g = 0, b = 0, a = 0 },
        ["border-color"] = { r = 0, g = 0, b = 0, a = 0 },
        ["border-width"] = 2,
        ["offsetX"] = 0,
        ["offsetY"] = 0,
        ["text-size"] = 10,
        ["text-font"] = "PT Sans Bold",
        ["text-color"] = { r = 0, g = 0, b = 0},
        ["text-transform"] = "none",
        ["text-location"] = "CENTER",
        ["text-offsetX"] = 0,
        ["text-offsetY"] = 0,
        ["vertex-color"] = { r = 1, g = 1, b = 1},
        ["texture-color"] = { r = 1, g = 1, b = 1}
      }

      return defaults[property]
  end

  __Arguments__ { String, String }
  function GetElementPropertyFromDB(self, elementID, property)
    Database:SelectRoot()

    if Database:SelectTable(false, "themes", self.name, "properties", elementID) then
      return Database:GetValue(property)
    end
  end

  __Arguments__ { String, String, Argument(Any, true)}
  function SetElementPropertyToDB(self, elementID, property, value)
    Database:SelectRoot()

    if Database:SelectTable(true, "themes", self.name, "properties", elementID) then
      Database:SetValue(property, value )
    end

    self:ClearAllElementLinks()
  end

  __Arguments__ { String }
  function ElementExistsFromDB(self, elementID)
    Database:SelectRoot()

    if Database:SelectTable(false, "themes", self.name, "properties", elementID) then
      return true
    end

    return false
  end

  ------------------------------------------------------------------------------
  --                        Helper Methods                                    --
  ------------------------------------------------------------------------------
  __Arguments__ { Class, Table }
  __Static__() function InstallScript(self, frame)
    if not frame.GetScript or not frame.SetScript then
      return
    end

    local theme = Themes:GetSelected()
    if not theme or not theme:ElementHasState(frame.elementID, "hover", frame.inheritElementID) then return end

    local function FrameOnHover(f)
      if Frame:MustBeInteractive(f) then
        Theme:SkinFrame(frame, nil, "hover")
      else
        Theme:SkinFrame(frame)
      end
    end

    if not frame:GetScript("OnEnter") then
      frame:SetScript("OnEnter", function()
        frame:SetScript("OnUpdate", FrameOnHover)
      end)
    end

    if not frame:GetScript("OnLeave") then
      frame:SetScript("OnLeave", function()
        frame:SetScript("OnUpdate", nil)
        Theme:SkinFrame(frame)
      end)
    end


    if not frame:GetScript("OnMouseDown") and not frame:GetScript("OnMouseUp") then
      frame:SetScript("OnMouseDown", _Addon.ObjectiveTrackerMouseDown)
      frame:SetScript("OnMouseUp", _Addon.ObjectiveTrackerMouseUp)
    end
  end

  -- ElementFlags (9)  = INCLUDE_PARENT (1) + INCLUDE_STATE (8)
  __Arguments__ { Class, String, Argument(String, true), Argument(ElementFlags, true, 9)}
  __Static__() function GetReadingIDList(self, elementID, inheritElementID, flags)
    local rawElementID, states = self:RemoveStates(elementID)
    local categories = { strsplit(".", rawElementID) }
    local list = List()

    local parentIDs, parentIDNum
    if ValidateFlags(flags, ElementFlags.INCLUDE_PARENT) then
      if inheritElementID then
        parentIDs = { strsplit(".", inheritElementID) }
        parentIDNum = #parentIDs
      end
    end


    -- We start to create the list without state
    local currentID = ""
    if not ValidateFlags(flags, ElementFlags.IGNORE_WITHOUT_STATE) then
      if ValidateFlags(flags, ElementFlags.INCLUDE_PARENT) then
        list:Insert("*")
      end
      for index, category in ipairs(categories) do
        if ValidateFlags(flags, ElementFlags.INCLUDE_PARENT) then
          if parentIDNum and parentIDNum == index then
            list:Insert(inheritElementID)
          end
        end

        if index ~= #categories then
          if ValidateFlags(flags, ElementFlags.INCLUDE_PARENT) then
            if inheritElementID then
              list:Insert(parentIDs[index]..".*")
            end
            list:Insert(currentID..category..".*")
          end
        else
          list:Insert(currentID..category)
        end
        currentID = currentID .. category .. "."
      end
    end

    -- Then we do the same things with the state if exists
    if ValidateFlags(flags, ElementFlags.INCLUDE_STATE) then
      if states then
        currentID = ""
        if ValidateFlags(flags, ElementFlags.INCLUDE_PARENT) then
          list:Insert("*"..states)
        end
        for index, category in ipairs(categories) do
          if ValidateFlags(flags, ElementFlags.INCLUDE_PARENT) then
            if parentIDNum and parentIDNum == index then
              list:Insert(inheritElementID..states)
            end
          end

          if index ~= #categories then
            if ValidateFlags(flags, ElementFlags.INCLUDE_PARENT) then
              if inheritElementID then
                list:Insert(parentIDs[index]..".*"..states)
              end

              list:Insert(currentID..category..".*"..states)
            end
          else
            list:Insert(currentID..category..states)
          end
          currentID = currentID .. category .. "."

        end
      end
    end
    return list:Range(-1, 1, -1):ToList()
  end

  __Arguments__ { Class, String, Argument(Boolean, true, false)}
  __Static__() function GetElementNameFromString(self, str, includeFlags)

    local categories = {strsplit(".", str) }
    if includeFlags then
      return categories[#categories]
    else
      local elementName = categories[#categories]
      local elementName = elementName:gsub("(%[[@,|%w]*%])", "")
      return elementName
    end
  end

  __Arguments__ { Class, String}
  __Static__() function RemoveStates(self, str)
    local states = str:match("(%[[,|%w]*%])")
    local str =  str:gsub("(%[[,|%w]*%])", "")
    return str, states
  end

  __Arguments__ { Class, String }
  __Static__() function GetPossibleElementIDs(self, str)
    local elementID, states = self:RemoveStates(str)
    if states then
      local possibleStates =  { self:GetPossibleStates(states) }
      local list = {}
      for _, s in ipairs(possibleStates) do
        tinsert(list, string.format("%s[%s]", elementID, s))
      end
      return unpack(list)
    else
      return elementID
    end
  end


  __Arguments__ { Class, String }
  __Static__() function GetPossibleStates(self, str)
    -- Build the list
    local andList = {}
    local andSplit = { strsplit(",", str) }
    for _, orList in ipairs(andSplit) do
      local list = {}
      local orSplit = { strsplit("|", orList) }
      for _, state in ipairs(orSplit) do
        state = state:gsub("([%c%p%s]*)", "") -- clear space and @ character
        tinsert(list, state)
      end
      tinsert(andList, list)
    end

    -- helper function (recurcive)
    local function GetList(i)
      local l = {}
      if andList[i+1] then
        local childStates = { GetList(i+1) }
        for _, state in ipairs(andList[i]) do
          for _, childState in ipairs(childStates) do
            tinsert(l, state..","..childState)
          end
        end
        return unpack(l)
      else
        return unpack(andList[i])
      end
    end

    return GetList(1)
  end

  --[[
  function ExportToText(self, includeDatabase)
    local theme = self
    if includeDatabase or self.lua == false then
      theme = System.Reflector.Clone(self, true)
      Database:SelectRoot()
      if Database:SelectTable(false, "themes", self.name, "properties") then
        for elementID, properties in Database:IterateTable() do
          for property, value in pairs(properties) do
            if type(value) == "table" then
              local t = {}
              for k,v in pairs(value) do
                t[k] = v
              end
              theme:SetElementProperty(elementID, property, t)
            else
              theme:SetElementProperty(elementID, property, value)
            end
          end
        end
      end
    end

    local data = Serialization.Serialize( StringFormatProvider(), theme)
    local compressedData = API:Compress(data)
    local encode = API:EncodeToBase64(compressedData)
    return encode
  end --]]

  __Arguments__ { Argument(Boolean, true, true) }
  function ExportToText(self, includeDB)


    local theme = Theme(self)
    theme.name = self.name
    theme.author = self.author
    theme.verison = self.version
    theme.stage = self.stage

    if includeDB and self.lua then
      Database:SelectRoot()
      if Database:SelectTable(false, "themes", self.name, "properties") then
        for elementID, properties in Database:IterateTable() do
          for property, value in pairs(properties) do
            local copy = API:ShallowCopy(value)
            theme:SetElementProperty(elementID, property, copy)
          end
        end
      end
    end

    local data = Serialization.Serialize( StringFormatProvider(), theme)
    local compressedData = API:Compress(data)
    local encode = API:EncodeToBase64(compressedData)
    return encode
  end

  __Arguments__ { Class, String }
  __Static__() function GetFromText(self, text)
    -- decode from base 64
    local decode = API:DecodeFromBase64(text)
    local decompress, msg = API:Decompress(decode)

    if not decompress then
      return nil, "Error decompressing: ".. msg
    end

    local isOK, theme = pcall(Serialization.Deserialize, StringFormatProvider(), decompress, Theme)
    if isOK then
      return theme
    else
      return nil, "Error deserializing"
    end
  end

  function MovePropertiesToDB(self)
    for elementID, properties in self.properties:GetIterator() do
      if properties then
        for property, value in properties:GetIterator() do
          self:SetElementPropertyToDB(elementID, property, value)
        end
      end
    end
    self.properties = SDictionary()
  end

  function SyncToDB(self)
    if not self.lua then
      Database:SelectRoot()
      if Database:SelectTable(true, "themes", self.name) then
        Database:SetValue("name", self.name)
        Database:SetValue("author", self.author)
        Database:SetValue("stage", self.stage)
        Database:SetValue("version", self.version)
      end
    end
  end

  function SetAuthor(self, author)
    -- If the theme isn't created from lua file, we need persist the value in the DB
    if not self.lua then
      Database:SelectRoot()

      if Database:SelectTable(true, "themes", self.name) then
        Database:SetValue("author", author)
      end
    end

    self.__author = author
  end

  function SetVersion(self, version)
    -- If the theme isn't created from lua file, we need persist the value in the DB
    if not self.lua then
      Database:SelectRoot()

      if Database:SelectTable(true, "themes", self.name) then
        Database:SetValue("version", version)
      end
    end

    self.__version = version
  end

  function SetName(self, name)
    -- If the theme isn't created from lua file, we need persist the value in the DB
    if not self.lua then
      Database:SelectRoot()
      if Database:SelectTable(true, "themes", name) then
        Database:SetValue("name", name)
        Database:MoveTable("themes", name)
      end

    end

    self.__name = name
  end

  function SetStage(self, stage)
    -- If the theme isn't created from lua file, we need persist the value in the DB
    if not self.lua then
      Database:SelectRoot()

      if Database:SelectTable(true, "themes", self.name) then
        Database:SetValue("stage", stage)
      end
    end

    self.__stage = stage
  end

  property "author" { TYPE = String, SET = "SetAuthor", GET = function(self) return self.__author end }
  property "version" { TYPE = String, DEFAULT = "1.0.0", SET = "SetVersion", GET = function(self) return self.__version end }
  property "name" {  TYPE = String, SET = "SetName", GET = function(self) return self.__name end }
  property "stage" { TYPE = String, DEFAULT = "Release", SET = "SetStage", GET = function(self) return self.__stage end }
  property "lua" { TYPE = Boolean, DEFAULT = true}

  function Serialize(self, info)
    info:SetValue("name", self.name, String)
    info:SetValue("author", self.author, String)
    info:SetValue("version", self.version, String)
    info:SetValue("stage", self.stage, String)
    info:SetValue("func", self.func, String)

    info:SetValue("properties", self.properties, SDictionary)
    info:SetValue("scripts", self.scripts, SDictionary)
    info:SetValue("options", self.options, SDictionary)

  end

  __Flags__()
  enum "OverrideFlags" {
    NONE = 0,
    OVERRIDE_THEME_INFO = 1,
  }

  __Flags__()
  enum "SourceFlags" {
    NONE = 0,
    DATABASE = 1,
    LUA_TABLE = 2,
  }

  __Arguments__ { Theme, Argument(SourceType, true, SourceFlags.DATABASE + SourceFlags.LUA_TABLE), Argument(OverrideFlags, true, OverrideFlags.OVERRIDE_THEME_INFO) }
  function Override(self, theme, sourceFlags, overrideFlags)
    if ValidateFlags(overrideFlags, OverrideFlags.OVERRIDE_THEME_INFO) then
      self.name = theme.name
      self.author = theme.author
      self.version = theme.version
      self.stage = theme.stage
    end

    if ValidateFlags(sourceFlags, SourceFlags.LUA_TABLE) then
      for elementID, properties in theme.properties:GetIterator() do
        for property, value in properties:GetIterator() do
          self:SetElementPropertyToDB(elementID, property, API:ShallowCopy(value))
        end
      end
    end

    if ValidateFlags(sourceFlags, SourceFlags.DATABASE) then
      Database:SelectRoot()
      if Database:SelectTable(false, "themes", theme.name, "properties") then
        for elementID, properties in Database:IterateTable() do
          for property, value in pairs(properties) do
            self:SetElementPropertyToDB(elementID, property, API:ShallowCopy(value))
          end
        end
      end
    end
  end

  --[[__Arguments__ { Theme }
  function Override(self, theme)
    self.name = theme.name
    self.author = theme.name
    self.version = theme.version
    self.stage = theme.stage

    for elementID, properties in theme.properties:GetIterator() do
      for property, value in properties:GetIterator() do
        self:SetElementPropertyToDB(elementID, property, API:ShallowCopy(value))
      end
    end
  end--]]



  __Arguments__{}
  function Theme(self)
    self.properties = SDictionary()
    self.scripts = SDictionary()
    self.options = SDictionary()

    self.links = SDictionary() -- used as cache to improve get performance
  end

  __Arguments__{ SerializationInfo }
  function Theme(self, info)
    This(self)

    self.name = info:GetValue("name", String)
    self.author = info:GetValue("author", String)
    self.version = info:GetValue("version", String)
    self.stage = info:GetValue("stage", String)

    self.properties = info:GetValue("properties", SDictionary)
  end

  __Arguments__ { Theme, Argument(Boolean, true, true )}
  function Theme(self, orig)
    This(self)

    if orig.lua then
      for elementID, properties in orig.properties:GetIterator() do
        for property, value in properties:GetIterator() do
          local copyValue = API:ShallowCopy(value)
          self:SetElementProperty(elementID, property, copyValue)
        end
      end
    else
      Database:SelectRoot()
      if Database:SelectTable(false, "themes", orig.name, "properties") then
        for elementID, properties in Database:IterateTable() do
          for property, value in pairs(properties) do
            local copyValue = API:ShallowCopy(value)
            self:SetElementProperty(elementID, property, copyValue)
          end
        end
      end
    end
  end


endclass "Theme"

class "Themes"
  _CURRENT_THEME = nil
  _THEMES = Dictionary()

  __Static__() __Arguments__ { Class, Theme }
  function Register(self, theme)
    if not _THEMES[theme.name] then
      _THEMES[theme.name] = theme
    end

    if not _CURRENT_THEME then
      _CURRENT_THEME = theme
    end
  end

  __Static__() __Arguments__ { Class, String }
  function Select(self, themeName)
    local theme = _THEMES[themeName]
    if theme then
      _CURRENT_THEME = theme
      Options:Set("theme-selected", themeName)

      -- TODO Does the refrehsed
      -- CallbackHandlers:CallGroup("refresher")
      CallbackHandlers:CallGroup("refresher")
    end
  end

  __Static__() __Arguments__ { Class }
  function GetSelected(self)
    -- In case where no theme has been selected
    if not _CURRENT_THEME then
      -- Check in the DB if the user has selected a theme
      local selected = Options:Get("theme-selected")
      -- The user has slected a theme
      if selected then
        _CURRENT_THEME = self:Get(selected)
        -- If the selected theme isn't available, return the first
        if not _CURRENT_THEME then
          _CURRENT_THEME = self:GetFirst()
        end
      else
        _CURRENT_THEME = self:GetFirst()
      end
    end

    return _CURRENT_THEME
  end

  __Static__() __Arguments__ { Class }
  function GetIterator(self)
    return _THEMES:GetIterator()
  end

  __Static__() __Arguments__ { Class, String }
  function Get(self, name)
    for _, theme in _THEMES:GetIterator() do
      if theme.name == name then
        return theme
      end
    end
  end

  __Static__() __Arguments__  { Class, String }
  function GetFirst(self)
    for _, theme in _THEMES:GetIterator() do return theme end
  end

  __Arguments__ { Class }
  __Static__() function LoadFromDB(self)
    Database:SelectRoot()

    if Database:SelectTable(false, "themes") then
      for name, themeDB in Database:IterateTable() do
        local name = themeDB.name
        local author = themeDB.author
        local version = themeDB.version
        local stage = themeDB.stage
        -- if the theme has these four properties, this say it not a lua theme.
        if name and author and version and stage then
          local theme = Theme()
          theme.name = name
          theme.author = author
          theme.version = version
          theme.stage = stage
          -- @NOTE It's important to edit the lua variable to last to avoid to useless sync with DB while loading.
          theme.lua = false -- [IMPORTANT]

          self:Register(theme)
        end
      end
    end
  end

  enum "ThemeCreateError" {
    ThemeAlreadyExists = 1,
    ThemeToCopyNotExists = 2,
  }



  -- Create a DB Theme, it hightly advised to use this function
  __Arguments__ { Class, String, String, String, String, Argument(String, true, "none"), Argument(Boolean, true, false)}
  __Static__() function CreateDBTheme(self, name, author, version, stage, themeToCopy, includeDB )
    -- Check if a theme already exists before to continue
    Database:SelectRoot()
    if Database:SelectTable(false, "themes", name) then
      return nil, Themes.ThemeAlreadyExists, "A theme with this name already exists."
    end

    Database:SelectRoot()
    if Database:SelectTable(true, "themes", name) then
      if themeToCopy == "none" then
        local theme = Theme()
        theme.lua = false
        theme.name = name
        theme.author = author
        theme.version = version
        theme.stage = stage

        self:Register(theme)
        return theme
      else
        local parentTheme = self:Get(themeToCopy)
        if not parentTheme then return nil, Themes.ThemeToCopyNotExists,"The theme to copy not exists." end

      -- If the theme copied is a lua theme
        if parentTheme.lua then
          --[[local theme = Theme(parentTheme)
          theme.lua = false
          theme.name = name
          theme.author = author
          theme.version = version
          theme:MovePropertiesToDB()
          self:Register(theme) --]]

          ---------
          local theme = Theme()
          theme.lua = false
          theme.name = name
          theme.author = author
          theme.version = version
          theme.stage = stage

          if includeDB then
              theme:Override(parentTheme, nil, Theme.OverrideFlags.NONE)
          else
              theme:Override(parentTheme, Theme.SourceFlags.DATABASE, Theme.OverrideFlags.NONE)
          end
          self:Register(theme)
        else
          Database:SelectRoot()
          if Database:SelectTable(false, "themes", parentTheme.name) then
            Database:CopyTable("themes", name)
            local theme = Theme()
            theme.lua = false
            theme.name = name
            theme.author = author
            theme.version = version
            theme.stage = stage
            self:Register(theme)
          end
        end
      end
    end
  end


  __Arguments__ { Class, String }
  __Static__() function Delete(self, name)
    local theme = self:Get(name)
    if theme and theme.lua == false then
      Database:SelectRoot()
      if Database:SelectTable(false, "themes", theme.name) then
        Database:DeleteTable()
        _THEMES[name] = nil
        return true
      end
    end

    return false
  end

  __Arguments__ { Class, String, Argument(String, true) }
  __Static__() function Import(self, importText, destName)
    local theme, msg = Theme:GetFromText(importText)
    if theme then
      if destName then
        theme.name = destName
      end
      theme.lua = false
      theme:SyncToDB()
      theme:MovePropertiesToDB()
      self:Register(theme)
    end
  end

  function Override(self, importText)
    local overrideTheme = Theme:GetFromText(importText)
    local theme = Themes:Get(overrideTheme.name)
    if theme then
      theme:Override(overrideTheme)

      if theme.name == Themes:GetSelected().name then
        CallbackHandlers:CallGroup("refresher")
      end
    end
  end


  __Arguments__ { Class }
  __Static__() function Print(self)
    print("----[[ Themes ]]----")
    local i = 1
    for _, theme in _THEMES:GetIterator() do
      print(i, "Name:", theme.name, " | Author:", theme.author, " | Version:", theme.version, " | Stage:", theme.stage, " | LUA:", theme.lua)
      i = i + 1
    end
    print("--------------------")
  end


endclass "Themes"


class "State"
  property "id" { TYPE = String }
  property "text" { TYPE = String }
  property "color" { TYPE = Color}

  __Arguments__ { String, String, Color }
  function State(self, id, text, color)
    self.id = id
    self.text = text
    self.color = color
  end


endclass "State"

class "States"
  _STATES = Dictionary()

  __Arguments__ { Class, State}
  __Static__() function Add(self, state)
    _STATES[state.id] = state
  end

  __Arguments__ { Class }
  __Static__() function GetIterator()
    return _STATES:GetIterator()
  end

  __Arguments__ { Class, String }
  __Static__() function Get(self, stateID)
    return _STATES[stateID]
  end

endclass "States"

function OnLoad(self)
  -- Add some basic state
  States:Add(State("none", "None", Color(1, 1, 1)))
  States:Add(State("completed", "Completed", Color(0, 1, 0)))
  States:Add(State("progress", "Progress", Color(0.5, 0.5, 0.5)))
  States:Add(State("tracked", "Tracked", Color(1.0, 0.5, 0)))

end
