--- Stop a running synchronized scene
--- @param scene number
local function stopScene(scene)
    if scene then
        NetworkStopSynchronisedScene(scene)
    end
end

--- Play a synchronized scene for a ped and multiple optional entities
--- @param ped number
--- @param objects number | table[]? -- A single entity or list of objects: { model?, entity?, animDict?, anim? }
--- @param animDict string
--- @param animName string
--- @param sceneCoords vector3
--- @param sceneRot vector3
--- @return number, table, { models: number[], animDicts: table<string, boolean> }
local function playScene(ped, objects, animDict, animName, entityAnim, sceneCoords, sceneRot)
    lib.requestAnimDict(animDict)

    local scene = NetworkCreateSynchronisedScene(
        sceneCoords.x, sceneCoords.y, sceneCoords.z,
        sceneRot.x, sceneRot.y, sceneRot.z,
        2, true, false, -1, 0, 1.0
    )

    NetworkAddPedToSynchronisedScene(ped, scene, animDict, animName, 1.5, -4.0, 4, 16, 0, 0)

    local spawnedObjects = {}
    local usedModels = {}
    local usedAnimDicts = { [animDict] = true }

    if type(objects) == "number" then
        if DoesEntityExist(objects) then
            NetworkAddEntityToSynchronisedScene(objects, scene, animDict, entityAnim, 1.0, 1.0, 1)
            spawnedObjects[#spawnedObjects+1] = objects
        end
    elseif type(objects) == "table" then
        for i = 1, #objects do
            local obj = objects[i]
            local entity = obj.entity
            local model = obj.model

            if not entity and model then
                lib.requestModel(obj.model)
                entity = CreateObject(obj.model, sceneCoords.x, sceneCoords.y, sceneCoords.z, true, true, false)
                SetEntityCoords(entity, sceneCoords.x, sceneCoords.y, sceneCoords.z)
                SetEntityRotation(entity, sceneRot.x, sceneRot.y, sceneRot.z, 2, true)
                SetEntityAsMissionEntity(entity, true, true)
                usedModels[#usedModels+1] = model
            end

            if entity and DoesEntityExist(entity) then
                local dict = obj.animDict or animDict
                local anim = obj.anim or animName
                lib.requestAnimDict(dict)
                usedAnimDicts[dict] = true

                NetworkAddEntityToSynchronisedScene(entity, scene, dict, anim, 1.0, 1.0, 1)
                spawnedObjects[#spawnedObjects+1] = entity
            end
        end
    end

    NetworkStartSynchronisedScene(scene)

    return scene, spawnedObjects, { models = usedModels, animDicts = usedAnimDicts }
end

return {
    playScene = playScene,

    --- Calculate position & rotation for scene from an entity
    --- @param entity number
    --- @return vector3 coords, vector3 rot
    getTransformFromEntity = function(entity)
        local coords = GetEntityCoords(entity)
        local heading = GetEntityHeading(entity)
        return coords, vector3(0.0, 0.0, heading)
    end,

    stopScene = stopScene,

    --- Play animation and wait until it's done before stopping scene
    ---@param ped number
    ---@param objects number | table[]? -- A single entity or list of objects: { model?, entity?, animDict?, anim? }
    ---@param animDict string
    ---@param animName string
    ---@param entityAnim string?
    ---@param sceneCoords vector3
    ---@param sceneRot vector3
    ---@param bypassDeletion table<string, boolean>? Key-value pair (key should be model or entity handle) of entites that should not be deleted after the scene finished.
    playAndWait = function(ped, objects, animDict, animName, entityAnim, sceneCoords, sceneRot, bypassDeletion)
        local scene, spawnedEntities, resources = playScene(ped, objects, animDict, animName, entityAnim,
            sceneCoords, sceneRot)

        local duration = math.ceil(GetAnimDuration(animDict, animName) * 1000)
        Wait(duration)

        stopScene(scene)
    
        for dict in pairs(resources.animDicts or {}) do
            RemoveAnimDict(dict)
        end

        if next(resources.models) then
            for i = 1, #resources.models do
                SetModelAsNoLongerNeeded(resources.models[i])
            end
        end

        if next(spawnedEntities) then
            for i = 1, #spawnedEntities do
                local entity = spawnedEntities[i]
                if DoesEntityExist(entity) and (not bypassDeletion or (not bypassDeletion[GetEntityModel(entity)] and not bypassDeletion[entity])) then
                    DeleteEntity(entity)
                end
            end
        end
    end
}
