local utils = {}

--- @param job string | table<string>
--- @return number
function utils.getJobOnlineCount(job)
    if type(job) == "string" then
        return ESX.GetNumPlayers("job", job)
    end

    local count = 0
    for i = 1, #job do
        count = count + ESX.GetNumPlayers("job", job[i])
    end
    return count
end

function utils.deleteByNetids(netIds)
    if not netIds then return end
    if type(netIds) == "number" then
        local entity = NetworkGetEntityFromNetworkId(netIds)
        DeleteEntity(entity)
    elseif type(netIds) == "table" then
        for _, netId in pairs(netIds) do
            utils.deleteByNetids(netId)
        end
    end
end

function utils.setHeistPropAttributes(netIds)
    if not netIds then return end
    if type(netIds) == "number" then
        local entity = NetworkGetEntityFromNetworkId(netIds)
        SetEntityIgnoreRequestControlFilter(entity, true)
        SetEntityRemoteSyncedScenesAllowed(entity, true)
    elseif type(netIds) == "table" then
        for _, netId in pairs(netIds) do
            utils.setHeistPropAttributes(netId)
        end
    end
end

function utils.notify(src, text)
    TriggerClientEvent("esx:showNotification", src, text, "info")
end

return utils