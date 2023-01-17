return function()
    local Script = require(script.Parent)
    describe("Script Constructor", function()
        it("__call", function()
            Script("Test")
        end)

        it("return table", function()
            expect(Script("Test")).to.be.ok()
        end)
    end)
end