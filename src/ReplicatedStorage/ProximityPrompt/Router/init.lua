-- Custom module for route actions
-- Should contain .route(object, action) function

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProximityPrompt_Folder = ReplicatedStorage:WaitForChild("ProximityPrompt")
local Manage_Folder = ProximityPrompt_Folder:WaitForChild("Manage")

local Dependencies = require(ReplicatedStorage.dependencies)

local Routes = {
    ["General"] = Manage_Folder:WaitForChild("General"),
    ["CTLockPick"] = Dependencies.getFolder('CarThief').Remotes.ProximityPrompt
    -- ...
}
local Argument_Seperator = "_"

local Router = {}

function Router.route(object, action)
    if action == nil then return end 
    
    local SeperatedAction = string.split(action, Argument_Seperator)
    local Route = Routes[SeperatedAction[1]]; if not Route then return end
    local Arguments = table.clone(SeperatedAction); table.remove(Arguments, 1)
    Route:FireServer(object, unpack(Arguments))
end

return Router