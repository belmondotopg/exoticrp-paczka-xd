local ESX = ESX
local Citizen = Citizen
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local TriggerServerEvent = TriggerServerEvent
local LocalPlayer = LocalPlayer
local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 75, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local DeleteEntity = DeleteEntity
local ClearPedSecondaryTask = ClearPedSecondaryTask
local GetPlayerServerId = GetPlayerServerId
local IsPedInAnyVehicle = IsPedInAnyVehicle
local IsPedRunning = IsPedRunning
local IsPedSprinting = IsPedSprinting
local GetEntityHeading = GetEntityHeading
local IsPauseMenuActive = IsPauseMenuActive
local GetGameTimer = GetGameTimer
local AttachEntityToEntity = AttachEntityToEntity
local CreateObject = CreateObject
local SetCurrentPedWeapon = SetCurrentPedWeapon
local TaskPlayAnim = TaskPlayAnim
local ClearPedTasks = ClearPedTasks
local ClearPedTasksImmediately = ClearPedTasksImmediately
local GetPedBoneIndex = GetPedBoneIndex
local GetHashKey = GetHashKey
local Wait = Wait
local CreateThread = CreateThread

local binds = nil
local binding = nil
local timer = nil
local allowed = false
local markerplayer = nil
local parkingwand, notes, pen, lopata, aparat, portfel, dowod, clipboard, scierka, telefon, telefon2, kawa, bouquet, teddy, karton, walizka, walizka2, walizka3, walizka4, wiertarka, toolbox, guitar, book, szampan, win, stickpropss, stickpropss2, plecakdokurwy

local function isBlocked()
	return LocalPlayer.state.IsHandcuffed or LocalPlayer.state.IsDead or LocalPlayer.state.Crosshair
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
	local job = ESX.PlayerData.job
	allowed = job and (job.name == 'police' or job.name == 'offpolice' or job.name == 'sheriff' or job.name == 'offsheriff')

	if not binds then
		Wait(1000)
		TriggerServerEvent('esx_animations:load')
	end
end)

CreateThread(function()
	if not binds then
		Wait(1000)
		TriggerServerEvent('esx_animations:load')
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	allowed = job and (job.name == 'police' or job.name == 'offpolice' or job.name == 'sheriff' or job.name == 'offsheriff')
end)

RegisterNetEvent('esx_animations:bind')
AddEventHandler('esx_animations:bind', function(list)
	binds = list
end)

local libCache = lib.onCache
local cachePed = cache.ped
local cacheCoords = cache.coords
local cachePlayerId = cache.playerId
local cacheVehicle = cache.vehicle

libCache('ped', function(ped)
	cachePed = ped
end)

libCache('coords', function(coords)
	cacheCoords = coords
end)

libCache('playerId', function(playerId)
	cachePlayerId = playerId
end)

libCache('vehicle', function(vehicle)
	cacheVehicle = vehicle
	ClearPedSecondaryTask(cachePed)
	ClearAnimationProps()
end)

local ConfigPed = {
	Active = false,
	Locked = false,
	Alive = false,
	Available = false,
}

function ClearAnimationProps()
	DeleteEntity(parkingwand)
	DeleteEntity(notes)
	DeleteEntity(lopata)
	DeleteEntity(pen)
	DeleteEntity(aparat)
	DeleteEntity(dowod)
	DeleteEntity(clipboard)
	DeleteEntity(scierka)
	DeleteEntity(telefon2)
	DeleteEntity(portfel)
	DeleteEntity(kawa)
	DeleteEntity(karton)
	DeleteEntity(walizka)
	DeleteEntity(walizka2)
	DeleteEntity(walizka3)
	DeleteEntity(walizka4)
	DeleteEntity(wiertarka)
	DeleteEntity(toolbox)
	DeleteEntity(teddy)
	DeleteEntity(bouquet)
	DeleteEntity(guitar)
	DeleteEntity(book)
	DeleteEntity(szampan)
	DeleteEntity(win)
	DeleteEntity(stickpropss)
	DeleteEntity(stickpropss2)
	DeleteEntity(plecakdokurwy)
end

local function ClearPortfelProp()
	if DoesEntityExist(dowod) then
		DeleteObject(dowod)
		SetEntityAsNoLongerNeeded(dowod)
	end
	if DoesEntityExist(portfel) then
		DeleteObject(portfel)
		SetEntityAsNoLongerNeeded(portfel)
	end
end

local function kierowanieruchemprop()
	parkingwand = CreateObject(GetHashKey('prop_parking_wand_01'), cacheCoords, true)
	AttachEntityToEntity(parkingwand, cachePed, GetPedBoneIndex(cachePed, 0xDEAD), 0.1, 0.0, -0.03, 65.0, 100.0, 130.0, 1, 0, 0, 0, 0, 1)
end

local function notesprop()
	notes = CreateObject(GetHashKey('prop_notepad_02'), cacheCoords, true)
	AttachEntityToEntity(notes, cachePed, GetPedBoneIndex(cachePed, 0x49D9), 0.15, 0.03, 0.0, -42.0, 0.0, 0.0, 1, 0, 0, 0, 0, 1)
	pen = CreateObject(GetHashKey('prop_pencil_01'), cacheCoords, true)
	AttachEntityToEntity(pen, cachePed, GetPedBoneIndex(cachePed, 0xFA10), 0.04, -0.02, 0.01, 90.0, -125.0, -180.0, 1, 0, 0, 0, 0, 1)
end

local function lopataprop()
	lopata = CreateObject(GetHashKey('prop_ld_shovel'), cacheCoords, true, false, false)
	AttachEntityToEntity(lopata, cachePed, GetPedBoneIndex(cachePed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1)
end

local function aparatprop()
	aparat = CreateObject(GetHashKey('prop_pap_camera_01'), cacheCoords, true)
	AttachEntityToEntity(aparat, cachePed, GetPedBoneIndex(cachePed, 0xE5F2), 0.1, -0.05, 0.0, -10.0, 50.0, 5.0, 1, 0, 0, 0, 0, 1)
end

local function portfeldowodprop()
	portfel = CreateObject(GetHashKey('prop_ld_wallet_01'), cacheCoords, true)
	AttachEntityToEntity(portfel, cachePed, GetPedBoneIndex(cachePed, 0x49D9), 0.17, 0.0, 0.019, -120.0, 0.0, 0.0, 1, 0, 0, 0, 0, 1)
	Wait(500)
	dowod = CreateObject(GetHashKey('prop_michael_sec_id'), cacheCoords, true)
	AttachEntityToEntity(dowod, cachePed, GetPedBoneIndex(cachePed, 0xDEAD), 0.150, 0.045, -0.015, 0.0, 0.0, 180.0, 1, 0, 0, 0, 0, 1)
	Wait(1300)
	ClearPortfelProp()
end

local function clipboardprop()
	clipboard = CreateObject(GetHashKey('p_amb_clipboard_01'), cacheCoords, true)
	AttachEntityToEntity(clipboard, cachePed, GetPedBoneIndex(cachePed, 0x8CBD), 0.1, 0.015, 0.12, 45.0, -130.0, 180.0, 1, 0, 0, 0, 0, 1)
end

local function scierkaprop()
	scierka = CreateObject(GetHashKey('prop_huf_rag_01'), cacheCoords, true)
	AttachEntityToEntity(scierka, cachePed, GetPedBoneIndex(cachePed, 0xDEAD), 0.16, 0.0, -0.040, 10.0, 0.0, -45.0, 1, 0, 0, 0, 0, 1)
end

local function telefonprop()
	telefon = CreateObject(GetHashKey('prop_amb_phone'), cacheCoords, true)
	AttachEntityToEntity(telefon, cachePed, GetPedBoneIndex(cachePed, 28422), -0.01, -0.005, 0.0, -10.0, 8.0, 0.0, 1, 0, 0, 0, 0, 1)
end

local function telefonprop2()
	telefon2 = CreateObject(GetHashKey('prop_amb_phone'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(telefon2, cachePed, GetPedBoneIndex(cachePed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
end

local function kawaprop()
	kawa = CreateObject(GetHashKey('p_amb_coffeecup_01'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(kawa, cachePed, GetPedBoneIndex(cachePed, 57005), 0.14, 0.015, -0.03, -80.0, 0.0, -20.0, 1, 1, 0, 1, 1, 1)
end

local function bouquetprop()
	bouquet = CreateObject(GetHashKey('prop_snow_flower_02'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(bouquet, cachePed, GetPedBoneIndex(cachePed, 24817), -0.29, 0.40, -0.02, -90.0, -90.0, 0.0, 1, 1, 0, 1, 1, 1)
end

local function teddyprop()
	teddy = CreateObject(GetHashKey('v_ilev_mr_rasberryclean'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(teddy, cachePed, GetPedBoneIndex(cachePed, 24817), -0.20, 0.46, -0.016, -180.0, -90.0, 0.0, 1, 1, 0, 1, 1, 1)
end

local function kartonprop()
	karton = CreateObject(GetHashKey('v_serv_abox_04'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(karton, cachePed, GetPedBoneIndex(cachePed, 28422), 0.0, -0.08, -0.17, 0, 0, 90.0, 1, 1, 0, 1, 1, 1)
end

local function walizkaprop()
	walizka = CreateObject(GetHashKey('prop_ld_case_01'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(walizka, cachePed, GetPedBoneIndex(cachePed, 57005), 0.13, 0.0, -0.02, -90.0, 0.0, 90.0, 1, 1, 0, 1, 1, 1)
end

local function walizkaprop2()
	walizka2 = CreateObject(GetHashKey('hei_p_attache_case_shut'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(walizka2, cachePed, GetPedBoneIndex(cachePed, 57005), 0.13, 0.0, 0.0, 0.0, 0.0, -90.0, 1, 1, 0, 1, 1, 1)
end

local function walizkaprop3()
	walizka3 = CreateObject(GetHashKey('prop_ld_suitcase_01'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(walizka3, cachePed, GetPedBoneIndex(cachePed, 57005), 0.36, 0.0, -0.02, -90.0, 0.0, 90.0, 1, 1, 0, 1, 1, 1)
end

local function walizkaprop4()
	walizka4 = CreateObject(GetHashKey('prop_suitcase_03'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(walizka4, cachePed, GetPedBoneIndex(cachePed, 57005), 0.36, -0.45, -0.05, -50.0, -60.0, 15.0, 1, 1, 0, 1, 1, 1)
end

local function wiertarkaprop()
	wiertarka = CreateObject(GetHashKey('prop_tool_drill'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(wiertarka, cachePed, GetPedBoneIndex(cachePed, 57005), 0.1, 0.04, -0.03, -90.0, 180.0, 0.0, 1, 1, 0, 1, 1, 1)
end

local function toolboxprop()
	toolbox = CreateObject(GetHashKey('prop_tool_box_04'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(toolbox, cachePed, GetPedBoneIndex(cachePed, 57005), 0.43, 0.0, -0.02, -90.0, 0.0, 90.0, 1, 1, 0, 1, 1, 1)
end

local function guitarprop()
	guitar = CreateObject(GetHashKey('prop_acc_guitar_01'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(guitar, cachePed, GetPedBoneIndex(cachePed, 24818), -0.1, 0.31, 0.1, 0.0, 20.0, 150.0, 1, 1, 0, 1, 1, 1)
end

local function bookprop()
	book = CreateObject(GetHashKey('prop_novel_01'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(book, cachePed, GetPedBoneIndex(cachePed, 6286), 0.15, 0.03, -0.065, 0.0, 180.0, 90.0, 1, 1, 0, 1, 1, 1)
end

local function szampanprop()
	szampan = CreateObject(GetHashKey('prop_drink_champ'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(szampan, cachePed, GetPedBoneIndex(cachePed, 18905), 0.10, -0.03, 0.03, -100.0, 0.0, -10.0, 1, 1, 0, 1, 1, 1)
end

local function wineprop()
	win = CreateObject(GetHashKey('prop_drink_redwine'), 0.10, -0.03, 0.03, -100.0, 0.0, -10.0)
	AttachEntityToEntity(win, cachePed, GetPedBoneIndex(cachePed, 18905), 0.10, -0.03, 0.03, -100.0, 0.0, -10.0, 1, 1, 0, 1, 1, 1)
end

local function stickprop()
	stickpropss = CreateObject(GetHashKey('ba_prop_battle_glowstick_01'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(stickpropss, cachePed, GetPedBoneIndex(cachePed, 28422), 0.0700, 0.1400, 0.0, -80.0, 20.0, -10.0, 1, 1, 0, 1, 1, 1)
end

local function stickprop2()
	stickpropss2 = CreateObject(GetHashKey('ba_prop_battle_glowstick_01'), 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(stickpropss2, cachePed, GetPedBoneIndex(cachePed, 60309), 0.0700, 0.1400, 0.0, -80.0, 20.0, -10.0, 1, 1, 0, 1, 1, 1)
end

local function plecakdokurwyy()
	plecakdokurwy = CreateObject(GetHashKey('p_michael_backpack_s'), 0.07, -0.11, -0.05, 0.0, 90.0, 175.0)
	AttachEntityToEntity(plecakdokurwy, cachePed, GetPedBoneIndex(cachePed, 24818), 0.07, -0.11, -0.05, 0.0, 90.0, 175.0, -10.0, 1, 1, 0, 1, 1, 1)
end

local function LoadDict(Dict)
	while not HasAnimDictLoaded(Dict) do
		Wait(0)
		RequestAnimDict(Dict)
	end
end

local function PlayAnim(Dict, Anim, Flag)
	if isBlocked() then return end
	LoadDict(Dict)
	TaskPlayAnim(cachePed, Dict, Anim, 8.0, -8.0, -1, Flag or 0, 0, false, false, false)
end

local function startWalkStyle(lib, anim)
	ESX.Streaming.RequestAnimSet(lib, function()
		SetPedMovementClipset(cachePed, anim, true)
	end)
end

local function startFaceExpression(anim)
	SetFacialIdleAnimOverride(cachePed, anim)
end

local function startAnim(lib, anim, loop, car)
	if isBlocked() then return end

	if cacheVehicle and car == 1 then
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
		end)
	elseif not cacheVehicle and car <= 1 then
		if anim ~= "biker_02_stickup_loop" and anim ~= "b_atm_mugging" then
			SetCurrentPedWeapon(cachePed, -1569615261, true)
		end
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
		end)
	elseif cacheVehicle and car == 2 then
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
		end)
	end
end

local function startAnim2(lib, anim, loop)
	if isBlocked() then return end
	if not cacheVehicle then
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
		end)
	end
end

local function startAnimAngle(lib, anim, loop)
	if isBlocked() then return end
	if not cacheVehicle then
		local he = GetEntityHeading(cachePed)
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnimAdvanced(cachePed, lib, anim, cacheCoords.x, cacheCoords.y, cacheCoords.z, 0, 0, he - 180, 8.0, 3.0, -1, loop, 0.0, 0, 0)
		end)
	end
end

local function startAnimAngle2(lib, anim, loop)
	if isBlocked() then return end
	if not cacheVehicle then
		local he = GetEntityHeading(cachePed)
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnimAdvanced(cachePed, lib, anim, cacheCoords.x, cacheCoords.y, cacheCoords.z, 0, 0, he - 90, 8.0, 3.0, -1, loop, 0.0, 0, 0)
		end)
	end
end

local function startAnimRozmowa(lib, anim, loop)
	if isBlocked() then return end
	if not cacheVehicle then
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, 33000, loop, 1, false, false, false)
		end)
	end
end

local function startAnimTabletka(lib, anim, loop)
	if isBlocked() then return end
	SetCurrentPedWeapon(cachePed, -1569615261, true)
	Wait(1)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, 3200, loop, -1, false, false, false)
	end)
end

local function startAnimSchowek(lib, anim, loop)
	if isBlocked() then return end
	if cacheVehicle then
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, 5000, loop, 1, false, false, false)
		end)
	end
end

local function startAnimOchroniarz(lib, anim, loop)
	if isBlocked() then return end
	if not cacheVehicle then
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			Wait(1500)
			RequestAnimDict("amb@world_human_stand_guard@male@base")
			while not HasAnimDictLoaded("amb@world_human_stand_guard@male@base") do
				Wait(0)
			end
			TaskPlayAnim(cachePed, "amb@world_human_stand_guard@male@base", "base", 8.0, 3.0, -1, 51, 1, false, false, false)
		end)
	end
end

local function startAnimOckniecie(lib, anim, loop)
	if isBlocked() then return end
	if not cacheVehicle then
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, 12000, loop, 1, false, false, false)
		end)
	end
end

local function startAnimProp(lib, anim, loop)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			kierowanieruchemprop()
			SetCurrentPedWeapon(cachePed, -1569615261, true)
		end)
	end
end

local function startAnimProp2(lib, anim, loop)
	if isBlocked() then return end
	ClearAnimationProps()
	SetCurrentPedWeapon(cachePed, -1569615261, true)
	Wait(1)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
		notesprop()
	end)
end

local function startAnimProp3(lib)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, "random@burial", "a_burial", 8.0, -4.0, -1, 1, 0, 0, 0, 0)
			lopataprop()
		end)
	end
end

local function startAnimProp5(lib, anim, loop)
	if isBlocked() then return end
	ClearAnimationProps()
	SetCurrentPedWeapon(cachePed, -1569615261, true)
	Wait(1)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
		aparatprop()
	end)
end

local function startAnimProp6(lib, anim, loop)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, 2000, loop, 1, false, false, false)
			portfeldowodprop()
		end)
	end
end

local function startAnimProp8(lib, anim, loop)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			clipboardprop()
		end)
	end
end

local function startAnimProp10(lib, anim, loop)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			scierkaprop()
		end)
	end
end

local function startAnimProp11(lib, anim, loop, car)
	if isBlocked() then return end
	ClearAnimationProps()
	SetCurrentPedWeapon(cachePed, -1569615261, true)
	Wait(1)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
		telefonprop()
	end)
end

local function startAnimProp12(lib, anim, loop, car)
	if isBlocked() then return end
	ClearAnimationProps()
	SetCurrentPedWeapon(cachePed, -1569615261, true)
	Wait(1)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
		telefonprop2()
	end)
end

local function startAnimProp15(lib, anim, loop, car)
	if isBlocked() then return end
	ClearAnimationProps()
	SetCurrentPedWeapon(cachePed, -1569615261, true)
	Wait(1)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
		kawaprop()
	end)
end

local function startAnimProp16(lib, anim, loop, car)
	if isBlocked() then return end
	ClearAnimationProps()
	SetCurrentPedWeapon(cachePed, -1569615261, true)
	Wait(1)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
		teddyprop()
	end)
end

local function startAnimProp17(lib, anim, loop, car)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			kartonprop()
		end)
	end
end

local function startAnimProp18(lib, anim, loop, car)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			walizkaprop()
		end)
	end
end

local function startAnimProp19(lib, anim, loop, car)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			walizkaprop2()
		end)
	end
end

local function startAnimProp20(lib, anim, loop, car)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			walizkaprop3()
		end)
	end
end

local function startAnimProp21(lib, anim, loop, car)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			walizkaprop4()
		end)
	end
end

local function startAnimProp22(lib, anim, loop, car)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			wiertarkaprop()
		end)
	end
end

local function startAnimProp23(lib, anim, loop, car)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			toolboxprop()
		end)
	end
end

local function startAnimProp24(lib, anim, loop, car)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			bouquetprop()
		end)
	end
end

local function startAnimProp33(lib, anim, loop, car)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			bouquetprop()
		end)
	end
end

local function startAnimProp34(lib, anim, loop, car)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			guitarprop()
		end)
	end
end

local function startAnimProp35(lib, anim, loop, car)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			bookprop()
		end)
	end
end

local function startAnimProp36(lib, anim, loop, car)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			szampanprop()
		end)
	end
end

local function startAnimProp37(lib, anim, loop, car)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			wineprop()
		end)
	end
end

local function startAnimProp39(lib, anim, loop, car)
	if isBlocked() then return end
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			plecakdokurwyy()
		end)
	end
end

local function startAnimProp38(lib, anim, loop)
	if not cacheVehicle then
		ClearAnimationProps()
		SetCurrentPedWeapon(cachePed, -1569615261, true)
		Wait(1)
		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(cachePed, lib, anim, 8.0, 3.0, -1, loop, 1, false, false, false)
			stickprop()
			stickprop2()
		end)
	end
end

local animFunctions = {
	['walkstyle'] = startWalkStyle,
	['faceexpression'] = startFaceExpression,
	['anim'] = startAnim,
	['anim2'] = startAnim2,
	['animangle'] = startAnimAngle,
	['animangle2'] = startAnimAngle2,
	['animangle3'] = startAnimAngle,
	['animrozmowa'] = startAnimRozmowa,
	['animtabletka'] = startAnimTabletka,
	['animschowek'] = startAnimSchowek,
	['animochroniarz'] = startAnimOchroniarz,
	['animockniecie'] = startAnimOckniecie,
	['animprop'] = startAnimProp,
	['animprop2'] = startAnimProp2,
	['animprop3'] = startAnimProp3,
	['animprop5'] = startAnimProp5,
	['animprop6'] = startAnimProp6,
	['animprop8'] = startAnimProp8,
	['animprop10'] = startAnimProp10,
	['animprop11'] = startAnimProp11,
	['animprop12'] = startAnimProp12,
	['animprop15'] = startAnimProp15,
	['animprop16'] = startAnimProp16,
	['animprop17'] = startAnimProp17,
	['animprop18'] = startAnimProp18,
	['animprop19'] = startAnimProp19,
	['animprop20'] = startAnimProp20,
	['animprop21'] = startAnimProp21,
	['animprop22'] = startAnimProp22,
	['animprop23'] = startAnimProp23,
	['animprop24'] = startAnimProp24,
	['animprop33'] = startAnimProp33,
	['animprop34'] = startAnimProp34,
	['animprop35'] = startAnimProp35,
	['animprop36'] = startAnimProp36,
	['animprop37'] = startAnimProp37,
	['animprop38'] = startAnimProp38,
	['animprop39'] = startAnimProp39
}

local function OpenAnimationsSubMenu(menu)
	local elements, title = {}, ""

	for i = 1, #Config.Animations do
		if Config.Animations[i].name == menu then
			title = Config.Animations[i].label

			for j = 1, #Config.Animations[i].items do
				local item = Config.Animations[i].items[j]
				local eValue = item.data.e
				if eValue ~= nil and tostring(eValue) ~= "" then
					table.insert(elements, {
						label = item.label .. ' ("<font color="#007d00"><b>/e ' .. tostring(eValue) .. '</b></font>")',
						type = item.type,
						value = item.data,
						bind = eValue,
						short = item.label
					})
				else
					table.insert(elements, {
						label = item.label,
						type = item.type,
						value = item.data,
						short = item.label
					})
				end
			end

			break
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'animations_sub', {
		title = title,
		align = 'bottom-right',
		elements = elements
	}, function(data, menu)
		if binding then
			menu.close()
			if not binds then
				binds = {}
			end
			binds[binding] = {
				label = '[' .. title .. '] ' .. data.current.short,
				type = data.current.type,
				data = data.current.value
			}
			TriggerServerEvent('esx_animations:save', binds)
			binding = nil
			OpenBindsSubMenu()
		else
			local animType = animFunctions[data.current.type]
			if animType then
				ClearPedTasks(cachePed)
				ClearAnimationProps()
				for _, v in pairs(GetGamePool('CObject')) do
					if IsEntityAttachedToEntity(cachePed, v) then
						SetEntityAsMissionEntity(v, true, true)
						DeleteObject(v)
						DeleteEntity(v)
					end
				end
				animType(data.current.value.lib, data.current.value.anim, data.current.value.loop, data.current.value.car)
			end
		end
	end, function(data, menu)
		menu.close()
	end)
end

local function OpenSyncedMenu()
	local elements2 = {}
	for k, v in pairs(Config.Synced) do
		table.insert(elements2, { label = v.Label, id = k })
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'play_synced', {
		title = 'Wspólne animacje',
		align = 'bottom-right',
		elements = elements2
	}, function(data2, menu2)
		local current = data2.current
		local allowed = false
		if Config.Synced[current.id].Car then
			if IsPedInAnyVehicle(cachePed, false) then
				allowed = true
			else
				ESX.ShowNotification('Nie jesteś w pojeździe!')
			end
		else
			allowed = true
		end
		if allowed then
			local playersInArea = ESX.Game.GetPlayersInArea(cacheCoords, 2.0)
			if #playersInArea >= 1 then
				local elements = {}
				for _, player in ipairs(playersInArea) do
					if player ~= cachePlayerId then
						table.insert(elements, { label = GetPlayerServerId(player), value = GetPlayerServerId(player) })
					end
				end
				if #elements > 0 then
					markerplayer = GetPlayerFromServerId(elements[1].value)
					ESX.UI.Menu.Open("default", GetCurrentResourceName(), "esx_animations_synced", {
						title = "Wybierz obywatela",
						align = "bottom-right",
						elements = elements
					}, function(data, menu)
						menu.close()
						if not timer or timer < GetGameTimer() then
							ESX.ShowNotification('Wysłano propozycję animacji!')
							TriggerServerEvent('esx_animations:requestSynced', data.current.value, current.id)
							markerplayer = nil
							timer = GetGameTimer() + 10000
						else
							ESX.ShowNotification('Poczekaj chwilę przed następną propozycją wspólnej animacji')
							markerplayer = nil
						end
					end, function(data, menu)
						menu.close()
						markerplayer = nil
					end, function(data, menu)
						markerplayer = GetPlayerFromServerId(data.current.value)
					end)
				else
					ESX.ShowNotification('Nie ma nikogo w pobliżu')
				end
			else
				ESX.ShowNotification('Nie ma nikogo w pobliżu')
			end
		end
	end, function(data2, menu2)
		menu2.close()
	end)
end

local function OpenAnimationsMenu()
	local elements = {}
	if not binding then
		if binds then
			table.insert(elements, { label = "Ulubione [SHIFT + 6-9]", value = "binds" })
		end
		table.insert(elements, { label = "Interakcje - Obywatel", value = "synced" })
	end

	for i = 1, #Config.Animations do
		table.insert(elements, { label = Config.Animations[i].label, value = Config.Animations[i].name })
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'animations', {
		title = 'Animacje',
		align = 'bottom-right',
		elements = elements
	}, function(data, menu)
		if data.current.value then
			if data.current.value == 'binds' then
				menu.close()
				OpenBindsSubMenu()
			elseif data.current.value == "synced" then
				OpenSyncedMenu()
			else
				OpenAnimationsSubMenu(data.current.value)
			end
		end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenBindsSubMenu()
	local elements = {}
	for i = 1, 4 do
		local bind = binds[i + 5]
		table.insert(elements, {
			label = (i + 5) .. (bind and (' - ' .. bind.label) or ' - PRZYPISZ'),
			value = i + 5,
			assigned = bind ~= nil
		})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'animations_binds', {
		title = 'Animacje - ulubione',
		align = 'bottom-right',
		elements = elements
	}, function(data, menu)
		menu.close()
		if data.current.assigned then
			binds[tonumber(data.current.value)] = nil
			TriggerServerEvent('esx_animations:save', binds)
			OpenBindsSubMenu()
		else
			binding = tonumber(data.current.value)
			OpenAnimationsMenu()
		end
	end, function(data, menu)
		menu.close()
		OpenAnimationsMenu()
	end)
end

CreateThread(function()
	while true do
		Wait(500)
		local localPlayerState = LocalPlayer.state
		local isPauseMenuActive = IsPauseMenuActive()
		ConfigPed.Active = not isPauseMenuActive
		if ConfigPed.Active then
			if not IsEntityDead(cachePed) then
				local isLocked = localPlayerState.InTrunk or localPlayerState.IsHandcuffed or localPlayerState.IsDead or localPlayerState.InHouseRobbery
				ConfigPed.Locked = isLocked
				ConfigPed.Alive = true
				ConfigPed.Available = not isLocked
			else
				ConfigPed.Alive = false
				ConfigPed.Available = false
			end
		end
	end
end)

RegisterNetEvent('esx_animations:play')
AddEventHandler('esx_animations:play', function(anim)
	if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InHouseRobbery then
		return
	end

	ClearPedTasks(cachePed)
	ClearAnimationProps()

	for _, v in pairs(GetGamePool('CObject')) do
		if IsEntityAttachedToEntity(cachePed, v) then
			SetEntityAsMissionEntity(v, true, true)
			DeleteObject(v)
			DeleteEntity(v)
		end
	end

	for _, animGroup in ipairs(Config.Animations) do
		for _, item in ipairs(animGroup.items) do
			if tostring(anim) == tostring(item.data.e) then
				if not IsPedCuffed(cachePed) then
					local animType = animFunctions[item.type]
					if animType then
						animType(item.data.lib, item.data.anim, item.data.loop, item.data.car)
					end
				end
				return
			end
		end
	end
end)

lib.addKeybind({
	name = 'cancelanim',
	description = 'Anuluj animacje',
	defaultKey = 'X',
	onReleased = function()
		if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
			ESX.ShowNotification('Nie możesz teraz tego zrobić!')
			return
		end
		ClearPedTasks(cachePed)
		ClearPedSecondaryTask(cachePed)
		ClearAnimationProps()
	end
})

CreateThread(function()
	while true do
		Wait(0)
		if markerplayer then
			local ped = GetPlayerPed(markerplayer)
			local coords2 = GetWorldPositionOfEntityBone(ped, GetPedBoneIndex(ped, 0x796E))
			if #(cacheCoords - coords2) < 40.0 then
				DrawMarker(0, coords2.x, coords2.y, coords2.z + 0.6, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.25, 255, 136, 0, 175, false, true, 2, false, false, false, false)
			end
		else
			Wait(500)
		end
	end
end)

RegisterNetEvent('esx_animations:syncRequest')
AddEventHandler('esx_animations:syncRequest', function(requester, id)
	CreateThread(function()
		local resetmenu = false
		local menu = ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'synced_animation_request', {
			title = 'Propozycja animacji ' .. Config.Synced[id].Label .. ' od ' .. requester,
			align = 'bottom-right',
			elements = {
				{ label = '<span style="color: lightgreen">Zaakceptuj</span>', value = true },
				{ label = '<span style="color: lightcoral">Odrzuć</span>', value = false },
			}
		}, function(data, menu)
			menu.close()
			resetmenu = true
			if data.current.value then
				TriggerServerEvent('esx_animations:syncAccepted', requester, id)
			else
				TriggerServerEvent('esx_animations:cancelSync', requester)
				ESX.ShowNotification('Odrzuciłeś/aś propozycję wspólnej animacji')
			end
		end, function(data, menu)
			resetmenu = true
			menu.close()
			TriggerServerEvent('esx_animations:cancelSync', requester)
			ESX.ShowNotification('Odrzuciłeś/aś propozycję wspólnej animacji')
		end)
		Wait(5000)
		if not resetmenu then
			menu.close()
			TriggerServerEvent('esx_animations:cancelSync', requester)
			ESX.ShowNotification('Propozycja wspólnej animacji wygasła')
		end
	end)
end)

RegisterNetEvent('esx_animations:playSynced')
AddEventHandler('esx_animations:playSynced', function(serverid, id, type)
	local anim = Config.Synced[id][type]
	local target = GetPlayerPed(GetPlayerFromServerId(serverid))

	if anim.Attach then
		local attach = anim.Attach
		AttachEntityToEntity(cachePed, target, attach.Bone, attach.xP, attach.yP, attach.zP, attach.xR, attach.yR, attach.zR, 0, 0, 0, 0, 2, 1)
	end

	Wait(750)

	if anim.Type == 'animation' then
		PlayAnim(anim.Dict, anim.Anim, anim.Flags)
	end

	if type == 'Requester' then
		anim = Config.Synced[id].Accepter
	else
		anim = Config.Synced[id].Requester
	end

	while not IsEntityPlayingAnim(target, anim.Dict, anim.Anim, 3) do
		Wait(0)
		SetEntityNoCollisionEntity(cachePed, target, true)
	end

	DetachEntity(cachePed)

	while IsEntityPlayingAnim(target, anim.Dict, anim.Anim, 3) do
		Wait(0)
		SetEntityNoCollisionEntity(cachePed, target, true)
	end

	ClearPedTasks(cachePed)
end)

local function openAnims()
	if not LocalPlayer.state.IsDead and not LocalPlayer.state.IsHandcuffed then
		OpenAnimationsMenu()
	end
end

exports('openAnims', openAnims)

RegisterCommand("e", function(source, args)
	if not LocalPlayer.state.IsDead and not LocalPlayer.state.IsHandcuffed and not LocalPlayer.state.Crosshair then
		if not args[1] then
			return
		end
		local arg = tostring(args[1])
		if arg == 'bramkarz' then
			local ad = "rcmepsilonism8"
			if DoesEntityExist(cachePed) and not LocalPlayer.state.IsDead then
				LoadDict(ad)
				if IsEntityPlayingAnim(cachePed, ad, "base_carrier", 3) then
					TaskPlayAnim(cachePed, ad, "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
				else
					TaskPlayAnim(cachePed, ad, "base_carrier", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
				end
			end
		elseif arg == 'kabura' then
			local ad = "move_m@intimidation@cop@unarmed"
			if DoesEntityExist(cachePed) and not LocalPlayer.state.IsDead then
				LoadDict(ad)
				if IsEntityPlayingAnim(cachePed, ad, "idle", 3) then
					TaskPlayAnim(cachePed, ad, "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
				else
					TaskPlayAnim(cachePed, ad, "idle", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
				end
			end
		elseif arg == 'aim' then
			local ad = "move_weapon@pistol@copa"
			if DoesEntityExist(cachePed) and not LocalPlayer.state.IsDead then
				LoadDict(ad)
				if IsEntityPlayingAnim(cachePed, ad, "idle", 3) then
					TaskPlayAnim(cachePed, ad, "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
				else
					TaskPlayAnim(cachePed, ad, "idle", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
					DisableControlAction(0, true)
				end
			end
		elseif arg == 'aim2' then
			local ad = "move_weapon@pistol@cope"
			if DoesEntityExist(cachePed) and not LocalPlayer.state.IsDead then
				LoadDict(ad)
				if IsEntityPlayingAnim(cachePed, ad, "idle", 3) then
					TaskPlayAnim(cachePed, ad, "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
				else
					TaskPlayAnim(cachePed, ad, "idle", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
				end
			end
		else
			if not LocalPlayer.state.IsDead then
				TriggerEvent('esx_animations:play', args[1])
			end
		end
	else
		ESX.ShowNotification('Nie możesz teraz tego wykonać!')
	end
end, false)

local options = {
	{
		name = 'esx_animations:togetherAnims',
		icon = 'fa-solid fa-hands-clapping',
		label = 'Wspólne animacje',
		canInteract = function(entity, distance, coords, name, bone)
			if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
				return false
			end
			if distance > 2 then
				return false
			end
			if cacheVehicle then
				return false
			end
			if entity then
				local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
				local playerState = Player(playerId).state
				if playerState.isCrawling or IsEntityPlayingAnim(entity, 'get_up@directional_sweep@combat@pistol@left', 'left_to_prone', 3) or IsEntityPlayingAnim(entity, 'move_crawl', 'onfront_bwd', 3) or IsEntityPlayingAnim(entity, 'move_crawl', 'onback_bwd', 3) or IsEntityPlayingAnim(entity, 'move_crawl', 'onback_fwd', 3) or IsEntityPlayingAnim(entity, 'get_up@directional_sweep@combat@pistol@right', 'right_to_prone', 3) or IsEntityPlayingAnim(entity, 'move_crawl', 'onfront_fwd', 3) or IsEntityPlayingAnim(entity, 'get_up@directional@transition@prone_to_knees@crawl', 'front', 3) or IsEntityPlayingAnim(entity, 'get_up@directional@transition@prone_to_seated@crawl', 'back', 3) then
					return false
				end
				if LocalPlayer.state.IsDraggingSomeone then
					return false
				end
				if playerState.InTrunk then
					return false
				end
				if playerState.DraggingById ~= nil then
					return false
				end
			end
			return true
		end,
		onSelect = function(data)
			local closest_player, closest_distance = ESX.Game.GetClosestPlayer()
			if closest_distance < 2.0 and closest_player ~= -1 then
				OpenSyncedMenu()
			else
				ClearPedTasks(cachePed)
				DetachEntity(cachePed, true, false)
				ESX.ShowNotification('Brak osoby w pobliżu')
			end
		end
	},
}

local ox_target = exports.ox_target
ox_target:addGlobalPlayer(options)

local Oczekuje4 = false
local Czas4 = 7
local wysylajacy4 = nil

RegisterNetEvent('esx_animations:przytulSynchroC2')
AddEventHandler('esx_animations:przytulSynchroC2', function(target)
	Oczekuje4 = true
	wysylajacy4 = target
end)

CreateThread(function()
	while true do
		Wait(1000)
		if Oczekuje4 then
			if LocalPlayer.state.isCrawling then
				Oczekuje4 = false
				ESX.ShowNotification('Nie możesz być przenoszony podczas czołgania!')
			else
				Czas4 = Czas4 - 1
			end
		else
			Wait(500)
		end
	end
end)

CreateThread(function()
	while true do
		Wait(250)
		if Czas4 < 1 then
			Oczekuje4 = false
			Czas4 = 7
			wysylajacy4 = nil
			ESX.ShowNotification('Anulowano propozycję animacji')
		else
			Wait(500)
		end
	end
end)

CreateThread(function()
	while true do
		Wait(0)
		if Oczekuje4 then
			if IsControlJustPressed(0, 246) or IsDisabledControlJustPressed(0, 246) then
				Oczekuje4 = false
				Czas4 = 7
				TriggerServerEvent('esx_animations:OdpalAnimacje5', wysylajacy4)
			end
		else
			Wait(500)
		end
	end
end)

CreateThread(function()
	for i = 1, #Config.Animations do
		for j = 1, #Config.Animations[i].items do
			local eValue = Config.Animations[i].items[j].data.e
			if eValue ~= "" then
				TriggerEvent('chat:addSuggestion', '/e ' .. eValue)
			end
		end
	end
end)

CreateThread(function()
	while true do
		Wait(0)
		if binds then
			if IsControlPressed(0, Keys["LEFTSHIFT"]) and not (IsPedSprinting(cachePed) or IsPedRunning(cachePed)) then
				local bind = nil
				for i, key in ipairs({159, 161, 162, 163}) do
					DisableControlAction(0, key, true)
					if IsDisabledControlJustPressed(0, key) and binds[i + 5] then
						bind = i + 5
						break
					end
				end
				if bind and not LocalPlayer.state.IsDead and not LocalPlayer.state.IsHandcuffed and not LocalPlayer.state.InTrunk and not LocalPlayer.state.InHouseRobbery then
					local bindData = binds[bind]
					local animType = animFunctions[bindData.type]
					if animType then
						ClearPedTasks(cachePed)
						ClearAnimationProps()
						for _, v in pairs(GetGamePool('CObject')) do
							if IsEntityAttachedToEntity(cachePed, v) then
								SetEntityAsMissionEntity(v, true, true)
								DeleteObject(v)
								DeleteEntity(v)
							end
						end
						animType(bindData.data.lib, bindData.data.anim, bindData.data.loop, bindData.data.car)
					end
				end
			else
				Wait(1000)
			end
		else
			Wait(1000)
		end
	end
end)
