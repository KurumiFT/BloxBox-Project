return function()
    local Handler = require(script.Parent)

    describe("Handler Constructor", function()
        it("__call", function()
            Handler()
        end)

        it("return table", function()
            expect(Handler()).to.be.ok()
        end)
    end)
end