function LoadDatabase()
    CreateThread(function()
        local bags = MySQL.query.await('SELECT * FROM clothing_bags', {})
        
        if not bags or #bags == 0 then
            print('[exotic_clothingbag] No bags found in database')
            return
        end

        for _, bag in ipairs(bags) do
            local outfits = MySQL.query.await('SELECT * FROM bags_outfits WHERE bag_id = ?', { bag.id })
            
            Bags[tostring(bag.id)] = {
                id = bag.id,
                owner = bag.owner,
                outfits = outfits or {},
            }
        end
    end)
end

function UseBag(playerId, itemMetaData)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local identifier = xPlayer.getIdentifier()

    if itemMetaData?.id then
        local bagId = tostring(itemMetaData.id)
        if Bags[bagId] and Bags[bagId].owner ~= identifier then
            return xPlayer.showNotification("~r~Nie możesz postawić nie swojej torby.")
        end
    end

    local netId = lib.callback.await('exotic_clothingbag:placeBag', playerId)

    local entity = NetworkGetEntityFromNetworkId(netId)
    local tries = 0

    while entity == 0 and tries < 50 do
        Citizen.Wait(100)

        entity = NetworkGetEntityFromNetworkId(netId)
        tries += 1
    end

    if entity == 0 then
        return
    end

    if not itemMetaData.id then
        CreateBag(identifier, entity)
    else
        Entity(entity).state.bagId = tostring(itemMetaData.id)
        Entity(entity).state.owner = identifier
        Entity(entity).state.private = true
    end
end

function CreateBag(identifier, entity)
    local bag = {}

    local id = MySQL.insert.await('INSERT INTO `clothing_bags` (owner) VALUES (?)', {
        identifier
    })

    bag.id = id
    bag.owner = identifier
    bag.outfits = {}

    Bags[tostring(id)] = bag

    Entity(entity).state.bagId = tostring(id)
    Entity(entity).state.owner = identifier
    Entity(entity).state.private = true
end

function SwitchBagPrivacy(playerId, netId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local entity = NetworkGetEntityFromNetworkId(netId)

    if entity == 0 then
        return xPlayer.showNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    local state = Entity(entity).state

    if state.owner ~= xPlayer.getIdentifier() then
        return xPlayer.showNotification("~r~Nie możesz zmienić prywatności nie swojej torby.")
    end

    local lastPrivacy = Entity(entity).state.private
    local newPrivacy = not lastPrivacy

    Entity(entity).state.private = newPrivacy

    xPlayer.showNotification(("Torba jest teraz %s."):format(newPrivacy and "prywatna" or "publiczna"))

    return newPrivacy
end

function TakeBag(playerId, netId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local entity = NetworkGetEntityFromNetworkId(netId)

    if entity == 0 then
        return xPlayer.showNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    local state = Entity(entity).state

    if state.owner ~= xPlayer.getIdentifier() then
        return xPlayer.showNotification("~r~Nie możesz podnieść nie swojej torby.")
    end

    local success = exports.ox_inventory:AddItem(playerId, Config.ItemName, 1, { id = tostring(state.bagId) })

    if not success then
        return
    end

    DeleteEntity(entity)

    return true
end

function OpenBag(playerId, netId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local entity = NetworkGetEntityFromNetworkId(netId)

    if entity == 0 then
        return xPlayer.showNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    local state = Entity(entity).state

    if state.owner ~= xPlayer.getIdentifier() and state.private then
        return xPlayer.showNotification("~r~Nie możesz otworzyć nie swojej torby.")
    end

    if not Bags[state.bagId] then
        return xPlayer.showNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    return Bags[state.bagId].outfits
end

function CreateNewOutfit(playerId, netId, name, outfit, sex)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local entity = NetworkGetEntityFromNetworkId(netId)

    if entity == 0 then
        return xPlayer.showNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    local state = Entity(entity).state

    if state.owner ~= xPlayer.getIdentifier() then
        return xPlayer.showNotification("~r~Nie możesz tworzyć strojów jeżeli torba nie jest twoja.")
    end

    if not Bags[state.bagId] then
        return xPlayer.showNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    if #Bags[state.bagId].outfits >= Config.OutfitsLimit then
        return xPlayer.showNotification("~r~Nie możesz tworzyć więcej stroi w tej torbie.")
    end

    local id = MySQL.insert.await('INSERT INTO `bags_outfits` (bag_id, label, numbers, sex) VALUES (?, ?, ?, ?)', {
        state.bagId, name, json.encode(outfit), sex
    })

    local newOutfit = {
        id = id,
        label = name,
        numbers = json.encode(outfit),
        sex = sex
    }

    table.insert(Bags[state.bagId].outfits, newOutfit)

    return Bags[state.bagId].outfits
end

function GetOutfitIndex(outfits, id)
    local index = 0

    for i, v in pairs(outfits) do
        if v.id == id then
            index = i
            break
        end
    end

    return index
end

function DeleteOutfit(playerId, netId, id)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local entity = NetworkGetEntityFromNetworkId(netId)

    if entity == 0 then
        return xPlayer.showNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    local state = Entity(entity).state

    if state.owner ~= xPlayer.getIdentifier() then
        return xPlayer.showNotification("~r~Nie możesz usunąć stroju jeżeli torba nie jest twoja.")
    end

    if not Bags[state.bagId] then
        return xPlayer.showNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    local outfitIndex = GetOutfitIndex(Bags[state.bagId].outfits, id)

    if outfitIndex == 0 then
        return xPlayer.showNotification("~r~Strój nie istnieje.")
    end

    MySQL.query.await('DELETE FROM `bags_outfits` WHERE id = ?', {
        id
    })

    table.remove(Bags[state.bagId].outfits, outfitIndex)

    return Bags[state.bagId].outfits
end

function GetOnlyClothesFromVariant(outfit, variant)
    local newOutfit = {}

    for i, v in pairs(outfit) do
        if Config.DressUpVariants[variant][i] then
            newOutfit[i] = v
        end
    end

    return newOutfit
end

function DressUp(playerId, netId, id, variant, sex)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local entity = NetworkGetEntityFromNetworkId(netId)

    if entity == 0 then
        return xPlayer.showNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    local state = Entity(entity).state

    if state.owner ~= xPlayer.getIdentifier() and state.private then
        return xPlayer.showNotification("~r~Nie możesz zakładać strojów jeżeli torba nie jest twoja.")
    end

    if not Bags[state.bagId] then
        return xPlayer.showNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    local outfitIndex = GetOutfitIndex(Bags[state.bagId].outfits, id)

    if outfitIndex == 0 then
        return xPlayer.showNotification("~r~Strój nie istnieje.")
    end

    local outfit = Bags[state.bagId].outfits[outfitIndex]

    if outfit.sex ~= sex then
        return xPlayer.showNotification(("~r~Ten strój jest przeznaczony dla %s."):format(outfit.sex == "M" and
            "mężczyzn" or "kobiet"))
    end

    local newOutfit = GetOnlyClothesFromVariant(json.decode(outfit.numbers), variant)
    
    return newOutfit
end

function PreviewOutfit(playerId, netId, id, sex)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local entity = NetworkGetEntityFromNetworkId(netId)

    if entity == 0 then
        return xPlayer.showNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    local state = Entity(entity).state

    if state.owner ~= xPlayer.getIdentifier() and state.private then
        return xPlayer.showNotification("~r~Nie możesz zakładać strojów jeżeli torba nie jest twoja.")
    end

    if not Bags[state.bagId] then
        return xPlayer.showNotification("~r~Wystąpił nieoczekiwany błąd.")
    end

    local outfitIndex = GetOutfitIndex(Bags[state.bagId].outfits, id)

    if outfitIndex == 0 then
        return xPlayer.showNotification("~r~Strój nie istnieje.")
    end

    local outfit = Bags[state.bagId].outfits[outfitIndex]

    local newOutfit = GetOnlyClothesFromVariant(json.decode(outfit.numbers), "all")
    if outfit.sex ~= sex then
        return xPlayer.showNotification(("~r~Ten strój jest przeznaczony dla %s."):format(outfit.sex == "M" and
            "mężczyzn" or "kobiet"))
    end

    return newOutfit
end
