local hospitalBeds = {
    [1] = {
        Beds = {
            {
                pos = vector3(1739.8566, 3626.7410, 35.6944 - 1.0),
                heading = 300.2923,
                isOccupied = false
            },
            {
                pos = vector3(1738.2328, 3629.4177, 35.6943 - 1.0),
                heading = 300.2923,
                isOccupied = false
            },
            {
                pos = vector3(1736.7626, 3632.3418, 35.6943 - 1.0),
                heading = 300.2923,
                isOccupied = false
            },
            {
                pos = vector3(1735.1847, 3634.9509, 35.6943 - 1.0),
                heading = 303.2923,
                isOccupied = false
            }
        }
    },
    [2] = {
        Beds = {
            {
                pos = vector3(-257.6407, 6321.9062, 33.3517 - 1.0),
                heading = 317.9848,
                isOccupied = false
            },
            {
                pos = vector3(-260.4585, 6324.0850, 33.352 - 1.0),
                heading = 317.9848,
                isOccupied = false
            },
            {
                pos = vector3(-262.6972, 6326.4375, 33.3516 - 1.0),
                heading = 317.9848,
                isOccupied = false
            },
            {
                pos = vector3(-258.6103, 6330.1885, 33.3517 - 1.0),
                heading = 135.9848,
                isOccupied = false
            },
            {
                pos = vector3(-256.4368, 6327.6929, 33.3517 - 1.0),
                heading = 136.9848,
                isOccupied = false
            }
        }
    },
    [3] = {
        Beds = {
            {
                pos = vector3(1124.8409, -1563.1327, 35.9583 - 1.0),
                heading = 4.6467,
                isOccupied = false
            },
            {
                pos = vector3(1121.4851, -1563.2446, 35.9583 - 1.0),
                heading = 359.0261,
                isOccupied = false
            },
            {
                pos = vector3(1118.0225, -1563.1443, 35.9583 - 1.0),
                heading = 355.6794,
                isOccupied = false
            },
            {
                pos = vector3(1117.6858, -1554.3213, 35.9583 - 1.0),
                heading = 182.4207,
                isOccupied = false
            },
            {
                pos = vector3(1121.2715, -1554.4396, 35.9583 - 1.0),
                heading = 187.4776,
                isOccupied = false
            },
            {
                pos = vector3(1124.7247, -1554.4220, 35.9583 - 1.0),
                heading = 178.8743,
                isOccupied = false
            }
        }
    },
    [4] = {
        Beds = {
            {
                pos = vector3(1151.9785, -1542.1112, 40.4282 - 1.0),
                heading = 176.2308,
                isOccupied = false
            },
            {
                pos = vector3(1152.0284, -1548.6956, 40.4281 - 1.0),
                heading = 177.2528,
                isOccupied = false
            },
            {
                pos = vector3(1152.0092, -1555.2002, 40.4281 - 1.0),
                heading = 180.0654,
                isOccupied = false
            }
        }
    }
}

ESX.RegisterServerCallback('esx_core:getFreeBed', function(source, cb, hospital)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb(nil)
        return
    end

    local hospitalData = hospitalBeds[hospital]
    if not hospitalData or not hospitalData.Beds then
        cb(nil)
        return
    end

    local beds = hospitalData.Beds
    for i = 1, #beds do
        if not beds[i].isOccupied then
            cb(beds[i])
            return
        end
    end

    cb(nil)
end)

RegisterNetEvent('esx_core:occupyBed', function(hospital, bed)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local hospitalData = hospitalBeds[hospital]
    if not hospitalData or not hospitalData.Beds then return end

    local bedData = hospitalData.Beds[bed]
    if not bedData or bedData.isOccupied then return end

    bedData.isOccupied = true
    CreateThread(function()
        Wait(15000)
        if hospitalBeds[hospital] and hospitalBeds[hospital].Beds and hospitalBeds[hospital].Beds[bed] then
            hospitalBeds[hospital].Beds[bed].isOccupied = false
        end
    end)
end)