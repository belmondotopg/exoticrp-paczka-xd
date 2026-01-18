local ESX = ESX
local RegisterNetEvent = RegisterNetEvent

RegisterNetEvent('esx_hud:sendWalletData', function(value, __src, title,cwel)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local sendSource = __src
    
    if __src == 'me' then
        sendSource = src
    end

    local licensesSQL = MySQL.query.await('SELECT type FROM user_licenses WHERE owner = ?', {xPlayer.identifier})
    local phoneNumber = MySQL.single.await('SELECT phone_number FROM users WHERE identifier = ?', {xPlayer.identifier})
    local licenses = {
        ['a'] = false,
        ['b'] = false,
        ['c'] = false,
        ['weapon'] = false,
    }

    for k, v in pairs(licensesSQL) do
        if v.type == 'drive' then
            licenses['b'] = true
        elseif v.type == 'drive_bike' then
            licenses['a'] = true
        elseif v.type == 'drive_truck' then
            licenses['c'] = true
        elseif v.type == 'weapon' then
            licenses['weapon'] = true
        end
    end

    local esx_menu = exports.esx_menu

    local data = {
        type = value,
        firstname = xPlayer.get('firstName'),
        lastname = xPlayer.get('lastName'),
        dob = xPlayer.get('dateofbirth'),
        gender = string.upper(xPlayer.get('sex')),
        nationality = xPlayer.get('nationality'),
        grade = (not (xPlayer.job.name:find("org") or xPlayer.job.name:find("gang")) and xPlayer.job.grade_label) or "Nieznane",
        badge = xPlayer.badge,
        avatar = '',
        licenses = licenses,
        phonenumber = phoneNumber.phone_number,
        haveOC = esx_menu:CheckInsuranceLSC(xPlayer.source),
        haveNNW = esx_menu:CheckInsuranceEMS(xPlayer.source),
        job = (not (xPlayer.job.name:find("org") or xPlayer.job.name:find("gang")) and xPlayer.job.label) or "Nieznane"
    }

    if value == 'weapon' and not licenses['weapon'] then
        xPlayer.showNotification('Nie posiadasz licencji na broń!')
        return
    end

    if value == 'dmv' and not licenses['a'] and not licenses['b'] and not licenses['c'] then
        xPlayer.showNotification('Nie posiadasz prawa jazdy!')
        return
    end

    xPlayer.showNotification('Przeglądasz '..title)

    TriggerClientEvent('esx_hud:animSend', src, data)


    TriggerClientEvent('esx_hud:walletSend', sendSource, data,cwel)

end)

RegisterServerEvent("esx_hud:sv:id:forceShow", function (serverId)
    local src = source

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local tPlayer = ESX.GetPlayerFromId(serverId)
    if not tPlayer then return end

    local count = exports.ox_inventory:Search(xPlayer.source, 'count', 'handcuffs')

    if not count then return end
    
	if count and count <= 0 then
		return
	end

    TriggerClientEvent('esx_hud:cl:id:forceShow', tPlayer.source, xPlayer.source)
end)

RegisterServerEvent('esx_hud:updateMugshotImage', function (mugshotImage, update, pdId, identifier)
    local src = source
    local xPlayer = nil

    if pdId then xPlayer = ESX.GetPlayerFromId(pdId) else xPlayer = ESX.GetPlayerFromId(src) end

    local selectIdentifier = identifier or (xPlayer and xPlayer.identifier)
    if not selectIdentifier then return end

    local getMugshotId = MySQL.single.await('SELECT id FROM users WHERE identifier = ?', {identifier})
    if not getMugshotId then return end

    local getMugshotPhoto = MySQL.single.await('SELECT img FROM users_mugshots WHERE id = ?', {getMugshotId.id})
    if not getMugshotPhoto then MySQL.query('INSERT INTO users_mugshots (id, img) VALUES (?, ?) ON DUPLICATE KEY UPDATE img = VALUES(img)', {getMugshotId.id, tostring(mugshotImage)}) end

    if update then MySQL.update('UPDATE users_mugshots SET img = ? WHERE id = ?', {tostring(mugshotImage), getMugshotId.id}) end
end)

lib.callback.register('esx_hud/getMugshot', function(source, identifier)
    local xPlayer = ESX.GetPlayerFromId(source)

    local targetIdentifier = identifier or (xPlayer and xPlayer.identifier)
    if not targetIdentifier then return nil end

    local getMugshotID = MySQL.single.await('SELECT id FROM users WHERE identifier = ?', {targetIdentifier})
    if not getMugshotID then return nil end

    local getMugshotPhoto = MySQL.single.await('SELECT img FROM users_mugshots WHERE id = ?', {getMugshotID.id})
    if not getMugshotPhoto then return nil end

    return getMugshotPhoto.img
end)

lib.callback.register('esx_hud/getLastLocation', function(source, identifier)
    local xPlayer = ESX.GetPlayerFromId(source)

    local targetIdentifier = identifier or (xPlayer and xPlayer.identifier)
    if not targetIdentifier then return nil end

    local result = MySQL.single.await('SELECT position FROM users WHERE identifier = ?', {targetIdentifier})
    if not result then return nil end

    return result.position
end)

lib.callback.register('esx_hud/getLastJob', function(source, identifier)
    local xPlayer = ESX.GetPlayerFromId(source)

    local targetIdentifier = identifier or (xPlayer and xPlayer.identifier)
    if not targetIdentifier then return nil end

    local result = MySQL.single.await('SELECT job FROM users WHERE identifier = ?', {targetIdentifier})
    if not result then return nil end

    return ESX.GetJobLabelFromName(result.job)
end)