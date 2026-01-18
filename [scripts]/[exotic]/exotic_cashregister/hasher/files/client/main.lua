local ESX = ESX
local LocalPlayer = LocalPlayer
local esx_hud = exports.esx_hud
local ox_target = exports.ox_target
local cacheCoords = cache.coords

lib.onCache('coords', function(coords)
	cacheCoords = coords
end)

local blockedJobs = {
	police = true,
	fib = true,
	ambulance = true,
	mechanik = true
}

local function hasRequiredWeapon()
	local ped = PlayerPedId()
	local playerWeapon = IsPedArmed(ped, 1) or IsPedArmed(ped, 4)
	return playerWeapon
end

local function callPolice()
	ESX.ShowNotification('W sklepie rozbrzmiał dźwięk cichego alarmu, uważaj...')
	PlaySoundFrontend(-1, "CHECKPOINT_MISSED", 0, 1)
	TriggerServerEvent('qf_mdt/addDispatchAlertSV', cacheCoords, 'Włamanie do kasetki!', 'W podanej lokalizacji uruchomił się alarm!', '10-90', 'rgb(192, 222, 0)', '10', 628, 3, 6)
end

local function StartMission()
	if not hasRequiredWeapon() then
		ESX.ShowNotification('Musisz mieć broń białą lub pistolet, aby wykonać napad!')
		return
	end

	ESX.TriggerServerCallback('exotic_cashregister:checkAlreadyRobbing', function(isRobbing)
		if isRobbing then
			TriggerServerEvent('exotic_cashregister:GetTimer')
			return
		end

		if GlobalState.Counter['police'] < Config.Cops then
			ESX.ShowNotification('Minimalnie musi być ' .. Config.Cops .. ' policjantów, aby włamać się do kasetki')
			return
		end

		if blockedJobs[ESX.PlayerData.job.name] then
			ESX.ShowNotification('Nie możesz tego zrobić!')
			return
		end

		ESX.UI.Menu.CloseAll()
		TriggerServerEvent('exotic_cashregister:BlockHeist', true)
		callPolice()
		LocalPlayer.state:set('InKasetka', true, true)

		if esx_hud:progressBar({
			duration = Config.RobDuration,
			useWhileDead = false,
			canCancel = true,
			label = 'Włamywanie...',
			anim = {
				dict = "oddjobs@shop_robbery@rob_till",
				clip = "loop",
			},
			disable = {
				move = true,
				car = true,
				combat = true,
			},
		}) then
			TriggerServerEvent('esx_core:komunikat', 'Otwiera kase fiskalną i wyjmuje z niej gotówkę')
			TriggerServerEvent('exotic_cashregister:getItems', ESX.GetClientKey(LocalPlayer.state.playerIndex))
		else
			TriggerServerEvent('exotic_cashregister:EndRobbery')
			LocalPlayer.state:set('InKasetka', false, true)
		end
	end)
end

ox_target:addModel(`prop_till_01`, {
	{
		icon = "fa-solid fa-cash-register",
		label = 'Obrabuj',
		canInteract = function(entity, distance, coords, name, bone)
			local state = LocalPlayer.state
			if state.IsDead or state.IsHandcuffed then return false end
			if state.ProtectionTime and state.ProtectionTime > 0 then return false end
			if blockedJobs[ESX.PlayerData.job.name] then return false end
			return true
		end,
		onSelect = StartMission,
		distance = 1.5
	}
})