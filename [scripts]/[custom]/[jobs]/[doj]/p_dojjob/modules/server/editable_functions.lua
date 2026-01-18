Editable = {
    showNotify = function(playerId, text, type)
        TriggerClientEvent('ox_lib:notify', playerId, {
            title = locale('notification'),
            description = text,
            type = type or 'inform'
        })
    end,
    registerStash = function(data)
        if GetResourceState('ox_inventory') == 'started' then
            exports['ox_inventory']:RegisterStash(data.id, data.label, data.slots, data.weight, data.owner)
        end
    end,
    addItem = function(playerId, itemName, itemCount, metadata)
        if GetResourceState('ox_inventory') == 'started' then
            exports['ox_inventory']:AddItem(playerId, itemName, itemCount, metadata)
        elseif GetResourceState('qb-inventory') == 'started' then
            exports['qb-inventory']:AddItem(playerId, itemName, itemCount, nil, metadata)
        elseif GetResourceState('ps-inventory') == 'started' then
            exports['ps-inventory']:AddItem(playerId, itemName, itemCount, nil, metadata)
        elseif GetResourceState('jpr-inventory') == 'started' then
            exports['jpr-inventory']:AddItem(playerId, itemName, itemCount, nil, metadata)
        elseif GetResourceState('qs-inventory') == 'started' then
            exports['qs-inventory']:AddItem(playerId, itemName, itemCount, nil, metadata)
        elseif GetResourceState('tgiann-inventory') == 'started' then
            exports['tgiann-inventory']:AddItem(playerId, itemName, itemCount, nil, metadata)
        elseif GetResourceState('codem-inventory') == 'started' then
            exports['codem-inventory']:AddItem(playerId, itemName, itemCount, nil, metadata)
        end
    end
}

local itemsFunctions = {
    ['printer_document'] = function(playerId, item)
        local metadata = item.metadata or item.info
        if metadata and metadata.url then
            TriggerClientEvent('p_dojjob/client_printer/displayPhoto', playerId, metadata)
        end
    end
}

Citizen.CreateThread(function()
    if GetResourceState('ox_inventory') ~= 'missing' then return end
    for k, v in pairs(itemsFunctions) do
        if ESX then
            ESX.RegisterUsableItem(k, v)
        elseif QBCore then
            QBCore.Functions.CreateUseableItem(k, v)
        end
    end
end)

RegisterNetEvent('p_dojjob/server/openInventory', function(data)
    if GetResourceState('tgiann-inventory') == 'started' then
        if data.owner then
            exports['tgiann-inventory']:OpenInventory(source, "stash", data.id..'_'..data.owner)
        else
            exports['tgiann-inventory']:OpenInventory(source, "stash", data)
        end
    end
end)

lib.callback.register('p_dojjob/server/fetchJobData', function(source)
    local _source = source
    local playerJob = Bridge.getPlayerJob(_source)
    local serverData = {
        grades = {},
        jobName = playerJob and playerJob.jobName or nil,
        licenses = {}
    }
    if GetResourceState('p_dojmdt') == 'started' then
        local licenses = exports['p_dojmdt']:getLicenses()
        for k, v in pairs(licenses) do
            serverData.licenses[#serverData.licenses + 1] = {
                value = k,
                label = v.label
            }
        end
    end
    if Config.Framework == 'ESX' then
        local job_grades = MySQL.query.await('SELECT * FROM job_grades')
        for i = 1, #job_grades, 1 do
            local job_grade = job_grades[i]
            if job_grade.job_name == serverData.jobName then
                serverData.grades[#serverData.grades + 1] = {
                    value = tostring(job_grade.grade),
                    label = job_grade.label
                }
            end
        end
    elseif Config.Framework == 'QB' then
        local QBCore = exports['qb-core']:GetCoreObject()
        for jobName, jobData in pairs(QBCore.Shared.Jobs) do
            for grade, gradeInfo in pairs(jobData.grades) do
                if jobName == serverData.jobName then
                    serverData.grades[#serverData.grades + 1] = {
                        value = tostring(grade),
                        label = gradeInfo.name
                    }
                end
            end
        end
    elseif Config.Framework == 'QBOX' then
        for jobName, jobData in pairs(exports['qbx_core']:GetJobs()) do
            for grade, gradeInfo in pairs(jobData.grades) do
                if jobName == serverData.jobName then
                    serverData.grades[#serverData.grades + 1] = {
                        value = tostring(grade),
                        label = gradeInfo.name
                    }
                end
            end
        end
    end

    return serverData
end)

RegisterNetEvent('p_dojjob/server/createOutfit', function(data, skin)
    local _source = source
    local grades = {}
    local licenses = nil
    for i = 1, #data[2], 1 do
        grades[tostring(data[2][i])] = true
    end
    if data[5] then
        licenses = {}
        for i = 1, #data[5], 1 do
            licenses[data[5][i]] = true
        end
    end
    local id = MySQL.insert.await(
        'INSERT INTO doj_outfits (job, grade, label, gender, license, requirements, skin) VALUES (@job, @grade, @label, @gender, @license, @requirements, @skin)', {
        ['@job'] = data[1],
        ['@grade'] = json.encode(grades),
        ['@label'] = data[3],
        ['@gender'] = data[4],
        ['@license'] = licenses and json.encode(licenses) or 'none',
        ['@requirements'] = data[6],
        ['@skin'] = json.encode(skin)
    })
    if id then
        Editable.showNotify(_source, locale('outfit_created', data[3], data[1]), 'success')
    end
end)

lib.callback.register('p_dojjob/server/getOutfits', function(source, playerGender)
    local _source = source
    local playerJob = Bridge.getPlayerJob(_source)
    local outfits = {}
    local result = MySQL.query.await('SELECT * FROM doj_outfits WHERE job = ?', {playerJob.jobName})
    for i = 1, #result, 1 do
        local outfit = result[i]
        if playerGender == outfit.gender then
            local grades = json.decode(outfit.grade)
            local licenses = outfit.license ~= 'none' and json.decode(outfit.license) or nil
            local hasGrade, hasLicense = grades[tostring(playerJob.jobGrade)], false
            if (outfit.requirements == 'required_grade' or outfit.requirements == 'required_both') and not hasGrade then
                goto skip
            end
            
            if outfit.requirements == 'required_license' or outfit.requirements == 'required_both' then
                if licenses then
                    local identifier = Bridge.getIdentifier(_source)
                    local row = MySQL.single.await('SELECT * FROM doj_employee_profiles WHERE identifier = ?', {identifier})
                    if not row then
                        goto skip
                    end
                    local plyLicenses = row.licenses and json.decode(row.licenses) or {}
                    for k, v in pairs(plyLicenses) do
                        if licenses[k] then
                            hasLicense = true
                            break
                        end
                    end
                end
    
                if not hasLicense then
                    goto skip
                end
            end
    
            outfits[#outfits + 1] = {
                label = outfit.label,
                skin = outfit.skin
            }
        end

        ::skip::
    end
    return outfits
end)

lib.callback.register('p_dojjob/server/fetchAllOutfits', function()
    local result = MySQL.query.await('SELECT * FROM doj_outfits')
    return result
end)

RegisterNetEvent('p_dojjob/server/removeOutfits', function(outfits)
    local _source = source
    local playerJob = Bridge.getPlayerJob(_source)
	if not Config.WardrobePermissions[playerJob.jobName] or Config.WardrobePermissions[playerJob.jobName] > tonumber(playerJob.jobGrade) then
		return
	end

    local data = {}
    for i = 1, #outfits do
        data[i] = {outfits[i]}
    end
    MySQL.prepare('DELETE FROM doj_outfits WHERE id = ?', data)
    Editable.showNotify(_source, locale('outfits_removed'), 'success')
end)