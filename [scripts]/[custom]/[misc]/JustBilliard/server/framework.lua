-- Credits: https://github.com/luman-studio
Framework = {}

if Config.Framework == FRAMEWORK_ESX then
    ESX = exports[FRAMEWORK_ESX]:getSharedObject()
elseif Config.Framework == FRAMEWORK_QB then
    QBCore = exports[FRAMEWORK_QB]:GetCoreObject()
elseif Config.Framework == FRAMEWORK_VRP then
    local Tunnel = module("vrp", "lib/Tunnel")
    local Proxy = module("vrp", "lib/Proxy")
    vRP = Proxy.getInterface("vRP")
    vRPclient = Tunnel.getInterface("vRP", "JustBilliard")
end

function Framework.takeMoney(playerId, amount)
    playerId = tonumber(playerId)
    
    if Config.Framework == FRAMEWORK_ESX then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        local money = xPlayer.getMoney()
        if money >= amount then
            xPlayer.removeMoney(amount)
            return true
        end
        return false
    elseif Config.Framework == FRAMEWORK_QB then
		local Ply = QBCore.Functions.GetPlayer(playerId)
		if Ply.PlayerData.money["cash"] >= amount then
            return Ply.Functions.RemoveMoney("cash", amount)
		else
            return false
        end
    elseif Config.Framework == FRAMEWORK_VRP then
        vRP.tryPayment({vRP.getUserId({playerId}), amount})
    else
        Framework.showSuccessNotification(playerId, 'removed_money', amount)
        return true
    end
end

function Framework.giveMoney(playerId, amount)
    playerId = tonumber(playerId)

    if Config.Framework == FRAMEWORK_ESX then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        xPlayer.addMoney(amount)
        return true
    elseif Config.Framework == FRAMEWORK_QB then
		local Ply = QBCore.Functions.GetPlayer(playerId)
        return Ply.Functions.AddMoney("cash", amount)
    elseif Config.Framework == FRAMEWORK_VRP then
        vRP.giveMoney({vRP.getUserId({playerId}), amount})
    else
        Framework.showSuccessNotification(playerId, 'received_money', amount)
        return true
    end
end

function Framework.showSuccessNotification(playerId, messgeId, ...)
    TriggerClientEvent(EVENTS['showSuccessNotification'], playerId, messgeId, ...)
end

function Framework.showWarningNotification(playerId, messgeId, ...)
    TriggerClientEvent(EVENTS['showWarningNotification'], playerId, messgeId, ...)
end

function Framework.showErrorNotification(playerId, messgeId, ...)
    TriggerClientEvent(EVENTS['showErrorNotification'], playerId, messgeId, ...)
end