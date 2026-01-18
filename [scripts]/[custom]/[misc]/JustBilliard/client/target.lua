
if Config.EnableInteractionTargetScript then
    -----------------------------
    -- Pool Tables Interaction --
    -----------------------------

    -- Add
    AddEventHandler(EVENTS['onGameObservingStarted'], function(gameId, propHandle)
        local icon = 'fa-solid fa-gamepad'
        local label = _('Join Pool Table')
        local distance = 1.0
        local function canInteract()
            return not joinedGames[gameId]
        end
        local function onSelect()
            if clientHasCueInHandStatebag() then
                TriggerServerEvent(EVENTS['joinTable'], gameId)
            else
                Framework.showWarningNotification(_('no_cue_in_hands'))
            end
        end
        
        if Config.TargetScriptName == SCRIPT_OX_TARGET then
            local options = {
                icon = icon,
                label = label,
                distance = distance,
                canInteract = function(entity, distance, coords, name)
                    return canInteract()
                end,
                onSelect = function(data)
                    return onSelect()
                end
            }
            exports[SCRIPT_OX_TARGET]:addLocalEntity({propHandle}, options)
        elseif Config.TargetScriptName == SCRIPT_QB_TARGET then
            exports[SCRIPT_QB_TARGET]:AddTargetEntity(propHandle, {
                options = {
                    {
                        icon = icon,
                        label = label,
                        canInteract = function()
                            return canInteract()
                        end,
                        action = function()
                            return onSelect()
                        end
                    },
                },
                distance = distance
            })
        end
    end)
    
    -- Remove
    AddEventHandler(EVENTS['onGameObservingStopped'], function(id, propHandle)
        if Config.TargetScriptName == SCRIPT_OX_TARGET then
            exports[SCRIPT_OX_TARGET]:removeLocalEntity(propHandle)
        elseif Config.TargetScriptName == SCRIPT_QB_TARGET then
            exports[SCRIPT_QB_TARGET]:RemoveTargetEntity(propHandle)
        end
    end)

    ----------------------------
    -- Cue Stands Interaction --
    ----------------------------

    -- Add
    local function initCueStandInteraction(hash, cueStandId)
        local icon = 'fa-solid fa-puzzle-piece'
        local label = _('Take/Put Cue')
        local distance = 1.0
        local function canInteract()
            return true
        end
        local function onSelect()
            requestToggleCueInHandStatebag(cueStandId)
        end

        if Config.TargetScriptName == SCRIPT_OX_TARGET then
            local options = {
                icon = icon,
                label = label,
                distance = distance,
                canInteract = function(entity, distance, coords, name)
                    return canInteract()
                end,
                onSelect = function(data)
                    return onSelect()
                end
            }
            exports[SCRIPT_OX_TARGET]:addModel(hash, options)
        elseif Config.TargetScriptName == SCRIPT_QB_TARGET then
            local options = {
                options = {
                    {
                        icon = icon,
                        label = label,
                        canInteract = function()
                            return canInteract()
                        end,
                        action = function()
                            return onSelect()
                        end
                    }
                },
                distance = distance
            }
            exports[SCRIPT_QB_TARGET]:AddTargetModel(hash, options)
        end
    end

    -- Collect unique model hashes
    local hashes = {}
    for k,v in ipairs(Config.Tables) do
        if v.type == TYPE_CUE_STAND then
            if v.prop?.hash then
                hashes[v.prop.hash] = v.id
            end
        end
    end
    for hash,cueStandId in pairs(hashes) do
        initCueStandInteraction(hash, cueStandId)
    end

    -- Remove
    AddEventHandler('onResourceStop', function(resourceName)
        if GetCurrentResourceName() == resourceName then
            for k,v in ipairs(Config.Tables) do
                if v.type == TYPE_CUE_STAND then
                    local hash = v.prop?.hash
                    if hash then
                        if Config.TargetScriptName == SCRIPT_OX_TARGET then
                            exports[SCRIPT_OX_TARGET]:removeModel(hash)
                        elseif Config.TargetScriptName == SCRIPT_QB_TARGET then
                            exports[SCRIPT_QB_TARGET]:RemoveTargetModel(hash)
                        end
                    end
                end
            end
        end
    end)
end