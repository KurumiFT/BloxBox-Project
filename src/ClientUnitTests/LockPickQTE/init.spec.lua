local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Dependencies = require(ReplicatedStorage.dependencies)
local LockPickDependency = Dependencies.get('LockPickQTE')

return function ()
    describe('LockPick QTE client unit test', function()
        local _LockPick

        beforeEach(function()
            _LockPick = LockPickDependency.new(2, 3, nil)
        end)

        afterEach(function()
            _LockPick:Destroy()
        end)

        it('.new return table', function()
            expect(_LockPick).to.be.ok()
        end)

        it('.new create input connection', function()
            expect(_LockPick.input_connection).to.be.ok()
        end)

        it('for iteration created data of chink and cursor', function()
            expect(_LockPick.chink).to.be.ok()
            expect(_LockPick.cursor).to.be.ok()
        end)
    end)
end