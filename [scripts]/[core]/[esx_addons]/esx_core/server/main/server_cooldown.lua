local timerFirst = 0
local isBlockedFirst = false

RegisterServerEvent('esx_core:BlockHeist')
AddEventHandler('esx_core:BlockHeist', function(status, time)
    if status then
        timerFirst = time or 25
        CooldownFirst()
    end
end)

RegisterServerEvent('esx_core:RemoveCooldown')
AddEventHandler('esx_core:RemoveCooldown', function()
	isBlockedFirst = false
end)

local function CooldownFirst()
    isBlockedFirst = true
   	CreateThread(function()
        while timerFirst > 0 do
            Wait(60000)
            timerFirst = timerFirst - 1
        end
        isBlockedFirst = false
    end)
end

local currentCooldown = {}
RegisterServerEvent('esx_core:GetTimer')
AddEventHandler('esx_core:GetTimer', function(heist)
	local src = source
	
	TriggerClientEvent('esx_core:ShowTimer', src, (currentCooldown[heist] and (currentCooldown[heist] - os.time())/60 or 0))
end)


ESX.RegisterServerCallback('esx_core:checkAlreadyRobbing', function(source, cb, name)
	cb(currentCooldown[name] and currentCooldown[name] > os.time() or false)
end)

local takenCops = 0
local whichHeist = {}
GlobalState.FreeCops = 0
AddStateBagChangeHandler("Counter", nil, function(bagName, key, value) 
    -- print("Counter updated", json.encode(value, { indent = true, pretty = true }))
	-- if takenCops > value.police then
	-- 	takenCops = value.police
	-- end
	GlobalState.FreeCops = (takenCops > value.police) and value.police or takenCops
end)

function takeCops(amount, heist) 
	if whichHeist[heist] == true then return end
	local newTakenCops = takenCops + amount
	-- if newTakenCops > GlobalState.Counter["police"] then
	-- 	newTakenCops = GlobalState.Counter["police"]
	-- end
	takenCops = newTakenCops
	GlobalState.FreeCops = (newTakenCops > GlobalState.Counter['police']) and GlobalState.Counter['police'] or newTakenCops
	whichHeist[heist] = true
end
exports("takeCops", takeCops)

function giveBackCops(amount, heist) 
	if whichHeist[heist] ~= true then return end
	local newTakenCops = takenCops - amount
	--[[
		if newTakenCops > GlobalState.Counter["police"] then
		newTakenCops = GlobalState.Counter["police"]
	else]]
	if newTakenCops < 0 then
		newTakenCops = 0
	end
	takenCops = newTakenCops
	GlobalState.FreeCops = (newTakenCops > GlobalState.Counter['police']) and GlobalState.Counter['police'] or newTakenCops
	whichHeist[heist] = false
end
exports("giveBackCops", giveBackCops)


GlobalState.CurrentHeistCooldown = currentCooldown
--[[
	heist: string
	time: int (minutes)
]]
function cooldownHeist(heist, time) 
	currentCooldown[heist] = os.time() + (tonumber(time) * 60)
	GlobalState.CurrentHeistCooldown = currentCooldown
end
exports("cooldownHeist", cooldownHeist)

function getCooldownForHeist(heist) 
	return currentCooldown[heist]
end
exports("getCooldownForHeist", getCooldownForHeist)

ESX.RegisterServerCallback("esx_core:checkCooldown", function(src, cb, heist) 
	cb(currentCooldown[heist] and currentCooldown[heist] > os.time() or false)
end)

ESX.RegisterServerCallback("esx_core:getCooldowns", function(src, cb) 
	cb(currentCooldown)
end)

RegisterCommand("resetcooldown", function(src,args,raw) 
	if src == 0 then
		currentCooldown[args[1]] = nil
		GlobalState.CurrentHeistCooldown = currentCooldown
	end
end,true)