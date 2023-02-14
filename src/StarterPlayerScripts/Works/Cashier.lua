local module = {}

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local ChatService = game:GetService('Chat')

local Player = Players.LocalPlayer

local Works_Folder = ReplicatedStorage:WaitForChild('Works')
local Cashier_Folder = Works_Folder:WaitForChild('Cashier')
local Events_Folder = Cashier_Folder:WaitForChild('Events')
local Task_Event = Events_Folder:WaitForChild('Task')
local LeaveEvent = Events_Folder:WaitForChild('Leave')
local kCashierProducts = Cashier_Folder:WaitForChild('Products')
local NpcPrefab = Cashier_Folder:WaitForChild('Npc')

local CashierPlots = workspace:WaitForChild('CashierPlot')

local Npc_Phrases = {"Hello! And also i want ", "Wassup bro, i want ", "Duuuuude you so cool, but i want also "}

local UI_Connections = {}

function iterPageItems(pages)
	return coroutine.wrap(function()
		local pagenum = 1
		while true do
			for _, item in ipairs(pages:GetCurrentPage()) do
				coroutine.yield(item, pagenum)
			end
			if pages.IsFinished then
				break
			end
			pages:AdvanceToNextPageAsync()
			pagenum = pagenum + 1
		end
	end)
end

-- prepare friends avatar
local userId = Players:GetUserIdFromNameAsync(Player.Name)
local friendPages = Players:GetFriendsAsync(userId)

local friends = {}
for item, _pageNo in iterPageItems(friendPages) do
	table.insert(friends, item.Id)
end

local FriendsPref_Folder = Instance.new('Folder', game.ReplicatedFirst)
FriendsPref_Folder.Name = 'FriendsAvatars'
for i = 1, math.min(10, #friends) do
	local friend_avatar = NpcPrefab:Clone()
	friend_avatar:PivotTo(CFrame.new(0, -50, 0))
	friend_avatar.Parent = workspace
	local fr = friends[i]
	local friendHumanoidDescription = Players:GetHumanoidDescriptionFromUserId(fr)
	friend_avatar.Humanoid:ApplyDescription(friendHumanoidDescription)
	
	spawn(function()
		wait(.1)
		friend_avatar.Parent = FriendsPref_Folder
	end)	
end
--



function render(plot, products)
	local SurfaceGui = plot.Display.Base.SurfaceGui 
	SurfaceGui.Enabled = true
	
	-- Clear products
	for i,v in pairs(plot.Items:GetChildren()) do
		v:Destroy()
	end
	
	for i,v in pairs(UI_Connections) do
		v:Disconnect()
		v = nil
	end
	
	if not products or #products == 0 then
		Task_Event:FireServer(true)
		return
	end
	
	for i,v in pairs(products) do
		local _Product = v:Clone()
		_Product.Parent = plot.Items
		_Product.CFrame = plot.Conveyor.Target.CFrame * CFrame.new(0, _Product.Size.Y / 2, 0) * CFrame.new(-(i-1) * 2, 0, 0)
	end
	
	local ProductsToRender = {products[1].Name}
	local SurfaceGuiChildren = SurfaceGui:GetChildren()
	
	for i,v in pairs(kCashierProducts:GetChildren()) do
		if table.find(ProductsToRender, v.Name) then continue end
		table.insert(ProductsToRender, v.Name)
		if #ProductsToRender == 4 then break end
	end
	
	while #ProductsToRender ~= 0 do -- Set on UI and make connecton
		local RandomIndex = math.random(1, #ProductsToRender)
		if ProductsToRender[RandomIndex] == products[1].Name then
			table.insert(UI_Connections, SurfaceGuiChildren[#ProductsToRender].Activated:Connect(function()
				local local_products = table.clone(products)
				table.remove(local_products, 1)
				render(plot, local_products)
			end))
		else
			table.insert(UI_Connections, SurfaceGuiChildren[#ProductsToRender].Activated:Connect(function()
				render(plot, products)
			end))
		end
		SurfaceGuiChildren[#ProductsToRender].Text = ProductsToRender[RandomIndex]
		table.remove(ProductsToRender, RandomIndex)
	end
end

Task_Event.OnClientEvent:Connect(function(plot, products, dishes)
	for i,v in pairs(plot.NPC_Spawn:GetChildren()) do v:Destroy() end -- Clear npcs
	
	local Prefab = FriendsPref_Folder:GetChildren()[math.random(1, #FriendsPref_Folder:GetChildren())]:Clone()
	Prefab.Parent = plot.NPC_Spawn
	Prefab:PivotTo(plot.NPC_Spawn.CFrame * CFrame.new(0, 3, 0))
	
	if #dishes ~= 0 then
		local dish_string = ""
		for i = 1, #dishes do
			if i > 1 then
				dish_string = dish_string + "and "..dishes[i].Name
			else
				dish_string = dishes[i].Name
			end
		end
		ChatService:Chat(Prefab.Head, Npc_Phrases[math.random(1, #Npc_Phrases)]..dish_string)
	end
	
	render(plot, products)
end)

LeaveEvent.OnClientEvent:Connect(function()
	for i,v in pairs(UI_Connections) do
		v:Disconnect()
	end 
	
	CashierPlots.Display.Base.SurfaceGui.Enabled = false
	for _, j in pairs(CashierPlots.Items:GetChildren()) do j:Destroy() end
	for _, j in pairs(CashierPlots.NPC_Spawn:GetChildren()) do j:Destroy() end
end)


return module
