local ESX = ESX
local RegisterNetEvent = RegisterNetEvent
local TriggerEvent = TriggerEvent

RegisterNetEvent('esx_core:putOnClothes', function(job)
	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			if Config.ItemsUniforms[job].male ~= nil then
				TriggerEvent('skinchanger:loadClothes', skin, Config.ItemsUniforms[job].male)
			else
				ESX.ShowNotification("Brak ubrania")
			end
		else
			if Config.ItemsUniforms[job].female ~= nil then
				TriggerEvent('skinchanger:loadClothes', skin, Config.ItemsUniforms[job].female)
			else
				ESX.ShowNotification("Brak ubrania")
			end
		end
	end)
end)