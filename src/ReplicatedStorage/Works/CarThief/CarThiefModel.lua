local ReplicatedStorage = game:GetService('ReplicatedStorage')

local CarThiefModel = {}

-- Dependencies
local Dependencies = require(ReplicatedStorage.dependencies)
local CheckPointDependencyFolder: Folder = Dependencies.getFolder('CheckPoint')
local TaskTrackingFolder: Folder = Dependencies.getFolder('TaskTracking')
local QTEDependency_Folder: Folder = Dependencies.getFolder('QTE')

local CheckPointRemotes_Folder: Folder = CheckPointDependencyFolder.Remotes
local CheckPointAdd_Event: RemoteEvent = CheckPointRemotes_Folder.Add
local CheckPointRemove_Event: RemoteEvent = CheckPointRemotes_Folder.Delete

local TaskTrackingRemotes_Folder:Folder = TaskTrackingFolder.Remotes
local TaskTrackingInit_Event: RemoteEvent = TaskTrackingRemotes_Folder.Init
local TaskTrackingDelete_Event: RemoteEvent =  TaskTrackingRemotes_Folder.Delete
local TaskTrackingSet_Event: RemoteEvent = TaskTrackingRemotes_Folder.Set

local ProximityPrompt_Folder: Folder = Dependencies.getFolder("ProximityPrompt")
local PPManage_Folder: Folder = ProximityPrompt_Folder.Manage
local AddPP_Event: RemoteEvent = PPManage_Folder:WaitForChild("Add")
local RemovePP_Event: RemoteEvent = PPManage_Folder:WaitForChild("Remove")
local Prompt_Module = require(ProximityPrompt_Folder:WaitForChild("Prompt"))
local Node_Module = require(ProximityPrompt_Folder:WaitForChild("Node"))
local Script_Module = require(ProximityPrompt_Folder:WaitForChild("Script"))

local QTERemotes_Folder: Folder = QTEDependency_Folder.Remotes
local QTEAdd_Event: RemoteEvent = QTERemotes_Folder.Add
local QTEDelete_Event: RemoteEvent = QTERemotes_Folder.Delete
--

local Remotes_Folder: Folder = script.Parent.Remotes
local CheckPointTrigger_Event: RemoteEvent = Remotes_Folder.CheckPoint
local ProximityPrompt_Event: RemoteEvent = Remotes_Folder.ProximityPrompt
local QTE_Event: RemoteEvent = Remotes_Folder.QTE

-- Temp solve
local Cars_Folder: Folder = workspace.Cars
local Target_Car: Model = Cars_Folder.ThiefCar

local CarDealer: Model = workspace.CarDealer
local Park_Part: Part = CarDealer.Park

local Cameras_Folder: Folder = workspace.CTCameras
local Camera_Range = {2, #Cameras_Folder:GetChildren()}

local StatesEnum = {
    ['None'] = 0,
    ['CheckPointMonitoring'] = 1,
    ['LockpickCamera'] = 2,
    ['ReachCar'] = 3,
    ['LockpickCar'] = 4,
    ['DeliverCar'] = 5
}

local CheckPointsAlias = {
    'CTReach',
    'CTDeliver'
}
local TaskTrackingAlias = {
    'CTCamera',
    'CTReach',
    'CTLockpickCar',
    'CTDeliver'
}

function CarThiefModel:_lockpickPP(target: Part, argument: string)
    local Prompt = Prompt_Module()
    Prompt:SetObject(target)
    Prompt:SetDistance(10)

    local Script = Script_Module()
    Prompt:SetScript(Script)

    local SingleNode = Node_Module("Single")
    local SingleNodeChoice = SingleNode:NewChoice("Hack", 1.5)
    SingleNodeChoice:SetAction("CTLockPick_"..argument)
    Script:AttachNode(SingleNode)
    Script:SetDefault(SingleNode.name)

    AddPP_Event:FireClient(self.player, Prompt)

    table.insert(self.registeredPP, target)
end

function CarThiefModel:_removePP()
    for i,v in pairs(self.registeredPP) do
        RemovePP_Event:FireClient(self.player, v)
    end

    self.registeredPP = {}
end

function CarThiefModel:_setCheckPointByAlias(alias: string, ...)
    if not self.player:IsA('Player') then return end

    for _, v in pairs(CheckPointsAlias) do
        if v ~= alias then
            CheckPointRemove_Event:FireClient(self.player, v)
        end
    end

    CheckPointAdd_Event:FireClient(self.player, ...)
end

function CarThiefModel:_destroyCheckPoints() -- Destroy all collector's checkpoints on client side
    if not self.player:IsA('Player') then return end -- That's mean, this mock object for testing

    for _, v in pairs(CheckPointsAlias) do
        CheckPointRemove_Event:FireClient(self.player, v)
    end

    for _, v in pairs(self.registeredCheckPoints) do
        CheckPointRemove_Event:FireClient(self.player, v)
    end

    self.registeredCheckPoints = {}
end

function CarThiefModel:_setTask(alias: string, ...) -- Set task to task tracking of player
    if not self.player:IsA('Player') then return end -- That's mean, this mock object for testing

    for _, v in pairs(TaskTrackingAlias) do -- Unrender previous tasks
        if v == alias then continue end
        TaskTrackingDelete_Event:FireClient(self.player, v)
    end

    TaskTrackingInit_Event:FireClient(self.player, ...)
end

function CarThiefModel:_clearTasks() -- Remove ct work tasks
    if not self.player:IsA('Player') then return end -- That's mean, this mock object for testing

    for _,v in pairs(TaskTrackingAlias) do -- Unrender all tasks
        TaskTrackingDelete_Event:FireClient(self.player, v)
    end
end

function CarThiefModel:_setProgressTask(...) -- Update progress task -> dependency from ProgressTracking
    if not self.player:IsA('Player') then return end 

    TaskTrackingSet_Event:FireClient(self.player, ...)
end

function CarThiefModel.new(player: Player) -- Constructor + init
    local self = setmetatable({}, {__index = CarThiefModel})

    self.player = player
    self.state = 0
    self.registeredCheckPoints = {}
    self.registeredPP = {}

    self:_checkPointListener()
    self:_ppListener()
    self:_qteListener()
    self:_pickCameraData()
    self:_cameraCheckpoint()
    return self
end

function CarThiefModel:Destroy()
    if self.checkpoint_connection then
        self.checkpoint_connection:Disconnect()
        self.checkpoint_connection = nil
    end

    if self.pp_connection then
        self.pp_connection:Disconnect()
        self.pp_connection = nil
    end

    if self.qte_connection then
        self.qte_connection:Disconnect()
        self.qte_connection = nil
    end

    if self.car then
        self.car:Destroy()
        self.car = nil
    end

    self:_removePP()
    self:_clearTasks()
    self:_destroyCheckPoints()
end

function CarThiefModel:_pickCameraData() -- Camera data btw
    self.camera_count = math.random(Camera_Range[1], Camera_Range[2])
    self.camera_list = {}
    local count = self.camera_count
    local Cameras_Childs = Cameras_Folder:GetChildren()
    while count > 0 do
        local RandomIndex = math.random(1, #Cameras_Childs)
        table.insert(self.camera_list, Cameras_Childs[RandomIndex])
        table.remove(Cameras_Childs, RandomIndex)
        count -= 1
    end

    local RandomLocations = self.camera_list[math.random(1, #self.camera_list)].Locations:GetChildren()
    self.spawn_point = RandomLocations[math.random(1, #RandomLocations)]
end

function CarThiefModel:_checkPointListener() -- Monitoring checkPoint event
    assert(not self.checkpoint_connection, 'Already has checkpoint connection')

    self.checkpoint_connection = CheckPointTrigger_Event.OnServerEvent:Connect(function(player: Player, state: boolean, name: string)
        if player ~= self.player then return end
        self:_removePP() -- Remove all PP before that, to update prev
        if self.state == StatesEnum.CheckPointMonitoring and state then
            local start_sub: number, end_sub: number = string.find(name, 'CTCamera'); if not start_sub then return end -- if not camera -> return 
            local index = tonumber(string.sub(name, end_sub + 1, #name))
            self:_lockpickPP(self.camera_list[index].PrimaryPart, index)  
            return
        end

        if self.state == StatesEnum.ReachCar and state then
            if name ~= 'CTReach' then return end -- Bug from client side
            self:_carHack()
            return
        end

        if self.state == StatesEnum.DeliverCar and state then
            if name ~= 'CTDeliver' then return end -- Bug from client side
            self:Destroy()
            if self.on_complete then
                self.on_complete()
            end
            return
        end
    end)
end

function CarThiefModel:_qteListener() -- Monitoring qte event
    self.qte_connection = QTE_Event.OnServerEvent:Connect(function(player: Player, state: boolean)
        if player ~= self.player then return end
        if self.state == StatesEnum.LockpickCamera then
            if not state then self.state = StatesEnum.CheckPointMonitoring; self:_cameraCheckpoint(); return end
            table.remove(self.camera_list, self.qte_index)
            self:_cameraCheckpoint()
        end

        if self.state == StatesEnum.LockpickCar then
            if not state then self:_carHack(); return end
            self:_deliverCar()
        end
    end)
end

function CarThiefModel:_ppListener() -- Monitoring pp event
    self.pp_connection = ProximityPrompt_Event.OnServerEvent:Connect(function(player: Player, object: Part, index: number)
        if player ~= self.player then return end
        if self.state == StatesEnum.CheckPointMonitoring then
           self.state = StatesEnum.LockpickCamera -- Update state
           self.qte_index = index
           self:_removePP() -- Remove all PP
           QTEAdd_Event:FireClient(self.player, 'LockPick', {2, 3, QTE_Event})
        end

        if self.state == StatesEnum.LockpickCar then
            self:_removePP() -- Remove all PP
            QTEAdd_Event:FireClient(self.player, 'LockPick', {2, 3, QTE_Event})
        end
    end)
end

function CarThiefModel:onComplete(callback) -- Callback on complete
    self.on_complete = callback
end

function CarThiefModel:_carReach()
    self.state = StatesEnum.ReachCar
    self.car = Target_Car:Clone()
    self.car.Parent = Cars_Folder
    self.car:PivotTo(self.spawn_point.CFrame * CFrame.new(0, 5, 0))
    self.car.VehicleSeat.Disabled = true

    self:_setTask('CTReach', 'CTReach', 'Car thief work', 'Reach <font color="#FA7298">car</font>', {0, 1})
    self:_setCheckPointByAlias('CTReach', 'CTReach', 30, self.spawn_point.Position - Vector3.new(0, self.spawn_point.Size.Y / 2), CheckPointTrigger_Event)
end

function CarThiefModel:_deliverCar()
    self.state = StatesEnum.DeliverCar
    self.car.VehicleSeat.Disabled = false

    self:_setTask('CTDeliver', 'CTDeliver', 'Car thief work', 'Deliver car to <font color="#FA7298">dealer</font>', {0, 1})
    self:_setCheckPointByAlias('CTDeliver', 'CTDeliver', 30, Park_Part.Position - Vector3.new(0, Park_Part.Size.Y / 2), CheckPointTrigger_Event)
end

function CarThiefModel:_carHack()
    self.state = StatesEnum.LockpickCar -- Update state
    self:_destroyCheckPoints()
    self:_setTask('CTLockpickCar', 'CTLockpickCar', 'Car thief work', 'Lockpick <font color="#FA7298">car</font>', {0, 1})
    self:_lockpickPP(self.car.PrimaryPart, '')  -- Empty argument
end

function CarThiefModel:_cameraCheckpoint() -- Entry point into cycle
    self:_destroyCheckPoints() -- Destroy prev checkpoints
    self:_removePP()

    if #self.camera_list == 0 then
        self:_carReach() -- Go to car reach cycle
        return
    end

    self:_setTask('CTCamera', 'CTCamera', 'Car thief work', 'Hack <font color="#FA7298">camera</font>', {self.camera_count - #self.camera_list, self.camera_count})
    self.state = StatesEnum.CheckPointMonitoring
    for index, camera in pairs(self.camera_list) do
        self:_setCheckPointByAlias('CTCamera'..index, 'CTCamera'..index, 30, camera.PrimaryPart.Position - Vector3.new(0, camera.PrimaryPart.Size.Y / 2), CheckPointTrigger_Event)
        table.insert(self.registeredCheckPoints, 'CTCamera'..index)
    end
end

return CarThiefModel