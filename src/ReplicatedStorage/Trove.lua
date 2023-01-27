local Trove = {}
Trove.__index = Trove

function Trove.new()
    local self = setmetatable({}, Trove)
    self.instances = {}
    self.connections = {}
    return self
end

function Trove:Add(instance: any): any -- Add instance to Trove
    table.insert(self.instances, instance)
    return instance
end

function Trove:AddConnection(signal: RBXScriptSignal, callback): RBXScriptConnection
    local connection = signal:Connect(callback)
    table.insert(self.connections, connection)
    return connection
end

function Trove:Disconnect() -- Remove all connections
    for i, v in pairs(self.connections) do
        if not v then continue end 
        v:Disconnect()
        v = nil
    end

    self.connections = {}
end

function Trove:Destroy()
    for _, instance in ipairs(self.instances) do
        if not instance then continue end
        instance:Destroy() 
        instance = nil
    end

    self:Disconnect()
end

return Trove