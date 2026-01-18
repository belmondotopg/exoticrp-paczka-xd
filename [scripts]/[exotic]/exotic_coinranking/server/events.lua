functions.claimProduct = function(id)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return
    end
    
    local product = functions.findProduct(id)
    if not product then
        xPlayer.showNotification('Produkt o podanym ID nie istnieje.', 'error')
        return
    end
    
    if not product.claimFunction then
        xPlayer.showNotification('Zgłoś to adminowi, że produkt nie posiada funkcji odbioru.', 'error')
        return
    end
    
    local steamIdentifier = functions.getSteam(src)
    local amount = functions.getPlayerCoins(steamIdentifier)
    
    if amount < product.price then
        xPlayer.showNotification('Nie posiadasz wystarczająco monet aby odebrać ten produkt.', 'error')
        return
    end
    
    local allowMultiple = product.allowMultipleClaims ~= nil and product.allowMultipleClaims or false
    if not allowMultiple and functions.isProductClaimed(steamIdentifier, product.id) then
        xPlayer.showNotification('Już odebrałeś ten produkt.', 'error')
        return
    end
    
    if allowMultiple and functions.isProductClaimed(steamIdentifier, product.id) then
        functions.removeClaimed(steamIdentifier, product.id)
    end
    
    product.claimFunction(src)
    functions.subtractAmount(src, product.price)
    if not allowMultiple then
        functions.saveClaimed(src, steamIdentifier, product.id)
    end
    
    TriggerClientEvent('vwk/exoticrp/refreshProducts', src)
end

RegisterNetEvent('vwk/exoticrp/claimProduct', functions.claimProduct)