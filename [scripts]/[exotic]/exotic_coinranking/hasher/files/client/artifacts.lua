functions = {}

functions.openUI = function()
    ESX.TriggerServerCallback('vwk/exoticrp/getSteamData', function(data)
        SendNUIMessage({
            eventName = "exoticrp/menu/open",
            payload = {
                open = true,
                profile = {
                    username = data.name,
                    avatar = data.avatar,
                    coins = data.coins
                }
            }
        })
        SetNuiFocus(true, true)
    end)
end

functions.init = function()
    functions.loadConfig()
    functions.startLeaderboardUpdate()
    RegisterCommand(Config.Command, function(source, args, rawCommand)
        functions.openUI()
    end)
end

functions.loadConfig = function()
    Wait(1000)
    ESX.TriggerServerCallback('vwk/exoticrp/getClaimedProducts', function(claimedItems)
        local products = {}
        for k, v in pairs(Config.Products) do
            if type(v) == "table" then
                products[k] = {}
                for key, value in pairs(v) do
                    if key ~= "claimFunction" then
                        products[k][key] = value
                    end
                end
                local allowMultiple = v.allowMultipleClaims ~= nil and v.allowMultipleClaims or false
                if claimedItems[v.id] and not allowMultiple then
                    products[k].status = "claimed"
                end
            else
                products[k] = v
            end
        end
        SendNUIMessage({
            eventName = "exoticrp/request/config",
            payload = {
                products = products
            }
        })
    end)
end

RegisterNetEvent('vwk/exoticrp/refreshProducts', function()
    functions.loadConfig()
end)

exports('openShop', functions.openUI)

CreateThread(functions.init)
