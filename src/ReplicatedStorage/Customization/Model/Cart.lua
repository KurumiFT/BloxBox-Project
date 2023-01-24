local Cart = {}

function Cart.new()
    local self = setmetatable({}, {__index = Cart})
    self.items = {}
    return self
end

function Cart:Add(item, count)
    -- check if already exist
    for _, item in ipairs() do
        if item.item == item then
            item.count += count
            return 
        end
    end

    table.insert(self.items, {item = item, count = count}) -- Add if doesn't exist in 'items'
end
return Cart