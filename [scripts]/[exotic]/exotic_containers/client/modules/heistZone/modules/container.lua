---@class ContainerObjects
---@field container number? Container entity
---@field collision number? Collision entity
---@field lock number? Lock entity

---@class AnimationObjects
---@field localContainer number? Local container entity
---@field localLock number? Local lock entity
---@field clientScene number? Synchronized scene

---@type ContainerObjects
local objects = {
    container = nil,
    collision = nil,
    lock = nil
}

---@type AnimationObjects
local animationObjects = {
    localContainer = nil,
    localLock = nil,
    clientScene = nil
}

--- Check if container exists locally or on server
---@return boolean
local function doesContainerExist()
    return objects.container ~= nil or lib.callback.await('exotic-containers:doesContainerExist')
end

--- Get existing container network IDs from server
---@return { container: number?, collision: number?, lock: number? }?
local function getExistingContainerNetIds()
    return lib.callback.await('exotic-containers:getContainerNetIds')
end

--- Assign existing container entities from network IDs
---@param netIds { container: number?, collision: number?, lock: number? }?
---@return boolean success Whether assignment was successful
local function assignExistingContainer(netIds)
    if not netIds or not netIds.container then return false end

    objects.container = NetworkGetEntityFromNetworkId(netIds.container)
    objects.collision = netIds.collision and NetworkGetEntityFromNetworkId(netIds.collision)
    objects.lock = netIds.lock and NetworkGetEntityFromNetworkId(netIds.lock)

    local entitiesExist = DoesEntityExist(objects.container or 0) and
        DoesEntityExist(objects.collision or 0)

    if not entitiesExist then
        objects.container = nil
        objects.collision = nil
        objects.lock = nil
        return false
    end

    return true
end

--- Setup local animation objects
---@param coords vector4
local function setupLocalObjects(coords)
    local containerHash = `tr_prop_tr_container_01h`
    local lockHash = `tr_prop_tr_lock_01a`

    lib.requestModel(containerHash)
    lib.requestModel(lockHash)

    animationObjects.localContainer = CreateObject(containerHash, coords.x, coords.y, coords.z, false, false, false)
    animationObjects.localLock = CreateObject(lockHash, coords.x, coords.y, coords.z, false, false, false)

    SetModelAsNoLongerNeeded(containerHash)
    SetModelAsNoLongerNeeded(lockHash)
end

--- Play container opening animation
---@param coords vector4
---@param force boolean? Force play animation even if container exists
local function playOpeningAnimation(coords, force)
    if not force and not doesContainerExist() then
        return
    end

    setupLocalObjects(coords)

    local animDict = 'anim@scripted@player@mission@tunf_train_ig1_container_p1@male@'
    lib.requestAnimDict(animDict)

    animationObjects.clientScene = CreateSynchronizedScene(
        coords.x, coords.y, coords.z, 0.0, 0.0, 0.0,
        2, true, false, 1065353216, 0, 1065353216
    )

    if animationObjects.localContainer and DoesEntityExist(animationObjects.localContainer) then
        PlaySynchronizedEntityAnim(
            animationObjects.localContainer,
            animationObjects.clientScene,
            'action_container',
            animDict,
            1.0, -1.0, 0, 1148846080
        )
        ForceEntityAiAndAnimationUpdate(animationObjects.localContainer)
    end

    if animationObjects.localLock and DoesEntityExist(animationObjects.localLock) then
        PlaySynchronizedEntityAnim(
            animationObjects.localLock,
            animationObjects.clientScene,
            'action_lock',
            animDict,
            1.0, -1.0, 0, 1148846080
        )
        ForceEntityAiAndAnimationUpdate(animationObjects.localLock)
    end

    if animationObjects.clientScene then
        SetSynchronizedScenePhase(animationObjects.clientScene, 0.99)
    end

    if animationObjects.localContainer then
        SetEntityCollision(animationObjects.localContainer, false, true)
        FreezeEntityPosition(animationObjects.localContainer, true)
    end

    RemoveAnimDict(animDict)
end

local function cleanupAnimationObjects()
    local entities = {
        animationObjects.localContainer,
        animationObjects.localLock
    }

    for i = 1, #entities do
        local entity = entities[i]
        if entity and DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end

    if animationObjects.clientScene then
        NetworkStopSynchronisedScene(animationObjects.clientScene)
    end

    animationObjects.localContainer = nil
    animationObjects.localLock = nil
    animationObjects.clientScene = nil
end

--- Create container objects
---@param coords vector4
local function createContainer(coords)
    if (animationObjects.localContainer and DoesEntityExist(animationObjects.localContainer)) or
        (objects.container and DoesEntityExist(objects.container)) then
        return
    end

    local containerExists = lib.callback.await('exotic-containers:doesContainerExist')

    if containerExists then
        local netIds = getExistingContainerNetIds()
        if netIds and assignExistingContainer(netIds) then
            return
        end
    end

    local containerHash = `tr_prop_tr_container_01h`
    local collisionHash = `prop_ld_container`
    local lockHash = `tr_prop_tr_lock_01a`

    objects.container = ESX.Game.SpawnObject(containerHash, coords)
    Wait(300)

    objects.collision = ESX.Game.SpawnObject(collisionHash, coords)
    FreezeEntityPosition(objects.container, true)
    SetEntityVisible(objects.collision, false, true)
    FreezeEntityPosition(objects.collision, true)

    objects.lock = ESX.Game.SpawnObject(lockHash,
        GetOffsetFromEntityInWorldCoords(objects.container, 0.0, -1.85, 1.1))

    local entities = { objects.container, objects.collision, objects.lock }
    local netIds = {}

    for i, entity in ipairs(entities) do
        if entity then
            local netId = nil
            ESX.Await(function()
                netId = NetworkGetNetworkIdFromEntity(entity)
                return NetworkDoesNetworkIdExist(netId)
            end)
            netIds[i] = netId
            Wait(250)
        end
    end

    TriggerServerEvent('exotic-containers:createContainer', netIds[1], netIds[2], netIds[3])
end

local function cleanup()
    cleanupAnimationObjects()
    objects.container = nil
    objects.collision = nil
    objects.lock = nil
end

return {
    doesContainerExist = doesContainerExist,

    --- Get current container objects
    ---@return ContainerObjects
    getObjects = function()
        return objects
    end,

    ---@param objectType 'container' | 'collision' | 'lock'
    ---@return number? Entity handle
    getObject = function(objectType)
        return objects[objectType]
    end,

    createContainer = createContainer,

    --- Create or show container based on state
    ---@param coords vector4
    createOrShowContainer = function(coords)
        local containerExists = lib.callback.await('exotic-containers:isContainerOpened')
        local localObjectsExist = animationObjects.localContainer and DoesEntityExist(animationObjects.localContainer)

        if containerExists then
            if not localObjectsExist then
                playOpeningAnimation(coords, true)
            end
        else
            if not (objects.container and DoesEntityExist(objects.container)) then
                createContainer(coords)
            end
        end
    end,

    playOpeningAnimation = playOpeningAnimation,
    cleanupAnimationObjects = cleanupAnimationObjects,

    ---Get animation objects
    ---@return AnimationObjects
    getAnimationObjects = function()
        return animationObjects
    end,

    cleanup = cleanup
}
