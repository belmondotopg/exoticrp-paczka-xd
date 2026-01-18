local NetworkSetFriendlyFireOption = NetworkSetFriendlyFireOption
local SetCanAttackFriendly = SetCanAttackFriendly
local ClearPlayerWantedLevel = ClearPlayerWantedLevel
local DisableControlAction = DisableControlAction
local SetEntityInvincible = SetEntityInvincible
local LocalPlayer = LocalPlayer
local ESX = ESX
local libCache = lib.onCache
local cachePlayerId = cache.playerId
local cacheVehicle = cache.vehicle

LocalPlayer.state:set('InSafeZone', false, true)

local isInSafeZone = false
local safeZoneCount = 0
local disabledPeds = {}
local lastPedProcessTime = 0
local processedPeds = {}

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        isInSafeZone = false
        safeZoneCount = 0
        LocalPlayer.state:set('InSafeZone', false, true)
        
        for ped, _ in pairs(disabledPeds) do
            if DoesEntityExist(ped) then
                ResetPedToDefault(ped)
            end
        end
        disabledPeds = {}
        processedPeds = {}
        
        if lib.zones.clearAllZones then
            lib.zones.clearAllZones()
        end
    end
end)

local function ResetPedToDefault(ped)
    if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
        SetBlockingOfNonTemporaryEvents(ped, false)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatAttributes(ped, 17, false)
        SetPedConfigFlag(ped, 32, false)
        SetPedConfigFlag(ped, 281, false)
        SetEntityInvincible(ped, false)
    end
end

local function DisablePedAggression(ped)
    if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedFleeAttributes(ped, 0, true)
        SetPedCombatAttributes(ped, 17, true)
        SetPedConfigFlag(ped, 32, true)
        SetPedConfigFlag(ped, 281, true)
        TaskSetBlockingOfNonTemporaryEvents(ped, true)
        ClearPedTasks(ped)
        ClearPedTasksImmediately(ped)
        SetEntityInvincible(ped, true)
        disabledPeds[ped] = true
    end
end

libCache('playerId', function(playerId)
    cachePlayerId = playerId
end)

libCache('vehicle', function(vehicle)
    cacheVehicle = vehicle
end)

local function onSafeZoneEnter()
    safeZoneCount = safeZoneCount + 1
    
    if not isInSafeZone then
        isInSafeZone = true
        ESX.UI.Menu.CloseAll()
        LocalPlayer.state:set('InSafeZone', true, true)
        SetPlayerInvincibleKeepRagdollEnabled(cachePlayerId, true)
        ESX.ShowNotification('Wszedłeś do zielonej strefy!')
    end
end

local function onSafeZoneExit()
    if safeZoneCount > 0 then
        safeZoneCount = safeZoneCount - 1
    end
    
    if safeZoneCount <= 0 and isInSafeZone then
        safeZoneCount = 0
        isInSafeZone = false
        LocalPlayer.state:set('InSafeZone', false, true)
        SetPlayerInvincibleKeepRagdollEnabled(cachePlayerId, false)
        
        for ped, _ in pairs(disabledPeds) do
            if DoesEntityExist(ped) then
                ResetPedToDefault(ped)
            end
        end
        disabledPeds = {}
        processedPeds = {}
        
        ESX.ShowNotification('Opuściłeś zieloną strefę!')
    end
end

local function isPointInPolygon(point, polygon)
    local x, y = point.x, point.y
    local inside = false
    local j = #polygon
    
    for i = 1, #polygon do
        local xi, yi = polygon[i].x, polygon[i].y
        local xj, yj = polygon[j].x, polygon[j].y
        
        if ((yi > y) ~= (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi) then
            inside = not inside
        end
        j = i
    end
    
    return inside
end

local uwuZonePoints = {
    vec3(-602.0, -1083.0, 22.0),
    vec3(-619.0, -1024.0, 22.0),
    vec3(-609.0, -980.0, 22.0),
    vec3(-557.0, -981.0, 22.0),
    vec3(-556.0, -1088.0, 22.0),
}

local bahamaZonePoints = {
    vec3(-1395.0, -580.0, 30.0),
    vec3(-1370.0, -580.0, 30.0),
    vec3(-1370.0, -630.0, 30.0),
    vec3(-1395.0, -630.0, 30.0),
}

local function inside()
    if ESX.IsPlayerLoaded() then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local isInUwUZone = false
        local isInBahamaZone = false
        
        isInUwUZone = isPointInPolygon(playerCoords, uwuZonePoints)
        isInBahamaZone = isPointInPolygon(playerCoords, bahamaZonePoints)
        
        local allowedJobs = {"police", "ambulance", "mechanik", "ec", "uwucafe", "doj"}
        local isAllowedJob = false
        
        for _, job in ipairs(allowedJobs) do
            if ESX.PlayerData.job.name == job then
                isAllowedJob = true
                break
            end
        end
        
        if ESX.PlayerData.job.name == "uwucafe" and isInUwUZone and ESX.PlayerData.job.onDuty then
            isAllowedJob = true
        end
        
        if ESX.PlayerData.job.name == "bahama_mamas" and isInBahamaZone and ESX.PlayerData.job.onDuty then
            isAllowedJob = true
        end
        
        if not isAllowedJob then
            local attackControls = {24, 257, 25, 263, 140, 37, 69, 92}
            for _, control in ipairs(attackControls) do
                DisableControlAction(2, control, true)
            end
            DisableControlAction(0, 37, true)
            DisableControlAction(0, 69, true)
            DisableControlAction(0, 92, true)
        end
        
        local playerVehicle = GetVehiclePedIsIn(playerPed, false)
        if playerVehicle and playerVehicle ~= 0 then
            for _, playerId in ipairs(GetActivePlayers()) do
                local targetPed = GetPlayerPed(playerId)
                if targetPed ~= playerPed and DoesEntityExist(targetPed) then
                    SetEntityNoCollisionEntity(playerVehicle, targetPed, true)
                    
                    local targetVehicle = GetVehiclePedIsIn(targetPed, false)
                    if targetVehicle and targetVehicle ~= 0 then
                        SetEntityNoCollisionEntity(playerVehicle, targetVehicle, true)
                    end
                end
            end
        end
    end
end

local safeZones = {
    {
        name = "EMS",
        points = {
            vec3(1096.4857177734, -1455.4971923828, 34.0),
            vector3(1207.6826171875, -1454.0747070312,34.0),
            vector3(1212.5611572266, -1580.6131591797,34.0),
            vector3(1112.876953125, -1627.7545166016,34.0),
            vector3(1090.2587890625, -1497.0821533203,34.0)
        },
        thickness = 60.1
    },
    {
        name = "MRPD",
        points = {
            vec3(406.0, -1034.0, 29.0),
            vec3(409.0, -963.0, 29.0),
            vec3(493.0, -962.0, 29.0),
            vec3(494.0, -1025.0, 29.0),
        },
        thickness = 54.0
    },
    {
        name = "SandyEMS",
        points = {
            vec3(1739.0, 3605.0, 35.0),
            vec3(1804.0, 3641.0, 35.0),
            vec3(1782.0, 3678.0, 35.0),
            vec3(1719.0, 3640.0, 35.0),
        },
        thickness = 10.0
    },
    {
        name = "SandyLSPD",
        points = {
            vec3(1820.0, 3649.0, 34.0),
            vec3(1884.0, 3688.0, 34.0),
            vec3(1859.0, 3717.0, 34.0),
            vec3(1799.0, 3685.0, 34.0),
        },
        thickness = 10.0
    },
    {
        name = "PaletoEMS",
        points = {
            vec3(-257.0, 6294.0, 31.0),
            vec3(-226.0, 6326.0, 31.0),
            vec3(-257.0, 6355.0, 31.0),
            vec3(-288.0, 6324.0, 31.0),
        },
        thickness = 10.0
    },
    {
        name = "LSC",
        points = {
            vec3(-345.0, -110.0, 39.0),
            vec3(-308.0, -124.0, 39.0),
            vec3(-311.0, -131.0, 39.0),
            vec3(-306.0, -133.0, 39.0),
            vec3(-317.0, -162.0, 39.0),
            vec3(-335.0, -168.0, 39.0),
            vec3(-353.0, -161.0, 39.0),
            vec3(-369.0, -139.0, 39.0),
            vec3(-357.0, -108.0, 39.0),
        },
        thickness = 47.0
    },
    {
        name = "Mieszkania1",
        points = {
            vec3(-823.0, -2279.0, 9.0),
            vec3(-796.0, -2307.0, 9.0),
            vec3(-793.0, -2307.0, 9.0),
            vec3(-769.0, -2331.0, 9.0),
            vec3(-767.0, -2336.0, 9.0),
            vec3(-740.0, -2364.0, 9.0),
            vec3(-729.0, -2326.0, 9.0),
            vec3(-730.5, -2280.0, 9.0),
            vec3(-741.0, -2270.0, 9.0),
            vec3(-786.5, -2256.0, 9.0),
        },
        thickness = 36.0
    },
    {
        name = "Mieszkania2",
        points = {
            vec3(155.19999694824, -1008.0999755859, -99.0),
            vec3(150.39999389648, -1008.0999755859, -99.0),
            vec3(150.89999389648, -998.5, -99.0),
            vec3(157.19999694824, -999.79998779297, -99.0),
        },
        thickness = 3.2
    },
    {
        name = "Cardealer",
        points = {
            vec3(-65.0, -1123.0, 26.0),
            vec3(-71.0, -1117.0, 26.0),
            vec3(-52.0, -1065.0, 26.0),
            vec3(-2.0, -1082.0, 26.0),
            vec3(-15.0, -1120.0, 26.0),
        },
        thickness = 15.0
    },
    {
        name = "MazeBank",
        points = {
            vec3(-276.0, -2042.9000244141, 30.0),
            vec3(-283.29998779297, -2029.6999511719, 30.0),
            vec3(-255.0, -1992.0, 30.0),
            vec3(-243.0, -2003.0, 30.0),
            vec3(-247.10000610352, -2015.0, 30.0),
            vec3(-254.0, -2025.3000488281, 30.0),
            vec3(-261.0, -2033.3000488281, 30.0),
            vec3(-267.0, -2038.0, 30.0),
        },
        thickness = 10.3
    },
    {
        name = "DOJ",
        points = {
            vec3(-560.0, -283.0, 44.0),
            vec3(-468.0, -241.0, 44.0),
            vec3(-520.0, -147.0, 44.0),
            vec3(-612.0, -187.0, 44.0),
        },
        thickness = 60.0
    },
    {
        name = "Molo",
        points = {
            vec3(-1832.1979980469, -1156.8256835938, 13.0),
            vec3(-1782.1228027344, -1198.9409179688, 13.0),
            vec3(-1813.13671875, -1235.8154296875, 13.0),
            vec3(-1805.7912597656, -1242.4125976562, 13.0),
            vec3(-1806.9342041016, -1248.1694335938, 13.0),
            vec3(-1820.0, -1280.0, 13.0),
            vec3(-1850.0, -1300.0, 13.0),
            vec3(-1890.0, -1280.0, 13.0),
            vec3(-1890.0, -1250.0, 13.0),
            vec3(-1870.0, -1220.0, 13.0),
            vec3(-1879.7583007812, -1213.4318847656, 13.0)
        },
        thickness = 51.0
    },
    {
        name = "BMC",
        points = {
            vec3(329.21017456055, -787.46405029297, 29.0),
            vec3(338.09588623047, -757.06433105469, 29.0),
            vec3(365.611328125, -762.25225830078, 29.0),
            vec3(355.49606323242, -796.31488037109, 29.0)
        },
        thickness = 51.0
    },
    {
        name = "Atom",
        points = {
            vec3(55.0, 272.0, 110.0),
            vec3(94.0, 258.0, 110.0),
            vec3(109.0, 306.0, 110.0),
            vec3(89.0, 314.0, 110.0),
            vec3(71.0, 307.0, 110.0),
        },
        thickness = 51.0
    },
    {
        name = "UwU",
        points = {
            vec3(-602.0, -1083.0, 22.0),
            vec3(-619.0, -1024.0, 22.0),
            vec3(-609.0, -980.0, 22.0),
            vec3(-557.0, -981.0, 22.0),
            vec3(-556.0, -1088.0, 22.0),
        },
        thickness = 51.0
    },
    {
        name = "ExoticCustoms",
        points = {
            vec3(781.29742431641, -1250.8341064453, 26.0),
            vec3(780.2958984375, -1314.0036621094, 26.0),
            vec3(693.19860839844, -1314.8765869141, 26.0),
            vec3(695.20397949219, -1252.8526611328, 26.0)
        },
        thickness = 25.0
    },
    {
        name = "WhiteWidow",
        points = {
            vec3(117.50177001953, -11.530464172363, 67.0),
            vec3(92.81428527832, -4.6664390563965, 67.0),
            vec3(105.36357879639, 25.906581878662, 67.0),
            vec3(127.87502288818, 16.550172805786, 67.0)
        },
        thickness = 25.0
    },
    {
        name = "Pizzeria",
        points = {
            vec3(-1173.9400634766, -1408.8431396484, 4.0),
            vec3(-1187.9819335938, -1419.7216796875, 4.0),
            vec3(-1204.3911132812, -1396.0914306641, 4.0),
            vec3(-1186.4283447266, -1383.6749267578, 4.0)
        },
        thickness = 25.0
    },
    {
        name = "Weazel",
        points = {
            vec3(-608.24530029297, -940.38287353516, 23.0),
            vec3(-546.9345703125, -939.51489257812, 23.0),
            vec3(-532.89617919922, -885.00860595703, 23.0),
            vec3(-569.96417236328, -886.11920166016, 23.0),
            vec3(-570.22052001953, -904.86920166016, 23.0),
            vec3(-609.64172363281, -905.91809082031, 23.0)
        },
        thickness = 25.0
    },
    {
        name = "Bahama",
        points = {
            vec3(-1381.6209716797, -577.54937744141, 30.0),
            vec3(-1420.3203125, -598.90991210938, 30.0),
            vec3(-1388.7456054688, -645.69226074219, 30.0),
            vec3(-1357.7303466797, -621.19525146484, 30.0)
        },
        thickness = 25.0
    },
    {
        name = "Taxi",
        points = {
            vec3(-1220.0845947266, -283.10467529297, 37.0),
            vec3(-1236.9411621094, -256.72814941406, 37.0),
            vec3(-1275.4602050781, -278.24996948242, 37.0),
            vec3(-1262.9561767578, -303.6061706543, 37.0)
        },
        thickness = 25.0
    },
    {
        name = "Ubrania Grapeseed",
        points = {
            vec3(1680.0646972656, 4830.09765625, 41.94),
            vec3(1682.3833007812, 4814.0649414062, 41.94),
            vec3(1702.8660888672, 4816.6279296875, 41.94),
            vec3(1701.0041503906, 4833.216796875, 41.94)
        },
        thickness = 25.0
    },
    {
        name = "Ubraniowy #2",
        points = {
            vec3(-712.8232421875, -165.89292907715, 37.7),
            vec3(-722.40881347656, -149.52919006348, 37.7),
            vec3(-705.720703125, -139.53967285156, 37.7),
            vec3(-696.97808837891, -156.98338317871, 37.7)
        },
        thickness = 25.0
    },
    {
        name = "Ubraniowy #3",
        points = {
            vec3(-1202.6798095703, -786.97692871094, 17.7),
            vec3(-1210.1135253906, -777.12152099609, 17.7),
            vec3(-1184.326171875, -758.09411621094, 17.7),
            vec3(-1176.2012939453, -767.255859375, 17.7)
        },
        thickness = 25.0
    },
    {
        name = "Ubraniowy #4",
        points = {
            vec3(417.56097412109, -797.04565429688, 29.26),
            vec3(419.24514770508, -813.50537109375, 29.26),
            vec3(434.03262329102, -813.48352050781, 29.26),
            vec3(434.49658203125, -797.69213867188, 29.26)
        },
        thickness = 25.0
    },
    {
        name = "Ubraniowy #5",
        points = {
            vec3(-151.17700195312, -296.31753540039, 39.55),
            vec3(-159.49409484863, -315.61965942383, 39.55),
            vec3(-185.22927856445, -306.75350952148, 39.55),
            vec3(-177.75274658203, -285.04278564453, 39.55)
        },
        thickness = 25.0
    },
    {
        name = "Ubraniowy #6",
        points = {
            vec3(84.421424865723, -1384.4649658203, 29.8),
            vec3(67.803619384766, -1385.6901855469, 29.8),
            vec3(68.262771606445, -1402.5466308594, 29.8),
            vec3(84.089195251465, -1401.3289794922, 29.8)
        },
        thickness = 25.0
    },
    {
        name = "Ubraniowy #7",
        points = {
            vec3(-813.11450195312, -1075.2019042969, 11.6),
            vec3(-821.17932128906, -1063.8171386719, 11.6),
            vec3(-832.18853759766, -1071.3405761719, 11.6),
            vec3(-825.52075195312, -1085.3122558594, 11.6)
        },
        thickness = 25.0
    },
    {
        name = "Ubraniowy #8",
        points = {
            vec3(-1464.4296875, -239.13656616211, 49.3),
            vec3(-1449.3309326172, -224.14604187012, 49.3),
            vec3(-1436.6549072266, -236.06898498535, 49.3),
            vec3(-1449.1749267578, -253.35348510742, 49.3)
        },
        thickness = 25.0
    },
    {
        name = "Ubraniowy #9",
        points = {
            vec3(-6.9130730628967, 6514.525390625, 31.45),
            vec3(6.8156690597534, 6526.423828125, 31.45),
            vec3(20.498931884766, 6512.4672851562, 31.45),
            vec3(6.9458737373352, 6500.29296875, 31.45)
        },
        thickness = 25.0
    },
    {
        name = "Ubraniowy #10",
        points = {
            vec3(611.666015625, 2743.7673339844, 41.97),
            vec3(625.15399169922, 2745.0773925781, 41.97),
            vec3(623.37066650391, 2780.0900878906, 41.97),
            vec3(609.96264648438, 2779.7541503906, 41.97)
        },
        thickness = 25.0
    },
    {
        name = "Ubraniowy #11",
        points = {
            vec3(1203.6379394531, 2698.3537597656, 38.07),
            vec3(1187.9468994141, 2698.81640625, 38.07),
            vec3(1187.0314941406, 2719.693359375, 38.07),
            vec3(1202.6839599609, 2719.2946777344, 38.07)
        },
        thickness = 25.0
    },
    {
        name = "Ubraniowy #12",
        points = {
            vec3(-3160.6577148438, 1058.20703125, 20.85),
            vec3(-3172.931640625, 1063.1810302734, 20.85),
            vec3(-3184.466796875, 1033.0059814453, 20.85),
            vec3(-3171.8029785156, 1032.7857666016, 20.85)
        },
        thickness = 25.0
    },
    {
        name = "Ubraniowy #13",
        points = {
            vec3(-1089.3544921875, 2707.4301757812, 18.9),
            vec3(-1101.4219970703, 2697.5034179688, 18.9),
            vec3(-1114.6259765625, 2712.4645996094, 18.9),
            vec3(-1103.5543212891, 2723.3056640625, 18.9)
        },
        thickness = 25.0
    },
    {
        name = "Ubraniowy #14",
        points = {
            vec3(122.93204498291, -203.47470092773, 54.51),
            vec3(135.27255249023, -209.83735656738, 54.51),
            vec3(124.25117492676, -238.64497375488, 54.51),
            vec3(113.97885894775, -234.9997253418, 54.51)
        },
        thickness = 25.0
    },
    {
        name = "Ammonation #1",
        points = {
            vec3(-655.43249511719, -945.96661376953, 22.4),
            vec3(-667.23486328125, -946.18444824219, 22.4),
            vec3(-668.5244140625, -930.45159912109, 22.4),
            vec3(-657.46563720703, -929.76733398438, 22.4)
        },
        thickness = 25.0
    },
    {
        name = "Ammonation #2",
        points = {
            vec3(808.86480712891, -2148.2348632812, 29.1),
            vec3(831.14636230469, -2147.7263183594, 29.1),
            vec3(829.54016113281, -2198.8635253906, 29.1),
            vec3(802.07281494141, -2195.8159179688, 29.1)
        },
        thickness = 25.0
    },
    {
        name = "Ammonation #3",
        points = {
            vec3(1698.0610351562, 3746.791015625, 34.4),
            vec3(1705.97265625, 3753.7514648438, 34.4),
            vec3(1688.3811035156, 3770.4375, 34.4),
            vec3(1681.9781494141, 3761.8601074219, 34.4)
        },
        thickness = 25.0
    },
    {
        name = "Ammonation #4",
        points = {
            vec3(-326.84875488281, 6070.5, 31.3),
            vec3(-319.21090698242, 6080.4482421875, 31.3),
            vec3(-339.76400756836, 6101.1630859375, 31.3),
            vec3(-347.61779785156, 6090.9404296875, 31.3)
        },
        thickness = 25.0
    },
    {
        name = "Ammonation #5",
        points = {
            vec3(240.26727294922, -49.792869567871, 69.92),
            vec3(242.4740447998, -40.041488647461, 69.92),
            vec3(261.23474121094, -43.716869354248, 69.92),
            vec3(253.90563964844, -55.725143432617, 69.92)
        },
        thickness = 25.0
    },
    {
        name = "Ammonation #6",
        points = {
            vec3(21.243839263916, -1117.2628173828, 29.3),
            vec3(-2.9898900985718, -1109.7980957031, 29.3),
            vec3(19.561603546143, -1063.0726318359, 29.3),
            vec3(34.323894500732, -1070.6301269531, 29.3),
            vec3(21.500438690186, -1101.2087402344, 29.3),
            vec3(26.849241256714, -1102.4422607422, 29.3)
        },
        thickness = 25.0
    },
    {
        name = "Ammonation #7",
        points = {
            vec3(2559.0219726562, 306.16705322266, 108.56),
            vec3(2578.6813964844, 305.09353637695, 108.56),
            vec3(2579.3679199219, 279.23287963867, 108.56),
            vec3(2558.66796875, 278.25192260742, 108.56)
        },
        thickness = 25.0
    },
    {
        name = "Ammonation #8",
        points = {
            vec3(-1107.1262207031, 2692.23828125, 18.63),
            vec3(-1115.9096679688, 2684.6242675781, 18.63),
            vec3(-1130.5084228516, 2702.3920898438, 18.63),
            vec3(-1122.4969482422, 2709.8063964844, 18.63)
        },
        thickness = 25.0
    },
    {
        name = "Ammonation #9",
        points = {
            vec3(835.76824951172, -1014.8024902344, 27.85),
            vec3(848.30676269531, -1015.5667724609, 27.85),
            vec3(848.59918212891, -1038.2465820312, 27.85),
            vec3(835.50671386719, -1040.5079345703, 27.85)
        },
        thickness = 25.0
    },
    {
        name = "Ammonation #10",
        points = {
            vec3(-1316.9453125, -387.05514526367, 36.41),
            vec3(-1317.8522949219, -395.0207824707, 36.41),
            vec3(-1301.07421875, -399.02133178711, 36.41),
            vec3(-1301.6199951172, -389.43789672852, 36.41)
        },
        thickness = 25.0
    },
    {
        name = "Ammonation #11",
        points = {
            vec3(-3163.4204101562, 1077.0819091797, 20.77),
            vec3(-3160.1291503906, 1086.1751708984, 20.77),
            vec3(-3177.01171875, 1095.2432861328, 20.77),
            vec3(-3178.6730957031, 1085.3900146484, 20.77)
        },
        thickness = 25.0
    },
    {
        name = "Mexican Restaurant",
        points = {
            vec3(369.41784667969, -320.5500793457, 48.7),
            vec3(374.69665527344, -305.35037231445, 48.7),
            vec3(399.42657470703, -313.78485107422, 48.7),
            vec3(392.65451049805, -330.17498779297, 48.7)
        },
        thickness = 25.0
    },
}

local zonesCreated = false

if not zonesCreated then
    for i, zone in ipairs(safeZones) do
        lib.zones.poly({
            points = zone.points,
            thickness = zone.thickness,
            inside = inside,
            onEnter = onSafeZoneEnter,
            onExit = onSafeZoneExit
        })
    end
    zonesCreated = true
end

local ox_target = exports.ox_target

local function onPointEnter(point)
    if not point.entity then
        local model = lib.requestModel(`a_m_y_busicas_01`)

        Citizen.Wait(1000)

        local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z - 1.0, point.heading, false, true)
    
        TaskStartScenarioInPlace(entity, 'WORLD_HUMAN_AA_COFFEE', 0, true)
    
        SetModelAsNoLongerNeeded(model)
        FreezeEntityPosition(entity, true)
        SetEntityInvincible(entity, true)
        SetBlockingOfNonTemporaryEvents(entity, true)

        local canInteract = function()
            return not (LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cache.vehicle)
        end

        if point.photo then
            ox_target:addLocalEntity(entity, {
                {
                    icon = 'fa-solid fa-camera',
                    label = point.label,
                    canInteract = canInteract,
                    onSelect = function()
                        Citizen.Wait(1000)
                        ESX.ShowNotification('Aktualizowanie zdjęcia! (5 sekund)')
                        TriggerServerEvent('esx_hud:updateMugshotImage', exports.esx_menu:GetMugShotBase64(cache.ped, true), true)
                    end,
                    distance = 2.0
                }
            })
        else
            ox_target:addLocalEntity(entity, {
                {
                    icon = 'fa-solid fa-suitcase',
                    label = point.label,
                    canInteract = canInteract,
                    onSelect = function()
                        ESX.UI.Menu.Open(
                            'dialog', GetCurrentResourceName(), 'subowner_player',
                            {
                                title = "Tablica rejestracyjna",
                                align = 'center'
                            },
                            function(data, menu)
                                local plate = string.upper(tostring(data.value))
                                ESX.TriggerServerCallback('esx_garage:checkIfPlayerIsOwner', function(isOwner)
                                    if isOwner then
                                        menu.close()
                                        ESX.UI.Menu.Open(
                                            'default', GetCurrentResourceName(), 'subowner_menu',
                                            {
                                                title = "Zarządzanie pojazdem " .. plate,
                                                align = 'center',
                                                elements = {
                                                    {label = "Zmień rejestrację", value = 'change_rej'},
                                                }
                                            },
                                            function(data2, menu2)
                                                if data2.current.value == 'change_rej' then
                                                    local vehicles = ESX.Game.GetVehicles()
                                                    local found = false
                                                    
                                                    for _, vehicle in ipairs(vehicles) do
                                                        local vehiclePlate = GetVehicleNumberPlateText(vehicle, true)
                                                        if type(vehiclePlate) == 'string' then
                                                            vehiclePlate = vehiclePlate:gsub("%s$", "")
                                                            if vehiclePlate == plate then
                                                                found = true
                                                                break
                                                            end
                                                        end
                                                    end
                                                    
                                                    if found then
                                                        ESX.ShowNotification('Pojazd musi zostać schowany do garażu')
                                                    else
                                                        ESX.UI.Menu.Open(
                                                            'dialog', GetCurrentResourceName(), 'rejestracja',
                                                            {
                                                                title = "Nowa rejestracja (8 znaków włącznie ze spacjami)",
                                                                align = 'center'
                                                            },
                                                            function(data3, menu3)
                                                                if string.len(data3.value) == 8 then
                                                                    local newPlate = string.upper(data3.value)
                                                                    ESX.TriggerServerCallback('esx_vehicleshop:isPlateTaken', function (isPlateTaken)
                                                                        if not isPlateTaken then
                                                                            menu3.close()
                                                                            menu2.close()
                                                                            TriggerServerEvent('esx_garage:updatePlate', plate, newPlate)
                                                                        else
                                                                            ESX.ShowNotification('Ta rejestracja jest już zajęta')
                                                                        end
                                                                    end, newPlate)
                                                                else
                                                                    ESX.ShowNotification('Nieodpowiednia długość tekstu nowej rejestracji')
                                                                end
                                                            end,
                                                            function(data3, menu3)
                                                                menu3.close()
                                                            end
                                                        )
                                                    end
                                                end
                                            end,
                                            function(data2, menu2)
                                                menu2.close()
                                            end
                                        )
                                    else
                                        ESX.ShowNotification("Nie jesteś właścicielem tego pojazdu!")
                                    end
                                end, plate)
                            end,
                            function(data, menu)
                                menu.close()
                            end
                        )
                    end,
                    distance = 3.0
                }
            })
        end

        point.entity = entity
    end
end

local function onPointExit(point)
    local entity = point.entity

    if not entity then return end

    ox_target:removeLocalEntity(entity, point.label)
    
    if DoesEntityExist(entity) then
        SetEntityAsMissionEntity(entity, false, true)
        DeleteEntity(entity)
    end

    point.entity = nil
end

local pedsSpawn = {
    {coords = vec3(316.6917, -1638.9315, 32.5353), heading = 328.7504, photo = false, label = 'Zmień rejestracje pojazdu'},
    {coords = vec3(320.7420, -1642.3582, 32.5353), heading = 316.2070, photo = true, label = 'Aktualizuj zdjęcie w dokumentach'},
}

Citizen.CreateThread(function()
    for k, v in pairs(pedsSpawn) do
        lib.points.new({
            id = 200 + k,
            coords = v.coords,
            distance = 15,
            onEnter = onPointEnter,
            onExit = onPointExit,
            label = v.label,
            heading = v.heading,
            photo = v.photo
        })
    end
end)