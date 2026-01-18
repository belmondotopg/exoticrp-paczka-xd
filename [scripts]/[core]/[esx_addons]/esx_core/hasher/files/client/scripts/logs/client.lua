local Citizen = Citizen
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler

local SetTextScale = SetTextScale
local SetTextFont = SetTextFont
local SetTextColour = SetTextColour
local SetTextProportional = SetTextProportional
local SetTextCentre = SetTextCentre
local SetTextEntry = SetTextEntry
local AddTextComponentString = AddTextComponentString
local World3dToScreen2d = World3dToScreen2d
local DrawText = DrawText
local GetGameplayCamCoords = GetGameplayCamCoords
local World3dToScreen2d = World3dToScreen2d

local function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.25, 0.25)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(vec3(x,y,z), 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
    DrawText(0.5, 0.02)
end

local function Display(id, crds, name, ssn, ambulance, reason)
    local displaying = true
    local text = nil

    Citizen.CreateThread(function()
        Citizen.Wait(30000)
        displaying = false
    end)

    if ambulance then
        text = "Gracz przeteleportował się na szpital\nID: ["..id.."] SSN: ["..ssn.."] ["..name.."]"
    else
        text = "Gracz opuścił rozgrywkę\nID: ["..id.."] SSN: ["..ssn.."] ["..name.."]\n["..reason.."]"
    end
	
    Citizen.CreateThread(function()
        while displaying do
			Citizen.Wait(1)
            if #(crds - cache.coords) < 15.0 then
                DrawText3D(crds.x, crds.y, crds.z, text)
            else
                Citizen.Wait(1000)
            end
        end
    end)
end

RegisterNetEvent("esx_core:disconnectLogs")
AddEventHandler("esx_core:disconnectLogs", function(id, crds, name, ssn, ambulance, reason)
    if ambulance == nil then ambulance = false end
    Display(id, crds, name, ssn, ambulance, reason)
end)