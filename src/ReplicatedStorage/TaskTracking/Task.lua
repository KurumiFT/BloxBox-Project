local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')

local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local Task = {}

local TaskFrame = script.Parent.TaskFrame
local ScreenGui_Name = "TaskTracking"

local TransitionTweeninfo = TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

function Task.new(name: string) -- Constructor for new task
    local self = {}

    self.name = name
    setmetatable(self, {__index = Task})
    return self
end

function Task:setHeader(text: string) -- Set task header
    self.header = text
end

function Task:setDescription(text: string) -- Set task target
    self.description = text
end

function Task:setProgression(current: number, target: number) -- Update progression data
    self.progression = {current, target}
end

function Task:Move(position: UDim2) -- Set position without tween animation
    if not self.frame then return end
    self.frame.Position = position
end

function Task:Transition(position: UDim2) -- Set position with tween
    if not self.frame then return end
    local tween = TweenService:Create(self.frame, TransitionTweeninfo, {Position = position})
    tween:Play()
end

function Task:Render() -- Render task frame on PlayerGui
    if self.frame then return end
    local ScreenGui = PlayerGui:FindFirstChild(ScreenGui_Name)
    if not ScreenGui then
        ScreenGui = Instance.new('ScreenGui', PlayerGui)
        ScreenGui.Name = ScreenGui_Name
    end

    self.frame = TaskFrame:Clone()
    self.frame.Parent = ScreenGui
    self:_setConnection()
end

function Task:unRender()
    if self.frame then
        self.frame:Destroy()
    end

    if self.render_connection then
        self.render_connection:Disconnect()
        -- self.render_connection = nil
    end
end

function Task:_setConnection() -- Set update connection 
    self.render_connection = RunService.Heartbeat:Connect(function(deltaTime) -- Update task info
        if not self.frame then self.render_connection:Disconnect(); return end
        
        -- Update part // Require self.header / self.progression / self.description
        self.frame.TextLabel.Text = string.format('%s - (%i / %i)', self.description, self.progression[1], self.progression[2])
        self.frame.Header.TextLabel.Text = self.header 
    end)
end

return Task