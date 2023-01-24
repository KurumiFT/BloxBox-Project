local Model = {}

local ClothingModel = require(script.Clothing)
local CartModel = require(script.Cart)

function clothingCheckOnCriteria(clothing, criteria: table)
    for part, categories in pairs(criteria) do
        for _, category_name in ipairs(categories) do
            if clothing:check(part, category_name) then return true end
        end
    end

    return false
end

function getKeys(target: table): table -- Get keys table from table
    local keys = {}
    for key, _ in pairs(target) do
        table.insert(keys, key)
    end
    return keys
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
    -- Must be selected category and part

    self:parse() -- Parse by default
    return self
end

return Model