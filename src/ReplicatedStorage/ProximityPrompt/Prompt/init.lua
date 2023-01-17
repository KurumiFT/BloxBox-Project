local Prompt = {}

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Player = game.Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local UI_Folder = script.Parent.UI
local Single_Frame = UI_Folder.Single
local Radial_Frame = UI_Folder.Radial

local TweenInfos = { -- Maybe later in another module with tween presets
    Appear = TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
    Disappear = TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)
}

local function Constructor()
    local self = {}

    setmetatable(self, {__index = Prompt})
    return self
end

local function checkOnFrame(position: Vector3, frame) -- Check 2D position over frame
	if not frame then return end
	if not ((position.X >= frame.AbsolutePosition.X) and (position.X <= frame.AbsolutePosition.X + frame.AbsoluteSize.X)) then
		return false
	end

	if not ((position.Y >= frame.AbsolutePosition.Y) and (position.Y <= frame.AbsolutePosition.Y + frame.AbsoluteSize.Y)) then
		return false
	end
	
	return true
end

local function getTableKeys(tab)
    local Keys = {}
    for _, v in pairs(tab) do
        table.insert(Keys, _)
    end

    return Keys
end

local function WorldToScreenPoint(position)
    local vector, onSreen = CurrentCamera:WorldToScreenPoint(position)
    return vector
end

function Prompt:SetScript(script)
    if self.script then
        self:HideCurrent()
        self.script:RemoveCallback("Action")
        self.script:RemoveCallback("Pointer")
    end

    self.script = script  
    self.script:AttachCallback('Action', function(action)
        if self.router then
            self.router.route(self.object, action)
        end
    end)
end

function Prompt:SetObject(obj: Part)
    self.object = obj
end

function Prompt:inputOnChoice(choice, choice_data)
    if choice_data.choice.duration == 0 then
        self.script:ProceedAction(choice_data.choice)
        return
    end

    local TInfo = TweenInfo.new(choice_data.choice.duration, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)
    local Tween = TweenService:Create(choice.Progress, TInfo, {Size = UDim2.new(1, 0, 1, 0)})
    Tween:Play()
    local TimeConnection
    local CurrentHold = tick()
    self.last_hold = CurrentHold
    TimeConnection = RunService.Heartbeat:Connect(function(deltaTime) -- Holding check connection
        if not self.render_data then TimeConnection:Disconnect(); return end
        if self.last_hold ~= CurrentHold then 
            if not choice or not choice.Parent then
                TimeConnection:Disconnect()
                return
            end
            local TInfo = TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)
             local Tween = TweenService:Create(choice.Progress, TInfo, {Size = UDim2.new(0, 0, 1, 0)})
            Tween:Play()
            TimeConnection:Disconnect()
            return
        end

        if tick() >= CurrentHold + choice_data.choice.duration then
            self.script:ProceedAction(choice_data.choice)
            TimeConnection:Disconnect()
            return
        end
    end)   
end

function Prompt:SetDistance(distance: number)
    self.distance = distance
end

function Prompt:GetNodeRenderType()
    if not self.script then return end
    if not self.script.ptr then return end
    if #self.script.ptr.choices == 0 then return end
    if #self.script.ptr.choices == 1 then return "Single" end
    return "Radial"
end

function Prompt:UserInput(input_object: InputObject)
    if not self.render_data then return end
    local RenderType = self:GetNodeRenderType()
    assert(RenderType, "No script or no pointer")

    if input_object.UserInputType == Enum.UserInputType.Keyboard then
        if input_object.KeyCode ~= Enum.KeyCode.E then return end
        if RenderType ~= "Single" then return end

        if input_object.UserInputState == Enum.UserInputState.End then self.last_hold = nil; return end 

        local Choice = getTableKeys(self.render_data)[1]
        local ChoiceData = self.render_data[Choice]
        
        self:inputOnChoice(Choice, ChoiceData)
        return
    end

    if input_object.UserInputType == Enum.UserInputType.Touch or input_object.UserInputType == Enum.UserInputType.MouseButton1 then
        if input_object.UserInputState == Enum.UserInputState.End then self.last_hold = nil; return end

        local Choice, ChoiceData
        for frame, data in pairs(self.render_data) do
            if checkOnFrame(input_object.Position, frame) then
                Choice = frame
                ChoiceData = data
                break
            end
        end

        if not Choice then return end 
        self:inputOnChoice(Choice, ChoiceData)
        return
    end
end

function Prompt:GetRenderFrame()
    local RenderType = self:GetNodeRenderType()
    assert(RenderType, "No script or no pointer")
    if RenderType == "Single" then
        local Returnable = {}
        
        local _SingleFrame = Single_Frame:Clone()
        _SingleFrame.ActivityLabel.Text = self.script.ptr.choices[1].display

        Returnable[_SingleFrame] = {choice = self.script.ptr.choices[1], offset = UDim2.new(0, 0, 0, 0)}
        return Returnable
    end

    if RenderType == "Radial" then
        local ChoiceFrames_Table = {}

        local Radius = CurrentCamera.ViewportSize.Y * .15
        local AnglePerChoce = 360 / #self.script.ptr.choices
        local CurrentAngle = -AnglePerChoce

        for _, choice in pairs(self.script.ptr.choices) do
            CurrentAngle += AnglePerChoce

            local _RadialFrame = Radial_Frame:Clone()
            _RadialFrame.ActivityLabel.Text = choice.display
            
            -- Calculate offset for radial choice
            local XOffset = math.cos(math.rad(CurrentAngle)) * Radius 
		    local YOffset = math.sin(math.rad(CurrentAngle)) * Radius

            ChoiceFrames_Table[_RadialFrame] = {choice = choice, offset = UDim2.new(0, XOffset, 0, YOffset)}
        end

        return ChoiceFrames_Table
    end
end

function Prompt:Unrender()
    if self.render_connection then
        self.render_connection:Disconnect()
    end

    self.script:RemoveCallback("Pointer")

    self:HideCurrent()
end

function Prompt:HideCurrent()
    if self.render_data and self.screen_gui then
        local TempScreenUI = Instance.new('ScreenGui', Player.PlayerGui)
        TempScreenUI.Name = "DebrisProximityPrompt"

        for frame, data in pairs(self.render_data) do
            local _frame = frame:Clone()
            _frame.Parent = TempScreenUI
            local DisappearTween = TweenService:Create(_frame, TweenInfos.Disappear, {Size = UDim2.new(0, 0, 0 ,0)})
            DisappearTween:Play()
            Debris:AddItem(_frame, TweenInfos.Disappear.Time)
        end

        Debris:AddItem(TempScreenUI, TweenInfos.Disappear.Time)
    end

    if self.screen_gui then
        self.screen_gui:Destroy()
        self.screen_gui = nil
    end

    self.render_data = nil
end

function Prompt:Render()
    assert(self.script, "No script")
    assert(self.script.default, "No default node in script")
    assert(self.object, "No target object")
    self.script:SetPointer(self.script.default) -- Set pointer to default 
    assert(self:GetNodeRenderType(), "No choices in node")
    self.script:AttachCallback("Pointer", function()
        self:HideCurrent()
    end)

    self.render_connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not self.screen_gui then -- Render prompt
            self.screen_gui = Instance.new("ScreenGui", Player.PlayerGui)
            self.screen_gui.Name = string.format("Prompt%i", tick())

            self.render_data = self:GetRenderFrame()
            for frame, data in pairs(self.render_data) do
                frame.Parent = self.screen_gui

                local TargetSize = frame.Size
                frame.Size = UDim2.new(0, 0, 0, 0)
                local AppearTween = TweenService:Create(frame, TweenInfos.Appear, {Size = TargetSize})
                AppearTween:Play()
            end
        end

        local ScreenPoint = WorldToScreenPoint(self.object.Position)
        for frame, data in pairs(self.render_data) do
            frame.Position = UDim2.new(0, (ScreenPoint.X - frame.AbsoluteSize.X / 2) + data.offset.X.Offset, 0, (ScreenPoint.Y - frame.AbsoluteSize.Y / 2) + data.offset.Y.Offset)
        end
    end)
end

setmetatable(Prompt, {__call = Constructor})
return Prompt
