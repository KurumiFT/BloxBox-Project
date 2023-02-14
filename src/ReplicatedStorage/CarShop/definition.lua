local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Definations = {}

Definations.MapTable = {
    ['speed'] = {
        name = 'Скорость:',
        value = function(value: string)
            return value.." MP/H"
        end
    },
    ['overclocking'] = {
        name = 'Ускорение:',
        value = function(value: string)
            return value.." СЕК"
        end
    },
    ['control'] = {
        name = 'Управление:',
        value = function(value: string)
            return value.."%"
        end
    },
    ['brakes'] = {
        name = 'Тормоза:',
        value = function(value: string)
            return value.."%"
        end
    }
}

Definations.MapOrder = {'speed', 'overclocking', 'control', 'brakes'}
Definations.BaseColors = {
    Color3.fromHex('#FFFFFF'),
    Color3.fromHex('#000000'),
    Color3.fromHex('#FF50ED'),
    Color3.fromHex('#FF9900'),
    Color3.fromHex('#FF5050'),
    Color3.fromHex('#FBFF50'),
    Color3.fromHex('#50FF76'),
    Color3.fromHex('#5076FF')
}

Definations.CarsFolder = ReplicatedStorage.Cars
Definations.CarPlace = Workspace.CarShow
Definations.CarCamera = Workspace.CarCamera
Definations.TDPlace = Workspace.CarTestPlace
Definations.SpawnCarFolder = Workspace.Cars
Definations.CarShopSpawnPoint = Workspace.CarShopSpawn

Definations.TD_UI = script.Parent.TD_Display

Definations.CostInfoTween = TweenInfo.new(.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
Definations.BlindTween = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
Definations.SplashScreenTween = TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

Definations.EventFolder = script.Parent.Events
Definations.Events = {
    Buy = Definations.EventFolder.Buy,
    State = Definations.EventFolder.State,
    TD = Definations.EventFolder.TD
}

return Definations

