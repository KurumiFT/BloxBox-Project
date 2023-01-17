return function()
    local RunService = game:GetService('RunService')

    local ScriptModule = require(script.Parent)
    local NodeModule = require(script.Parent.Parent.Node)

    local function stepsWait(count: number)
        for _=1, count do
            RunService.Heartbeat:Wait()
        end
    end

    describe("Callback test", function()
        it("Callback attach",function()
            local _Script = ScriptModule()
            _Script:AttachCallback("Pointer", function() end)
        end)

        it("callback fire", function()
            local _Script = ScriptModule()
            _Script:AttachNode(NodeModule("Test1"))
            _Script:AttachNode(NodeModule("Test2"))
            _Script:SetPointer("Test1")
            _Script:AttachCallback("Pointer", function()
                _Script:RemoveNode("Test1")
            end)
            _Script:SetPointer("Test2")
            expect(_Script:GetNode("Test1")).never.be.ok()
        end)

        it("callback remove", function()
            local _Script = ScriptModule()
            _Script:AttachNode(NodeModule("Test1"))
            _Script:AttachNode(NodeModule("Test2"))
            _Script:SetPointer("Test1")
            _Script:AttachCallback("Pointer", function()
                _Script:RemoveNode("Test1")
            end)

            _Script:RemoveCallback("Pointer")
            _Script:SetPointer("Test2")
            expect(_Script:GetNode("Test1")).to.be.ok()
        end)

        it("callback function invoke", function()
            local _Script = ScriptModule()
            local _Node = NodeModule("Test1")
            local _TestChoice = _Node:NewChoice("Test")
            _TestChoice:SetAction("TestAction")
            _TestChoice:SetRedirect("Test2")
            _Script:AttachNode(_Node)
            _Script:AttachNode(NodeModule("Test2"))
            _Script:SetPointer("Test1")
            _Script:AttachCallback("Action", function(action)
                if action == "TestAction" then
                    _Script:RemoveNode("Test1")

                    expect(_Script:GetNode("Test1")).never.be.ok()
                end
            end)

            _Script:ProceedAction(_TestChoice)            
        end)

        it("callback function remove", function()
            local _Script = ScriptModule()
            local _Node = NodeModule("Test1")
            local _TestChoice = _Node:NewChoice("Test")
            _TestChoice:SetAction("TestAction")
            _TestChoice:SetRedirect("Test2")
            _Script:AttachNode(_Node)
            _Script:AttachNode(NodeModule("Test2"))
            _Script:SetPointer("Test1")
            _Script:AttachCallback("Action", function(action)
                if action == "TestAction" then
                    _Script:RemoveNode("Test1")
                end
            end)

            _Script:RemoveCallback("Action")
            _Script:ProceedAction(_TestChoice)            

            stepsWait(2)

            expect(_Script:GetNode("Test1")).to.be.ok()
        end)
    end)
end
