------------------------------------------------------------------
-- Target Integration Layer                                       
-- (Information) ► Centralized bridge for ox_target / qb-target. 
------------------------------------------------------------------

---@param target string|number
function removeTarget(target)
    if Config.Misc.AccessMethod == "ox_target" then
        exports.ox_target:removeZone(target)
    elseif Config.Misc.AccessMethod == "qb-target" then
        exports['qb-target']:RemoveZone(target)
    end
end

---@param name string
---@param coords vector3
---@param size vector3
---@param icon string
---@param label string
---@param onselect function
---@return any
function addTargetTyped(name, coords, size, icon, label, onselect)
    if Config.Misc.AccessMethod == "ox_target" then
        return exports.ox_target:addBoxZone({
            name = name,
            coords = coords,
            size = size,
            options = {
                {
                    icon = icon,
                    label = label,
                    distance = 3.0,
                    onSelect = function()
                        onselect()
                    end
                }
            }
        })
    elseif Config.Misc.AccessMethod == "qb-target" then
        exports['qb-target']:AddCircleZone(
            name,
            coords,
            size.x,
            { name = name, debugPoly = false },
            {
                options = {
                    {
                        icon = icon,
                        label = label,
                        action = function()
                            onselect()
                        end
                    }
                }
            }
        )
        return name
    end
end

---@param data any
function removeTargetPlayer(data)
    if Config.Misc.AccessMethod == "ox_target" then
        exports.ox_target:removeGlobalPlayer(data)
    elseif Config.Misc.AccessMethod == "qb-target" then
        exports['qb-target']:RemoveGlobalPlayer(data)
    end
end

---@param name string
---@param icon string
---@param label string
---@param onselect function
---@return string
function addTargetPlayer(name, icon, label, onselect)
    if Config.Misc.AccessMethod == "ox_target" then
        exports.ox_target:addGlobalPlayer({
            distance = 2.0,
            icon = icon,
            label = label,
            onSelect = function()
                onselect()
            end
        })
        return label
    elseif Config.Misc.AccessMethod == "qb-target" then
        exports['qb-target']:AddGlobalPlayer({
            options = {
                {
                    num = 1,
                    type = "client",
                    icon = icon,
                    label = label,
                    action = function(entity)
                        onselect()
                    end,
                    canInteract = function(entity)
                        return IsPedAPlayer(entity)
                    end
                }
            },
            distance = 2.5
        })
        return label
    end
end

---@param name string
---@param icon string
---@param label string
---@param onselect function
---@return string
function addTargetVehicle(name, icon, label, onselect)
    if Config.Misc.AccessMethod == "ox_target" then
        exports.ox_target:addGlobalVehicle({
            size = vec3(5.0, 5.0, 5.0),
            icon = icon,
            label = label,
            onSelect = function()
                onselect()
            end
        })
        return label
    elseif Config.Misc.AccessMethod == "qb-target" then
        exports['qb-target']:AddGlobalVehicle({
            options = {
                {
                    num = 1,
                    type = "client",
                    icon = icon,
                    label = label,
                    action = function(entity)
                        onselect()
                    end,
                    canInteract = function(entity)
                        return IsPedAPlayer(entity)
                    end
                }
            },
            distance = 2.5
        })
        return label
    end
end

---@param data any
function removeTargetVehicle(data)
    if Config.Misc.AccessMethod == "ox_target" then
        exports.ox_target:removeGlobalVehicle(data)
    elseif Config.Misc.AccessMethod == "qb-target" then
        exports['qb-target']:RemoveGlobalVehicle(data)
    end
end