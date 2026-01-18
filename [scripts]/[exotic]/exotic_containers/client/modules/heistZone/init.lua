local Config = require('config.main')
local HeistConfig = Config.Heist
local Scenes = require('client.modules.syncedScene')

local Container = require('client.modules.heistZone.modules.container')

---@type CPoint?
local heistPoint
local heistBlip
local detailedHeistBlip
local centerredHeistBlip
local lockTargetAdded = false

local spawnedLootspots = {}

local function removeTargetFromLock()
    if not lockTargetAdded then return end
    exports.ox_target:removeZone('openContainerTarget')
    lockTargetAdded = false
end

local function addTargetToLock()
    if lockTargetAdded then return end

    local objects = Container.getObjects()
    local lockEntity = objects.lock

    if not lockEntity or not DoesEntityExist(lockEntity) then
        print('No lock target to add - container might be opened')
        return
    end

    local lockNetId = NetworkGetNetworkIdFromEntity(lockEntity)
    if not NetworkDoesNetworkIdExist(lockNetId) then
        return
    end

    exports.ox_target:addSphereZone({
        coords = GetEntityCoords(objects.lock),
        radius = 0.3,
        name = 'openContainerTarget',
        options = {
            {
                icon = 'fas fa-lock',
                label = 'Otwórz kontener',
                onSelect = function(data)
                    if not lib.callback.await('exotic-containers:canOpenContainer') then return end

                    local minigameType = HeistConfig.openContainerMinigame or 'Balance'
                    local success = exports['lc-minigames']:StartMinigame(minigameType)
                    Wait(700)
                    if success then
                        SetEntityDrawOutline(objects.container, false)
                        local animDict = 'anim@scripted@player@mission@tunf_train_ig1_container_p1@male@'
                        lib.requestAnimDict(animDict)

                        local coords = GetEntityCoords(objects.container)
                        Scenes.playAndWait(
                            cache.ped,
                            {
                                { entity = objects.container,        anim = 'action_container' },
                                { model = 'hei_p_m_bag_var22_arm_s', anim = 'action_bag' },
                                { entity = objects.lock,             anim = 'action_lock' },
                                { model = 'tr_prop_tr_grinder_01a',  anim = 'action_angle_grinder' }
                            },
                            animDict, 'action', nil, coords,
                            vec3(0.0, 0.0, 0.0)
                        )
                        TriggerServerEvent('exotic-containers:openContainer')
                    end
                end,
                distance = 3
            }
        },
    })
    lockTargetAdded = true
end

local LootSpots = require('client.modules.heistZone.modules.lootSpot')

local function syncLootspots()
    local animationObjects = Container.getAnimationObjects()
    local baseEntity = animationObjects.localContainer

    if not baseEntity or not DoesEntityExist(baseEntity) then
        lib.print.warn("localContainer does not exist for loot spawning")
        return
    end

    local searchedSpots = lib.callback.await('exotic-containers:getSearchedSpots')

    for spotIndex, item in ipairs(HeistConfig.lootSpots) do
        if not searchedSpots[spotIndex] then
            local spawnCoords = GetOffsetFromEntityInWorldCoords(
                baseEntity,
                item.offset.x,
                item.offset.y,
                item.offset.z
            )

            lib.requestModel(item.model)
            local object = CreateObject(item.model, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, true, false)

            if object and DoesEntityExist(object) then
                FreezeEntityPosition(object, true)

                local lootData = {
                    object = object,
                    coords = spawnCoords
                }

                LootSpots.add(spotIndex, lootData)
            end

            SetModelAsNoLongerNeeded(item.model)
        end
    end
end

local function removeCurrent()
    if heistPoint then
        heistPoint:remove()
        heistPoint = nil
    end

    if heistBlip then
        if DoesBlipExist(heistBlip) then
            RemoveBlip(heistBlip)
        end
        heistBlip = nil
    end

    if detailedHeistBlip then
        if DoesBlipExist(detailedHeistBlip) then
            RemoveBlip(detailedHeistBlip)
        end
        detailedHeistBlip = nil
    end

    if centerredHeistBlip then
        if DoesBlipExist(centerredHeistBlip) then
            RemoveBlip(centerredHeistBlip)
        end
        centerredHeistBlip = nil
    end

    Container.cleanup()
    LootSpots.clearAll()
end

return {
    ---@param coords vector4
    ---@param startedBy number
    setup = function(coords, startedBy, searchedSpots)
        ESX.ValidateType(coords, 'vector4')

        local crimeNotify = HeistConfig.crimeNotify
        assert(crimeNotify, "'HeistConfig.crimeNotify' does not exist but is required to exist.")

        removeCurrent()

        local isInitiator = startedBy and
        startedBy ==
        ESX.GetPlayerData()?.identifier                                                -- replace with LocalPlayer.state.identifier if exists - better performance.
        
        -- Powiadomienie dla wszystkich graczy (oprócz inicjatora, który już dostał powiadomienie)
        if crimeNotify.notification and not isInitiator then 
            ESX.ShowNotification(crimeNotify.notification) 
        end
        
        local radius = 150.0
        local blipConfig = crimeNotify.blip
        local radiusBlipCoords

        if blipConfig then
            radius = math.random(blipConfig.radius.min, blipConfig.radius.max)
            local minOffset, maxOffset = math.ceil(radius * 0.4), math.ceil(radius * 0.4)

            radiusBlipCoords = vec3(
                coords.x + math.random(minOffset, maxOffset),
                coords.y + math.random(minOffset, maxOffset),
                coords.z
            )

            heistBlip = AddBlipForRadius(radiusBlipCoords.x, radiusBlipCoords.y, radiusBlipCoords.z, radius + 0.0)
            SetBlipColour(heistBlip, blipConfig.color)
            SetBlipAlpha(heistBlip, blipConfig.alpha)
        end

        local hdBlipConfig = crimeNotify.highDetailedBlip
        if isInitiator and hdBlipConfig then
            detailedHeistBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(detailedHeistBlip, hdBlipConfig.sprite)
            SetBlipColour(detailedHeistBlip, hdBlipConfig.color)
            SetBlipScale(detailedHeistBlip, hdBlipConfig.scale)
            SetBlipAlpha(detailedHeistBlip, hdBlipConfig.alpha)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(hdBlipConfig.label)
            EndTextCommandSetBlipName(detailedHeistBlip)
        end

        local centerredBlipConfig = crimeNotify.centerredBlip
        if not isInitiator and centerredBlipConfig and radiusBlipCoords then
            centerredHeistBlip = AddBlipForCoord(radiusBlipCoords.x, radiusBlipCoords.y, radiusBlipCoords.z)
            SetBlipSprite(centerredHeistBlip, centerredBlipConfig.sprite)
            SetBlipColour(centerredHeistBlip, centerredBlipConfig.color)
            SetBlipScale(centerredHeistBlip, centerredBlipConfig.scale)
            SetBlipAlpha(centerredHeistBlip, centerredBlipConfig.alpha)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(centerredBlipConfig.label)
            EndTextCommandSetBlipName(centerredHeistBlip)
        end

        heistPoint = lib.points.new({
            coords = coords,
            distance = radius,
            onEnter = function()
                Container.createOrShowContainer(coords)
                Wait(1000)
                addTargetToLock()
                syncLootspots()

                if isInitiator then
                    local container = Container.getObject('container')
                    if container and DoesEntityExist(container) then
                        SetEntityDrawOutline(container, true)
                        SetEntityDrawOutlineColor(255, 0, 0, 200)
                    end
                end
            end,
            onExit = function()
                removeTargetFromLock()
                LootSpots.clearAll()
            end
        })
    end,
    
    --- Cleanup heist zone
    cleanup = function()
        removeCurrent()
    end,
    
    Container = Container
}
