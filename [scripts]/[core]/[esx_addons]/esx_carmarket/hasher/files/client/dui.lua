local RESOURCE_NAME = GetCurrentResourceName()
local duiUrl = string.format("https://cfx-nui-%s/web/build/index.html", RESOURCE_NAME)
local SCREEN_WIDTH = 1920
local SCREEN_HEIGHT = 1080
local DUI_INIT_COUNTER = 100
local NEAR_DISTANCE = 8.0
local FAR_DISTANCE = 15.0
local DUI_OFFSET_Z = 1.4

local Duis = {}

local function getVehicleDisplayName(model)
    if type(model) == "string" and tonumber(model) then
        model = tonumber(model)
    end
    
    if type(model) == "number" then
        return GetDisplayNameFromVehicleModel(model) or "Nieznany"
    else
        return model or "Nieznany"
    end
end

local function removeAllDuis()
    for k, v in pairs(Duis) do
        if v and v.duiObject then
            DestroyDui(v.duiObject)
        end
    end
    Duis = {}
end

local function removeDui(vehicle)
    local vehicleIndexString = tostring(vehicle)
    if Duis[vehicleIndexString] then
        Duis[vehicleIndexString].active = false
        
        if Duis[vehicleIndexString].duiObject then
            DestroyDui(Duis[vehicleIndexString].duiObject)
        end
        
        Duis[vehicleIndexString] = nil
    end
end

exports('removeDui', removeDui)
exports('removeAllDuis', removeAllDuis)

function createDUI(vehicle, dataVehicle)
    if not DoesEntityExist(vehicle) then return end
    if not dataVehicle or not dataVehicle.props then 
        return 
    end
    
    if type(dataVehicle.props) ~= "table" then
        return
    end
    
    local vehicleIndexString = tostring(vehicle)
    
    if Duis[vehicleIndexString] then
        removeDui(vehicle)
    end
    
    Duis[vehicleIndexString] = {}
    Duis[vehicleIndexString].duiObject = CreateDui(duiUrl, SCREEN_WIDTH, SCREEN_HEIGHT)
    Duis[vehicleIndexString].duiHandle = GetDuiHandle(Duis[vehicleIndexString].duiObject)
    Duis[vehicleIndexString].active = true

    local txd = CreateRuntimeTxd('dui_texture_' .. vehicleIndexString)
    CreateRuntimeTextureFromDuiHandle(txd, 'dui_render_' .. vehicleIndexString, Duis[vehicleIndexString].duiHandle)
    local initCounter = DUI_INIT_COUNTER

    local positionAboveCar = GetEntityCoords(vehicle)
    positionAboveCar = vec3(positionAboveCar.x, positionAboveCar.y, positionAboveCar.z + DUI_OFFSET_Z)

    local function Clamp(value, min, max)
        if value < min then return min end
        if value > max then return max end
        return value
    end

    while Duis[vehicleIndexString] and Duis[vehicleIndexString].active and DoesEntityExist(vehicle) do
        local sleep = 100
        local onScreen, screenX, screenY =
        GetScreenCoordFromWorldCoord(positionAboveCar.x, positionAboveCar.y, positionAboveCar.z)
        local camCoord = GetGameplayCamCoord()
        local distance = #(positionAboveCar - camCoord)
        local playercoords = GetEntityCoords(PlayerPedId())
        local vehiclecoords = positionAboveCar
        local distance2 = #(playercoords - vehiclecoords)
        local scale = math.max(0.1, 5.0 / distance)

        if distance2 < NEAR_DISTANCE then
            sleep = 0
            DrawSprite('dui_texture_' .. vehicleIndexString, 'dui_render_' .. vehicleIndexString, screenX,
            screenY, scale, scale, 0.0, 255, 255, 255, 255)
        elseif distance2 < FAR_DISTANCE then
            sleep = 0
            DrawSprite('dui_texture_' .. vehicleIndexString, 'dui_render_' .. vehicleIndexString, screenX,
            screenY, scale, scale, 0.0, 255, 255, 255, 255)
        else
            sleep = 200
        end

        if initCounter > 0 then
            initCounter = initCounter - 1
            SendDuiMessage(Duis[vehicleIndexString].duiObject, json.encode({
                action = "setVisible",
                data = true
            }))
            
            local displayData = {
                model = getVehicleDisplayName(dataVehicle.model),
                owner = dataVehicle.owner,
                price = dataVehicle.price,
                since = dataVehicle.since,
                phone = dataVehicle.phone or "Brak numeru"
            }
            
            SendDuiMessage(Duis[vehicleIndexString].duiObject, json.encode({
                action = "setVehicleBasics",
                data = displayData
            }))

            local modEngine = dataVehicle.props.modEngine or -1
            local modTransmission = dataVehicle.props.modTransmission or -1
            local modBrakes = dataVehicle.props.modBrakes or -1
            local modSuspension = dataVehicle.props.modSuspension or -1
            local modTurbo = dataVehicle.props.modTurbo or false

            local upgrades = {
                { name = "Silnik", level = modEngine + 1, maxLevel = 5, installed = modEngine >= 0 },
                { name = "Skrzynia biegów", level = modTransmission + 1, maxLevel = 5, installed = modTransmission >= 0 },
                { name = "Hamulce", level = modBrakes + 1, maxLevel = 5, installed = modBrakes >= 0 },
                { name = "Zawieszenie", level = modSuspension + 1, maxLevel = 5, installed = modSuspension >= 0 },
                { name = "Turbo", level = modTurbo and 1 or 0, maxLevel = 1, installed = modTurbo },
            }

            local modelHash = GetHashKey(dataVehicle.model)
            local baseSpeed = GetVehicleModelEstimatedMaxSpeed(modelHash) or 30.0
            local baseAcceleration = GetVehicleModelAcceleration(modelHash) or 0.5
            local baseBraking = GetVehicleModelMaxBraking(modelHash) or 1.0
            local baseTraction = GetVehicleModelMaxTraction(modelHash) or 2.0

            local performanceStats = {
                {
                    name = "Prędkość",
                    value = Clamp(math.floor((baseSpeed / 50) + (upgrades[1].level * 0.5) + (upgrades[5].installed and 0.5 or 0)), 1, 5),
                    maxValue = 5
                },
                {
                    name = "Akceleracja",
                    value = Clamp(math.floor((baseAcceleration * 4) + (upgrades[1].level * 0.3) + (upgrades[2].level * 0.2) + (upgrades[5].installed and 0.5 or 0)), 1, 5),
                    maxValue = 5
                },
                {
                    name = "Hamowanie",
                    value = Clamp(math.floor((baseBraking * 3) + (upgrades[3].level * 0.4)), 1, 5),
                    maxValue = 5
                },
                {
                    name = "Trakcja",
                    value = Clamp(math.floor((baseTraction * 2) + (upgrades[4].level * 0.3)), 1, 5),
                    maxValue = 5
                },
            }

            SendDuiMessage(Duis[vehicleIndexString].duiObject, json.encode({
                action = "setUpgrades",
                data = upgrades
            }))

            SendDuiMessage(Duis[vehicleIndexString].duiObject, json.encode({
                action = "setPerformanceStats",
                data = performanceStats
            }))

        end

        Wait(sleep)
    end
end