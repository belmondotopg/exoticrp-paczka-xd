local id = 0
local MugshotsCache = {}
local Answers = {}
local LastMugshot = nil
local LastUpdateTime = 0
local CacheDuration = 120000

function CreateNewMugshot(ped, transparent)
	if not ped or not DoesEntityExist(ped) then return "" end
	id = id + 1

	local handle = RegisterPedheadshot(ped)
	local timer = 2000

	while (not handle or not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle)) and timer > 0 do
		Wait(10)
		timer = timer - 10
	end

	local mugShotTxd = 'none'
	if IsPedheadshotReady(handle) and IsPedheadshotValid(handle) then
		MugshotsCache[id] = handle
		mugShotTxd = GetPedheadshotTxdString(handle)
	end

	SendNUIMessage({
		type = 'convert',
		pMugShotTxd = mugShotTxd,
		removeImageBackGround = transparent or false,
		id = id,
	})

	local p = promise.new()
	Answers[id] = p

	local base64 = Citizen.Await(p)
	if MugshotsCache[id] then
		UnregisterPedheadshot(MugshotsCache[id])
		MugshotsCache[id] = nil
	end

	return base64
end

function GetMugShotBase64(ped, transparent)
	if not ped or not DoesEntityExist(ped) then return "" end

	local now = GetGameTimer()
	if LastMugshot and (now - LastUpdateTime) < CacheDuration then
		return LastMugshot
	end

	local base64 = CreateNewMugshot(ped, transparent)
	if base64 and base64 ~= "" then
		LastMugshot = base64
		LastUpdateTime = now
	end

	return base64
end

exports("GetMugShotBase64", GetMugShotBase64)

RegisterNUICallback('Answer', function(data)
	local cacheId = data.Id
	if Answers[cacheId] then
		Answers[cacheId]:resolve(data.Answer)
		Answers[cacheId] = nil
	end
end)

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end

	for _, handle in pairs(MugshotsCache) do
		if handle and IsPedheadshotValid(handle) then
			UnregisterPedheadshot(handle)
		end
	end

	MugshotsCache = {}
	Answers = {}
	LastMugshot = nil
	LastUpdateTime = 0
	id = 0
end)
