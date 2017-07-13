-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio            "EskaQuestTracker.Attributes"                              ""
-- ========================================================================== --
namespace "EQT"
-- ========================================================================== --
-- __DBTextOptions__(dbTable, hasMultipleFonts)
__AttributeUsage__{ AttributeTarget = AttributeTargets.Class, RunOnce = true, BeforeDefinition = true }
  class "__DBTextOptions__" (function(_ENV)
    extend "IAttribute"

    _TMP_DB_TABLE = nil
    _TMP_DB_HAS_MULTIPLE_FONTS = nil
    _CLASSES_DB_TABLE = {}

    local function GetDB(class)
      local db = _CLASSES_DB_TABLE[class]
      if type(db) == "function" then
        db = db()
      end
      return db
    end

    function ApplyAttribute(target, targetType)
      _CLASSES_DB_TABLE[targetType] = _TMP_DB_TABLE

      if _TMP_DB_HAS_MULTIPLE_FONTS then

        __Static__()
        function targetType:SetTextSize(index, size)
          GetDB(self).textSizes[index] = size
          if self.RefreshAll then self:RefreshAll() end
        end

        __Static__()
        function targetType:GetTextSize(index)
          return GetDB(self).textSizes[index]
        end

        __Static__()
        function targetType:SetTextFont(index, font)
          GetDB(self).textFonts[index] = font
          if self.RefreshAll then self:RefreshAll() end
        end

        __Static__()
        function targetType:GetTextFont(index)
          return  GetDB(self).textFonts[index]
        end

        __Static__()
        function targetType:SetTextColor(index, color)
          GetDB(self).textColors[index] = color
          if self.RefreshAll then self:RefreshAll() end
        end

        __Static__()
        function targetType:GetTextColor(index)
          return GetDB(self).textColors[index]
        end

        __Static__()
        function targetType:SetTextTransform(index, transform)
          GetDB(self).textTransforms[index] = transform
          if self.RefreshAll then self:RefreshAll() end
        end

        __Static__()
        function targetType:GetTextTransform(index)
          return  GetDB(self).textTransforms[index]
        end

      else
        targetType.textSize = __Static__ {
          TYPE = System.Number,
          GET = function(self) return GetDB(self).textSize end,
          SET = function(self, size) GetDB(self).textSize = size
            if self.RefreshAll then self:RefreshAll() end
          end
        }

        targetType.textFont = __Static__ {
          TYPE = System.String,
          GET = function(self) return GetDB(self).textFont end,
          SET = function(self, font) GetDB(self).textFont = font
            if self.RefreshAll then self:RefreshAll() end
          end
        }

        targetType.textColor = __Static__ {
          TYPE = System.Any,
          GET = function(self) return  GetDB(self).textColor end,
          SET = function(self, color) GetDB(self).textColor = color
            if self.RefreshAll then self:RefreshAll() end
          end
        }

        targetType.textTransform = __Static__ {
          TYPE = System.String,
          GET = function(self) return GetDB(self).textTransform end,
          SET = function(self, transform) GetDB(self).textTransform = transform
            if self.RefreshAll then self:RefreshAll() end
          end,
        }
      end

    end

    __Arguments__{ Table + Function, Argument(Boolean, true, true, "hasMultipleFonts")}
    function __DBTextOptions__(self, dbTable, hasMultipleFonts)
      _TMP_DB_TABLE = dbTable
      _TMP_DB_HAS_MULTIPLE_FONTS = hasMultipleFonts
    end

  end)

-- __InitChildBlockDB__ "dbName used"
  __AttributeUsage__{ AttributeTarget = AttributeTargets.Class, RunOnce = true, BeforeDefinition = true }
    class "__InitChildBlockDB__" (function(_ENV)
      extend "IAttribute"

      _TMP_DB_NAME = nil


      local function GetDBValue(dbName, property)
        if not _DB.Block.childs then
          _DB.Block.childs = {}
          return _DB.Block[property]
        end

        if not _DB.Block.childs[dbName] then
          _DB.Block.childs[dbName] = {}
          return _DB.Block[property]
        end

        if not _DB.Block.childs[dbName][property] then
          return _DB.Block[property]
        end

        return _DB.Block.childs[dbName][property]
      end

      local function CheckDB(dbName)
        if not _DB.Block then
          _DB.Block = {}
        end

        if not _DB.Block.childs then
          _DB.Block.childs = {}
        end

        if not _DB.Block.childs[dbName] then
          _DB.Block.childs[dbName] = {}
          _DB.Block.childs[dbName].customProperties = {}
        end
      end

      function ApplyAttribute(target, targetType)
        local dbName = tostring(targetType)

        targetType.customConfigEnabled = __Static__ {
          TYPE = System.Boolean,
          GET = function()
            if _DB.Block.childs and _DB.Block.childs[dbName] and _DB.Block.childs[dbName].customConfigEnabled then
              return _DB.Block.childs[dbName].customConfigEnabled
            end
            return false
          end,
          SET = function(self, enabled)
            CheckDB(dbName)
            _DB.Block.childs[dbName].customConfigEnabled = enabled
            self:RefreshAll()
          end,
        }


        __Static__()
        function targetType:BlockPropertyExists(property)
          if _DB.Block.childs and _DB.Block.childs[dbName] and _DB.Block.childs[dbName].customProperties
          and _DB.Block.childs[dbName].customProperties[property]
          and _DB.Block.childs[dbName].customProperties[property].value then
            return true
          else
            return false
          end
        end

        __Static__()
        function targetType:IsBlockPropertyEnabled(property)
          if not targetType.customConfigEnabled then
            return false
          end

          if _DB.Block.childs and _DB.Block.childs[dbName] and _DB.Block.childs[dbName].customProperties
            and _DB.Block.childs[dbName].customProperties[property]
            and _DB.Block.childs[dbName].customProperties[property].enabled then
            return true
          else
            return false
          end
        end

        __Static__()
        function targetType:GetBlockProperty(property)
          if not targetType:BlockPropertyExists(property) or not targetType:IsBlockPropertyEnabled(property) then
            return _DB.Block[property]
          end


            return _DB.Block.childs[dbName].customProperties[property].value
        end


        __Static__()
        function targetType:SetBlockPropertyValue(property, value)
          CheckDB(dbName)

          if _DB.Block.childs[dbName].customProperties[property] then
            _DB.Block.childs[dbName].customProperties[property].value = value
          else
            _DB.Block.childs[dbName].customProperties[property] = {
              enabled = true,
              value = value ,
            }
          end

          targetType:RefreshAll()
        end

          __Static__()
          function targetType:SetBlockPropertyEnabled(property, enabled)
            CheckDB(dbName)

            if _DB.Block.childs[dbName].customProperties[property] then
              _DB.Block.childs[dbName].customProperties[property].enabled = enabled
            else
              _DB.Block.childs[dbName].customProperties[property] = {
                enabled = enabled,
              }
            end
            targetType:RefreshAll()
          end




        targetType.backdropColor = __Static__ {
          TYPE = Table,
          GET = function(self) return GetDBValue(dbName, "backdropColor") end,
          SET = function(self, color)
            _DB.Block.childs[dbName].backdropColor = color
          end
        }

        targetType.borderColor = __Static__ {
          TYPE = Table,
          GET = function() return GetDBValue(dbName, "borderColor") end,
          SET = function(_, color)
            _DB.Block.childs[dbName].borderColor = color
          end
        }

      end

    end)
