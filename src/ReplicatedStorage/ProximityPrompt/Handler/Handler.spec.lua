return function ()
    local RunService = game:GetService("RunService")

    local PromptModule = require(script.Parent.Parent.Prompt)
    local NodeModule = require(script.Parent.Parent.Node)
    local ScriptModule = require(script.Parent.Parent.Script)
    local HandlerModule = require(script.Parent)

    local function stepsWait(count: number) 
        for _ = 1, count do
            RunService.Heartbeat:Wait()
        end
    end

    describe("Prompt test", function()
        local _Prompt, _Script, _SingleNode, _RadialNode, _Handler

        beforeEach(function()
            _Handler = HandlerModule()
            _Prompt = PromptModule()
            _Prompt:SetObject(workspace.TestPart)
            _Prompt:SetDistance(20)
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
            _Handler:AddPrompt(_Prompt)
        end)

        afterEach(function()
            _Handler:Monitoring(false)
        end)

        it("set router", function()
            _Handler:SetRouter("test") -- please don't set string in Router, it waits module
            expect(_Handler.router).to.equal("test")
        end)

        it("add prompt", function()
            expect(#_Handler.prompts).to.equal(1)
        end)

        it("remove prompt", function()
            _Handler:RemovePrompt(workspace.TestPart)
            expect(#_Handler.prompts).to.equal(0)
        end)

        it("monitoring start", function()
            _Handler:Monitoring(true)
            expect(_Handler.connection).to.be.ok()
        end)

        it("nearest prompt", function()
            _Handler:Monitoring(true)
            _Prompt:SetDistance(1000)
            expect(_Handler:NearestPrompt()).to.be.ok()
        end)

        it("render nearest prompt", function()
            _Handler:Monitoring(true)
            _Prompt:SetDistance(1000)

            stepsWait(2)
            expect(_Handler.current_prompt).to.equal(_Prompt)
        end)

        it("unrender nearest prompt", function()
            _Handler:Monitoring(true)
            _Prompt:SetDistance(1000)

            stepsWait(2)
            _Prompt:SetDistance(0)
            stepsWait(2)
            expect(_Handler.current_prompt).never.be.ok()
        end)

        it("controller created", function()
            _Handler:Monitoring(true)
            _Prompt:SetDistance(1000)

            stepsWait(2)

            expect(_Handler.contoller_connection_begin).to.be.ok()
            expect(_Handler.controller_connection_end).to.be.ok()
        end)
    end)
end