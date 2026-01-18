if GetResourceState('just-banks') ~= 'started' then return end

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
        SELECT justbank_cards.*, justbank_users.name, doj_accounts_note.note FROM justbank_cards
        LEFT JOIN doj_accounts_note ON justbank_cards.card_number = doj_accounts_note.account
        LEFT JOIN justbank_users ON justbank_cards.holder = justbank_users.id
        WHERE justbank_users.name LIKE @value
           OR justbank_cards.card_number LIKE @value
           OR justbank_cards.type LIKE @value
    ]], {
        ['@value'] = '%' .. data.value .. '%'
    })
    for i = 1, #result, 1 do
        local account = result[i]

        financesData.accounts[#financesData.accounts + 1] = { -- BankAccount
            name = account.name,
            owner = account.name,
            number = account.card_number,
            balance = account.balance,
            type = locale('personal'),
            note = account.note or '',
        }

        local history = MySQL.query.await('SELECT * FROM justbank_transactions WHERE card = ?', {account.card_number})
        if history then
            for k, v in pairs(history) do
                financesData.transactions[#financesData.transactions + 1] = { -- BankTransaction
                    id = v.id,
                    from = 'SYSTEM',
                    to = 'SYSTEM',
                    title = v.description,
                    amount = v.amount,
                    type = v.type == 'deposit' and 'income' or 'outcome',
                    date = os.date('%d-%m-%Y %H:%M', v.time),
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
    local cardId = exports.JustBanks:GetCardId(data.account)
    if not cardId then
        Editable.showNotify(source, locale('account_not_found'), 'error')
        return false
    end

    local permissions = Pages.Main.getPermissions(_source)
    if not permissions or not permissions['charge_account'] then
        Editable.showNotify(_source, locale('no_permissions'), 'error')
        return false
    end

    exports.JustBanks:RemoveMoney(cardId, tonumber(data.amount))
    Editable.showNotify(_source, locale('account_charged', data.amount, data.reason), 'success')
    return true
end)

lib.callback.register('p_dojmdt/server/finances/donateAccount', function(source, data)
    local _source = source
    local cardId = exports.JustBanks:GetCardId(data.account)
    if not cardId then
        Editable.showNotify(source, locale('account_not_found'), 'error')
        return false
    end

    local permissions = Pages.Main.getPermissions(_source)
    if not permissions or not permissions['donate_account'] then
        Editable.showNotify(_source, locale('no_permissions'), 'error')
        return false
    end

    exports.JustBanks:AddMoney(cardId, tonumber(data.amount))
    return false
end)