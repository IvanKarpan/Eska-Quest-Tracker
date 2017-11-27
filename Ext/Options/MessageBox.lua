-- ========================================================================== --
-- 										 EskaQuestTracker                                       --
-- @Author   : Skamer <https://mods.curse.com/members/DevSkamer>              --
-- @Website  : https://wow.curseforge.com/projects/eska-quest-tracker         --
-- ========================================================================== --
Scorpio           "EskaQuestTracker.Options.MessageBox"                       ""
--============================================================================--
namespace "EQT"
--============================================================================--

class "MessageBox"
  _MESSAGE_BOX = nil


  __Arguments__ { Class, Argument(Table, true, UIParent), Argument(String, true, ""), Argument(String, true, ""), Argument(String, true, ""), Argument(Function, true), Argument(Function, true) }
  __Static__() function QuestionWithEditBox(self, parent, title, text, defaultValue, callback, checkfunc)
      self._InitFrame()
      _MESSAGE_BOX.frame:SetPoint("CENTER", parent, "CENTER")
      _MESSAGE_BOX:SetTitle(title)
      _MESSAGE_BOX:ReleaseChildren()
      _MESSAGE_BOX.frame:SetFrameStrata("TOOLTIP")
      _MESSAGE_BOX:Show()
      _AceGUI:SetFocus(_MESSAGE_BOX)

      local label = _AceGUI:Create("Label")
      label:SetText(text)
      label:SetFullWidth(true)
      _MESSAGE_BOX:AddChild(label)

      local status = _AceGUI:Create("Label")
      status:SetText("\n")
      status:SetFullWidth(true)
      _MESSAGE_BOX:AddChild(status)

      local editbox = _AceGUI:Create("EditBox")
      editbox:SetText(defaultValue)
      _MESSAGE_BOX:AddChild(editbox)

      local confirm = _AceGUI:Create("Button")
      confirm:SetText("Confirm !")
      confirm:SetDisabled(true)
      _MESSAGE_BOX:AddChild(confirm)

      -- callback
      editbox:SetCallback("OnEnterPressed", function(_, _, newText)
        if checkfunc then
          local check, msg = checkfunc(newText)
          if check then
            status:SetText(string.format("\n|cff00ff00%s|r", msg))
            confirm:SetDisabled(false)
          else
            status:SetText(string.format("\n|cffff0000%s|r", msg))
            confirm:SetDisabled(true)
          end
        else
          confirm:SetDisabled(false)
        end
      end)

      confirm:SetCallback("OnClick", function()
        if callback then
          callback(editbox:GetText())
        end
        _MESSAGE_BOX:Hide()
        end)

  end

  __Static__() function _InitFrame(self)
    if not _MESSAGE_BOX then
      _MESSAGE_BOX = _AceGUI:Create("Frame")
      _MESSAGE_BOX:SetHeight(175)
      _MESSAGE_BOX:SetWidth(300)
      _MESSAGE_BOX:EnableResize(false)
    end

  end



endclass "MessageBox"
