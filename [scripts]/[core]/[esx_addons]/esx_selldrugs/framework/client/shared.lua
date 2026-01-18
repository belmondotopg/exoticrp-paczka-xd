Framework = nil
Fr = {}
ScriptFunctions = {}

local drugsCache = { data = nil, expiresAt = 0 }
local cacheTime = 10000

ScriptFunctions.GetInventoryDrugs = function()
    local playerData = Fr.GetPlayerData()
    if not playerData then
        debugPrint("[ERROR] playerData is nil in GetInventoryDrugs!")
        return {}
    end
    
    local drugsList = {}

    local now = GetGameTimer() or 0
    if drugsCache.data and now < drugsCache.expiresAt then
        return drugsCache.data
    end
    
    if ESX then
        local items = playerData.inventory
        if not items then 
            debugPrint("[WARNING] playerData.inventory is nil")
            return {} 
        end
        
        for k, v in pairs(items) do
            if v and Config.DrugSelling.availableDrugs[v.name] and v.count > 0 then
                local drugInfo = Config.DrugSelling.availableDrugs[v.name]
                table.insert(drugsList, {
                    icon = drugInfo.icon,
                    spawn_name = v.name,
                    label = drugInfo.label,
                    amount = v.count,
                    normalPrice = drugInfo.optimalPrice,
                    priceRangeMin = drugInfo.minimumPrice,
                    priceRangeMax = drugInfo.maximumPrice,
                })
            end
        end
    else
        debugPrint("[ERROR] ESX is not loaded!")
    end

    drugsCache.data = drugsList
    drugsCache.expiresAt = now + cacheTime
    
    if Config.Debug then
        debugPrint("[DEBUG] GetInventoryDrugs: Found", #drugsList, "drugs")
    end
    
    return drugsList
end