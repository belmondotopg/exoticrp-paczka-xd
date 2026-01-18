if GetResourceState('ox_target') ~= 'started' or not Config.UseTarget then return end
local ox_target = exports.ox_target

function AddModel(models, options)
    local optionsNames = {}
    for i=1, #options do 
        optionsNames[i] = options[i].name
    end
    RemoveModel(models, optionsNames)
    ox_target:addModel(models, options)
end

function RemoveModel(models, optionsNames)
    ox_target:removeModel(models, optionsNames)
end

function AddTargetZone(coords, radius, options)
    return ox_target:addSphereZone({
        coords = coords,
        radius = radius,
        options = options
    })
end

function RemoveTargetZone(index)
    ox_target:removeZone(index)
end