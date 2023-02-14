local DataInit = require(script.Parent:WaitForChild('DataInit'))

local Players = game:GetService('Players')

PLAYER_DATA = {
	CD = {

	},

	Values = {
		AInteract = true,
		AInventory = true,
		ABuilding = true,
		InventoryStatus = false,
	},

	Build = {
		GridScale = 2
	},
	
	Work = {
		WorkOn = "no",
		Meta = {}
	}
}

Players.PlayerAdded:Connect(function(player)
	DataInit.init({PlayerData = PLAYER_DATA}, player)
end)