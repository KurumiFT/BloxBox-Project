return function()
    local Node = require(script.Parent)

    describe("Node Constructor", function()
        it("__call", function()
            Node("Test")
        end)

        it("return table", function()
            expect(Node("Test")).to.be.ok()
        end)
    end)
end