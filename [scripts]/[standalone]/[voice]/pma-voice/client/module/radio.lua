local LocalPlayer = LocalPlayer
local MumbleIsPlayerTalking = MumbleIsPlayerTalking
local GetConvarInt = GetConvarInt
local TaskPlayAnim = TaskPlayAnim
local SetCurrentPedWeapon = SetCurrentPedWeapon
local IsPedInAnyVehicle = IsPedInAnyVehicle
local SetControlNormal = SetControlNormal
local MumbleClearVoiceTargetPlayers = MumbleClearVoiceTargetPlayers
local StopAnimTask = StopAnimTask
local ClearPedTasks = ClearPedTasks

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	ESX.PlayerData = playerData
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

local radioPressed = false
local radioChannel = 0
local radioNames = {}

function syncRadioData(radioTable, localPlyRadioName)
	radioData = radioTable
	logger.info('[radio] Syncing radio table.')
	if GetConvarInt('voice_debugMode', 0) >= 4 then
		print('-------- RADIO TABLE --------')
		tPrint(radioData)
		print('-----------------------------')
	end
	for tgt, enabled in pairs(radioData) do
		if tgt ~= playerServerId then
			toggleVoice(tgt, enabled, 'radio')
		end
	end
	if GetConvarInt("voice_syncPlayerNames", 0) == 1 then
		radioNames[playerServerId] = localPlyRadioName
	end
end

RegisterNetEvent('pma-voice:syncRadioData', syncRadioData)

function setTalkingOnRadio(plySource, enabled)
	toggleVoice(plySource, enabled, 'radio')
	radioData[plySource] = enabled
	playMicClicks(enabled)
end

RegisterNetEvent('pma-voice:setTalkingOnRadio', setTalkingOnRadio)

function addPlayerToRadio(plySource, plyRadioName)
	local cachePlayerId = cache.playerId
	radioData[plySource] = false
	if GetConvarInt("voice_syncPlayerNames", 0) == 1 then
		radioNames[plySource] = plyRadioName
	end
	if radioPressed then
		logger.info('[radio] %s joined radio %s while we were talking, adding them to targets', plySource, radioChannel)
		playerTargets(radioData, MumbleIsPlayerTalking(cachePlayerId) and callData or {})
	else
		logger.info('[radio] %s joined radio %s', plySource, radioChannel)
	end
end
RegisterNetEvent('pma-voice:addPlayerToRadio', addPlayerToRadio)

function removePlayerFromRadio(plySource)
	local cachePlayerId = cache.playerId
	if plySource == playerServerId then
		logger.info('[radio] Left radio %s, cleaning up.', radioChannel)
		radioPressed = false
		TriggerEvent("pma-voice:radioActive", false)
		for tgt, _ in pairs(radioData) do
			if tgt ~= playerServerId then
				toggleVoice(tgt, false, 'radio')
			end
		end
		radioNames = {}
		radioData = {}
		playerTargets(MumbleIsPlayerTalking(cachePlayerId) and callData or {})
	else
		toggleVoice(plySource, false)
		if radioPressed then
			logger.info('[radio] %s left radio %s while we were talking, updating targets.', plySource, radioChannel)
			playerTargets(radioData, MumbleIsPlayerTalking(cachePlayerId) and callData or {})
		else
			logger.info('[radio] %s has left radio %s', plySource, radioChannel)
		end
		radioData[plySource] = nil
		if GetConvarInt("voice_syncPlayerNames", 0) == 1 then
			radioNames[plySource] = nil
		end
	end
end

RegisterNetEvent('pma-voice:removePlayerFromRadio', removePlayerFromRadio)

function setRadioChannel(channel)
	type_check({channel, "number"})
	TriggerServerEvent('pma-voice:setPlayerRadio', channel)
	radioChannel = channel
end

exports('setRadioChannel', setRadioChannel)

exports('SetRadioChannel', setRadioChannel)

exports('removePlayerFromRadio', function()
	setRadioChannel(0)
end)

exports('addPlayerToRadio', function(_radio)
	local radio = tonumber(_radio)
	if radio then
		setRadioChannel(radio)
	end
end)

CreateThread(function ()
	while not ESX.IsPlayerLoaded() do
		Wait(200)
	end

	lib.addKeybind({
		name = 'changechannelfast',
		description = 'Rozmawiaj na radiu',
		defaultKey = 'M',
		onPressed = function()
			if LocalPlayer.state.IsDead then return end
			if LocalPlayer.state.IsHandcuffed then return end
		
			local cachePlayerId = cache.playerId
			
			if not radioPressed and radioEnabled then
				if radioChannel > 0 then
					playerTargets(radioData, MumbleIsPlayerTalking(cachePlayerId) and callData or {})
					TriggerServerEvent('pma-voice:setTalkingOnRadio', true)
					radioPressed = true
					playMicClicks(true)
					local cachePed = cache.ped
					if GetConvarInt('voice_enableRadioAnim', 0) == 1 and not (GetConvarInt('voice_disableVehicleRadioAnim', 0) == 1 and IsPedInAnyVehicle(cachePed, false)) then
						if ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "ambulance" then
							lib.requestAnimDict('amb@code_human_police_investigate@idle_a')
							TaskPlayAnim(cachePed, "amb@code_human_police_investigate@idle_a", "idle_b", 8.0, -8, -1, 49, 0, 0, 0, 0 )
							SetCurrentPedWeapon(cachePed, `GENERIC_RADIO_CHATTER`, true)
						else
							lib.requestAnimDict('random@arrests')
							TaskPlayAnim(cachePed, "random@arrests", "generic_radio_enter", 8.0, 2.0, -1, 50, 2.0, 0, 0, 0)
						end	

						TriggerServerEvent("pma-radio:addRadioTalking")
					end
					Citizen.CreateThread(function()
						TriggerEvent("pma-voice:radioActive", true)
						while radioPressed do
							Citizen.Wait(1)
							SetControlNormal(0, 249, 1.0)
							SetControlNormal(1, 249, 1.0)
							SetControlNormal(2, 249, 1.0)
						end
					end)
				end
			end
		end,
		onReleased = function(self)
			local cachePlayerId = cache.playerId
		
			if radioPressed and (radioChannel > 0 or radioEnabled) then
				radioPressed = false
				MumbleClearVoiceTargetPlayers(voiceTarget)
				playerTargets(MumbleIsPlayerTalking(cachePlayerId) and callData or {})
				TriggerEvent("pma-voice:radioActive", false)
				if not LocalPlayer.state.IsDead then
					playMicClicks(false)
				end
				if GetConvarInt('voice_enableRadioAnim', 0) == 1 then
					local cachePed = cache.ped
					if ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "ambulance" then
						ClearPedTasks(cachePed)
					else
						StopAnimTask(cachePed, "random@arrests", "generic_radio_enter", -4.0)
					end	
					TriggerServerEvent("pma-radio:stopRadioTalking")
				end
				TriggerServerEvent('pma-voice:setTalkingOnRadio', false)
			end
		end,
	})
end)

function syncRadio(_radioChannel)
	if GetConvarInt('voice_enableRadios', 1) ~= 1 then return end
	logger.info('[radio] radio set serverside update to radio %s', radioChannel)
	radioChannel = _radioChannel
end

RegisterNetEvent('pma-voice:clSetPlayerRadio', syncRadio)

exports('getRadioData', function ()
	return radioData and radioData or {}
end)
