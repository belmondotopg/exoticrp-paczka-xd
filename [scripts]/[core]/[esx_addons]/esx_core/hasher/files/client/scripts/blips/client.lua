local Citizen = Citizen

local AddBlipForCoord = AddBlipForCoord
local SetBlipSprite = SetBlipSprite
local SetBlipScale = SetBlipScale
local SetBlipDisplay = SetBlipDisplay
local SetBlipColour = SetBlipColour
local SetBlipAsShortRange = SetBlipAsShortRange
local EndTextCommandSetBlipName = EndTextCommandSetBlipName
local AddTextComponentSubstringPlayerName = AddTextComponentSubstringPlayerName
local BeginTextCommandSetBlipName = BeginTextCommandSetBlipName

local function StartBlips()
	for i,v in ipairs(Config.Blips) do
		local blip = AddBlipForCoord(v.coords[1], v.coords[2], v.coords[3])

		SetBlipSprite (blip, v.sprite)
		SetBlipDisplay(blip, v.display)
		SetBlipScale  (blip, v.scale)
		SetBlipColour (blip, v.color)
		SetBlipAsShortRange(blip, v.shortrange)
	
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(v.name)
		EndTextCommandSetBlipName(blip)
	end
end

CreateThread(StartBlips)