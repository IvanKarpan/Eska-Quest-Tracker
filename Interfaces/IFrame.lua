-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
namespace "EQT"
  interface "IFrame"

    event "OnWidthChanged"
    event "OnHeightChanged"
    event "OnSizeChanged"
    event "DrawRequested"
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

    -- ======================================================================== --
    -- Methods                                                                  --
    -- ======================================================================== --
    function SetWidth(self, width)
      self.width = width
      return OnSizeChanged(self, width, self.height)
    end

    function GetWidth(self)
      return self.width
    end

    function SetHeight(self, height)
      self.height = height
      return OnSizeChanged(self, self.width, height)
    end

    function GetHeight(self)
      return self.height
    end

    function SetSize(self, width, height)
      self.width = width
      self.height = height

      return OnSizeChanged(self, width, height)
    end

    function GetSize(self)
      return self.width, self.height
    end

    function SetParent(self, parent)
      self.frame:SetParent(parent)
    end

    function GetParent(self)
      self.frame:GetParent()
    end

    function ClearAllPoints(self)
      self.frame:ClearAllPoints()
    end

    function Show(self)
      self.frame:Show()
    end

    function Hide(self)
      self.frame:Hide()
    end

    function IsShown(self)
      return self.frame:IsShown()
    end

    -- ======================================================================== --
    -- Properties
    -- ======================================================================== --
    property "frame" { TYPE = Table }
    property "width" { TYPE = Number, HANDLER = UpdateWidth }
    property "height" { TYPE = Number, HANDLER = UpdateHeight }
    property "baseHeight" { TYPE = Number }
    property "baseWidth" { TYPE = Number }

  endinterface "IFrame"
