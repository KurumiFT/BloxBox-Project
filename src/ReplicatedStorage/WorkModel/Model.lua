-- Model for Work Controller

local Model = {}

function _initModelFolder(parent: Player) -- It's immutable data, please don't set values outside Model module
    local Core_Folder: Folder = Instance.new('Folder', parent)
    Core_Folder.Name = 'WorkData'
    
    local Work_String: StringValue = Instance.new('StringValue', Core_Folder)
    Work_String.Name = 'Work'

    local MetaData_Folder: Folder = Instance.new('Folder', Core_Folder)
    MetaData_Folder.Name = 'Meta'

    return Core_Folder
end

function Model.new(player: Player) -- Constructor for model + init data folder
    local self = {}

    self.player = player
    self.data = _initModelFolder(player)
    setmetatable(self, {__index = Model})
    return self
end

function Model:Destroy() -- Destroy model data
    if self.data then
        self.data:Destroy()
        self.data = nil
    end
end

function Model:Hire(work: string): boolean -- Try to hire
    if not self.data then return false end
    -- TODO
end 

return Model