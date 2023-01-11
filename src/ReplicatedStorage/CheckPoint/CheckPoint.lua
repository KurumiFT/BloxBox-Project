local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')

local Player = game.Players.LocalPlayer

local CheckPointModel: Model = script.Parent.CheckPointModel
local CheckPointTarget: string = "CheckPoints"
local CheckPointHeight: number = 25
local CheckPointVisualHeight: number = 75
local CheckPointCloseKoef: number = .8 -- Koef how close should be player to the center of checkpoint

local CheckPoint = {}

local VisibilityTweenInfo = TweenInfo.new(.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)

function checkOnProperty(instance: Instance, property: string) -- Help function to check instance on property
    local success = pcall(function()
        local check = instance[property]
    end)

    return success
end

function CheckPoint.new(name: string) -- Constructor for checkpoint
   local self = {}

   self.name = name
   setmetatable(self, {__index = CheckPoint})
   return self
end

function CheckPoint:setPosition(position: Vector3) -- Set checkpoint position
    self.position = position
end

function CheckPoint:setRadius(radius: number) -- Set radius to checkpoint
    self.radius = radius
end

function CheckPoint:_setVisibility(state: boolean) -- Set visibility with tween
    assert(self.checkpoint, 'No checkpoint in this model')
    if state then -- That mean we should show checkpoint
        for _, instance in pairs(self.checkpoint:GetDescendants()) do
            if checkOnProperty(instance, 'Transparency') then -- If this instance has transparency
                local GoalTransparency = instance.Transparency -- Goal transparency // idk how i can comment this
                instance.Transparency = 1 -- Hide
                TweenService:Create(instance, VisibilityTweenInfo, {Transparency = GoalTransparency}):Play()
            end
        end
    else -- We should hide this shit
        for _, instance in pairs(self.checkpoint:GetDescendants()) do
            if checkOnProperty(instance, 'Transparency') then -- If this instance has transparency
                TweenService:Create(instance, VisibilityTweenInfo, {Transparency = 1}):Play() -- Just play hide tween
            end
        end
    end
end

function CheckPoint:Spawn() -- Spawn function
    assert(self.position, "No position")
    assert(self.radius, "No radius")

    local TargetFolder: Folder? = workspace:FindFirstChild(CheckPointTarget) -- Check if folder exist in workspace
    if not TargetFolder then
        TargetFolder = Instance.new('Folder', workspace) -- Create if not
        TargetFolder.Name = CheckPointTarget
    end

    -- Init CheckPoint object
    local _CheckPoint: Model = CheckPointModel:Clone()
    _CheckPoint.Parent = TargetFolder
    _CheckPoint:PivotTo(CFrame.new(self.position) * CFrame.fromEulerAnglesXYZ(0, 0, math.pi /2) * CFrame.new(_CheckPoint.Ring.Size.X / 2, 0, 0))
    _CheckPoint.CheckPoint.Size = Vector3.new(_CheckPoint.CheckPoint.Size.X, self.radius * 2, self.radius * 2)
    _CheckPoint.Ring.Size = Vector3.new(CheckPointVisualHeight, self.radius * 2, self.radius * 2)
    _CheckPoint.Ring.CFrame = _CheckPoint.CheckPoint.CFrame * CFrame.new(_CheckPoint.Ring.Size.X / 2, 0, 0)

    self.checkpoint = _CheckPoint
    self:_setVisibility(true) -- show
end

function CheckPoint:Destroy() -- Destroy checkpoint
    if self.checkpoint then
        self:_setVisibility(false)
        task.delay(VisibilityTweenInfo.Time, function() -- Destroy after tween
            if self.checkpoint then
                self.checkpoint:Destroy()
                self.checkpoint = nil    
            end
        end)
    end

    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
end

function CheckPoint:listenCollisition(event: BindableEvent | RemoteEvent | nil)
    self.state = false -- False = not in CheckPoint area // True = in

    local function fire(...)
        if event:IsA('BindableEvent') then event:Fire(...) 
        elseif event:IsA('RemoteEvent') then event:FireServer(...) end
    end

    self.connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not self.checkpoint then return end -- If not checkpoint just ignore this iteration
        if not Player.Character then
            if self.state then -- If character was in CheckPoint
                fire(not self.state, self.name) -- Fire change state
                self.state = false
            end
        end

        if not self:_checkCollision(Player.Character.HumanoidRootPart.Position) then
            if self.state then -- If character was in CheckPoint
                fire(not self.state, self.name) -- Fire change state
                self.state = false
            end
        else
            if not self.state then -- If character wasn't in CheckPoint
                fire(not self.state, self.name) -- Fire change state
                self.state = true
            end
        end
    end)
end

function CheckPoint:_checkCollision(position: Vector3) -- Method for check collision with checkpoint
    assert(self.position, "No position")

    -- First we check Height
    if math.abs(position.Y - self.position.Y) > CheckPointHeight then return false end

    -- Get modified position where Y equal checkpoint Y
    local _ModifiedPosition: Vector3 = Vector3.new(position.X, self.position.Y, position.Z)

    return (_ModifiedPosition - self.position).Magnitude <= self.radius * CheckPointCloseKoef -- Point in circle? 
end

return CheckPoint