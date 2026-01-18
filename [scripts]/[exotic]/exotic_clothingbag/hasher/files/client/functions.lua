function Init()
    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(100)
    end

    PlayerData = ESX.GetPlayerData()

    exports.ox_target:addModel(Config.Prop, {
        {
            label = "Otwórz torbę",
            icon = "fa-solid fa-shirt",
            onSelect = OpenBag,
            canInteract = function(entity)
                return Entity(entity).state.owner ~= nil
            end
        },
        {
            label = "Podnieś torbę",
            icon = "fa-solid fa-hand",
            onSelect = TakeBag,
            canInteract = function(entity)
                return Entity(entity).state.owner == PlayerData.identifier
            end
        }
    })
end

function PlaceBag()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local forwardVector = GetEntityForwardVector(playerPed)
    local propCoords = playerCoords + forwardVector

    RequestModel(Config.Prop)
    RequestAnimDict(Config.PlaceAnimation.dict)

    while not HasModelLoaded(Config.Prop) or not HasAnimDictLoaded(Config.PlaceAnimation.dict) do
        Citizen.Wait(10)
    end

    TaskPlayAnim(playerPed, Config.PlaceAnimation.dict, Config.PlaceAnimation.anim, 8.0, 1.0, 2000, 50, 0.0, false, false,
        false)
    RemoveAnimDict(Config.PlaceAnimation.dict)

    local entity = CreateObject(Config.Prop, propCoords.x, propCoords.y, propCoords.z, true, false, false)

    PlaceObjectOnGroundOrObjectProperly(entity)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)

    SetModelAsNoLongerNeeded(Config.Prop)

    return NetworkGetNetworkIdFromEntity(entity)
end

function TakeBag(data)
    local entity = data.entity
    local state = Entity(entity).state

    if (state.owner ~= PlayerData.identifier) then
        return
    end

    RequestAnimDict(Config.TakeAnimation.dict)

    while not HasAnimDictLoaded(Config.TakeAnimation.dict) do
        Citizen.Wait(10)
    end

    TaskPlayAnim(PlayerPedId(), Config.TakeAnimation.dict, Config.TakeAnimation.anim, 8.0, 1.0, 2000, 50, 0.0, false,
        false, false)

    RemoveAnimDict(Config.TakeAnimation.dict)

    lib.callback.await('exotic_clothingbag:takeBag', false, NetworkGetNetworkIdFromEntity(entity))
end

function SwitchPrivacy(data, cb)
    local entity = CurrentBag
    local state = Entity(entity).state

    if (state.owner ~= PlayerData.identifier) then
        cb(false)
        return ESX.ShowNotification("~r~Nie możesz zmienić prywatności nie swojej torby.")
    end

    lib.callback.await('exotic_clothingbag:switchBagPrivacy', false, NetworkGetNetworkIdFromEntity(entity))
    cb(true)
end

function CreatePedToNui()
    CreateThread(function()
        local ped = PlayerPedId()
        local heading = GetEntityHeading(ped)
        local coords = GetEntityCoords(ped)
        local forwardVector = GetEntityForwardVector(ped)
        local camCoords = coords + forwardVector * 2

        local positionBuffer = {}
        local bufferSize = 5

        Cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

        SetCamActive(Cam, true)
        SetCamCoord(Cam, camCoords.x, camCoords.y, camCoords.z)
        SetCamRot(Cam, 15.0, 0.0, heading + 180.0, 0.0)
        PointCamAtCoord(Cam, coords.x, coords.y, coords.z + 0.1)
        RenderScriptCams(true, true, 1000, true, true)

        ClonedPed = ClonePed(ped, false, false, false)
        SetEntityCoords(ClonedPed, coords.x, coords.y, coords.z - 10, true, false, false, false)
        SetEntityHeading(ClonedPed, heading + 40)
        FreezeEntityPosition(ClonedPed, true)
        SetEntityInvincible(ClonedPed, true)
        SetBlockingOfNonTemporaryEvents(ClonedPed, true)
        ClearPedTasksImmediately(ClonedPed)
        SetPedCanRagdoll(ClonedPed, false)
        SetPedDiesWhenInjured(ClonedPed, false)
        SetPedCanBeTargetted(ClonedPed, false)

        Citizen.Wait(1000)

        local world, normal = GetWorldCoordFromScreenCoord(0.15, 0.75)
        local depth = 3.5
        local target = world + normal * depth

        table.insert(positionBuffer, target)
        if #positionBuffer > bufferSize then
            table.remove(positionBuffer, 1)
        end

        local averagedTarget = vector3(0, 0, 0)
        for _, position in ipairs(positionBuffer) do
            averagedTarget = averagedTarget + position
        end
        averagedTarget = averagedTarget / #positionBuffer

        SetEntityCoords(ClonedPed, averagedTarget.x, averagedTarget.y, averagedTarget.z, false, false, false, true)
    end)
end

function OpenBag(data)
    local state = Entity(data.entity).state

    if (state.owner ~= PlayerData.identifier and state.private) then
        return ESX.ShowNotification("~r~Nie możesz otworzyć tej torby.")
    end

    local outfits = lib.callback.await('exotic_clothingbag:openBag', false, NetworkGetNetworkIdFromEntity(data.entity))

    if not outfits then return end

    local ped = PlayerPedId()

    RequestAnimDict(Config.OpenBagAnimation.dict)

    while not HasAnimDictLoaded(Config.OpenBagAnimation.dict) do
        Citizen.Wait(10)
    end

    RequestAnimDict(Config.IdleAnimation.dict)

    while not HasAnimDictLoaded(Config.IdleAnimation.dict) do
        Citizen.Wait(10)
    end

    TaskPlayAnim(ped, Config.OpenBagAnimation.dict, Config.OpenBagAnimation.anim, 8.0, 1.0, 1000, 50, 0.0,
        false,
        false, false)

    RemoveAnimDict(Config.OpenBagAnimation.dict)

    Citizen.CreateThread(function()
        Citizen.Wait(900)

        TaskPlayAnim(ped, Config.IdleAnimation.dict, Config.IdleAnimation.anim, 4.0, 1.0, -1, 1, 0.0, false, false,
            false)
    end)

    CreatePedToNui()
    CurrentBag = data.entity

    SendNUIMessage({
        action = "setData",
        data = {
            outfits = outfits,
            limit = Config.OutfitsLimit
        }
    })
    SendNUIMessage({
        action = "setVisible",
        data = {
            visible = true
        }
    })
    SetNuiFocus(true, true)
end

function CloseNui(data, cb)
    CurrentBag = 0

    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "setVisible",
        data = {
            visible = false
        }
    })

    ClearPedTasksImmediately(PlayerPedId())

    if ClonedPed and DoesEntityExist(ClonedPed) then
        DeleteEntity(ClonedPed)
        ClonedPed = nil
    end

    if Cam and DoesCamExist(Cam) then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(Cam, false)
        Cam = nil
    end

    if cb ~= nil then
        cb(true)
    end
end

function GetClothes(skin)
    local newOutfit = {
        props = {

        },
        components = {

        }
    }

    for i, v in pairs(skin.components) do
        for _, value in pairs(Config.DressUpVariants["all"].components) do
            if v.component_id == value then
                newOutfit.components[#newOutfit.components + 1] = v
            end
        end
    end

    for i, v in pairs(skin.props) do
        for _, value in pairs(Config.DressUpVariants["all"].props) do
            if v.prop_id == value then
                newOutfit.props[#newOutfit.props + 1] = v
            end
        end
    end

    return newOutfit
end

function CreateNewOutfit(data, cb)
    local name = data.name
    local skin = exports["skinchanger"]:GetSkin()
    local outfit = GetClothes(skin)

    if CurrentBag == 0 then
        cb(false)
        return ESX.ShowNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    local outfits = lib.callback.await('exotic_clothingbag:createNewOutfit', false,
        NetworkGetNetworkIdFromEntity(CurrentBag), name, outfit, skin.sex == 0 and "M" or "F")

    cb(true)

    if not outfits then return end

    SendNUIMessage({
        action = "setData",
        data = {
            outfits = outfits,
            limit = Config.OutfitsLimit
        }
    })
end

function DeleteOutfit(data, cb)
    local id = data.id

    if CurrentBag == 0 then
        cb(false)
        return ESX.ShowNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    local outfits = lib.callback.await('exotic_clothingbag:deleteOutfit', false,
        NetworkGetNetworkIdFromEntity(CurrentBag), id)

    cb(true)

    if not outfits then return end

    SendNUIMessage({
        action = "setData",
        data = {
            outfits = outfits,
            limit = Config.OutfitsLimit
        }
    })
end

function DressUp(data, cb)
    local id = data.id
    local variant = data.variant

    if not Config.DressUpVariants[variant] then
        cb(false)
        return ESX.ShowNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    if CurrentBag == 0 then
        cb(false)
        return ESX.ShowNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    local playerSkin = exports["skinchanger"]:GetSkin()
    local sex = playerSkin.sex == 0 and "M" or "F"
    local outfit = lib.callback.await('exotic_clothingbag:dressUp', false, NetworkGetNetworkIdFromEntity(CurrentBag), id, variant, sex)

    if not outfit then
        cb(false)
        return
    end

    exports["qf_skinmenu"]:setPedComponents(PlayerPedId(), outfit.components)
    exports["qf_skinmenu"]:setPedProps(PlayerPedId(), outfit.props)
    cb(true)
    CloseNui()
end

function PreviewOutfit(data, cb)
    local id = data.id
    local playerSkin = exports["skinchanger"]:GetSkin()
    local sex = playerSkin.sex == 0 and "M" or "F"

    if CurrentBag == 0 then
        cb(false)
        return ESX.ShowNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    local outfit = lib.callback.await('exotic_clothingbag:previewOutfit', false,
        NetworkGetNetworkIdFromEntity(CurrentBag), id, sex)

    if not outfit then
        cb(false)
        return
    end

    if not DoesEntityExist(ClonedPed) then
        cb(false)
        return
    end

    exports["qf_skinmenu"]:setPedComponents(ClonedPed, outfit.components)
    exports["qf_skinmenu"]:setPedProps(ClonedPed, outfit.props)

    cb(true)
end
