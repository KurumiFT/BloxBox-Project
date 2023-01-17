local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')

local Player: Player = game.Players.LocalPlayer
local PlayerUI: PlayerGui = Player.PlayerGui

local UI_Prefab: ScreenGui = script.Parent.QTE_UI 
local EmptySpaceKoef: number = 0.03 -- Koef of empty space between circle and frame borders

local CursorSpeed: number = 1.3
local PossibleDiff: number = 12
local MaxErrors: number = 2

local ErrorTweenInfo: TweenInfo = TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In,0, false, 0)
local SuccessTweenInfo: TweenInfo = TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)

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

function QTE:_fire(...) -- Fire data to event
    if self.destroyed then return end
    if not self.callback_event then return end
    if self.callback_event:IsA('BindableEvent') then
        self.callback_event:Fire(...)
    elseif self.callback_event:IsA('RemoteEvent') then
        self.callback_event:FireServer(...)
    end
end

function QTE:_try() -- Input handler
    if not self.connection then return end -- Ignore this try, cause this isn't render connection

    if math.abs(self.chink - self.cursor) <= PossibleDiff then
        self:_success(.5)
    else
        self:_error(.5)
    end
end

function QTE:_error(del: number) -- Del - delay between stop and iteration
    if self.connection then
       self.connection:Disconnect()
    self.connection = nil 
    end
    self.errors += 1
    if self.ui.Chink then -- Play tween animation to error
        TweenService:Create(self.ui.Chink, ErrorTweenInfo, {ImageColor3 = Color3.fromRGB(255, 0, 0)}):Play()
    end

    task.wait(del) -- Wait until next try
    self:_iteration()
end

function QTE:_success(del: number) -- Success 
    if self.connection then
       self.connection:Disconnect()
       self.connection = nil 
    end

    self.done_iterations += 1
    if self.ui.Chink then -- Play tween animation to error
        TweenService:Create(self.ui.Chink, ErrorTweenInfo, {ImageColor3 = Color3.fromRGB(0, 255, 0), ImageTransparency = 1}):Play()
    end

    task.wait(del) -- Wait until next try
    self:_iteration()
end

function QTE:_iteration() -- Method to prepare one iteration of lockpicking
    if not self.ui then return end
    if self.errors >= MaxErrors then -- If make enough errors -> destroy this shit
        self:_fire(false)
        self.destroyed = true -- set ignore new fires flag
        self:Destroy()
        return
    end

    if self.done_iterations >= self.iterations then
        self:_fire(true)
        self.destroyed = true -- set ignore new fires flag
        self:Destroy()
        return
    end

    self.chink = math.random(45, 335)
    self.cursor = 0
    self.direction = 1

    self.ui.Chink.ImageColor3 = Color3.fromRGB(255, 255, 255)
    self.ui.Chink.ImageTransparency = 0

    if self.connection then -- Remove previous connection
        self.connection:Disconnect()
    end

    local function render()
        if not self.ui then return end -- If not ui -> skip this call
        local Width = self.ui.AbsoluteSize.Y / 2
        local Radius = (Width - (Width * EmptySpaceKoef)) / 2

        local ChinkFrame: ImageLabel = self.ui.Chink
        local RoadFrame: ImageLabel = self.ui.Road
        local CursorFrame: Frame = self.ui.Cursor

        RoadFrame.Size = UDim2.new(0, Width, 0, Width)
	    RoadFrame.Position = UDim2.new(.5, -Width / 2, .5, -Width / 2)
        ChinkFrame.Size = UDim2.new(0, Radius / 4, 0, Radius / 4)
        CursorFrame.Size = UDim2.new(0, Radius / 3.5, 0, Radius / 3.5)

        local ChinkRad: number = math.rad(self.chink) -- Radial presentation of chink
        local CursorRad: number = math.rad(self.cursor) -- Radial presentation of cursor

        local x_chink = (RoadFrame.AbsolutePosition.X + RoadFrame.AbsoluteSize.X / 2 - ChinkFrame.AbsoluteSize.X / 2) + (math.cos(ChinkRad) * Radius) + (math.sign(math.cos(ChinkRad)) * -1 * ChinkFrame.AbsoluteSize.X / 4)
	    local y_chink = (RoadFrame.AbsolutePosition.Y + RoadFrame.AbsoluteSize.Y / 2 - ChinkFrame.AbsoluteSize.Y / 2) + (math.sin(ChinkRad) * Radius) + (math.sign(math.sin(ChinkRad)) * -1 * ChinkFrame.AbsoluteSize.Y / 4)
	    ChinkFrame.Position = UDim2.new(0, x_chink, 0, y_chink)

        local x_cursor = (RoadFrame.AbsolutePosition.X + RoadFrame.AbsoluteSize.X / 2 - ChinkFrame.AbsoluteSize.X / 2) + (math.cos(CursorRad) * Radius) + (math.sign(math.cos(CursorRad)) * -1 * ChinkFrame.AbsoluteSize.X / 4)
	    local y_cursor = (RoadFrame.AbsolutePosition.Y + RoadFrame.AbsoluteSize.Y / 2 - ChinkFrame.AbsoluteSize.Y / 2) + (math.sin(CursorRad) * Radius) + (math.sign(math.sin(CursorRad)) * -1 * ChinkFrame.AbsoluteSize.Y / 4)
	    CursorFrame.Position = UDim2.new(0, x_cursor, 0, y_cursor)
    end

    self.connection = RunService.Heartbeat:Connect(function(deltaTime) -- Render connection
        self.cursor = math.clamp(self.cursor + CursorSpeed * self.speed * self.direction, 0, 360)
        if self.cursor >= 360 then
            self.direction = -1
        elseif self.cursor <= 0 and self.direction == -1 then
            self:_error(.5)
        end

        render()
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
    self:_fire(false) -- Fire missed QTE
    if self.ui then
        self.ui:Destroy()
        self.ui = nil
    end
    self.destroyed = true
    self:_destroyConnection() -- Destroy all connections
end

function QTE.new(speed: number, iterations: number, callback_event: BindableEvent | RemoteEvent | nil) -- Constructor
    local self = setmetatable({}, {__index = QTE})
    self.speed = speed
    self.errors = 0
    self.iterations = iterations
    self.done_iterations = 0
    self.callback_event = callback_event
    self.connection = nil -- Just remember this field
    self.destroyed = false
    self:_createInputConnection()
    self:_initUI()
    self:_iteration()

    return self
end


return QTE