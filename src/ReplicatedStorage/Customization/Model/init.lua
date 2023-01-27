local Model = {}

local ClothingModel = require(script.Clothing)
local CartModel = require(script.Cart)
local Shared = require(script.Parent.shared)

function clothingCheckOnCriteria(clothing, criteria: table)
    for part, categories in pairs(criteria) do
        for _, category_name in ipairs(categories) do
            if clothing:check(part, category_name) then return true end
        end
    end

    return false
end

function Model:parse()
    assert(self.from, "There isn't 'from' attribute")

    self.clothing_data = {} -- Reset clothing data
    for i,v in ipairs(self.from:GetDescendants()) do
        if not v:IsA('Folder') then continue end -- Parse only folder
        local success, data = pcall(function() -- Try to parse
            local ClothingData = ClothingModel.newFrom(v)
            if clothingCheckOnCriteria(ClothingData, self.criteria) then -- Checks on criteria
                table.insert(self.clothing_data, ClothingData)
            end
        end)
        if not success then
            warn(string.format("Error while parsing - %s", v.Name))
        end  
    end
end

function Model:select(part: string, category: string): table
    local output = {}
    for _, model in pairs(self.clothing_data) do
        if model:check(part, category) then table.insert(output, model) end
    end

    return output
end

function Model.new(from: Folder, criteria: table)
    local self = setmetatable({}, {__index = Model})

    self.from = from
    self.criteria = criteria
    self.clothing_data = {} -- Parsed clothing models
    self.cart = CartModel.new()
    self.selected_part = Shared.sortByOrder(Shared.getKeys(self.criteria), Shared.Part_Order)[1]
    self.selected_category = Shared.sortByOrder(self.criteria[self.selected_part], Shared.Category_Order)[1]
    -- Selected values waiting
    self:parse() -- Parse by default
    return self
end

return Model