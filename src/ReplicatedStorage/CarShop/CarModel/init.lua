local CarModel = {}
CarModel.__index = CarModel

function CarModel.new(car_model: Model)
    local self = setmetatable({model = car_model, instance = nil}, CarModel)
    local Configuration = car_model:FindFirstChild('Configuration')
    assert(Configuration, string.format("%s hasn't configuration", car_model.Name))
    self.model = car_model

    for i, v in pairs(Configuration:GetChildren()) do
        self[v.Name] = v.Value
    end

    return self
end

function CarModel:Destroy()
    if self.instance then self.instance:Destroy() end
end

function CarModel:color(color: Color3)
    if not self.instance then return end
    self.used_color = color
    for _, part in pairs(self.instance:GetDescendants()) do
        if part.Name == 'Paint' and part:IsA('Model') then
            for _, paint in pairs(part:GetDescendants()) do
                if paint:IsA('BasePart') or paint:IsA('MeshPart') then
                    paint.Color = color
                end
            end
        end
    end
end

function CarModel:spawn(cframe: CFrame, parent)
    self:Destroy()

    local _instance: Model = self.model:Clone()
    _instance.Parent = parent
    _instance:PivotTo(cframe * CFrame.new(0, _instance:GetExtentsSize().Y / 2, 0))
    self.instance = _instance
end

return CarModel