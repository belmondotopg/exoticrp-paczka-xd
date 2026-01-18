LocalPlayer.state:set('insideMagazine', false, true)
LocalPlayer.state:set('isPlayerGymDelivering', false, true)

local ox_target = exports.ox_target
local Blips = {}
Mission = {
    vehicle = nil,
    targetIds = {},
    deliveredCount = 0,
    totalBoxes = 0,
    loadedCount = 0,
    missionText = nil,
    inAnimation = nil,
    gym_name = nil,
    props = {
        list = {
            vector4(851.6216, -3001.2048, -48.9998, 31.0591),
        },
        boxModel = `prop_cs_cardbox_01`,
        carryThread = nil,
        markerThread = nil,
        alreadySpawned = false,
        carrying = false,
        carryingBox = nil,
        boxes = {},
        boxState = {},
        ready = false,
        vehicleTargetActive = false,
    }
}

local function removeVehicleLoadTarget()
    if not Mission.props.vehicleTargetActive then return end
    
    if Mission.vehicle and DoesEntityExist(Mission.vehicle) then
        local netId = NetworkGetNetworkIdFromEntity(Mission.vehicle)
        local isNetworked = NetworkGetEntityIsNetworked(Mission.vehicle)
        
        if isNetworked and netId then
            ox_target:removeEntity(netId, 'gym_load_box')
        else
            ox_target:removeLocalEntity(Mission.vehicle, 'gym_load_box')
        end
    end
    
    Mission.props.vehicleTargetActive = false
end

local function MissionText(text, clear)
    if clear or not text or text == "" then
        Mission.missionText = nil
        return
    end

    Mission.missionText = tostring(text):sub(1, 240)
end

function Mission:ClearBlips()
    if #Blips > 0 then
        for i = 1, #Blips do
            RemoveBlip(Blips[i])
        end
        Blips = {}
    end
end

function Mission:Reset()
    if self and self.ClearBlips then self:ClearBlips() end
    if self and self.RemoveAllProps then self:RemoveAllProps() end

    removeVehicleLoadTarget()

    if self and self.vehicle and DoesEntityExist(self.vehicle) then
        SetEntityAsMissionEntity(self.vehicle, true, true)
        DeleteVehicle(self.vehicle)
    end

    if self and self.targetIds and #self.targetIds > 0 then
        for i = 1, #self.targetIds do
            ox_target:removeZone(self.targetIds[i])
        end
    end

    local keptList = self.props and self.props.list or {}
    local keptModel = self.props and self.props.boxModel or `prop_cs_cardbox_01`

    self.vehicle = nil
    self.targetIds = {}
    self.deliveredCount = 0
    self.totalBoxes = 0
    self.loadedCount = 0
    self.missionText = nil
    self.inAnimation = nil
    self.gym_name = nil
    self.props = {
        list = keptList,
        boxModel = keptModel,
        carryThread = nil,
        markerThread = nil,
        alreadySpawned = false,
        carrying = false,
        carryingBox = nil,
        boxes = {},
        boxState = {},
        ready = false,
        vehicleTargetActive = false
    }

    MissionText('', true)
    LocalPlayer.state:set('isPlayerGymDelivering', false, true)
    LocalPlayer.state:set('insideMagazine', false, true)

    TriggerServerEvent('esx_gym/server/mission/resetDelivery')
end

function Mission:AddBlip(x, y, z, sprite, colour, title)
    local blip = AddBlipForCoord(x, y, z)

    SetBlipSprite (blip, sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.9)
    SetBlipColour (blip, colour)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(title)
    EndTextCommandSetBlipName(blip)

    Blips[#Blips+1] = blip

    return blip
end

local function loadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Citizen.Wait(0) end
end

local function loadModel(m)
    if not HasModelLoaded(m) then
        RequestModel(m)
        while not HasModelLoaded(m) do Citizen.Wait(0) end
    end
end

local function makeCamAt(pos, heading)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, pos.x, pos.y, pos.z)
    PointCamAtCoord(cam, pos.x, pos.y, pos.z)
    SetCamRot(cam, 0.0, 0.0, heading or 0.0, 2)
    RenderScriptCams(true, true, 0, false, true)
    SetFocusPosAndVel(pos.x, pos.y, pos.z, 0.0, 0.0, 0.0)
    return cam
end

local function ensureCarryLoop()
    if Mission.props.carryThread then return end
    Mission.props.carryThread = true
    Citizen.CreateThread(function()
        local dict, name = 'anim@heists@box_carry@', 'idle'
        loadAnim(dict)
        while Mission.props.carrying do
            local ped = PlayerPedId()
            local box = Mission.props.carryingBox
            if not DoesEntityExist(box) then
                Mission.props.carrying = false
                break
            end
            if not IsEntityAttachedToEntity(box, ped) then
                AttachEntityToEntity(box, ped, GetPedBoneIndex(ped, 28422), 0.0, -0.05, -0.25, 0.0, 90.0, 90.0, false, false, false, false, 2, true)
            end
            if not IsEntityPlayingAnim(ped, dict, name, 3) and not IsPedRagdoll(ped) then
                TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 8.0, -8.0, -1, 50, 0.0, false, false, false)
            end
            SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
            SetPedCanSwitchWeapon(ped, false)
            SetEnableHandcuffs(ped, true)
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 23, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 45, true)
            DisableControlAction(0, 200, true)
            DisableControlAction(0, 37, true)
            DisableControlAction(0, 16, true)
            DisableControlAction(0, 17, true)
            DisableControlAction(0, 182, true)
            DisableControlAction(0, 288, true)
            DisableControlAction(0, 289, true)
            DisableControlAction(0, 170, true)
            DisableControlAction(0, 38, true)
            Citizen.Wait(0)
        end
        local ped = PlayerPedId()
        ClearPedTasks(ped)
        SetEnableHandcuffs(ped, false)
        SetPedCanSwitchWeapon(ped, true)
        Mission.props.carryThread = nil
    end)
end

local function tryLoadToVehicle(boxEntity)
    if not Mission.props.carrying or Mission.props.carryingBox ~= boxEntity then return end
    if not Mission.vehicle or not DoesEntityExist(Mission.vehicle) then return end

    MissionText('', true)

    SetVehicleDoorOpen(Mission.vehicle, 2, false)
    SetVehicleDoorOpen(Mission.vehicle, 3, false)
    
    Citizen.Wait(1000)

    DetachEntity(boxEntity, true, true)
    ox_target:removeLocalEntity(boxEntity)
    DeleteEntity(boxEntity)

    Mission.props.carrying = false
    Mission.props.carryingBox = nil

    removeVehicleLoadTarget()

    Citizen.Wait(1000)

    SetVehicleDoorShut(Mission.vehicle, 2, false)
    SetVehicleDoorShut(Mission.vehicle, 3, false)

    Mission.loadedCount = (Mission.loadedCount or 0) + 1
    if Mission.loadedCount >= (Mission.totalBoxes or 0) then
        Mission:FinishDelivery()
    end
end

local function findVehicleByPlate(plate)
    if not plate then return nil end
    local vehicles = ESX.Game.GetVehicles()
    for _, veh in ipairs(vehicles) do
        if DoesEntityExist(veh) and GetVehicleNumberPlateText(veh) == plate then
            return veh
        end
    end
    return nil
end

local function addVehicleLoadTarget(waitTime)
    if waitTime and waitTime > 0 then
        Citizen.Wait(waitTime)
    end
    
    if not Mission.vehicle or not DoesEntityExist(Mission.vehicle) then
        if Mission.plate then
            Mission.vehicle = findVehicleByPlate(Mission.plate)
        end
    end
    
    if not Mission.vehicle or not DoesEntityExist(Mission.vehicle) then
        return
    end
    
    if Mission.props.vehicleTargetActive then
        return
    end
    
    removeVehicleLoadTarget()
    Citizen.Wait(100)
    
    local netId = NetworkGetNetworkIdFromEntity(Mission.vehicle)
    local isNetworked = NetworkGetEntityIsNetworked(Mission.vehicle)
    
    local options = {
        {
            name = 'gym_load_box',
            icon = 'fa-solid fa-truck-ramp-box',
            label = 'Załaduj do auta',
            distance = 5.0,
            canInteract = function(entity, distance)
                if not Mission.vehicle or entity ~= Mission.vehicle then return false end
                if not DoesEntityExist(Mission.vehicle) then return false end
                if not Mission.props.carrying then return false end
                if not Mission.props.carryingBox or not DoesEntityExist(Mission.props.carryingBox) then return false end
                
                local ped = PlayerPedId()
                local vehicleCoords = GetEntityCoords(Mission.vehicle)
                local pedCoords = GetEntityCoords(ped)
                local distanceToVehicle = #(pedCoords - vehicleCoords)
                
                return distanceToVehicle <= 5.0 and distance <= 5.0
            end,
            onSelect = function()
                if Mission.props.carryingBox and DoesEntityExist(Mission.props.carryingBox) then
                    tryLoadToVehicle(Mission.props.carryingBox)
                end
            end
        }
    }
    
    if isNetworked and netId then
        ox_target:addEntity(netId, options)
    else
        ox_target:addLocalEntity(Mission.vehicle, options)
    end
    
    Mission.props.vehicleTargetActive = true
end

local function startCarrying(boxEntity)
    if Mission.props.carrying then return end
    local ped = PlayerPedId()
    FreezeEntityPosition(boxEntity, false)
    AttachEntityToEntity(boxEntity, ped, GetPedBoneIndex(ped, 28422), 0.0, -0.05, -0.25, 0.0, 90.0, 90.0, false, false, false, false, 2, true)
    loadAnim('anim@heists@box_carry@')
    TaskPlayAnim(ped, 'anim@heists@box_carry@', 'idle', 8.0, -8.0, -1, 50, 0.0, false, false, false)
    Mission.props.carrying = true
    Mission.props.carryingBox = boxEntity
    if Mission.props.boxState[boxEntity] then
        Mission.props.boxState[boxEntity].picked = true
    end
    
    if not Mission.vehicle or not DoesEntityExist(Mission.vehicle) then
        if Mission.plate then
            Mission.vehicle = findVehicleByPlate(Mission.plate)
        end
    end
    
    if Mission.vehicle and DoesEntityExist(Mission.vehicle) then
        Citizen.Wait(300)
        addVehicleLoadTarget()
    end
    
    ensureCarryLoop()
end

function Mission:CreateProp(model, coords)
    loadModel(model)

    local object = CreateObjectNoOffset(model, coords.x, coords.y, coords.z - 0.9, false, false, false)

    SetEntityHeading(object, coords.w)
    SetEntityCollision(object, true, true)
    FreezeEntityPosition(object, true)
    PlaceObjectOnGroundProperly(object)

    Mission.props.boxes[#Mission.props.boxes+1] = object
    Mission.props.boxState[object] = { picked = false }

    ox_target:addLocalEntity(object, {
        {
            icon = 'fa-solid fa-box',
            label = 'Podnieś paczkę',
            distance = 2.0,
            onSelect = function()
                if Mission.props.carrying then return end
                startCarrying(object)
            end,
            canInteract = function(entity)
                return entity == object and not Mission.props.carrying
            end
        }
    })
end

function Mission:BoxMarkers()
    if Mission.props.markerThread then return end
    Mission.props.markerThread = true

    Citizen.CreateThread(function()
        while Mission.props.ready do
            local t = GetGameTimer() / 1000.0
            local active = 0
            for _, obj in ipairs(Mission.props.boxes) do
                if DoesEntityExist(obj) then
                    local st = Mission.props.boxState[obj]
                    if st and not st.picked and Mission.props.carryingBox ~= obj then
                        local c = GetEntityCoords(obj)
                        local z = c.z + 0.7 + math.sin(t * 2.6) * 0.07
                        DrawMarker(2, c.x, c.y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.32, 0.32, 0.32, 255, 255, 255, 185, false, true, 2, false, nil, nil, false)
                        active = active + 1
                    end
                end
            end
            if active == 0 then
                if Mission.loadedCount >= (Mission.totalBoxes or 0) or not Mission.props.ready then break end
                Citizen.Wait(300)
            else
                Citizen.Wait(0)
            end
        end
        Mission.props.markerThread = nil
    end)
end

function Mission:SpawnBoxes()
    if not Mission.props.alreadySpawned then
        Mission.props.alreadySpawned = true

        for k, v in ipairs(Mission.props.list) do
            Mission:CreateProp(Mission.props.boxModel, v)
            Citizen.Wait(100)
        end

        Mission.totalBoxes = #Mission.props.list
        Mission.props.ready = true

        Mission:BoxMarkers()
    end
end

function Mission:MagazineAnimation(where, sceneCoords, camPos, camHeading)
    self.inAnimation = true

    TriggerEvent('esx_hud/hideHud', false)

    local playerPed = PlayerPedId()

    local dict, clip = "mp_doorbell", "player_enter_r_peda"
    loadAnim(dict)

    local scene = NetworkCreateSynchronisedScene(
        sceneCoords.x, sceneCoords.y, sceneCoords.z,
        0.0, 0.0, sceneCoords.w,
        2, false, false, 1.0, 0.45, 1.0
    )
    NetworkAddPedToSynchronisedScene(playerPed, scene, dict, clip, 2.0, -2.0, 0, 0, 0.0, 0)

    local cam = makeCamAt(camPos, camHeading)

    NetworkStartSynchronisedScene(scene)
    Citizen.Wait(500)

    DoScreenFadeOut(2000)
    Citizen.Wait(2500)

    if cam then
        DestroyCam(cam)
        RenderScriptCams(false, true, 0, true, true)
        ClearFocus()
        cam = nil
    end

    while IsScreenFadingOut() do Citizen.Wait(0) end

    if where == 'enter' then
        SetEntityCoordsNoOffset(playerPed, Config.Mission.magazine.inside.coords.x, Config.Mission.magazine.inside.coords.y, Config.Mission.magazine.inside.coords.z)
        SetEntityHeading(playerPed, Config.Mission.magazine.inside.coords.w)
        LocalPlayer.state:set('insideMagazine', true, true)

        MissionText('Zbierz oznaczone paczki i zapakuj je do pojazdu.', false)

        Mission:SpawnBoxes()
    else
        SetEntityCoordsNoOffset(playerPed, Config.Mission.magazine.entrance.coords.x, Config.Mission.magazine.entrance.coords.y, Config.Mission.magazine.entrance.coords.z)
        SetEntityHeading(playerPed, Config.Mission.magazine.entrance.coords.w)
        LocalPlayer.state:set('insideMagazine', false, true)
    end

    DoScreenFadeIn(1500)
    while IsScreenFadingIn() do Citizen.Wait(0) end

    if where == 'exit' then
        Citizen.CreateThread(function()
            Citizen.Wait(500)
            
            if not Mission.vehicle or not DoesEntityExist(Mission.vehicle) then
                if Mission.plate then
                    Mission.vehicle = findVehicleByPlate(Mission.plate)
                end
            end
            
            if Mission.props.carrying and Mission.vehicle and DoesEntityExist(Mission.vehicle) then
                addVehicleLoadTarget()
            end
        end)
    end

    TriggerEvent('esx_hud/hideHud', true)

    self.inAnimation = false
end

function Mission:FinishDelivery()
    Mission:ClearBlips()
    Mission:RemoveAllProps()

    removeVehicleLoadTarget()

    if Mission.targetIds and #Mission.targetIds > 0 then
        for i = 1, #Mission.targetIds do
            ox_target:removeZone(Mission.targetIds[i])
        end
    end

    Mission.targetIds = {}

    local blip = Mission:AddBlip(Config.Mission.magazine.deliverTo.coords.x, Config.Mission.magazine.deliverTo.coords.y, Config.Mission.magazine.deliverTo.coords.z, 286, 70, 'Punkt dostawy')

    SetBlipRoute(blip, true)
    MissionText('Udaj się do zaznaczonego punktu na mapie aby dostarczyć towar.', false)
    
    local playerPed = PlayerPedId()
    local deliverCoords = vec3(Config.Mission.magazine.deliverTo.coords.x, Config.Mission.magazine.deliverTo.coords.y, Config.Mission.magazine.deliverTo.coords.z)
    local sleep = 1000
    
    while #(GetEntityCoords(playerPed) - deliverCoords) > 5.0 do
        Citizen.Wait(sleep)
        local currentCar = GetVehiclePedIsIn(playerPed, false)
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - deliverCoords)
        
        if currentCar == Mission.vehicle and distance < 15.0 then
            sleep = 0
            DrawMarker(2, deliverCoords.x, deliverCoords.y, deliverCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.32, 0.32, 0.32, 255, 255, 255, 185, false, true, 2, false, nil, nil, false)
            
            if distance < 5.0 then
                TriggerServerEvent('esx_gym/server/mission/suppliesDelivered', Mission.gym_name)

                DoScreenFadeOut(1000)
                while IsScreenFadingOut() do
                    Citizen.Wait(0)
                end

                Mission:Reset()

                DoScreenFadeIn(1000)
                while IsScreenFadingIn() do
                    Citizen.Wait(0)
                end

                ESX.ShowNotification('Pomyślnie dostarczono towar!')
                break
            end
        else
            sleep = 1000
        end
    end
end

function Mission:AddTargets()
    Mission.targetIds[#Mission.targetIds + 1] = ox_target:addBoxZone({
        coords = vec3(849.8, -1938.0, 30.4),
        size = vec3(0.4, 1.2, 4.0),
        rotation = 356.0,
        debug = false,
        options = {
            {
                name = 'magazine/enter',
                icon = "fa-solid fa-door-closed",
                label = 'Wejdź',
                canInteract = function(entity, distance, coords, name)
                    if LocalPlayer.state.IsDead then return false end
                    if LocalPlayer.state.IsHandcuffed then return false end
                    if distance > 2.0 then return false end

                    return true
                end,
                onSelect = function ()
                    Mission:MagazineAnimation(
                        'enter',
                        vector4(849.0, -1939.3486, 30.2, 260.4280),
                        vector3(849.1837, -1934.1331, 30.4684),
                        146.8033
                    )
                end
            }
        }
    })

    Mission.targetIds[#Mission.targetIds + 1] = ox_target:addBoxZone({
        coords = vec3(845.0, -3004.95, -44.0),
        size = vec3(0.35, 1.35, 2.9),
        rotation = 0.0,
        debug = false,
        options = {
            {
                name = 'magazine/enter',
                icon = "fa-solid fa-door-closed",
                label = 'Wyjdź',
                canInteract = function(entity, distance, coords, name)
                    if LocalPlayer.state.IsDead then return false end
                    if LocalPlayer.state.IsHandcuffed then return false end
                    if distance > 2.0 then return false end

                    return true
                end,
                onSelect = function ()
                    Mission:MagazineAnimation(
                        'exit',
                        vector4(844.6988, -3005.9470, -44.4000, 274.4652),
                        vector3(844.6605, -3003.5266, -44.1015),
                        139.2890
                    )
                end
            }
        }
    })
end

function Mission:Start(gym_name)
    lib.callback('esx_gym/server/mission/canStartDelivery', false, function(can)
        if can then
            Mission.gym_name = gym_name
            local playerPed = PlayerPedId()

            SetEntityCoords(playerPed, Config.Mission.vehicle.spawn.x, Config.Mission.vehicle.spawn.y, Config.Mission.vehicle.spawn.z)

            DoScreenFadeOut(1000)

            while IsScreenFadingOut() do
                Citizen.Wait(0)
            end

            ESX.Game.SpawnVehicle(Config.Mission.vehicle.model, vec3(Config.Mission.vehicle.spawn.x, Config.Mission.vehicle.spawn.y, Config.Mission.vehicle.spawn.z), Config.Mission.vehicle.spawn.w, function(vehicle)
                SetVehicleDirtLevel(vehicle, 0)
                TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

                Mission.vehicle = vehicle
                Mission.plate = GetVehicleNumberPlateText(vehicle)
            end)

            DoScreenFadeIn(1000)

            while IsScreenFadingIn() do
                Citizen.Wait(0)
            end

            local blip = Mission:AddBlip(Config.Mission.magazine.entrance.coords.x, Config.Mission.magazine.entrance.coords.y, Config.Mission.magazine.entrance.coords.z, 286, 70, 'Magazyn suplementów')

            SetBlipRoute(blip, true)

            MissionText('Udaj się do zaznaczonego magazynu suplementów na mapie, zbierz towar i wróć z zapasami.', false)

            LocalPlayer.state:set('isPlayerGymDelivering', true, true)
            
            Citizen.CreateThread(function()
                local entranceCoords = vec3(Config.Mission.magazine.entrance.coords.x, Config.Mission.magazine.entrance.coords.y, Config.Mission.magazine.entrance.coords.z)
                local sleep = 1000
                while DoesEntityExist(Mission.vehicle) do
                    Citizen.Wait(sleep)
                    local distance = #(GetEntityCoords(playerPed) - entranceCoords)
                    if distance < 10.0 and not Mission.inAnimation then
                        sleep = 0
                        DrawMarker(2, entranceCoords.x, entranceCoords.y, entranceCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.32, 0.32, 0.32, 255, 255, 255, 185, false, true, 2, false, nil, nil, false)
                    else
                        sleep = 1000
                    end
                end
            end)

            Citizen.CreateThread(function()
                local insideCoords = vec3(Config.Mission.magazine.inside.coords.x, Config.Mission.magazine.inside.coords.y, Config.Mission.magazine.inside.coords.z)
                local sleep = 1000
                while DoesEntityExist(Mission.vehicle) do
                    Citizen.Wait(sleep)
                    local distance = #(GetEntityCoords(playerPed) - insideCoords)
                    if distance < 10.0 and not Mission.inAnimation then
                        sleep = 0
                        DrawMarker(2, insideCoords.x, insideCoords.y, insideCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.32, 0.32, 0.32, 255, 255, 255, 185, false, true, 2, false, nil, nil, false)
                    else
                        sleep = 1000
                    end
                end
            end)
            
            Citizen.CreateThread(function()
                local entranceCoords = vec3(Config.Mission.magazine.entrance.coords.x, Config.Mission.magazine.entrance.coords.y, Config.Mission.magazine.entrance.coords.z)
                while #(GetEntityCoords(playerPed) - entranceCoords) > 10.0 do
                    Citizen.Wait(250)
                    if GetVehiclePedIsIn(playerPed, false) == Mission.vehicle then
                        Mission:AddTargets()
                        break
                    end
                end
            end)    
        else
            ESX.ShowNotification('Nie możesz zacząć teraz misji uzupełnienia towaru, ponieważ wykonuje ją ktoś inny!')
        end
    end)
end

function Mission:RemoveAllProps()
    if self.props and self.props.boxes then
        for i = 1, #self.props.boxes do
            local obj = self.props.boxes[i]
            if DoesEntityExist(obj) then
                ox_target:removeLocalEntity(obj)
                DeleteEntity(obj)
            end
        end

        self.props.boxes = {}
        self.props.boxState = {}
        self.props.carrying = false
        self.props.carryingBox = nil
    end
end

Citizen.CreateThread(function ()
    if #Mission.targetIds > 0 then
        for i = 1, #Mission.targetIds do
            ox_target:removeZone(Mission.targetIds[i])
        end
    end
    
    Mission.targetIds = {}
end)

Citizen.CreateThread(function()
    while true do
        if Mission.missionText then
            Citizen.Wait(0)
            SetTextFont(4)
            SetTextScale(0.35, 0.35)
            SetTextColour(255, 255, 255, 255)
            SetTextOutline()
            SetTextCentre(true)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(Mission.missionText)
            EndTextCommandDisplayText(0.5, 0.90)
        else
            Citizen.Wait(2000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
        
        if LocalPlayer.state.isPlayerGymDelivering and Mission.props.carrying and not Mission.props.vehicleTargetActive then
            if not Mission.vehicle or not DoesEntityExist(Mission.vehicle) then
                if Mission.plate then
                    Mission.vehicle = findVehicleByPlate(Mission.plate)
                end
            end
            
            if Mission.vehicle and DoesEntityExist(Mission.vehicle) then
                addVehicleLoadTarget()
            end
        end
    end
end)

RegisterNetEvent('esx_gym/mission/abortMission', function ()
    if Mission.vehicle ~= nil and LocalPlayer.state.isPlayerGymDelivering then
        Mission:Reset()
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        Mission:Reset()
    end
end)

AddEventHandler('gameEventTriggered', function(event, args)
    local playerPed = PlayerPedId()
    local playerId = PlayerId()

    if event ~= "CEventNetworkEntityDamage" or GetEntityType(args[1]) ~= 1 or NetworkGetPlayerIndexFromPed(args[1]) ~= playerId then return end
    if not IsEntityDead(playerPed) then return end
    if not LocalPlayer.state.isPlayerGymDelivering then return end

    Mission:Reset()
end)