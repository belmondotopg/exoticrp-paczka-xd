local libCache = lib.onCache
local cacheVehicle = cache.vehicle

libCache('vehicle', function(vehicle)
    cacheVehicle = vehicle
end)

CreateThread(function()
    while true do
        local waitTime = 1000

        if cacheVehicle then
            local speed = GetEntitySpeed(cacheVehicle) * 3.6
            if speed > 320 then
                SetEntityMaxSpeed(cacheVehicle, 320 / 3.6)
                waitTime = 0
            end
        end

        Wait(waitTime)
    end
end)