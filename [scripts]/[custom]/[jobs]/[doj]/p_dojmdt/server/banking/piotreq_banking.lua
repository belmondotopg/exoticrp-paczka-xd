if GetResourceState('piotreq_banking') ~= 'started' then return end

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
        LEFT JOIN doj_accounts_note ON users.account_number = doj_accounts_note.account
        WHERE users.firstname LIKE @value OR users.lastname LIKE @value OR users.account_number LIKE @value
    ]], {
        ['@value'] = '%' .. data.value .. '%'
    })
    for i = 1, #result, 1 do
        local account = result[i]
        local xPlayer = Bridge.getPlyByIdentifier(account.identifier)
        financesData.accounts[#financesData.accounts + 1] = { -- BankAccount
            name = ('%s %s'):format(account.firstname, account.lastname),
            owner = ('%s %s'):format(account.firstname, account.lastname),
            number = account.account_number,
            balance = xPlayer and xPlayer.getAccount('bank').money or json.decode(account.accounts).bank,
            type = locale('personal'),
            note = account.note or '',
        }

        local history = MySQL.query.await('SELECT * FROM bank_history WHERE number = ?', {account.account_number})
        if history then
            for k, v in pairs(history) do
                financesData.transactions[#financesData.transactions + 1] = { -- BankTransaction
                    id = v.id,
                    from = v.sender,
                    to = ('%s %s'):format(account.firstname, account.lastname),
                    title = v.title,
                    amount = v.amount,
                    type = v.type == 1 and 'income' or 'outcome',
                    date = os.date('%d-%m-%Y %H:%M', v.time),
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
    local row = MySQL.single.await('SELECT * FROM users WHERE account_number = ?', {data.account})
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
    local owner = Bridge.getPlyByIdentifier(row.identifier)
    if owner then
        exports['p_dojmdt']:addMoney({from = owner.getName(), amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        owner.removeAccountMoney('bank', data.amount)
        Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
        Editable.showNotify(owner.source, locale('your_account_charged', data.amount, data.reason), 'inform')
        return true
    end

    return false
end)

lib.callback.register('p_dojmdt/server/finances/donateAccount', function(source, data)
    local _source = source
    local row = MySQL.single.await('SELECT * FROM users WHERE account_number = ?', {data.account})
    if not row then
        Editable.showNotify(source, locale('account_not_found'), 'error')
        return false
    end

    local permissions = Pages.Main.getPermissions(_source)
    if not permissions or not permissions['donate_account'] then
        Editable.showNotify(_source, locale('no_permissions'), 'error')
        return false
    end

    local playerJob = Bridge.getPlayerJob(_source)
    local societyMoney = exports['p_dojmdt']:getMoney(playerJob.jobName)
    data.amount = tonumber(data.amount)

    if societyMoney < data.amount then
        Editable.showNotify(_source, locale('society_not_enough_money'), 'error')
        return false
    end

    local owner = Bridge.getPlyByIdentifier(row.identifier)
    if owner then
        exports['p_dojmdt']:removeMoney({to = owner.getName(), amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        owner.addAccountMoney('bank', data.amount)
        Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
        Editable.showNotify(owner.source, locale('account_donated', data.amount, data.reason), 'inform')
        return true
    end
    return false
end)