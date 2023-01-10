local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Very base tests for collector work model

return function ()
    local Dependencies = require(ReplicatedStorage.dependencies)
    local CollectorDependencies = Dependencies.get('Collector')

    local MockPlayer = Instance.new('Folder')
    MockPlayer.Name = 'MockPlayer'

    describe('Collector model client unit tests', function()
        local _CollectorModel
        
        beforeEach(function()
            _CollectorModel = CollectorDependencies.new(MockPlayer)
        end)

        afterEach(function()
            _CollectorModel:Destroy()
        end)

        it('.new checks', function()
            expect(_CollectorModel.player).to.be.equal(MockPlayer)
            expect(_CollectorModel).to.be.ok()
        end)

        it('get random target', function()
            _CollectorModel:_pickATM()
            expect(_CollectorModel.target).to.be.ok()
        end)

        it('_entry create connection', function()
            _CollectorModel:_entry()
            expect(_CollectorModel.connection).to.be.ok()
        end)
    end)
end