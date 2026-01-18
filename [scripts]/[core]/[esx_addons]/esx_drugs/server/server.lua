local TriggerClientEvent = TriggerClientEvent
local RegisterServerEvent = RegisterServerEvent
local AddEventHandler = AddEventHandler
local ESX = ESX

local PlayersHarvesting		   = {}
local esx_core = exports.esx_core

RegisterServerEvent('esx_drugs:onStopDrugs')
AddEventHandler('esx_drugs:onStopDrugs', function()
	local src = source
	PlayersHarvesting[src] = nil
end)

RegisterServerEvent(GetCurrentResourceName() .. ':onCollectingDrugs')
AddEventHandler(GetCurrentResourceName() .. ':onCollectingDrugs', function(name)
    local src = source
    
    if Player(src).state.ProtectionTime and Player(src).state.ProtectionTime > 0 then
        TriggerClientEvent('esx:showNotification', src, 'Nie możesz zbierać narkotyków będąc na antytrollu!')
        return
    end
    
    PlayersHarvesting[src] = true
	
	if Player(src).state.onCollectingDrugs then
		if name == "meth" or name == "cocaine" or name == "weed" or name == "opium" or name == "heroina" then 
			if PlayersHarvesting[src] == true then
				local xPlayer  = ESX.GetPlayerFromId(src)
				local item = xPlayer.getInventoryItem(name)
				if item ~= nil then
					if item.limit ~= -1 and item.count >= 141 then
						TriggerClientEvent('esx:showNotification', src, 'Nie możesz już zbierać, Twój ekwipunek jest pełen')
					else
						PlayersHarvesting[src] = nil
		
						esx_core:SendLog(src, "Zbieranie narkotyków", "Zebrał narkotyk: " .. name .. " x10", 'drugs-collecting')
						exports["esx_hud"]:UpdateTaskProgress(src, "DrugsCollect")
						xPlayer.addInventoryItem(name, 10)
					end
				else
					PlayersHarvesting[src] = nil
				end
			else
				return
			end
		end
	end
end)

RegisterServerEvent(GetCurrentResourceName() .. ':onProcessDrugs')
AddEventHandler(GetCurrentResourceName() .. ':onProcessDrugs', function(name, name2)
	local src = source
	
	-- Sprawdź czy gracz jest na antytrollu
	if Player(src).state.ProtectionTime and Player(src).state.ProtectionTime > 0 then
		TriggerClientEvent('esx:showNotification', src, 'Nie możesz przetwarzać narkotyków będąc na antytrollu!')
		return
	end
	
	local xPlayer = ESX.GetPlayerFromId(src)

	if Player(src).state.onTransferringDrugs then
		if name == "meth" or name == "cocaine" or name == "weed" or name == "opium" or name == "heroina" then 
			if PlayersHarvesting[src] == nil then
				PlayersHarvesting[src] = true
				local pooch = xPlayer.getInventoryItem(name2..'_packaged')
				local itemQuantity = xPlayer.getInventoryItem(name).count
				local poochQuantity = xPlayer.getInventoryItem(name2..'_packaged').count
				
				if pooch ~= nil and itemQuantity ~= nil and poochQuantity ~= nil then
					if itemQuantity < 5 then
						TriggerClientEvent('esx:showNotification', src, 'Nie masz wystarczająco narkotyku, aby go przetworzyć')
						
						PlayersHarvesting[src] = nil
					else
						if name == "meth" then
							xPlayer.removeInventoryItem(name, 30)
							xPlayer.addInventoryItem(name2 .. '_packaged', 1)
							esx_core:SendLog(src, "Przetwarzanie narkotyków", "Przetworzył narkotyk: " .. name2 .. "_packaged x1", 'drugs-packing')
						else
							xPlayer.removeInventoryItem(name, 5)
							xPlayer.addInventoryItem(name2 .. '_packaged', 1)
							esx_core:SendLog(src, "Przetwarzanie narkotyków", "Przetworzył narkotyk: " .. name2 .. "_packaged x1", 'drugs-packing')
						end

						exports["esx_hud"]:UpdateTaskProgress(src, "DrugsCollect")
						PlayersHarvesting[src] = nil
					end
				end
			end
		end
	end
end)

local NarcoZones = {
	vec3(1390.75, 3605.2, 39.0),
    vec3(2435.75, 4964.15, 42.3),
    vec3(1344.0, 4386.5, 44.5),
    vec3(-475.25, 6286.1, 13.6),
	vec3(-35.3, -2686.0, 6.0),
	vec3(1076.0, -2319.25, 30.25),
}

local function IsInZone(src)
	for i=1, #NarcoZones, 1 do
		if #(NarcoZones[i] - GetEntityCoords(GetPlayerPed(src))) <= 50.0 then
			return true
		end
	end

	return false
end

