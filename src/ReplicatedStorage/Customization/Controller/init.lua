local Controller = {}

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService: UserInputService = game:GetService('UserInputService')

local Dependencies = require(ReplicatedStorage:WaitForChild('dependencies'))
local Trove = Dependencies.get('Trove')
local View = require(script.Parent.View)
local Model = require(script.Parent.Model)

local RotationSensitive = .25

function checkOverFrame(hit: Vector3, frame: Frame | ScrollingFrame | TextButton) -- Check hit position over frame
    if frame.AbsolutePosition.X > hit.X then return false end
    if frame.AbsolutePosition.X + frame.AbsoluteSize.X < hit.X then return false end
    if frame.AbsolutePosition.Y > hit.Y then return false end
    if frame.AbsolutePosition.Y + frame.AbsoluteSize.Y < hit.Y then return false end
    return true
end

function Controller:bindCameraMove() -- Bind camera move
    self.last_position = nil
    self.camera_began = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if self.view.activity then
                local over = false
                for i, v in pairs(self.view.activity.ui:GetDescendants()) do
                    if v:IsA('TextButton') or v:IsA('Frame') or v:IsA('ScrollingFrame') then
                        if checkOverFrame(input.Position, v) then over = true; break end
                    end
                end

                if over then return end
                self.last_position = input.Position
            end
        end
    end)
    self.camera_move = UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if not self.last_position then return end
            local YRotation = (self.last_position.X - input.Position.X) * RotationSensitive
            local XRotation = (self.last_position.Y - input.Position.Y) * RotationSensitive
            self.last_position = input.Position
            self.view.camera_rotation = self.view.camera_rotation * CFrame.fromEulerAnglesXYZ(math.rad(XRotation), math.rad(YRotation), 0)
        end
    end)

    self.camera_end = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.last_position = nil
        end
    end)
end

function Controller.new(clothing: Folder, criteria: table)
    local self = setmetatable({}, {__index = Controller})

    self._trove = Trove.new()
    self.model = Model.new(clothing, criteria)
    self.view = View.new(self.model)
    self.view:renderRoom()
    self:bindCameraMove()
    self.view:cameraBind()
    self.view:render(View.Activities.Shop)
    self.view:bind('ChooseCloth', function(data)
        if self.model.selected_cloth[self.model.selected_category] then
            if self.model.selected_cloth[self.model.selected_category].data == data then
                self.view:undress(self.model.selected_category, true) 
            end
        else
            self.view:dress(data)
        end

        self.view:updateHeader()
    end)

    self.view:bind('ChoosePart', function(part)
        if self.model.selected_part == part then return end
        self.model.selected_part = part
        self.view.camera_rotation = CFrame.fromEulerAnglesXYZ(0, 0, 0) -- Reset camera
        self.model:pickDefaultCategory()
        self.view:render(View.Activities.Shop)
    end)

    self.view:bind('ChooseCategory', function(category)
        if self.model.selected_category == category then return end
        self.view.camera_rotation = CFrame.fromEulerAnglesXYZ(0, 0, 0) -- Reset camera
        self.model.selected_category = category
        self.view:render(View.Activities.Shop)
    end)    

    self.view:bind('ChooseColor', function(color: Color3)
        print(color)
        if self.model.selected_cloth[self.model.selected_category] then
            self.model.selected_cloth[self.model.selected_category].item.Color3 = color
        end
    end)

    self._trove:Add(self.view)
    self._trove:Add(self.model)
    return self
end

return Controller