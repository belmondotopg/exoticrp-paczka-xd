if GetResourceState('es_extended') == 'started' then return end
if GetResourceState('qs-banking') ~= 'started' then return end

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
    local result = MySQL.query.await([[
        SELECT bank_accounts.*, doj_accounts_note.note FROM players
        LEFT JOIN doj_accounts_note ON bank_accounts.account_name = doj_accounts_note.account
        WHERE bank_accounts.account_type != 'job'
            AND (bank_accounts.account_name LIKE @value OR bank_accounts.citizenid LIKE @value)
    ]], {
        ['@value'] = '%' .. data.value .. '%'
    })
    for i = 1, #result, 1 do
        local account = result[i]

        local accountName = Bridge.getOfflineName(account.citizenid)
        financesData.accounts[#financesData.accounts + 1] = { -- BankAccount
            name = accountName,
            owner = accountName,
            number = account.citizenid,
            balance = account.account_balance,
            type = locale('personal'),
            note = account.note or '',
        }

        local history = MySQL.query.await('SELECT * FROM bank_statements WHERE account_name = @me', {
            ['@me'] = account.account_name
        })
        if history then
            for k, v in pairs(history) do
                financesData.transactions[#financesData.transactions + 1] = { -- BankTransaction
                    id = v.id,
                    from = v.statement_type == 'withdraw' and accountName or 'SYSTEM',
                    to = v.statement_type == 'deposit' and accountName or 'SYSTEM',
                    title = v.reason,
                    amount = v.amount,
                    type = v.statement_type == 'withdraw' and 'outcome' or 'income',
                    date = v.date,
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

    local row = MySQL.single.await('SELECT * FROM bank_accounts WHERE citizenid = ?', {data.account})
    if row then
        MySQL.update('UPDATE doj_accounts_note SET note = ? WHERE account = ?', {data.note, data.account})
    else
        MySQL.insert('INSERT INTO doj_accounts_note (account, note) VALUES (?, ?)', {data.account, data.note})
    end
    Editable.showNotify(_source, locale('saved_account_note'), 'success')
end)

lib.callback.register('p_dojmdt/server/finances/chargeAccount', function(source, data)
    local _source = source
    local row = MySQL.single.await('SELECT * FROM bank_accounts WHERE citizenid = ?', {data.account})
    if not row then
        Editable.showNotify(_source, locale('account_not_found'), 'error')
        return false
    end

    local permissions = Pages.Main.getPermissions(_source)
    if not permissions or not permissions['charge_account'] then
        Editable.showNotify(_source, locale('no_permissions'), 'error')
        return false
    end

    data.amount = tonumber(data.amount)
    local playerJob = Bridge.getPlayerJob(_source)
    local xPlayer = Bridge.getPlyByIdentifier(row.citizenid)
    if xPlayer then
        Bridge.removeMoney(xPlayer.PlayerData.source, 'bank', data.amount)
        exports['p_dojmdt']:addMoney({
            from = Bridge.getName(xPlayer.PlayerData.source), amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel
        })
        Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
        return true
    else
        Editable.showNotify(_source, locale('player_is_offline'), 'error')
    end
    return false
end)

lib.callback.register('p_dojmdt/server/finances/donateAccount', function(source, data)
    local _source = source
    local row = MySQL.single.await('SELECT * FROM bank_accounts WHERE citizenid = ?', {data.account})
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
    local xPlayer = Bridge.getPlyByIdentifier(row.citizenid)
    if xPlayer then
        local money = exports['p_dojmdt']:getMoney(playerJob.jobName)
        if money < data.amount then
            Editable.showNotify(_source, locale('society_not_enough_money'), 'error')
            return false
        end

        Bridge.addMoney(xPlayer.PlayerData.source, 'bank', data.amount)
        exports['p_dojmdt']:removeMoney({
            to = Bridge.getName(xPlayer.PlayerData.source), amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel
        })
        Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
        return true
    else
        Editable.showNotify(_source, locale('player_is_offline'), 'error')
    end
    return false
end)