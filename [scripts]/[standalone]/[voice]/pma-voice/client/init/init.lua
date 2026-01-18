local LocalPlayer = LocalPlayer

AddEventHandler('onClientResourceStart', function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end
	print('Starting script initialization')

	local success = pcall(function()
		local micClicksKvp = GetResourceKvpString('pma-voice_enableMicClicks')
		if not micClicksKvp then
			SetResourceKvp('pma-voice_enableMicClicks', tostring(true))
		else
			if micClicksKvp ~= 'true' and micClicksKvp ~= 'false' then
				error('Invalid Kvp, throwing error for automatic cleaning')
			end
			micClicks = micClicksKvp
		end
	end)

	if not success then
		logger.warn('Failed to load resource Kvp, likely was inappropriately modified by another server, resetting the Kvp.')
		SetResourceKvp('pma-voice_enableMicClicks', tostring(true))
		micClicks = 'true'
	end

	if LocalPlayer.state.radioChannel and LocalPlayer.state.radioChannel ~= 0 then
		setRadioChannel(LocalPlayer.state.radioChannel)
	end

	if LocalPlayer.state.callChannel and LocalPlayer.state.callChannel ~= 0 then
		setCallChannel(LocalPlayer.state.callChannel)
	end
	print('Script initialization finished.')
end)
