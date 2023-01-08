local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Dependencies
local Dependencies = require(ReplicatedStorage.dependencies)
local CheckPointDependency = Dependencies.get('CheckPoint')
local CheckPointFolder: Folder = Dependencies.getFolder('CheckPoint')

-- Remotes
local CheckPointRemotes: Folder = CheckPointFolder.Remotes
local Add_Event: RemoteEvent = CheckPointRemotes.Add
local Delete_Event: RemoteEvent = CheckPointRemotes.Delete

-- Bindables
local CheckPointBindables: Folder = CheckPointFolder.Bindables
local BAdd_Event: BindableEvent = CheckPointBindables.Add
local BDelete_Event: BindableEvent = CheckPointBindables.Delete

local CheckPoints = {}

local GarbageCollectorPer: number = 10 -- Delay between garbage collector iteration

function Add(name: string, radius: number, position: Vector3, callback: RemoteEvent | BindableEvent | nil)
    if CheckPoints[name] then -- If already this checkpoint exist
        CheckPoints[name]:Destroy()
    end

    local _CheckPoint = CheckPointDependency.new(name)
    _CheckPoint:setRadius(radius)
    _CheckPoint:setPosition(position)
    _CheckPoint:listenCollisition(callback) -- Toggle on collision listener
    _CheckPoint:Spawn()

    CheckPoints[name] = _CheckPoint -- Write this checkpoint to table
end

function Delete(name: string) -- Remove callback by name // %all% to delete all checkpoints
    if name == '%all%' then -- Remove all checkpoints if equals
        for key, checkpoint in pairs(CheckPoints) do
            checkpoint:Destroy()
            CheckPoints[key] = nil
        end
        
        return
    end

    if CheckPoints[name] then
        CheckPoints[name]:Destroy()
        CheckPoints[name] = nil
    end
end

-- Server -> client requests handler + delegation
Add_Event.OnClientEvent:Connect(Add)
Delete_Event.OnClientEvent:Connect(Delete)

-- Client -> client requests handler + delegation
BAdd_Event.Event:Connect(Add)
BDelete_Event.Event:Connect(Delete)


task.defer(function() -- Cycle for garbage collector
    while script do
        task.wait(GarbageCollectorPer)

        for key, checkpoint in pairs(CheckPoints) do
            if not checkpoint.checkpoint then -- It means that checkpoint was removed without callback // or scripter is stupid and forgot to remove checkpoint after event
                checkpoint:Destroy()
                CheckPoints[key] = nil
            end 
        end
    end
end)