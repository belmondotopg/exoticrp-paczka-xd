local function BanPlayer(reason)
    TriggerServerEvent(GetCurrentResourceName()..":BAN", reason)
end

local function checkCar(car)
    if not car then return end

    local carModel = GetEntityModel(car)
    if Config.CarsBL[carModel] and not ESX.IsPlayerAdminClient() then
        local carName = GetDisplayNameFromVehicleModel(carModel)
        DeleteEntity(car)
        BanPlayer("Blacklistowany pojazd - " .. carName)
    end
end

for _, event in ipairs(Config.ClientEventsBlacklist) do
    RegisterNetEvent(event)
    AddEventHandler(event, function()
        BanPlayer(("Użyto zakazany event: %s"):format(event))
    end)
end

RegisterNetEvent("esx:getSharedObject")
AddEventHandler("esx:getSharedObject", function()
    BanPlayer("Próba załadowania menu z ESX object - " .. (GetInvokingResource() or "unknown"))
end)

Citizen.CreateThread(function()
    local CHECK_INTERVAL = 5000
    local IDLE_WAIT = 1000

    while true do
        Wait(CHECK_INTERVAL)

        if not ESX.IsPlayerLoaded() then
            Citizen.Wait(IDLE_WAIT)
            goto continue
        end

        local ped = cache.ped
        local vehicle = cache.vehicle

        if not ped or not DoesEntityExist(ped) then
            goto continue
        end

        if vehicle and vehicle > 0 and DoesEntityExist(vehicle) then
            checkCar(vehicle)
        end

        ::continue::
    end
end)

AddEventHandler('onClientResourceStop', function(res)
	if res == "Sorry redENGINE" or res == "Master Dream" or res == "_cfx_internal" then
		BanPlayer("Wykryto Executor: CDream etc. ("..res..")")
    end
end)

AddEventHandler('onClientResourceStart', function(res)
	if res == "Sorry redENGINE" or res == "Master Dream" or res == "_cfx_internal" then
		BanPlayer("Wykryto Executor: CDream etc. ("..res..")")
    end
end)

RegisterNetEvent(GetCurrentResourceName().. ".verify")
AddEventHandler(GetCurrentResourceName().. ".verify", function()
	local skrypt = GetInvokingResource()

	if not skrypt then 
		skrypt = GetCurrentResourceName()
	end
	
	BanPlayer("Wykryto Menu: Lux Menu ("..skrypt..")")
end)

RegisterNetEvent(GetCurrentResourceName().. ".getEvents")
AddEventHandler(GetCurrentResourceName().. ".getEvents", function()
	local skrypt = GetInvokingResource()

	if not skrypt then 
		skrypt = GetCurrentResourceName()
	end

	BanPlayer("Wykryto Menu: Lux Menu ("..skrypt..")")
end)

RegisterNetEvent(GetCurrentResourceName().. ".getServerEvents")
AddEventHandler(GetCurrentResourceName().. ".getServerEvents", function()
	local skrypt = GetInvokingResource()

	if not skrypt then 
		skrypt = GetCurrentResourceName()
	end

	BanPlayer("Wykryto Menu: Lux Menu ("..skrypt..")")
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function()
	local re = GetInvokingResource()

	if re then
		BanPlayer("Próba nadania joba po client-side XD ("..re..")")
	end
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function()
	local re = GetInvokingResource()
	
	if re then
		BanPlayer("Próba nadania joba2 po client-side XD ("..re..")")
	end
end)

AddStateBagChangeHandler(nil, nil, function(bagName, key, value) 
	if #key >= 131072 then
		BanPlayer("Próba wyjebania serwera - State Bag Exploit")
	end
end)

lib.callback.register('ss:getImage', function()
    local p = promise.new()
    exports['screenshot-basic']:requestScreenshotUpload('', 'files[]', function(data)
        local resp = json.decode(data)
        if resp and resp.attachments and resp.attachments[1] then
            p:resolve(resp.attachments[1].url .. ".jpeg")
        else
            p:resolve(nil)
        end
    end)
    return Citizen.Await(p)
end)
