functions = {}

functions.getPlayerCoins = function(identifier)
    local result = MySQL.query.await('SELECT coins FROM timecoins WHERE identifier = ?', { identifier })
    return result and result[1] and result[1].coins or 0
end

functions.subtractAmount = function(source, amount)
    local steamIdentifier = functions.getSteam(source)
    MySQL.update.await('UPDATE timecoins SET coins = coins - ? WHERE identifier = ?', { amount, steamIdentifier })
end

functions.findProduct = function(id)
    for _, product in ipairs(Config.Products) do
        if product.id == id then
            return product
        end
    end
end

functions.getSteam = function(source)
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(id, 1, 6) == "steam:" then
            return id
        end
    end
end

functions.isProductClaimed = function(identifier, productId)
    local result = MySQL.scalar.await('SELECT claimed FROM timecoins WHERE identifier = ?', { identifier })
    if result and result ~= '' then
        local ok, decoded = pcall(json.decode, result)
        if ok and type(decoded) == 'table' then
            for _, id in ipairs(decoded) do
                if id == productId then
                    return true
                end
            end
        end
    end
    return false
end

functions.removeClaimed = function(identifier, productId)
    local result = MySQL.scalar.await('SELECT claimed FROM timecoins WHERE identifier = ?', { identifier })
    if result and result ~= '' then
        local ok, decoded = pcall(json.decode, result)
        if ok and type(decoded) == 'table' then
            local claimed = {}
            for _, id in ipairs(decoded) do
                if id ~= productId then
                    table.insert(claimed, id)
                end
            end
            MySQL.update.await('UPDATE timecoins SET claimed = ? WHERE identifier = ?', { json.encode(claimed), identifier })
        end
    end
end

functions.saveClaimed = function(source, identifier, productId)
    local result = MySQL.scalar.await('SELECT claimed FROM timecoins WHERE identifier = ?', { identifier })
    local claimed = {}
    if result and result ~= '' then
        local ok, decoded = pcall(json.decode, result)
        if ok and type(decoded) == 'table' then
            claimed = decoded
        end
    end
    table.insert(claimed, productId)
    local rowsChanged = MySQL.update.await('UPDATE timecoins SET claimed = ? WHERE identifier = ?', { json.encode(claimed), identifier })
    if rowsChanged == 0 then
        MySQL.insert.await('INSERT INTO timecoins (identifier, claimed) VALUES (?, ?)', { identifier, json.encode(claimed) })
    end
end

functions.addCoins = function(source, amount)
    local steamIdentifier = functions.getSteam(source)
    MySQL.update.await('UPDATE timecoins SET coins = coins + ? WHERE identifier = ?', { amount, steamIdentifier })
end