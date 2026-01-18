Targets = {}
PriceLists = {}
IsCreatingPriceList = false
PriceListCoords = nil
PriceListText = nil
CurrentJob = nil
PlayerPed = PlayerPedId()
WorkTips = {
    missionText = nil,
    vehicleTaken = false,
    productsCollected = false,
    productsDelivered = false,
    currentWaypoint = nil,
    hasPackage = false,
    packageInVehicle = false
}

local PackageProp = nil

CreateThread(Init)
RegisterNetEvent("esx:setJob", LoadJob)
RegisterNetEvent("exotic_businesses:loadPriceLists", LoadPriceLists)
RegisterNetEvent("exotic_businesses:courseCompleted", function()
    if CurrentJob and IsInWorkClothes then
        ResetWorkTips()
        Wait(500)
        ShowWorkTip("vehicle")
    end
end)
RegisterCommand("cennik", OpenPriceListMenu, false)
RegisterCommand("placepricelist", PlacePriceList, false)
RegisterCommand("cancelplacingpricelist", CancelPlacingPriceList, false)
RegisterKeyMapping("placepricelist", "Postawienie cennika", "keyboard", "RETURN")
RegisterKeyMapping("cancelplacingpricelist", "Anulowanie stawiania cennika", "keyboard", "ESCAPE")

lib.onCache('ped', function(value)
    PlayerPed = value
end)

exports('useItem', function(data, slot)
    exports.ox_inventory:useItem(data, function(itemData)
        if itemData then UseItem(itemData) end
    end)
end)
