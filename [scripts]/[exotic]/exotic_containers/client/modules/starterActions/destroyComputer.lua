--- @param data TargetData
--- @return boolean Success
return function(data)
    local zoneIndex = data.zoneIndex

    if data.weapon then
        local count = exports.ox_inventory:Search('count', data.weapon)
        if count < 1 then 
            ESX.ShowNotification('Potrzebujesz łom.')
            return false 
        end

        if data.equipped and cache.weapon ~= joaat(data.weapon) then
            ESX.ShowNotification('Musisz mieć wyciągnięty łom')
            return false
        end
    end

    local deskEntity = data.entity
    local ped = cache.ped
    local animDict = 'missheist_jewel'
    local animName = 'smash_case'

    lib.requestAnimDict(animDict)

    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 49, 0, false, false, false)

    local duration = GetAnimDuration(animDict, animName) * 1000

    Wait(math.floor(duration))

    ClearPedTasks(ped)

    TriggerServerEvent('exotic-containers:startHeist', 'destroyComputer', zoneIndex, nil)

    return true
end
