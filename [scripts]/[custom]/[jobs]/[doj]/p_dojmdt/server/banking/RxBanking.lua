if GetResourceState('RxBanking') ~= 'started' then return end

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

local transactionTypes = {
    ['payment'] = 'outcome',
    ['deposit'] = 'income',
    ['withdraw'] = 'outcome',
    ['transfer'] = 'outcome',
    ['interest'] = 'income' 
}

lib.callback.register('p_dojmdt/server/finances/getFinances', function(source, data)
    local financesData = {accounts = {}, transactions = {}}
    local result = MySQL.query.await([[
        SELECT rx_banking_accounts.*, doj_accounts_note.note FROM rx_banking_accounts
        LEFT JOIN doj_accounts_note ON rx_banking_accounts.iban = doj_accounts_note.account
        WHERE rx_banking_accounts.name LIKE @value
           OR rx_banking_accounts.owner LIKE @value
           OR rx_banking_accounts.iban LIKE @value
           OR rx_banking_accounts.type LIKE @value
    ]], {
        ['@value'] = '%' .. data.value .. '%'
    })
    for i = 1, #result, 1 do
        local account = result[i]
        local xPlayer = Bridge.getPlyByIdentifier(account.owner)
        local ownerName = Bridge.getOfflineName(account.owner)
        local ownerId = Bridge.getSource(account.owner)
        financesData.accounts[#financesData.accounts + 1] = { -- BankAccount
            name = ownerName ~= 'Unknown' and ownerName or account.owner,
            owner = ownerName ~= 'Unknown' and ownerName or account.owner,
            number = account.iban,
            balance = account.balance,
            type = account.type == 'personal' and locale('personal') or locale('business'),
            note = account.note or '',
        }

        local history = MySQL.single.await('SELECT * FROM rx_banking_transactions WHERE fromIban = @me OR toIban = @me', {
            ['@me'] = account.iban
        })
        if history then
            for k, v in pairs(history) do
                financesData.transactions[#financesData.transactions + 1] = { -- BankTransaction
                    id = v.id,
                    from = v.fromIban,
                    to = v.toIban,
                    title = v.reason,
                    amount = v.amount,
                    type = transactionTypes[v.type] or 'income',
                    date = os.date('%d-%m-%Y %H:%M', v.createdAt),
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
    local row = MySQL.single.await('SELECT * FROM rx_banking_accounts WHERE iban = ?', {data.account})
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
    if row.society then
        exports['RxBanking']:RemoveSocietyMoney(row.society, data.amount, 'payment', 'Charged Account')
        exports['p_dojmdt']:addMoney({from = row.owner, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
    else
        exports['RxBanking']:RemoveAccountMoney(data.account, data.amount, 'payment', 'Charged Account')
        exports['p_dojmdt']:addMoney({from = row.owner, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
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

    if row.society then
        exports['RxBanking']:AddSocietyMoney(row.society, data.amount, 'transfer', 'Donated Account')
        exports['p_dojmdt']:removeMoney({to = row.owner, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
    else
        exports['RxBanking']:AddAccountMoney(data.account, data.amount, 'transfer', 'Donated Account')
        exports['p_dojmdt']:removeMoney({to = row.owner, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
        return true
    end

    return false
end)