Framework = Framework or {};

local libCache = lib.onCache
local cacheVehicle = cache.vehicle
libCache('vehicle', function(vehicle)
    cacheVehicle = vehicle
end)

CreateThread(function()
    if Config.Framework ~= 'esx' then
        return
    end

    function Framework:getCore()
        return exports['es_extended']:getSharedObject();
    end

    local ESX = Framework:getCore();

    function Framework:getCharacterIdentifier()
        return ESX.GetPlayerData().identifier
    end

    function Framework:Notify(message)
        ESX.ShowNotification(message)
    end

    function Framework:isPlayerDead()
        local isDead = false

        if GetEntityHealth(PlayerPedId()) >= 1 then
            isDead = true
        end

        return isDead
    end

    function Framework:isCurrentJob(jobName)
        local isJob = false
        local playerData = ESX.GetPlayerData()

        if playerData and playerData.job.name == jobName then
            isJob = true
        end

        return isJob
    end

    function Framework:canOpenMenu()
        if LocalPlayer.state.IsDead then
            return false
        end

        if LocalPlayer.state.IsHandcuffed then
            return false
        end

        if LocalPlayer.state.Crosshair then
            return false
        end

        if cacheVehicle then
            return false
        end

        return true
    end

    function Framework:canPlayAnimation(animationName)
        if LocalPlayer.state.IsDead then
            return false
        end

        if LocalPlayer.state.IsHandcuffed then
            return false
        end

        if LocalPlayer.state.Crosshair then
            return false
        end

        if cacheVehicle then
            return false
        end

        return true
    end

    function Framework:onPlayAnimation(animationName)
        -- Add your custom logic here
    end

    function Framework:onCancelAnimation()
        -- Add your custom logic here
    end

    RegisterNetEvent('esx:playerLoaded', function()
        Citizen.Wait(1000)

        local animationData, isNew = Main:getCache()

        if not isNew then
            Main:playAnimation(cache.ped, animationData.walkingstyle or nil, false, true)
            Main:playAnimation(cache.ped, animationData.expression or nil, false, true)
            Main:playAnimation(cache.ped, animationData.weaponstyle or nil, false, true)
        end

        TriggerServerEvent(eventName .. "server:playerLoaded")
    end)
end)
