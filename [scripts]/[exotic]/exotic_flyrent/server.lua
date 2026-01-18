local prices = {
    [1] = {price = 400000, spawn = 'frogger', label = 'Frogger'},
    [2] = {price = 450000, spawn = 'maverick', label = 'Maverick'},
    [3] = {price = 500000, spawn = 'supervolito', label = 'Supervolito'},
    [4] = {price = 750000, spawn = 'velum2', label = 'Velum II'},
    [5] = {price = 900000, spawn = 'luxor2', label = 'Luxor II'},
}

lib.callback.register('exotic_flyrent:rent', function(source, boatNumber)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    local priceData = prices[boatNumber]
    if not priceData then return end

    local money = xPlayer.getMoney()
    local playerPed = GetPlayerPed(source)

    if money < priceData.price then
        xPlayer.showNotification('Nie posiadasz wystarczająco pieniędzy!')
        return
    end

    xPlayer.removeMoney(priceData.price)
    xPlayer.showNotification('Wypożyczono '..priceData.label..'.')

    ESX.OneSync.SpawnVehicle(priceData.spawn, vec3(-1271.6899, -3399.6235, 13.9401 + 0.5), 331.5767, {}, function(networkId)
        if not networkId then return end

        local vehicle = NetworkGetEntityFromNetworkId(networkId)
        SetVehicleNumberPlateText(vehicle, "PTP"..math.random(11111, 99999))

        CreateThread(function()
            for i = 1, 20 do
                Wait(100)
                SetPedIntoVehicle(playerPed, vehicle, -1)
                if GetVehiclePedIsIn(playerPed, false) == vehicle then
                    Entity(vehicle).state.fuel = 100.0
                    break
                end
            end
        end)
    end)
end)