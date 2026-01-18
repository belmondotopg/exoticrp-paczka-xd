local esx_hud = exports.esx_hud
local ox_target = exports.ox_target

local ROBBERY_COOLDOWN = 30000
local STAND_STILL_DURATION = 12000
local FLEE_DURATION = 10000
local FLEE_DISTANCE = 100.0
local PROGRESS_DURATION = 8
local INTERACTION_DISTANCE = 2.0

local robbedRecently = false
local robbedPeds = {}

local cachePed = cache.ped
local cacheCoords = cache.coords

lib.onCache('ped', function(ped)
    cachePed = ped
end)

lib.onCache('coords', function(coords)
    cacheCoords = coords
end)

local function cleanupPedState(targetPed)
    FreezeEntityPosition(targetPed, false)
    FreezeEntityPosition(cachePed, false)
    ClearPedTasks(cachePed)
    ClearPedTasks(targetPed)
    TaskSmartFleePed(targetPed, cachePed, FLEE_DISTANCE, FLEE_DURATION, false, false)
end

local function sendDispatchAlert()
    TriggerServerEvent('qf_mdt:addDispatchAlertSV', cacheCoords, 'Okradnięto obywatela!', 
        'Zgłoszono rabunek na obywatelu w podanej lokalizacji!', '10-71', 
        'rgb(49, 145, 105)', '10', 480, 3, 6)
end

local function RobNPC(targetPed)
    robbedRecently = true

    if robbedPeds[targetPed] then
        ox_target:removeEntity(targetPed, 'esx_core:onRobPed')
    end

    Citizen.CreateThread(function()
        lib.requestAnimDict('random@mugging3')
        lib.requestAnimDict('random@countryside_gang_fight')
        lib.requestAnimDict('anim@gangops@facility@servers@bodysearch@')

        TaskStandStill(targetPed, STAND_STILL_DURATION)
        FreezeEntityPosition(targetPed, true)
        FreezeEntityPosition(cachePed, true)
        TaskPlayAnim(targetPed, 'random@mugging3', 'handsup_standing_base', 8.0, 1.0, -1, 49, 0.0, 0, 0, 0)
        TaskPlayAnim(cachePed, 'random@countryside_gang_fight', 'biker_02_stickup_loop', 8.0, 1.0, -1, 49, 0.0, 0, 0, 0)
        ESX.ShowNotification('Rozpoczęto okradanie lokalnego!')

        robbedPeds[targetPed] = true

        local progressCompleted = esx_hud:progressBar({
            duration = PROGRESS_DURATION,
            label = 'Okradanie',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
                mouse = false,
            },
            anim = {
                dict = 'anim@gangops@facility@servers@bodysearch@',
                clip = 'player_search'
            },
            prop = {},
        })

        if progressCompleted then
            local success = lib.skillCheck({'easy', 'medium', 'medium'})
            sendDispatchAlert()

            if not success then
                ESX.ShowNotification('Nie udało ci się, zwiewaj!')
                cleanupPedState(targetPed)
            else
                Citizen.Wait(1000)
                TriggerServerEvent("esx_core_robnpc:giveReward", ESX.GetClientKey(LocalPlayer.state.playerIndex))
                cleanupPedState(targetPed)
            end
        else
            ESX.ShowNotification('Anulowano.')
            cleanupPedState(targetPed)
        end

        Citizen.Wait(ROBBERY_COOLDOWN)
        ESX.ShowNotification('Możesz okradać lokalnych ponownie!')
        robbedRecently = false
    end)
end

local options = {
    {
        name = 'esx_core:onRobPed',
        icon = 'fas fa-wallet',
        label = 'Obrabuj obywatela',
        canInteract = function(entity, distance, coords, name, bone)
            if IsEntityDead(entity) then
                return false
            end

            if robbedRecently then
                return false
            end

            if distance >= INTERACTION_DISTANCE then
                return false
            end

            if robbedPeds[entity] then
                return false
            end

            if IsEntityPositionFrozen(entity) then
                return false
            end

            local entityModel = GetEntityModel(entity)
            for _, blacklistedModel in ipairs(Config.PedsBlacklist) do
                if entityModel == blacklistedModel then
                    return false
                end
            end

            local playerState = LocalPlayer.state
            if playerState.IsDead or playerState.InCasino or playerState.IsHandcuffed then
                return false
            end

            if playerState.ProtectionTime and playerState.ProtectionTime > 0 then
                return false
            end

            if playerState.InSafeZone then
                return false
            end

            return IsPedArmed(cachePed, 1) or IsPedArmed(cachePed, 4)
        end,
        onSelect = function(entity)
            if GlobalState.Counter['police'] < Config.RequiredCops.rob_npc then
                ESX.ShowNotification('Minimalnie musi być ' .. Config.RequiredCops.rob_npc .. ' policjantów, aby okraść lokalnego')
                return
            end

            local entityHandle = entity.entity
            local dist = #(cacheCoords - GetEntityCoords(entityHandle))

            if not DoesEntityExist(entityHandle) then
                return
            end

            if not IsEntityAPed(entityHandle) then
                return
            end

            if IsPedInAnyVehicle(entityHandle, false) then
                return
            end

            if dist >= INTERACTION_DISTANCE then
                return
            end

            if robbedRecently then
                ESX.ShowNotification('Okradłeś ostatnio lokalnego, odczekaj chwile!')
                return
            end

            if IsPedDeadOrDying(entityHandle, true) then
                ESX.ShowNotification('Twój cel jest nieprzytomny')
                ox_target:removeEntity(entityHandle, 'esx_core:onRobPed')
                return
            end

            RobNPC(entityHandle)
            ox_target:removeEntity(entityHandle, 'esx_core:onRobPed')
        end,
        distance = INTERACTION_DISTANCE
    },
}

ox_target:addGlobalPed(options)