if Config.Clothing.clothingScript ~= "skinchanger" then return end

local PED_COMPONENTS_IDS = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
local PED_PROPS_IDS = {0, 1, 2, 6, 7}

local function getPedComponents(ped)
    local size = #PED_COMPONENTS_IDS
    local components = {}
    
    for i = 1, size do
        local componentId = PED_COMPONENTS_IDS[i]
        components[i] = {
            component_id = componentId,
            drawable = GetPedDrawableVariation(ped, componentId),
            texture = GetPedTextureVariation(ped, componentId),
        }
    end
    
    return components
end

local function getPedProps(ped)
    local size = #PED_PROPS_IDS
    local props = {}
    
    for i = 1, size do
        local propId = PED_PROPS_IDS[i]
        props[i] = {
            prop_id = propId,
            drawable = GetPedPropIndex(ped, propId),
            texture = GetPedPropTextureIndex(ped, propId),
        }
    end
    return props
end

function getPlayerClothes(cb)
    local playerPed = PlayerPedId()
    
    local components = getPedComponents(playerPed)
    local props = getPedProps(playerPed)
    
    local clothing = {
        components = components,
        props = props
    }
    
    cb(clothing)
end

function setPlayerClothes(clothing)
    local playerPed = PlayerPedId()
    
    local function copyComponents(components)
        local copy = {}
        for i = 1, #components do
            copy[i] = {
                component_id = components[i].component_id,
                drawable = components[i].drawable,
                texture = components[i].texture
            }
        end
        table.sort(copy, function(a, b)
            return a.component_id < b.component_id
        end)
        return copy
    end
    
    if clothing.components then
        local componentsCopy1 = copyComponents(clothing.components)
        exports['qf_skinmenu']:setPedComponents(playerPed, componentsCopy1)
        Wait(100)
        
        local componentsCopy2 = copyComponents(clothing.components)
        exports['qf_skinmenu']:setPedComponents(playerPed, componentsCopy2)
    end
    
    if clothing.props then
        exports['qf_skinmenu']:setPedProps(playerPed, clothing.props)
        Wait(50)
        exports['qf_skinmenu']:setPedProps(playerPed, clothing.props)
    end
    
    Wait(200)
    
    Wait(100)
    local currentAppearance = exports.qf_skinmenu.getPedAppearance()
    
    currentAppearance.components = getPedComponents(playerPed)
    currentAppearance.props = getPedProps(playerPed)
    
    TriggerServerEvent("qf_skinmenu/saveAppearance", currentAppearance)
end