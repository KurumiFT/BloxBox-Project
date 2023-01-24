-- Clothing model

local ClothingModel = {}

function ClothingModel.new(name: string, object: Decal | Model | MeshPart | Pants | Shirt, part: string, category: string, price: number, meta: table)
    local self = setmetatable({}, {__index = ClothingModel})
    -- Set fields
    self.name = name
    self.object = object
    self.part = part
    self.category = category
    self.price = price
    self.meta = meta
    
    return self
end

function ClothingModel.newFrom(target: Folder)
    return ClothingModel.new(target.Display.Value, target.Object, target.Part.Value, target.Category.Value, target.Price.Value, nil)
end

function ClothingModel:check(part: string, category: string)
    if self.category ~= category or self.part ~= part then return false end
    return true
end

return ClothingModel