-- This test require atleast 1 player
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

return function ()
    local Dependencies = require(ReplicatedStorage.dependencies)
    local WorkModelDependency = Dependencies.get('WorkModel')

    repeat
        task.wait()
    until #Players:GetChildren() > 0
    local TargetPlayer = Players:GetChildren()[1] -- Wait until player added

    describe('WorkModel server unit tests', function()
        local _WorkModel

        beforeEach(function()
            _WorkModel = WorkModelDependency.new(TargetPlayer)
        end)

        afterEach(function()
            _WorkModel:Destroy()
        end)

        it('.new call', function()
            expect(_WorkModel).to.be.ok()
        end)

    end)
end