local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')

local Definations = require(script.Parent.definition)

type CarInfo = {
    speed: number,
    overclocking: number,
    control: number,
    brakes: number,
    display: string,
    colors: table
}

type BaseProps = {
    size: UDim2,
    position: UDim2
}

type CarCardProps = BaseProps & {
    offset: UDim2,
    padding: number
}

type ColorPickProps = BaseProps & {
    offset: number
}

CarCard = {}
CarCard.__index = CarCard

local PropPresets = { -- Presets of Props
    CarCard = {size = UDim2.new(.28, 0, .2, 0), position = UDim2.new(.01, 0, .73, 0), offset = UDim2.new(.05, 0, .1, 0), padding = .05},
    RightSwipeArrow = {size = UDim2.new(.05, 0, .15, 0), position = UDim2.new(.94, 0, .425, 0)},
    LeftSwipeArrow = {size = UDim2.new(.05, 0, .15, 0), position = UDim2.new(.01, 0, .425, 0)},
    ColorPick = {size = UDim2.new(.27, 0, .25, 0), position = UDim2.new(.35, 0, .93, 0), offset = .06},
    Actions = {size = UDim2.new(.15, 0, .15, 0), position = UDim2.new(.8, 0, .78, 0)}
}

function CarCard.new(props: CarCardProps, parent: Instance)
    local self = setmetatable({
        parent = parent,
        ui = nil,
        label = nil,
        info = {},
        props = props
    }, CarCard)
    
    return self
end

function CarCard:setInfo(info: CarInfo)
    self.info = info
    self:render()
end

function CarCard:render()
    local Frame = Instance.new('Frame', self.parent)
    self:destroy()
    self.ui = Frame;
    Frame.Name = 'CarCard'
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.Size = self.props.size
    Frame.Position = self.props.position
    Frame.BackgroundTransparency = .5
    
    local UICorner = Instance.new('UICorner', self.ui)
    UICorner.CornerRadius = UDim.new(.05, 0)

    local LabelHeight = (1 - (self.props.offset.Y.Scale * 2) - (self.props.padding * (#Definations.MapOrder - 1))) / #Definations.MapOrder
    local LabelWidth = (1 - (self.props.offset.X.Scale * 2)) / 2

    -- Labels block
    for i, key in pairs(Definations.MapOrder) do
        local Name_Label = Instance.new('TextLabel', Frame)
        local Value_Label = Instance.new('TextLabel', Frame)
        local Height = self.props.offset.Y.Scale + (LabelHeight * (i - 1)) + (self.props.padding * (i -1))

        Name_Label.BackgroundTransparency = 1
        Name_Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Name_Label.FontFace = Font.fromEnum(Enum.Font.Arial)  
        Name_Label.TextScaled = true
        Name_Label.TextXAlignment = Enum.TextXAlignment.Left;
        Name_Label.Text = Definations.MapTable[key].name
        Name_Label.Size = UDim2.new(LabelWidth, 0, LabelHeight, 0)
        Name_Label.Position = UDim2.new(self.props.offset.X.Scale, 0, Height, 0)

        Value_Label.BackgroundTransparency = 1
        Value_Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Value_Label.FontFace = Font.fromEnum(Enum.Font.ArialBold)  
        Value_Label.TextScaled = true
        Value_Label.TextXAlignment = Enum.TextXAlignment.Right;
        Value_Label.Text = Definations.MapTable[key].value(self.info[key] or "")
        Value_Label.Size = UDim2.new(LabelWidth, 0, LabelHeight, 0)
        Value_Label.Position = UDim2.new(self.props.offset.X.Scale + LabelWidth, 0, Height, 0)
    end

    -- Display name TextLabel
    local TextLabel = Instance.new('TextLabel', self.parent)
    TextLabel.Size = UDim2.new(.4, 0, .07, 0)
    TextLabel.Position = UDim2.new(.05, 0, .01, 0)
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.FontFace = Font.fromEnum(Enum.Font.Arial)
    TextLabel.RichText = true
    TextLabel.Text = self.info.display or ""
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextScaled = true
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.label = TextLabel
end

function CarCard:destroy()
    if self.ui then self.ui:Destroy() end
    if self.label then self.label:Destroy() end
end

local SwipeArrow = {}
SwipeArrow.__index = SwipeArrow
function SwipeArrow.new(props: BaseProps, parent: Instance, callback, rotation: number)   
    local self = setmetatable({
        props = props, 
        ui = nil,
        connections = {},
        parent= parent,
        callback = callback,
        rotation = rotation}, SwipeArrow)

    return self
end

function SwipeArrow:destroy()
    for _, connection in self.connections do
        connection:Disconnect()
        connection = nil
    end

    self.connections = {}

    if self.ui then
        self.ui:Destroy()
    end
end

function SwipeArrow:render()
    self:destroy()
    

    local Button = Instance.new('TextButton', self.parent); self.ui = Button
    Button.Rotation = self.rotation
    Button.Position = self.props.position
    Button.Size = self.props.size
    Button.FontFace = Font.fromEnum(Enum.Font.ArialBold)
    Button.Text = ">"
    Button.TextScaled = true
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Button.BackgroundTransparency = .5

    table.insert(self.connections, Button.Activated:Connect(function()
        self.callback(self.rotation)
    end))
end

local ColorPick = {}
ColorPick.__index = ColorPick

function ColorPick.new(props: ColorPickProps, parent: Instance, callback, colors: table)
    local self = setmetatable({
        parent = parent,
        props = props,
        colors = colors,
        connections = {},
        callback = callback
    }, ColorPick)    

    return self
end

function ColorPick:destroy()
    for _, connection in self.connections do
        connection:Disconnect()
        connection = nil
    end

    self.connections = {}

    if self.ui then
        self.ui:Destroy()
    end
end

function ColorPick:render()
    self:destroy()

    local ScrollingFrame = Instance.new('ScrollingFrame', self.parent); self.ui = ScrollingFrame
    ScrollingFrame.Size = self.props.size
    ScrollingFrame.ScrollingEnabled = false
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.Size = self.props.size
    ScrollingFrame.ScrollBarThickness = 0

    local ColorsPerRow = #self.colors / 2
    local SizePerButton = (ScrollingFrame.AbsoluteSize.X - (ScrollingFrame.AbsoluteSize.X * self.props.offset * (ColorsPerRow - 1))) / ColorsPerRow

    ScrollingFrame.Size = UDim2.new(self.props.size.X.Scale, 0, 0, (SizePerButton * 2) + (self.props.offset * ScrollingFrame.AbsoluteSize.X))
    ScrollingFrame.Position = UDim2.new(self.props.position.X.Scale, 0, self.props.position.Y.Scale, -ScrollingFrame.AbsoluteSize.Y)

    for i, v in ipairs(self.colors) do
        local TextButton = Instance.new('TextButton', ScrollingFrame)
        TextButton.BackgroundColor3 = Color3.fromRGB('0, 0, 0')
        TextButton.BackgroundTransparency = .5
        TextButton.Text = ""
        TextButton.Name = 'Choice'
        TextButton.Size = UDim2.new(0, SizePerButton, 0,SizePerButton)
        local Height = if i > ColorsPerRow then SizePerButton + (ScrollingFrame.AbsoluteSize.X * self.props.offset) else 0
        local Index = if i > ColorsPerRow then i - ColorsPerRow else i
        TextButton.Position = UDim2.new(0, (SizePerButton * (Index - 1)) + (ScrollingFrame.AbsoluteSize.X * self.props.offset * (Index - 1)), 0, Height)

        local Frame = Instance.new('Frame', TextButton)
        Frame.Size = UDim2.fromScale(.9, .9)
        Frame.Position = UDim2.fromScale(.05, .05)
        Frame.BackgroundColor3 = v
        Frame.Name = 'Body'

        local UICorner = Instance.new('UICorner', TextButton)
        UICorner.CornerRadius = UDim.new(.1, 0)
        UICorner:Clone().Parent = Frame

        table.insert(self.connections, TextButton.Activated:Connect(function()
            self.callback(v)
        end))
    end
end

function ColorPick:setInfo(colors: table)
    self.colors = colors
    self:render()
end

function ColorPick:pick(color: Color3) -- Select
    for i, v in pairs(self.ui:GetChildren()) do
        if v.Body.BackgroundColor3 == color then v.BackgroundColor3 = Color3.fromHex('#FFFFFF')
        else v.BackgroundColor3 = Color3.fromRGB(0, 0, 0) end
    end
end

local Blind = {}
Blind.__index = Blind
function Blind.new(tween, callback ,parent)
    local self = setmetatable({}, Blind)
    self.tween = tween
    self.blind = nil
    self.callback = callback
    self.parent = parent
    return self
end

function Blind:Drop()
    if self.blind then self.blind:Destroy() end

    local _blind = Instance.new('Frame', self.parent)
    _blind.Size = UDim2.new(1, 0, 0, 0)
    _blind.BackgroundColor3 = Color3.fromHex('#38393E')
    _blind.BorderSizePixel = 0
    _blind.ZIndex = 1000
    _blind.Position = UDim2.new(0, 0, 0 ,-36)
    self.blind = _blind
    local Tween = TweenService:Create(_blind, self.tween, {Size = UDim2.new(1, 0, 1, 36)})
    Tween:Play()
    Tween.Completed:Once(function(playbackState)
        self.callback(true)
    end)
end

function Blind:Pump()
    if not self.blind then return end

    local Tween = TweenService:Create(self.blind, self.tween, {Size = UDim2.new(1, 0, 0, 0)})
    Tween:Play()
    Tween.Completed:Once(function()
        self.blind:Destroy()
    end)
end

local SplashScreen = {}
SplashScreen.__index = SplashScreen
function SplashScreen.new(text: string, parent)
    local self = setmetatable({connection = nil}, SplashScreen)
    local Frame = Instance.new('Frame', parent); self.ui = Frame
    Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Frame.ZIndex = 10
    Frame.Size = UDim2.new(0, 0, 0, 0)
    local UICorner = Instance.new('UICorner', Frame)
    UICorner.CornerRadius = UDim.new(.1, 0)    

    local InfoLabel = Instance.new('TextLabel', Frame)
    InfoLabel.Size = UDim2.fromScale(.9, .75)
    InfoLabel.Position = UDim2.fromScale(.05, .125)
    InfoLabel.RichText = true
    InfoLabel.TextScaled = true
    InfoLabel.FontFace = Font.fromEnum(Enum.Font.Arial)
    InfoLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = text
    InfoLabel.ZIndex = Frame.ZIndex + 1

    local Progression = Instance.new('Frame', Frame)
    Progression.BackgroundColor3 = Color3.fromRGB(153, 153, 153)
    Progression.Position = UDim2.fromScale(0, .95)
    Progression.ZIndex = Frame.ZIndex + 1
    local _corner = UICorner:Clone()
    _corner.Parent = Progression
    _corner.CornerRadius = UDim.new(.5, 0)
    local Duration = 3
    local StartTime = tick()

    local Tween = TweenService:Create(Frame, Definations.SplashScreenTween, {Size = UDim2.new(.35, 0, .35, 0)})
    Tween:Play()
    self.connection = RunService.Heartbeat:Connect(function(deltaTime)
        Frame.Position = UDim2.fromScale(.5 - Frame.Size.X.Scale / 2, .5 - Frame.Size.Y.Scale / 2)
        if tick() - StartTime >= Duration then
            self:destroy()
        else
            Progression.Size = UDim2.new(1 - ((tick() - StartTime) / Duration), 0, .05, 0)
        end
    end)
end

function SplashScreen:destroy() -- (!) Must complete
    self.connection:Disconnect()
    local R
end 

local Actions = {}
Actions.__index = Actions
function Actions.new(props: BaseProps, callbacks, parent)
    local self = setmetatable({parent = parent, callbacks = callbacks ,props = props, ui = nil, connections = {}}, Actions)

    return self
end

function Actions:destroy() 
    if self.ui then self.ui:Destroy() end
    for i, v in pairs(self.connections) do
        v:Disconnect()
        v = nil
    end 
    self.connections = {}
end

function Actions:render(buy_state: boolean, td_state: boolean, cost: number) 
    self:destroy()

    local Holder_Frame = Instance.new('Frame', self.parent); self.ui = Holder_Frame
    Holder_Frame.BackgroundTransparency = 1
    Holder_Frame.Size = self.props.size
    Holder_Frame.Position = self.props.position
    
    local BuyButton = Instance.new('TextButton', Holder_Frame)
    BuyButton.BackgroundColor3 = if buy_state then Color3.fromHex('#F5F5F5') else Color3.fromHex('#1B1B1B')
    BuyButton.BackgroundTransparency = if buy_state then 0 else .5
    BuyButton.Active = buy_state
    BuyButton.Size = UDim2.new(1, 0, .45, 0)
    BuyButton.Text = ""
    BuyButton.Position = UDim2.new(0, 0, .55, 0)
    local Body = Instance.new('TextLabel', BuyButton)
    Body.Size = UDim2.new(.75, 0, .75, 0)
    Body.TextColor3 =  if buy_state then Color3.fromHex('#292929') else Color3.fromHex('#686868')
    Body.TextScaled = true
    Body.Position = UDim2.fromScale(.125, .125)
    Body.BackgroundTransparency = 1
    Body.FontFace = Font.fromEnum(Enum.Font.Arial)
    Body.Text = 'КУПИТЬ'


    local UI_Corner = Instance.new('UICorner', BuyButton)
    UI_Corner.CornerRadius = UDim.new(.1, 0)

    local TestDrive = BuyButton:Clone()
    TestDrive.Parent = Holder_Frame
    TestDrive.Position = UDim2.new(0, 0, 0, 0)
    TestDrive.TextLabel.Text = 'ТЕСТ-ДРАЙВ'
    TestDrive.BackgroundTransparency = if td_state then 0 else .5
    TestDrive.TextLabel.TextColor3 =  if td_state then Color3.fromHex('#292929') else Color3.fromHex('#686868')
    TestDrive.BackgroundColor3 = if td_state then Color3.fromHex('#F5F5F5') else Color3.fromHex('#1B1B1B')
    TestDrive.Active = td_state

    local Cost_Info: ScrollingFrame = Instance.new('ScrollingFrame', BuyButton)
    Cost_Info.ZIndex = 5
    Cost_Info.Size = UDim2.new(1, 0, 0, 0)
    Cost_Info.ScrollingEnabled = false
    Cost_Info.ScrollBarThickness = 0
    Cost_Info.Position = UDim2.fromScale(0, 1)
    Cost_Info.BorderSizePixel = 0
    Cost_Info.BackgroundColor3 = BuyButton.BackgroundColor3
    Cost_Info.BackgroundTransparency = BuyButton.BackgroundTransparency
    local CostInfo_Body:TextLabel = Instance.new('TextLabel', Cost_Info)
    CostInfo_Body.ZIndex = 6
    CostInfo_Body.Size = UDim2.fromOffset(BuyButton.AbsoluteSize.X, BuyButton.AbsoluteSize.Y * .5)
    CostInfo_Body.Text = cost.."$"
    CostInfo_Body.FontFace = Font.fromEnum(Enum.Font.ArialBold)
    CostInfo_Body.TextColor3 = Body.TextColor3
    CostInfo_Body.BackgroundTransparency = 1
    CostInfo_Body.TextScaled = true
    UI_Corner:Clone().Parent = Cost_Info

    table.insert(self.connections, BuyButton.InputBegan:Connect(function(inputObject: InputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
            local Tween = TweenService:Create(Cost_Info, Definations.CostInfoTween, {Size = UDim2.new(1, 0, .5, 0)})
            Tween:Play() 
        end
    end))

    table.insert(self.connections, BuyButton.InputEnded:Connect(function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
            local Tween = TweenService:Create(Cost_Info, Definations.CostInfoTween, {Size = UDim2.new(1, 0, 0, 0)})
            Tween:Play() 
        end
    end))

    table.insert(self.connections, BuyButton.Activated:Connect(function()
        self.callbacks.buy()
    end))

    table.insert(self.connections, TestDrive.Activated:Connect(function()
        self.callbacks.testdrive()
    end))
end

local View = {}
View.__index = View
function View.new(parent, callbacks: table)
    local Holder = Instance.new('ScreenGui', parent)
    Holder.Name = 'CarShop'

    local self = setmetatable({
        Holder = Holder,
        CarCard = CarCard.new(PropPresets.CarCard, Holder),
        RightSwipe = SwipeArrow.new(PropPresets.RightSwipeArrow, Holder, callbacks.swipe, 0),
        LeftSwipe = SwipeArrow.new(PropPresets.LeftSwipeArrow, Holder, callbacks.swipe, 180),
        ColorPick = ColorPick.new(PropPresets.ColorPick, Holder, callbacks.color, {}),
        Actions = Actions.new(PropPresets.Actions, callbacks, Holder),

        Info = {}
    },View)

    return self
end
function View:pickColor(color: Color3)
    self.ColorPick:pick(color)
end

function View:setInfo(info: CarInfo)
    self.Info = info
    self.CarCard:setInfo(info)
    self.ColorPick:setInfo(info.colors)
end

function View:Destroy()
    for i,v in pairs(self) do
        if v.destroy then
            v:destroy()
        end
    end
end

return {View = View, Blind = Blind, SplashScreen = SplashScreen}