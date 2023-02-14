local ReplicatedStorage = game:GetService('ReplicatedStorage')

local kItemData = ReplicatedStorage:WaitForChild('kItemData')
local GetRemote = kItemData:WaitForChild("GetRemote")
local GetBindable = kItemData:WaitForChild('GetBindable')

local Kept_Data = {}

function getByID(id)
	if Kept_Data[id] then return Kept_Data[id] end
	
	Kept_Data[id] = GetRemote:InvokeServer(id)
	return Kept_Data
end

GetBindable.OnInvoke = function(id)
	return getByID(id)
end