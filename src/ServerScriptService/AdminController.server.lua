-- This is temp solve

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Dependencies = require(ReplicatedStorage.dependencies)
local WorkModelDependency = Dependencies.getFolder('WorkModel')

local Admins = {'KurumiFT'}
local Commands = {
    'work'
}

local Prefix: string = ':'

function checkOnCommand(player, command: string, ...: string)
    local Arguments = {...}
    if command == 'work' then
        if #Arguments < 1 then return end
        WorkModelDependency.Bindables.Hire:Fire(player, true, Arguments[1])
    end
end

Players.PlayerAdded:Connect(function(player: Player)
    if table.find(Admins, player.Name) then
        print('Admin')
        player.Chatted:Connect(function(message: string)
            if string.sub(message, 1, 1) == Prefix then
                checkOnCommand(player, unpack(string.split(string.sub(message, 2, #message + 1), ' ')))
            end
        end)
    end
end)

