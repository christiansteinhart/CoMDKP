local AddonName = "CoMDKP"
local CoMDKP = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceConsole-3.0");

local AceGUI = LibStub("AceGUI-3.0")
local LibQTip = LibStub('LibQTip-1.0')

local defaults = {
    profile = {
        points = {},
        names = {},
        history = {},
        attendance = {},
    }
}

function CoMDKP:OnInitialize()
    CoMDKP.db = LibStub("AceDB-3.0"):New("ComDKPDB", defaults, true)
end


function CoMDKP:OnEnable()
	CoMDKP.mainFrame = AceGUI:Create("Frame")
	CoMDKP.mainFrame:SetTitle("DKP Liste")
	CoMDKP.mainFrame:SetLayout("Flow")
	CoMDKP.mainFrame:SetWidth(600)
	CoMDKP.mainFrame:Hide()

	local importButton = AceGUI:Create("Button")
	importButton:SetText("Import")
	importButton:SetRelativeWidth(0.25)
	importButton:SetCallback("OnClick", function() CoMDKP:ShowImport() end)
	CoMDKP.mainFrame:AddChild(importButton)

	local exportButton = AceGUI:Create("Button")
	exportButton:SetText("Export")
	exportButton:SetRelativeWidth(0.25)
	exportButton:SetCallback("OnClick", function() CoMDKP:ShowExport() end)
	CoMDKP.mainFrame:AddChild(exportButton)

	local historyButton = AceGUI:Create("Button")
	historyButton:SetText("History")
	historyButton:SetRelativeWidth(0.25)
	historyButton:SetCallback("OnClick", function() CoMDKP:showHistory() end)
	CoMDKP.mainFrame:AddChild(historyButton)

	local helperButton = AceGUI:Create("Button")
	helperButton:SetText("LootFrameHelp")
	helperButton:SetRelativeWidth(0.25)
	helperButton:SetCallback("OnClick", function() CoMDKP:LootFrameHelp() end)
	CoMDKP.mainFrame:AddChild(helperButton)

	local scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
	scrollcontainer:SetFullWidth(true)
	scrollcontainer:SetFullHeight(true) -- probably?
	scrollcontainer:SetLayout("Fill") -- important!

	CoMDKP.mainFrame:AddChild(scrollcontainer)

	CoMDKP.scroll = AceGUI:Create("ScrollFrame")
	CoMDKP.scroll:SetLayout("Flow") -- probably?
	scrollcontainer:AddChild(CoMDKP.scroll)
end



CoMDKP:RegisterChatCommand("comdkp", "SlashCommand")
function CoMDKP:SlashCommand(msg, editbox)
	if msg == "debug" then
		for i, v in pairs(CoMDKP.db.profile.points) do
	  		print(i, v)
		end
		return
	end
	CoMDKP:ShowDKP()
end




function CoMDKP:ShowImport()
	local importDKPFrame = AceGUI:Create("Frame")
	importDKPFrame:SetTitle("Import DKP")
	importDKPFrame:SetWidth(400)
	importDKPFrame:SetCallback("OnClose", function(widget) widget:ReleaseChildren(); AceGUI:Release(widget) end)
	importDKPFrame:SetLayout("Flow")

	local editbox = AceGUI:Create("MultiLineEditBox")
	editbox:SetLabel("Insert text:")
	editbox:SetFullWidth(true)
	editbox:SetNumLines(20)
	importDKPFrame:AddChild(editbox)

	local button = AceGUI:Create("Button")
	button:SetText("Import DKP")
	button:SetWidth(200)
	button:SetCallback("OnClick", function() CoMDKP:Import(editbox:GetText()) end)
	importDKPFrame:AddChild(button)
end

function CoMDKP:Import(text)
	CoMDKP.db.profile.points = {}
	CoMDKP.db.profile.names = {}
	CoMDKP.db.profile.history = {}
    CoMDKP.db.profile.attendance = {}

	local name;
	for i in string.gmatch(text, "%S+") do
	  if name == nil 
	    then 
	      name = i
	    else
	      CoMDKP.db.profile.points[name] = i
	      table.insert(CoMDKP.db.profile.names, name)
	      name = nil
	  end
	end
	table.sort(CoMDKP.db.profile.names)
	CoMDKP:Refresh()
end

function CoMDKP:ShowExport()
	local exportText = CoMDKP:CreateExportString()
	local importDKPFrame = AceGUI:Create("Frame")
	importDKPFrame:SetTitle("Export DKP")
	importDKPFrame:SetWidth(400)
	importDKPFrame:SetCallback("OnClose", function(widget) widget:ReleaseChildren(); AceGUI:Release(widget) end)
	importDKPFrame:SetLayout("Flow")

	local editbox = AceGUI:Create("MultiLineEditBox")
	editbox:SetLabel("DKP Export:")
	editbox:SetFullWidth(true)
	editbox:SetNumLines(20)
	editbox:SetText(exportText)
	editbox:HighlightText(0, string.len(exportText))
	editbox:SetFocus()
	importDKPFrame:AddChild(editbox)
end

function CoMDKP:CreateExportString()
	local exportText = ""

	local dateText = date("%Y-%m-%d")
	local reason = "Lootzuweisung"

    local player, points

	for _, v in pairs(CoMDKP.db.profile.history) do
		player = v.player
		points = v.cost * -1
		exportText = exportText .. CoMDKP:CreateExportLine(player, points, reason, dateText)
	end


    reason = "Anwesenheit"
    for i, v in pairs(CoMDKP.db.profile.attendance) do
        player = i
        points = v * 100

        if points > 0 then
            exportText = exportText .. CoMDKP:CreateExportLine(player, points, reason, dateText)
        end
    end

	return exportText
end

function CoMDKP:CreateExportLine(player, points, reason, date)
	return player .. "\t" .. points .. "\t" .. reason  .. "\t" .. date .. "\n"
end

function CoMDKP:ShowDKP()
	CoMDKP:Refresh()
	CoMDKP.mainFrame:Show()
end

function CoMDKP:Refresh()
	CoMDKP.scroll:ReleaseChildren();
	for i, v in ipairs(CoMDKP.db.profile.names) do
  		CoMDKP.scroll:AddChild(CoMDKP:createDKPLine(v,CoMDKP.db.profile.points[v]))
	end
end

function CoMDKP:createDKPLine(player, points)
	local line = AceGUI:Create("SimpleGroup")
	line:SetFullWidth(true)
	line:SetLayout("Flow")

  	local checkAttend = AceGUI:Create("CheckBox")
	checkAttend:SetRelativeWidth(0.05)
  	checkAttend:SetTriState(true)
	checkAttend:SetCallback("OnValueChanged", function(widget, callback, value) CoMDKP:SetAttendance(widget:GetUserData("player"), value) end)
	checkAttend:SetUserData("player", player)
  	line:AddChild(checkAttend)

	local name = AceGUI:Create("Label")
	name:SetRelativeWidth(0.25)
  	name:SetText(player)
  	name:SetColor(255,255,255)
  	line:AddChild(name)

	local dkp = AceGUI:Create("Label")
	dkp:SetRelativeWidth(0.1)
  	dkp:SetText(points)
  	dkp:SetColor(255,255,255)
  	line:AddChild(dkp)

  	checkAttend:SetCallback("OnEnter", function () name:SetColor(255,0,0); dkp:SetColor(255,0,0) end)
  	checkAttend:SetCallback("OnLeave", function () name:SetColor(255,255,255); dkp:SetColor(255,255,255) end)

  	local btn50 = AceGUI:Create("Button")
  	btn50:SetRelativeWidth(0.15)
  	btn50:SetText("- 50%")
  	btn50:SetUserData("player", player)
  	btn50:SetCallback("OnClick", function(widget)
  		newDKP, cost = CoMDKP:adjustDKPByPercent(widget:GetUserData("player"), 50)
  		print(string.format("%s wurden %d Punkte abgezogen.", widget:GetUserData("player"), cost))
  		dkp:SetText(newDKP)
  	end)
  	btn50:SetCallback("OnEnter", function (widget)
        name:SetColor(255,0,0)
        dkp:SetColor(255,0,0)
        CoMDKP:ShowItemsTooltip(widget.frame, {"Trinket"})
    end)
  	btn50:SetCallback("OnLeave", function (widget)
        name:SetColor(255,255,255)
        dkp:SetColor(255,255,255)
        CoMDKP:HideItemsTooltip(widget.frame)
    end)
  	line:AddChild(btn50)

  	local btn33 = AceGUI:Create("Button")
  	btn33:SetRelativeWidth(0.15)
  	btn33:SetText("- 33%")
  	btn33:SetUserData("player", player)
  	btn33:SetCallback("OnClick", function(widget)
  		newDKP, cost = CoMDKP:adjustDKPByPercent(widget:GetUserData("player"), 33)
  		print(string.format("%s wurden %d Punkte abgezogen.", widget:GetUserData("player"), cost))
  		dkp:SetText(newDKP)
  	end)
  	btn33:SetCallback("OnEnter", function (widget)
        name:SetColor(255,0,0)
        dkp:SetColor(255,0,0)
        CoMDKP:ShowItemsTooltip(widget.frame, {"Set-Token", "Helm", "Brust", "Beine", "Relikte"})
    end)
  	btn33:SetCallback("OnLeave", function (widget)
        name:SetColor(255,255,255)
        dkp:SetColor(255,255,255)
        CoMDKP:HideItemsTooltip(widget.frame)
    end)
   	line:AddChild(btn33)

  	local btn25 = AceGUI:Create("Button")
  	btn25:SetRelativeWidth(0.15)
  	btn25:SetText("- 25%")
  	btn25:SetUserData("player", player)
  	btn25:SetCallback("OnClick", function(widget)
  		newDKP, cost = CoMDKP:adjustDKPByPercent(widget:GetUserData("player"), 25)
  		print(string.format("%s wurden %d Punkte abgezogen.", widget:GetUserData("player"), cost))
  		dkp:SetText(newDKP)
  	end)
  	btn25:SetCallback("OnEnter", function (widget)
        name:SetColor(255,0,0)
        dkp:SetColor(255,0,0)
        CoMDKP:ShowItemsTooltip(widget.frame, {"Schultern", "Hände", "Gürtel", "Füße"})
    end)
  	btn25:SetCallback("OnLeave", function (widget)
        name:SetColor(255,255,255)
        dkp:SetColor(255,255,255)
        CoMDKP:HideItemsTooltip(widget.frame)
    end)
  	line:AddChild(btn25)

  	local btn20 = AceGUI:Create("Button")
  	btn20:SetRelativeWidth(0.15)
  	btn20:SetText("- 20%")
  	btn20:SetUserData("player", player)
  	btn20:SetCallback("OnClick", function(widget)
  		newDKP, cost = CoMDKP:adjustDKPByPercent(widget:GetUserData("player"), 20)
  		print(string.format("%s wurden %d Punkte abgezogen.", widget:GetUserData("player"), cost))
  		dkp:SetText(newDKP)
  	end)	
  	btn20:SetCallback("OnEnter", function (widget)
        name:SetColor(255,0,0)
        dkp:SetColor(255,0,0)
        CoMDKP:ShowItemsTooltip(widget.frame, {"Hals", "Ring", "Rücken", "Armschienen"})
    end)
  	btn20:SetCallback("OnLeave", function (widget)
        name:SetColor(255,255,255)
        dkp:SetColor(255,255,255)
        CoMDKP:HideItemsTooltip(widget.frame)
    end)
  	line:AddChild(btn20)  	

  	return line
end

function CoMDKP:showHistory()
	local historyFrame = AceGUI:Create("Frame")
	historyFrame:SetTitle("DKP History")
	historyFrame:SetLayout("Flow")
	historyFrame:SetWidth(600)
	historyFrame:SetCallback("OnClose", function(widget) widget:ReleaseChildren(); AceGUI:Release(widget) end)

	local scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
	scrollcontainer:SetFullWidth(true)
	scrollcontainer:SetFullHeight(true) -- probably?
	scrollcontainer:SetLayout("Fill") -- important!

	historyFrame:AddChild(scrollcontainer)

	local scroll = AceGUI:Create("ScrollFrame")
	scroll:SetLayout("Flow") -- probably?
	scrollcontainer:AddChild(scroll)

	local header = {};
	header.player = "Spieler"
	header.before = "Punkte davor"
	header.after = "Punkte danach"
	header.cost = "Abzug"

	scroll:AddChild(CoMDKP:createHistoryLine(0,header,historyFrame))
	for i, v in ipairs(CoMDKP.db.profile.history) do
  		scroll:AddChild(CoMDKP:createHistoryLine(i,v,historyFrame))
	end
end

function CoMDKP:createHistoryLine(index, history, parent)
	local line = AceGUI:Create("SimpleGroup")
	line:SetFullWidth(true)
	line:SetLayout("Flow")

	local name = AceGUI:Create("Label")
	name:SetRelativeWidth(0.2)
  	name:SetText(history.player)
  	name:SetColor(255,255,255)
  	line:AddChild(name)

	local before = AceGUI:Create("Label")
	before:SetRelativeWidth(0.2)
  	before:SetText(history.before)
  	before:SetColor(255,255,255)
  	line:AddChild(before)

  	local after = AceGUI:Create("Label")
	after:SetRelativeWidth(0.2)
  	after:SetText(history.after)
  	after:SetColor(255,255,255)
  	line:AddChild(after)

  	local cost = AceGUI:Create("Label")
	cost:SetRelativeWidth(0.2)
  	cost:SetText(history.cost)
  	cost:SetColor(255,255,255)
  	line:AddChild(cost)

  	if (index ~= 0) then
	  	local undo = AceGUI:Create("Button")
	  	undo:SetRelativeWidth(0.2)
	  	undo:SetText("Rückgängig")
	  	undo:SetUserData("historyIndex", index)
	  	undo:SetCallback("OnClick", function(widget)
	  		CoMDKP:UndoHistory(widget:GetUserData("historyIndex"))
	  		parent:Hide()
	  	end)
	  	undo:SetCallback("OnEnter", function () 
	  		name:SetColor(255,0,0)
	  		before:SetColor(255,0,0)
	  		after:SetColor(255,0,0)
	  		cost:SetColor(255,0,0)
	  	end)
	  	undo:SetCallback("OnLeave", function ()
	  		name:SetColor(255,255,255)
	  		before:SetColor(255,255,255) 
	  		after:SetColor(255,255,255) 
	  		cost:SetColor(255,255,255) 
	  	end)
	  	line:AddChild(undo)
	end

  	return line
end

function CoMDKP:UndoHistory(index)
	local history = CoMDKP.db.profile.history[index]
	CoMDKP.db.profile.points[history.player] = CoMDKP.db.profile.points[history.player] + history.cost
	table.remove(CoMDKP.db.profile.history, index)
	CoMDKP:Refresh()
end

function CoMDKP:adjustDKPByPercent(player, percent)
	local basePoints = CoMDKP.db.profile.points[player]
	local cost = math.floor(basePoints / 100 * percent + 0.5)
	local newPoints = basePoints - cost
	CoMDKP.db.profile.points[player] = newPoints
	local history = {}
	history.player = player
	history.before = basePoints
	history.cost = cost
	history.after = newPoints
	table.insert(CoMDKP.db.profile.history, history)
	return newPoints, cost
end

function CoMDKP:SetAttendance(player, attendance)
	local ratio;
	if attendance == nil then 
		ratio = 0.5
	elseif attendance == true then
		ratio = 1
	else
		ratio = 0;
	end

	CoMDKP.db.profile.attendance[player] = ratio
end

function CoMDKP:LootFrameHelp()
	for i,playerFrame in ipairs(LootHistoryFrame.usedPlayerFrames) do
		playerFrameText = playerFrame.PlayerName:GetText()
		playerName = CoMDKP:ExtractPlayerNameFromLootFrameText(playerFrameText)
		if CoMDKP.db.profile.points[playerName] ~= nil then
			text = CoMDKP.db.profile.points[playerName]  .. " + " .. playerName;
			playerFrame.PlayerName:SetText(text)
		end
	end
end

function CoMDKP:ExtractPlayerNameFromLootFrameText(t)
    local p
    _, p = string.find(t, "+ ")
    if p == nil then
        return t
    end
    return string.sub(t, p+1, -1)
end


function CoMDKP:ShowItemsTooltip(frame, items)
    local tooltip = LibQTip:Acquire("ComDKPItemsTooltip", 1, "LEFT")
    frame.tooltip = tooltip
   
    for _, v in pairs(items) do
        tooltip:AddLine(v)
    end
   
    tooltip:SmartAnchorTo(frame)
    tooltip:Show()
end

function CoMDKP:HideItemsTooltip(frame)
    LibQTip:Release(frame.tooltip)
    self.tooltip = nil
end
