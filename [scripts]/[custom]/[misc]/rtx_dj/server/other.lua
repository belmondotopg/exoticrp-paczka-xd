function GetPlayerIdentifierRTX(playersource)
	local playeridentifierdata = ""
	if Config.Framework == "esx" then
		local xPlayer = ESX.GetPlayerFromId(playersource)
		if xPlayer then
			playeridentifierdata = xPlayer.identifier
		end
	elseif Config.Framework == "qbcore" then
		local xPlayer = QBCore.Functions.GetPlayer(playersource)
		if xPlayer then	
			playeridentifierdata = xPlayer.PlayerData.citizenid
		end
	elseif Config.Framework == "standalone" then
		playeridentifierdata = GetPlayerIdentifiers(playersource)[1]	
	end
	return playeridentifierdata
end

function GetPlayerNameRTX(playersource)
	return GetPlayerName(playersource)
end

function CheckDjCreatorPermission(playersource)
	local permission = false
	if Config.Framework == "esx" then
		local xPlayer = ESX.GetPlayerFromId(playersource)
		local playergroup = xPlayer.getGroup()
		if playergroup == "founder" then
			permission = true
		end
        if xPlayer.job.name == 'bahama_mamas' and xPlayer.job.grade >= 4 then
            permission = true
        end
	elseif Config.Framework == "qbcore" then
		if QBCore.Functions.HasPermission(playersource, 'admin') or QBCore.Functions.HasPermission(playersource, 'god') then
			permission = true
		end
	elseif Config.Framework == "standalone" then
		-- configure your permissions here
	end	
	if Config.IngameCreatorNoPermission == true then
		permission = true
	end
	return permission
end


local function GetPlayerJobName(src)
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

local function GetIdentifierSet(src)
    local set = {}
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        set[string.lower(id)] = true
    end
    return set
end

function PlayerHasLocationAccess(src, locId)
    local loc = Config.DjLocations[tonumber(locId)]
    if not loc then return false end

    local permNode = loc.permissions or {}
    if permNode.everyone == true then
        return true
    end

    local rules = permNode.permissions or {}
    if type(rules) ~= "table" or #rules == 0 then
        return false
    end

    local ids  = GetIdentifierSet(src)
    local job  = GetPlayerJobName(src)
    local ljob = job and string.lower(job) or nil

    for _, rule in ipairs(rules) do
        local rtype = tostring(rule.permissiontype or ""):lower()
        local rperm = tostring(rule.permission or rule[1] or "")

        if rtype == "ace" then
            if rperm ~= "" and IsPlayerAceAllowed(src, rperm) then
                return true
            end

        elseif rtype == "job" then
            if ljob and rperm ~= "" and ljob == string.lower(rperm) then
                return true
            end

        elseif rtype == "identifier" then
            local key = string.lower(rperm)
            if key ~= "" and ids[key] then
                return true
            end
        end
    end

    return false
end
