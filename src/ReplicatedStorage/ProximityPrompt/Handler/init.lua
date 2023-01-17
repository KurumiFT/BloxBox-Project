-- Please use this module only in one local script, it's singletone!

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local Handler = {}

local function Constructor()
    local self = {}
    self.prompts = {}
    self.current_prompt = nil

    setmetatable(self, {__index = Handler})
    return self
end

local function CharacterPosition()
    if not Player.Character then return end
    if not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    return Player.Character.HumanoidRootPart.Position
end

function Handler:SetRouter(router)
    self.router = router

    for _, prompt in pairs(self.prompts) do -- Update router in every prompt
        prompt.router = router
    end
 end

function Handler:GetByObject(object: BasePart)
    for _, v in pairs(self.prompts) do
        if v.object == object then return v end
    end
end

function Handler:AddPrompt(prompt)
    assert(prompt.object, "This prompt hasnt 'object' field")
    assert(prompt.distance, "This prompt hasnt 'distance' field")

    prompt.router = self.router
    table.insert(self.prompts, prompt)
end

function Handler:NearestPrompt()
    local CharacterPosition = CharacterPosition()
    if not CharacterPosition then return end
    local NearestPrompt -- First index for prompt, second for magnitude
    for _, prompt in pairs(self.prompts) do
        local Magnitude = (prompt.object.Position - CharacterPosition).Magnitude
        if Magnitude <= prompt.distance then
            if not NearestPrompt then
                NearestPrompt = {prompt, Magnitude}
            else
                if NearestPrompt[2] > Magnitude then
                    NearestPrompt = {prompt, Magnitude}
                end
            end
        end
    end
    if NearestPrompt then
        return NearestPrompt[1] 
    end
    return
end

function Handler:RemovePrompt(object: BasePart) -- Remove prompt by object)
    local Prompt = self:GetByObject(object)
    if not Prompt then return end

    table.remove(self.prompts, table.find(self.prompts, Prompt)) -- Need optimization

    if self.current_prompt then
        if self.current_prompt.object == object then self.current_prompt:Unrender(); self.current_prompt = nil end
    end
end

function Handler:Monitoring(state)
    if state then -- Start monitoring
        self.connection = RunService.Heartbeat:Connect(function()
            local NearestPrompt = self:NearestPrompt()
            if NearestPrompt ~= self.current_prompt then
                if self.current_prompt then self.current_prompt:Unrender() end
                self.current_prompt = NearestPrompt
                if self.current_prompt then self.current_prompt:Render() end
            end
        end)

        self.contoller_connection_begin = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
            if self.current_prompt then
                self.current_prompt:UserInput(input)
            end
        end)

        self.controller_connection_end = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
            if self.current_prompt then
                self.current_prompt:UserInput(input)
            end
        end)
    else
        if self.current_prompt then self.current_prompt:Unrender() end
        self.current_prompt = nil

        -- Disconnect all connections
        if self.connection then self.connection:Disconnect() end
        self.connection = nil
        if self.contoller_connection_begin then self.contoller_connection_begin:Disconnect() end
        self.contoller_connection_begin = nil
        if self.controller_connection_end then self.controller_connection_end:Disconnect() end
        self.controller_connection_end = nil
    end
end

setmetatable(Handler, {__call = Constructor})
return Handler