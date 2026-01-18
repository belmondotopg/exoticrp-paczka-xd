--[[local Player = Player

local function isValueTooLarge(val)
    local valType = type(val)
    if valType == "string" then
        return val:len() > 500
    elseif valType == "table" then
        return msgpack.pack_args(val):len() > 5000
    end
    return false
end

local function rejectStateChange(caller, ent, state, key, curVal)
    TriggerEvent("StateBagAbuse", caller, ent)

	SetTimeout(0, function()
        state[key] = curVal
    end)
end

AddStateBagChangeHandler("", "", function(bagName, key, value, source, replicated)
    if bagName == "global" then return end
    if not replicated then return end
    local ent
    local owner
    local state

    if bagName:find("entity") then
        ent = GetEntityFromStateBagName(bagName)
        owner = NetworkGetEntityOwner(ent)
        state = Entity(ent).state
    else
        ent = GetPlayerFromStateBagName(bagName)
        owner = ent
        state = Player(ent).state
    end
    local curVal = state[key]

    if type(key) == "string" then
        if key:len() > 20 then
            rejectStateChange(owner, ent, state, key, curVal)
        end
    end
    if isValueTooLarge(value) then
        rejectStateChange(owner, ent, state, key, curVal)
    end
end)]]