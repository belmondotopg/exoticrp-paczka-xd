if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

Bridge = {
    getSource = function(identifier)
        local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
        if xPlayer then
            return xPlayer.source
        end
    end,
    getIdentifier = function(playerId)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            return xPlayer.identifier
        end
    end,
    getPlyByIdentifier = function(identifier)
        local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
        if xPlayer then
            return xPlayer
        end
    end,
    getPlyByUniqueId = function(uniqueId)
        local success, result = pcall(MySQL.single.await, 'SELECT * FROM users WHERE ssn = ?', {uniqueId})
        if not success then
            local success2, result2 = pcall(MySQL.single.await, 'SELECT * FROM users WHERE id = ?', {uniqueId})
            if success2 then
                result = result2
            end
        end

        return result or nil
    end,
    getName = function(playerId)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            return xPlayer.getName()
        end

        return 'Unknown'
    end,
    getOfflineName = function(identifier)
        local result = MySQL.single.await('SELECT firstname, lastname FROM users WHERE identifier = ?', {identifier})
        if result then
            return ('%s %s'):format(result.firstname, result.lastname)
        end

        return 'Unknown'
    end,
    getPlayerJob = function(playerId)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            return {
                jobName = xPlayer.job.name,
                jobLabel = xPlayer.job.label,
                jobGrade = xPlayer.job.grade,
                jobGradeLabel = xPlayer.job.grade_label
            }
        end
    end,
    getMoney = function(playerId, account)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            return xPlayer.getAccount(account).money
        end
    end,
    addMoney = function(playerId, account, amount)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            xPlayer.addAccountMoney(account, amount)
            return true
        end

        return false
    end,
    removeMoney = function(playerId, account, amount)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            xPlayer.removeAccountMoney(account, amount)
            return true
        end

        return false
    end,
    searchCitizens = function(value)
        value = value:lower()
        local citizens = {}
        local result = MySQL.query.await([[
            SELECT users.*, jobs.label AS job_label, doj_citizen_profiles.picture FROM users
            LEFT JOIN jobs ON users.job = jobs.name
            LEFT JOIN doj_citizen_profiles ON doj_citizen_profiles.player = users.identifier
            WHERE LOWER(users.firstname) LIKE "%]]..value..[[%" 
            OR LOWER(users.lastname) LIKE "%]]..value..[[%"
            OR CONCAT(users.firstname, ' ', users.lastname) LIKE "%]]..value..[[%"
        ]])
        for i = 1, #result, 1 do
            local wanted = false
            if GetResourceState('piotreq_gpt') == 'started' then
                local row = MySQL.single.await('SELECT * FROM gpt_citizens_wanted WHERE player = ?', {result[i].identifier})
                if row then
                    wanted = true
                end
            elseif GetResourceState('origen_police') == 'started' then
                wanted = result[i].wanted == 1 and true or false
            elseif GetResourceState('redutzu-mdt') == 'started' then
                local row = MySQL.single.await('SELECT * FROM mdt_bolos WHERE player = ?', {result[i].identifier})
                if row then
                    wanted = true
                end
            end
            citizens[i] = {
                identifier = result[i].identifier,
                picture = result[i].picture,
                firstName = result[i].firstname,
                lastName = result[i].lastname,
                name = ('%s %s'):format(result[i].firstname, result[i].lastname),
                birthdate = result[i].dateofbirth,
                job = result[i].job_label,
                bank = result[i].accounts and json.decode(result[i].accounts).bank or 0,
                wanted = wanted
            }
        end
        return citizens
    end,
    getCitizenDetails = function(identifier)
        local data = {info = {}}
        local result = MySQL.single.await(
        [[
        SELECT users.*, doj_citizen_profiles.* FROM users
        LEFT JOIN doj_citizen_profiles ON users.identifier = doj_citizen_profiles.player
        WHERE users.identifier = ?
        ]], {identifier})

        if not result then
            lib.print.error(('Player with identifier %s not found'):format(identifier))
            return data
        end

        local jobData = MySQL.single.await('SELECT * FROM jobs WHERE name = ?', {result.job})
        -- THIS INFO WILL BE DISPLAYED IN CITIZEN DETAILS [MAX 9!]
        -- YOU CAN EDIT IT FOR WHATEVER YOU WANT :)

        local phoneNumber = result.phone_number or locale('no_data')
        if GetResourceState('yseries') == 'started' then
            phoneNumber = exports['yseries']:GetPhoneNumberByIdentifier(identifier)
        elseif GetResourceState('lb-phone') == 'started' then
            local phone = MySQL.single.await('SELECT phone_number FROM phone_phones WHERE owner_id = ?', {identifier})
            phoneNumber = phone and phone.phone_number or locale('no_data')
        elseif GetResourceState('roadphone') == 'started' then
            phoneNumber = exports['roadphone']:getNumberFromIdentifier(identifier)
        elseif GetResourceState('piotreq_phone') == 'started' then
            phoneNumber = result.phone_number
        elseif GetResourceState('gksphone') == 'started' then
            local phoneData = exports["gksphone"]:GetPhoneDataByCitizenID(identifier)
            if phoneData then
                phoneNumber = phoneData.phone_number
            end
        end

        data.info = {
            {label = locale('first_name'), value = result.firstname},
            {label = locale('last_name'), value = result.lastname},
            {label = locale('birthdate'), value = result.dateofbirth},
            {label = locale('job'), value = jobData.label},
            {label = locale('phone_number'), value = phoneNumber},
            {label = locale('nationality'), value = result.nationality},
            {label = locale('gender'), value = result.sex == 'm' and locale('male') or locale('female')},
            {label = locale('bank_balance'), money = true, value = result.accounts and json.decode(result.accounts).bank or 0},
            {label = locale('identifier'), value = result.ssn or result.id or result.identifier},
        }

        data.firstName = result.firstname
        data.lastName = result.lastname
        data.identifier = result.identifier
        data.birthdate = result.dateofbirth
        data.job = result.job
        bank = result.accounts and json.decode(result.accounts).bank or 0
        data.picture = result.picture or nil
        data.notes = result.notes and json.decode(result.notes) or {}
        data.tags = result.tags and json.decode(result.tags) or {}
        if GetResourceState('bcs_licensemanager') == 'started' then
            data.licenses = MySQL.query.await('SELECT * FROM licenses WHERE owner = ?', {identifier})
        else
            data.licenses = MySQL.query.await('SELECT * FROM user_licenses WHERE owner = ?', {identifier})
        end
        data.vehicles = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = ?', {identifier})
        data.properties = {}

        if GetResourceState('qs-housing') == 'started' then
            local plyProperties = MySQL.query.await('SELECT * FROM player_houses WHERE owner = ?', {identifier})
            for k, v in pairs(plyProperties) do
                data.properties[#data.properties + 1] = {
                    name = v.house
                }
            end
        elseif GetResourceState('vms_housing') == 'started' then
            local properties = exports['vms_housing']:GetPlayerProperties(identifier)
            for k, v in pairs(properties) do
                data.properties[#data.properties + 1] = {
                    name = v.name
                }
            end
        end

        data.notes = Pages.Citizens.checkNotes(data.identifier, data.notes)
        table.sort(data.notes, function(a, b) return b.id < a.id end)

        for k, v in pairs(data.vehicles) do
            v.vehicleModel = v.vehicle and json.decode(v.vehicle).model or nil
        end

        for k, v in pairs(data.licenses) do
            if GetResourceState('bcs_licensemanager') == 'started' then
                v.label = Config.Citizens.Licenses[v.license] or ('%s License'):format(v.license)
            else
                v.label = Config.Citizens.Licenses[v.type] or ('%s License'):format(v.type)
            end
        end

        return data
    end,
    searchVehicles = function(value)
        value = value:lower()
        local vehicles = {}
        local result = MySQL.query.await([[
            SELECT owned_vehicles.*, users.firstname, users.lastname, doj_vehicle_profiles.picture FROM owned_vehicles
            LEFT JOIN users ON owned_vehicles.owner = users.identifier
            LEFT JOIN doj_vehicle_profiles ON owned_vehicles.plate = doj_vehicle_profiles.plate
            WHERE LOWER(owned_vehicles.plate) LIKE "%]]..value..[[%"
        ]])
        for i = 1, #result, 1 do
            local wanted = false
            if GetResourceState('piotreq_gpt') == 'started' then
                local row = MySQL.single.await('SELECT * FROM gpt_vehicles_wanted WHERE vin = ?', {result[i].vin})
                if row then
                    wanted = true
                end
            elseif GetResourceState('origen_police') == 'started' then
                wanted = result[i].wanted == 1 and true or false
            end
            vehicles[i] = {
                owner = result[i].firstname and ('%s %s'):format(result[i].firstname, result[i].lastname) or locale('no_data'),
                plate = result[i].plate,
                model = result[i].vehicle and json.decode(result[i].vehicle).model or locale('no_data'),
                picture = result[i].picture or nil,
                wanted = wanted
            }
        end
        return vehicles
    end,
    getVehicleDetails = function(plate)
        local data = {}
        local result = MySQL.single.await([[
            SELECT owned_vehicles.*, users.firstname, users.lastname, doj_vehicle_profiles.picture, 
            doj_vehicle_profiles.notes, doj_vehicle_profiles.tags, doj_vehicle_profiles.ownership FROM owned_vehicles
            LEFT JOIN users ON owned_vehicles.owner = users.identifier
            LEFT JOIN doj_vehicle_profiles ON owned_vehicles.plate = doj_vehicle_profiles.plate
            WHERE owned_vehicles.plate = ?
        ]], {plate})
        if GetResourceState('piotreq_gpt') == 'started' then
            data.wanted = MySQL.single.await('SELECT * FROM gpt_vehicles_wanted WHERE vin = ?', {result.vin})
        elseif GetResourceState('origen_police') == 'started' then
            data.wanted = data.wanted == 1 and true or false
        end
        
        data.picture = result and result.picture or nil
        data.notes = result and result.notes and json.decode(result.notes) or {}
        data.tags = result and result.tags and json.decode(result.tags) or {}
        data.ownership = result and result.ownership and json.decode(result.ownership) or {}
        data.ownerIdentifier = result and result.owner or nil
        data.model = result and result.vehicle and json.decode(result.vehicle).model or nil
        data.plate = plate

        data.info = {
            {label = locale('plate'), value = plate},
            {label = locale('owner'), citizen = true, value = result and Bridge.getOfflineName(result.owner) or locale('no_data')},
            {label = locale('co_owner'), citizen = true, value = locale('no_data')},
            {label = locale('vin'), value = result and result.vin or locale('no_data')},
            {label = locale('wanted'), type = 'badge', color = data.wanted and 'red' or 'green', value = data.wanted and locale('yes') or locale('no')},
        }

        for i = 1, #data.ownership, 1 do
            data.ownership[i].date = os.date('%d-%m-%Y %H:%M', data.ownership[i].time)
        end

        data.notes = Pages.Vehicles.checkNotes(plate, data.notes)
        table.sort(data.notes, function(a, b) return b.id < a.id end)
        
        return data
    end,
    getVehicleOwner = function(plate)
        local result = MySQL.single.await('SELECT owner FROM owned_vehicles WHERE plate = ?', {plate})
        if result then
            return result.owner
        end
        return nil
    end,
    getEmployees = function(playerId, jobName)
        local employees = {}
        local result = MySQL.query.await([[
            SELECT users.*, job_grades.label AS job_grade_label, doj_employee_profiles.picture AS picture FROM users
            LEFT JOIN job_grades ON users.job = job_grades.job_name AND users.job_grade = job_grades.grade
            LEFT JOIN doj_employee_profiles ON doj_employee_profiles.identifier = users.identifier
            WHERE users.job = ?
        ]], {jobName})
        for i = 1, #result, 1 do
            local player = ESX.GetPlayerFromIdentifier(result[i].identifier)
            employees[i] = {
                identifier = result[i].identifier,
                grade_number = tonumber(result[i].job_grade),
                picture = result[i].picture or nil,
                grade = result[i].job_grade_label,
                name = ('%s %s'):format(result[i].firstname, result[i].lastname),
                birthdate = result[i].dateofbirth,
                status = player and 1 or 0
            }
        end

        -- sorting by grade and status ;)
        table.sort(employees, function(a, b)
            if a.grade_number == b.grade_number then
                return a.status > b.status
            end
            return a.grade_number > b.grade_number
        end)
        
        return employees
    end,
    getEmployeeDetails = function(playerId, data)
        local result = MySQL.single.await([[
            SELECT users.*, job_grades.label AS job_grade_label FROM users
            LEFT JOIN job_grades ON users.job = job_grades.job_name AND users.job_grade = job_grades.grade
            WHERE users.identifier = ?
        ]], {data.identifier})
        if not result then
            lib.print.error(('Player with identifier %s not found'):format(data.identifier))
            return
        end

        local profile = MySQL.single.await('SELECT * FROM doj_employee_profiles WHERE identifier = ?', {data.identifier})
        if not profile then
            MySQL.insert('INSERT INTO doj_employee_profiles (identifier, notes, tags, licenses, joinDate) VALUES (?, ?, ?, ?, ?)', {
                data.identifier, '{}', '{}', '{}', os.date('%Y-%m-%d %H:%M:%S')
            })
            profile = {
                notes = {}, tags = {}, licenses = {}, joinDate = os.date('%Y-%m-%d %H:%M:%S')
            }
        else
            profile.notes = profile.notes and json.decode(profile.notes) or {}
            profile.tags = profile.tags and json.decode(profile.tags) or {}
            profile.licenses = profile.licenses and json.decode(profile.licenses) or {}
            profile.joinDate = profile.joinDate or os.date('%Y-%m-%d %H:%M:%S')

            local notes = {}
            local outdatedNotes = 0
            for k, v in pairs(profile.notes) do
                if v.expire and v.expire < os.time() then
                    outdatedNotes += 1
                else
                    notes[#notes + 1] = v
                end
            end

            if outdatedNotes > 0 then
                MySQL.update('UPDATE doj_employee_profiles SET notes = ? WHERE identifier = ?', {json.encode(notes), data.identifier})
            end
            profile.notes = notes
            table.sort(profile.notes, function(a, b) return a.id < b.id end)
        end

        local newLicenses = {}
        for license, _ in pairs(profile.licenses) do
            newLicenses[#newLicenses + 1] = {
                label = Config.Employees.Licenses[license] or ('%s License'):format(license),
                type = license,
            }
        end

        profile.licenses = newLicenses
        local player = ESX.GetPlayerFromIdentifier(result.identifier)
        return {
            identifier = result.identifier,
            firstName = result.firstname,
            lastName = result.lastname,
            grade = result.job_grade_label,
            notes = profile.notes,
            licenses = profile.licenses,
            tags = profile.tags,
            picture = profile.picture,
            joinDate = profile.joinDate,
            status = player and 1 or 0,
        }
    end,
    hireEmployee = function(playerId, data)
        local player = ESX.GetPlayerFromId(playerId)
        local grade = tonumber(data.grade)
        if player.job.grade < grade then
            Editable.showNotify(playerId, locale('too_low_grade_to_hire'), 'error')
            return false
        end

        local target = ESX.GetPlayerFromId(data.player)
        if target then
            local gradeData = Pages.Main.Jobs[player.job.name][grade]
            target.setJob(player.job.name, grade)
            Editable.showNotify(target.source, locale('you_are_hired', player.getName(), gradeData.label), 'success')
            return true
        else
            Editable.showNotify(playerId, locale('player_is_offline'), 'error')
            return false
        end
    end,
    promoteEmployee = function(playerId, data)
        local player = ESX.GetPlayerFromId(playerId)
        local grade = tonumber(data.grade)
        if player.job.grade < grade then
            Editable.showNotify(playerId, locale('too_low_grade_to_promote'), 'error')
            return false
        end

        local target = ESX.GetPlayerFromIdentifier(data.identifier)
        if target then
            local gradeData = Pages.Main.Jobs[player.job.name][grade]
            target.setJob(target.job.name, grade)
            Editable.showNotify(target.source, locale('you_are_promoted', gradeData.label, player.getName(), data.reason), 'success')
        end

        MySQL.update('UPDATE users SET job_grade = ? WHERE identifier = ? AND job = ?', {grade, data.identifier, target.job.name})
        return true
    end,
    fireEmployee = function(playerId, data)
        local player = ESX.GetPlayerFromId(playerId)

        local target = ESX.GetPlayerFromIdentifier(data.identifier)
        if target then
            if player.job.grade < target.job.grade then
                Editable.showNotify(playerId, locale('too_low_grade_to_fire'), 'error')
                return false
            end

            target.setJob('unemployed', 0)
            Editable.showNotify(target.source, locale('you_are_fired', player.getName()), 'inform')
        end

        MySQL.update('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {'unemployed', 0, data.identifier})
        return true
    end,
    getJobGrades = function()
        local jobs = {}
        local result = MySQL.query.await('SELECT * FROM job_grades')
        for i = 1, #result, 1 do
            if not jobs[result[i].job_name] then
                jobs[result[i].job_name] = {}
            end

            jobs[result[i].job_name][result[i].grade] = {
                label = result[i].label,
                grade = result[i].grade,
            }
        end

        return jobs
    end,
    getCompanies = function()
        local companies = {}
        if GetResourceState('p_banking') == 'started' then
            local result = MySQL.query.await([[
                SELECT p_bank_accounts.*, doj_companies.picture, doj_companies.invoices FROM p_bank_accounts
                LEFT JOIN doj_companies ON p_bank_accounts.name = doj_companies.name
                WHERE p_bank_accounts.type = "society"
            ]])
            for i = 1, #result, 1 do
                local data = result[i]
                local employees = MySQL.query.await([[
                    SELECT * FROM users WHERE job = ?
                ]], {data.name})
                data.owner = nil
                data.label = data.name
                data.employees = #employees
                data.invoices = data.invoices and json.decode(data.invoices) or {}
                data.picture = data.picture or nil
                for k, v in pairs(employees) do
                    local jobData = Pages.Main.Jobs[jobName]
                    local gradeData = jobData and jobData[tonumber(v.job_grade)] or nil
                    if gradeData then
                        if not jobData[tonumber(v.job_grade) + 1] then
                            data.owner = ('%s %s'):format(v.firstname, v.lastname)
                        end
                    end
                end
    
                if not data.owner then
                    data.owner = locale('no_owner')
                end
                companies[#companies + 1] = data
            end
        elseif GetResourceState('fd_banking') == 'started' then
            local result = MySQL.query.await([[
                SELECT fd_advanced_banking_accounts.*, doj_companies.picture, doj_companies.invoices FROM fd_advanced_banking_accounts
                LEFT JOIN doj_companies ON fd_advanced_banking_accounts.name = doj_companies.name
                WHERE fd_advanced_banking_accounts.type = "business"
            ]])
            for i = 1, #result, 1 do
                local data = result[i]
                local employees = MySQL.query.await([[
                    SELECT * FROM users WHERE job = ?
                ]], {data.business})
                data.employees = #employees
                data.invoices = data.invoices and json.decode(data.invoices) or {}
                data.picture = data.picture or nil
                for k, v in pairs(employees) do
                    local jobData = Pages.Main.Jobs[jobName]
                    local gradeData = jobData and jobData[tonumber(v.job_grade)] or nil
                    if gradeData then
                        if not jobData[tonumber(v.job_grade) + 1] then
                            data.owner = ('%s %s'):format(v.firstname, v.lastname)
                        end
                    end
                end
    
                if not data.owner then
                    data.owner = locale('no_owner')
                end
                companies[#companies + 1] = data
            end
        elseif GetResourceState('crm-banking') == 'started' then
            local result = MySQL.query.await([[
                SELECT crm_bank_accounts.*, doj_companies.picture, doj_companies.invoices FROM crm_bank_accounts
                LEFT JOIN doj_companies ON crm_bank_accounts.crm_name = doj_companies.name
                WHERE crm_bank_accounts.crm_type = "crm-society"
            ]])
            for i = 1, #result, 1 do
                local data = result[i]
                local employees = MySQL.query.await([[
                    SELECT * FROM users WHERE job = ?
                ]], {data.crm_name})
                data.label = result.crm_name
                data.employees = #employees
                data.invoices = data.invoices and json.decode(data.invoices) or {}
                data.picture = data.picture or nil
                for k, v in pairs(employees) do
                    local jobData = Pages.Main.Jobs[jobName]
                    local gradeData = jobData and jobData[tonumber(v.job_grade)] or nil
                    if gradeData then
                        if not jobData[tonumber(v.job_grade) + 1] then
                            data.owner = ('%s %s'):format(v.firstname, v.lastname)
                        end
                    end
                end
    
                if not data.owner then
                    data.owner = locale('no_owner')
                end
                companies[#companies + 1] = data
            end
        else
            local result = MySQL.query.await([[
                SELECT addon_account.*, addon_account_data.money AS balance, doj_companies.picture, doj_companies.invoices FROM addon_account
                LEFT JOIN addon_account_data ON addon_account_data.account_name = addon_account.name
                LEFT JOIN doj_companies ON addon_account.name = doj_companies.name
                WHERE addon_account.name LIKE 'society_%'
            ]])
            for i = 1, #result, 1 do
                local data = result[i]
                local jobName = data.name:gsub('society_', '')
                local employees = MySQL.query.await('SELECT * FROM users WHERE job = ?', {jobName})
                data.employees = #employees
                data.invoices = data.invoices and json.decode(data.invoices) or {}
                data.picture = data.picture or nil
                for k, v in pairs(employees) do
                    local jobData = Pages.Main.Jobs[jobName]
                    local gradeData = jobData and jobData[tonumber(v.job_grade)] or nil
                    if gradeData then
                        if not jobData[tonumber(v.job_grade) + 1] then
                            data.owner = ('%s %s'):format(v.firstname, v.lastname)
                        end
                    end
                end
                if not data.owner then
                    data.owner = locale('no_owner')
                end
                companies[#companies + 1] = data
            end
        end
        return companies
    end,
    transferVehicle = function(data)
        local affectedRows = MySQL.update.await('UPDATE owned_vehicles SET owner = ? WHERE plate = ? AND owner = ?', {
            data.newOwner, data.plate, data.oldOwner
        })
        if affectedRows > 0 then
            return true
        end
        return false
    end,
    addCitizenLicense = function(identifier, type)
        if GetResourceState('bcs_licensemanager') == 'started' then
            local Player = ESX.GetPlayerFromIdentifier(identifier)
            if Player then
                TriggerClientEvent('LicenseManager:client:AddLicense', Player.source, type)
                return true
            end
        else
            local row = MySQL.single.await('SELECT * FROM user_licenses WHERE owner = ? AND type = ?',
                { identifier, type })
            if row then
                return false
            end
        end

        MySQL.insert('INSERT INTO user_licenses (owner, type) VALUES (?, ?)', { identifier, type })

        return true
    end,
    removeCitizenLicense = function(identifier, type)
        if GetResourceState('bcs_licensemanager') == 'started' then
            exports.bcs_licensemanager:RevokeLicense(identifier, type, source)
            return true
        else
            local row = MySQL.single.await('SELECT * FROM user_licenses WHERE owner = ? AND type = ?',
                { identifier, type })
            if not row then
                return false
            end

            MySQL.update('DELETE FROM user_licenses WHERE owner = ? AND type = ?', { identifier, type })
            return true
        end
    end,
}