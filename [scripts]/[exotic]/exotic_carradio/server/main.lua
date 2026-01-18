local Radio = {}

RegisterNetEvent('piotreq_radiocar:server:OpenRadio', function()
    local _source = source
    local plyPed = GetPlayerPed(_source)
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    if not plyVeh or plyVeh == 0 then
        return Config.Notification(_source, Config.Translation[Config.Language]['not_in_veh'])
    end

    if not isOnSeat(plyPed, plyVeh) then
        return Config.Notification(_source, Config.Translation[Config.Language]['not_on_seat'])
    end

    local vehPlate = GetVehicleNumberPlateText(plyVeh)
    local songs = MySQL.query.await('SELECT * FROM piotreq_radio WHERE plate = ?', {vehPlate})
    TriggerClientEvent('piotreq_radiocar:client:OpenRadio', _source, {
        songs = songs,
        vehicle = Radio[vehPlate],
        plate = vehPlate
    })
end)

RegisterNetEvent('piotreq_radiocar:server:PlayMusic', function(data)
    local _source = source
    local plyPed = GetPlayerPed(_source)
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    if not plyVeh or plyVeh == 0 then
        return
    end

    local vehPlate = GetVehicleNumberPlateText(plyVeh)
    if Radio[vehPlate] then
        exports['xsound']:Destroy(-1, vehPlate)
    end
    
    local vehCoords = GetEntityCoords(plyVeh)
    exports['xsound']:PlayUrlPos(-1, vehPlate, data.url, data.volume or 0.5, vector3(vehCoords.x, vehCoords.y, vehCoords.z), false)
    exports['xsound']:Distance(-1, vehPlate, Config.Distance[data.model] or Config.DefaultDist)
    SetTimeout(3000, function()
        TriggerClientEvent("piotreq_radiocar:client:Dynamic", -1, {name = data.name})
    end)
    Radio[vehPlate] = {
        netid = NetworkGetNetworkIdFromEntity(plyVeh),
        volume = data.volume or 0.5,
        url = data.url,
        loop = false,
        position = vector3(vehCoords.x, vehCoords.y, vehCoords.z)
    }
    SetTimeout(1000, function()
        TriggerClientEvent('piotreq_radiocar:client:RadioTime', _source, {plate = vehPlate})
    end)
end)

RegisterNetEvent('piotreq_radiocar:server:StopMusic', function(data)
    local _source = source
    local plyPed = GetPlayerPed(_source)
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    if not plyVeh or plyVeh == 0 then
        return
    end

    local vehPlate = GetVehicleNumberPlateText(plyVeh)
    if Radio[vehPlate] then
        exports['xsound']:Destroy(-1, vehPlate)
        Radio[vehPlate] = nil
    end
end)

RegisterNetEvent('piotreq_radiocar:server:ToggleLoop', function(data)
    local _source = source
    local plyPed = GetPlayerPed(_source)
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    if not plyVeh or plyVeh == 0 then
        return
    end

    local vehPlate = GetVehicleNumberPlateText(plyVeh)
    if Radio[vehPlate] then
        TriggerClientEvent('piotreq_radiocar:client:LoopRadio', -1, {name = vehPlate, toggle = data.loop})
        Radio[vehPlate].loop = data.loop
    end
end)

RegisterNetEvent('piotreq_radiocar:server:ChangeVolume', function(data)
    local _source = source
    local plyPed = GetPlayerPed(_source)
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    if not plyVeh or plyVeh == 0 then
        return
    end

    local vehPlate = GetVehicleNumberPlateText(plyVeh)
    if Radio[vehPlate] then
        local volume = tonumber(data.volume) / 100
        exports['xsound']:setVolume(-1, vehPlate, volume)
        Radio[vehPlate].volume = volume
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        for plate, data in pairs(Radio) do
            sleep = Config.RefreshRate or 250
            local entity = NetworkGetEntityFromNetworkId(data.netid)
            if entity and DoesEntityExist(entity) then
                local newCoords = GetEntityCoords(entity)
                if data.position and #(newCoords - data.position) >= 10 then
                    exports['xsound']:Position(-1, plate, vector3(newCoords.x, newCoords.y, newCoords.z))
                end
            else
                exports['xsound']:Destroy(-1, plate)
                Radio[plate] = nil
            end
        end
        Citizen.Wait(sleep)
    end
end)

RegisterNetEvent('piotreq_radiocar:server:SaveMusic', function(data)
    local _source = source
    local plyPed = GetPlayerPed(_source)
    local plyVeh = GetVehiclePedIsIn(plyPed, false)
    if not plyVeh or plyVeh == 0 then
        return
    end

    local slot = tonumber(data.slot)
    local vehPlate = GetVehicleNumberPlateText(plyVeh)
    if slotOccupied(slot, vehPlate) then
        MySQL.update('UPDATE piotreq_radio SET url = ? WHERE slot = ? AND plate = ?', {data.url, slot, vehPlate})
    else
        MySQL.insert('INSERT INTO piotreq_radio (plate, url, slot) VALUES (?, ?, ?)', {vehPlate, data.url, slot})
    end
end)

function slotOccupied(slot, plate)
    local isOccupied = false
    local row = MySQL.single.await('SELECT * FROM piotreq_radio WHERE slot = ? AND plate = ?', {slot, plate})
    if row and row.url then
        isOccupied = true
    end

    return isOccupied
end

function isOnSeat(ped, vehicle)
    local onSeat = false
    for i = -1, 6, 1 do
        local seatPed = GetPedInVehicleSeat(vehicle, i)
        if seatPed == ped then
            if Config.Restrict then
                if Config.Restrict[tostring(i)] then
                    onSeat = true
                end
            else
                onSeat = true
            end
            break
        end
    end

    return onSeat
end