local libCache = lib.onCache
local cachePed = cache.ped
local cacheVehicle = cache.vehicle

libCache('ped', function(ped)
    cachePed = ped
end)

libCache('vehicle', function(vehicle)
    cacheVehicle = vehicle
end)

local DOUBLE_CLICK_TIMEOUT = 300

RegisterNetEvent('esx_core:tackle:receiveTackled', function(forwardVector)
    SetPedToRagdollWithFall(cachePed, 3000, 3000, 0, forwardVector.x, forwardVector.y, forwardVector.z, 10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    ESX.ShowNotification('Zostałeś obalony!')
end)

local function getTackledPlayerIds()
    local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(cachePed), 5)
    local playerIds = {}
    for _, player in ipairs(nearbyPlayers) do
        if IsEntityTouchingEntity(cachePed, player.ped) and not IsPedRagdoll(player.ped) then
            local playerIndex = NetworkGetPlayerIndexFromPed(player.ped)
            if playerIndex ~= -1 then
                table.insert(playerIds, GetPlayerServerId(playerIndex))
            end
        end
    end
    return playerIds
end

local lastSpace = 0
local spaceCount = 0

lib.addKeybind({
    name = 'tackle_player',
    description = 'Obalanie graczy (dwuklik spacji)',
    defaultKey = 'SPACE',
    onPressed = function()
        local currentTime = GetGameTimer()

        if currentTime - lastSpace < DOUBLE_CLICK_TIMEOUT then
            spaceCount = spaceCount + 1
        else
            spaceCount = 1
        end
        lastSpace = currentTime

        if spaceCount == 2 then
            spaceCount = 0

            if not IsPedSprinting(cachePed) or cacheVehicle then
                return
            end

            local forwardVector = GetEntityForwardVector(cachePed)
            SetPedToRagdollWithFall(cachePed, 1000, 1500, 0, forwardVector.x, forwardVector.y, forwardVector.z, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            if not IsPedRagdoll(cachePed) then
                return
            end

            local playerIds = getTackledPlayerIds()
            if #playerIds > 0 then
                TriggerServerEvent('esx_core:tackle:sendTackledPlayers', playerIds, forwardVector)
            end
        end
    end
})
