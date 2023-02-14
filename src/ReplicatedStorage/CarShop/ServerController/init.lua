local RunService = game:GetService("RunService")
local Controller = {}
Controller.__index = Controller

local Definations = require(script.Parent.definition)
local CarModel = require(script.Parent.CarModel)

function getPlayerData(player)
    if not player:FindFirstChild('Data') then return end
    if not player.Data:FindFirstChild('Car') then return end
    return player.Data.Car
end

function getPlayerEconomic(player)
    if not player:FindFirstChild('Data') then return end
    if not player.Data:FindFirstChild('Economic') then return end
    return player.Data.Economic
end

function Controller.new()
    local self = setmetatable({}, Controller)
    self.connections = {}
    self.td_cars = {}

    -- Register TD_Event / Buy_Event
    Definations.Events.TD.OnServerEvent:Connect(function(player, meta)
        if self.td_cars[player] then
            self.td_cars[player]:Destroy()
            self.td_cars[player] = nil
        end

        local data = getPlayerData(player)
        if not data then return end

        if data.Attempts.Value <= 0 then return end

        data.Attempts.Value -= 1
        data.LastAttempt.Value = os.time()
        Definations.Events.State:FireClient(player, false)

        local TD_CarModel = CarModel.new(meta.model)
        TD_CarModel:spawn(Definations.TDPlace.CFrame, Definations.SpawnCarFolder)
        TD_CarModel:color(meta.used_color)
        self.td_cars[player] = TD_CarModel
        
        -- Seat binding

        local TD_Display = Definations.TD_UI:Clone()
        TD_Display.Parent = TD_CarModel.instance
        TD_Display.Adornee = TD_CarModel.instance

        local TargetTime = tick() + 30

        local Connection; Connection = RunService.Heartbeat:Connect(function()
            TD_Display.TextLabel.Text = string.format('Тест-Драйв\n<font color="rgb(255, 255, 255)">%i</font>', math.floor(TargetTime - tick()))

            if tick() >= TargetTime then
                TD_CarModel:Destroy()

                if not player then Connection:Disconnect();Connection = nil; return end
                if self.td_cars[player] ~= TD_CarModel then Connection:Disconnect();Connection = nil; return end
                
                self.td_cars[player]:Destroy()
                self.td_cars[player] = nil
                player.Character.HumanoidRootPart.CFrame = Definations.CarShopSpawnPoint.CFrame * CFrame.new(0, 3, 0)

                Connection:Disconnect()
                Connection = nil
                return
            end
        end)
        table.insert(self.connections, Connection)
    end)

    Definations.Events.Buy.OnServerEvent:Connect(function(player, meta)
        local edata = getPlayerEconomic(player)
        local cdata = getPlayerData(player)
        if not edata or not cdata then return end

        local OriginalCar = meta.model
        if OriginalCar.Configuration.cost.Value > edata.Cash.Value then return end
        -- Here may checks for available slots
        local CarFolder = Instance.new('Folder', cdata.Has)
        CarFolder.Name = meta.model.Name

        local Color_Value = Instance.new('Color3Value', CarFolder)
        Color_Value.Name = 'Color'
        Color_Value.Value = meta.used_color

        edata.Cash.Value -= OriginalCar.Configuration.cost.Value

        Definations.Events.Buy:FireClient(player, meta)
    end)

    return self
end

return Controller
