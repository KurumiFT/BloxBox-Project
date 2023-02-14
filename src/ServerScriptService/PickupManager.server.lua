local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Dependencies = require(ReplicatedStorage.dependencies)
local ProximityPrompt_Folder: Folder = Dependencies.getFolder("ProximityPrompt")
local PPManage_Folder: Folder = ProximityPrompt_Folder.Manage
local AddPP_Event: RemoteEvent = PPManage_Folder:WaitForChild("Add")
local RemovePP_Event: RemoteEvent = PPManage_Folder:WaitForChild("Remove")
local Prompt_Module = require(ProximityPrompt_Folder:WaitForChild("Prompt"))
local Node_Module = require(ProximityPrompt_Folder:WaitForChild("Node"))
local Script_Module = require(ProximityPrompt_Folder:WaitForChild("Script"))

local Inventory_Folder = ReplicatedStorage:WaitForChild('kInventory')
local Pickup_Event = Inventory_Folder:WaitForChild('Pickup')
local Add_Event = Inventory_Folder:WaitForChild('Add')

local kItemData = ReplicatedStorage:WaitForChild('kItemData')
local GetBindable = kItemData:WaitForChild('GetBindable')

local Pickups = workspace:WaitForChild('Pickups')
local PickupDistance = 7

function characterAdded(character)
	local Player = Players:GetPlayerFromCharacter(character)

	for i,v in pairs(Pickups:GetChildren()) do
		if v.Name ~= "Handle" then continue end
		local ItemData = GetBindable:Invoke(v.ItemID.Value)
		local Prompt = Prompt_Module()
        Prompt:SetObject(v)
        Prompt:SetDistance(PickupDistance)

        local Script = Script_Module()
        Prompt:SetScript(Script)

        local SingleNode = Node_Module("Single")
        local SingleNodeChoice = SingleNode:NewChoice(string.format("Pickup %s", ItemData.display_name), 1.5)
        SingleNodeChoice:SetAction("Pickup")
        Script:AttachNode(SingleNode)
        Script:SetDefault(SingleNode.name)

        AddPP_Event:FireClient(Player, Prompt)
	end
end

Players.PlayerAdded:Connect(function(player)
	if player.Character then characterAdded(player.Character) end
	player.CharacterAdded:Connect(characterAdded)
end)

Pickups.ChildRemoved:Connect(function(obj)
	RemovePP_Event:FireAllClients(obj)
end)

Pickup_Event.OnServerEvent:Connect(function(player, object, args)
    local Character = player.Character
	if (Character.HumanoidRootPart.Position - object.Position).Magnitude > 10 then return end
	if not object:FindFirstChild('ItemID') then return end
	
	Add_Event:Fire(player, object.ItemID.Value, 1)
	object:Destroy()
end)