if GetResourceState('pefcl') ~= 'started' then return end

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
        SELECT pefcl_accounts.*, doj_accounts_note.note FROM
        pefcl_accounts
        LEFT JOIN doj_accounts_note ON pefcl_accounts.number = doj_accounts_note.account
        WHERE pefcl_accounts.accountName LIKE @value
           OR pefcl_accounts.number LIKE @value
           OR pefcl_accounts.type LIKE @value
    ]], {
        ['@value'] = '%' .. data.value .. '%'
    })
    for i = 1, #result, 1 do
        local account = result[i]

        financesData.accounts[#financesData.accounts + 1] = { -- BankAccount
            name = account.accountName,
            owner = Bridge.getOfflineName(account.owner),
            number = account.number,
            balance = account.balance,
            type = account.type == 'personal' and locale('personal') or locale('business'),
            note = account.note or '',
        }

        local history = MySQL.query.await('SELECT * FROM pefcl_transactions WHERE fromAccountId = @me OR toAccountId = @me', {
            ['@me'] = account.id
        })
        if history then
            for k, v in pairs(history) do
                financesData.transactions[#financesData.transactions + 1] = { -- BankTransaction
                    id = v.id,
                    from = v.fromAccountId == account.id and account.name or v.fromAccountId,
                    to = v.toAccountId == account.id and account.name or v.toAccountId,
                    title = v.message,
                    amount = v.amount,
                    type = v.type == 'Outgoing' and 'outcome' or 'income',
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
    local row = MySQL.single.await('SELECT * FROM pefcl_accounts WHERE number = ?', {data.account})
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
    if row.type == 'personal' then
        local playerSource = Bridge.getSource(row.owner)
        if playerSource then
            exports.pefcl:removeBankBalance(playerSource, { amount = data.amount, message = data.reason })
            Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
            return true
        else
            Editable.showNotify(_source, locale('player_is_offline'), 'error')
        end
    else
        MySQL.update('UPDATE pefcl_accounts SET balance = balance - ? WHERE number = ?', {data.amount, data.account})
        Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
        return true
    end
    return false
end)

lib.callback.register('p_dojmdt/server/finances/donateAccount', function(source, data)
    local _source = source
    local row = MySQL.single.await('SELECT * FROM pefcl_accounts WHERE number = ?', {data.account})
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
    if row.type == 'personal' then
        local playerSource = Bridge.getSource(row.owner)
        if playerSource then
            exports.pefcl:addBankBalance(playerSource, { amount = data.amount, message = data.reason })
            Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
            return true
        else
            Editable.showNotify(_source, locale('player_is_offline'), 'error')
        end
    else
        MySQL.update('UPDATE pefcl_accounts SET balance = balance + ? WHERE number = ?', {data.amount, data.account})
        Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
        return true
    end
    return false
end)