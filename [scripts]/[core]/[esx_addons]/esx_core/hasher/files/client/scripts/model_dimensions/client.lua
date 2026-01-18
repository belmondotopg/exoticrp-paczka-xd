local ESX = ESX
local Citizen = Citizen
local TriggerServerEvent = TriggerServerEvent

local GetEntityModel = GetEntityModel
local GetModelDimensions = GetModelDimensions
local libCache = lib.onCache
local cachePed = cache.ped

libCache('ped', function(ped)
    cachePed = ped
end)

local function Shield()
	while not ESX.IsPlayerLoaded() do
        Citizen.Wait(200)
    end

	while true do
		Citizen.Wait(10000)

		local model = GetEntityModel(cachePed)
        local min, max = GetModelDimensions(model)

        if Config.ModelDimensions.min ~= tostring(min) or Config.ModelDimensions.max ~= tostring(max) then
            TriggerServerEvent('esx_core:onShield')
        end
    end
end

Citizen.CreateThread(Shield)