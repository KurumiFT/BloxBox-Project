local ReplicatedStorage = game:GetService('ReplicatedStorage')

return function ()
    describe("TaskTracking client test" ,function() 
        local Dependencies = require(ReplicatedStorage.dependencies)
        local TaskTrackingDependency = Dependencies.get('TaskTracking')
        
        local _Task

        afterEach(function()
            _Task:unRender()
        end)

        beforeEach(function()
            _Task = TaskTrackingDependency.new()
        end)

        it(".new call", function()
            expect(_Task).to.be.ok()
        end)

        it("task header", function()
            _Task:setHeader('Test')
            expect(_Task.header).to.be.equal('Test')
        end)

        it("task description", function()
            _Task:setDescription('Test task')
            expect(_Task.description).to.be.equal('Test task')
        end)

        it("task progress", function()
            _Task:setProgression(0, 1)
            expect(_Task.progression).to.be.ok()
        end)

        it("task render frame", function()
            _Task:setHeader('Test')
            _Task:setDescription('Hire on work <font color="#FA7298">Loader</font>')
            _Task:setProgression(1, 10)
            _Task:Render()
            expect(_Task.frame).to.be.ok()
        end)

        it("task render create render connection", function()
            _Task:setHeader('Test')
            _Task:setDescription('Hire on work <font color="#FA7298">Loader</font>')
            _Task:setProgression(1, 10)
            _Task:Render()
            expect(_Task.render_connection).to.be.ok()
        end)

        it("task :unRender destroy connection", function()
            _Task:setHeader('Test')
            _Task:setDescription('Hire on work <font color="#FA7298">Loader</font>')
            _Task:setProgression(1, 10)
            _Task:Render()
            _Task:unRender()
            expect(_Task.render_connection).never.be.ok()
        end)
    end) 
end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             