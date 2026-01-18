Utils = Utils or {}

-- Create a NPC
-- @param table dataObject Table containing all the required values
-- @return number pedId The id of the created NPC
function Utils:CreateNpc(dataObject)
    if not TypeChecker:ValidateSchema(dataObject, TypeChecker.Utils.NpcDataSchema) then
        return
    end

    local model = GetHashKey(dataObject.model)

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(1)
    end

    local ped = CreatePed(4, model, dataObject.position.x, dataObject.position.y, dataObject.position.z - 1, dataObject.heading, dataObject.isNetworked, true)

    -- TODO: add options in the dataObject to enable/disable these features
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    return ped
end
exports("createNpc", function(dataObject)
    return Utils:CreateNpc(dataObject)
end)