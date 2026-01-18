if GetResourceState('qb-core') ~= 'started' then return end
if GetResourceState('okokBanking') ~= 'started' then return end

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
        LEFT JOIN doj_accounts_note ON JSON_UNQUOTE(JSON_EXTRACT(players.charinfo, '$.account')) = doj_accounts_note.account
        WHERE players.charinfo LIKE @value
    ]], {
        ['@value'] = '%' .. data.value .. '%'
    })
    for i = 1, #result, 1 do
        local account = result[i]

        local accountName = Bridge.getOfflineName(account.citizenid)
        financesData.accounts[#financesData.accounts + 1] = { -- BankAccount
            name = accountName,
            owner = accountName,
            number = json.decode(account.charinfo).account or 'N/A',
            balance = json.decode(account.money).bank or 0,
            type = locale('personal'),
            note = account.note or '',
        }

        local history = MySQL.query.await('SELECT * FROM okokbanking_transactions WHERE receiver_identifier = @me OR sender_identifier = @me', {
            ['@me'] = account.citizenid
        })
        if history then
            for k, v in pairs(history) do
                financesData.transactions[#financesData.transactions + 1] = { -- BankTransaction
                    id = v.id,
                    from = v.sender_name,
                    to = v.receiver_name,
                    title = v.receiver_identifier == account.citizenid and v.sender_name or v.receiver_name,
                    amount = v.value,
                    type = v.type == 'deposit' and 'income' or v.type == 'withdraw' and 'outcome' or (v.type == 'transfer' and v.sender_identifier == account.citizenid and 'outcome' or 'income'),
                    date = v.date,
                }
            end
        end
    end

    return financesData
end)

RegisterNetEvent('p_dojmdt/server/finances/saveAccountNote', function(data)
    local _source = source
    if not permissions or not permissions['save_account_note'] then
        Editable.showNotify(_source, locale('no_permissions'), 'error')
        return false
    end

    local row = MySQL.single.await('SELECT * FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(players.charinfo, "$.account")) = ?', {data.account})
    if row then
        MySQL.update('UPDATE doj_accounts_note SET note = ? WHERE account = ?', {data.note, data.account})
    else
        MySQL.insert('INSERT INTO doj_accounts_note (account, note) VALUES (?, ?)', {data.account, data.note})
    end
    Editable.showNotify(_source, locale('saved_account_note'), 'success')
end)

lib.callback.register('p_dojmdt/server/finances/chargeAccount', function(source, data)
    local _source = source
    local row = MySQL.single.await('SELECT * FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(players.charinfo, "$.account")) = ?', {data.account})
    if not row then
        Editable.showNotify(_source, locale('account_not_found'), 'error')
        return false
    end

    local permissions = Pages.Main.getPermissions(_source)
    if not permissions or not permissions['charge_account'] then
        Editable.showNotify(_source, locale('no_permissions'), 'error')
        return false
    end

    data.amount = tonumber(data.amount)
    local playerJob = Bridge.getPlayerJob(_source)
    local xPlayer = QBCore.Functions.GetPlayerByCitizenId(row.citizenid)
    if xPlayer then
        xPlayer.Functions.RemoveMoney('bank', data.amount)
        exports['p_dojmdt']:addMoney({from = ('%s %s'):format(xPlayer.PlayerData.charinfo.firstname, xPlayer.PlayerData.charinfo.lastname), amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
        return true
    else
        Editable.showNotify(_source, locale('player_is_offline'), 'error')
    end
    return false
end)

lib.callback.register('p_dojmdt/server/finances/donateAccount', function(source, data)
    local _source = source
    local row = MySQL.single.await('SELECT * FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(players.charinfo, "$.account")) = ?', {data.account})
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
    local xPlayer = QBCore.Functions.GetPlayerByCitizenId(row.citizenid)
    if xPlayer then
        local money = exports['p_dojmdt']:getMoney(playerJob.jobName)
        if money < data.amount then
            Editable.showNotify(_source, locale('society_not_enough_money'), 'error')
            return false
        end

        xPlayer.Functions.AddMoney('bank', data.amount)
        exports['p_dojmdt']:removeMoney({to = ('%s %s'):format(xPlayer.PlayerData.charinfo.firstname, xPlayer.PlayerData.charinfo.lastname), amount = data.amount, jobName = playerJob.jobName, jobLabel = playerJob.jobLabel})
        Editable.showNotify(_source, locale('account_donated', data.amount, data.reason), 'success')
        return true
    else
        Editable.showNotify(_source, locale('player_is_offline'), 'error')
    end
    return false
end)