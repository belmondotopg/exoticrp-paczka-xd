if GetResourceState('qb-core') ~= 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()

Bridge = {
    getSource = function(identifier)
        local xPlayer = QBCore.Functions.GetPlayerByCitizenId(identifier)
        if xPlayer then
            return xPlayer.PlayerData.source
        end
    end,
    getIdentifier = function(playerId)
        local player = QBCore.Functions.GetPlayer(playerId)
        if player then
            return player.PlayerData.citizenid
        end
    end,
    getPlyByIdentifier = function(identifier)
        local player = QBCore.Functions.GetPlayerByCitizenId(identifier)
        if player then
            return player
        end
    end,
    getPlyByUniqueId = function(uniqueId)
        uniqueId = uniqueId:upper()
        local result = MySQL.single.await('SELECT * FROM players WHERE citizenid = ?', {uniqueId})
        lib.print.info(uniqueId, result)
        if result then
            result.charinfo = result.charinfo and json.decode(result.charinfo) or {}
            result.firstname = result.charinfo.firstname
            result.lastname = result.charinfo.lastname
        end
        return result or nil
    end,
    getName = function(playerId)
        local player = QBCore.Functions.GetPlayer(playerId)
        if player then
            return ('%s %s'):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)
        end

        return 'Unknown'
    end,
    getOfflineName = function(identifier)
        local result = MySQL.single.await([[
            SELECT JSON_UNQUOTE(JSON_EXTRACT(charinfo, "$.firstname")) AS firstname, 
            JSON_UNQUOTE(JSON_EXTRACT(charinfo, "$.lastname")) AS lastname 
            FROM players WHERE citizenid = ?
        ]], {identifier})
        if result then
            return ('%s %s'):format(result.firstname, result.lastname)
        end

        return 'Unknown'
    end,
    getPlayerJob = function(playerId)
        local player = QBCore.Functions.GetPlayer(playerId)
        if player then
            return {
                jobName = player.PlayerData.job.name,
                jobLabel = player.PlayerData.job.label,
                jobGrade = tonumber(player.PlayerData.job.grade.level),
                jobGradeLabel = player.PlayerData.job.grade.name
            }
        end
    end,
    getMoney = function(playerId, account)
        if account == 'money' then
            account = 'cash'
        end

        local player = QBCore.Functions.GetPlayer(playerId)
        if player then
            local money = player.PlayerData.money[account] or 0
            return money
        end
    end,
    addMoney = function(playerId, account, amount)
        if account == 'money' then
            account = 'cash'
        end

        local player = QBCore.Functions.GetPlayer(playerId)
        if player then
            player.Functions.AddMoney(account, amount, 'doj')
            return true
        end

        return false
    end,
    removeMoney = function(playerId, account, amount)
        if account == 'money' then
            account = 'cash'
        end

        local player = QBCore.Functions.GetPlayer(playerId)
        if player then
            player.Functions.RemoveMoney(account, amount, 'doj')
            return true
        end

        return false
    end,
    searchCitizens = function(value)
        value = value:lower()
        local citizens = {}
        local result = MySQL.query.await([[
            SELECT players.*, doj_citizen_profiles.picture FROM players
            LEFT JOIN doj_citizen_profiles ON doj_citizen_profiles.player = players.citizenid
            WHERE LOWER(JSON_UNQUOTE(JSON_EXTRACT(players.charinfo, "$.firstname"))) LIKE "%]]..value..[[%" 
            OR LOWER(JSON_UNQUOTE(JSON_EXTRACT(players.charinfo, "$.lastname"))) LIKE "%]]..value..[[%"
            OR CONCAT(JSON_UNQUOTE(JSON_EXTRACT(players.charinfo, "$.firstname")), ' ', JSON_UNQUOTE(JSON_EXTRACT(players.charinfo, "$.lastname"))) 
            LIKE "%]]..value..[[%"
        ]])
        for i = 1, #result, 1 do
            local charinfo = result[i].charinfo and json.decode(result[i].charinfo) or {}
            local wanted = false
            if GetResourceState('piotreq_gpt') == 'started' then
                local row = MySQL.single.await('SELECT * FROM gpt_citizens_wanted WHERE player = ?', {result[i].citizenid})
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
                identifier = result[i].citizenid,
                picture = result[i].picture,
                firstName = charinfo.firstname or locale('no_data'),
                lastName = charinfo.lastname or locale('no_data'),
                name = ('%s %s'):format(charinfo.firstname, charinfo.lastname),
                birthdate = charinfo.birthdate or locale('no_data'),
                job = json.decode(result[i].job).label,
                bank = result[i].money and json.decode(result[i].money).bank or 0,
                wanted = wanted
            }
        end
        return citizens
    end,
    getCitizenDetails = function(identifier)
        local data = {info = {}}
        local result = MySQL.single.await(
        [[
        SELECT players.*, doj_citizen_profiles.* FROM players
        LEFT JOIN doj_citizen_profiles ON players.citizenid = doj_citizen_profiles.player
        WHERE players.citizenid = ?
        ]], {identifier})

        if not result then
            lib.print.error(('Player with identifier %s not found'):format(identifier))
            return data
        end

        -- THIS INFO WILL BE DISPLAYED IN CITIZEN DETAILS [MAX 9!]
        -- YOU CAN EDIT IT FOR WHATEVER YOU WANT :)
        local charinfo = result.charinfo and json.decode(result.charinfo) or {}

        local phoneNumber = locale('no_data')
        if GetResourceState('yseries') == 'started' then
            phoneNumber = exports['yseries']:GetPhoneNumberByIdentifier(identifier)
        elseif GetResourceState('lb-phone') == 'started' then
            local phone = MySQL.single.await('SELECT phone_number FROM phone_phones WHERE owner_id = ?', {identifier})
            phoneNumber = phone and phone.phone_number or locale('no_data')
        elseif GetResourceState('roadphone') == 'started' then
            phoneNumber = exports['roadphone']:getNumberFromIdentifier(identifier)
        else
            phoneNumber = charinfo.phone
        end

        data.info = {
            {label = locale('first_name'), value = charinfo.firstname},
            {label = locale('last_name'), value = charinfo.lastname},
            {label = locale('birthdate'), value = charinfo.birthdate},
            {label = locale('job'), value = result.job and json.decode(result.job).label or locale('no_data')},
            {label = locale('phone_number'), value = phoneNumber},
            {label = locale('nationality'), value = result.nationality or 'USA'},
            {label = locale('gender'), value = charinfo.gender == 0 and locale('male') or locale('female')},
            {label = locale('bank_balance'), money = true, value = result.money and json.decode(result.money).bank or 0},
            {label = locale('identifier'), value = result.citizenid},
        }

        data.firstName = charinfo.firstname
        data.lastName = charinfo.lastname
        data.identifier = result.citizenid
        data.birthdate = charinfo.birthdate
        data.job = result.job
        data.bank = result.money and json.decode(result.money).bank or 0
        data.picture = result.picture or nil
        data.notes = result.notes and json.decode(result.notes) or {}
        data.tags = result.tags and json.decode(result.tags) or {}

        local licenses = {}
        local metadata = json.decode(result.metadata)
        for k, v in pairs(metadata.licences) do
            licenses[#licenses + 1] = {type = k, label = Config.Citizens.Licenses[k] or ('%s License'):format(k)}
        end

        data.licenses = licenses
        data.vehicles = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', {identifier})

        data.properties = {}

        local success, result = pcall(MySQL.query.await, 'SELECT * FROM apartaments WHERE citizenid = '..identifier)
        if success and result then
            for k, v in pairs(result) do
                data.properties[#data.properties + 1] = {name = v.label}
            end
        end

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
            v.vehicleModel = v.vehicle or nil
        end

        return data
    end,
    searchVehicles = function(value)
        value = value:lower()
        local vehicles = {}
        local result = MySQL.query.await([[
            SELECT player_vehicles.*, JSON_UNQUOTE(JSON_EXTRACT(players.charinfo, "$.firstname")) AS firstname, 
            JSON_UNQUOTE(JSON_EXTRACT(players.charinfo, "$.lastname")) AS lastname, doj_vehicle_profiles.picture FROM player_vehicles
            LEFT JOIN players ON player_vehicles.citizenid = players.citizenid
            LEFT JOIN doj_vehicle_profiles ON player_vehicles.plate = doj_vehicle_profiles.plate
            WHERE LOWER(player_vehicles.plate) LIKE "%]]..value..[[%"
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
                model = result[i].vehicle or locale('no_data'),
                picture = result[i].picture or nil,
                wanted = wanted
            }
        end
        return vehicles
    end,
    getVehicleDetails = function(plate)
        local data = {}
        local result = MySQL.single.await([[
            SELECT player_vehicles.*, JSON_UNQUOTE(JSON_EXTRACT(players.charinfo, "$.firstname")) AS firstname, 
            JSON_UNQUOTE(JSON_EXTRACT(players.charinfo, "$.lastname")) AS lastname, doj_vehicle_profiles.picture, 
            doj_vehicle_profiles.notes, doj_vehicle_profiles.tags, doj_vehicle_profiles.ownership FROM player_vehicles
            LEFT JOIN players ON player_vehicles.citizenid = players.citizenid
            LEFT JOIN doj_vehicle_profiles ON player_vehicles.plate = doj_vehicle_profiles.plate
            WHERE player_vehicles.plate = ?
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
        data.ownerIdentifier = result and result.citizenid or nil
        data.model = result and result.vehicle or nil
        data.plate = plate

        data.info = {
            {label = locale('plate'), value = plate},
            {label = locale('owner'), citizen = true, value = result and Bridge.getOfflineName(result.citizenid) or locale('no_data')},
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
        local result = MySQL.single.await('SELECT citizenid FROM player_vehicles WHERE plate = ?', {plate})
        if result then
            return result.citizenid
        end
        return nil
    end,
    getEmployees = function(playerId, jobName)
        local employees = {}
        local result = MySQL.query.await([[
            SELECT players.*, doj_employee_profiles.picture AS picture FROM players
            LEFT JOIN doj_employee_profiles ON doj_employee_profiles.identifier = players.citizenid
            WHERE JSON_UNQUOTE(JSON_EXTRACT(players.job, "$.name")) = ?
        ]], {jobName})
        for i = 1, #result, 1 do
            local player = QBCore.Functions.GetPlayerByCitizenId(result[i].citizenid)
            local charinfo = result[i].charinfo and json.decode(result[i].charinfo) or {}
            employees[i] = {
                identifier = result[i].citizenid,
                grade_number = tonumber(json.decode(result[i].job).grade.level),
                picture = result[i].picture or nil,
                grade = json.decode(result[i].job).grade.name,
                name = ('%s %s'):format(charinfo.firstname, charinfo.lastname),
                birthdate = charinfo.birthdate,
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
            SELECT * FROM players WHERE citizenid = ?
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
        local player = QBCore.Functions.GetPlayerByCitizenId(data.identifier)
        local charinfo = result.charinfo and json.decode(result.charinfo) or {}
        return {
            identifier = data.identifier,
            firstName = charinfo.firstname,
            lastName = charinfo.lastname,
            grade = json.decode(result.job).grade.name,
            notes = profile.notes,
            licenses = profile.licenses,
            tags = profile.tags,
            picture = profile.picture,
            joinDate = profile.joinDate,
            status = player and 1 or 0,
        }
    end,
    hireEmployee = function(playerId, data)
        local player = QBCore.Functions.GetPlayer(playerId)
        local grade = tonumber(data.grade)
        if player.PlayerData.job.grade.level < grade then
            Editable.showNotify(playerId, locale('too_low_grade_to_hire'), 'error')
            return false
        end

        data.player = tonumber(data.player)
        local target = QBCore.Functions.GetPlayer(data.player)
        if target then
            local gradeData = Pages.Main.Jobs[player.PlayerData.job.name][grade]
            target.Functions.SetJob(player.PlayerData.job.name, grade)
            Editable.showNotify(target.PlayerData.source, locale('you_are_hired', player.Functions.GetName(), gradeData.label), 'success')
            return true
        else
            Editable.showNotify(playerId, locale('player_is_offline'), 'error')
            return false
        end
    end,
    promoteEmployee = function(playerId, data)
        local player = QBCore.Functions.GetPlayer(playerId)
        local grade = tonumber(data.grade)
        if player.PlayerData.job.grade.level < grade then
            Editable.showNotify(playerId, locale('too_low_grade_to_promote'), 'error')
            return false
        end

        local target = QBCore.Functions.GetPlayerByCitizenId(data.identifier)
        if target then
            local gradeData = Pages.Main.Jobs[player.PlayerData.job.name][grade]
            target.Functions.SetJob(target.PlayerData.job.name, grade)
            Editable.showNotify(target.PlayerData.source, locale('you_are_promoted', gradeData.label, player.Functions.GetName(), data.reason), 'success')
        end

        local row = MySQL.single.await('SELECT job FROM players WHERE citizenid = ?', {data.identifier})
        if row then
            local jobData = json.decode(row.job)
            jobData.grade.level = grade
            MySQL.update('UPDATE players SET job = ? WHERE citizenid = ?', {json.encode(jobData), data.identifier})
            return true
        end

        return false
    end,
    fireEmployee = function(playerId, data)
        local player = QBCore.Functions.GetPlayer(playerId)
        local target = QBCore.Functions.GetPlayerByCitizenId(data.identifier)
        if target then
            if player.PlayerData.job.grade.level < target.PlayerData.job.grade.level then
                Editable.showNotify(playerId, locale('too_low_grade_to_fire'), 'error')
                return false
            end

            target.Functions.SetJob('unemployed', 0)
            Editable.showNotify(target.PlayerData.source, locale('you_are_fired', player.Functions.GetName()), 'inform')
        end

        local jobData = QBCore.Shared.Jobs['unemployed']
        MySQL.update('UPDATE players SET job = ? WHERE citizenid = ?', {json.encode({
            name = 'unemployed',
            label = jobData.label,
            grade = jobData.grades['0'],
            grade_label = jobData.grades['0'].name,
            on_duty = false,
            isboss = false,
            payment = jobData.grades['0'].payment,
        }), data.identifier})
        return true
    end,
    getJobGrades = function()
        local jobs = {}
        local result = QBCore.Shared.Jobs
        for job, data in pairs(result) do
            if not jobs[job] then
                jobs[job] = {}
            end

            for grade, gradeData in pairs(data.grades) do
                jobs[job][grade] = {
                    label = gradeData.name,
                    grade = grade,
                }
            end
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
                    SELECT * FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(job, "$.name")) = ?
                ]], {data.name})
                data.owner = nil
                data.label = data.name
                data.employees = #employees
                data.invoices = data.invoices and json.decode(data.invoices) or {}
                data.picture = data.picture or nil
                for k, v in pairs(employees) do
                    if json.decode(v.job).grade.isboss then
                        data.owner = ('%s %s'):format(json.decode(v.charinfo).firstname, json.decode(v.charinfo).lastname)
                        break
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
                    SELECT * FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(job, "$.name")) = ?
                ]], {data.crm_name})
                data.label = data.crm_name
                data.employees = #employees
                data.invoices = data.invoices and json.decode(data.invoices) or {}
                data.picture = data.picture or nil
                for k, v in pairs(employees) do
                    if json.decode(v.job).grade.isboss then
                        data.owner = ('%s %s'):format(json.decode(v.charinfo).firstname, json.decode(v.charinfo).lastname)
                        break
                    end
                end
    
                if not data.owner then
                    data.owner = locale('no_owner')
                end
                companies[#companies + 1] = data
            end
        elseif GetResourceState('Renewed-Banking') == 'started' then
            local result = MySQL.query.await([[
                SELECT bank_accounts_new.*, doj_companies.picture, doj_companies.invoices FROM bank_accounts_new
                LEFT JOIN doj_companies ON bank_accounts_new.id = doj_companies.name
            ]])
            for i = 1, #result, 1 do
                local data = result[i]
                local employees = MySQL.query.await([[
                    SELECT * FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(job, "$.name")) = ?
                ]], {data.id})
                data.label = data.id
                data.employees = #employees
                data.invoices = data.invoices and json.decode(data.invoices) or {}
                data.picture = data.picture or nil
                for k, v in pairs(employees) do
                    if json.decode(v.job).grade.isboss then
                        data.owner = ('%s %s'):format(json.decode(v.charinfo).firstname, json.decode(v.charinfo).lastname)
                        break
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
                    SELECT * FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(job, "$.name")) = ?
                ]], {data.business})
                data.label = data.name
                data.employees = #employees
                data.invoices = data.invoices and json.decode(data.invoices) or {}
                data.picture = data.picture or nil
                for k, v in pairs(employees) do
                    if json.decode(v.job).grade.isboss then
                        data.owner = ('%s %s'):format(json.decode(v.charinfo).firstname, json.decode(v.charinfo).lastname)
                        break
                    end
                end
    
                if not data.owner then
                    data.owner = locale('no_owner')
                end
                companies[#companies + 1] = data
            end
        elseif GetResourceState('snipe-banking') == 'started' then
            local result = MySQL.query.await([[
                SELECT banking_accounts.*, doj_companies.picture, doj_companies.invoices FROM banking_accounts
                LEFT JOIN doj_companies ON banking_accounts.account = doj_companies.name
            ]])
            for i = 1, #result, 1 do
                local data = result[i]
                local employees = MySQL.query.await([[
                    SELECT * FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(job, "$.name")) = ?
                ]], {data.account})
                data.label = (data.label and data.label ~= '') and data.label or data.account
                data.balance = data.amount
                data.employees = #employees
                data.invoices = data.invoices and json.decode(data.invoices) or {}
                data.picture = data.picture or nil
                for k, v in pairs(employees) do
                    if json.decode(v.job).grade.isboss then
                        data.owner = ('%s %s'):format(json.decode(v.charinfo).firstname, json.decode(v.charinfo).lastname)
                        break
                    end
                end
    
                if not data.owner then
                    data.owner = locale('no_owner')
                end
                companies[#companies + 1] = data
            end
        else
            local result = MySQL.query.await([[
                SELECT bank_accounts.*, doj_companies.picture, doj_companies.invoices FROM bank_accounts
                LEFT JOIN doj_companies ON bank_accounts.account_name = doj_companies.name
                WHERE bank_accounts.account_type = "job"
            ]])
            for i = 1, #result, 1 do
                local data = result[i]
                local employees = MySQL.query.await([[
                    SELECT * FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(job, "$.name")) = ?
                ]], {data.account_name})
                data.label = data.account_name
                data.balance = data.account_balance
                data.employees = #employees
                data.invoices = data.invoices and json.decode(data.invoices) or {}
                data.picture = data.picture or nil
                for k, v in pairs(employees) do
                    if json.decode(v.job).grade.isboss then
                        data.owner = ('%s %s'):format(json.decode(v.charinfo).firstname, json.decode(v.charinfo).lastname)
                        break
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
        local affectedRows = MySQL.update.await('UPDATE player_vehicles SET citizenid = ? WHERE plate = ? AND citizenid = ?', {
            data.newOwner, data.plate, data.oldOwner
        })
        if affectedRows > 0 then
            return true
        end
        return false
    end,
    addCitizenLicense = function(identifier, type)
        local player = QBCore.Functions.GetPlayerByCitizenId(identifier)
        if player then
            local licences = player.PlayerData.metadata.licences
            licences[type] = true
            player.Functions.SetMetaData('licences', licences)
            if GetResourceState('bcs_licensemanager') == 'started' then
                TriggerClientEvent('LicenseManager:addLicense', player.source, type)
            end
            return true
        else
            local row = MySQL.single.await('SELECT metadata FROM players WHERE citizenid = ?', {identifier})
            if row then
                local metadata = json.decode(row.metadata)
                if not metadata.licences then
                    metadata.licences = {}
                end
                metadata.licences[type] = true
                MySQL.update('UPDATE players SET metadata = ? WHERE citizenid = ?', {json.encode(metadata), identifier})

                return true
            end
        end

        return false
    end,
    removeCitizenLicense = function(identifier, type)
        local player = QBCore.Functions.GetPlayerByCitizenId(identifier)
        if player then
            local licences = player.PlayerData.metadata.licences
            licences[type] = nil
            player.Functions.SetMetaData('licences', licences)
            if GetResourceState('bcs_licensemanager') == 'started' then
                MySQL.update('DELETE FROM licenses WHERE owner = ? AND type = ?', {identifier, type})
            end
            return true
        else
            local row = MySQL.single.await('SELECT metadata FROM players WHERE citizenid = ?', {identifier})
            if row then
                local metadata = json.decode(row.metadata)
                if not metadata.licences then
                    metadata.licences = {}
                end
                metadata.licences[type] = nil
                MySQL.update('UPDATE players SET metadata = ? WHERE citizenid = ?', {json.encode(metadata), identifier})
                if GetResourceState('bcs_licensemanager') == 'started' then
                    MySQL.update('DELETE FROM licenses WHERE owner = ? AND type = ?', {identifier, type})
                end
                return true
            end
        end
        
        return false
    end,
}