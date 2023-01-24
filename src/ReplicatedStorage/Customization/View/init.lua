local ReplicatedStorage = game:GetService('ReplicatedStorage')

local View = {}
local Activity = {} -- Store activity
Activity.__index = Activity

local Dependencies = require(ReplicatedStorage.dependencies)
local Trove = Dependencies.get('Trove')

local Presets: Folder = script.Parent:WaitForChild('Presets')
local Customization_Screen: ScreenGui = Presets:WaitForChild('Customization')
local BodyPartFiller: TextButton = Presets:WaitForChild('BodyPartFiller')
local CategoryFiller: TextButton = Presets:WaitForChild('CategoryFiller')

View.Activities = {
    ['Shop'] = 1
}

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

    print(self.model:select('Legs', 'Pants'))
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