if GetResourceState('es_extended') ~= 'started' then return end
if GetResourceState('wasabi_banking') ~= 'started' then return end

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

    local accountsResult = MySQL.query.await([[
        SELECT users.*, users.identifier, doj_accounts_note.note 
        FROM users
        LEFT JOIN doj_accounts_note ON users.iban = doj_accounts_note.account
        WHERE users.firstname LIKE @value OR users.lastname LIKE @value
    ]], {
        ['@value'] = '%' .. data.value .. '%'
    })

    local transactionsResult = MySQL.query.await('SELECT * FROM wasabibanking_transactions')

    local transactionsByCitizen = {}
    for _, t in pairs(transactionsResult) do
        if not transactionsByCitizen[t.citizenid] then
            transactionsByCitizen[t.citizenid] = {}
        end
        table.insert(transactionsByCitizen[t.citizenid], t)
    end

    for _, account in ipairs(accountsResult) do
        financesData.accounts[#financesData.accounts + 1] = {
            name = ('%s %s'):format(account.firstname, account.lastname),
            owner = ('%s %s'):format(account.firstname, account.lastname),
            number = account.iban,
            balance = json.decode(account.accounts).bank or 0,
            type = locale('personal'),
            note = account.note or '',
        }

        local history = transactionsByCitizen[account.identifier]
        if history then
            for _, v in pairs(history) do
                financesData.transactions[#financesData.transactions + 1] = {
                    id = v.id,
                    from = v.citizenid,
                    to = v.account,
                    title = v.reason,
                    amount = v.amount,
                    type = v.type == 'withdraw' and 'outcome' or 'income',
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

    local playerJob = Bridge.getPlayerJob(_source)
    local playerSource = Bridge.getSource(row.identifier)
    local amount = tonumber(data.amount)

    if not amount then
        Editable.showNotify(_source, 'Montant invalide', 'error')
        return false
    end

    if playerSource then
        Bridge.removeMoney(playerSource, 'bank', amount)

        exports.wasabi_banking:Transaction(
            row.identifier,
            data.reason or 'Charged via DOJ MDT',
            amount,
            'sent',
            'personal'
        )

        exports['p_dojmdt']:addMoney({
            from = Bridge.getName(playerSource),
            amount = amount,
            jobName = playerJob.jobName,
            jobLabel = playerJob.jobLabel
        })

        Editable.showNotify(_source, locale('account_charged', amount, data.reason), 'success')
        return true
    else
        Editable.showNotify(_source, locale('player_is_offline'), 'error')
    end

    return false
end)

lib.callback.register('p_dojmdt/server/finances/donateAccount', function(source, data)
    local _source = source
    data.amount = tonumber(data.amount)
    
    local row = MySQL.single.await('SELECT * FROM users WHERE iban = ?', {data.account})
    if not row then
        Editable.showNotify(_source, locale('account_not_found'), 'error')
        return false
    end

    local permissions = Pages.Main.getPermissions(_source)
    if not permissions or not permissions['donate_account'] then
        Editable.showNotify(_source, locale('no_permissions'), 'error')
        return false
    end

    local playerJob = Bridge.getPlayerJob(_source)
    local societyMoney = exports['p_dojmdt']:getMoney(playerJob.jobName)

    if societyMoney < data.amount then
        Editable.showNotify(_source, locale('society_not_enough_money'), 'error')
        return false
    end

    local playerSource = Bridge.getSource(row.identifier)

    if playerSource then
        Bridge.addMoney(playerSource, 'bank', data.amount)

        exports.wasabi_banking:Transaction(
            row.identifier,
            data.reason or 'Charged via DOJ MDT',
            data.amount,
            'received',
            'personal'
        )

        exports['p_dojmdt']:removeMoney({
            to = Bridge.getName(playerSource), 
            amount = data.amount, 
            jobName = playerJob.jobName, 
            jobLabel = playerJob.jobLabel
        })

        Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
        return true
    else
        Editable.showNotify(_source, locale('player_is_offline'), 'error')
    end

    return false
end)
