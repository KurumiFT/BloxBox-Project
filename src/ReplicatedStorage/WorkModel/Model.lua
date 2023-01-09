-- Model for Work Controller

local Model = {}

local Router = require(script.Parent.Router)

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

function Model:TryHire(work: string) -- Try to hire // Fire if all good
    if not self.data then return end
    if self.data.Work.Value ~= "" then return end -- Already on job
    self.data.Work.Value = work

    Router.route(work, self.player, true) -- Route event
end

function Model:Hire(work: string) -- Force hire on work
    if not self.data then return end
    if self.data.Work.Value ~= "" then -- If has then fire "fire" event
        Router.route(self.data.Work.Value, self.player, false) 
    end -- Already on job

    self.data.Work.Value = work
    Router.route(work, self.player, true) -- Route event
end

function Model:TryFire(work: string) -- Try to fire from given work
    if not self.data then return end
    if self.data.Work.Value ~= work then return end
    self.data.Work.Value = '' -- Reset work to none
    Router.route(work, self.player, false) -- Route fire event
end

function Model:Fire() -- Force fire from work
    if not self.data then return end
    if self.data.Work.Value ~= '' then -- If he has work
        Router.route(self.data.Work.Value, self.player, false) 
    end

    self.data.Work.Value = '' -- Reset work data
end

return Model