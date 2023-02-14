local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Inventory assets, events etc
local kInventory = ReplicatedStorage:WaitForChild('kInventory')
local SwapEvent = kInventory:WaitForChild('Swap')
local RemoveEvent = kInventory:WaitForChild('Remove')
local hSet = kInventory:WaitForChild('hSet')
local hRemove = kInventory:WaitForChild('hRemove')
local EquipEvent = kInventory:WaitForChild('Equip')
local AddEvent = kInventory:WaitForChild('Add')

local kItemData = ReplicatedStorage:WaitForChild('kItemData')
local GetBindable = kItemData:WaitForChild('GetBindable')

local ItemsPrefabs = ReplicatedStorage:WaitForChild('Items')

local SlotsCount = 5 * 6

function getInventoryData(player)
	if not player:FindFirstChild("Data") then return end
	return player.Data:FindFirstChild("Inventory")
end

function getHotbarData(player)
	if not player:FindFirstChild("Data") then return end
	return player.Data:FindFirstChild("Hotbar")
end

function getItemInPlayer(player, id)
	local PlayerInventory = getInventoryData(player)
	if not PlayerInventory then return end
	
	return PlayerInventory:FindFirstChild(tostring(id))
end


function getItemInPlayerWithSlotIndex(player, index)
	local PlayerInventory = getInventoryData(player)
	if not PlayerInventory then return end
	
	for i,v in pairs(PlayerInventory:GetChildren()) do
		if v.SlotIndex.Value == index then return v end
	end
	
	return
end

function getItemPrefab(id)
	for i,v in pairs(ItemsPrefabs:GetChildren()) do
		if v.Configuration.ItemID.Value == id then return v end
	end
end

hRemove.OnServerEvent:Connect(function(player, id)
	local HotbarData = getHotbarData(player)
	for i,v in pairs(HotbarData:GetChildren()) do
		if v.Value == id then v.Value = -1 end
	end
end)

hSet.OnServerEvent:Connect(function(player, id, index) -- Hotbar Set event
	local BaseItem = getItemInPlayer(player, id)
	if not BaseItem then return end
	
	local HotbarData = getHotbarData(player)
	if not HotbarData:FindFirstChild(tostring(index)) then return end -- Exploit security
	for i,v in pairs(HotbarData:GetChildren()) do
		if v.Value == id then v.Value = -1 end
	end
	
	HotbarData[tostring(index)].Value = id
end)

EquipEvent.OnServerEvent:Connect(function(player, id) -- Equip with ID ~= -1 / Unequip with ID == 1
	if not player.Character then return end
	
	for i,v in pairs(player.Character:GetChildren()) do
		if v:IsA('Tool') then v:Destroy() end
	end
	
	if id == -1 then return end
	
	local BaseItem = getItemInPlayer(player, id)
	if not BaseItem then return end
	
	local ItemPrefab = getItemPrefab(id)
	if not ItemPrefab then return end
	ItemPrefab = ItemPrefab:Clone()
	ItemPrefab.Parent = player.Character
end) 

AddEvent.Event:Connect(function(player, id, count)
	local InventoryData = getInventoryData(player)
	local BusySlots = {} -- Busy slots index
	
	local ItemData = GetBindable:Invoke(id)
	
	for i,v in pairs(InventoryData:GetChildren()) do
		if v.Name == tostring(id) then
			if ItemData.stacking then
				v.Count.Value += count
				return
			end
		end
		
		table.insert(BusySlots, v.SlotIndex.Value)
	end
	
	for i = 1, SlotsCount do
		if not table.find(BusySlots, i) then
			local Item = Instance.new('Folder', InventoryData)
			Item.Name = tostring(id)
			
			local SlotIndex = Instance.new('IntValue', Item)
			SlotIndex.Name = "SlotIndex"
			SlotIndex.Value = i
			
			local Count = Instance.new('IntValue', Item)
			Count.Name = "Count"
			Count.Value = count
			return
		end
	end
end)

RemoveEvent.OnServerEvent:Connect(function(player, id, index)
	local Item = getItemInPlayerWithSlotIndex(player, index)
	if not Item then return end
	if Item.Name ~= tostring(id) then return end
	
	Item:Destroy()
	
	local HotbarData = getHotbarData(player)
	for i,v in pairs(HotbarData:GetChildren()) do
		if v.Value == id then v.Value = -1 end
	end
end)

SwapEvent.OnServerEvent:Connect(function(player, id, from, to)
	local BaseItem = getItemInPlayerWithSlotIndex(player, from)
	if not BaseItem then return end
	if BaseItem.Name ~= tostring(id) then return end
	
	local SlotItem = getItemInPlayerWithSlotIndex(player, to)
	if not SlotItem then
		BaseItem.SlotIndex.Value = to
	else
		SlotItem.SlotIndex.Value = BaseItem.SlotIndex.Value
		BaseItem.SlotIndex.Value = to
	end
end)