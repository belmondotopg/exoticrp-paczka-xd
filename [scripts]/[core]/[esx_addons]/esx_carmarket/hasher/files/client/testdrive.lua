local isOnTestDrive = false
local testDriveVehicle = nil
local testDriveTimer = nil
local originalCoords = nil
local testDriveCooldowns = {}

local function getVehicleDisplayName(model)
    if type(model) == "string" and tonumber(model) then
        model = tonumber(model)
    end
    
    if type(model) == "number" then
        return GetDisplayNameFromVehicleModel(model) or "Nieznany"
    else
        return model or "Nieznany"
    end
end

local function getServerTime()
    local cloudTime = GetCloudTimeAsInt()
    if cloudTime > 0 then
        return cloudTime
    end
    return GetGameTimer() / 1000
end

local function canTestDrive(plate)
    if not testDriveCooldowns[plate] then
        return true
    end
    
    local currentTime = getServerTime()
    local timeLeft = testDriveCooldowns[plate] - currentTime
    if timeLeft <= 0 then
        testDriveCooldowns[plate] = nil
        return true
    end
    
    local minutes = math.ceil(timeLeft / 60)
    ESX.ShowNotification("~r~Musisz poczekać ~w~" .. minutes .. " minut~r~ przed kolejną jazdą testową tego pojazdu")
    return false
end

local function startTestDrive(vehicleData)
    if isOnTestDrive then
        ESX.ShowNotification("~r~Jesteś już na jeździe testowej!")
        return
    end
    
    if not canTestDrive(vehicleData.plate) then
        return
    end
    
    originalCoords = GetEntityCoords(PlayerPedId())
    
    ESX.TriggerServerCallback('qf_carMarket:startTestDrive', function(success, bucketId)
        if not success then
            ESX.ShowNotification("~r~Nie udało się rozpocząć jazdy testowej")
            return
        end
        
        isOnTestDrive = true
        
        DoScreenFadeOut(500)
        Wait(500)
        
        local spawnLoc = Config.TestDrive.SpawnLocation
        SetEntityCoords(PlayerPedId(), spawnLoc.x, spawnLoc.y, spawnLoc.z, false, false, false, false)
        
        Wait(500)
        local model
        if type(vehicleData.model) == "number" then
            model = vehicleData.model
        elseif type(vehicleData.model) == "string" and tonumber(vehicleData.model) then
            model = tonumber(vehicleData.model)
        else
            model = GetHashKey(vehicleData.model)
        end
        
        RequestModel(model)
        local timeout = 5000
        while not HasModelLoaded(model) and timeout > 0 do
            Wait(50)
            timeout = timeout - 50
        end
        
        if not HasModelLoaded(model) then
            ESX.ShowNotification("~r~Nie udało się załadować pojazdu: " .. getVehicleDisplayName(vehicleData.model))
            endTestDrive(true)
            return
        end
        
        testDriveVehicle = CreateVehicle(model, spawnLoc.x, spawnLoc.y, spawnLoc.z, spawnLoc.w, true, false)
        
        if not testDriveVehicle or testDriveVehicle == 0 then
            ESX.ShowNotification("~r~Nie udało się utworzyć pojazdu")
            SetModelAsNoLongerNeeded(model)
            endTestDrive(true)
            return
        end
        
        SetModelAsNoLongerNeeded(model)
        
        local props = vehicleData.props
        if type(props) == "string" then
            props = json.decode(props)
        end
        
        if props and type(props) == "table" then
            ESX.Game.SetVehicleProperties(testDriveVehicle, props)
        end
        
        SetVehicleNumberPlateText(testDriveVehicle, "TEST")
        SetPedIntoVehicle(PlayerPedId(), testDriveVehicle, -1)
        
        DoScreenFadeIn(500)
        
        ESX.ShowNotification("~g~Jazda testowa rozpoczęta! ~w~Masz " .. (Config.TestDrive.Duration / 60) .. " minuty")
        
        SendNUIMessage({
            action = "setTestDriveVisible",
            data = true
        })
        local remainingTime = Config.TestDrive.Duration
        testDriveTimer = CreateThread(function()
            while isOnTestDrive and remainingTime > 0 do
                Wait(1000)
                remainingTime = remainingTime - 1
                
                SendNUIMessage({
                    action = "updateTestDriveTime",
                    data = {
                        remainingTime = remainingTime
                    }
                })
                
                if not IsPedInVehicle(PlayerPedId(), testDriveVehicle, false) then
                    ESX.ShowNotification("~r~Jazda testowa przerwana - wyszedłeś z pojazdu")
                    endTestDrive(false)
                    break
                end
                
                if IsEntityDead(PlayerPedId()) then
                    ESX.ShowNotification("~r~Jazda testowa przerwana - zginąłeś")
                    endTestDrive(false)
                    break
                end
            end
            
            if remainingTime <= 0 and isOnTestDrive then
                ESX.ShowNotification("~y~Czas jazdy testowej upłynął!")
                endTestDrive(false)
            end
        end)
        
        testDriveCooldowns[vehicleData.plate] = getServerTime() + Config.TestDrive.Cooldown
    end, vehicleData.id)
end

function endTestDrive(force)
    if not isOnTestDrive then return end
    
    isOnTestDrive = false
    
    if testDriveTimer then
        testDriveTimer = nil
    end
    
    SendNUIMessage({
        action = "setTestDriveVisible",
        data = false
    })
    
    if testDriveVehicle and DoesEntityExist(testDriveVehicle) then
        SetEntityAsMissionEntity(testDriveVehicle, false, true)
        DeleteEntity(testDriveVehicle)
        testDriveVehicle = nil
    end
    
    DoScreenFadeOut(500)
    Wait(500)
    
    local returnLoc = Config.TestDrive.ReturnLocation
    SetEntityCoords(PlayerPedId(), returnLoc.x, returnLoc.y, returnLoc.z, false, false, false, false)
    
    pcall(function()
        TriggerServerEvent('qf_carMarket:endTestDrive')
    end)
    
    Wait(500)
    DoScreenFadeIn(500)
    
    if not force then
        ESX.ShowNotification("~g~Jazda testowa zakończona!")
    end
end

exports('startTestDrive', startTestDrive)
exports('endTestDrive', endTestDrive)

AddEventHandler('gameEventTriggered', function(event, data)
    if event == 'CEventNetworkEntityDamage' then
        local victim = data[1]
        if victim == PlayerPedId() and IsEntityDead(victim) and isOnTestDrive then
            endTestDrive(false)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if isOnTestDrive then
        endTestDrive(true)
    end
end)

RegisterNetEvent('qf_carMarket:forceEndTestDrive')
AddEventHandler('qf_carMarket:forceEndTestDrive', function()
    if isOnTestDrive then
        endTestDrive(true)
    end
end)

