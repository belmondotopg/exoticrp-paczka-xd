Prison = nil

PrisonInteractions = {}
PrisonSirens = {}

local CheckBreakout = true
local LocalPlayer = LocalPlayer
local prisonBlips = {}

local function addBlips()
    if prisonBlips[1] ~= nil then
        for i=1, #prisonBlips, 1 do
            RemoveBlip(prisonBlips[i])
        end

        prisonBlips = {}
    end

    local blip = AddBlipForCoord(1773.9653, 2493.1362, 45.7408)
    SetBlipSprite (blip, 365)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.9)
    SetBlipColour (blip, 42)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Bolingbroke - Sprzątanie")
    EndTextCommandSetBlipName(blip)
    table.insert(prisonBlips, blip)

    Citizen.Wait(500)

    blip = AddBlipForCoord(1750.0331, 2479.8518, 45.7407)
    SetBlipSprite (blip, 365)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.9)
    SetBlipColour (blip, 35)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Bolingbroke - Siłownia")
    EndTextCommandSetBlipName(blip)
    table.insert(prisonBlips, blip)

    Citizen.Wait(500)

    blip = AddBlipForCoord(1787.3306, 2562.6624, 45.6731)
    SetBlipSprite (blip, 365)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.9)
    SetBlipColour (blip, 44)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Bolingbroke - Kuchnia")
    EndTextCommandSetBlipName(blip)
    table.insert(prisonBlips, blip)

    Citizen.Wait(500)

    blip = AddBlipForCoord(1779.5208, 2560.6865, 45.6731)
    SetBlipSprite (blip, 59)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 0.7)
    SetBlipColour (blip, 70)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Bolingbroke - Bufet")
    EndTextCommandSetBlipName(blip)
    table.insert(prisonBlips, blip)
end

local function removeBlips()
    if prisonBlips[1] ~= nil then
        for i=1, #prisonBlips, 1 do
            RemoveBlip(prisonBlips[i])
        end

        prisonBlips = {}
    end
end

function InitializeScript()
    for k,v in pairs(Config.Prisons) do 
        PrisonInteractions[k] = {}
        if v.blip then 
            CreateBlip(v.blip)
        end
    end
end

function TeleportHospital()
    if not Prison then return end
    CheckBreakout = false
    Wait(2000)
    local ped = PlayerPedId()
    local coords = Config.Prisons[Prison.index].hospital.coords
    local heading = Config.Prisons[Prison.index].hospital.heading
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    SetEntityHeading(ped, heading)
    Wait(2000)
    CheckBreakout = true
end

function ResetBreakout(index)
    local prison = Config.Prisons[index]
    if PrisonInteractions[index].breakout then 
        DeleteInteraction(PrisonInteractions[index].breakout)
    end
    PrisonInteractions[index].breakout = CreateInteraction({
        label = _L("interact_breakout"),
        coords = prison.breakout.start.coords,
        heading = prison.breakout.start.heading
    }, function(selected)
        ServerCallback("esx_prisons:canBreakout", function(result) 
            if not result then return end
            if Config.Breakout.process(prison.breakout.start) then
                ShowNotification(_L("breakout_success"))
                TriggerServerEvent("esx_prisons:startBreakout", index)
            else
                ShowNotification(_L("breakout_fail"))
            end
        end, index)
    end)
end

function GetClosestPrison() 
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closest
    for k,v in pairs(Config.Prisons) do 
        if (not closest or (#(coords-v.coords) < closest.dist)) then
            closest = {index = k, dist = #(coords-v.coords) }
        end
    end 
    if closest then 
        return closest.index
    end
end 

RegisterNetEvent("esx_prisons:startBreakout", function(index)
    local prison = Config.Prisons[index]
    DeleteInteraction(PrisonInteractions[index].breakout)
    PrisonInteractions[index].breakout = CreateInteraction({
        label = _L("interact_active_breakout"),
        coords = prison.breakout.start.coords,
        heading = prison.breakout.start.heading,
        model = Config.Breakout.model
    }, function(selected)
        ServerCallback("esx_prisons:enterBreakoutPoint", function(result) 
            if not result then return end
            local coords = prison.breakout.enter.coords
            local heading = prison.breakout.enter.heading
            TriggerServerEvent("esx_prisons:breakout")
            TriggerEvent("esx_prisons:leavePrison")
            WarpPlayer(coords, heading)
            local interact = CreateInteraction({
                label = _L("interact_exit_breakout"),
                coords = prison.breakout.leave.coords,
                heading = prison.breakout.leave.heading,
                model = Config.Breakout.model
            }, function(selected)
                ServerCallback("esx_prisons:enterBreakoutPoint", function(result) 
                    if not result then return end
                    local coords = prison.breakout.finish.coords
                    local heading = prison.breakout.finish.heading
                    WarpPlayer(coords, heading)
                    DeleteInteraction(interact)
                end, index, "finish")
            end)
        end, index, "enter")
    end)
end)

RegisterNetEvent("esx_prisons:stopBreakout", function(index)
    ResetBreakout(index)
end)

RegisterNetEvent("esx_prisons:jailPlayer", function(data)
    Prison = data
    local prison = Config.Prisons[data.index]
    local cell = prison.cells[math.random(1, #prison.cells)]
    local coords = cell.coords
    local heading = cell.heading

    WarpPlayer(coords, heading, function()
        ToggleOutfit(true)
    end)

    TriggerEvent("esx_prisons:enterPrison")

    addBlips()

    if IsPedCuffed(PlayerPedId()) then
        TriggerEvent('esx_police:HandcuffOnPlayer', PlayerPedId())
        TriggerEvent('esx_police:unrestPlayerHandcuffs')
    end

    Wait(2000)
    CreateThread(function()
        local coords = prison.coords
        while Prison and Prison.index == data.index do 
            RemoveAllPedWeapons(PlayerPedId(), true)
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                ClearPedTasks(PlayerPedId())
            end

            ClearAreaOfPeds(prison.coords.x, prison.coords.y, prison.coords.z, 400.0, 1)

            if CheckBreakout then
                if Config.EnableSneakout then 
                    local pcoords = GetEntityCoords(PlayerPedId())
                    if #(coords - pcoords) > prison.radius then 
                        TriggerServerEvent("esx_prisons:breakout")
                        TriggerEvent("esx_prisons:leavePrison")
                        break
                    end
                else
                    local pcoords = GetEntityCoords(PlayerPedId())
                    if #(coords - pcoords) > prison.radius then
                        ShowNotification(_L("cant_sneakout"))
                        SetEntityCoords(PlayerPedId(), 1767.6052, 2501.1599, 44.7407)
                        SetEntityHeading(PlayerPedId(), 207.1)
                        ToggleOutfit(true)
                    end
                end
            end
            Wait(1500)
        end
    end)
end)

RegisterNetEvent("esx_prisons:unjailPlayer", function(data)
    removeBlips()
    TriggerEvent("esx_prisons:leavePrison")
    local prison = Config.Prisons[data.index]
    local coords = prison.release.coords
    local heading = prison.release.heading
    WarpPlayer(coords, heading, function()
        ToggleOutfit(false)
    end)
end)

RegisterNetEvent("esx_prisons:enterPrison", function()
    local index = Prison.index
    local prison = Config.Prisons[index]
    ResetBreakout(index)
end)

RegisterNetEvent("esx_prisons:leavePrison", function()
    Prison = nil
end)

RegisterNetEvent("esx_prisons:startSiren", function(index)
    if PrisonSirens[index] then return end
    PrisonSirens[index] = true
    local prison = Config.Prisons[index]
    SendNUIMessage({
        type = "startSiren"
    })
    CreateThread(function()
        local maxDist = prison.radius * 2
        while PrisonSirens[index] do 
            if GetClosestPrison() == index then
                local pcoords = GetEntityCoords(PlayerPedId())
                local dist = #(prison.coords - pcoords)
                local factor = 1.0 - (dist / maxDist)
                if factor < 0 then
                    factor = 0
                end
                SendNUIMessage({
                    type = "setVolume",
                    value = factor
                })
            end
            Wait(1500)
        end
        SendNUIMessage({
            type = "endSiren"
        })
    end)
end)

RegisterNetEvent("esx_prisons:stopSiren", function(index)
    PrisonSirens[index] = nil
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    Wait(1000)
    TriggerServerEvent("esx_prisons:initializePlayer")
end)

CreateThread(function()
    InitializeScript()
end)

local function drawText(text)
	SetTextScale(0.28, 0.28)
	SetTextFont(0)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 55)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(0.5, 0.02)
end

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(200)
    end

    while not LocalPlayer.state.IsJailed do
        Citizen.Wait(150)
    end

	while true do
        Citizen.Wait(0)
		if LocalPlayer.state.IsJailed > 0 then
			drawText("Pozostało ~r~"..ESX.Round(LocalPlayer.state.IsJailed).. " ~w~miesięcy do zwolnienia")
		else
			Citizen.Wait(1000)
		end
	end
end)