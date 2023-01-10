local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Dependencies = require(ReplicatedStorage.dependencies)
local CollectorModelDependency = Dependencies.get('Collector')

local Models = {} -- Remembered models

Players.PlayerAdded:Connect(function(player)
    wait(5) -- For debug

    local _Model = CollectorModelDependency.new(player)
    _Model:spawnCar()
end)