local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local CharacterExamplar: Folder = ReplicatedStorage:WaitForChild('CharacterExamplar')

function CharacterAdded(character)
    local exist = CharacterExamplar:FindFirstChild(character.Name)
    if exist then
        exist:Destroy()
    end

    character.Archivable = true
    character:Clone().Parent = CharacterExamplar
    character.Archivable = false
end

Players.PlayerAdded:Connect(function(player)
    if player.Character then CharacterAdded(player.Character) end
    player.CharacterAdded:Connect(CharacterAdded)
end)