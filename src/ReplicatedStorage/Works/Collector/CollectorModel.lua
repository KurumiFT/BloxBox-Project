local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local CollectorModel = {}

local ATM_Folder = game.Workspace.ATM
local Bank = workspace.Bank

-- Dependencies
local Dependencies = require(ReplicatedStorage.dependencies)
local CheckPointDependencyFolder: Folder = Dependencies.getFolder('CheckPoint')
local TaskTrackingFolder: Folder = Dependencies.getFolder('TaskTracking')

local CheckPointRemotes_Folder: Folder = CheckPointDependencyFolder.Remotes
local CheckPointAdd_Event: RemoteEvent = CheckPointRemotes_Folder.Add
local CheckPointRemove_Event: RemoteEvent = CheckPointRemotes_Folder.Delete

local TaskTrackingRemotes_Folder:Folder = TaskTrackingFolder.Remotes
local TaskTrackingInit_Event: RemoteEvent = TaskTrackingRemotes_Folder.Init
local TaskTrackingDelete_Event: RemoteEvent =  TaskTrackingRemotes_Folder.Delete
local TaskTrackingSet_Event: RemoteEvent = TaskTrackingRemotes_Folder.Set
--

-- Maybe temporary
local CarPrefab = workspace.Cars.CollectorCar
local CarsParent = workspace.Cars

local Remotes_Folder = script.Parent.Remotes
local CheckPointTrigger_Event = Remotes_Folder.CheckPoint

local CarCheckPointRender_Per = .5

local CheckPointsAlias = {
    'CollectorATM',
    'CollectorPick',
    'CollectorCarry',
    'CollectorUnload'
}

local TaskTrackingAlias = {
    'CollectorATM',
    'CollectorCarry',
    'CollectorUnload'
}

function CollectorModel:_setCheckPointByAlias(alias: string, ...) -- Remove all checkpoints except 'alias'
    if not self.player:IsA('Player') then return end -- That's mean, this mock object for testing

    for _, v in pairs(CheckPointsAlias) do
        if v ~= alias then 
            CheckPointRemove_Event:FireClient(self.player, v)
        end
    end

    CheckPointAdd_Event:FireClient(self.player, ...)
end

function CollectorModel:spawnCar() -- Maybe this method will accept car prefab, temporary it's here
    assert(self.player.Character, "Player hasn't character")

    self.car = CarPrefab:Clone() -- Spawn car
    self.car.Parent = CarsParent

    self.car:PivotTo(self.player.Character.PrimaryPart.CFrame * CFrame.new(10, 5, 0))
end

function CollectorModel.new(player: Player) -- Constructor for collector model (task)
    local self = {}
    self.player = player
    self.connection = nil -- Just remember that this field exist
    self.heartbeat_connection = nil
    setmetatable(self, {__index = CollectorModel})

    self:_entry() -- Start cycke

    return self
end

function CollectorModel:Destroy() -- Destructor
    self:_destroyConnections()
end

function CollectorModel:_pickATM() -- Private method to pick random ATM
    local ATM_Childrens = ATM_Folder:GetChildren()
    self.target = ATM_Childrens[math.random(1, #ATM_Childrens)]
end

function CollectorModel:_setTask(alias: string, ...) -- Set task to task tracking of player
    if not self.player:IsA('Player') then return end -- That's mean, this mock object for testing

    for _, v in pairs(TaskTrackingAlias) do -- Unrender previous tasks
        TaskTrackingDelete_Event:FireClient(self.player, v)
    end

    TaskTrackingInit_Event:FireClient(self.player, ...)
end

function CollectorModel:_setProgressTask(...)
    if not self.player:IsA('Player') then return end 

    TaskTrackingSet_Event:FireClient(self.player, ...)
end

function CollectorModel:_destroyConnections()
    if self.connection then
        self.connection:Disconnect()
    end

    if self.heartbeat_connection then
        self.heartbeat_connection:Disconnect()
    end
end

function CollectorModel:_carry() -- Carry cycle
    assert(self.car, 'No car in this player, please fix this bug!')

    self:_destroyConnections() -- Destroy previous connections

    local function spawnCheckPoint() -- function for attach checkpoint to car
        local last_tick = 0

        self.heartbeat_connection = RunService.Heartbeat:Connect(function()
            if not self.car then return end
            if tick() - last_tick < CarCheckPointRender_Per then return end
            last_tick = tick()

            self:_setCheckPointByAlias('CollectorCarry', 'CollectorCarry', 5, (self.car.PrimaryPart.CFrame * CFrame.new(0, 0, 6)).p, CheckPointTrigger_Event) -- Set checkpoint                 
        end)
    end

    self.connection = CheckPointTrigger_Event.OnServerEvent:Connect(function(player: Player, state: boolean, name: string)
        if player ~= self.player then return end
        if state == true and name == 'CollectorCarry' then
            self.carried_bags += 1
            self:_pick()
        end
    end)

    spawnCheckPoint()
end

function CollectorModel:_unload() -- Unload car cycle
    assert(Bank:FindFirstChild('CollectorZone'), "No 'CollectorZone' in Bank model")
    self:_destroyConnections() -- Destroy previous connections
    
    self:_setCheckPointByAlias('CollectorUnload', 'CollectorUnload', 30, Bank.CollectorZone.Position - Vector3.new(0, Bank.CollectorZone.Size.Y / 2), CheckPointTrigger_Event) -- Set checkpoint
    self:_setTask('CollectorUnload', 'CollectorUnload', 'Collector work', 'Unload <font color="#FA7298">bags with cash</font>', {0, 1})

    self.connection = CheckPointTrigger_Event.OnServerEvent:Connect(function(player: Player, state: boolean, name: string) -- Wait for event from checkpoint
        if player ~= self.player then return end
        if state == true and name == 'CollectorUnload' then
            print('End cycle')

            self:_entry() -- Repeat cycle
        end
    end)
end

function CollectorModel:_pick()
    assert(self.target, "No target, it's critical bug!")
    assert(self.req_bags, "No require bags, it's critical bug!")
    assert(self.carried_bags, "No carried bags, it's critical bug!")

    if self.carried_bags >= self.req_bags then -- If deliver enough bags -> unload
        self:_unload()
        return
    end

    self:_destroyConnections() -- Destroy previous connections

    self:_setCheckPointByAlias('CollectorPick', 'CollectorPick', 5, self.target.Pick.Position - Vector3.new(0, self.target.Pick.Size.Y / 2), CheckPointTrigger_Event) -- Set checkpoint    
    self:_setProgressTask('CollectorCarry', {self.carried_bags, self.req_bags})

    self.connection = CheckPointTrigger_Event.OnServerEvent:Connect(function(player: Player, state: boolean, name: string)
        if player ~= self.player then return end
        if state == true and name == 'CollectorPick' then
            self:_carry()
        end
    end)
end

function CollectorModel:_entry() -- Private method to start collector cycle
    self:_pickATM()
    assert(self.target, 'No target, please check ATM folder')

    self:_destroyConnections()

    self:_setCheckPointByAlias('CollectorATM', 'CollectorATM', 30, self.target.PrimaryPart.Position - Vector3.new(0, self.target.PrimaryPart.Size.Y / 2), CheckPointTrigger_Event) -- Set checkpoint
    self:_setTask('CollectorATM', 'CollectorATM', 'Collector work', 'Reach <font color="#FA7298">ATM</font>', {0, 1})

    self.connection = CheckPointTrigger_Event.OnServerEvent:Connect(function(player: Player, state: boolean, name: string) -- Wait for event from checkpoint
        if player ~= self.player then return end
        if state == true and name == 'CollectorATM' then
            -- Get requires for work
            self.req_bags = math.random(3,5) -- Require bags for complete work
            self.carried_bags = 0

            self:_setTask('CollectorCarry', 'CollectorCarry', 'Collector work', 'Carry <font color="#00CC33">cash bags</font>', {self.carried_bags, self.req_bags})
            self:_pick()
        end
    end)
end

return CollectorModel