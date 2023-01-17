local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Dependencies = require(ReplicatedStorage.dependencies)
local CarThiefModelDependency = Dependencies.get('CarThief')
local CarThiefModelFolder: Folder = Dependencies.getFolder('CarThief')

local Bindables_Folder: Folder = CarThiefModelFolder.Bindables
local Work_Event: BindableEvent = Bindables_Folder.Work

local Models = {} -- Remembered models

Work_Event.Event:Connect(function(player, state) -- Listen work model change event
    if not state then
        if not Models[player] then return end
        Models[player]:Destroy()
        Models[player] = nil
    else
        if Models[player] then return end
        Models[player] = CarThiefModelDependency.new(player) -- Create model for this player
    end
end)