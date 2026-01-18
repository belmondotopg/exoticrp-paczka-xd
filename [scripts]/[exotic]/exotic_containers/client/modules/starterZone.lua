---@alias TargetData { entity: number?, requiredItems: string, weapon: string?, equipped: boolean?, zoneIndex: number }

local Config = require('config.main')
local MissionStarter = Config.MissionStarter
local currentZone = nil
local currentDeskObject = nil

---@param coords vector4
---@return number EntityHandle Returns the desk entity handle
local function placeDesk(coords)
    local deskModel = `reh_prop_reh_desk_comp_01a`
    lib.requestModel(deskModel)

    local existingObject = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.0, deskModel, false, false, false)
    if existingObject ~= 0 then
        if Config.debug then lib.print.info('desk object already exists, skipping.') end
        currentDeskObject = existingObject
        return currentDeskObject
    end

    local object = CreateObject(deskModel, coords.x, coords.y, coords.z, true, true, false)
    SetEntityHeading(object, coords.w)
    FreezeEntityPosition(object, true)
    SetModelAsNoLongerNeeded(deskModel)
    PlaceObjectOnGroundProperly(object)

    return object
end

return {
    setupZone = function(zoneIndex)
        local zoneData = Config.MissionStarter[zoneIndex]
        assert(zoneData, ("Invalid zoneIndex '%s' provided."):format(zoneIndex))

        local targetData = zoneData.targetData
        assert(targetData, ("Can not setup zone '%s', no targetData specified in config"):format(zoneIndex))

        currentZone = zoneIndex

        if targetData.options and next(targetData.options) then
            for i = 1, #targetData.options do
                local option = targetData.options[i]
                local success, actionModule = pcall(require, ("client.modules.starterActions.%s"):format(option.actionId))
                if success then
                    local originalOnSelect = actionModule
                    option.onSelect = function(data)
                        local canStart, errorInfo = lib.callback.await('exotic-containers:canStartHeist', false,
                            currentZone, option.actionId)

                        if not canStart then
                            if errorInfo then
                                if errorInfo.reason == 'missing_item' then
                                    ESX.ShowNotification('Brakuje ci wymaganego przedmiotu.')
                                elseif errorInfo.reason == 'abandoned_cooldown' then
                                    local minutes = math.ceil(errorInfo.timeLeft / 60)
                                    ESX.ShowNotification(('Musisz poczekać jeszcze %d minut przed rozpoczęciem nowego napadu.')
                                        :format(minutes))
                                elseif errorInfo.reason == 'finish_cooldown' then
                                    local minutes = math.ceil(errorInfo.timeLeft / 60)
                                    ESX.ShowNotification(('Musisz poczekać jeszcze %d minut po ukończonym napadzie.')
                                        :format(minutes))
                                end
                            else
                                ESX.ShowNotification('Nie możesz teraz rozpocząć napadu.')
                            end
                            return
                        end

                        data.zoneIndex = currentZone
                        return originalOnSelect(data)
                    end
                else
                    lib.print.error(("Failed to load module for actions '%s': %s"):format(option.actionId, actionModule))
                end
            end
        end

        if zoneData.deskCoords then
            ESX.ValidateType(zoneData.deskCoords, "vector4")
            currentDeskObject = placeDesk(zoneData.deskCoords)
        end

        if targetData.options then
            for i = 1, #targetData.options do
                if not targetData.options[i].entity and currentDeskObject then
                    targetData.options[i].entity = currentDeskObject
                end
            end
        end

        exports.ox_target:addSphereZone({
            coords = targetData.coords,
            name = ("missionStarter:%s"):format(currentZone),
            radius = targetData.radius,
            debug = Config.debug,
            options = targetData.options
        })
    end,
    destroyZone = function()
        if currentZone then
            exports.ox_target:removeZone(("missionStarter:%s"):format(currentZone))
            currentZone = nil
        end
    end
}
