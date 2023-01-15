-- This test requires atleast 1 player

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

local Dependencies = require(ReplicatedStorage.dependencies)
local QTEDependency_Folder: Folder = Dependencies.getFolder('QTE') 

local Remotes_Folder: Folder = QTEDependency_Folder.Remotes
local Add_Event: RemoteEvent = Remotes_Folder.Add
local Delete_Event: RemoteEvent = Remotes_Folder.Delete

function waitSteps(steps: number)
    for _ = 1, steps do
        RunService.Heartbeat:Wait()
    end
end

return function ()
    local _Callback: RemoteEvent = Instance.new('RemoteEvent')

    -- Wait till player joined
    repeat
        task.wait()
    until #Players:GetChildren() > 0

    local Target_Player = Players:GetChildren()[1]

    describe('LockPick QTE server integration tests', function()
        it('destroy callback', function()
            local flag: boolean = false

            _Callback.OnServerEvent:Connect(function(player: Player, state: boolean)
                if player ~= Target_Player then return end
                if not state then flag = true end
            end)

            Add_Event:FireClient(Target_Player, 'LockPick', {2, 3, _Callback})
            Delete_Event:FireClient(Target_Player, 'LockPick')

            waitSteps(2)

            expect(flag).to.be.ok(true)
        end)
    end)
end