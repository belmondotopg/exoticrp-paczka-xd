local esx_hud = exports.esx_hud
local libCache = lib.onCache
local cachePed = cache.ped

libCache('ped', function(ped)
    cachePed = ped
end)

local floorNames = {
    ["-1"] = "Piętro -1",
    ["0"] = "Parter 0",
    ["1"] = "Piętro 1",
    ["2"] = "Piętro 2",
    ["3"] = "Piętro 3",
    ["4"] = "Piętro 4",
    ["5"] = "Piętro 5",
}

local allowedJobs = {
    police = true,
    sheriff = true,
    ambulance = true,
    doj = true,
}

local elevatorConfig = {
    ["Komenda 1"] = {
        ["-1"] = {
            name = "Garaż",
            target = vec4(-1096.1810302734, -850.82629394531, 5.06, 48.177532196045),
        },
        ["1"] = {
            name = "Recepcja",
            target = vec4(-1096.1810302734, -850.82629394531, 19.311557769775, 48.177532196045),
        },
        ["2"] = {
            name = "Lobby",
            target = vec4(-1096.1573486328, -850.85388183594, 26.831434249878, 35.370861053467),
        },
        ["3"] = {
            name = "Biura operacyjne",
            target = vec4(-1096.125, -850.79730224609, 30.949203491211, 35.78849029541),
        },
        ["4"] = {
            name = "Biuro szefa",
            target = vec4(-1096.1276855469, -850.81927490234, 34.279670715332, 41.7317237854),
        },
        ["5"] = {
            name = "Lądowisko",
            target = vec4(-1096.1276855469, -850.81927490234, 37.928512573242, 41.494827270508),
        },
    },
    ["Komenda 2"] = {
        ["-1"] = {
            name = "Garaż",
            target = vec4(-1066.0505371094, -833.58410644531, 5.0610971450806, 36.725254058838),
        },
        ["0"] = {
            name = "Cele, zbrojownia, szatnia",
            target = vec4(-1066.0505371094, -833.58422851562, 10.951229095459, 32.695411682129),
        },
        ["1"] = {
            name = "Recepcja",
            target = vec4(-1066.0598144531, -833.57995605469, 19.312133789062, 47.676929473877),
        },
        ["2"] = {
            name = "Lobby",
            target = vec4(-1066.1376953125, -833.77655029297, 23.070775985718, 32.159683227539),
        },
        ["3"] = {
            name = "Biura operacyjne",
            target = vec4(-1065.95703125, -833.81634521484, 26.831750869751, 36.384689331055),
        },
    },
    ["Szpital"] = {
        ["0"] = {
            name = "Parter",
            target = vec4(1140.9836425781, -1567.8767089844, 35.032955169678, 1.6878616809845),
        },
        ["1"] = {
            name = "Piętro 1",
            target = vec4(1140.8735351562, -1568.017578125, 39.503662109375, 358.45916748047),
        },
    }
}

local isTakingElev = false

local function gotoFloor(floorNumber, elevatorName, currentFloor)
    if isTakingElev then return end

    local elevator = elevatorConfig[elevatorName]
    if not elevator then
        ESX.ShowNotification('Nieprawidłowa nazwa windy!', 'error')
        return
    end

    local floorStr = tostring(floorNumber)
    local floorData = elevator[floorStr]
    if not floorData then
        ESX.ShowNotification('Nieprawidłowe piętro!', 'error')
        return
    end

    if floorStr == tostring(currentFloor) then
        ESX.ShowNotification('Jesteś już na tym piętrze!')
        return
    end

    isTakingElev = true
    PlaySoundFrontend(-1, "BUTTON", "MP_PROPERTIES_ELEVATOR_DOORS", true)

    if esx_hud:progressBar({
        duration = 3,
        label = 'Trwa wzywanie windy...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
    }) then
        DoScreenFadeOut(500)
        PlaySoundFrontend(-1, "OPENING", "MP_PROPERTIES_ELEVATOR_DOORS", true)
        Citizen.Wait(1500)

        local targetCoords = floorData.target
        SetEntityCoords(cachePed, targetCoords.x, targetCoords.y, targetCoords.z - 1)
        SetEntityHeading(cachePed, targetCoords.w)

        ESX.ShowNotification('Winda dojechała do celu!')
        PlaySoundFrontend(-1, "CLOSING", "MP_PROPERTIES_ELEVATOR_DOORS", true)
        DoScreenFadeIn(500)
    else
        ESX.ShowNotification('Anulowano wzywanie windy.')
    end
    isTakingElev = false
end

local function openElevatorMenu(elevatorName, currentFloor)
    local elevator = elevatorConfig[elevatorName]
    if not elevator then
        ESX.ShowNotification('Błąd: Nieprawidłowa nazwa windy!')
        return
    end

    local sortedFloors = {}
    for floor in pairs(elevator) do
        table.insert(sortedFloors, tonumber(floor))
    end
    table.sort(sortedFloors)

    local currentFloorNum = tonumber(currentFloor) or 0
    local floorOptions = {}

    for _, floorNum in ipairs(sortedFloors) do
        local floorStr = tostring(floorNum)
        if floorStr ~= tostring(currentFloor) then
            local floorData = elevator[floorStr]
            local floorLabel = floorData.name or floorNames[floorStr] or ("Piętro " .. floorStr)
            local icon = 'fa-solid fa-elevator'
            if floorNum > currentFloorNum then
                icon = 'fa-solid fa-arrow-up'
            elseif floorNum < currentFloorNum then
                icon = 'fa-solid fa-arrow-down'
            end

            table.insert(floorOptions, {
                title = floorLabel,
                description = 'Wezwij windę na ' .. floorLabel:lower(),
                icon = icon,
                onSelect = function()
                    gotoFloor(floorStr, elevatorName, currentFloor)
                end
            })
        end
    end

    if #floorOptions == 0 then
        ESX.ShowNotification('Brak dostępnych pięter!')
        return
    end

    local displayName = elevatorName:gsub("^%l", string.upper)
    local menuId = 'elevator_menu_' .. elevatorName .. '_' .. currentFloor

    lib.registerContext({
        id = menuId,
        title = 'Winda - ' .. displayName,
        options = floorOptions
    })

    lib.showContext(menuId)
end

local function canUseElevator()
    if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
        return false
    end
    return allowedJobs[ESX.PlayerData.job.name] == true
end

CreateThread(function()
    local showingNotification = false
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(cachePed)
        local shouldShowNotification = false

        for elevatorName, elevator in pairs(elevatorConfig) do
            for floorStr, floorData in pairs(elevator) do
                local coords = floorData.target
                local distance = #(playerCoords - vec3(coords.x, coords.y, coords.z))

                if distance < 20.0 then
                    sleep = 0
                    ESX.DrawMarker(coords)
                    
                    if distance < 2.0 and canUseElevator() then
                        shouldShowNotification = true
                        if not showingNotification then
                            exports["esx_hud"]:helpNotification('Naciśnij', 'E', 'aby wezwać windę')
                            showingNotification = true
                        end
                        if IsControlJustReleased(0, 38) then
                            openElevatorMenu(elevatorName, floorStr)
                            exports["esx_hud"]:hideHelpNotification()
                            showingNotification = false
                        end
                    end
                end
            end
        end

        if showingNotification and not shouldShowNotification then
            exports["esx_hud"]:hideHelpNotification()
            showingNotification = false
        end

        Wait(sleep)
    end
end)