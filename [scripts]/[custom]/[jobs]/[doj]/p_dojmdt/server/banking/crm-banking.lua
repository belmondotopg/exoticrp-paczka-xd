if GetResourceState('crm-banking') ~= 'started' then return end

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
        SELECT crm_bank_accounts.*, doj_accounts_note.note FROM crm_bank_accounts
        LEFT JOIN doj_accounts_note ON crm_bank_accounts.crm_iban = doj_accounts_note.account
        WHERE crm_bank_accounts.crm_name LIKE @value
           OR crm_bank_accounts.crm_owner LIKE @value
           OR crm_bank_accounts.crm_iban LIKE @value
           OR crm_bank_accounts.crm_type LIKE @value
    ]], {
        ['@value'] = '%' .. data.value .. '%'
    })

    local history = MySQL.query.await('SELECT * FROM crm_bank_transactions LIMIT 100')
    for i = 1, #result, 1 do
        local account = result[i]

        financesData.accounts[#financesData.accounts + 1] = { -- BankAccount
            name = account.crm_name,
            owner = account.crm_type == 'crm_society' and account.crm_name or Bridge.getOfflineName(account.crm_owner),
            number = account.crm_iban,
            balance = account.crm_balance,
            type = account.type == 'crm_society' and locale('business') or locale('personal'),
            note = account.note or '',
        }
        for k, v in pairs(history) do
            if v.crm_sender == account.crm_iban or v.crm_receiver == account.crm_iban then
                financesData.transactions[#financesData.transactions + 1] = { -- BankTransaction
                    id = v.id,
                    from = v.crm_sender,
                    to = v.crm_receiver,
                    title = v.crm_description,
                    amount = v.crm_amount,
                    type = v.crm_type == 'crm-withdraw' and 'outcome' or 'income',
                    date = v.crm_date,
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

    local row = MySQL.single.await('SELECT * FROM crm_bank_accounts WHERE crm_iban = ?', {data.account})
    if row then
        MySQL.update('UPDATE doj_accounts_note SET note = ? WHERE account = ?', {data.note, data.account})
    else
        MySQL.insert('INSERT INTO doj_accounts_note (account, note) VALUES (?, ?)', {data.account, data.note})
    end
    Editable.showNotify(_source, locale('saved_account_note'), 'success')
end)

lib.callback.register('p_dojmdt/server/finances/chargeAccount', function(source, data)
    local _source = source
    local row = MySQL.single.await('SELECT * FROM crm_bank_accounts WHERE crm_iban = ?', {data.account})
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
    if row.crm_type == 'crm-society' then
        exports["crm-banking"]:crm_remove_money(row.crm_owner, data.amount)
        exports['p_dojmdt']:addMoney({from = row.crm_name, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
    else
        local playerSource = Bridge.getSource(row.crm_owner)
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
    local row = MySQL.single.await('SELECT * FROM crm_bank_accounts WHERE crm_iban = ?', {data.account})
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
    if row.crm_type == 'crm-society' then
        exports["crm-banking"]:crm_add_money(row.crm_owner, data.amount)
        exports['p_dojmdt']:removeMoney({to = row.crm_name, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
    else
        local playerSource = Bridge.getSource(row.crm_owner)
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