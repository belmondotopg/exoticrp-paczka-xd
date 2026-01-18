CreateThread(function()
    print("^2[SPEED LIMITER]^7 Client loaded")

    while true do
        Wait(Config.CheckInterval)

        local ped = PlayerPedId()
        if not IsPedInAnyVehicle(ped, false) then
            goto continue
        end

        local vehicle = GetVehiclePedIsIn(ped, false)
        if GetPedInVehicleSeat(vehicle, -1) ~= ped then
            goto continue
        end

        local modelHash = GetEntityModel(vehicle)
        local limitKmh = nil

        for spawnName, maxKmh in pairs(Config.SpeedLimits) do
            if modelHash == GetHashKey(spawnName) then
                limitKmh = maxKmh
                break
            end
        end

        if limitKmh then
            local maxSpeed = limitKmh / 3.6
            
            SetVehicleMaxSpeed(vehicle, maxSpeed)
            SetEntityMaxSpeed(vehicle, maxSpeed)
        end

        ::continue::
    end
end)

RegisterCommand("hashcar", function()
    local ped = PlayerPedId()

    if not IsPedInAnyVehicle(ped, false) then
        print("^1[HASHCAR]^7 Nie jesteś w pojeździe")
        return
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    local modelHash = GetEntityModel(vehicle)
    local displayName = GetDisplayNameFromVehicleModel(modelHash)

    print("========== HASHCAR DEBUG ==========")
    print("Vehicle entity:", vehicle)
    print("Model hash:", modelHash)
    print("Display name:", displayName)
    print("Config entry:")
    print(string.format('["%s"] = 150,', string.lower(displayName)))
    print("==================================")
end, false)
