local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Dependencies = require(ReplicatedStorage.dependencies)
local WorkModelDependency = Dependencies.get('WorkModel')
local WorkModelFolder = Dependencies.getFolder('WorkModel')

local Bindables_Folder = WorkModelFolder.Bindables
local Hire_Event = Bindables_Folder.Hire
local Fire_Event = Bindables_Folder.Fire

local Models = {}

Players.PlayerAdded:Connect(function(player) -- Added -> init model for this player
    local _Model = WorkModelDependency.new(player)
    Models[player.Name] = _Model -- As key i use player name
end)

Players.PlayerRemoving:Connect(function(player)
    if Models[player.Name] then
        Models[player.Name]:Destroy()
        Models[player.Name] = nil
    end
end)

Hire_Event.Event:Connect(function(owner: Player, force: boolean, work_string: string) -- Hire event
    if not Models[owner.Name] then return end
    if not force then -- If we just try to hire
        Models[owner.Name]:TryHire(work_string)
    else -- Else force 
        Models[owner.Name]:Hire(work_string)
    end
end)

Fire_Event.Event:Connect(function(owner: Player, force: boolean, work_string: string) -- Fire evet
    if not Models[owner.Name] then return end
    if not force then -- If we just try to fire
        Models[owner.Name]:TryFire(work_string)
    else -- Else force
        Models[owner.Name]:Fire()
    end
end)
