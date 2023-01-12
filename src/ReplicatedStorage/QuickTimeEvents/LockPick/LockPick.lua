local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')

local Player: Player = game.Players.LocalPlayer
local PlayerUI: PlayerGui = Player.PlayerGui

local UI_Prefab: ScreenGui = script.Parent.QTE_UI 
local EmptySpaceKoef: number = 0.03 -- Koef of empty space between circle and frame borders

local QTE = {}

function QTE:_createInputConnection() -- Input listener
    self.input_connection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self:_try()
        end
    end)
end

function QTE:_destroyConnection() -- Destroy all connections for this model
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end

    if self.input_connection then
        self.input_connection:Disconnect()
        self.input_connection = nil
    end
end

function QTE:_try() -- Input handler
    
end

function QTE:_iteration() -- Method to prepare one iteration of lockpicking
    self.chink = math.random(45, 335)
    self.cursor = 0

    self.connection = RunService.Heartbeat:Connect(function(deltaTime) -- Render connection
        
    end)
end

function QTE:_initUI()
    if self.ui then error('Player already have QTE UI!') end

    if PlayerUI:FindFirstChild(UI_Prefab.Name) then
        warn('This not good, he already has QTE! Please fix this')
    end

    self.ui = UI_Prefab:Clone()
    self.ui.Parent = PlayerUI
end

function QTE:Destroy()
    self:_destroyConnection() -- Destroy all connections
    if self.ui then
        self.ui:Destroy()
        self.ui = nil
    end

end

function QTE.new(speed: number, iterations: number, callback_event: BindableEvent | RemoteEvent | nil) -- Constructor
    local self = setmetatable({}, {__index = QTE})
    self.speed = speed
    self.iterations = iterations
    self.callback_event = callback_event
    self.connection = nil -- Just remember this field
    self:_createInputConnection()
    self:_initUI()
    self:_iteration()

    return self
end


return QTE