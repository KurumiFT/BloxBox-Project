local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Router = {} -- Route work string changes to events

local Works_Folder = ReplicatedStorage.Works
Router._routes = { 
    ['Collector'] = Works_Folder.Collector.Bindables.Work
}

function Router.route(route_string: string, ...)
    if not Router._routes[route_string] then
        warn(string.format("This route string '%s' don't fire any event!", route_string))
        return
    end

    Router._routes[route_string]:Fire(...)
end

return Router