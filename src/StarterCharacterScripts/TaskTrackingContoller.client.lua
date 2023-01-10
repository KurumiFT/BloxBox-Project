local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Dependencies
local Dependencies = require(ReplicatedStorage.dependencies)
local TaskTrackingFolder: Folder = Dependencies.getFolder('TaskTracking')
local TaskTrackingDependency = Dependencies.get('TaskTracking')

-- Remotes
local TaskTrackingRemotes: Folder = TaskTrackingFolder.Remotes
local Init_Event: RemoteEvent = TaskTrackingRemotes.Init
local Delete_Event: RemoteEvent = TaskTrackingRemotes.Delete
local Set_Event: RemoteEvent = TaskTrackingRemotes.Set

local TaskFrame: Frame = TaskTrackingFolder.TaskFrame -- Needs to calculate position

local Player = game.Players.LocalPlayer

local Tasks = {} -- Stored tasks in player

-- (Aka) List setting
local StartPosition: UDim2 = UDim2.new(1 - .01 - TaskFrame.Size.X.Scale, 0, .2, 0)
local Padding: number = TaskFrame.Size.Y.Scale + (TaskFrame.Size.Y.Scale * TaskFrame.Header.Size.Y.Scale) + .01 -- Calculate margin between tasks

function getTaskByName(name: string) -- if task with .Name == name exist, return index and meta-table of this task
    for index, task in pairs(Tasks) do
        if task.name == name then
            return index, task 
        end
    end
end

function addNewTask(name: string, header: string, description: string, progress: table)
    if getTaskByName(name) then -- If task exist - update progress data
        setProgression(name, progress) 
        return
    end

    -- Parse data in Task examplar
    local _Task = TaskTrackingDependency.new(name)
    _Task:setDescription(description)
    _Task:setHeader(header)
    _Task:setProgression(unpack(progress))
    table.insert(Tasks, _Task)

    -- Render
    local SpawnPosition: UDim2 = UDim2.new(StartPosition.X.Scale + .5, 0, StartPosition.Y.Scale + (#Tasks - 1) * Padding, 0)
    _Task:Render()
    _Task:Move(SpawnPosition) -- Set start position
    _Task:Transition(UDim2.new(StartPosition.X.Scale, 0, SpawnPosition.Y.Scale, 0))
end

function setProgression(name: string, progress: table) -- Update progress for task by name
    local Index, Task = getTaskByName(name)
    if not Task then return end
    
    Task:setProgression(unpack(progress))
end

function removeTask(name: string) -- Remove task
    local Index, Task = getTaskByName(name)
    if not Index then return end
    table.remove(Tasks, Index) -- Remove it from Tasks table

    if not Task.frame then return end -- If it hasn't frame, exit from this function
    -- If has
    local TransitionTween: Tween = Task:Transition(UDim2.new(Task.frame.Position.X.Scale + 1, 0, Task.frame.Position.Y.Scale, 0)) -- Transition for hide task frame
    for i = Index, #Tasks do -- Move next tasks upper
        local TargetPosition: UDim2 = UDim2.new(StartPosition.X.Scale, 0, StartPosition.Y.Scale + (i - 1) * Padding, 0)
        Tasks[i]:Transition(TargetPosition)
    end
    task.delay(TransitionTween.TweenInfo.Time, function() -- Tween completed - unrender task
        Task:unRender()
    end)
end

Set_Event.OnClientEvent:Connect(function(name: string, progress: table)
    setProgression(name, progress)
end)

Init_Event.OnClientEvent:Connect(function(name: string, header: string, description: string, progress: table) -- Add task to player from server side
    addNewTask(name, header, description, progress)
end)

Delete_Event.OnClientEvent:Connect(function(name: string)
    removeTask(name)
end)