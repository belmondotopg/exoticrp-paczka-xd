if GetResourceState('fd_banking') ~= 'started' then return end

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
        SELECT fd_advanced_banking_accounts.*, doj_accounts_note.note FROM fd_advanced_banking_accounts
        LEFT JOIN doj_accounts_note ON fd_advanced_banking_accounts.iban = doj_accounts_note.account
        WHERE fd_advanced_banking_accounts.name LIKE @value
           OR fd_advanced_banking_accounts.iban LIKE @value
           OR fd_advanced_banking_accounts.type LIKE @value
    ]], {
        ['@value'] = '%' .. data.value .. '%'
    })
    for i = 1, #result, 1 do
        local account = result[i]

        local owner = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts_members WHERE account_id = ? AND is_owner = 1', {account.id})
        local ownerName = owner and Bridge.getOfflineName(owner.identifier) or nil
        financesData.accounts[#financesData.accounts + 1] = { -- BankAccount
            name = account.type == 'personal' and ownerName or account.name,
            owner = account.type == 'personal' and ownerName or account.name,
            number = account.iban,
            balance = account.balance,
            type = account.type == 'personal' and locale('personal') or locale('business'),
            note = account.note or '',
        }

        local history = MySQL.query.await('SELECT * FROM fd_advanced_banking_accounts_transactions WHERE from_account = @me OR to_account = @me', {
            ['@me'] = account.iban
        })
        if history then
            for k, v in pairs(history) do
                financesData.transactions[#financesData.transactions + 1] = { -- BankTransaction
                    id = v.id,
                    from = v.from_account,
                    to = v.to_account,
                    title = v.description,
                    amount = v.amount,
                    type = v.action == 'withdraw' and 'outcome' or 'income',
                    date = v.created_at,
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

    local row = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts WHERE iban = ?', {data.account})
    if row then
        MySQL.update('UPDATE doj_accounts_note SET note = ? WHERE account = ?', {data.note, data.account})
    else
        MySQL.insert('INSERT INTO doj_accounts_note (account, note) VALUES (?, ?)', {data.account, data.note})
    end
    Editable.showNotify(_source, locale('saved_account_note'), 'success')
end)

lib.callback.register('p_dojmdt/server/finances/chargeAccount', function(source, data)
    local _source = source
    local row = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts WHERE iban = ?', {data.account})
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
    if row.is_society then
        exports.fd_banking:RemoveMoney(row.business, data.amount, 'DOJ')
        exports['p_dojmdt']:addMoney({from = row.name, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
    else
        local owner = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts_members WHERE account_id = ? AND is_owner = 1', {row.id})
        local playerSource = Bridge.getSource(owner.identifier)
        if playerSource then
            Bridge.removeMoney(playerSource, 'bank', data.amount)
            exports['p_dojmdt']:addMoney({
                from = Bridge.getName(playerSource), amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel
            })
            Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
            return true
        else
            Editable.showNotify(_source, locale('player_is_offline'), 'error')
        end
    end
    return false
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
    if row.is_society then
        exports.fd_banking:RemoveMoney(row.business, data.amount, 'DOJ')
        exports['p_dojmdt']:removeMoney({to = row.name, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
    else
        local owner = MySQL.single.await('SELECT * FROM fd_advanced_banking_accounts_members WHERE account_id = ? AND is_owner = 1', {row.id})
        local playerSource = Bridge.getSource(owner.identifier)
        local playerSource = Bridge.getSource(row.owner)
        if playerSource then
            Bridge.addMoney(playerSource, 'bank', data.amount)
            exports['p_dojmdt']:removeMoney({
                to = Bridge.getName(playerSource), amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel
            })
            Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
            return true
        else
            Editable.showNotify(_source, locale('player_is_offline'), 'error')
        end
    end
    return false
end)