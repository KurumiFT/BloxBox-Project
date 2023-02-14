-- Data manager script made by Kurumi#5206 // vk.com/kurumitoshika

local DataStore2 = require(script:WaitForChild('DataStore2')) -- this script use DataStore2
local DataInit = require(script:WaitForChild('DataInit'))

local Players = game:GetService('Players')

local DB_KEY = '002' -- DataStore Name
local DB_AUTOSAVE = 5 -- Autosave DS in seconds
local DATA_TEMPLATE = { -- Put stores and default data for each one
	Inventory = {
		
	},
	Hotbar = {
		[1] = -1,
		[2] = -1
	},
	
	Economic = {
		Cash = 2000
	},
	
	Needs = {
		Hunger = 100,
		Hygiene = 100,
		Energy = 100,
		Fun = 100
	},

	Car = {
		Attempts = 3,
		LastAttempt = 0,
		Has = {}
	}
}
local PLAYERS_STORES = {}

DataStore2.Combine(DB_KEY, 'Car', 'Inventory', "Hotbar", "Needs", "Economic") -- After DB_KEY set EVERY used store(!) from DATA_TEMPLATE

function ConvertedData() -- Use if you want change data (For example - Random Race)
	-- TODO
	return DATA_TEMPLATE
end

function Reccursion(data_table) -- Needed for get data as table from folder
	local Rec_Data = {}

	for i,v in pairs(data_table:GetChildren()) do
		if v:IsA("Folder") then
			Rec_Data[v.Name] = Reccursion(v)
		else
			Rec_Data[v.Name] = v.Value
		end
	end

	return Rec_Data
end

Players.PlayerAdded:Connect(function(player) 
	local PLAYER_DATA = ConvertedData()
	
	PLAYERS_STORES[player] = {}
	
	for i,v in DATA_TEMPLATE do -- Put player's data into PLAYER_DATA
		PLAYERS_STORES[player][i] = DataStore2(i, player)
		PLAYER_DATA[i] = PLAYERS_STORES[player][i]:Get(PLAYER_DATA[i])
	end
	
	local DATA_FOLDER = DataInit.init({Data = PLAYER_DATA}, player) -- Data is name of data folder in player
	
	local function AutoSave()
		while wait(DB_AUTOSAVE) and DATA_FOLDER and player and PLAYERS_STORES[player] do
			local CURRENT_DATA = Reccursion(DATA_FOLDER)
			
			for i,v in pairs(CURRENT_DATA) do
				PLAYERS_STORES[player][i]:Set(v)
			end
		end
	end	
	
	spawn(AutoSave)
end)

Players.PlayerRemoving:Connect(function(player) -- Save player data and erase him for PLAYERS_STORES
	local DATA_FOLDER = player:FindFirstChild('Data') -- Data is name of data folder
	
	if DATA_FOLDER then
		local CURRENT_DATA = Reccursion(DATA_FOLDER)
		
		for i,v in pairs(CURRENT_DATA) do
			PLAYERS_STORES[player][i]:Set(v)
		end
	end
	
	PLAYERS_STORES[player] = nil
end) 