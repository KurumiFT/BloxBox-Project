local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Router = {} -- Route work string changes to events

local Dependencies = require(ReplicatedStorage.dependencies)

local Works_Folder = ReplicatedStorage.Works

Router._routes = { 
    ['Test'] = script.Parent.Bindables.Test, -- Using for tests
    ['Collector'] = Dependencies.getFolder('Collector').Bindables.Work,
    ['CarThief'] = Dependencies.getFolder('CarThief').Bindables.Work
}

local TestPrefix = 'Test'

local function isTest(route_string: string): boolean -- If this route was used for test
    local start_i, end_i = string.find(route_string, TestPrefix)
    if start_i == 1 then -- That's mean this test
        return true
    end

    return false
end

function Router.route(route_string: string, ...)
    if isTest(route_string) then -- If this was used for test
        Router._routes['Test']:Fire(...)
        return
    end

    if not Router._routes[route_string] then -- No route in table
        warn(string.format("This route string '%s' don't fire any event!", route_string))
        return
    end
    Router._routes[route_string]:Fire(...) -- Deletegate
end

return Router