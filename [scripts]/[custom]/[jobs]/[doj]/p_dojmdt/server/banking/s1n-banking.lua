if GetResourceState('s1n_banking') ~= 'started' then return end

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
        SELECT s1n_bank_accounts.*, doj_accounts_note.note FROM
        s1n_bank_accounts
        LEFT JOIN doj_accounts_note ON s1n_bank_accounts.iban = doj_accounts_note.account
        WHERE s1n_bank_accounts.name LIKE @value
           OR s1n_bank_accounts.owner LIKE @value
           OR s1n_bank_accounts.iban LIKE @value
           OR s1n_bank_accounts.type LIKE @value
    ]], {
        ['@value'] = '%' .. data.value .. '%'
    })
    for i = 1, #result, 1 do
        local account = result[i]

        financesData.accounts[#financesData.accounts + 1] = { -- BankAccount
            name = account.name,
            owner = account.owner,
            number = account.iban,
            balance = account.balance,
            type = account.type == 'useraccount' and locale('personal') or locale('business'),
            note = account.note or '',
        }

        local history = MySQL.query.await('SELECT * FROM s1n_bank_statements WHERE iban = ?', {account.iban})
        if history then
            for k, v in pairs(history) do
                financesData.transactions[#financesData.transactions + 1] = { -- BankTransaction
                    id = v.id,
                    from = 'SYSTEM',
                    to = account.name,
                    title = v.title,
                    amount = v.amount,
                    type = v.action:find('withdraw') and 'outcome' or 'income',
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
    local row = MySQL.single.await('SELECT * FROM s1n_bank_accounts WHERE iban = ?', {data.account})
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
    if row.type == 'useraccount' then
        local playerSource = Bridge.getSource(row.owner)
        if playerSource then
            exports['s1n_lib']:removePlayerMoneyFromBankAccount(playerSource, data.amount)
            Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
            return true
        else
            Editable.showNotify(_source, locale('player_is_offline'), 'error')
        end
    else
        exports['s1n_banking']:RemoveMoneyFromSociety(row.name, data.amount, "Charged for " .. data.reason)
        Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
        return true
    end
    return false
end)

lib.callback.register('p_dojmdt/server/finances/donateAccount', function(source, data)
    local _source = source
    local row = MySQL.single.await('SELECT * FROM s1n_bank_accounts WHERE iban = ?', {data.account})
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
    if row.type == 'useraccount' then
        local playerSource = Bridge.getSource(row.owner)
        if playerSource then
            exports['s1n_lib']:addPlayerMoneyToBankAccount(playerSource, data.amount)
            Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
            return true
        else
            Editable.showNotify(_source, locale('player_is_offline'), 'error')
        end
    else
        exports['s1n_banking']:AddMoneyToSociety(row.name, data.amount, "Charged for " .. data.reason)
        Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
        return true
    end
    return false
end)