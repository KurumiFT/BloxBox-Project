return function()
    local RunService = game:GetService("RunService")

    local PromptModule = require(script.Parent)
    local ScriptModule = require(script.Parent.Parent.Script)
    local NodeModule = require(script.Parent.Parent.Node)

    local CurrentCamera = workspace.CurrentCamera

    local function WorldToScreenPoint(position)
        local vector, onSreen = CurrentCamera:WorldToScreenPoint(position)
        return vector
    end

    local function stepsWait(count: number)
        for i = 1, count do
            RunService.Heartbeat:Wait()
        end
    end

    describe("Base render logic test", function()
        local _Prompt,_Script

        afterEach(function()
            _Prompt:Unrender()
        end)

        beforeEach(function()
            _Prompt = PromptModule()
            _Prompt:SetObject(workspace.TestPart)
            _Script = ScriptModule()
        end)

        it("set script", function()
            _Prompt:SetScript(_Script)
            expect(_Prompt.script).to.equal(_Script)
        end)

        it("set object", function()
            _Prompt:SetObject(workspace.Baseplate)
            expect(_Prompt.object).to.equal(workspace.Baseplate)
        end)

        it("set distance", function()
            _Prompt:SetDistance(10)
            expect(_Prompt.distance).to.equal(10)
        end)

        it("render without script", function()
            expect(function()
                _Prompt:Render()
            end).to.throw()
        end)

        it("render without default node", function()
            _Prompt:SetScript(_Script)
            expect(function()
                _Prompt:Render()
            end).to.throw()
        end)

        it("render without choices in node", function()
            local _Node = NodeModule("Test")
            _Script:AttachNode(_Node)
            _Script:SetDefault(_Node.name)
            _Prompt:SetScript(_Script)
            expect(function()
                _Prompt:Render()
            end).to.throw()
        end)

        it("render without target object", function()
            _Prompt:SetObject(nil)
            expect(function()
                _Prompt:Render()
            end).to.throw()
        end)
    end)

    describe("Render test", function()
        local _Prompt, _Script, _SingleNode, _RadialNode
        

        afterEach(function()
            _Prompt:Unrender()
        end)

        beforeEach(function()
            _Prompt = PromptModule()
            _Prompt:SetObject(workspace.TestPart)
            _Script = ScriptModule()
            _SingleNode = NodeModule("Single")    
            _SingleNode:NewChoice("Test", 0)
            _RadialNode = NodeModule("Radial")    
            _RadialNode:NewChoice("Test", 0)
            _RadialNode:NewChoice("Test", 0)
            _Script:AttachNode(_SingleNode)
            _Script:AttachNode(_RadialNode)
            _Script:SetDefault(_SingleNode.name)
            _Prompt:SetScript(_Script)
        end)

        it("render set connection", function()
            _Prompt:Render()
            expect(_Prompt.render_connection).to.be.ok()
        end)

        it("single frame instance", function()
            _Prompt:Render()
            expect(_Prompt:GetRenderFrame()).to.be.ok()
        end)

        it("radial frame instance", function()
            _Script:SetDefault(_RadialNode.name)
            _Prompt:Render()
            expect(_Prompt:GetRenderFrame()).to.be.ok()
        end)

        it("render create screen gui / game", function()
            _Prompt:Render()

            stepsWait(2)
            expect(_Prompt.screen_gui).to.be.ok()
        end)

        it("render add frames into screen gui / game", function()
            _Prompt:Render()

            stepsWait(2)
            expect(#_Prompt.screen_gui:GetChildren() > 0).to.be.ok()
        end)

        it("unrender delete screen gui / game", function()
            _Prompt:Render()

            stepsWait(2)
            _Prompt:Unrender()
            expect(_Prompt.screen_gui).never.to.be.ok()
        end)
    end)

    describe("Input test // test in game", function()
        local _Prompt, _Script, _SingleNode, _RadialNode, _Choice

        beforeEach(function()
            _Prompt = PromptModule()
            _Prompt:SetObject(workspace.TestPart)
            _Script = ScriptModule()
            _SingleNode = NodeModule("Single")    
            local _Choice = _SingleNode:NewChoice("Test", 0)
            _Choice:SetRedirect("Radial")
            _RadialNode = NodeModule("Radial")    
            _RadialNode:NewChoice("Test", 0)
            _RadialNode:NewChoice("Test", 0)
            _Script:AttachNode(_SingleNode)
            _Script:AttachNode(_RadialNode)
            _Script:SetDefault(_SingleNode.name)
            _Prompt:SetScript(_Script)
        end)

        afterEach(function()
            _Prompt:Unrender()
        end)

        it("press e / proceed single action without holding", function()
            _Prompt:Render()

            stepsWait(2)

            local fakeInputObject = {UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.E, UserInputState = Enum.UserInputState.Begin}
             _Prompt:UserInput(fakeInputObject)
             expect(_Prompt.script.ptr).to.equal(_RadialNode)    
        end)

        it("press e / proceed single action with holding", function()
            local _SingleDNode = NodeModule("SingleDuration")    
            local _Choice = _SingleDNode:NewChoice("Test", .01)
            _Script:AttachNode(_SingleDNode)
            _Script:SetDefault(_SingleDNode.name)
            _Choice:SetRedirect("Radial")
            _Prompt:Render()

            stepsWait(2)

            local fakeInputObject = {UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.E, UserInputState = Enum.UserInputState.Begin}

            _Prompt:UserInput(fakeInputObject)

            stepsWait(2)

            expect(_Prompt.script.ptr).to.equal(_RadialNode)
        end)

        it("press e / cancel single action with holding", function()
            local _SingleDNode = NodeModule("SingleDuration")    
            local _Choice = _SingleDNode:NewChoice("Test", 3)
            _Script:AttachNode(_SingleDNode)
            _Script:SetDefault(_SingleDNode.name)
            _Choice:SetRedirect("Radial")
            _Prompt:Render()

            stepsWait(2)

            local fakeInputObject = {UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.E, UserInputState = Enum.UserInputState.Begin}

            _Prompt:UserInput(fakeInputObject)

            stepsWait(2)

            fakeInputObject.UserInputState = Enum.UserInputState.End
            _Prompt:UserInput(fakeInputObject)

            expect(_Prompt.script.ptr).to.equal(_SingleDNode)
        end)

        it("touch frame / proceed single action without holding", function()
            _Prompt:Render()
            stepsWait(10)

            local fakeInputObject = {UserInputType = Enum.UserInputType.Touch, Position = WorldToScreenPoint(workspace.TestPart.Position), UserInputState = Enum.UserInputState.Begin}
            _Prompt:UserInput(fakeInputObject)

            stepsWait(2)

            expect(_Prompt.script.ptr).to.equal(_RadialNode)
        end)

        it("touch frame / proceed single action with holding", function()
            local _SingleDNode = NodeModule("SingleDuration")    
            local _Choice = _SingleDNode:NewChoice("Test", .05)
            _Script:AttachNode(_SingleDNode)
            _Script:SetDefault(_SingleDNode.name)
            _Choice:SetRedirect("Radial")
            _Prompt:Render()
            stepsWait(10)

            local fakeInputObject = {UserInputType = Enum.UserInputType.Touch, Position = WorldToScreenPoint(workspace.TestPart.Position), UserInputState = Enum.UserInputState.Begin}
            _Prompt:UserInput(fakeInputObject)

            stepsWait(8)
            fakeInputObject.UserInputState = Enum.UserInputState.End
            _Prompt:UserInput(fakeInputObject)

            expect(_Prompt.script.ptr).to.equal(_RadialNode)
        end)

        it("touch frame / cancel single action with holding", function()
            local _SingleDNode = NodeModule("SingleDuration")    
            local _Choice = _SingleDNode:NewChoice("Test", .3)
            _Script:AttachNode(_SingleDNode)
            _Script:SetDefault(_SingleDNode.name)
            _Choice:SetRedirect("Radial")
            _Prompt:Render()
            stepsWait(10)

            local fakeInputObject = {UserInputType = Enum.UserInputType.Touch, Position = WorldToScreenPoint(workspace.TestPart.Position), UserInputState = Enum.UserInputState.Begin}
            _Prompt:UserInput(fakeInputObject)

            stepsWait(2)
            fakeInputObject.UserInputState = Enum.UserInputState.End
            _Prompt:UserInput(fakeInputObject)

            expect(_Prompt.script.ptr).to.equal(_SingleDNode)
        end)
    end)
end