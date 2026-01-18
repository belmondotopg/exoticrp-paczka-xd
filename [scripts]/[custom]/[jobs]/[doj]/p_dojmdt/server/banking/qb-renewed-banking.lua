if GetResourceState('Renewed-Banking') ~= 'started' then return end
if GetResourceState('es_extended') == 'started' then return end

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
        SELECT players.*, doj_accounts_note.note FROM players
        LEFT JOIN doj_accounts_note ON players.citizenid = doj_accounts_note.account
        WHERE players.charinfo LIKE @value OR players.citizenid LIKE @value
    ]], {
        ['@value'] = '%' .. data.value .. '%'
    })
    for i = 1, #result, 1 do
        local account = result[i]

        local charinfo = json.decode(account.charinfo)
        financesData.accounts[#financesData.accounts + 1] = { -- BankAccount
            name = ('%s %s'):format(charinfo.firstname, charinfo.lastname),
            owner = ('%s %s'):format(charinfo.firstname, charinfo.lastname),
            number = account.citizenid,
            balance = json.decode(account.money).bank or 0,
            type = locale('personal'),
            note = account.note or '',
        }

        local history = MySQL.single.await('SELECT * FROM player_transactions WHERE id = ?', {
            account.citizenid
        })
        if history then
            local transactions = json.decode(history.transactions)
            for k, v in pairs(transactions) do
                financesData.transactions[#financesData.transactions + 1] = { -- BankTransaction
                    id = v.trans_id,
                    from = v.issuer,
                    to = v.receiver,
                    title = v.message,
                    amount = v.amount,
                    type = v.trans_type == 'withdraw' and 'outcome' or 'income',
                    date = os.date('%H:%M %d-%m-%Y', v.time),
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
    local row = MySQL.single.await('SELECT * FROM players WHERE citizenid = ?', {data.account})
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
    local playerSource = Bridge.getSource(data.account)
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
    return false
end)

lib.callback.register('p_dojmdt/server/finances/donateAccount', function(source, data)
    local _source = source
    local playerJob = Bridge.getPlayerJob(_source)
    local row = MySQL.single.await('SELECT * FROM players WHERE citizenid = ?', {data.account})
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
    
    return false
end)