local Script = {}

local function Constructor()
    local self = {}
    self.nodes = {}
    self.callbacks = {Pointer = Instance.new('BindableEvent'), Action = Instance.new("BindableFunction")}
    self.connections = {}
    setmetatable(self, {__index = Script})
    return self
end

function Script:AttachNode(node)
    table.insert(self.nodes, node)
end

function Script:GetNode(name: string)
    for _, v in ipairs(self.nodes) do
        if v.name == name then return v end
    end
end

function Script:AttachCallback(name: string, callback)
    assert(self.callbacks[name], "This callback doesnt exist")

    if self.callbacks[name]:IsA("BindableEvent") then
        self.connections[name] = self.callbacks[name].Event:Connect(callback) 
    elseif self.callbacks[name]:IsA("BindableFunction") then
        self.callbacks[name].OnInvoke = callback
    end
end

function Script:RemoveCallback(name: string)
    if self.callbacks[name] then
        if self.callbacks[name]:IsA("BindableEvent") then
            if self.connections[name] then
                self.connections[name]:Disconnect()     
            end
            self.connections[name] = nil
        elseif self.callbacks[name]:IsA("BindableFunction") then
            self.callbacks[name].OnInvoke = nil
        end
    end
end

function Script:RemoveNode(name: string)
    local Node = self:GetNode(name)
    if not Node then return end
    table.remove(self.nodes, table.find(self.nodes, Node))
end

function Script:SetDefault(name: string)
    self.default = name
end

function Script:ProceedAction(choice)
    if choice.redirect then
        self:SetPointer(choice.redirect) 
    else
        self:SetPointer(self.default) 
    end

    spawn(function()
        self.callbacks['Action']:Invoke(choice.action) 
    end)
end

function Script:SetPointer(name: string)
    local Node = self:GetNode(name)
    if not Node then return end
    self.ptr = Node
    self.callbacks['Pointer']:Fire()
end

setmetatable(Script, {__call = Constructor})

return Script