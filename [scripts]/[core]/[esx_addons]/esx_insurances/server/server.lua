local PRICES = {[1] = 8000, [3] = 20000, [7] = 55000, [14] = 90000, [30] = 180000}
local DAY_SECONDS = 86400

local function getInsuranceType(station)
	return station == "NNW" and "ems_insurance" or station == "OC" and "oc_insurance" or nil
end

local function getFraction(station)
	return station == "NNW" and "ambulance" or "mechanik"
end

local function addMoneyToFraction(fraction, amount)
	TriggerEvent('esx_addonaccount:getSharedAccount', fraction, function(account)
		account.addMoney(ESX.Math.Round(amount * 0.5))
	end)
end

local function Check()
	MySQL.query('SELECT owner, type, time AS timestamp FROM user_licenses WHERE type = ? OR type = ?', {'ems_insurance', 'oc_insurance'}, function(result)
		local nowTime = os.time()
		for i = 1, #result do
			local aboTime = tonumber(result[i].timestamp)
			if aboTime and aboTime <= nowTime then
				MySQL.update('DELETE FROM user_licenses WHERE type = ? AND owner = ?', {result[i].type, result[i].owner})
			end
		end
	end)
end

Citizen.CreateThread(function()
	while true do
		Check()
		Citizen.Wait(3600000)
	end
end)

RegisterServerEvent('esx_insurances:sell')
AddEventHandler('esx_insurances:sell', function(station, hLong, isExtension)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local iType = getInsuranceType(station)
	if not iType then return end

	local needMoney = PRICES[hLong]
	if not needMoney then return end

	if xPlayer.getMoney() < needMoney then
		xPlayer.showNotification("Nie masz wystarczającej ilości pieniędzy!")
		return
	end

	MySQL.query('SELECT time FROM user_licenses WHERE owner = ? AND type = ?', {xPlayer.identifier, iType}, function(result)
		local currentTime = os.time()
		local newExpire = currentTime + hLong * DAY_SECONDS
		local existingTime = result[1] and tonumber(result[1].time)
		
		if isExtension and existingTime and existingTime > currentTime then
			newExpire = existingTime + hLong * DAY_SECONDS
			MySQL.execute('UPDATE user_licenses SET time = ? WHERE owner = ? AND type = ?', {newExpire, xPlayer.identifier, iType}, function()
				xPlayer.removeMoney(needMoney)
				xPlayer.showNotification("Przedłużyłeś/aś ubezpieczenie " .. station .. " o " .. hLong .. " dni")
				addMoneyToFraction(getFraction(station), needMoney)
			end)
		else
			MySQL.execute('INSERT INTO user_licenses (owner, type, time) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE time = ?', {xPlayer.identifier, iType, newExpire, newExpire}, function()
				xPlayer.removeMoney(needMoney)
				xPlayer.showNotification("Zakupiłeś/aś ubezpieczenie " .. station .. " na " .. hLong .. " dni")
				addMoneyToFraction(getFraction(station), needMoney)
			end)
		end
	end)
end)

ESX.RegisterServerCallback('esx_insurances:check', function(source, cb, station)
	local xPlayer = ESX.GetPlayerFromId(source)
	local iType = getInsuranceType(station)
	if not iType then
		cb(nil)
		return
	end

	MySQL.query('SELECT time FROM user_licenses WHERE owner = ? AND type = ?', {xPlayer.identifier, iType}, function(result)
		if result[1] and result[1].time then
			local timeStr = tostring(result[1].time):gsub(",", "")
			local timestamp = tonumber(timeStr, 10)
			local currentTime = os.time()

			if timestamp and timestamp > currentTime then
				cb({
					expire = os.date('%Y-%m-%d %H:%M:%S', timestamp),
					daysLeft = math.floor((timestamp - currentTime) / DAY_SECONDS)
				})
				return
			end
		end
		cb(nil)
	end)
end)

ESX.RegisterServerCallback('esx_insurances:getLicenses', function(source, cb)
	MySQL.query('SELECT * FROM jobs_insurance ORDER BY oc, nnw ASC', function(results)
		cb(results)
	end)
end)

RegisterServerEvent('esx_insurances:setInsurance')
AddEventHandler('esx_insurances:setInsurance', function(type, insurance, job)
	if insurance ~= "oc" and insurance ~= "nnw" then return end
	
	local value = type == 'SET' and 1 or 0
	MySQL.update('UPDATE jobs_insurance SET ' .. insurance .. ' = ? WHERE name = ?', {value, job})
end)

RegisterServerEvent('esx_insurances:addInsurance')
AddEventHandler('esx_insurances:addInsurance', function(job_name, job_label)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local job = string.lower(job_name)

	if ESX.DoesJobExist(job, 0) then
		MySQL.query('SELECT name FROM jobs_insurance WHERE name = ?', {job}, function(results)
			if results[1] then
				xPlayer.showNotification("Podana praca znajduje się już na liście!")
			else
				MySQL.update('INSERT INTO jobs_insurance (name, job_label) VALUES (?, ?)', {job, job_label})
				xPlayer.showNotification("Pomyślnie dodano firmę " .. job_label .. " do listy")
			end
		end)
	else
		xPlayer.showNotification("Podana praca nie istnieje, proszę wprowadzić poprawną nazwę!")
	end
end)