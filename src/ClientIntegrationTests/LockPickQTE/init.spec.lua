local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Player: Player = game.Players.LocalPlayer

return function ()
    local Dependencies = require(ReplicatedStorage.dependencies)
    local LockPickDependency = Dependencies.get('LockPickQTE')

    local function waitSteps(steps: number) -- Function for waits heatbeat steps
        for i = 1, steps do
            RunService.Heartbeat:Wait()
        end
    end

    describe("LockPick QTE client side integration tests", function()
        local _LockPick: table
        local _BindableEvent: BindableEvent = Instance.new('BindableEvent')
        beforeEach(function()
            _LockPick = LockPickDependency.new(2, 3, _BindableEvent)
        end)

        afterEach(function()
            _LockPick:Destroy()
        end)
        
        afterAll(function()
            _BindableEvent:Destroy()
        end)

        it('check callback if success', function()
            _LockPick.done_iterations = _LockPick.iterations
            
            local flag: boolean = false
            _BindableEvent.Event:Connect(function(state)
                if state then flag = true end  
            end)
            _LockPick:_iteration()
            waitSteps(1)
            expect(flag).to.be.equal(true)
        end)

        it('check callback if misses', function()
            _LockPick.errors = 10
            
            local flag: boolean = false
            _BindableEvent.Event:Connect(function(state)
                if not state then flag = true end  
            end)
            _LockPick:_iteration()
            waitSteps(1)
            expect(flag).to.be.equal(true)
        end)
    end)
end