local function BanPlayer(source, reason)
	local xPlayer = ESX.GetPlayerFromId(source)

	if not xPlayer then
		return
	end

	if xPlayer.group ~= 'user' then
		return
	end

	exports.esx_core:SendLog(source, tostring(reason), "ac")
	exports["ElectronAC"]:banPlayer(source, tostring(reason))
end

-- local EventsRateLimits = {}

-- for i = 1, #Config.EventsRateLimits do
--     local event, limit, timer = Config.EventsRateLimits[i].event, Config.EventsRateLimits[i].limit, Config.EventsRateLimits[i].timer
--     RegisterServerEvent(event)
--     AddEventHandler(event, function()
--         local src = source
--         if src then
--             if not EventsRateLimits[event] then
--                 EventsRateLimits[event] = {}
--             end

--             EventsRateLimits[event][src] = (EventsRateLimits[event][src] or 0) + 1

--             if EventsRateLimits[event][src] > limit then
--                 BanPlayer(src, ("Event '%s' wywołany %d razy w ciągu %d sekund."):format(event, limit, timer))
-- 				EventsRateLimits[event] = {}
-- 				return
--             end

--             Citizen.Wait(timer * 1000)
--             EventsRateLimits[event][src] = EventsRateLimits[event][src] - 1
--         end
--     end)
-- end


for i = 1, #Config.ServerEventsBlacklist do
	local event = Config.ServerEventsBlacklist[i]
	RegisterNetEvent(event)
	AddEventHandler(event, function()
		local src = source
		BanPlayer(src, ("Użyto zakazany event: %s"):format(event))
	end)
end

SetConvar('sv_enableNetworkedSounds', 'false')
SetConvar('sv_filterRequestControl', '4')

RegisterServerEvent(GetCurrentResourceName() .. ":BAN")
AddEventHandler(GetCurrentResourceName() .. ":BAN", function(reason)
	BanPlayer(source, reason)
end)

local PedSpam = {}
local VehSpam = {}
local fastVehSpam = {}

AddEventHandler('entityCreated', function(entity)
	Wait(500)
	if not DoesEntityExist(entity) then return end
	
	local src = NetworkGetFirstEntityOwner(entity)
	if not src or src == 0 then return end
	
	local model = GetEntityModel(entity)
	local entityType = GetEntityType(entity)
	local script = GetEntityScript(entity)
	local attached = GetEntityAttachedTo(entity)
	local entitySpeed = GetEntitySpeed(entity)
	
	if entityType == 3 then
		if script then
			-- if not Config.WhitelistedPropsResources[script] then
			-- 	if DoesEntityExist(entity) then
			-- 		DeleteEntity(entity)
			-- 	end
			-- 	return BanPlayer(src,"Spawn propa: "..model.." Przy użyciu skryptu: "..script)
			-- end
			if model == 0 then
				if DoesEntityExist(entity) then
					DeleteEntity(entity)
				end
				return BanPlayer(src, "Gracz próbował zrespić pickupa (Dodać broń/kamizelkę innej osobie)")
			end
		end
	elseif entityType == 2 then
		if entitySpeed > 45.0 then
			DeleteEntity(entity)

			local currentTime = os.time()
		
			if not fastVehSpam[src] or currentTime - fastVehSpam[src].time > 10 then
				fastVehSpam[src] = {
					time = currentTime,
					count = 1,
				}
			else
				fastVehSpam[src].count = fastVehSpam[src].count + 1
				
				if fastVehSpam[src].count >= 4 then
					BanPlayer(src, "Tried to shoot vehicles")
					fastVehSpam[src] = nil
				end
			end
            return
        end

		if attached ~= 0 and IsPedAPlayer(attached) then
			BanPlayer(src,"Tried to attach a vehicle to a player")
            DeleteEntity(entity)
            return
        end

		if script then
			if not Config.WhitelistedCarResources[script] then
				if DoesEntityExist(entity) then
					DeleteEntity(entity)
				end
				return BanPlayer(src,"Spawn pojazdu: "..model.." Przy użyciu skryptu: "..script)
			end

			local currentTime = os.time()
			
			if not VehSpam[src] or currentTime - VehSpam[src].time > 10 then
				VehSpam[src] = {
					time = currentTime,
					count = 1,
					list = { entity }
				}
			else
				VehSpam[src].count = VehSpam[src].count + 1
				table.insert(VehSpam[src].list, entity)
				
				if VehSpam[src].count >= 10 then
					for i = 1, #VehSpam[src].list do
						if DoesEntityExist(VehSpam[src].list[i]) then
							DeleteEntity(VehSpam[src].list[i])
						end
					end
					
					BanPlayer(src, string.format(
						"Gracz zrespił %d aut w %d sekund. (Ostatni pojazd: %s) (Skrypt: %s)",
						VehSpam[src].count,
						currentTime - VehSpam[src].time,
						model,
						script
					))
					
					VehSpam[src] = nil
				end
			end
		end
	elseif entityType == 1 then
		if script then
			local currentTime = os.time()
			
			if not PedSpam[src] or currentTime - PedSpam[src].time > 10 then
				PedSpam[src] = {
					time = currentTime,
					count = 1
				}
			else
				PedSpam[src].count = PedSpam[src].count + 1
				
				if PedSpam[src].count >= 10 then
					BanPlayer(src, string.format(
						"Gracz zrespił %d pedów w %d sekund. (Ostatni ped: %s) (Skrypt: %s)",
						PedSpam[src].count,
						currentTime - PedSpam[src].time,
						model,
						script
					))
					
					if DoesEntityExist(entity) then
						DeleteEntity(entity)
					end
					
					PedSpam[src] = nil
				end
			end
		end
	end
end)

AddEventHandler('explosionEvent', function(sender, ev)
	CancelEvent()
	if not sender or sender == 0 then return end
	
	if Config.ExplosionBlacklist[ev.explosionType] then
		return BanPlayer(sender, "Użycie zablokowanej eksplozji (" .. ev.explosionType .. ")")
	end
end)

AddEventHandler('entityCreating', function(entity)
	local model = GetEntityModel(entity)
	if model == 0 then return end

	local src = NetworkGetFirstEntityOwner(entity)
	if not src or src == -1 then return end

	local entityType = GetEntityType(entity)

	if entityType == 2 and Config.CarsBL[model] then
		CancelEvent()
	end
end)

AddEventHandler("startProjectileEvent", function(sender, data)
	if Config.WeaponsBlacklist[data.weaponType] then
		BanPlayer(tonumber(sender), "Użyto zakazy przedmiot miotany: " .. Config.WeaponsBlacklist[data.weaponType])
		CancelEvent()
	end
end)

AddEventHandler("weaponDamageEvent", function(sender, data)
	if GetPlayerRoutingBucket(sender) > 0 then
		return
	end
	
	if Config.WeaponsBlacklist[data.weaponType] then
		BanPlayer(tonumber(sender), "Zadano damage z zablokowanej broni: " .. Config.WeaponsBlacklist[data.weaponType])
		CancelEvent()
	end
end)

AddEventHandler("playerDropped", function()
	local src = source
	if src then
		if PedSpam[src] then
			PedSpam[src] = nil
		end
		if VehSpam[src] then
			VehSpam[src] = nil
		end
	end
end)

AddEventHandler('giveWeaponEvent', function(sender, data)
	local _source = tonumber(sender)
	BanPlayer(_source, "Próba dodania broni innemu graczowi: " .. json.encode(data))
	CancelEvent()
end)

AddEventHandler("RemoveAllWeaponsEvent", function(sender, data)
	local _source = tonumber(sender)
	BanPlayer(_source, "Próba zabrania all broni graczowi: " .. json.encode(data))
	CancelEvent()
end)

AddEventHandler("RemoveWeaponEvent", function(sender, data)
	local _source = tonumber(sender)
	BanPlayer(_source, "Próba zabrania broni graczowi: " .. json.encode(data))
	CancelEvent()
end)

AddEventHandler("playerDropped", function(reason)
	local src = source
	if string.find(reason, "Failed to create environment") then
		BanPlayer(src, "Wykryto executor: redENGINE (6)")
	end
	if string.find(reason, "cryptography") then
		BanPlayer(src, "Wykryto executor: CFXMafia (6)")
	end
end)

local disableDetections = os.time() + 180
ESX.RegisterServerCallback(GetCurrentResourceName() .. ':CanRestart', function(src, cb)
	return disableDetections >= os.time()
end)

AddEventHandler("onResourceStart", function()
	disableDetections = os.time() + 180
end)

AddEventHandler("onResourceStop", function()
	disableDetections = os.time() + 180
end)

RegisterCommand('deletepropscheater', function(source, args, raw)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer then
		if ESX.IsPlayerAdmin(source) then
			for k, object in ipairs(GetAllObjects()) do
				if DoesEntityExist(object) then
					DeleteEntity(object)
				end
			end

			exports['esx_core']:SendLog(xPlayer.source, "Clear Props Cheater", "Użyto komendy /deletepropscheater", "admin-commands")
			TriggerClientEvent("esx:showNotification", source,"Usunięto wszystkie propy które mógł zrespić cheater")
		end
	end
end, false)
