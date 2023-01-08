local ReplicatedStorage = game:GetService('ReplicatedStorage')

local TestEz = require(ReplicatedStorage.TestEZ.TestBootstrap)

local UnitTestsPath = ReplicatedStorage.ClientUnitTests
local IntegrationTestsPath = ReplicatedStorage.ClientIntegrationTests

local Configuration: Configuration = script:WaitForChild('Configuration')
local Unit_Value: BoolValue = Configuration:WaitForChild('Unit')
local Integration_Value: BoolValue = Configuration:WaitForChild('I&T')

if Unit_Value.Value then
    print('Unit tests:')
    TestEz:run({UnitTestsPath})    
end

if Integration_Value.Value then
    print('Integration tests:')
    TestEz:run({IntegrationTestsPath})
end

