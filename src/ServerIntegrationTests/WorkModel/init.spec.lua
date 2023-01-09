local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

function waitSteps(count: number)
    for _ = 1, count do
        RunService.Heartbeat:Wait()
    end
end

return function ()
    local Dependencies = require(ReplicatedStorage.dependencies)
    local WorkModelDependency = Dependencies.get('WorkModel')
    local WorkModelFolder: Folder = Dependencies.getFolder('WorkModel')

    local Bindables_Folder: Folder = WorkModelFolder.Bindables
    local Test_Event: BindableEvent = Bindables_Folder.Test

    local MockPlayer: Folder = Instance.new('Folder') -- Instead real player we could use mock
    MockPlayer.Name = 'MockPlayer'

    describe('WorkModel server integration tests', function()
        local _WorkModel

        beforeEach(function()
            _WorkModel = WorkModelDependency.new(MockPlayer)
        end)

        afterEach(function()
            _WorkModel:Destroy()
        end)

        it('hire event handler', function()
            local flag = false
            local Connection
            Connection = Test_Event.Event:Connect(function(parent, state)
                if state == true then flag = true end
            end)

            _WorkModel:TryHire('Test')
            Connection:Disconnect()
            expect(flag).to.be.equal(true)
        end)

        it('fire event handler', function()
            local flag = false
            local Connection
            Connection = Test_Event.Event:Connect(function(parent, state)
                if state == false then flag = true end
            end)

            _WorkModel:TryHire('Test')
            _WorkModel:TryFire('Test')
            Connection:Disconnect()
            expect(flag).to.be.equal(true)
        end)

        it('fire + hire event handler', function()
            local counter = 0
            local Connection
            Connection = Test_Event.Event:Connect(function(parent, state)
                counter += 1
            end)

            _WorkModel:TryHire('Test')
            _WorkModel:TryFire('Test')
            Connection:Disconnect()
            expect(counter).to.be.equal(2)
        end)
    end)
end