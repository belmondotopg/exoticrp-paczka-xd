local playersOnTestDrive = {}
local nextBucketId = 1000
local TIMEOUT_CHECK_INTERVAL = 60000
local MAX_TESTDRIVE_TIME_MULTIPLIER = 2

local function cleanupTestDrive(source)
    if playersOnTestDrive[source] then
        SetPlayerRoutingBucket(source, 0)
        playersOnTestDrive[source] = nil
    end
end

ESX.RegisterServerCallback('qf_carMarket:startTestDrive', function(source, cb, vehicleId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        cb(false, nil)
        return 
    end
    
    if playersOnTestDrive[source] then
        xPlayer.showNotification("~r~Jesteś już na jeździe testowej!")
        cb(false, nil)
        return
    end
    
    local bucketId = nextBucketId
    nextBucketId = nextBucketId + 1
    
    SetPlayerRoutingBucket(source, bucketId)
    playersOnTestDrive[source] = {
        vehicleId = vehicleId,
        bucketId = bucketId,
        startTime = os.time()
    }
    
    cb(true, bucketId)
end)

RegisterNetEvent('qf_carMarket:endTestDrive')
AddEventHandler('qf_carMarket:endTestDrive', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    cleanupTestDrive(src)
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    cleanupTestDrive(src)
end)

CreateThread(function()
    while true do
        Wait(TIMEOUT_CHECK_INTERVAL)
        
        local currentTime = os.time()
        for source, data in pairs(playersOnTestDrive) do
            local elapsed = currentTime - data.startTime
            
            if elapsed > (Config.TestDrive.Duration * MAX_TESTDRIVE_TIME_MULTIPLIER) then
                local xPlayer = ESX.GetPlayerFromId(source)
                if xPlayer then
                    xPlayer.showNotification("~r~Jazda testowa została przerwana (timeout)")
                    TriggerClientEvent('qf_carMarket:forceEndTestDrive', source)
                end
                
                cleanupTestDrive(source)
            end
        end
    end
end)

RegisterNetEvent('qf_carMarket:forceEndTestDrive')
AddEventHandler('qf_carMarket:forceEndTestDrive', function()
    local src = source
    cleanupTestDrive(src)
end)
