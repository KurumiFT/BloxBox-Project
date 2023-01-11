local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Dependencies = require(ReplicatedStorage.dependencies)
local CollectorModelDependency = Dependencies.get('Collector')
local CollectorModelFolder: Folder = Dependencies.getFolder('Collector')

local Bindables_Folder: Folder = CollectorModelFolder.Bindables
local Work_Event: BindableEvent = Bindables_Folder.Work

local Models = {} -- Remembered models

Work_Event.Event:Connect(function(player, state) -- Listen work model change event
    if not state then
        if not Models[player] then return end
        Models[player]:Destroy()
        Models[player] = nil
    else
        if Models[player] then return end
        Models[player] = CollectorModelDependency.new(player) -- Create model for this player
    end
end)

-- Debug part
Players.PlayerAdded:Connect(function(player)
    wait(10) -- For debug
    game.ReplicatedStorage.WorkModel.Bindables.Hire:Fire(player, false, 'Collector')
end)