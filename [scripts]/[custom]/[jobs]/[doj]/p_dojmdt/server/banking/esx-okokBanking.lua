if GetResourceState('es_extended') ~= 'started' then return end
if GetResourceState('okokBanking') ~= 'started' then return end

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
        SELECT users.*, doj_accounts_note.note FROM users
        LEFT JOIN doj_accounts_note ON users.iban = doj_accounts_note.account
        WHERE users.firstname LIKE @value OR users.lastname LIKE @value
    ]], {
        ['@value'] = '%' .. data.value .. '%'
    })
    for i = 1, #result, 1 do
        local account = result[i]

        local accountName = Bridge.getOfflineName(account.identifier)
        lib.print.info(account.iban, accountName)
        financesData.accounts[#financesData.accounts + 1] = { -- BankAccount
            name = accountName,
            owner = accountName,
            number = account.iban,
            balance = json.decode(account.accounts).bank or 0,
            type = locale('personal'),
            note = account.note or '',
        }

        local history = MySQL.query.await('SELECT * FROM okokbanking_transactions WHERE receiver_identifier = @me OR sender_identifier = @me', {
            ['@me'] = account.identifier
        })
        if history then
            for k, v in pairs(history) do
                financesData.transactions[#financesData.transactions + 1] = { -- BankTransaction
                    id = v.id,
                    from = v.sender_name,
                    to = v.receiver_name,
                    title = v.receiver_identifier == account.identifier and v.sender_name or v.receiver_name,
                    amount = v.value,
                    type = v.type == 'deposit' and 'income' or v.type == 'withdraw' and 'outcome' or (v.type == 'transfer' and v.sender_identifier == account.identifier and 'outcome' or 'income'),
                    date = v.date,
                }
            end
        end
    end

    return financesData
end)

RegisterNetEvent('p_dojmdt/server/finances/saveAccountNote', function(data)
    local _source = source
    if not permissions or not permissions['save_account_note'] then
        Editable.showNotify(_source, locale('no_permissions'), 'error')
        return false
    end

    local row = MySQL.single.await('SELECT * FROM users WHERE iban = ?', {data.account})
    if row then
        MySQL.update('UPDATE doj_accounts_note SET note = ? WHERE account = ?', {data.note, data.account})
    else
        MySQL.insert('INSERT INTO doj_accounts_note (account, note) VALUES (?, ?)', {data.account, data.note})
    end
    Editable.showNotify(_source, locale('saved_account_note'), 'success')
end)

lib.callback.register('p_dojmdt/server/finances/chargeAccount', function(source, data)
    local _source = source
    local row = MySQL.single.await('SELECT * FROM users WHERE iban = ?', {data.account})
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
    local xPlayer = ESX.GetPlayerFromIdentifier(row.identifier)
    if xPlayer then
        xPlayer.removeAccountMoney('bank', data.amount)
        exports['p_dojmdt']:addMoney({from = xPlayer.getName(), amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
        return true
    else
        Editable.showNotify(_source, locale('player_is_offline'), 'error')
    end
    return false
end)

lib.callback.register('p_dojmdt/server/finances/donateAccount', function(source, data)
    local _source = source
    local row = MySQL.single.await('SELECT * FROM users WHERE iban = ?', {data.account})
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
    local xPlayer = ESX.GetPlayerFromIdentifier(row.identifier)
    if xPlayer then
        local money = exports['p_dojmdt']:getMoney(playerJob.jobName)
        if money < data.amount then
            Editable.showNotify(_source, locale('society_not_enough_money'), 'error')
            return false
        end

        xPlayer.addAccountMoney('bank', data.amount)
        exports['p_dojmdt']:removeMoney({to = xPlayer.getName(), amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
        return true
    else
        Editable.showNotify(_source, locale('player_is_offline'), 'error')
    end
    return false
end)