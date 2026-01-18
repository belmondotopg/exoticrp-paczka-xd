local Player = Player
local MySQL = MySQL
local TriggerClientEvent = TriggerClientEvent
local RegisterServerEvent = RegisterServerEvent
local AddEventHandler = AddEventHandler
local ESX = ESX
local GetCurrentResourceName = GetCurrentResourceName

local esx_core = exports.esx_core
local ox_inventory = exports.ox_inventory
local GetPlayerPed = GetPlayerPed
local GetPlayerName = GetPlayerName
local ReceivedTokens = {}
local Events = {
	onTargetRevive = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	removeItem = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	setDeathStatus = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	heal = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	komunikat = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	komunikatDamage = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	onBuyAddons = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
}

RegisterServerEvent('esx_ambulance:makeRequest')
AddEventHandler('esx_ambulance:makeRequest', function()
	local src = source

    if not ReceivedTokens[src] then
        TriggerClientEvent("esx_ambulance:getRequest", src, Events.onTargetRevive, Events.removeItem, Events.setDeathStatus, Events.heal, Events.komunikat, Events.komunikatDamage, Events.onBuyAddons)
        ReceivedTokens[src] = true
    else
		esx_core:SendLog(src, "Aktywność nadużycia", "Wykryto próbę wywołania TriggerServerEvent z użyciem nieodpowiedniego tokenu! Skrypt w którym wykryto niepożądane działanie: "..GetCurrentResourceName(), "ac")
        return
    end
end)

RegisterNetEvent(Events.onBuyAddons)
AddEventHandler(Events.onBuyAddons, function(tablica, dodatek, state)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer then
		if state then
			xPlayer.showNotification('Zamontowano dodatek')
		else
			xPlayer.showNotification('Zdemontowano dodatek')
		end
	end
end)

AddEventHandler('playerDropped', function(reason)
	local src = source

	if not src then return end
	
    ReceivedTokens[src] = nil

	local reasonLower = reason:lower()
	if reasonLower:find("txadmin") or reasonLower:find("crashed") or reasonLower:find("game crashed") or reasonLower:find("fiveguard") or reasonLower:find("timed out") then return end
	
    if Player(src).state.IsDead then
		if Player(src).state.AntiCL then
			esx_core:SendLog(src, "Wyszedł podczas BW", "Wyszedł podczas BW z serwera z powodem: "..reason.." Był podczas Anti-CL.", "cl")
		end
	end
end)

RegisterServerEvent(Events.onTargetRevive)
AddEventHandler(Events.onTargetRevive, function(target, syringe, medic)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local targetIdentifiers = ESX.ExtractIdentifiers(target)

	if medic == nil then medic = false end
	if syringe == nil then syringe = false end

	if syringe then
		TriggerClientEvent('esx_ambulance:onTargetRevive', target)
		esx_core:SendLog(src, "Ożywienie gracza", "Udzielił pomocy strzykawką `[revive]` na graczu: `["..target.."]`\nLicense: `"..targetIdentifiers.license.."`\nDiscord ID: <@!"..targetIdentifiers.discord..">", 'ems-revive')
	elseif xPlayer.job.name == 'ambulance' or xPlayer.job.name == 'offambulance' then
		TriggerEvent('esx_addonaccount:getSharedAccount', 'ambulance', function(account)
			account.addMoney(500)
			xPlayer.addMoney(500)
		end)

		if medic then
			esx_core:SendLog(src, "Ożywienie gracza", "Ożywił gracza przy pomocy apteczki `[revive]` na graczu: `["..target.."]`\nLicense: `"..targetIdentifiers.license.."`\nDiscord ID: <@!"..targetIdentifiers.discord..">", 'ems-revive')
		end

		exports["esx_hud"]:UpdateTaskProgress(src, "EMS")

		TriggerClientEvent('esx_ambulance:onTargetRevive', target)
	end
end)

ESX.RegisterServerCallback('esx_ambulance:removeItemsAfterRPDeath', function(source, cb)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local crds = GetEntityCoords(GetPlayerPed(src))
	local name = GetPlayerName(src)
	local SSN = ''
	local permamentID = Player(src).state.ssn

	if xPlayer then
		if permamentID ~= nil and permamentID ~= '' then
			SSN = permamentID
		else
			SSN = 'Brak'
		end

		TriggerClientEvent("esx_core:disconnectLogs", -1, src, crds, name, SSN, true)

		return cb()
	end
	
	cb()
end)

RegisterServerEvent(Events.removeItem)
AddEventHandler(Events.removeItem, function(item)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer then
		xPlayer.removeInventoryItem(item, 1)
	end
end)

RegisterCommand('revive', function(source, args, user)
	local targetId = tonumber(args[1])
	local isConsole = (source == 0)
	
	if isConsole then
		if targetId and GetPlayerName(targetId) then
			local tPlayer = ESX.GetPlayerFromId(targetId)
			if tPlayer then
				TriggerClientEvent('esx_ambulance:onTargetRevive', targetId, true)
				TriggerClientEvent("esx:showNotification", targetId, "Zostałeś ożywiony przez prompt!")
				TriggerClientEvent('esx_police:unrestPlayerHandcuffs',targetId,true)
				local logMsg = "Użyto komendy /revive " .. targetId
				
				esx_core:SendLog(nil, "[PROMPT] Ożywienie gracza", logMsg, 'revive')
			end
		end
		return
	end
	
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end
	
	if not ESX.IsPlayerAdmin(xPlayer.source) then
		xPlayer.showNotification('Nie posiadasz permisji')
		return
	end

	local reviveTarget = targetId or source
	local tPlayer = ESX.GetPlayerFromId(reviveTarget)
	
	if not tPlayer or not GetPlayerName(reviveTarget) then
		xPlayer.showNotification('Gracz nie został znaleziony')
		return
	end
	
	if reviveTarget == source then
		TriggerClientEvent("esx:showNotification", source, "Zostałeś ożywiony przez samego siebie!")
		TriggerClientEvent('esx_ambulance:onTargetRevive', source, true)
		esx_core:SendLog(source, "Ożywienie gracza", "Użyto komendy /revive na samym sobie", "revive")
		TriggerClientEvent('esx_police:unrestPlayerHandcuffs',source,true)
	else
		TriggerClientEvent("esx:showNotification", reviveTarget, "Zostałeś ożywiony przez administratora "..GetPlayerName(xPlayer.source).."!")
		TriggerClientEvent('esx_ambulance:onTargetRevive', reviveTarget, true)
		
		TriggerClientEvent('esx_police:unrestPlayerHandcuffs',reviveTarget,true)
		local logMsg = "Użyto komendy /revive " .. reviveTarget
		esx_core:SendLog(source, "Ożywienie gracza", logMsg, "revive")
	end
end, false)

RegisterServerEvent(Events.setDeathStatus)
AddEventHandler(Events.setDeathStatus, function(isDead)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	if xPlayer then
		MySQL.update.await("UPDATE users SET isDead = ? WHERE identifier = ?", {isDead, xPlayer.identifier})
	end
end)

AddEventHandler('esx:playerLoaded', function(playerId)
	local src = playerId
	local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
		local result = MySQL.single.await('SELECT isDead FROM users WHERE identifier = ?', {xPlayer.identifier})

		if result ~= nil then
			if result.isDead == true or result.isDead == 1 then
				TriggerClientEvent('esx:onPlayerIsDeath', src)
			end
		end
    end
end)

lib.callback.register('esx_ambulance:getStatus', function(source)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	local result = MySQL.single.await('SELECT isDead FROM users WHERE identifier = ?', {xPlayer.identifier})

	if result ~= nil then
		if result.isDead == true or result.isDead == 1 then
			return true
		end
	end

	return false
end)

RegisterServerEvent(Events.heal)
AddEventHandler(Events.heal, function(target, itemName, medic50, medic100)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	if not xPlayer then return end
	
	if xPlayer.job.name ~= 'ambulance' and xPlayer.job.name ~= 'offambulance' then
		return
	end
	
	local targetIdentifiers = ESX.ExtractIdentifiers(target)

	if medic50 == nil then medic50 = false end
	if medic100 == nil then medic100 = false end

	if medic50 then
		esx_core:SendLog(src, "Uleczenie gracza", "Uleczył gracza przy pomocy bandażu `[50% zdrowia]` na graczu: `["..target.."]`\nLicense: `"..targetIdentifiers.license.."`\nDiscord ID: <@!"..targetIdentifiers.discord..">", 'ems-revive')
	elseif medic100 then
		esx_core:SendLog(src, "Uleczenie gracza", "Uleczył gracza przy pomocy apteczki `[100% zdrowia]` na graczu: `["..target.."]`\nLicense: `"..targetIdentifiers.license.."`\nDiscord ID: <@!"..targetIdentifiers.discord..">", 'ems-revive')
	end

	TriggerClientEvent('esx_ambulance:heal', target, itemName)
end)

local stash = {
	{
		id = 'ambulance',
		label = 'EMS Schowek',
		slots = 350,
		weight = 500000,
		owner = false,
		groups = {["ambulance"] = 0}
	},
	{
		id = 'ambulance_hc',
		label = 'EMS Schowek HC',
		slots = 350,
		weight = 500000,
		owner = false,
		groups = {["ambulance"] = 10}
	},
}

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
		for k, v in pairs(stash) do
			ox_inventory:RegisterStash(v.id, v.label, v.slots, v.weight, v.owner, v.groups)
		end
    end
end)

RegisterServerEvent(Events.komunikat)
AddEventHandler(Events.komunikat, function(text)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	if not xPlayer then return end
	
	if xPlayer.job.name ~= 'ambulance' and xPlayer.job.name ~= 'offambulance' then
		return
	end
	
	local color = {r = 255, g = 202, b = 247, alpha = 255}

	if src then
		TriggerClientEvent("esx_chat:sendAddonChatMessageMe", -1, src, src, text)
		TriggerClientEvent('esx_chat:onCheckChatDisplay', -1, text, src, color)
	end
end)

RegisterServerEvent(Events.komunikatDamage)
AddEventHandler(Events.komunikatDamage, function(text, target)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	if not xPlayer then return end
	
	if xPlayer.job.name ~= 'ambulance' and xPlayer.job.name ~= 'offambulance' then
		return
	end
	
	local color = {r = 255, g = 202, b = 247, alpha = 255}

	if src then
		TriggerClientEvent("esx_chat:sendAddonChatMessageMe", -1, src, src, text)
		TriggerClientEvent('esx_chat:onCheckChatDisplay', -1, text, src, color)

		color = {r = 255, g = 26, b = 26, alpha = 255}

		SetTimeout(5000, function()
			TriggerClientEvent("esx_chat:sendAddonChatMessageMed", -1, target, target, Player(target).state.BodyDamage)
			TriggerClientEvent('esx_chat:onCheckChatDisplay', -1, Player(target).state.BodyDamage, target, color)
		end)
	end
end)

ESX.RegisterUsableItem('bandage', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer.job.name == 'ambulance' then
		xPlayer.removeInventoryItem('bandage', 1)
		TriggerClientEvent('esx_ambulance:heal', source, 'bandage')
	else
		xPlayer.showNotification('Nie umiesz założyć bandażu, zgłoś się do EMS!')
	end
end)

RegisterServerEvent('esx_ambulance:sync:addTargets', function ()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	if xPlayer.job.name == "ambulance" then
		TriggerClientEvent('esx_ambulance:sync:removeTargets', src)
		TriggerClientEvent('esx_ambulance:sync:addTargetsCL', src)
	else
		TriggerClientEvent('esx_ambulance:sync:removeTargets', src)
	end
end)

ESX.RegisterServerCallback('vwk/ambulance/getUniforms', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb({})
        return
    end
    
    if xPlayer.job.name ~= "ambulance" and xPlayer.job.name ~= "offambulance" then
        cb({})
        return
    end
    
    local jobName = xPlayer.job.name
    
    MySQL.query('SELECT * FROM fractions_uniforms WHERE job = ?', {jobName}, function(result)
        local uniforms = {}
        
        if not result then
            cb({})
            return
        end
        
        if result and #result > 0 then
            for i=1, #result, 1 do
                if result[i].category and result[i].name then
                    local minGrade = result[i].min_grade or 0
                    if xPlayer.job.grade < minGrade then
                        goto continue
                    end
                    
                    if not uniforms[result[i].category] then
                        uniforms[result[i].category] = {}
                    end
                    
                    local maleData = {}
                    local femaleData = {}
                    
                    if result[i].male and result[i].male ~= '' then
                        local success, decoded = pcall(json.decode, result[i].male)
                        if success and decoded then
                            maleData = decoded
                        end
                    end
                    
                    if result[i].female and result[i].female ~= '' then
                        local success, decoded = pcall(json.decode, result[i].female)
                        if success and decoded then
                            femaleData = decoded
                        end
                    end
                    
                    uniforms[result[i].category][result[i].name] = {
                        male = maleData,
                        female = femaleData,
                        min_grade = minGrade
                    }
                    ::continue::
                end
            end
        end
        
        cb(uniforms)
    end)
end)

ESX.RegisterServerCallback('vwk/ambulance/addUniform', function(source, cb, uniformData)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		cb(false)
		return
	end
	
	if xPlayer.job.name ~= "ambulance" and xPlayer.job.name ~= "offambulance" then
		cb(false)
		return
	end
	
	if xPlayer.job.grade <= 10 then
		cb(false)
		return
	end
	
	if not uniformData or not uniformData.name or not uniformData.category then
		cb(false)
		return
	end
	local maleJson = json.encode(uniformData.male or {})
	local femaleJson = json.encode(uniformData.female or {})
	local minGrade = uniformData.min_grade or 0
	
	MySQL.query([[
		CREATE TABLE IF NOT EXISTS fractions_uniforms (
			id INT AUTO_INCREMENT PRIMARY KEY,
			job VARCHAR(50) NOT NULL,
			name VARCHAR(100) NOT NULL,
			category VARCHAR(100) NOT NULL,
			male TEXT,
			female TEXT,
			min_grade INT DEFAULT 0,
			UNIQUE KEY unique_job_name (job, name)
		)
	]], {}, function()
		MySQL.insert('INSERT INTO fractions_uniforms (job, name, category, male, female, min_grade) VALUES (?, ?, ?, ?, ?, ?)',
			{xPlayer.job.name, uniformData.name, uniformData.category, maleJson, femaleJson, minGrade},
			function(id)
				cb(id ~= nil)
			end)
	end)
end)

ESX.RegisterServerCallback('vwk/ambulance/removeUniform', function(source, cb, uniformName)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		cb(false)
		return
	end
	
	if xPlayer.job.name ~= "ambulance" and xPlayer.job.name ~= "offambulance" then
		cb(false)
		return
	end
	
	if xPlayer.job.grade <= 10 then
		cb(false)
		return
	end
	
	MySQL.query('DELETE FROM fractions_uniforms WHERE job = ? AND name = ?', {xPlayer.job.name, uniformName}, function(affected)
		cb(affected.affectedRows > 0)
	end)
end)

ESX.RegisterServerCallback('vwk/ambulance/copyUniform', function(source, cb, sourceName, newName, newCategory)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		cb(false)
		return
	end
	
	if xPlayer.job.name ~= "ambulance" and xPlayer.job.name ~= "offambulance" then
		cb(false)
		return
	end
	
	if xPlayer.job.grade <= 10 then
		cb(false)
		return
	end
	
	MySQL.query('SELECT * FROM fractions_uniforms WHERE job = ? AND name = ?', {xPlayer.job.name, sourceName}, function(result)
		if result and #result > 0 then
			local uniform = result[1]
			MySQL.query('SELECT id FROM fractions_uniforms WHERE job = ? AND name = ?', {xPlayer.job.name, newName}, function(checkResult)
				if checkResult and #checkResult > 0 then
					cb(false)
					return
				end
				
				MySQL.insert('INSERT INTO fractions_uniforms (job, name, category, male, female, min_grade) VALUES (?, ?, ?, ?, ?, ?)',
					{xPlayer.job.name, newName, newCategory or uniform.category, uniform.male, uniform.female, uniform.min_grade or 0},
					function(id)
						cb(id ~= nil)
					end)
			end)
		else
			cb(false)
		end
	end)
end)

ESX.RegisterServerCallback('vwk/ambulance/setUniformMinGrade', function(source, cb, uniformName, minGrade)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		cb(false)
		return
	end
	
	if xPlayer.job.name ~= "ambulance" and xPlayer.job.name ~= "offambulance" then
		cb(false)
		return
	end
	
	if xPlayer.job.grade <= 10 then
		cb(false)
		return
	end
	
	MySQL.update('UPDATE fractions_uniforms SET min_grade = ? WHERE job = ? AND name = ?',
		{minGrade, xPlayer.job.name, uniformName},
		function(affected)
			cb(affected and affected > 0)
		end)
end)

ESX.RegisterServerCallback('vwk/ambulance/renameUniform', function(source, cb, oldName, newName)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		cb(false)
		return
	end
	
	if xPlayer.job.name ~= "ambulance" and xPlayer.job.name ~= "offambulance" then
		cb(false)
		return
	end
	
	if xPlayer.job.grade <= 10 then
		cb(false)
		return
	end
	
	if not oldName or not newName or newName == '' then
		cb(false)
		return
	end
	
	MySQL.query('SELECT id FROM fractions_uniforms WHERE job = ? AND name = ?', {xPlayer.job.name, newName}, function(result)
		if result and #result > 0 then
			cb(false)
			return
		end
		
		MySQL.update('UPDATE fractions_uniforms SET name = ? WHERE job = ? AND name = ?', 
			{newName, xPlayer.job.name, oldName}, 
			function(affected)
				cb(affected and affected > 0)
			end)
	end)
end)