-- ⚠️ Each mission must be configured using the structure below! ⚠️

--- @param type: car / weapon / money / black_money / item
--- Description:
---   - "car" → Must be a vehicle available in the Vehicle Store. Otherwise, it will not appear.
---   - To assign a vehicle as a mission reward, enable "vehicle visibility" from the Admin Panel
---     and provide the model name using:
---       @param ModelName

-- 💡 Mission-related functions are located in:
--    config/Missions/MissionsFunctions.lua

Config.Missions = {
    -- Note: Metadata currently work only for ox_inventory. If you want to make metadata compatible with your inventory script:
    -- Files that need to be edited: `integrations/server/inventory/` and one of `framework/server` function Fr.AddItem
    
    ["find_vehicle"] = {
        UI = {
            missionLabel = "ZNAJDŹ POJAZD NA ULICY",
            missionDescription = "Znajdź model pojazdu, który ci wyślemy i przywieź go do nas, bez uszkodzeń.",
            missionExp = 100,
            missionReward = {
                label = "Ammo 9mm x100",
                nameSpawn = "ammo-9",
                amount = 100,
                img = "https://cdn3d.iconscout.com/3d/premium/thumb/ammo-3d-icon-download-in-png-blend-fbx-gltf-file-formats--ammunition-case-metal-box-bullet-military-pack-weapon-icons-9555390.png",
                rare = "red",
                type = "item",
                metadata = {
                    durability = 50
                }
            }
        },
        OnMissionStart = function()
            startFindVehicleMission()
        end,
    },
    ["laundry_100k"] = {
        UI = {
            missionLabel = "PRANIE 100 000$ BRUDNYCH PIENIĘDZY",
            missionDescription = "Wypierz 100 000$ brudnych pieniędzy w punkcie prania. Aby to zrobić, twoja organizacja musi odblokować ulepszenie Prania!",
            missionExp = 250,
            missionReward = {
                label = "2x Pistolet gazowy",
                nameSpawn = "weapon_pistol",
                amount = 2,
                img = "https://data.otherplanet.dev/fivemicons/%5bweapons%5d/weapon_pistol.png",
                rare = "purple",
                type = "item"
            }
        },
        OnMissionStart = function()
            startLaundryMission()
        end,
    },
    ["capture_3Zones"] = {
        UI = {
            missionLabel = "Przejmij przynajmniej 3 Strefy.",
            missionDescription = "Przejmij przynajmniej 3 strefy, aby zdobyć dodatkowe nagrody i punkty EXP dla swojej organizacji.",
            missionExp = 150,
            missionReward = {
                label = "20 000$",
                nameSpawn = "",
                amount = 20000,
                img = "https://cdn-icons-png.flaticon.com/512/7630/7630510.png",
                rare = "blue",
                type = "money"
            }
        },
        OnMissionStart = function()
            startZoneCaptureMission()
        end,
    },
    ["spray_graffiti"] = {
        UI = {
            missionLabel = "Misja Graffiti",
            missionDescription = "Namaluj przynajmniej 3 graffiti w Strefach Terytorialnych",
            missionExp = 180,
            missionReward = {
                label = "20 000$",
                nameSpawn = "",
                amount = 20000,
                img = "https://cdn-icons-png.flaticon.com/512/7630/7630510.png",
                rare = "blue",
                type = "money"
            }
        },
        OnMissionStart = function()
            startSprayGraffitiMission()
        end,
    },
    ["remove_graffiti"] = {
        UI = {
            missionLabel = "Misja Graffiti",
            missionDescription = "Usuń przynajmniej 5 graffiti wrogiego gangu",
            missionExp = 180,
            missionReward = {
                label = "20 000$",
                nameSpawn = "",
                amount = 20000,
                img = "https://cdn-icons-png.flaticon.com/512/7630/7630510.png",
                rare = "blue",
                type = "money"
            }
        },
        OnMissionStart = function()
            startRemoveGraffitiMission()
        end,
    },
    ["sell_drugs"] = {
        UI = {
            missionLabel = "Sprzedaj Narkotyki",
            missionDescription = "Sprzedaj narkotyki 50 osobom, wybrany narkotyk w Strefie Terytorialnej",
            missionExp = 180,
            missionReward = {
                label = "15 000$",
                nameSpawn = "",
                amount = 15000,
                img = "https://cdn-icons-png.flaticon.com/512/7630/7630510.png",
                rare = "blue",
                type = "money"
            }
        },
        OnMissionStart = function()
            startSellingDrugsMission()
        end,
    },
    ["steal_van"] = {
        UI = {
            missionLabel = "Ukradnij Furgonetkę",
            missionDescription = "Ukradnij furgonetkę z narkotykami od uzbrojonych gangsterów i dostarcz ją bezpiecznie",
            missionExp = 180,
            missionReward = {
                label = "30 000$",
                nameSpawn = "",
                amount = 20000,
                img = "https://cdn-icons-png.flaticon.com/512/7630/7630510.png",
                rare = "purple",
                type = "money"
            }
        },
        OnMissionStart = function()
            deliverVanMission()
        end,
    },
    ["drug_sell_npc"] = {
        UI = {
            missionLabel = "Dostarcz Narkotyki",
            missionDescription = "Dostarcz 50G Marihuany do Oznaczonej Lokalizacji.",
            missionExp = 120,
            missionReward = {
                label = "15 000$",
                nameSpawn = "",
                amount = 15000,
                img = "https://cdn-icons-png.flaticon.com/512/7630/7630510.png",
                rare = "purple",
                type = "money"
            }
        },
        OnMissionStart = function()
            startWeedDelivey()
        end,
    },

    --[[ 

    -------------------------------------------------
    -- ONLY FOR VEHICLE THEFT SCRIPT ----------------
    -- https://www.otherplanet.dev/product/6503031 --
    -------------------------------------------------

    ["vehicleTheft"] = {
        UI = {
            missionLabel = "Ukończ Hakowanie Kradzieży Pojazdu",
            missionDescription = "Rozpocznij i ukończ proces hakowania kradzieży pojazdu.",
            missionExp = 350,
            missionReward = {
                label = "50 000$",
                nameSpawn = "",
                amount = 15,
                img = "https://cdn-icons-png.flaticon.com/512/7630/7630510.png",
                rare = "blue",
                type = "money"
            }
        },
        OnMissionStart = function()
            startVehicleTheftMission()
        end,
    },]]--
}