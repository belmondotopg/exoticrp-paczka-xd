local timerFirst = 0
local isBlockedFirst = false
local activeRobberies = 0

RegisterServerEvent('exotic_cashregister:BlockHeist')
AddEventHandler('exotic_cashregister:BlockHeist', function(status)
	if status then
		activeRobberies = activeRobberies + 1
		isBlockedFirst = true
	end
end)

RegisterServerEvent('exotic_cashregister:EndRobbery')
AddEventHandler('exotic_cashregister:EndRobbery', function()
	if activeRobberies > 0 then
		activeRobberies = activeRobberies - 1
	end
	if activeRobberies == 0 then
		isBlockedFirst = true
		timerFirst = 15
	end
end)

RegisterServerEvent('exotic_cashregister:RemoveCooldown')
AddEventHandler('exotic_cashregister:RemoveCooldown', function()
	isBlockedFirst = false
end)


CreateThread(function()
	while true do
		if isBlockedFirst then
			while timerFirst > 0 do
				Wait(60000)
				timerFirst = timerFirst - 1
			end
			isBlockedFirst = false
		else
			Wait(1000)
		end
	end
end)

RegisterServerEvent('exotic_cashregister:GetTimer')
AddEventHandler('exotic_cashregister:GetTimer', function()
	if timerFirst > 0 then
		TriggerClientEvent('exotic_cashregister:ShowTimer', source, timerFirst)
	end
end)

local lastCheck = 0

ESX.RegisterServerCallback('exotic_cashregister:checkAlreadyRobbing', function(source, cb)
	local currentTime = GetGameTimer()
	if currentTime < lastCheck then
		cb(activeRobberies > 0 or isBlockedFirst)
		return
	end
	lastCheck = currentTime + 5000
	cb(activeRobberies > 0 or isBlockedFirst)
end)