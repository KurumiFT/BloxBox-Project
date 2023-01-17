local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Dependencies = require(ReplicatedStorage.dependencies)
local ProximityPrompt_Folder: Folder = Dependencies.getFolder('ProximityPrompt')
local PPManage_Folder: Folder = ProximityPrompt_Folder:WaitForChild("Manage")

local NodeModule = require(ProximityPrompt_Folder:WaitForChild('Node'))
local PromptModule = require(ProximityPrompt_Folder:WaitForChild('Prompt'))
local HandlerModule = require(ProximityPrompt_Folder:WaitForChild('Handler'))
local Router = require(ProximityPrompt_Folder:WaitForChild('Router'))
local ScriptModule = require(ProximityPrompt_Folder:WaitForChild('Script'))

local Add_Event: RemoteEvent = PPManage_Folder:WaitForChild("Add")
local Remove_Event: RemoteEvent = PPManage_Folder:WaitForChild("Remove")

local Handler = HandlerModule()
Handler:SetRouter(Router)

function Deserialization(info)
    local _Prompt = PromptModule()
    _Prompt:SetDistance(info.distance)
    _Prompt:SetObject(info.object)
    
    local _Script = ScriptModule()
    _Script:SetDefault(info.script.default)
    _Prompt:SetScript(_Script)

    for _, node in pairs(info.script.nodes) do
        local _Node = NodeModule(node.name)
        for i, choice in pairs(node.choices) do
            local _Choice = _Node:NewChoice(choice.display, choice.duration)    
            _Choice:SetRedirect(choice.redirect)
            _Choice:SetAction(choice.action)
        end
        _Script:AttachNode(_Node)
    end

    return _Prompt
end

Add_Event.OnClientEvent:Connect(function(serialization_data)
    Handler:AddPrompt(Deserialization(serialization_data))
end)

Remove_Event.OnClientEvent:Connect(function(object: Part)
    Handler:RemovePrompt(object)
end)

Handler:Monitoring(true)