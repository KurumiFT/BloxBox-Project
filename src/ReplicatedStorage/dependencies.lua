local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Dependencies = {}

local Dependencies_Parent = ReplicatedStorage

local Errors = { -- Enum with errors
    ['No dependency'] = "%s dependency is not registered",
    ['Error while require'] = "Error when require %s dependency"
}

Dependencies._table = { -- Add dependencies here
    ['TaskTracking'] = {Folder = ReplicatedStorage.TaskTracking, RequiredModule = ReplicatedStorage.TaskTracking.Task},
    ['BubblePrompt'] = {Folder = ReplicatedStorage.BubblePrompt, RequiredModule = ReplicatedStorage.BubblePrompt.BPrompt},
    ['CheckPoint'] = {Folder = ReplicatedStorage.CheckPoint, RequiredModule = ReplicatedStorage.CheckPoint.CheckPoint},
    ['WorkModel'] = {Folder = ReplicatedStorage.WorkModel, RequiredModule = ReplicatedStorage.WorkModel.Model},
    ['Collector'] = {Folder = ReplicatedStorage.Works.Collector, RequiredModule = ReplicatedStorage.Works.Collector.CollectorModel},
    ['CarThief'] = {Folder = ReplicatedStorage.Works.CarThief, RequiredModule = ReplicatedStorage.Works.CarThief.CarThiefModel},
    ['ProximityPrompt'] = {Folder = ReplicatedStorage.ProximityPrompt}, -- Structure of this module need to refactor (legacy)
    ['QTE'] = {Folder = ReplicatedStorage.QuickTimeEvents}, -- This havent's module
    ['LockPickQTE'] = {Folder = ReplicatedStorage.QuickTimeEvents.LockPick, RequiredModule = ReplicatedStorage.QuickTimeEvents.LockPick.LockPick}
}

function Dependencies.get(name: string) -- Get dependency require 
    assert(Dependencies._table[name], string.format(Errors['No dependency'], name))
    local successed, require =  pcall(function() -- Try require
        return require(Dependencies._table[name].RequiredModule)
    end)
    
    assert(successed, string.format(Errors['Error while require'], name))

    return require
end

function Dependencies.getFolder(name: string) -- Get dependency folder // For examle to get Remotes from another script
    assert(Dependencies._table[name], string.format(Errors['No dependency'], name))
    return Dependencies._table[name].Folder
end

return Dependencies