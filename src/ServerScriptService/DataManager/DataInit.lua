-- Script made by Kurumi )
-- Script needed for initialization data folder

local module = {}

local DataTypes = {
	string = "StringValue",
	number = "NumberValue",
	boolean = "BoolValue",
	Vector3 = "Vector3Value",
	CFrame = "CFrameValue",
	BrickColor = "BrickColorValue",
	Color3 = "Color3Value",
	Ray = "RayValue",
	Instance = "ObjectValue"
}

function initObject(object, data) -- Instead using Instance.new() and setting attributes
	local _instance = Instance.new(object, data.Parent)

	for i,v in pairs(data) do
		_instance[i] = v
	end

	return _instance
end

function module.init(data, parent)
	local function goRecursive(_dictionary, _parent) -- Recursive function
		local data_folder

		for i,v in pairs(_dictionary) do
			local _type = typeof(v)
			if _type == "table" then
				data_folder	= initObject("Folder", {Name = i, Parent = _parent})
				goRecursive(v, data_folder)
			elseif DataTypes[_type] then
				initObject(DataTypes[_type], {Value = v, Name = i, Parent = _parent})
			end 
		end

		return data_folder
	end 

	return goRecursive(data, parent)
end

return module
