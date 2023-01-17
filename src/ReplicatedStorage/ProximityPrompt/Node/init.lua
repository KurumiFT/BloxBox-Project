local Node = {}

local function Constructor(table, name: string)
    local self = {}

    self.name = name
    self.choices = {}
    setmetatable(self, {__index = Node})

    return self
end

function Node:NewChoice(display: string, duration: number)
    local choice = {}
    choice.display = display
    choice.duration = duration

    function choice:SetRedirect(name: string)
        choice.redirect = name
    end

    function choice:SetAction(action: string)
        choice.action = action
    end

    table.insert(self.choices, choice)
    return choice
end

setmetatable(Node, {__call = Constructor})

return Node