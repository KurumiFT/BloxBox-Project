local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')


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
local ClothFiller: TextButton = Presets:WaitForChild('ClothFiller')
local ColorFiller: TextButton = Presets:WaitForChild('ColorFiller')

local Room: Model = script.Parent.Room

local Camera: Camera = workspace.CurrentCamera
local ChangeCameraTween: TweenInfo = TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)
local CameraRotation: CFrame = CFrame.fromEulerAnglesXYZ(0, 0, 0)
local CameraZoom: number = 5

local ColorSelectionTween: TweenInfo = TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)

local ClothBorderSize: number = 10 -- In pixels
local ClothMargin: number = .06

local Fillers_Scale = {
    ['BodyPart'] =  .75,
    ['Category'] = .75,
    ['Additional'] = .3,
    ['AdditionalAction'] = .75,
    ['Color'] = .75,
    ['Section'] = 1,
}

View.Binds = {
    'ChooseCloth',
    'ChoosePart',
    'ChooseCategory',
    'ChooseColor'
}

View.Activities = {
    ['Shop'] = 1
}

function View:_clothRender(filler: TextButton, cloth_data)
    local fillerBody: ImageLabel = filler.Body
    local additionalMain: TextButton = filler.Additional
    local additionalBody: ImageLabel = additionalMain.Body
    -- Setup
    fillerBody.Size = UDim2.new(1, -ClothBorderSize, 1, -ClothBorderSize)
    fillerBody.Position = UDim2.new(0, ClothBorderSize / 2, 0, ClothBorderSize / 2)

    additionalMain.Size = UDim2.new(Fillers_Scale.Additional, 0, Fillers_Scale.Additional, 0)
    additionalMain.Position = UDim2.new(1 - Fillers_Scale.Additional, -ClothBorderSize / 2, 1 - Fillers_Scale.Additional, -ClothBorderSize / 2)        

    additionalBody.Size = UDim2.new(Fillers_Scale.AdditionalAction, 0, Fillers_Scale.AdditionalAction, 0)
    additionalBody.Position = UDim2.new(.5 - Fillers_Scale.AdditionalAction / 2, 0, .5 - Fillers_Scale.AdditionalAction / 2)

    return function ()
        if not self.model.selected_cloth[cloth_data.category] then
            filler.BackgroundColor3 = Color3.fromRGB(148, 148, 148)
        elseif self.model.selected_cloth[cloth_data.category].data ~= cloth_data then
            filler.BackgroundColor3 = Color3.fromRGB(148, 148, 148)
        else
            filler.BackgroundColor3 = Color3.fromRGB(227, 255, 191)
        end            
    end
end

function View:_colorRender(holder: ScrollingFrame)
    return function ()
        local Size = (holder.Parent.Parent.AbsoluteSize.X * holder.Parent.OriginalSize.Value) * Fillers_Scale.Color
        for i, v in pairs(holder:GetChildren()) do
            if v:IsA('TextButton') then
                if holder.AbsoluteSize.X == 0 then
                    v.Visible = false
                else
                    v.Visible = true
                end
                v.Size = UDim2.new(0, Size, 0, Size)
            end
        end
    end
end

function clothGridSetup(grid: UIGridLayout)
    return function ()
        local SizePerCell: number = ((grid.Parent.AbsoluteSize.X) * (1 - ClothMargin * 1)) / 2
        local Padding: number =  (grid.Parent.AbsoluteSize.X) * ClothMargin
        
        grid.CellSize = UDim2.new(0, SizePerCell, 0, SizePerCell)
        grid.CellPadding = UDim2.new(0, Padding, 0, Padding)
    end
end

function fillerRender(filler: TextButton, dependency_parameter: string, scale: number)
    return function()
        local size = filler.Parent.AbsoluteSize[dependency_parameter] * scale
        filler.Size = UDim2.new(0, size, 0, size)
    end
end

function View.new(model) -- View
    local self = setmetatable({}, {__index = View})
    self.player = Players.LocalPlayer
    self.model = model
    self.activity = nil
    self.callbacks = {}
    self.camera_rotation = CameraRotation
    self.camera_zoom = CameraZoom
    self.color_status = false
    self.stored_cloth = {}
    self._trove = Trove.new()

    -- -- Init events
    -- for i, v in ipairs(View.Binds) do
    --     self.events[v] = Instance.new('BindableEvent')
    --     self._trove:Add(self.events[v])
    -- end
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
        _Customization_Screen.Main.ColorHolder.Size = UDim2.new(0, 0, _Customization_Screen.Main.ColorHolder.Size.Y.Scale, _Customization_Screen.Main.ColorHolder.Size.Y.Offset)
        self.activity = Activity.new(View.Activities.Shop, _Customization_Screen)
        self.activity._trove:Add(_Customization_Screen)
    end 

    self.activity._trove:Disconnect() -- Disconnect previous connections

    self:_fillParts()
    self:_fillCategories()
    self:_fillSections()
    self:_fillCloth()
    self:_bindColorSelection()
    self:updateHeader()
end

function View:undress(category: string, restore: boolean)
    if self.model.selected_cloth[category] then
        self.model.selected_cloth[category].item:Destroy()
        self.model.selected_cloth[category] = nil
    end

    if not restore then
        local exist = self.model.character:FindFirstChild(category, true)
        if exist then
            self.stored_cloth[category] = {obj = exist:Clone(), parent = exist.Parent}
            self.stored_cloth[category].obj.Parent = nil
            exist:Destroy()
        end
    else
        if self.stored_cloth[category] then
            self.stored_cloth[category].obj.Parent = self.stored_cloth[category].parent
            self.stored_cloth[category] = nil
        end 
    end
end

function View:dress(data: any)
    assert(self.model.character, 'No character in player')

    self:undress(data.category, false)

    if data.object:IsA('Shirt') or data.object:IsA('Pants') then
        local _item = data.object:Clone()
        _item.Name = data.category
        _item.Color3 = data.colors.Default
        _item.Parent = self.model.character
        self.model.selected_cloth[data.category] = {data = data, item = _item}
        self._trove:Add(_item)
        return
    end

    if data.object:IsA('Decal') then
        local _item = data.object:Clone()
        _item.Name = data.category
        _item.Color3 = data.colors.Default
        _item.Parent = self.model.character.Head
        self.model.selected_cloth[data.category] = {data = data, item = _item}
        self._trove:Add(_item)
        return
    end
end

function View:cameraBind()
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = CFrame.new((self.model.character.HumanoidRootPart.CFrame * self.camera_rotation * CFrame.new(0, 0, -self.camera_zoom)).p, self.model.character.HumanoidRootPart.Position)
    self.camera_tween = nil

    self._trove:AddConnection(RunService.Heartbeat, function()
        local Target
        local OffsetData: table = Shared.Offsets[self.model.selected_category]

        if not OffsetData then
            Target = CFrame.new((self.model.character.HumanoidRootPart.CFrame * self.camera_rotation * CFrame.new(0, 0, -self.camera_zoom)).p, self.model.character.HumanoidRootPart.Position)
        else
            local BodyPart = self.model.character[OffsetData.Part]
            Target = CFrame.new((BodyPart.CFrame * self.camera_rotation * CFrame.new(0, OffsetData.Offset.Y, -self.camera_zoom)).p, BodyPart.Position + OffsetData.Offset)
        end

        if self.camera_target ~= self.model.selected_category then
            self.camera_tween = TweenService:Create(Camera, ChangeCameraTween, {CFrame = Target})
            self.camera_tween:Play()
            self.camera_target = self.model.selected_category
        else
            if self.camera_tween.PlaybackState ~= Enum.PlaybackState.Playing then
                Camera.CFrame = Target
            end
        end
    end)
end

function View:renderRoom()
    local _Room = Room:Clone()
    _Room.Parent = workspace
    _Room:PivotTo(CFrame.new(0, 1000, 0))
    self.model.character:PivotTo(_Room.StandPoint.CFrame * CFrame.new(0, _Room.StandPoint.Size.Y / 2 + 2.5, 0))
    self.room = _Room
    self._trove:Add(self.room)
end

function View:bind(action: string, callback)
    self.callbacks[action] = callback
end

function View:_bindColorSelection()
    local _Customization_Screen: ScreenGui = self.activity.ui
    local Main_Frame: Frame = _Customization_Screen.Main
    local ColorSelect: TextButton = Main_Frame.ColorSelect
    local ColorHolder: Frame = Main_Frame.ColorHolder
    local ColorHolderBody: ScrollingFrame = ColorHolder.Body
    local LastItem = nil

    self.activity._trove:AddConnection(ColorSelect.Activated, function()
        if not self.color_status then
            TweenService:Create(ColorHolder, ColorSelectionTween, {Size = UDim2.new(ColorHolder.OriginalSize.Value, 0, ColorHolder.Size.Y.Scale, ColorHolder.Size.Y.Offset)}):Play()
            TweenService:Create(ColorSelect.Body, ColorSelectionTween, {Rotation = 180}):Play()
            self.color_status = true
        else
            TweenService:Create(ColorHolder, ColorSelectionTween, {Size = UDim2.new(0, 0, ColorHolder.Size.Y.Scale, ColorHolder.Size.Y.Offset)}):Play()
            TweenService:Create(ColorSelect.Body, ColorSelectionTween, {Rotation = 0}):Play()
            self.color_status = false
        end
    end)

    self.activity._trove:AddConnection(RunService.PreRender, function()
        ColorHolder.Position = UDim2.new(0, -ColorHolder.AbsoluteSize.X, ColorHolder.Position.Y.Scale, ColorHolder.Position.Y.Offset)
        ColorSelect.Position = UDim2.new(-ColorSelect.Size.X.Scale, -ColorHolder.AbsoluteSize.X, ColorSelect.Position.Y.Scale, ColorSelect.Position.Y.Offset)
    end)

    self.activity._trove:AddConnection(RunService.Stepped, function()
        if not self.model.selected_cloth[self.model.selected_category] then 
            for i, v in pairs(ColorHolderBody:GetChildren()) do
                if v:IsA('TextButton') then v:Destroy() end
            end
            return
        end

        if self.model.selected_cloth[self.model.selected_category] == LastItem then return end

        for i, v in pairs(ColorHolderBody:GetChildren()) do
            if v:IsA('TextButton') then v:Destroy() end
        end

        LastItem = self.model.selected_cloth[self.model.selected_category]
        local Colors = LastItem.data.colors
        local DefaultFiller = ColorFiller:Clone()
        DefaultFiller.Parent = ColorHolderBody
        DefaultFiller.LayoutOrder = 0
        DefaultFiller.Body.BackgroundColor3 = Colors.Default
        self.activity._trove:AddConnection(DefaultFiller.Activated, function()
            self:_callback('ChooseColor', Colors.Default)
        end)

        for i, v in pairs(Colors.Other) do
            local _Filler = ColorFiller:Clone()
            _Filler.Parent = ColorHolderBody
            _Filler.LayoutOrder = 1+i
            _Filler.Body.BackgroundColor3 = v
            self.activity._trove:AddConnection(_Filler.Activated, function()
                self:_callback('ChooseColor', v)
            end)
        end

        self.activity._trove:Add(DefaultFiller)
    end)

    self.activity._trove:AddConnection(RunService.Heartbeat, self:_colorRender(ColorHolderBody))
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
        self.activity._trove:AddConnection(_BodyPartFiller.Activated, function()
            self:_callback('ChoosePart', part)
        end)
        self.activity._trove:AddConnection(RunService.PreRender, fillerRender(_BodyPartFiller, 'X',Fillers_Scale.BodyPart))
    end
end

function View:updateHeader()
    assert(self.activity.ui, 'No UI in activity')

    local _Customization_Screen: ScreenGui = self.activity.ui
    local Main_Frame: Frame = _Customization_Screen.Main
    local Header_Frame: Frame = Main_Frame.Header
    local Title: TextLabel = Header_Frame.Title


    if not self.model.selected_cloth[self.model.selected_category] then
        Title.Text = ""
    else
        Title.Text = self.model.selected_cloth[self.model.selected_category].data.name       
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
        self.activity._trove:AddConnection(_CategoryFiller.Activated, function()
            self:_callback('ChooseCategory', category)
        end)
        self.activity._trove:AddConnection(RunService.PreRender, fillerRender(_CategoryFiller, 'X',Fillers_Scale.Category))
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
    self.activity._trove:AddConnection(RunService.PreRender, fillerRender(_Section, 'Y',Fillers_Scale.Section))
end

function View:_callback(event: string, ...)
    if self.callbacks[event] then
        self.callbacks[event](...)
    end
end

function View:Destroy()
    self._trove:Destroy()
end

function View:_fillCloth()
    assert(self.activity.ui, 'No UI in activity')

    local _Customization_Screen: ScreenGui = self.activity.ui
    local Main_Frame: Frame = _Customization_Screen.Main
    local Holder_Frame: ScrollingFrame = Main_Frame.Holder

    for i, v in pairs(Holder_Frame:GetChildren()) do -- Remove previous cloth
        if v:IsA(ClothFiller.ClassName) then
            v:Destroy()
        end
    end

    for i, v in pairs(self.model.clothing_data) do
        if not v:check(self.model.selected_part, self.model.selected_category) then continue end
        local _ClothFiller = ClothFiller:Clone()
        _ClothFiller.Parent = Holder_Frame
        _ClothFiller.Body.Image = v.image
        self.activity._trove:AddConnection(_ClothFiller.Activated, function()
            self:_callback('ChooseCloth', v) 
        end)
        self.activity._trove:Add(_ClothFiller)
        self.activity._trove:AddConnection(RunService.PreRender, self:_clothRender(_ClothFiller, v))
    end
    self.activity._trove:AddConnection(RunService.PreRender, clothGridSetup(Holder_Frame.UIGridLayout))
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