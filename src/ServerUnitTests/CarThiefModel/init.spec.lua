local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Dependencies = require(ReplicatedStorage.dependencies)
local CarThiefModel = Dependencies.get('CarThief')

return function ()
    local MockPlayer = Instance.new('Folder')
    MockPlayer.Name = 'MockPlayer'

    describe('CarThief model client unit tests', function()
        local _Model

        beforeEach(function()
            _Model = CarThiefModel.new(MockPlayer)
        end)

        it('.new call', function()
            expect(_Model).to.be.ok()
        end)

        it('pick camera data', function()
            expect(_Model.camera_count).to.be.ok()
            expect(_Model.camera_list).to.be.ok()
        end)

        it('state init', function()
            expect(_Model.state).to.be.ok()
        end)
    end)
end