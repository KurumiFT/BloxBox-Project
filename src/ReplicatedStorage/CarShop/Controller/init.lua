local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService('Debris')

local Player = Players.LocalPlayer

local View = require(script.Parent.View).View
local Blind = require(script.Parent.View).Blind
local SplashScreen = require(script.Parent.View).SplashScreen
local CarModel = require(script.Parent.CarModel)
local Definations = require(script.Parent.definition)

local Camera = workspace.CurrentCamera

local Controller = {}
Controller.__index = Controller

function Controller:checkTestDrive()
    return self.player_data.Car.Attempts.Value > 0
end

function Controller:checkOnCash(amount)
    return self.player_data.Economic.Cash.Value >= amount
end

function Controller:renderByIndex(index: number)
    if not self.status then return end
    assert(self.view, 'There isnt view')

    if self.cars[self.rendered_index] then
        self.cars[self.rendered_index]:Destroy()
    end

    local car_table: table = self.cars[index]
    car_table['colors'] = Definations.BaseColors

    self.rendered_index = index
    self.cars[index]:spawn(Definations.CarPlace.CFrame * CFrame.new(0, Definations.CarPlace.Size.Y / 2, 0) * CFrame.fromEulerAnglesXYZ(0, math.pi / 3, 0), workspace)
    self.view:setInfo(car_table)
    self.view.RightSwipe:render()
    self.view.LeftSwipe:render()
    self:paint(car_table['colors'][1])
    self:setActions(self:checkOnCash(car_table.cost), self:checkTestDrive(), car_table.cost or 0)
end

function Controller:paint(color: Color3)
    if not self.cars[self.rendered_index] then return end
    if not self.cars[self.rendered_index].instance then return end
    self.color = color
    self.view:pickColor(color)
    self.cars[self.rendered_index]:color(color)
end

function Controller:reducer(step: number)
    if step > 0 then
        if #self.cars < self.rendered_index + step then
            self:renderByIndex(1)
            return
        end
    else
        if self.rendered_index + step <= 0 then
            self:renderByIndex(#self.cars)
            return
        end
    end
    self:renderByIndex(self.rendered_index + step)
end

function Controller:setActions(buy_state: boolean, td_state: boolean, cost: number)
    self.view.Actions:render(buy_state, td_state, cost)
end

function Controller:Destroy()
    self.status = false
    local blind
    local TempUI = Instance.new('ScreenGui', Player.PlayerGui)
    Debris:AddItem(TempUI, 5)
    blind = Blind.new(Definations.BlindTween, function()
        self:CameraOff()
        self.view:Destroy()
        for i, v in pairs(self.cars) do
            v:Destroy()
            v = nil
        end

        for i, v in pairs(self.connections) do
            v:Disconnect()
            v = nil
        end

        blind:Pump()
    end, TempUI); blind:Drop()
end

function Controller:CameraOff()
    if self.camera_connection then
        self.camera_connection:Disconnect()
    end
    
    Camera.CameraType = Enum.CameraType.Custom
    Camera.CFrame = Player.Character.Head.CFrame   
end

function Controller:CameraOn()
    if self.camera_connection then
        self.camera_connection:Disconnect()
    end
    
    self.camera_connection = RunService.Heartbeat:Connect(function(deltaTime)
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = Definations.CarCamera.CFrame
    end)
end

function Controller.new(target: Player)
    local self = setmetatable({connections = {},view = nil, cars = {}, color = nil, rendered_index = 0}, Controller)
    self.status = true
    self.player_data = target:WaitForChild('Data')

    self.view = View.new(target.PlayerGui, {swipe = function(val)
        self:reducer(if val == 180 then -1 else 1)
    end, color = function(val)
        self:paint(val)
    end, buy = function()
        local FiredIndex = self.rendered_index
        Definations.Events.Buy:FireServer(self.cars[self.rendered_index])
        task.wait(.15)
        if self.rendered_index == FiredIndex then
            self:renderByIndex(FiredIndex)
        end
    end, testdrive = function()
        Definations.Events.TD:FireServer(self.cars[self.rendered_index])
    end})

    table.insert(self.connections, Definations.Events.Buy.OnClientEvent:Connect(function(meta)
        if not self.status then return end
        local SScreen = SplashScreen.new(string.format('Поздравляем с покупкой\n<font color="rgb(255,125,0)"><font weight="heavy">%s</font></font>', meta.display), self.view.Holder)
    end))

    for i, v in pairs(Definations.CarsFolder:GetChildren()) do
        table.insert(self.cars, CarModel.new(v))
    end

    local blind
    blind = Blind.new(Definations.BlindTween, function()
        if self.status then
            self:CameraOn()
            self:renderByIndex(1) 
        end

        blind:Pump()
    end, self.view.Holder); blind:Drop()

    return self
end

return Controller