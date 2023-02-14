local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')


local Dependencies = require(ReplicatedStorage.dependencies)

-- Prompt block
-- local kPromptsAssets = ReplicatedStorage:WaitForChild('kPromptsAssets')
-- local kPromptsManage = kPromptsAssets:WaitForChild('Manage')
-- local PromptAddEvent = kPromptsManage:WaitForChild('Add')
-- local PromptRemoveEvent = kPromptsManage:WaitForChild('Remove')

local CashierPlot = workspace:WaitForChild('CashierPlot')

local ProximityPrompt_Folder: Folder = Dependencies.getFolder("ProximityPrompt")
local PPManage_Folder: Folder = ProximityPrompt_Folder.Manage
local AddPP_Event: RemoteEvent = PPManage_Folder:WaitForChild("Add")
local RemovePP_Event: RemoteEvent = PPManage_Folder:WaitForChild("Remove")
local Prompt_Module = require(ProximityPrompt_Folder:WaitForChild("Prompt"))
local Node_Module = require(ProximityPrompt_Folder:WaitForChild("Node"))
local Script_Module = require(ProximityPrompt_Folder:WaitForChild("Script"))

local Cashier_Folder = Dependencies.getFolder('Cashier')
local Events_Folder = Cashier_Folder:WaitForChild('Events')
local PromptEvent = Events_Folder:WaitForChild('Prompt')
local LeaveEvent = Events_Folder:WaitForChild('Leave')
local TaskEvent = Events_Folder:WaitForChild('Task')
local CashierProducts = Cashier_Folder:WaitForChild('Products')
local CashierDishes = Cashier_Folder:WaitForChild('Dishes')

local Bindables_Folder = Cashier_Folder:WaitForChild('Bindables')
local Work_Event = Bindables_Folder:WaitForChild('Work')

local PromisedPlayers = {}

function characterInit(character)
	-- local Player = Players:GetPlayerFromCharacter(character)
	-- for i,v in pairs(script.Parent:GetChildren()) do
	-- 	if not v:FindFirstChild('Display') then continue end
	-- 	PromptAddEvent:FireClient(Player, PromptNode.new(v.Equipment.PrimaryPart, 10, {{ScriptNode.new("Become a cashier", "Cashier_Join")}}))
	-- end
end

function bindHotdog(player)
	if not PromisedPlayers[player] then return end
	
    local Prompt = Prompt_Module()
    Prompt:SetObject(PromisedPlayers[player].Plot.Hotdog['1'].PrimaryPart)
    Prompt:SetDistance(10)

    local Script = Script_Module()
    Prompt:SetScript(Script)

    local SingleNode = Node_Module("Single")
    local SingleNodeChoice = SingleNode:NewChoice("Take the bun", .5)
    SingleNodeChoice:SetAction("Cashier_Hotdog")
    Script:AttachNode(SingleNode)
    Script:SetDefault(SingleNode.name)

    AddPP_Event:FireClient(player, Prompt)
end

function unbindHotdog(player)
	if not PromisedPlayers[player] then return end
	
	for i,v in pairs(PromisedPlayers[player].Plot.Hotdog:getChildren()) do
		RemovePP_Event:FireClient(player, v.PrimaryPart)
	end
end

function generateTask(player)
	unbindHotdog(player) -- Clear exists prompt
	
	local ProductsCount = math.random(1, 3)
	local Dish_Count = math.random(0, 1)
	
	local ProductList = {}
	local DishesList = {}
	local ProductsChildren = CashierProducts:GetChildren()
	local DishesChildren = CashierDishes:GetChildren()
	
	for i=1, ProductsCount do
		table.insert(ProductList, ProductsChildren[math.random(1, #ProductsChildren)])
	end
	
	for i = 1, Dish_Count do
		table.insert(DishesList, DishesChildren[i])
	end
	
	PromisedPlayers[player] = {Plot = PromisedPlayers[player].Plot,Products = ProductList, Dishes = DishesList}
	-- Bind dishes
	if table.find(DishesList, CashierDishes.Hotdog) then
		bindHotdog(player)
	end
end

function checkPlayerOnCashier(player)
	if player.PlayerData.Work.WorkOn.Value ~= "Cashier" then return false end
	return true
end

Players.PlayerAdded:Connect(function(player)
	if player.Character then characterInit(player.Character) end
	player.CharacterAdded:Connect(characterInit)
end)

PromptEvent.OnServerEvent:Connect(function(player, object, argument)
	if not player.Character then return end
	
	if argument == "Join" then
		joinJob(player)
	end
	
	if argument == "Hotdog" then
		if object.Parent.Parent.Name ~= "Hotdog" then return end
		if not PromisedPlayers[player] then return end
		local Stage = tonumber(object.Parent.Name)
		if Stage == 1 then
			RemovePP_Event:FireClient(player, object)
			
			if not table.find(PromisedPlayers[player].Dishes, CashierDishes.Hotdog) then return end
			
			local _Hotdog = CashierDishes['Hotdog']:Clone()
			_Hotdog.Parent = player.Character
			_Hotdog.Stage.Value = 1
			
            local Prompt = Prompt_Module()
            Prompt:SetObject(PromisedPlayers[player].Plot.Hotdog['2'].PrimaryPart)
            Prompt:SetDistance(10)
        
            local Script = Script_Module()
            Prompt:SetScript(Script)
        
            local SingleNode = Node_Module("Single")
            local SingleNodeChoice = SingleNode:NewChoice("Take the sausage", .5)
            SingleNodeChoice:SetAction("Cashier_Hotdog")
            Script:AttachNode(SingleNode)
            Script:SetDefault(SingleNode.name)
        
            AddPP_Event:FireClient(player, Prompt)
		elseif Stage == 2 then
            RemovePP_Event:FireClient(player, object)
			
			if not player.Character:FindFirstChild("Hotdog") then
				sendPlayerTask(player)
				return
			end
			
			if player.Character.Hotdog.Stage.Value ~= 1 then
				sendPlayerTask(player)
				return
			end
			
			player.Character.Hotdog.Stage.Value = 2

            local Prompt = Prompt_Module()
            Prompt:SetObject(PromisedPlayers[player].Plot.Hotdog['3'].PrimaryPart)
            Prompt:SetDistance(10)
        
            local Script = Script_Module()
            Prompt:SetScript(Script)
        
            local SingleNode = Node_Module("Single")
            local SingleNodeChoice = SingleNode:NewChoice("Take the sauce", .5)
            SingleNodeChoice:SetAction("Cashier_Hotdog")
            Script:AttachNode(SingleNode)
            Script:SetDefault(SingleNode.name)
        
            AddPP_Event:FireClient(player, Prompt)
		elseif Stage == 3 then
			RemovePP_Event:FireClient(player, object)
			
			if not player.Character:FindFirstChild("Hotdog") then
				sendPlayerTask(player)
				return
			end

			if player.Character.Hotdog.Stage.Value ~= 2 then
				sendPlayerTask(player)
				return
			end
			
			player.Character.Hotdog.Stage.Value = 3

            local Prompt = Prompt_Module()
            Prompt:SetObject(PromisedPlayers[player].Plot.Basket.PrimaryPart)
            Prompt:SetDistance(10)
        
            local Script = Script_Module()
            Prompt:SetScript(Script)
        
            local SingleNode = Node_Module("Single")
            local SingleNodeChoice = SingleNode:NewChoice("Put in", .5)
            SingleNodeChoice:SetAction("Cashier_Basket")
            Script:AttachNode(SingleNode)
            Script:SetDefault(SingleNode.name)
        
            AddPP_Event:FireClient(player, Prompt)
			return
		end
		return
	end
	
	if argument == "Basket" then
		RemovePP_Event:FireClient(player, object)
		if not PromisedPlayers[player] then return end
		local Hotdog = player.Character:FindFirstChild('Hotdog')
		
		if Hotdog then
			if Hotdog.Stage.Value == 3 then
				Hotdog:Destroy()
				table.remove(PromisedPlayers[player].Dishes, table.find(PromisedPlayers[player].Dishes, CashierDishes.Hotdog))
				if #PromisedPlayers[player].Dishes == 0 then
					if #PromisedPlayers[player].Products == 0 then
						print('Successful')
						sendPlayerTask(player)
					end
				end
			end
		end
		return
	end
	
	if argument == "Leave" then
		leaveJob(player)
        return
	end
end)

function sendPlayerTask(player)
	generateTask(player)
	TaskEvent:FireClient(player, PromisedPlayers[player].Plot, PromisedPlayers[player].Products, PromisedPlayers[player].Dishes)
end

function leaveJob(player)
    unbindHotdog(player)
	PromisedPlayers[player] = nil
    --TODO
	-- RemovePP_Event:FireClient(player, object)
	LeaveEvent:FireClient(player)
	characterInit(player.Character)
	return
end

function joinJob(player)
	-- Clear prompt
	-- for i,v in pairs (script.Parent:GetChildren()) do
	-- 	if not v:FindFirstChild('Display') then continue end
	-- 	PromptRemoveEvent:FireClient(player, v.Equipment.PrimaryPart)
	-- end
	-- PromptAddEvent:FireClient(player, PromptNode.new(object.Parent.Parent.Equipment.PrimaryPart, 10, {{ScriptNode.new("Quit his job", "Cashier_Leave")}}))

	PromisedPlayers[player] = {Plot = CashierPlot}
	generateTask(player)
	TaskEvent:FireClient(player, PromisedPlayers[player].Plot, PromisedPlayers[player].Products, PromisedPlayers[player].Dishes)
	return
end

Work_Event.Event:Connect(function(player, state)
    if not state then
        leaveJob(player)
    else
        if PromisedPlayers[player] then return end
        joinJob(player)
    end
end)

TaskEvent.OnServerEvent:Connect(function(player, state)
	if state then
		if not PromisedPlayers[player] then return end
		PromisedPlayers[player].Products = {} 
		if #PromisedPlayers[player].Dishes ~= 0 then return end
		
		sendPlayerTask(player)
	end
end)