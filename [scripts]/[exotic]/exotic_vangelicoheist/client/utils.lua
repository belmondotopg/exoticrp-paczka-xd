local utils = {}

local function getNetId(entity)
    if not DoesEntityExist(entity) then
        print("Entity does not exist:", entity)
        return nil
    end

    return lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(entity) then
            NetworkRegisterEntityAsNetworked(entity)
        else
            local netId = NetworkGetNetworkIdFromEntity(entity)
            if NetworkDoesNetworkIdExist(netId) then
                return netId
            end
        end
    end, 5000, false) -- Added 5 second timeout
end

--- @param obj number | table<number>
function utils.getNetIds(obj)
    if type(obj) == "number" then
        return getNetId(obj)
    elseif type(obj) == "table" then
        local netIds = {}
        for k, v in pairs(obj) do
            netIds[k] = utils.getNetIds(v)
        end
        return netIds
    end
    return nil
end

local ESX_HUD <const> = exports.esx_hud

function utils.notify(text)
    ESX_HUD:sendNotification(text, "info")
end

function utils.requestControl(entity)
    if not DoesEntityExist(entity) then
        print("Entity does not exist:", entity)
        return false
    end

    local startTime = GetGameTimer()
    while not NetworkHasControlOfEntity(entity) do
        NetworkRequestControlOfEntity(entity)
        Citizen.Wait(1)

        if GetGameTimer() - startTime > 5000 then -- 5 second timeout
            print("Failed to gain control of entity within timeout:", entity)
            return false
        end
    end
    return true
end

function utils.helpNotify(...)
    exports["esx_hud"]:helpNotification(...)
end

function utils.hideHelpNotify()
    exports["esx_hud"]:hideHelpNotification()
end

function utils.loadAnimDicts(dicts)
    if type(dicts) == 'string' then
        lib.requestAnimDict(dicts)
    elseif type(dicts) == 'table' then
        for k, v in pairs(dicts) do
            if type(v) == 'table' then
                utils.loadAnimDicts(v)
            else
                lib.requestAnimDict(v)
            end
        end
    end
end

function utils.loadModels(models)
    if type(models) == 'string' then
        lib.requestModel(models)
    elseif type(models) == 'table' then
        for k, v in pairs(models) do
            if type(v) == 'table' then
                utils.loadModels(v)
            else
                lib.requestModel(v)
            end
        end
    end
end

function utils.unloadAnimDicts(dicts)
    if type(dicts) == 'string' then
        RemoveAnimDict(dicts)
    elseif type(dicts) == 'table' then
        for k, v in pairs(dicts) do
            if type(v) == 'table' then
                utils.unloadAnimDicts(v)
            else
                RemoveAnimDict(v)
            end
        end
    end
end

function utils.unloadModels(models)
    if type(models) == 'string' then
        SetModelAsNoLongerNeeded(GetHashKey(models))
    elseif type(models) == 'table' then
        for k, v in pairs(models) do
            if type(v) == 'table' then
                utils.unloadModels(v)
            else
                SetModelAsNoLongerNeeded(GetHashKey(v))
            end
        end
    end
end

function utils.prepForScene(coords, entity, clearbag)
    SetPlayerControl(cache.playerId, false, 1 << 8)
    local pedcoords = GetEntityCoords(cache.ped)
    local targetcoords = entity and GetEntityCoords(entity) or coords
    local headingvec = vec(targetcoords.x - pedcoords.x, targetcoords.y - pedcoords.y)
    local heading = GetHeadingFromVector_2d(headingvec.x, headingvec.y)
    TaskGoStraightToCoord(cache.ped, coords.x, coords.y, coords.z, 1.0, 2000, heading, 1.0)
    Wait(500)
    local started = GetGameTimer()
    while GetGameTimer() - started < 2000 and #(GetEntityCoords(cache.ped) - coords) > 1.5 do
        print(#(GetEntityCoords(cache.ped) - coords))
        local taskStatus = GetScriptTaskStatus(cache.ped, "SCRIPT_TASK_GO_STRAIGHT_TO_COORD")
        if (taskStatus >= 2) then break end
        Wait(0)
    end
    FreezeEntityPosition(cache.ped, true)
    ClearPedTasksImmediately(cache.ped)
    if clearbag then SetPedComponentVariation(cache.ped, 5, 0, 0, 0) end
    Wait(200)
end

function utils.resetScenePrep()
    SetPlayerControl(cache.playerId, true, 0)
    FreezeEntityPosition(cache.ped, false)
end

-- local _NetworkStartSynchronisedScene = NetworkStartSynchronisedScene
-- NetworkStartSynchronisedScene = function(id)
--     Wait(100)
--     _NetworkStartSynchronisedScene(id)
-- end

return utils
