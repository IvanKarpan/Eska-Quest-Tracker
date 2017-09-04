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
--                         Config                                             --
--------------------------------------------------------------------------------
--[[__Final__()
interface "Config"
  function GetOption(self, option)
    if not _DB and not _DB.options then
      -- TODO written a error code
      return
    end

    return _DB.options[option]
  end

  function SetOption(self, option, value)
    if not _DB then
      -- TODO written an error code
      return
    end

    if not _DB.option then _DB.options = {} end

    _DB.options[option] = value
  end
endinterface "Config"--]]

-- EQT.Config:GetOption()
-- EQT.Config:SetOption()
-- EQT.Config:RegisterOption()
-- EQT.Config:SelectProfile()
-- EQT.Config:UseSpecDB()
-- EQT.Config:UseGlobalDB()
-- EQT.Config:UseCharacterDB()

-- [Config] [Use Character DB, Use Spec DB, Use Global DB
-- charactersDB[name] = "spec" | "character"


-- Refresh:Group()
-- Refresj
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

--[[  __Static__() __Arguments__{ Class, { Type = String, Nilable = true, IsList = true } }
  function SelectTable(self, ...)
      local count = select("#", ...)

      if not CURRENT_TABLE then
        CURRENT_TABLE = self:Get()
      end
      local tb = CURRENT_TABLE
      for i = 1, count do
        local indexTable = select(i, ...)
          if not tb[indexTable] then
            tb[indexTable] = {}
          end

          tb = tb[indexTable]
      end
      CURRENT_TABLE = tb
  end--]]
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

        tb = tb[indexTable]
    end
    CURRENT_TABLE = tb

    return true
  end

  __Static__() __Arguments__{ Class }
  function SelectRoot(self)
    CURRENT_TABLE = self:Get()
  end

  __Static__() __Arguments__{ Class }
  function SelectRootChar(self)
    CURRENT_TABLE = self:GetChar()
  end

  __Static__() __Arguments__ { Class }
  function SelectRootSpec(self)
    CURRENT_TABLE = self:GetSpec()
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
--[[
__Final__()
interface "Options"
  _KEYWORDS = Dictionary()

  __Flags__()
  enum "ThemeKeywordType" {
    FRAME = 1,
    TEXT = 2,
    TEXTURE = 4,
  }

  struct "ThemeKeyword"
    target = String

    __Default__( ThemeKeywordType.FRAME )
    type = ThemeKeywordType

    __Default__("0094FF")
    flagColorStr = String

  endstruct "ThemeKeyword"

  function AddAvailableThemeKeywords(...)
    --print(self, ...)
    for i = 1, select('#', ...) do
      local keyword = select(i, ...)
      if not _KEYWORDS[keyword.target] then
        _KEYWORDS[keyword.target] = keyword
      end
    end
  end

  function GetAvailableThemeKeywords()
    return _KEYWORDS.Values:ToList():Sort("a,b=>a.target<b.target"):GetIterator()
  end
endinterface "Options"
--]]



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
_KEYWORDS = Dictionary()

OPTIONS = Dictionary()

-- @REVIEW Do that during the theme API update and create OptionRecipe!
__Flags__()
enum "ThemeKeywordType" {
  FRAME = 1,
  TEXT = 2,
  TEXTURE = 4,
}

-- @REVIEW Do that during the theme API update and create OptionRecipe!
struct "ThemeKeyword"
  target = String

  __Default__( ThemeKeywordType.FRAME )
  type = ThemeKeywordType

  __Default__("0094FF")
  flagColorStr = String

endstruct "ThemeKeyword"

-- @REVIEW Do that during the theme API update and create OptionRecipe!
__Static__()
function AddAvailableThemeKeywords(...)

  --print(self, ...)
  for i = 1, select('#', ...) do
    local keyword = select(i, ...)
    if not _KEYWORDS[keyword.target] then
      _KEYWORDS[keyword.target] = keyword
    end
  end
end

-- @REVIEW Do that during the theme API update and create OptionRecipe!
__Static__()
function GetAvailableThemeKeywords()
  return _KEYWORDS.Values:ToList():Sort("a,b=>a.target<b.target"):GetIterator()
end

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

__Static__() __Arguments__ { Class, String, Argument(Any, true, nil), Argument(Boolean, true, true)}
function Set(self, option, value, useHandler)
  -- select the current profile (global, char or spec)
  self:SelectCurrentProfile()

  Database:SelectTable("options")
  Database:SetValue(option, value)

  -- Call the handler if needed
  if useHandler then
    local opt = OPTIONS[option]
    if opt then
      opt(value)
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

      info:SetValue(1, keys)
      info:SetValue(2, vals)
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

  -- Some Theme function
  function GetThemeProperty(self, target, property, inherit, includeParent)
    if _Addon:GetCurrentTheme() then
      return _Addon:GetCurrentTheme():GetProperty(target, property, inherit, includeParent)
    end
  end

  function SetThemeProperty(self, target, property, value)
    if _Addon:GetCurrentTheme() then
      _Addon:GetCurrentTheme():SetProperty(target, property, value, true)
    end
  end

  function SetAndRefreshThemeProperty(self, target, property, value)
    if not target or not property then
      return
    end

    -- print(target, property, value)

    self:SetThemeProperty(target, property, value)


    local firstClass = strsplit(".", API:RemoveThemePropertyFlags(target), 2)


    Theme.RefreshGroup(firstClass)
  end

  function GetThemePropertyFlags(self, target)
    local flags = {}
    for flag in string.gmatch(target, "[%[@,](%w+)") do
      tinsert(flags, flag)
    end
    return flags
  end

  function RemoveThemePropertyFlags(self, target)
    return target:gsub("%[.*%]", "")
  end




  class "Config"
    _DEFAULT_VALUES = {}

    function GetOption(self, option)

    end

    function SetOption(self, option)

    end

    __Static__() __Arguments__ { String }
    function SelectDatabase(self, db)

    end

    function RegisterOption(self, option)
      -- name
      -- default =
      -- refresh callback
    end

  endclass "Config"
endinterface "API"
--------------------------------------------------------------------------------
--                   Base Frame class                                         --
--        All the frames must inherit from this class                         --
--------------------------------------------------------------------------------
class "Frame"
  _FrameCache = setmetatable( {}, { __mode = "k" })

  event "OnDrawRequest"
  event "OnWidthChanged"
  event "OnHeightChanged"
  event "OnSizeChanged"
  -- ======================================================================== --
  -- Handlers
  -- ======================================================================== --
  local function UpdateHeight(self, new, old, prop)
    if self.frame then
      self.frame:SetHeight(new)
    end
    return OnHeightChanged(self, new, old)
  end

  local function UpdateWidth(self, new, old, prop)
    if self.frame then
      self.frame:SetWidth(new)
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
  -- ======================================================================== --
  -- Methods                                                                  --
  -- ======================================================================== --
  __Arguments__ { Number }
  function SetWidth(self, width)
    self.width = width
    return OnSizeChanged(self, width, self.height)
  end

  __Arguments__{}
  function GetWidth(self)
    return self.width
  end

  __Arguments__{ Number }
  function SetHeight(self, height)
    self.height = height
    return OnSizeChanged(self, self.width, height)
  end

  __Arguments__{ Number, Number }
  function SetSize(self, width, height)
    self.width = width
    self.height = height
    return OnSizeChanged(self, width, height)
  end

  __Arguments__{}
  function GetSize(self)
    return self.width, self.height
  end


  function SetParent(self, parent)
    self.frame:SetParent(parent)
  end

  function GetParent(self)
    self.frame:GetParent()
  end


  __Arguments__{}
  function ClearAllPoints(self)
    self.frame:ClearAllPoints()
  end

  __Arguments__{}
  function Show(self)
    self.frame:Show()
  end

  __Arguments__{}
  function Hide(self)
    self.frame:Hide()
  end

  __Arguments__{}
  function IsShown(self)
    return self.frame:IsShown()
  end


  __Arguments__ { Argument(Table, true)}
  function MustBeInteractive(self, frame)

    if not frame then
      frame = self.frame
    end
    --[[]]
    --local xTop = frame:GetLeft()
    local yTop = frame:GetTop()

    --local xBot = frame:GetRight()
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

  __Static__() function RefreshAll()
    for obj in pairs(_FrameCache) do
      if obj.Refresh then
        obj:Refresh()
      end
    end
  end

  -- ======================================================================== --
  -- Properties
  -- ======================================================================== --
  property "frame" { TYPE = Table }
  property "width" { TYPE = Number, HANDLER = UpdateWidth }
  property "height" { TYPE = Number, HANDLER = UpdateHeight }
  property "baseHeight" { TYPE = Number }
  property "needToBeRedraw" { TYPE = Boolean, DEFAULT = false }
  property "tID" { TYPE = String, DEFAULT = "frame"}

  function Frame(self)
    self.OnDrawRequest = self.OnDrawRequest + OnDrawRequestHandler

    _FrameCache[self] = true
  end
endclass "Frame"

--------------------------------------------------------------------------------
--                          Theme System                                      --
--------------------------------------------------------------------------------
__Serializable__()
class "Theme" extend "ISerializable"
  _REGISTERED_FRAMES = {}
  _REFRESH_HANDLER = Dictionary()
  _KEYWORDS = List()


  __Static__() function SetAvailableKeywords(...)
    for i = 1, select('#', ...) do
      local keyword = select(i, ...)
      if not _KEYWORDS:Contains(keyword) then
        _KEYWORDS:Insert(keyword)
      end
    end
  end

  __Static__() function RegisterRefreshHandler(id, handler)
    local handlers
    if not _REFRESH_HANDLER[id] then
      handlers = {}
      _REFRESH_HANDLER[id] = handlers
    else
      handlers = _REFRESH_HANDLER[id]
    end
    tinsert(handlers, handler)
  end

  __Static__() function RefreshGroup(id)
    if _REFRESH_HANDLER[id] then
      local handlers = _REFRESH_HANDLER[id]
      for _, handler in ipairs(handlers) do
        handler()
      end
    end
  end

  __Static__() function RefreshGroups()
    Frame:RefreshAll()
  end

  __Arguments__ { String, Table, Argument(String, true), Argument(String, true, "FRAME")}
  __Static__() function RegisterFrame(keyword, frame, inherit, type)
    if not frame then
      return
    end

    if not type then
      type = "FRAME"
    end

    local frames = _REGISTERED_FRAMES[keyword]
    if not frames then
      frames = setmetatable( {}, { __mode = "k"})
      _REGISTERED_FRAMES[keyword] = frames
    end

    if frames[frame] then return end

    frames[frame] = true
    frame.themeClassID = keyword
    frame.type = type

    if inherit then
      frame.inheritTID = inherit
    end


    if frame.text then
      frame.text.themeClassID = keyword
      frame.text.type = "TEXT"
      if inherit then
        frame.text.inheritTID = inherit
      end
    end

    if frame.texture then
      frame.texture.themeClassID = keyword
      frame.texture.type = "TEXTURE"
      if inherit then
        frame.texture.inheritTID = inherit
      end
    end

    Theme.InstallScript(frame)
  end


  __Static__() function GetKeywords()
    return _KEYWORDS:GetIterator()
  end

  __Arguments__ { String, Table, Argument(String, true) }
  __Static__() function RegisterTexture(keyword, frame, inherit)
    Theme.RegisterFrame(keyword, frame, inherit, "TEXTURE")
  end

  __Arguments__ { String, Table, Argument(String, true) }
  __Static__() function RegisterText(keyword, frame, inherit)
    Theme.RegisterFrame(keyword, frame, inherit, "TEXT")
  end

  __Arguments__ { Table }
  __Static__() function InstallScript(frame)
    if not frame.GetScript or not frame.SetScript then
      return
    end

    if _Addon:GetCurrentTheme() and _Addon:GetCurrentTheme():HasFlag(frame.themeClassID, "hover", true) then
      local function FrameOnHover(f)
        if EQT.Frame:MustBeInteractive(f) then
          Theme.SkinFrame(frame, nil, "hover")
        else
          Theme.SkinFrame(frame)
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
          Theme.SkinFrame(frame)
        end)
      end


      if not frame:GetScript("OnMouseDown") and not frame:GetScript("OnMouseUp") then
        frame:SetScript("OnMouseDown", _Addon.ObjectiveTrackerMouseDown)
        frame:SetScript("OnMouseUp", _Addon.ObjectiveTrackerMouseUp)
      end

    end
  end

  __Arguments__ { Table }
  __Static__() function UnregisterFrame(self, frame)

  end

  __Arguments__ { { Type = String, Nilable = true, IsList = true } }
  __Static__() function GetFlagsString(...)
    local strFlags = ""
    for i = 1, select("#", ...) do
        v = select(i, ...)
        if i == 1 then
          strFlags = "@"..v
        else
          strFlags = strFlags..",@"..v
        end
    end
    return strFlags
  end

  __Arguments__ { Table, { Type = String, Nilable = true, IsList = true}}
  __Static__() function SkinTexture(texture, ...)
    local theme = _Addon:GetCurrentTheme()

    if not theme then return end -- TODO add error msg
    if not texture then return end  -- TODO add error msg

    local themeClassID = texture.themeClassID
    local inheritTID = texture.inheritTID

    if not themeClassID then return end -- TODO add error msg

    local flags = Theme.GetFlagsString(...)
    if flags ~= "" then
      themeClassID = themeClassID.."["..flags.."]"
      inheritTID = inheritTID and inheritTID.."["..flags.."]"
    end

    local color = theme:GetProperty(themeClassID, "vertex-color", inheritTID)

    --if color then
    texture:SetVertexColor(color.r, color.g, color.b, color.a )
  --end

  end

    -- @NOTE: No arguments attribute because the systeme can't know who is who in the args
    -- @TODO: Review the Skin arguments method in order to the arguements attribe can work.
  __Static__() function SkinText(fontstring, originText, ...)
    local theme = _Addon:GetCurrentTheme()

    if not theme then return end -- TODO add error msg
    if not fontstring then return end  -- TODO add error msg

    local themeClassID = fontstring.themeClassID
    local inheritTID = fontstring.inheritTID


    if not themeClassID then return end -- TODO add error msg

    local flags = Theme.GetFlagsString(...)
    if flags ~= "" then
      themeClassID = themeClassID.."["..flags.."]"
      inheritTID = inheritTID and inheritTID.."["..flags.."]"
    end

    local size = theme:GetProperty(themeClassID, "text-size", inheritTID)
    local font = _LibSharedMedia:Fetch("font", theme:GetProperty(themeClassID, "text-font", inheritTID))
    local transform = theme:GetProperty(themeClassID, "text-transform", inheritTID)
    fontstring:SetFont(font, size, "OUTLINE")

    local textColor = theme:GetProperty(themeClassID, "text-color", inheritTID)


    fontstring:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)


    local location = theme:GetProperty(themeClassID, "text-location", inheritTID)
    local offsetX = theme:GetProperty(themeClassID, "text-offsetX", inheritTID)
    local offsetY = theme:GetProperty(themeClassID, "text-offsetY", inheritTID)

    for i = 1, fontstring:GetNumPoints() do
      local point, relativeTo, relativePoint, xOffset, yOffset = fontstring:GetPoint(i)
      if i == 1 then
        fontstring:SetPoint(point, relativeTo, relativePoint, offsetX or xOffset, offsetY or yOffset)
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

    if transform == "uppercase" then
      txt = txt:upper()
    elseif transform == "lowercase" then
      txt = txt:lower()
    end

    fontstring:SetText(txt)
  end

  -- @NOTE: No arguments attribute because the systeme can't know who is who in the args
  -- @TODO: Review the Skin arguments method in order to the arguements attribe can work.
  __Static__() function SkinFrame(frame, originText, ...)

    local theme = _Addon:GetCurrentTheme()
    -- print("Current Theme", theme.name)

    if not theme then
      return
    end

    if not frame then
      return
    end

    if not frame.themeClassID then
      return
    end

    local themeClassID = frame.themeClassID
    local inheritTID = frame.inheritTID

    local flags = Theme.GetFlagsString(...)
    if flags ~= "" then
      themeClassID = themeClassID.."["..flags.."]"
      inheritTID = inheritTID and inheritTID.."["..flags.."]"
    end

    -- The frame is a normal frame
    if frame.type == "FRAME" then
      -- Background color
      local color
      if frame.SetBackdropColor then
        color = theme:GetProperty(themeClassID, "background-color", inheritTID)
        --print("F", frame.themeClassID, color.r, color.g, color.b, color.a)
        frame:SetBackdropColor(color.r, color.g, color.b, color.a)
      end

      if frame.SetBackdropBorderColor then
        color = theme:GetProperty(themeClassID, "border-color", inheritTID)
        frame:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
      end

      if frame.text then
        Theme.SkinText(frame.text, originText, ...)
      end

      if frame.texture then
        Theme.SkinTexture(frame.texture, ...)
      end
    end
  end


  _DEFAULT_PROPERTY_VALUES = {
    ["background-color"] = { r = 0, g = 0, b = 0, a = 0 },
    ["border-color"] = { r = 0, g = 0, b = 0, a = 0 },
    ["offsetX"] = 0,
    ["offsetY"] = 0,
    ["text-size"] = 10,
    ["text-font"] = "PT Sans Bold",
    ["text-color"] = { r = 0, g = 0, b = 0},
    ["text-transform"] = "none",
    ["text-location"] = "CENTER",
    ["text-offsetX"] = 0,
    ["text-offsetY"] = 0,
    ["vertex-color"] = { r = 1, g = 1, b = 1}
  }

  _DEFAULT_CLASSES = setmetatable({}, { __mode = "v"})

  -- Helper function
  local function UnpackTargets(...)
    local target = ""
    local count = select("#", ...)

    for i = 1, count do
      local val = select(i, ...)
      if i == 1 and i == count then
        return val, string.format("%s.*", val:gsub("(%[[\@%w]*\%])", ""))
      elseif i == 1 then
        target = val
      elseif i == count then
        local flags = val:match("[\[\|]([@,%w]*)") or ""
        if flags ~= "" then
           flags = "["..flags.."]"
        end
        local checkAll = "*"..flags

        return string.format("%s.%s", target, val),
        val ~= checkAll and string.format("%s.*%s", target, flags) or nil,
        string.format("%s%s", target, flags),
        count
      else
        target = target.."."..val
      end
    end
  end

  local function GetClassAmount(str)
    local _, count = str:gsub("%.", "")
    return count + 1
  end

  function _GetProperty(self, target, property)
    if _DB and _DB.Themes and _DB.Themes[self.name] then
      local dbTheme = _DB.Themes[self.name]
      --if dbTheme[target] and dbTheme[target][property] and  then
        --return dbTheme[target][property]
      --end
      if dbTheme.properties and dbTheme.properties[target] and dbTheme.properties[target][property] then
        return dbTheme.properties[target][property]
      end
    end

    if self.properties[target] and self.properties[target][property] then
      return self.properties[target][property]
    end
  end


  __Arguments__{ String, String, Argument(String, true), Argument(Boolean, true, true) }
  function GetProperty(self, target, property, inheritTarget, includeParent)
    local val = self:_GetProperty(target, property)

    if not includeParent then
      return val
    end

    if val then
      return val
    else
      local _, allTarget, parent, num = UnpackTargets(strsplit(".", target))

      val = self:_GetProperty(allTarget, property)
      if val then
        return val
      end

      val = self:_GetProperty(inheritTarget, property)
      if val then
        return val
      end

      if parent then
        return self:GetProperty(parent, property)
      end

      val = self:_GetProperty("*", property)
      if val then
        return val
      end
    end
    return _DEFAULT_PROPERTY_VALUES[property]
  end

  __Arguments__{ String, String }
  function GetDBProperty(self, target, property)
    if _DB and _DB.Themes and _DB.Themes[self.name] then
      local dbTheme = _DB.Themes[self.name]
      if dbTheme.properties and dbTheme.properties[target] and dbTheme.properties[target][property] then
        return dbTheme.properties[target][property]
      end
    end
  end

--[[
  __Arguments__{ String, String, Argument(String, true) }
  function GetProperty(self, target, property, inheritTarget)
    if self.properties[target] and self.properties[target][property] then
      return self.properties[target][property]
    else
      local _, allTarget, parent, num = UnpackTargets(strsplit(".", target))

      if allTarget and self.properties[allTarget] and self.properties[allTarget][property] then
        return self.properties[allTarget][property]
      end

      if inheritTarget and self.properties[inheritTarget] and self.properties[inheritTarget][property] then
        return self.properties[inheritTarget][property]
      end

      if parent then
        return self:GetProperty(parent, property)
      end

      if self.properties["*"] and self.properties["*"][property] then
        return self.properties["*"][property]
      end
    end
    return _DEFAULT_PROPERTY_VALUES[property]
  end

  -]]

  __Arguments__{ String }
  function GetProperty(self, property)
    return This.GetProperty(self, "*", property)
  end



  __Arguments__{ String, String, Argument(Boolean, true, false)}
  function HasProperty(self, target, property, includeParent)

    if self.properties[target] and self.properties[t] then
      return true
    end

    if includeParent then
      local isBlock = target:find("block")
      if isBlock then
        local _, name, _ = strsplit(".", target, 3)

        local t = string.format("block.%s.*", name)
        if self.properties[t] and self.properties[t][property] then
          return true
        end

        t = string.format("block.%s", name)
        if self.properties[t] and self.properties[t][property] then
          return true
        end

        t = "block.*"
        if self.properties[t] and self.properties[t][property] then
          return true
        end
      else
        local className, _ = strsplit(".", target, 2)

        t = string.format("%s.*", className)
        if self.properties[t] and self.properties[t][property] then
          return true
        end
      end
    end

    return false
  end

  function HasFlag(self, class, flag, includeParent)
    flag = "@"..flag
    local target = string.format("%s[%s]", class, flag)
    if self.properties[target] then
      return true
    end

    if includeParent then
      local isBlock = class:find("block")
      if isBlock then
        local _, name, _ = strsplit(".", class, 3)

        local t = string.format("block.%s.*[%s]", name, flag)
        if self.properties[t] then
          return true
        end

        t = string.format("block.%s[%s]", name, flag)
        if self.properties[t] then
          return true
        end

        t = "block.*"
        t = string.format("block.*[%s]", flag)
        if self.properties[t] then
          return true
        end
      else
        local className, _ = strsplit(".", class, 2)

        t = string.format("%s.*[%s]", className, flag)
        if self.properties[t] then
          return true
        end
      end
    end

    return false
  end


  function _SetProperty(self, target, property, value, saveInDB)
    local properties
    if saveInDB then
      if not _DB.Themes then _DB.Themes = {} end

      if not _DB.Themes[self.name] then
        _DB.Themes[self.name] = {}
        _DB.Themes[self.name].properties = {}
      end

      properties = _DB.Themes[self.name].properties
    else
      properties = self.properties
    end


    local targetProps = properties[target] and properties[target] or SDictionary()
    targetProps[property] = value

    if not properties[target] then
      properties[target] = targetProps
    end

  end

  function _ParseFlags(self, fstr)
    local flags = {}
    for flag in string.gmatch(fstr, "[\[\|]([@,%w]*)") do
      tinsert(flags, flag)
    end
    return flags
  end


  __Arguments__{ String, String, Argument(Any, true), Argument(Boolean, true, false) }
  function SetProperty(self, target, property, value, saveInDB)
    if target == "*" then
      self:_SetProperty(target, property, value, saveInDB)
    else
      local class, fstr = strsplit(".", target)
      if not fstr then
        self:_SetProperty(target, property, value, saveInDB)
        return
      end

      local flags = self:_ParseFlags(fstr)
      if #flags > 0 then
        _, _, fstr = fstr:find("(%w*)[\[]")
        for _, flag in pairs(flags) do
          target = string.format("%s.%s[%s]", class, fstr, flag)
          self:_SetProperty(target, property, value, saveInDB)
        end
      else
        self:_SetProperty(target, property, value, saveInDB)
      end
    end
  end

  __Arguments__{ String, Any }
  function SetProperty(self, property, value)
    This.SetProperty(self, "*", property, value)
  end

  function _SetScript(self,  target, script, funcStr)
    local targetScripts = self.scripts[target] and self.scripts[target] or SDictionary()
    targetScripts[script] = funcStr

    if not self.scripts[target] then
      self.scripts[target] = targetScripts
    end
  end

  __Arguments__{ String, String, String }
  function SetScript(self, target, script, funcStr)
      if target == "*" then
        self:_SetScript(target, script, funcStr)
      else
        local class, fstr = strsplit(".", target)
        if not fstr then
          return
        end

        local flags = self:_ParseFlags(fstr)
        if #flags > 0 then
          _, _, fstr = fstr:find("(%w*)[\[]")
          for _, flag in pairs(flags) do
            target = string.format("%s.%s[%s]", class, fstr, flag)
            self:_SetScript(target, script, funcStr)
          end
        else
          self:_SetScript(target, script, funcStr)
        end
      end
  end

  __Arguments__{ String, String }
  function SetScript(self, script, funcStr)
    This.SetScript(self, "*", script , funcStr)
  end

  __Arguments__{ String, String }
  function GetScript(self, target, script)
    -- tracker.name-OnHover
    local funcID  = target.."-"..script
    local funcStr = self.scripts[target] and self.scripts[target][property]

    --print("GetScript", funcID, funcStr)

    -- if we don't find it, check if the parent script exists
    if not funcStr then
      local class = strsplit(".", target)
      target = class..".*"
      if self.scripts[target] and self.scripts[target][script] then
        funcStr = self.scripts[target][script]
        funcID = class.."-"..script
      elseif self.scripts["*"] and self.scripts["*"][script] then
        funcStr = self.scripts["*"][script]
        funcID = "*-"..script
      else
        return
      end
    end

    if self.functionCache[funcID] then
      return self.functionCache[funcID]
    else
      local loadedFunction, errorString = loadstring("return " .. funcStr)
      if errorString then
        print(errorString)
      else
        local success, func = pcall(assert(loadedFunction))
        if success then
          self.functionCache[funcStr] = func
          return func
        end
      end
    end
  end

  __Arguments__{ String, String }
  function RegisterFont(self, fontID, fontFile)
    if _LibSharedMedia then
      _LibSharedMedia:Register("font", fontID, fontFile)
    end
  end

  function SetOption(self, option, value)
    self.options[option] = value
  end

  function GetOption(self, option)
    return self.options[option]
  end

  property "author" { TYPE = String }
  property "version" { TYPE = String }
  property "name" { TYPE = String }
  property "stage" { TYPE = String }
  property "func" { TYPE = String }
  --property "properties" { TYPE = SDictionary }

  -- Avoid to refresh the frames when the addons has been not finished its loading.
  __Static__()  property "refreshOnPropertyChanged" { DEFAULT = false }

  __Static__()
  function _RegisterClass(self, id, class)
    _DEFAULT_CLASSES[id] = class
  end

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

  __Arguments__{}
  function Theme(self)
    self.properties = SDictionary()
    self.scripts = SDictionary()
    self.options = SDictionary()
    self.functionCache = {}
  end

  __Arguments__{ SerializationInfo }
  function Theme(self, info)

    self.name = info:GetValue("name", String)
    self.author = info:GetValue("author", String)
    self.version = info:GetValue("version", String)
    self.stage = info:GetValue("stage", String)
    --self.frameProperties = info:GetValue("frameProperties", Table)
    self.properties = info:GetValue("properties", SDictionary)
    self.func = info:GetValue("func", String)
    self.scripts = info:GetValue("scripts", SDictionary)
    self.options = info:GetValue("options", SDictionary)

  end

endclass "Theme"
