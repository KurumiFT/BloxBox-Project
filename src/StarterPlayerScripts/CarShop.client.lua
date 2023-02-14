local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Controller = require(ReplicatedStorage.CarShop.Controller)
local CarDefinitions = require(ReplicatedStorage.CarShop.definition)

local c

CarDefinitions.Events.State.OnClientEvent:Connect(function(state)
    if not state then c:Destroy() 
    else c = Controller.new(Players.LocalPlayer) end
end)