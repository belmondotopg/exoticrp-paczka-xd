if Config.Target ~= 'ox_target' then return end

Target = {
    addSphereZone = function(data)
        return exports['ox_target']:addSphereZone(data)
    end,
    addPlayer = function(options)
        exports['ox_target']:addGlobalPlayer(options)
    end,
    addVehicle = function(options)
        exports['ox_target']:addGlobalVehicle(options)
    end,
    addModel = function(models, options)
        exports['ox_target']:addModel(models, options)
    end,
    removeZone = function(zoneId)
        exports['ox_target']:removeZone(zoneId)
    end,
    addLocalEntity = function(entity, options)
        exports['ox_target']:addLocalEntity(entity, options)
    end
}