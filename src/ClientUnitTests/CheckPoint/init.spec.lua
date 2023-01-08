local ReplicatedStorage = game:GetService('ReplicatedStorage')

return function ()
    local Dependencies = require(ReplicatedStorage.dependencies)
    local CheckPointDependency = Dependencies.get('CheckPoint')

    describe("CheckPoint client test", function()
        local _CheckPoint

        beforeEach(function()
            _CheckPoint = CheckPointDependency.new('Test')
        end)

        afterEach(function()
            _CheckPoint:Destroy()
        end)

        it(".new call", function()
            expect(_CheckPoint).to.be.ok()
        end)

        -- it('set checkpoint type', function()
        --     expect(_CheckPoint.type).to.be.ok()
        -- end)

        it('set position', function()
            _CheckPoint:setPosition(Vector3.new(0, 0, 0))
            expect(_CheckPoint.position).to.be.equal(Vector3.new(0, 0, 0))
        end)

        it('set radius', function()
            _CheckPoint:setRadius(5)
            expect(_CheckPoint.radius).to.be.equal(5)
        end)

        it('spawn', function()
            _CheckPoint:setPosition(Vector3.new(0, 0, 0))
            _CheckPoint:setRadius(20)
            _CheckPoint:Spawn()

            expect(_CheckPoint.checkpoint).to.be.ok()
        end)

        it('collision check', function()
            _CheckPoint:setPosition(Vector3.new(0, 0, 0))
            _CheckPoint:setRadius(10)
            expect(_CheckPoint:_checkCollision(Vector3.new(1, 5, 0))).to.be.equal(true)
            expect(_CheckPoint:_checkCollision(Vector3.new(11, 5, 0))).to.be.equal(false)
            expect(_CheckPoint:_checkCollision(Vector3.new(1, 50, 0))).to.be.equal(false)
        end)   
    end)
end