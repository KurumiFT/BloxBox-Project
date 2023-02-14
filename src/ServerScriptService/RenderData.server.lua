-- Script for get data from "Postgre" 

-- Services
local Http_Service = game:GetService('HttpService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Assets
local kItemData = ReplicatedStorage:WaitForChild('kItemData')
local GetRemote = kItemData:WaitForChild('GetRemote')
local GetBindable = kItemData:WaitForChild('GetBindable')

local Kept_Data = {}

local URL = "https://bloxbox.onrender.com/item?id=" -- URL Template

GetBindable.OnInvoke = function(id)
	if not Kept_Data[id] then 
		local response = Http_Service:GetAsync(URL..id)
		local data = Http_Service:JSONDecode(response)
		Kept_Data[id] = data
	end
	return Kept_Data[id]
end

GetRemote.OnServerInvoke = function(player, id)
	if not Kept_Data[id] then 
		local response = Http_Service:GetAsync(URL..id)
		local data = Http_Service:JSONDecode(response)
		Kept_Data[id] = data
	end

	return Kept_Data[id]
end
