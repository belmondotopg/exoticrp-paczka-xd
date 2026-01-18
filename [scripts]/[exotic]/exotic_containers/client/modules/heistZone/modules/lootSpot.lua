local lootSpots = {}

local function searchSpot(spotIndex)
    if not lib.callback.await('exotic-containers:startSearchingSpot', 0, spotIndex) then
        return ESX.ShowNotification('To miejsce zostało już przeszukane lub kontener nie jest otwarty.')
    end

    if exports.esx_hud:progressBar({
            duration = 15,
            label = 'Przeszukujesz...',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
            },
            anim = {
                dict = 'anim@gangops@facility@servers@bodysearch@',
                clip = 'player_search',
            },
        }) then
        TriggerServerEvent('exotic-containers:searchSpot', spotIndex)
    else
        ESX.ShowNotification('Przestałeś przeszukiwać.')
    end
end

return {
    add = function(spotIndex, spot)
        local targetRef = exports.ox_target

        if spot.object and DoesEntityExist(spot.object) then
            spot.targetId = targetRef:addLocalEntity(spot.object, {
                {
                    name = 'exotic-containers:lootSpot',
                    event = 'exotic-containers:lootSpot',
                    icon = 'fa-solid fa-box-open',
                    label = 'Przeszukaj',
                    onSelect = function()
                        searchSpot(spotIndex)
                    end
                }
            }
            )
        elseif spot.coords then
            spot.targetId = targetRef:addSphereZone({
                name = 'exotic-containers:lootSpot',
                coords = spot.coords,
                size = vec3(0.5, 0.5, 0.5),
                rotation = 0,
                options = {
                    {
                        icon = 'fa-solid fa-box-open',
                        label = 'Przeszukaj',
                        onSelect = function()
                            searchSpot(spotIndex)
                        end
                    }
                }
            })
        end

        lootSpots[spotIndex] = spot
    end,
    remove = function(index)
        local spot = lootSpots[index]
        if spot then
            local targetRef = exports.ox_target
            if spot.targetId then
                targetRef:removeZone(spot.targetId)
            end

            if spot.object and DoesEntityExist(spot.object) then
                DeleteEntity(spot.object)
            end

            lootSpots[index] = nil
            lib.print.info('Removed loot spot: ' .. index)
        end
    end,
    clearAll = function()
        local targetRef = exports.ox_target
        for spotIndex, spot in pairs(lootSpots) do
            if spot.targetId then
                targetRef:removeZone(spot.targetId)
            end

            if spot.object and DoesEntityExist(spot.object) then
                DeleteEntity(spot.object)
            end

            lootSpots[spotIndex] = nil
            lib.print.info('Removed loot spot: ' .. spotIndex)
        end
    end
}
