local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Player: Player = game.Players.LocalPlayer
local Character: Model = Player.Character or Player.CharacterAdded:Wait()

return function ()
    local Dependencies = require(ReplicatedStorage.dependencies)
    local CheckPointDependency = Dependencies.get('CheckPoint')

    local function waitSteps(steps: number) -- Function for waits heatbeat steps
        for i = 1, steps do
            RunService.Heartbeat:Wait()
        end
    end

    describe("CheckPoint client side integration tests", function()
        local _CheckPoint
        beforeEach(function()
            _CheckPoint = CheckPointDependency.new('Test')
        end)

        afterEach(function()
            _CheckPoint:Destroy()
        end)

        it('check callback', function()
            local flag = false

            _CheckPoint:setRadius(20)
            _CheckPoint:setPosition(Character.HumanoidRootPart.Position)
            _CheckPoint:Spawn()

            local BEvent: BindableEvent = Instance.new('BindableEvent')

            _CheckPoint:listenCollisition(BEvent)
            BEvent.Event:Connect(function()
                flag = true
            end)

            waitSteps(2)

            expect(flag).to.be.equal(true)
        end)
    end)
end