imagewebhook = "https://discord.com/api/webhooks/1452830099358351512/zjx3alsatTm39ydVk4oY7VlQMC3LmYN1DuK04ZWiZD18Vo0mpyMMJfaJ5zDrceLUx8GG"

local webhookurl = "https://discord.com/api/webhooks/1448436346011258972/GHLzbhgMlJiYsmp_dwFgc6uftsDUr5baAHV2yHuE-4zwePeebkgGC9l0HTfy-eBEXyUS" --write webhookurl here
local iconurl = "https://i.imgur.com/3snGmGq.png" -- put your icon for webhok here
local titletext = "House Log"

function AddLog(playersource, propertyid, action)
	if Config.WebHooks == true then
		local houselocationhandler = housinglocations[tostring(propertyid)]
		local playername = ""
		if playersource ~= nil then
			playername = GetPlayerNameRTX(playersource) .. " "
		end
		local textdata = ""
		if action == "purchased" then
			textdata = playername .. "kupił nieruchomość o ID " .. propertyid
		elseif action == "rented" then
			textdata = playername .. "wynajął nieruchomość o ID " .. propertyid
		elseif action == "lockpicked" then
			textdata = playername .. "włamał się do nieruchomości o ID " .. propertyid
		elseif action == "raid" then
			textdata = playername .. "przeszukał nieruchomość o ID " .. propertyid
		elseif action == "propertysold" then
			textdata = playername .. "sprzedał nieruchomość o ID " .. propertyid
		elseif action == "propertytransfered" then
			textdata = playername .. "przekazał nieruchomość o ID " .. propertyid .. " do " .. houselocationhandler.owner
		elseif action == "robbery" then
			textdata = playername .. "rozpoczął okradanie nieruchomości o ID " .. propertyid
		elseif action == "propertytermintaed" then
			textdata = "Nieruchomość o ID " .. propertyid .. " została skonfiskowana"
		elseif action == "propertyrentstop" then
			textdata = playername .. "anulował wynajem nieruchomości o ID " .. propertyid
		end
		if playersource == nil then
			exports.esx_core:SendLog(nil, "Domy", tostring(textdata), 'houses')
		else
			exports.esx_core:SendLog(playersource, "Domy", tostring(textdata), 'houses')
		end
	end
end

function GetPlayerPermissionsCreator(playersource)
	local playerallowed = false
	if Config.PropertyCreatorPermissions.acepermissionsforusecontrolmenu.enable == true then
		if IsPlayerAceAllowed(playersource, Config.PropertyCreatorPermissions.acepermissionsforusecontrolmenu.permission) then 
			playerallowed = true
		end
	end
	if Config.PropertyCreatorPermissions.jobpermissionsforusecontrolmenu.enable == true then
		if Config.Framework == "esx" then
			local xPlayer = ESX.GetPlayerFromId(playersource)
			if xPlayer then
				if xPlayer.job.name == Config.PropertyCreatorPermissions.jobpermissionsforusecontrolmenu.jobname then
					playerallowed = true
				end
			end
		elseif Config.Framework == "qbcore" then
			local xPlayer = QBCore.Functions.GetPlayer(playersource)
			if xPlayer then	
				if xPlayer.PlayerData.job.name == Config.PropertyCreatorPermissions.jobpermissionsforusecontrolmenu.jobname then
					playerallowed = true
				end
			end
		elseif Config.Framework == "standalone" then
			-- add here your job check function
		end
	end	
	if Config.PropertyCreatorPermissions.identifierspermissionsforcontrolmenu == true then
		local licensedata = "unknown"
		local steamdata = "unknown"
		local xboxdata = "unknown"
		local livedata = "unknown"
		local discorddata = "unknown"
		local ipdata = "unknown"
		for i, licensehandler in ipairs(GetPlayerIdentifiers(playersource)) do
			if string.sub(licensehandler, 1,string.len("steam:")) == "steam:" then
				steamdata = tostring(licensehandler)
			elseif string.sub(licensehandler, 1,string.len("license:")) == "license:" then
				licensedata = tostring(licensehandler)
			elseif string.sub(licensehandler, 1,string.len("live:")) == "live:" then
				livedata = tostring(licensehandler)
			elseif string.sub(licensehandler, 1,string.len("xbl:")) == "xbl:" then
				xboxdata = tostring(licensehandler)
			elseif string.sub(licensehandler, 1,string.len("discord:")) == "discord:" then
				discorddata = tostring(licensehandler)
			elseif string.sub(licensehandler, 1,string.len("ip:")) == "ip:" then
				ipdata = tostring(licensehandler)
			end
		end			
		for i, permissionhandler in ipairs(Config.PropertyCreatorPermissions.permissionsviaidentifiers) do
			if permissionhandler.permissiontype == "license" then
				if permissionhandler.permisisondata == licensedata then
					playerallowed = true
					break
				end
			end
			if permissionhandler.permissiontype == "steam" then
				if permissionhandler.permisisondata == steamdata then
					playerallowed = true
					break
				end
			end	
			if permissionhandler.permissiontype == "xbox" then
				if permissionhandler.permisisondata == xboxdata then
					playerallowed = true
					break
				end
			end	
			if permissionhandler.permissiontype == "live" then
				if permissionhandler.permisisondata == livedata then
					playerallowed = true
					break
				end
			end	
			if permissionhandler.permissiontype == "discord" then
				if permissionhandler.permisisondata == discorddata then
					playerallowed = true
					break
				end
			end		
			if permissionhandler.permissiontype == "ip" then
				if permissionhandler.permisisondata == ipdata then
					playerallowed = true
					break
				end
			end							
		end
	end		
	return playerallowed
end

function AddMoneyRTX(playersource, moneydata)
	if Config.Framework == "esx" then
		local xPlayer = ESX.GetPlayerFromId(playersource)
		if xPlayer then
			xPlayer.addMoney(moneydata)
		end
	elseif Config.Framework == "qbcore" then
		local xPlayer = QBCore.Functions.GetPlayer(playersource)
		if xPlayer then	
			xPlayer.Functions.AddMoney('cash', moneydata)
		end
	elseif Config.Framework == "standalone" then
		-- add here money add function	
	end
end	

function RemoveMoneyRTX(playersource, moneydata)
	if Config.Framework == "esx" then
		local xPlayer = ESX.GetPlayerFromId(playersource)
		if xPlayer then
			xPlayer.removeMoney(moneydata)
		end
	elseif Config.Framework == "qbcore" then
		local xPlayer = QBCore.Functions.GetPlayer(playersource)
		if xPlayer then	
			xPlayer.Functions.RemoveMoney('cash', moneydata)	
		end
	elseif Config.Framework == "standalone" then
		-- add here money remove function	
	end
end	

function GetMoneyRTX(playersource)
	local moneydata = 0
	if Config.Framework == "esx" then
		local xPlayer = ESX.GetPlayerFromId(playersource)
		if xPlayer then
			moneydata = xPlayer.getMoney()
		end
	elseif Config.Framework == "qbcore" then
		local xPlayer = QBCore.Functions.GetPlayer(playersource)
		if xPlayer then	
			moneydata = xPlayer.Functions.GetMoney('cash')
		end
	elseif Config.Framework == "standalone" then
		moneydata = 99999999999
		-- add here money get function	
	end
	return moneydata
end	

function GetPlayerIdentifierRTX(playersource)
	local playeridentifierdata = ""
	if Config.Framework == "esx" then
		local xPlayer = ESX.GetPlayerFromId(playersource)
		if xPlayer then
			playeridentifierdata = xPlayer.identifier
		else
			playeridentifierdata = GetPlayerIdentifiers(playersource)[1]	
		end
	elseif Config.Framework == "qbcore" then
		local xPlayer = QBCore.Functions.GetPlayer(playersource)
		if xPlayer then	
			playeridentifierdata = xPlayer.PlayerData.citizenid
		else
			playeridentifierdata = GetPlayerIdentifiers(playersource)[1]	
		end
	elseif Config.Framework == "standalone" then
		playeridentifierdata = GetPlayerIdentifiers(playersource)[1]	
	end
	return playeridentifierdata
end

function GetPlayerNameRTX(playersource)
	local playername = GetPlayerName(playersource)
	if Config.Framework == "esx" then
		local xPlayer = ESX.GetPlayerFromId(playersource)
		if xPlayer then	
			playername = xPlayer.getName()
		end
	elseif Config.Framework == "qbcore" then
		local xPlayer = QBCore.Functions.GetPlayer(playersource)
		if xPlayer then	
			if xPlayer.PlayerData.charinfo.firstname ~= nil and xPlayer.PlayerData.charinfo.lastname ~= nil then
				playername = ""..xPlayer.PlayerData.charinfo.firstname.." "..xPlayer.PlayerData.charinfo.lastname..""
			end
		end
	end
	return playername
end

function CanPlayerPurchaseThisProperty(playersource, houselocationid)
	local houselocationhandler = housinglocations[tostring(houselocationid)]
    -- Purchase permission check placeholder
    -- Always allow for now, customize later (VIP, jobs, restrictions, etc.)
    return true
end


function GiveItemRTX(playersource, itemname, itemcount)
	if Config.Framework == "esx" then
		if Config.OxInventory == true then
			exports.ox_inventory:AddItem(playersource, itemname, itemcount)
		else						
			local xPlayer = ESX.GetPlayerFromId(playersource)
			if xPlayer then
				xPlayer.addInventoryItem(itemname, itemcount)			
			end	
		end
	end
	if Config.Framework == "qbcore" then
		if Config.OxInventory == true then
			exports.ox_inventory:AddItem(playersource, itemname, itemcount)
		else						
			local xPlayer = QBCore.Functions.GetPlayer(playersource)
			if xPlayer then	
				if Config.QBCoreNewInventoryVersion == true then
					exports['qb-inventory']:AddItem(playersource, itemname, itemcount, false, false, '')
				else
					xPlayer.Functions.AddItem(itemname, itemcount, false, {})
				end
			end		
		end
	end		
	if Config.Framework == "standalone" then
		if Config.OxInventory == true then
			exports.ox_inventory:AddItem(playersource, itemname, itemcount)
		end							
	end
end

function GiveItemKey(playersource, keyidentifier)
	if Config.InventorySystem == "oxinventory" then
		exports.ox_inventory:AddItem(playersource, "house_key", 1, {keyid = keyidentifier})
    elseif Config.InventorySystem == "qbcoreinventory" then

        local Player = QBCore.Functions.GetPlayer(playersource)
        if Player then
            Player.Functions.AddItem("house_key", 1, false, {
                keyid = keyidentifier
            })
            TriggerClientEvent('inventory:client:ItemBox', playersource, QBCore.Shared.Items["house_key"], "add")
        end

    elseif Config.InventorySystem == "codeminventory" then

		exports['codem-inventory']:AddItem(
			playersource,
			"house_key",
			1, 
			nil,
			{
				keyid = keyidentifier
			} 
		)

    elseif Config.InventorySystem == "coreinventory" then

		local inventory = playersource 
		local inventoryType = "player"

		local metadata = {
			keyid = keyidentifier
		}

		local itemsAdd = exports.core_inventory:addItem(
			inventory,
			"house_key",
			1,
			metadata,
			inventoryType
		)


    elseif Config.InventorySystem == "psinventory" then

        local Player = QBCore.Functions.GetPlayer(playersource)
        if Player then
            Player.Functions.AddItem("house_key", 1, false, {
                keyid = keyidentifier
            })
            TriggerClientEvent('inventory:client:ItemBox', playersource, QBCore.Shared.Items["house_key"], "add")
        end

    elseif Config.InventorySystem == "jaksam_inventory" then

		local success, result = exports['jaksam_inventory']:addItem(
			playersource,
			'house_key',
			1,
			{
				keyid = keyidentifier
			}
		)


    elseif Config.InventorySystem == "tgiann-inventory" then

		local metadata = {
			keyid = keyidentifier
		}

		local success = exports["tgiann-inventory"]:AddItem(
			playersource,
			"house_key",
			1,  
			nil,
			metadata,
			false 
		)

		if success then
		end
    end
end

function RemoveItemRTX(playersource, itemname, itemcount)
	local removed = false
	if Config.Framework == "esx" then
		if Config.OxInventory == true then
			local success = exports.ox_inventory:RemoveItem(playersource, itemname, itemcount)
			if success then 
				removed = true 
			end		
		else			
			local xPlayer = ESX.GetPlayerFromId(playersource)
			if xPlayer then
				local itemdata = xPlayer.getInventoryItem(itemname)
				if itemdata and itemdata.count >= itemcount then				
					xPlayer.removeInventoryItem(itemname, itemcount)	
					removed = true
				end
			end		
		end
	end
	if Config.Framework == "qbcore" then
		if Config.OxInventory == true then
			local success = exports.ox_inventory:RemoveItem(playersource, itemname, itemcount)
			if success then 
				removed = true 
			end		
		else				
			local xPlayer = QBCore.Functions.GetPlayer(playersource)
			if xPlayer then	
				if Config.QBCoreNewInventoryVersion == true then
					local hasItem = exports['qb-inventory']:HasItem(playersource, itemname, itemcount)
					if hasItem then			
						exports['qb-inventory']:RemoveItem(playersource, itemname, itemcount, false, 'qb-inventory:testRemove')
						removed = true
					end				
				else
					local itemdata = xPlayer.Functions.GetItemByName(itemname)
					if itemdata and itemdata.amount >= itemcount then					
						xPlayer.Functions.RemoveItem(itemname, itemcount, false, {})
						removed = true
					end
				end
			end		
		end
	end		
	if Config.Framework == "standalone" then
		if Config.OxInventory == true then
			local success = exports.ox_inventory:RemoveItem(playersource, itemname, itemcount)
			if success then 
				removed = true 
			end		
		else				
			removed = true
		end
	end
	return removed
end


function GetItemRTX(playersource, itemname, itemcount)
	local removed = false
	if Config.Framework == "esx" then
		if Config.OxInventory == true then
			local count = exports.ox_inventory:Search(playersource, 'count', itemname)
			if count and  count >= itemcount then	
				removed = true
			end
		else
			local xPlayer = ESX.GetPlayerFromId(playersource)
			if xPlayer then
				local itemdata = xPlayer.getInventoryItem(itemname)
				if itemdata and itemdata.count >= itemcount then		
					removed = true
				end
			end	
		end
	end
	if Config.Framework == "qbcore" then
		if Config.OxInventory == true then
			local count = exports.ox_inventory:Search(playersource, 'count', itemname)
			if count and count >= itemcount then	
				removed = true
			end
		else		
			local xPlayer = QBCore.Functions.GetPlayer(playersource)
			if xPlayer then	
				if Config.QBCoreNewInventoryVersion == true then
					local hasItem = exports['qb-inventory']:HasItem(playersource, itemname, itemcount)
					if hasItem then			
						removed = true
					end				
				else
					local itemdata = xPlayer.Functions.GetItemByName(itemname)
					if itemdata and itemdata.amount >= itemcount then
						removed = true
					end
				end
			end		
		end
	end		
	if Config.Framework == "standalone" then
		if Config.OxInventory == true then
			local count = exports.ox_inventory:Search(playersource, 'count', itemname)
			if count and count >= itemcount then	
				removed = true
			end
		else	
			removed = true
		end
	end
	return removed
end

function CheckHouseCreatorPermission(playersource)
	local permission = false
	if Config.Framework == "esx" then
		local xPlayer = ESX.GetPlayerFromId(playersource)
		local playergroup = xPlayer.getGroup()
		if playergroup == "admin" or playergroup == "superadmin" then
			permission = true
		end
	elseif Config.Framework == "qbcore" then
		if QBCore.Functions.HasPermission(playersource, 'admin') or QBCore.Functions.HasPermission(playersource, 'god') then
			permission = true
		end
	elseif Config.Framework == "standalone" then
		permission = true
	end	
	if permission == false then
		permission = GetPlayerPermissionsCreator(playersource)
	end
	return permission
end


function GetPlayerJobName(src)
    if Config.Framework == "esx" and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.job and xPlayer.job.name then
            return xPlayer.job.name
        end
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if xPlayer and xPlayer.PlayerData and xPlayer.PlayerData.job and xPlayer.PlayerData.job.name then
            return xPlayer.PlayerData.job.name
        end
    end
    return nil
end

function GetJobSources(jobsTable)
    local sources = {}

    if not jobsTable then
        return sources
    end

    if Config.Framework == "ESX" and ESX then
        for jobName, enabled in pairs(jobsTable) do
            if enabled then
                local xPlayers = ESX.GetExtendedPlayers('job', jobName)
                if xPlayers then
                    for _, xPlayer in ipairs(xPlayers) do
                        if xPlayer and xPlayer.source then
                            table.insert(sources, xPlayer.source)
                        end
                    end
                end
            end
        end

    elseif Config.Framework == "qbcore" and QBCore then
        for jobName, enabled in pairs(jobsTable) do
            if enabled then
                local players, count = QBCore.Functions.GetPlayersOnDuty(jobName)
                if players then
                    for _, v in pairs(players) do
                        local src = v

                        if type(v) ~= "number" then
                            if v.PlayerData and v.PlayerData.source then
                                src = v.PlayerData.source
                            else
                                src = nil
                            end
                        end

                        if src then
                            table.insert(sources, src)
                        end
                    end
                end
            end
        end
    end

    return sources
end


function GetTotalJobsOnline(jobsTable)
    local total = 0

    for jobName, enabled in pairs(jobsTable) do
        if enabled then

            if Config.Framework == "ESX" then
                total = total + (#ESX.GetExtendedPlayers('job', jobName) or 0)

            elseif Config.Framework == "qbcore" then
                local players, count = QBCore.Functions.GetPlayersOnDuty(jobName)
                total = total + (count or 0)
            end

        end
    end

    return total
end

function HasPlayerLockPick(playersource)
	local lockpick = false
	if Config.LockPickRaidSettings.LockPick.enabled == true then
		if Config.LockPickRaidSettings.LockPick.itemrequired == true then
			 local hasItem = GetItemRTX(playersource, Config.LockPickRaidSettings.LockPick.itemname, Config.LockPickRaidSettings.LockPick.itemcount)
			 if hasItem then
				lockpick = true
			end
		else
			lockpick = true
		end
	end
	return lockpick
end

function IsPlayerPolice(playersource)
	local police = false
	if Config.LockPickRaidSettings.Raid.enabled == true then
		if Config.LockPickRaidSettings.Raid.jobs[GetPlayerJobName(playersource)] then
			police = true
		end
	end
	return police
end

function HasPlayerRobberyItem(playersource)
	local robberyitem = true
	if Config.RobberySettings.itemrequired == true then
		 local hasItem = GetItemRTX(playersource, Config.RobberySettings.itemname, Config.RobberySettings.itemcount)
		 if hasItem then
			robberyitem = true
		else
			robberyitem = false
		end
	end
	return robberyitem
end

function CheckPropertyKeys(playersource, houselocationid)
	local houselocationhandler = housinglocations[tostring(houselocationid)]
	local havekeys = false
	for i, keyhandler in ipairs(houselocationhandler.keys) do
		if Config.InventorySystem == "oxinventory" then
			local count = exports.ox_inventory:Search(playersource, 'count', "house_key", {keyid = keyhandler.identifier})
			if count and count >= 1 then
				havekeys = true
			end
		elseif Config.InventorySystem == "qbcoreinventory" then
			local Player = QBCore.Functions.GetPlayer(playersource)
			if Player then
				local items = Player.Functions.GetItemsByName("house_key")

				if items then
					for _, item in pairs(items) do
						if item.info and item.info.keyid == keyhandler.identifier then
							havekeys = true
						end
					end
				end
			end		
		elseif Config.InventorySystem == "codeminventory" then

			local items = exports['codem-inventory']:GetInventory(playersource)
			if items then
				for _, item in pairs(items) do
					if item.name == "house_key"
					and item.metadata
					and item.metadata.keyid == keyhandler.identifier then
						havekeys = true
					end
				end
			end

		elseif Config.InventorySystem == "coreinventory" then

			local items = exports.core_inventory:GetInventory(playersource)
			if items then
				for _, item in pairs(items) do
					if item.name == "house_key"
					and item.metadata
					and item.metadata.keyid == keyhandler.identifier then
						havekeys = true
					end
				end
			end

		elseif Config.InventorySystem == "psinventory" then

			local Player = QBCore.Functions.GetPlayer(playersource)
			if Player then
				local items = Player.PlayerData.items
				if items then
					for _, item in pairs(items) do
						if item.name == "house_key"
						and item.info
						and item.info.keyid == keyhandler.identifier then
							havekeys = true
						end
					end
				end
			end

		elseif Config.InventorySystem == "chezza" then

			local items = exports['chezza_inventory']:GetPlayerInventory(playersource)
			if items then
				for _, item in pairs(items) do
					if item.name == "house_key"
					and item.metadata
					and item.metadata.keyid == keyhandler.identifier then
						havekeys = true
					end
				end
			end

		elseif Config.InventorySystem == "jaksam_inventory" then

			local items = exports['jaksam_inventory']:GetInventory(playersource)
			if items then
				for _, item in pairs(items) do
					if item.name == "house_key"
					and item.metadata
					and item.metadata.keyid == keyhandler.identifier then
						havekeys = true
					end
				end
			end

		elseif Config.InventorySystem == "tgiann-inventory" then

			local items = exports['tgiann-inventory']:GetPlayerItems(playersource)
			if items then
				for _, item in pairs(items) do
					if item.name == "house_key"
					and item.metadata
					and item.metadata.keyid == keyhandler.identifier then
						havekeys = true
					end
				end
			end
		end
	end
	return havekeys
end

function GetPropertyPermissions(playersource, houselocationid)
	local playeridentifier = GetPlayerIdentifierRTX(playersource)
	local perms = {}
	if housinglocations[tostring(houselocationid)].permissions[tostring(playeridentifier)] ~= nil or housinglocations[tostring(houselocationid)].tenants[tostring(playeridentifier)] ~= nil or housinglocations[tostring(houselocationid)].owner == tostring(playeridentifier) then
		if housinglocations[tostring(houselocationid)].tenants[tostring(playeridentifier)] ~= nil then
			perms = {
				["furnitureMenu"] = false,
				["unlocking"]     = false,
				["wardrobe"]      = false,
				["storage"]       = false,
				["manageKeys"]    = false,
				["upgrades"]      = false,
				["payBills"]      = false,
				["garage"]        = false,
				["orderServices"] = false,
				["tenants"]       = false,
				["clean"]         = false,
				["doorbell"]      = false,
				["cameras"]       = false,		
				["services"]       = false,	
				["positions"]       = false,
			}
			for perm, enabled in pairs(Config.TenantPropertyPermissions or {}) do
				if enabled == true and perms[perm] ~= nil then
					perms[perm] = true
				end
			end	
		elseif housinglocations[tostring(houselocationid)].owner == tostring(playeridentifier) then
			perms = {
				["furnitureMenu"] = true,
				["unlocking"]     = true,
				["wardrobe"]      = true,
				["storage"]       = true,
				["manageKeys"]    = true,
				["upgrades"]      = true,
				["payBills"]      = true,
				["garage"]        = true,
				["orderServices"] = true,
				["tenants"]       = true,
				["clean"]         = true,
				["doorbell"]      = true,
				["cameras"]       = true,		
				["services"]       = true,	
				["positions"]       = true,
			}			
		else
			perms = housinglocations[tostring(houselocationid)].permissions[tostring(playeridentifier)].permissions
		end
			
	else
		perms = {
			["furnitureMenu"] = false,
			["unlocking"]     = false,
			["wardrobe"]      = false,
			["storage"]       = false,
			["manageKeys"]    = false,
			["upgrades"]      = false,
			["payBills"]      = false,
			["garage"]        = false,
			["orderServices"] = false,
			["tenants"]       = false,
			["clean"]         = false,
			["doorbell"]      = false,
			["cameras"]       = false,		
			["services"]       = false,	
			["positions"]       = false,
		}
	end
	return perms
end

function GetPropertyPermission(playersource, houselocationid, permtypedata)
	local playeridentifier = GetPlayerIdentifierRTX(playersource)
	local perms = {}
	if housinglocations[tostring(houselocationid)].permissions[tostring(playeridentifier)] ~= nil or housinglocations[tostring(houselocationid)].tenants[tostring(playeridentifier)] ~= nil or housinglocations[tostring(houselocationid)].owner == tostring(playeridentifier) then
		if housinglocations[tostring(houselocationid)].tenants[tostring(playeridentifier)] ~= nil then
			perms = {
				["furnitureMenu"] = false,
				["unlocking"]     = false,
				["wardrobe"]      = false,
				["storage"]       = false,
				["manageKeys"]    = false,
				["upgrades"]      = false,
				["payBills"]      = false,
				["garage"]        = false,
				["orderServices"] = false,
				["tenants"]       = false,
				["clean"]         = false,
				["doorbell"]      = false,
				["cameras"]       = false,		
				["services"]       = false,	
				["positions"]       = false,
			}
			for perm, enabled in pairs(Config.TenantPropertyPermissions or {}) do
				if enabled == true and perms[perm] ~= nil then
					perms[perm] = true
				end
			end	
		elseif housinglocations[tostring(houselocationid)].owner == tostring(playeridentifier) then
			perms = {
				["furnitureMenu"] = true,
				["unlocking"]     = true,
				["wardrobe"]      = true,
				["storage"]       = true,
				["manageKeys"]    = true,
				["upgrades"]      = true,
				["payBills"]      = true,
				["garage"]        = true,
				["orderServices"] = true,
				["tenants"]       = true,
				["clean"]         = true,
				["doorbell"]      = true,
				["cameras"]       = true,		
				["services"]       = true,	
				["positions"]       = true,
			}			
		else
			perms = housinglocations[tostring(houselocationid)].permissions[tostring(playeridentifier)].permissions
		end
			
	else
		perms = {
			["furnitureMenu"] = false,
			["unlocking"]     = false,
			["wardrobe"]      = false,
			["storage"]       = false,
			["manageKeys"]    = false,
			["upgrades"]      = false,
			["payBills"]      = false,
			["garage"]        = false,
			["orderServices"] = false,
			["tenants"]       = false,
			["clean"]         = false,
			["doorbell"]      = false,
			["cameras"]       = false,		
			["services"]       = false,	
			["positions"]       = false,
		}
	end
	return perms[permtypedata]
end

function HasPlayerAnyPropertyPermissions(playersource, houselocationid)
	local playeridentifier = GetPlayerIdentifierRTX(playersource)
	local someperm = false
	if housinglocations[tostring(houselocationid)].permissions[tostring(playeridentifier)] ~= nil or housinglocations[tostring(houselocationid)].tenants[tostring(playeridentifier)] ~= nil or housinglocations[tostring(houselocationid)].owner == tostring(playeridentifier) then
		someperm = true
	else
		someperm = false
	end
	return someperm
end

function NearbyProperty(playersource, houselocationid)
	local nearby = true
	return nearby
end

function ActionCheck(playersource, houselocationid, actiontype)
    local actionpossible = true

    if actiontype == "lock" then
        local now = GetGameTimer()  
        local last = latestLockAction[houselocationid] or 0
        local diff = now - last

        if diff < Config.ActionCooldown then
            actionpossible = false
        else
            
            latestLockAction[houselocationid] = now
            actionpossible = true
        end
    elseif actiontype == "light" then
        local now = GetGameTimer()  
        local last = latestLightAction[houselocationid] or 0
        local diff = now - last

        if diff < Config.ActionCooldown then
            actionpossible = false
        else
            
            latestLightAction[houselocationid] = now
            actionpossible = true
        end		
    elseif actiontype == "bell" then
        local now = GetGameTimer()  
        local last = latestBellAction[houselocationid] or 0
        local diff = now - last

        if diff < Config.ActionCooldown then
            actionpossible = false
        else
            
            latestBellAction[houselocationid] = now
            actionpossible = true
        end	
    elseif actiontype == "service" then
        local now = GetGameTimer()  
        local last = latestServiceAction[houselocationid] or 0
        local diff = now - last

        if diff < Config.ActionCooldown then
            actionpossible = false
        else
            
            latestServiceAction[houselocationid] = now
            actionpossible = true
        end		
    elseif actiontype == "changedoorbell" then
        local now = GetGameTimer()  
        local last = latestChangeDoorbellAction[houselocationid] or 0
        local diff = now - last

        if diff < Config.ActionCooldown then
            actionpossible = false
        else
            
            latestChangeDoorbellAction[houselocationid] = now
            actionpossible = true
        end			
    elseif actiontype == "changedance" then
        local now = GetGameTimer()  
        local last = latestChangeDanceAction[houselocationid] or 0
        local diff = now - last

        if diff < Config.ActionCooldown then
            actionpossible = false
        else
            
            latestChangeDanceAction[houselocationid] = now
            actionpossible = true
        end		
    elseif actiontype == "motiondetect" then
        local now = GetGameTimer()  
        local last = latestMotionDetectAction[houselocationid] or 0
        local diff = now - last

        if diff < Config.MotionDetectorSettings.motionalertcooldown then
            actionpossible = false
        else
            
            latestMotionDetectAction[houselocationid] = now
            actionpossible = true
        end		
    elseif actiontype == "motiondetectinside" then
        local now = GetGameTimer()  
        local last = latestMotionDetectInsideAction[houselocationid] or 0
        local diff = now - last

        if diff < Config.MotionDetectorSettings.motionalertcooldown then
            actionpossible = false
        else
            
            latestMotionDetectInsideAction[houselocationid] = now
            actionpossible = true
        end	
    elseif actiontype == "pinchange" then
        local now = GetGameTimer()  
        local last = latestPinChangeAction[houselocationid] or 0
        local diff = now - last

        if diff < Config.ActionCooldown then
            actionpossible = false
        else
            
            latestPinChangeAction[houselocationid] = now
            actionpossible = true
        end		
    elseif actiontype == "list" then
        local now = GetGameTimer()  
        local last = latestListAction[houselocationid] or 0
        local diff = now - last

        if diff < Config.ActionCooldown then
            actionpossible = false
        else
            
            latestListAction[houselocationid] = now
            actionpossible = true
        end	
    elseif actiontype == "vacuum" then
        local now = GetGameTimer()  
        local last = latestVacuumAction[houselocationid] or 0
        local diff = now - last

        if diff < Config.ActionCooldown then
            actionpossible = false
        else
            
            latestVacuumAction[houselocationid] = now
            actionpossible = true
        end					
    end

    return actionpossible
end

function FurnitureInteraction(furnituretype)
	if furnituretype == "sink" then
		-- add hygiene
	elseif furnituretype == "shower" then
		-- add hygiene
	end
		
end

function PropertyServicesRate()
	return Config.ServicesSettings
end

function RegisterStorages(houseiddata, storageid)
	local houselocationhandler = housinglocations[tostring(houseiddata)]
	if Config.InventorySystem == "oxinventory" then
		local stash = {
			id = 'property-'..houseiddata..'-storage-'..storageid..'',
			label = 'Property Storage - '..storageid..'',
			slots = houselocationhandler.storage.slots,
			weight = houselocationhandler.storage.weight,
			owner = false,
		}	
		exports.ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner)
	elseif Config.InventorySystem == "qbcoreinventory" then		
		RegisterServerEvent("rtx_housing:Global:OpenStorageQB", function(storagenamedata)
			local playersource = source
			local data = { label = storagenamedata, maxweight = houselocationhandler.storage.weight, slots = houselocationhandler.storage.slots }
			exports['qb-inventory']:OpenInventory(playersource, storagenamedata, data)
		end)	
	elseif Config.InventorySystem == "jaksam_inventory" then	
		local virtualStashId = exports['jaksam_inventory']:registerStash({
			id = "property-"..houseiddata.."-storage-"..storageid.."",
			label = "Property Storage - "..storageid.."",
			maxWeight = houselocationhandler.storage.weight,
			maxSlots = houselocationhandler.storage.slots,
			isPrivate = false,
		})		
	end	
end

function RegisterSafe(houseiddata, storageid)
	local houselocationhandler = housinglocations[tostring(houseiddata)]
	if Config.InventorySystem == "oxinventory" then
		local stash = {
			id = 'property-'..houseiddata..'-storage-'..storageid..'',
			label = 'Property Safe - '..storageid..'',
			slots = Config.SafeSettings.slots,
			weight = Config.SafeSettings.weight,
			owner = false,
		}	
		exports.ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner)
	elseif Config.InventorySystem == "qbcoreinventory" then		
		RegisterServerEvent("rtx_housing:Global:OpenStorageQB", function(storagenamedata)
			local playersource = source
			local data = { label = storagenamedata, maxweight = Config.SafeSettings.weight, slots =  houselocationhandler.storage.slots }
			exports['qb-inventory']:OpenInventory(playersource, storagenamedata, data)
		end)	
	elseif Config.InventorySystem == "jaksam_inventory" then	
		local virtualStashId = exports['jaksam_inventory']:registerStash({
			id = "property-"..houseiddata.."-storage-"..storageid.."",
			label = "Property Safe - "..storageid.."",
			maxWeight = Config.SafeSettings.weight,
			maxSlots = Config.SafeSettings.slots,
			isPrivate = false,
		})		
	end	
end

function RegisterGarage(houseiddata)
	local houselocationhandler = housinglocations[tostring(houseiddata)]
	if Config.GarageSystem == "ZSX_Garages" then
        local players = {}
        table.insert(players, houselocationhandler.owner)
        local coordinates = {vector4( houselocationhandler.garage.coords.x, houselocationhandler.garage.coords.y, houselocationhandler.garage.coords.z-2.0, houselocationhandler.garage.heading )}
        exports['ZSX_Garages']:AddTempGarage("temp_property"..houseiddata, houselocationhandler.propertyname, true, 'player', players, coordinates)
	elseif Config.GarageSystem == "vms_garagesv2" then
		 exports["vms_garagesv2"]:registerHousingGarage(
			'rtx-housing-' .. houseiddata,
			'Garage',                                    
			tostring(houseiddata), 
			vector4( houselocationhandler.garage.coords.x, houselocationhandler.garage.coords.y, houselocationhandler.garage.coords.z-2.0, houselocationhandler.garage.heading ),
			1 
		)
	end	
end

function UpdateGarage(houseiddata)
	local houselocationhandler = housinglocations[tostring(houseiddata)]
	if Config.GarageSystem == "ZSX_Garages" then
		table.insert(players, property.owner)
		exports['ZSX_Garages']:UpdateTempGaragePlayerList("temp_property"..houseiddata, players)
	end	
end

function RemoveGarage(houseiddata)
	local houselocationhandler = housinglocations[tostring(houseiddata)]
	if Config.GarageSystem == "ZSX_Garages" then
		exports['ZSX_Garages']:RemoveTempGarage("temp_property"..houseiddata)
	end	
end

function GetStarterApartmentName(playersource)
	local startername = ""
	local playername = GetPlayerNameRTX(playersource)
	if Language[Config.Language]["notallowed"] ~= nil then
		startername = LanguageFile("starterapartment", playername)
	else
		startername = playername.." Apartment"
	end
	return startername
end

function GetCurrentDate()
    local now = os.time()
    local dt = os.date("*t", now)

    local months = {
        [1]  = "January",
        [2]  = "February",
        [3]  = "March",
        [4]  = "April",
        [5]  = "May",
        [6]  = "June",
        [7]  = "July",
        [8]  = "August",
        [9]  = "September",
        [10] = "October",
        [11] = "November",
        [12] = "December"
    }

    local monthName = months[dt.month] or "Unknown"

    return string.format("%s %d, %d", monthName, dt.day, dt.year)
end

function IsIdentifierOnline(identifier)
    if not identifier then 
        return false, nil 
    end

    identifier = tostring(identifier)

    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
        if xPlayer then
            return true, xPlayer.source
        end
        return false, nil
    end

    if Config.Framework == "qbcore" then
        local player = QBCore.Functions.GetPlayerByCitizenId(identifier)
        if player then
            return true, player.PlayerData.source
        end
        return false, nil
    end

    if Config.Framework == "standalone" then
        for _, src in ipairs(GetPlayers()) do
            local ids = GetPlayerIdentifiers(src)
            for _, id in ipairs(ids) do
                if id == identifier then
                    return true, tonumber(src)
                end
            end
        end
        return false, nil
    end

    print("[WARNING] Unknown framework in Config.Framework:", Config.Framework)
    return false, nil
end

function AlarmAlert(propertyid, alarmside)
	local houselocationhandler = housinglocations[tostring(propertyid)]
	local alarmcoords = houselocationhandler.enter.coords
	if houselocationhandler.propertytype == "MLO" then
		alarmcoords = houselocationhandler.managment.coords
	end	
	if alarmside == "owner" then
		local online, serverId = IsIdentifierOnline(houselocationhandler.owner)
		if online then		
			if Config.AlertSystem == "default" then
				TriggerClientEvent("rtx_housing:Notify", serverId, "warning", Language[Config.Language]["alarm2"], LanguageFile("alarm", houselocationhandler.propertyname, houselocationhandler.adress))	
				TriggerClientEvent("rtx_housing:Global:AlarmBlip",serverId, propertyid, alarmcoords)
			end
		end
	elseif alarmside == "police" then
		if Config.AlertSystem == "default" then
			local alertSources = GetJobSources(Config.AlarmSettings.Police.jobs)
			for i, policesrc in ipairs(alertSources) do
				TriggerClientEvent("rtx_housing:Notify", policesrc, "warning", Language[Config.Language]["alarm2"], LanguageFile("alarm", houselocationhandler.propertyname, houselocationhandler.adress))	
				TriggerClientEvent("rtx_housing:Global:AlarmBlip",policesrc, propertyid, alarmcoords)		
			end
		elseif Config.AlertSystem == "qf_mdt" then
			local alertSources = GetJobSources(Config.AlarmSettings.Police.jobs)
			for i, policesrc in ipairs(alertSources) do
				TriggerClientEvent('qf_mdt/addDispatchAlert', -1, alarmcoords, "Alarm w domu", 'W czyimś domu uruchomił się alarm, sprawdź to!', '10-90', 'rgb(251, 201, 43)', '3')
			end
		end
	end
end

function RobberyAlert(propertyid, robberyside)
	local houselocationhandler = housinglocations[tostring(propertyid)]
	local alarmcoords = houselocationhandler.enter.coords
	if houselocationhandler.propertytype == "MLO" then
		alarmcoords = houselocationhandler.managment.coords
	end	
	if robberyside == "owner" then
		local online, serverId = IsIdentifierOnline(houselocationhandler.owner)
		if online then		
			if Config.AlertSystem == "default" then
				TriggerClientEvent("rtx_housing:Notify", serverId, "warning", Language[Config.Language]["robbery"], LanguageFile("robberyalert", houselocationhandler.propertyname, houselocationhandler.adress))	
				TriggerClientEvent("rtx_housing:Global:AlarmBlip",serverId, propertyid, alarmcoords)
			end
		end
	elseif robberyside == "police" then
		if Config.AlertSystem == "default" then
			local alertSources = GetJobSources(Config.AlarmSettings.Police.jobs)
			for i, policesrc in ipairs(alertSources) do
				TriggerClientEvent("rtx_housing:Notify", policesrc, "warning", Language[Config.Language]["robbery"], LanguageFile("robberyalert", houselocationhandler.propertyname, houselocationhandler.adress))	
				TriggerClientEvent("rtx_housing:Global:AlarmBlip",policesrc, propertyid, alarmcoords)		
			end
		elseif Config.AlertSystem == "qf_mdt" then
			local alertSources = GetJobSources(Config.AlarmSettings.Police.jobs)
			for i, policesrc in ipairs(alertSources) do
				TriggerClientEvent('qf_mdt/addDispatchAlert', -1, alarmcoords, "Alarm w domu", 'W czyimś domu uruchomił się alarm, prawdopodobnie trwa włam!', '10-90', 'rgb(251, 201, 43)', '3')
			end
		end
	end
end