local ReplicatedStorage = game:GetService('ReplicatedStorage')

return function ()
    local Dependencies = require(ReplicatedStorage.dependencies)
    local WorkModelDependency = Dependencies.get('WorkModel')

    local MockPlayer = Instance.new('Folder') -- Mock object to avoid using Player
    MockPlayer.Name = 'MockPlayer'

    describe('WorkModel server unit tests', function()
        local _WorkModel

        beforeEach(function()
            _WorkModel = WorkModelDependency.new(MockPlayer)
        end)

        afterEach(function()
            _WorkModel:Destroy()
        end)

        it('.new call', function()
            expect(_WorkModel).to.be.ok()
        end)

        it('try hire on work', function()
            _WorkModel:TryHire('Test')
            expect(_WorkModel.data.Work.Value).to.be.equal('Test')

            _WorkModel:TryHire('Test2')
            expect(_WorkModel.data.Work.Value).never.be.equal('Test2')
        end)

        it('force hire on work', function()
            _WorkModel:TryHire('Test')
            expect(_WorkModel.data.Work.Value).to.be.equal('Test')

            _WorkModel:Hire('Test2')
            expect(_WorkModel.data.Work.Value).to.be.equal('Test2')
        end)

        it('try to fire from work -> without affect', function()
            _WorkModel:Hire('Test') -- Hire on work
            _WorkModel:TryFire('Test1') -- Fire from other work -> should do nothing

            expect(_WorkModel.data.Work.Value).to.be.equal("Test")
        end)

        it('try to fire from work -> with affect', function()
            _WorkModel:Hire('Test')
            _WorkModel:TryFire('Test')

            expect(_WorkModel.data.Work.Value).to.be.equal('')
        end)

        it('force fire from work', function()
            _WorkModel:Hire('Test')
            _WorkModel:Fire() -- Force fire

            expect(_WorkModel.data.Work.Value).to.be.equal('')
        end)
    end)
end