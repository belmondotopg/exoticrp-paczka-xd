if GetResourceState('tgg-banking') ~= 'started' then return end

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
    lib.print.info(data, 'data for finances callback')
    local financesData = {accounts = {}, transactions = {}}
    local result = MySQL.query.await([[
        SELECT tgg_banking_accounts.*, doj_accounts_note.note FROM tgg_banking_accounts
        LEFT JOIN doj_accounts_note ON tgg_banking_accounts.iban = doj_accounts_note.account
        WHERE tgg_banking_accounts.name LIKE @value
           OR tgg_banking_accounts.ownerId LIKE @value
           OR tgg_banking_accounts.iban LIKE @value
           OR tgg_banking_accounts.type LIKE @value
    ]], {
        ['@value'] = '%' .. data.value .. '%'
    })
    lib.print.info(result, 'tgg-banking database data')
    for i = 1, #result, 1 do
        local account = result[i]

        financesData.accounts[#financesData.accounts + 1] = { -- BankAccount
            name = account.name,
            owner = account.type == 'personal' and Bridge.getOfflineName(account.ownerId) or account.name,
            number = account.iban,
            balance = account.balance,
            type = account.type == 'personal' and locale('personal') or locale('business'),
            note = account.note or '',
        }

        local history = MySQL.query.await('SELECT * FROM tgg_banking_transactions WHERE toIban = @iban OR fromIban = @iban', {
            ['@iban'] = account.iban
        })
        if history then
            for k, v in pairs(history) do
                local readableDate = os.date("%Y-%m-%d %H:%M:%S", math.floor(v.createdAt / 1000))

                financesData.transactions[#financesData.transactions + 1] = { -- BankTransaction
                    id = v.transactionId,
                    from = v.fromIban,
                    to = v.toIban,
                    title = v.description,
                    amount = v.amount,
                    type = v.type == 'withdraw' and 'outcome' or 'income',
                    date = readableDate, 
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
    local playerJob = Bridge.getPlayerJob(_source)
    local row = MySQL.single.await('SELECT * FROM tgg_banking_accounts WHERE iban = ?', {data.account})
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
        local playerSource = Bridge.getSource(row.ownerId)
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
    else
        local success = exports['tgg-banking']:RemoveSocietyMoney(row.ownerId, data.amount)
        if success then
            exports['p_dojmdt']:addMoney({
                from = row.name, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel
            })
            Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
            return true
        end
    end
    return false
end)

lib.callback.register('p_dojmdt/server/finances/donateAccount', function(source, data)
    local _source = source
    local playerJob = Bridge.getPlayerJob(_source)
    local row = MySQL.single.await('SELECT * FROM tgg_banking_accounts WHERE iban = ?', {data.account})
    if not row then
        Editable.showNotify(source, locale('account_not_found'), 'error')
        return false
    end

    local permissions = Pages.Main.getPermissions(_source)
    if not permissions or not permissions['donate_account'] then
        Editable.showNotify(_source, locale('no_permissions'), 'error')
        return false
    end

    local societyMoney = exports['p_dojmdt']:getMoney(playerJob.jobName)
    if societyMoney < data.amount then
        Editable.showNotify(source, locale('society_not_enough_money'), 'error')
        return false
    end

    data.amount = tonumber(data.amount)
    if row.type == 'personal' then
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
    else
        local success = exports['tgg-banking']:AddSocietyMoney(row.ownerId, data.amount)
        if success then
            exports['p_dojmdt']:removeMoney({
                from = row.name, amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel
            })
            Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
            return true
        end
    end
    return false
end)