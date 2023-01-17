return function ()
    local PromptModule = require(script.Parent)

    describe("Constructor test", function()

        it("__call", function()
            expect(function()
               PromptModule() 
            end).never.to.throw()
        end)

        it("return table", function()
            expect(PromptModule()).to.be.ok()
        end)
    end)
end
