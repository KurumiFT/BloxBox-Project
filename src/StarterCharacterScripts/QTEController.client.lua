local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Dependencies = require(ReplicatedStorage.dependencies)
local QTEDependency_Folder: Folder = Dependencies.getFolder('QTE')

local QTERemotes_Folder: Folder = QTEDependency_Folder.Remotes
local AddRemote_Event: RemoteEvent = QTERemotes_Folder.Add
local DeleteRemote_Event: RemoteEvent = QTERemotes_Folder.Delete

local QTE_Dependencies = {
    ['LockPick'] = Dependencies.get('LockPickQTE')
}

local LastQTE = {type = nil, examplar = nil} -- Last QTE

function Add(type: string, meta: table)
    if LastQTE.examplar then
        LastQTE.examplar:Destroy() -- Destroy prev QTE
    end
    assert(QTE_Dependencies[type], "There isn't QTE with this type")
    LastQTE = {type = type, examplar = QTE_Dependencies[type].new(unpack(meta))}
end

function Delete(type: string)
    if LastQTE.type == type then
        LastQTE.examplar:Destroy()
        LastQTE = {type = nil, examplar = nil}
    end
end

AddRemote_Event.OnClientEvent:Connect(Add) -- Delegete 'add' remote event
DeleteRemote_Event.OnClientEvent:Connect(Delete) -- Delegete 'delete' remote event