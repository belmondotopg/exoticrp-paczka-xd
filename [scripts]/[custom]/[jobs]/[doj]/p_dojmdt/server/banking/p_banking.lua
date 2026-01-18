if GetResourceState('p_banking') ~= 'started' then return end

---@class BankAccount
---@field name string
---@field owner string
---@field number string | number
---@field balance number
---@field type string

---@class BankTransaction
---@field id number
---@field from string
---@field to string
---@field title string
---@field amount number
---@field date string
---@field type income | outcome

lib.callback.register('p_dojmdt/server/finances/getFinances', function(source, data)
    local financesData = {accounts = {}, transactions = {}}
    local result = MySQL.query.await(string.format([[
        SELECT p_bank_accounts.*, doj_accounts_note.note FROM p_bank_accounts
        LEFT JOIN doj_accounts_note ON p_bank_accounts.iban = doj_accounts_note.account
        WHERE p_bank_accounts.name LIKE '%%%s%%'
           OR p_bank_accounts.owner LIKE '%%%s%%'
           OR p_bank_accounts.iban LIKE '%%%s%%'
           OR p_bank_accounts.type LIKE '%%%s%%'
    ]], data.value, data.value, data.value, data.value))
    for i = 1, #result, 1 do
        local account = result[i]
        local xPlayer = Bridge.getPlyByIdentifier(account.owner)
        local ownerName = Bridge.getOfflineName(account.owner)
        local ownerId = Bridge.getSource(account.owner)
        financesData.accounts[#financesData.accounts + 1] = { -- BankAccount
            name = account.name,
            owner = ownerName ~= 'Unknown' and ownerName or account.owner,
            number = account.iban,
            balance = ownerId and Bridge.getMoney(ownerId, 'bank') or account.balance,
            type = account.type == 'personal' and locale('personal') or locale('business'),
            note = account.note or '',
        }

        local history = json.decode(account.transactions) or {}
        if history then
            for k, v in pairs(history) do
                financesData.transactions[#financesData.transactions + 1] = { -- BankTransaction
                    id = v.id,
                    from = v.from,
                    to = v.to,
                    title = v.title,
                    amount = v.amount,
                    type = v.type,
                    date = os.date('%d-%m-%Y %H:%M', v.date),
                }
            end
        end
    end

    return financesData
end)

RegisterNetEvent('p_dojmdt/server/finances/saveAccountNote', function(data)
    local _source = source
    local permissions = Pages.Main.getPermissions(_source)
    if not permissions or not permissions['save_account_note'] then
        Editable.showNotify(_source, locale('no_permissions'), 'error')
        return false
    end

    local row = MySQL.single.await('SELECT * FROM doj_accounts_note WHERE account = ?', {data.account})
    if row then
        MySQL.update('UPDATE doj_accounts_note SET note = ? WHERE account = ?', {data.note, data.account})
    else
        MySQL.insert('INSERT INTO doj_accounts_note (account, note) VALUES (?, ?)', {data.account, data.note})
    end
    Editable.showNotify(_source, locale('saved_account_note'), 'success')
end)

lib.callback.register('p_dojmdt/server/finances/chargeAccount', function(source, data)
    local _source = source
    local row = MySQL.single.await('SELECT * FROM p_bank_accounts WHERE iban = ?', {data.account})
    if not row then
        Editable.showNotify(source, locale('account_not_found'), 'error')
        return false
    end

    local permissions = Pages.Main.getPermissions(_source)
    if not permissions or not permissions['charge_account'] then
        Editable.showNotify(_source, locale('no_permissions'), 'error')
        return false
    end

    data.amount = tonumber(data.amount)
    local playerJob = Bridge.getPlayerJob(_source)
    if row.type == 'personal' then
        local owner = Bridge.getPlyByIdentifier(row.owner)
        if owner then
            local ownerId = Bridge.getSource(row.owner)
            Bridge.removeMoney(ownerId, 'bank', data.amount)
            exports['p_dojmdt']:addMoney({from = row.name, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
            Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
            exports['p_banking']:createHistory({
                iban = row.iban, -- replace with existing account iban
                type = 'outcome', -- income / outcome
                amount = data.amount,
                title = 'Charged by Department of Justice',
                from = row.name,
                to = 'Department of Justice'
            })
            return true
        else
            Editable.showNotify(_source, locale('player_is_offline'), 'error')
        end
    else
        exports['p_dojmdt']:addMoney({from = row.name, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        row.balance = row.balance - data.amount
        MySQL.update('UPDATE p_bank_accounts SET balance = ? WHERE iban = ?', {row.balance, row.iban})
        Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
        exports['p_banking']:createHistory({
            iban = row.iban, -- replace with existing account iban
            type = 'outcome', -- income / outcome
            amount = data.amount,
            title = 'Charged by Department of Justice',
            from = row.name,
            to = 'Department of Justice'
        })
        return true
    end

    return false
end)

lib.callback.register('p_dojmdt/server/finances/donateAccount', function(source, data)
    local _source = source
    local row = MySQL.single.await('SELECT * FROM p_bank_accounts WHERE iban = ?', {data.account})
    if not row then
        Editable.showNotify(source, locale('account_not_found'), 'error')
        return false
    end

    local permissions = Pages.Main.getPermissions(_source)
    if not permissions or not permissions['donate_account'] then
        Editable.showNotify(_source, locale('no_permissions'), 'error')
        return false
    end

    data.amount = tonumber(data.amount)
    local playerJob = Bridge.getPlayerJob(_source)
    local societyMoney = exports['p_dojmdt']:getMoney(playerJob.jobName)

    if societyMoney < data.amount then
        Editable.showNotify(_source, locale('society_not_enough_money'), 'error')
        return false
    end

    if row.type == 'personal' then
        local owner = Bridge.getPlyByIdentifier(row.owner)
        if owner then
            local ownerId = Bridge.getSource(row.owner)
            Bridge.addMoney(ownerId, 'bank', data.amount)
            exports['p_dojmdt']:removeMoney({to = row.name, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
            Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
            exports['p_banking']:createHistory({
                iban = row.iban, -- replace with existing account iban
                type = 'income', -- income / outcome
                amount = data.amount,
                title = 'Donated by Department of Justice',
                from = row.name,
                to = 'Department of Justice'
            })
            return true
        else
            Editable.showNotify(_source, locale('player_is_offline'), 'error')
        end
    else
        exports['p_dojmdt']:removeMoney({to = row.name, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        row.balance = row.balance + data.amount
        MySQL.update('UPDATE p_bank_accounts SET balance = ? WHERE iban = ?', {row.balance, row.iban})
        Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
        exports['p_banking']:createHistory({
            iban = row.iban, -- replace with existing account iban
            type = 'income', -- income / outcome
            amount = data.amount,
            title = 'Donated by Department of Justice',
            from = row.name,
            to = 'Department of Justice'
        })
        return true
    end

    return false
end)