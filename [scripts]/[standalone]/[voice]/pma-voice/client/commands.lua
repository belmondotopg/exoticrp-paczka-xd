local LocalPlayer = LocalPlayer
local wasProximityDisabledFromOverride = false
disableProximityCycle = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer

	while not ESX.IsPlayerLoaded() do
        Citizen.Wait(200)
    end
    
	local voiceMode = mode
	local newMode = voiceMode + 1

	voiceMode = (newMode <= #Cfg.voiceModes and newMode) or 1
	local voiceModeData = Cfg.voiceModes[voiceMode]
	MumbleSetTalkerProximity(voiceModeData[1] + 0.0)
	mode = voiceMode

	LocalPlayer.state:set('proximity', {
		index = voiceMode,
		distance =  voiceModeData[1],
		mode = voiceModeData[2],
	}, true)
end)

RegisterCommand('setvoiceintent', function(source, args)
	if GetConvarInt('voice_allowSetIntent', 1) == 1 then
		local intent = args[1]
		if intent == 'speech' then
			MumbleSetAudioInputIntent(`speech`)
		elseif intent == 'music' then
			MumbleSetAudioInputIntent(`music`)
		end
		LocalPlayer.state:set('voiceIntent', intent, true)
	end
end)

RegisterCommand('vol', function(_, args)
	if not args[1] then return end
	setVolume(tonumber(args[1]))
end)

RegisterNetEvent('pma-voice:changeVolume', function(vol)
	if vol >= 0 then
		setVolume(vol)
	end
end)

exports('setAllowProximityCycleState', function(state)
	type_check({state, "boolean"})
	disableProximityCycle = state
end)

function setProximityState(proximityRange, isCustom)
	local voiceModeData = Cfg.voiceModes[mode]
	MumbleSetTalkerProximity(proximityRange + 0.0)

	LocalPlayer.state:set('proximity', {
		index = mode,
		distance = proximityRange,
		mode = isCustom and "Custom" or voiceModeData[2],
	}, true)
end

exports("overrideProximityRange", function(range, disableCycle)
	type_check({range, "number"})
	setProximityState(range, true)
	if disableCycle then
		disableProximityCycle = true
		wasProximityDisabledFromOverride = true
	end
end)

exports("clearProximityOverride", function()
	local voiceModeData = Cfg.voiceModes[mode]
	setProximityState(voiceModeData[1], false)
	if wasProximityDisabledFromOverride then
		disableProximityCycle = false
	end
end)

lib.addKeybind({
	name = 'changeproximity',
	description = 'Zmień odległość mówienia',
	defaultKey = 'F5',
	onPressed = function()
		if GetConvarInt('voice_enableProximityCycle', 1) ~= 1 then return end
		if playerMuted then return end

		local voiceMode = mode
		local newMode = voiceMode + 1

		voiceMode = (newMode <= #Cfg.voiceModes and newMode) or 1
		local voiceModeData = Cfg.voiceModes[voiceMode]

		setProximityState(voiceModeData[1] + 0.0, false)
		
		mode = voiceMode

		LocalPlayer.state:set('proximity', {
			index = voiceMode,
			distance =  voiceModeData[1],
			mode = voiceModeData[2],
		}, true)

		TriggerEvent('pma-voice:setTalkingMode', mode)

		local voicedistance = Cfg.voiceModes[mode][1]
		local cachePed = cache.ped

		DrawMarker(28, GetPedBoneCoords(cachePed, 12844, 0.0, 0.0, 0.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, voicedistance, voicedistance, voicedistance, 178, 15, 52, 70, 0, 0, 2, 0, 0, 0, 0)
	end,
})