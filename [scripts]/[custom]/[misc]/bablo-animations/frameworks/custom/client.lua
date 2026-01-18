Framework = Framework or {};

CreateThread(function()
    local identifier

    if Config.Framework ~= 'standalone' then
        return
    end

    function Framework:getCharacterIdentifier()
        if not identifier then
            local callback = TriggerServerCallback({
                eventName = eventName .. 'server:getIdentifier',
                args = {}
            })

            if callback.status then
                identifier = callback.identifier
            else
                Trace('Failed to get identifier')

                identifier = nil
            end
        end

        return identifier
    end

    function Framework:Notify(message)
        SetNotificationTextEntry('STRING')
        AddTextComponentString(message)
        DrawNotification(false, true)
    end

    function Framework:isPlayerDead()
        local isDead = false

        if GetEntityHealth(PlayerPedId()) >= 1 then
            isDead = true
        end

        return isDead
    end

    function Framework:isCurrentJob(jobName)
        return false
    end

    function Framework:canOpenMenu()
        -- Add your custom logic here

        return true
    end

    function Framework:canPlayAnimation(animationName)
        -- Add your custom logic here
        return true
    end

    function Framework:onPlayAnimation(animationName)
        -- Add your custom logic here
    end

    function Framework:onCancelAnimation()
        -- Add your custom logic here
    end

    RegisterNetEvent('playerSpawned', function()
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
