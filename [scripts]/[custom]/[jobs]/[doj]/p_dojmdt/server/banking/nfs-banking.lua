if GetResourceState('nfs-banking') ~= 'started' then return end

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
        SELECT banking_cards.*, doj_accounts_note.note FROM banking_cards
        LEFT JOIN doj_accounts_note ON banking_cards.iban = doj_accounts_note.account
        WHERE banking_cards.name LIKE @value
           OR banking_cards.iban LIKE @value
           OR banking_cards.type LIKE @value
    ]], {
        ['@value'] = '%' .. data.value .. '%'
    })
    for i = 1, #result, 1 do
        local account = result[i]
        account.data = json.decode(account.data)

        local ownerName = Bridge.getOfflineName(account.owner)
        financesData.accounts[#financesData.accounts + 1] = { -- BankAccount
            name = ownerName,
            owner = ownerName,
            number = account.iban,
            balance = account.data.balance,
            type = locale('personal'),
            note = account.note or '',
        }

        local history = MySQL.single.await('SELECT * FROM banking_transactions WHERE iban = @me', {
            ['@me'] = account.iban
        })
        if history then
            local historyData = json.decode(history.data)
            for k, v in pairs(historyData) do
                financesData.transactions[#financesData.transactions + 1] = { -- BankTransaction
                    id = v.id,
                    from = v.type == 'deposit' and ownerName or 'SYSTEM',
                    to = v.type == 'withdraw' and ownerName or 'SYSTEM',
                    title = v.note,
                    amount = v.amount,
                    type = v.type == 'withdraw' and 'outcome' or 'income',
                    date = os.date('%H:%M %d/%m/%Y', v.date),
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

    local row = MySQL.single.await('SELECT * FROM banking_cards WHERE iban = ?', {data.account})
    if row then
        MySQL.update('UPDATE doj_accounts_note SET note = ? WHERE account = ?', {data.note, data.account})
    else
        MySQL.insert('INSERT INTO doj_accounts_note (account, note) VALUES (?, ?)', {data.account, data.note})
    end
    Editable.showNotify(_source, locale('saved_account_note'), 'success')
end)

lib.callback.register('p_dojmdt/server/finances/chargeAccount', function(source, data)
    local _source = source
    local row = MySQL.single.await('SELECT * FROM banking_cards WHERE iban = ?', {data.account})
    if not row then
        Editable.showNotify(source, locale('account_not_found'), 'error')
        return false
    end

    local permissions = Pages.Main.getPermissions(_source)
    if not permissions or not permissions['charge_account'] then
        Editable.showNotify(_source, locale('no_permissions'), 'error')
        return false
    end

    local playerJob = Bridge.getPlayerJob(_source)
    data.amount = tonumber(data.amount)
    exports['nfs-banking']:addBalance(data.account, data.amount, {transaction = true, note = 'DOJ'})
    exports['p_dojmdt']:addMoney({from = row.name, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
    Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
    return true
end)

lib.callback.register('p_dojmdt/server/finances/donateAccount', function(source, data)
    local _source = source
    local row = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts WHERE iban = ?', {data.account})
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
    data.amount = tonumber(data.amount)
    exports['nfs-banking']:addBalance(data.account, data.amount, {transaction = true, note = 'DOJ'})
    exports['p_dojmdt']:removeMoney({to = row.name, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
    Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
    return true
end)