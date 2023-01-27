local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local View = {}
local Activity = {} -- Store activity
Activity.__index = Activity

local Dependencies = require(ReplicatedStorage.dependencies)
local Trove = Dependencies.get('Trove')
local Shared = require(script.Parent.shared)

local Presets: Folder = script.Parent:WaitForChild('Presets')
local Customization_Screen: ScreenGui = Presets:WaitForChild('Customization')
local BodyPartFiller: TextButton = Presets:WaitForChild('BodyPartFiller')
local CategoryFiller: TextButton = Presets:WaitForChild('CategoryFiller')
local SectionFiller: TextButton = Presets:WaitForChild('SectionFiller')

local Fillers_Scale = {
    ['BodyPart'] =  .75,
    ['Category'] = .75,
    ['Section'] = 1
}

View.Activities = {
    ['Shop'] = 1
}

function fillerRender(filler: TextButton, dependency_parameter: string, scale: number)
    return function()
        local size = filler.Parent.AbsoluteSize[dependency_parameter] * scale
        filler.Size = UDim2.new(0, size, 0, size)
    end
end

function View.new(player: Player, model) -- View
    local self = setmetatable({}, {__index = View})
    self.player = player
    self.model = model
    self.activity = nil
    return self
end

function View:_renderShopActivity() -- This just render shop activity
    local _Customization_Screen

    if self.activity then
        if self.activity.id ~= View.Activities.Shop then
            self.activity:Destroy()
        else
            _Customization_Screen = self.activity.ui
        end
    else
        _Customization_Screen = Customization_Screen:Clone()
        _Customization_Screen.Parent = self.player.PlayerGui
    
        self.activity = Activity.new(View.Activities.Shop, _Customization_Screen)
        self.activity._trove:Add(_Customization_Screen)
    end 

    self.activity._trove:Disconnect()
    self:_fillParts()
    self:_fillCategories()
    self:_fillSections()
end

function View:_fillParts()
    -- First we need unrender previous body parts
    assert(self.activity.ui, 'No UI in activity')

    local _Customization_Screen: ScreenGui = self.activity.ui
    for i, v in pairs(_Customization_Screen.BodyPart:GetChildren()) do
        if v:IsA('TextButton') then
            v:Destroy()
        end
    end

    for _, part in pairs(Shared.sortByOrder(Shared.getKeys(self.model.criteria), Shared.Part_Order)) do
        local _BodyPartFiller = BodyPartFiller:Clone()
        _BodyPartFiller.Parent = _Customization_Screen.BodyPart
        _BodyPartFiller.LayoutOrder = _
        if self.model.selected_part == part then 
            _BodyPartFiller.Hover.Visible = true
        else
            _BodyPartFiller.Hover.Visible = false
        end
        self.activity._trove:Add(_BodyPartFiller)
        self.activity._trove:AddConnection(RunService.Heartbeat, fillerRender(_BodyPartFiller, 'X',Fillers_Scale.BodyPart))
    end
end

function View:_fillCategories()
    assert(self.activity.ui, 'No UI in activity')

    local _Customization_Screen: ScreenGui = self.activity.ui
    for i, v in pairs(_Customization_Screen.Category:GetChildren()) do
        if v:IsA('TextButton') then
            v:Destroy()
        end
    end

    for _, category in pairs(Shared.sortByOrder(self.model.criteria[self.model.selected_part], Shared.Category_Order)) do
        local _CategoryFiller = CategoryFiller:Clone()
        _CategoryFiller.Parent = _Customization_Screen.Category
        _CategoryFiller.LayoutOrder = _
        if self.model.selected_category == category then 
            _CategoryFiller.Hover.Visible = true
        else
            _CategoryFiller.Hover.Visible = false
        end
        self.activity._trove:Add(_CategoryFiller)
        self.activity._trove:AddConnection(RunService.Heartbeat, fillerRender(_CategoryFiller, 'X',Fillers_Scale.Category))
    end
end

function View:_fillSections()
    assert(self.activity.ui, 'No UI in activity')

    local _Customization_Screen: ScreenGui = self.activity.ui
    local Main_Frame: Frame = _Customization_Screen.Main
    local Section_Frame: Frame = Main_Frame.Section
    for i, v in pairs(Section_Frame:GetChildren()) do
        if v:IsA('TextButton') then
            v:Destroy()
        end
    end
    
    -- Temp solve (obly global section)
    local _Section = SectionFiller:Clone()
    _Section.Parent = Section_Frame
    self.activity._trove:Add(_Section)
    self.activity._trove:AddConnection(RunService.Heartbeat, fillerRender(_Section, 'Y',Fillers_Scale.Section))
end

function View:render(activity) -- AkA router
    if activity == View.Activities.Shop then
        self:_renderShopActivity()
    end
end

function Activity.new(id: number, ui: ScreenGui)
    local self = setmetatable({}, Activity)
    self.id = id
    self.ui = ui
    self._trove = Trove.new()
    return self
end

function Activity:Destroy()
    self._trove:Destroy()
end

return View