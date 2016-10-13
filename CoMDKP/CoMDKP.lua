local AddonName = "CoMDKP"
local CoMDKP = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceConsole-3.0");

local AceGUI = LibStub("AceGUI-3.0")

CoMDKP.points = {}
CoMDKP.names = {}
CoMDKP.history = {}

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
	historyButton:SetCallback("OnClick", function() print ("Noch nicht implementiert") end)
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
		for i, v in pairs(CoMDKP.points) do
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
	CoMDKP.points = {}
	CoMDKP.names = {}
	local name;
	for i in string.gmatch(text, "%S+") do
	  if name == nil 
	    then 
	      name = i
	    else
	      CoMDKP.points[name] = i
	      table.insert(CoMDKP.names, name)
	      name = nil
	  end
	end
	table.sort(CoMDKP.names)
	CoMDKP:Refresh()
end

function CoMDKP:ShowExport()
	local exportText = ""
	for i, v in ipairs(CoMDKP.names) do
  		exportText = exportText .. v .. "\t" .. CoMDKP.points[v] .. "\n"
	end
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

function CoMDKP:ShowDKP()
	CoMDKP:Refresh()
	CoMDKP.mainFrame:Show()
end

function CoMDKP:Refresh()
	CoMDKP.scroll:ReleaseChildren();
	for i, v in ipairs(CoMDKP.names) do
  		CoMDKP.scroll:AddChild(CoMDKP:createDKPLine(v,CoMDKP.points[v]))
	end
end

function CoMDKP:createDKPLine(player, points)
	local line = AceGUI:Create("SimpleGroup")
	line:SetFullWidth(true)
	line:SetLayout("Flow")

	local name = AceGUI:Create("Label")
	name:SetRelativeWidth(0.2)
  	name:SetText(player)
  	name:SetColor(255,255,255)
  	line:AddChild(name)

	local dkp = AceGUI:Create("Label")
	dkp:SetRelativeWidth(0.2)
  	dkp:SetText(points)
  	dkp:SetColor(255,255,255)
  	line:AddChild(dkp)

  	local btn50 = AceGUI:Create("Button")
  	btn50:SetRelativeWidth(0.15)
  	btn50:SetText("- 50%")
  	btn50:SetUserData("player", player)
  	btn50:SetCallback("OnClick", function(widget)
  		newDKP, cost = CoMDKP:adjustDKPByPercent(widget:GetUserData("player"), 50)
  		print(string.format("%s wurden %d Punkte abgezogen.", widget:GetUserData("player"), cost))
  		dkp:SetText(newDKP)
  	end)
  	btn50:SetCallback("OnEnter", function () name:SetColor(255,0,0); dkp:SetColor(255,0,0) end)
  	btn50:SetCallback("OnLeave", function () name:SetColor(255,255,255); dkp:SetColor(255,255,255) end)
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
  	btn33:SetCallback("OnEnter", function () name:SetColor(255,0,0); dkp:SetColor(255,0,0) end)
  	btn33:SetCallback("OnLeave", function () name:SetColor(255,255,255); dkp:SetColor(255,255,255) end)
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
  	btn25:SetCallback("OnEnter", function () name:SetColor(255,0,0); dkp:SetColor(255,0,0) end)
  	btn25:SetCallback("OnLeave", function () name:SetColor(255,255,255); dkp:SetColor(255,255,255) end)
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
  	btn20:SetCallback("OnEnter", function () name:SetColor(255,0,0); dkp:SetColor(255,0,0) end)
  	btn20:SetCallback("OnLeave", function () name:SetColor(255,255,255); dkp:SetColor(255,255,255) end)
  	line:AddChild(btn20)

  	return line
end

function CoMDKP:adjustDKPByPercent(player, percent)
	local basePoints = CoMDKP.points[player]
	local cost = math.floor(basePoints / 100 * percent + 0.5)
	local newPoints = basePoints - cost
	CoMDKP.points[player] = newPoints
	local history = {}
	history.player = player
	history.before = basePoints
	history.cost = cost
	history.after = after
	table.insert(CoMDKP.history, history)
	return newPoints, cost
end

function CoMDKP:LootFrameHelp()
	for i,playerFrame in ipairs(LootHistoryFrame.usedPlayerFrames) do
		playerFrameText = playerFrame.PlayerName:GetText()
		for playerName in string.gmatch(playerFrameText, "%a+-?%a*") do
			if CoMDKP.points[playerName] ~= nil then
				text = CoMDKP.points[playerName]  .. " - " .. playerName;
				playerFrame.PlayerName:SetText(text)
			end
			break;
		end
	end
end
