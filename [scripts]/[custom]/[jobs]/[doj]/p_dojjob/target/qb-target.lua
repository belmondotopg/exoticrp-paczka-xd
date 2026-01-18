if Config.Target ~= 'qb-target' then return end

Target = {}

Target.addSphereZone = function(data)
    for i = 1, #data.options, 1 do
        if data.options[i].onSelect then
            data.options[i].action = data.options[i].onSelect
        end
        if data.options[i].groups then
            data.options[i].job = data.options[i].groups
        end
        if data.options[i].items then
            data.options[i].item = data.options[i].items
        end
    end
    local name = 'doj_job'..tostring(math.random(11111111, 99999999))
    exports['qb-target']:AddCircleZone(name, data.coords, data.radius, {
        name = name,
        debugPoly = Config.Debug,
    }, {
        options = data.options,
        distance = data.options[1].distance or 2
    })
    return name
end

Target.addPlayer = function(options)
    for i = 1, #options, 1 do
        if options[i].onSelect then
            options[i].action = options[i].onSelect
        end
        if options[i].groups then
            options[i].job = options[i].groups
        end
        if options[i].items then
            options[i].item = options[i].items
        end
    end
    exports['qb-target']:AddGlobalPlayer({
        options = options,
        distance = 2.0
    })
end

Target.addVehicle = function(options)
    for i = 1, #options, 1 do
        if options[i].onSelect then
            options[i].action = options[i].onSelect
        end
        if options[i].groups then
            options[i].job = options[i].groups
        end
        if options[i].items then
            options[i].item = options[i].items
        end
    end
    exports['qb-target']:AddGlobalVehicle({
        options = options,
        distance = 2.0
    })
end

Target.addModel = function(models, options)
    for i = 1, #options, 1 do
        if options[i].onSelect then
            options[i].action = options[i].onSelect
        end
        if options[i].groups then
            options[i].job = options[i].groups
        end
        if options[i].items then
            options[i].item = options[i].items
        end
    end
    exports['qb-target']:AddTargetModel(models, {
        options = options,
        distance = options[1].distance or 1.75
    })
end

Target.removeZone = function(zoneId)
    exports['qb-target']:RemoveZone(zoneId)
end

Target.addLocalEntity = function(entity, options)
    for i = 1, #options, 1 do
        if options[i].onSelect then
            options[i].action = options[i].onSelect
        end
        if options[i].groups then
            options[i].job = options[i].groups
        end
        if options[i].items then
            options[i].item = options[i].items
        end
    end
    exports['qb-target']:AddTargetEntity(entity, {
        options = options,
        distance = 2.0
    })
end