local CONFIG = {
    GARAGE_DETECTION_DISTANCE = 10.0,
    IMPOUND_DETECTION_DISTANCE = 7.5,
    MARKER_RENDER_DISTANCE = 15.0,
    MARKER_HEIGHT_OFFSET = 0.50,
    THREAD_WAIT_TIME = 1,
    TEXTURE_LOAD_WAIT = 1000
}

local Markers = {}
local PlayerCoords = vec3(0, 0, 0)
local isTextureLoaded = false

lib.onCache("coords", function(Coords)
    PlayerCoords = Coords
end)

local function GetNearestMarker(markerType, maxDistance)
    if not Markers or #Markers == 0 then
        return false
    end
    
    local nearest = {
        Name = "",
        Distance = math.huge,
        OnSelect = false
    }
    
    for i = 1, #Markers do
        local marker = Markers[i]
        if marker and marker.coords and marker.name then
            local distance = #(PlayerCoords - marker.coords)
            
            if distance < nearest.Distance and string.find(marker.name, markerType) then
                nearest = {
                    Name = marker.name,
                    Distance = distance,
                    OnSelect = marker.onSelect
                }
            end
        end
    end
    
    return nearest.Distance <= maxDistance and nearest or false
end

local function GetNearestGarage()
    return GetNearestMarker("garage", CONFIG.GARAGE_DETECTION_DISTANCE)
end

local function GetNearestImpound()
    return GetNearestMarker("impound", CONFIG.IMPOUND_DETECTION_DISTANCE)
end

local function LoadTextureDict()
    if not isTextureLoaded then
        if not HasStreamedTextureDictLoaded("marker") then
            RequestStreamedTextureDict("marker", true)
            local timeout = 0
            while not HasStreamedTextureDictLoaded("marker") and timeout < 50 do
                Wait(100)
                timeout = timeout + 1
            end
            if timeout >= 50 then
                return false
            end
        end
        isTextureLoaded = true
    end
    return true
end

CreateThread(function()
    while true do
        Wait(CONFIG.THREAD_WAIT_TIME)
        
        if not Markers or #Markers == 0 then
            Wait(5000)
            goto continue
        end

        if not LoadTextureDict() then
            Wait(CONFIG.TEXTURE_LOAD_WAIT)
            goto continue
        end

        for i = 1, #Markers do
            local marker = Markers[i]
            if marker and marker.coords then
                local distance = #(PlayerCoords - marker.coords)
                
                if distance < CONFIG.MARKER_RENDER_DISTANCE then
                    local markerCoords = vec3(
                        marker.coords[1], 
                        marker.coords[2], 
                        marker.coords[3] + CONFIG.MARKER_HEIGHT_OFFSET
                    )
                    
                    DrawMarker(
                        9,
                        markerCoords,
                        0.0, 0.0, 0.0,
                        vec3(90.0, 0.0, 0.0),
                        vec3(3.0, 1.0, 3.0),
                        255, 255, 255, 230,
                        false, true, 0.0, false,
                        "marker", marker.markerType, false
                    )
                end
            end
        end
        
        ::continue::
    end
end)

local function ValidateTargetConfig()
    if not Config or not Config.Misc or not Config.Misc.Target then
        return false
    end
    return true
end

function removeTarget(target)
    if not ValidateTargetConfig() or not target then
        return false
    end
    
    local success = false
    
    if Config.Misc.Target == "ox-target" then
        success = pcall(function()
            exports.ox_target:removeZone(target, true) -- suppressWarning = true to avoid warnings for non-existent zones
        end)
    elseif Config.Misc.Target == "qb-target" then
        success = pcall(function()
            exports['qb-target']:RemoveZone(target)
        end)
    elseif Config.Misc.Target == "onex-radialmenu" then
        success = pcall(function()
            exports['onex-radialmenu']:onexRemoveRadialItem(target.parent, target.id)
        end)
    else
        return false
    end
    
    return success
end

function addTargetTyped(name, coords, size, icon, label, onselect)
    if not name or not coords or not size or not icon or not label or not onselect then
        return false
    end
    
    if not ValidateTargetConfig() then
        return false
    end
    
    local targetType = "garage"
    if string.find(name, "impound") then
        targetType = "impound"
    end
    
    local success = false
    local result = false
    
    if Config.Misc.Target == "ox-target" then
        Markers[#Markers + 1] = {
            coords = coords,
            name = name,
            onSelect = onselect,
            markerType = targetType
        }
        result = name
        success = true
        
    elseif Config.Misc.Target == "qb-target" then
        success = pcall(function()
            exports['qb-target']:AddCircleZone(name, coords, size.x, {
                name = name,
                debugPoly = false,
                useZ = true
            }, {
                options = {
                    {
                        icon = icon,
                        label = label,
                        action = function()
                            onselect()
                        end
                    }
                },
                distance = size.x
            })
        end)
        result = success and name or false
        
    elseif Config.Misc.Target == "onex-radialmenu" then
        success = pcall(function()
            exports['onex-radialmenu']:onexRadialItemAdd({
                title = label,
                closeRadialMenu = false,
                icon = {
                    address = icon,
                    width = "24px",
                    height = "24px"
                },
                type = "nested",
                trigger = {
                    onSelect = function()
                        onselect()
                    end
                }
            }, name, 'main_menu')
        end)
        result = success and {id = name, parent = "main_menu"} or false
        
    else
        return false
    end
    
    return result
end

exports("GetNearestImpound", GetNearestImpound)
exports("GetNearestGarage", GetNearestGarage)