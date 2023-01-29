local Shared = {}

Shared.Part_Order = {
    ['Head'] = 0,
    ['Body'] = 1,
    ['Legs'] = 2,
    ['Foot'] = 3,
    ['Accessories'] = 4
}

Shared.Category_Order = {
    -- Head
    ['Brows'] = 0,
    ['Eyes'] = 1,
    ['Mouth'] = 2,
    ['Beard'] = 3,
    ['Hair'] = 4
}

Shared.Offsets = {
    ['Brows'] = {Part= 'Head', Offset = Vector3.zero},
    ['Eyes'] = {Part = 'Head', Offset = Vector3.zero},

    ['Pants'] = {Part = 'HumanoidRootPart', Offset = Vector3.new(0, -1.5, 0)},
    ['Shirt'] = {Part = 'HumanoidRootPart', Offset = Vector3.zero}
}

Shared.getKeys = function(target: table): table -- Get keys table from table
    local keys = {}
    for key, _ in pairs(target) do
        table.insert(keys, key)
    end
    return keys
end

Shared.sortByOrder = function(exist: table, order_table: table)
    local OrderedTable = {}
    local UnOrderedTable = {}
    local OutputTable = {}
    for _, v in pairs(exist) do
        local ordered = order_table[v]
        if not ordered then
            table.insert(UnOrderedTable, v)
        else
            OrderedTable[v] = ordered
        end
    end

    for i = 0, #Shared.getKeys(order_table) - 1 do
        for _, v in pairs(OrderedTable) do
            if v == i then
                table.insert(OutputTable, _)
                break
            end
        end
    end

    for i, v in pairs(UnOrderedTable) do
        table.insert(OutputTable, v)
    end

    return OutputTable
end

return Shared