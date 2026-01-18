Config = {}

Config.Debug = false

Config.Language = "en" -- Language to use.

Config.RenderDistance = 20.0 -- Model Display Radius.

Config.InteractDistance = 2.0 -- Interact Radius

Config.UseTarget = true -- When set to true, it'll use targeting instead of key-presses to interact.

Config.NoModelTargeting = true -- When set to true and using Target, it'll spawn a small invisible prop so you can third-eye when no entity is defined.

Config.Marker = { -- This will only be used if enabled, not using target, and no model is defined in the interaction.
    enabled = true,
    id = 2,
    scale = 0.25, 
    color = {255, 255, 255, 127}
}

Config.NavigationDisplay = true -- This will only be used if enabled, this is used to help the user find the activity point.

Config.ServeTimeOffline = false -- When set to true, players can serve their time offline, lowering the time by how long they were gone.

Config.EnableSneakout = false -- When set to true, anytime the player is outside the prison without being part of a breakout, they are freed instead of being brought back.

Config.XPEnabled = false -- When set to true, this will enable Pickle's XP compatibility, and enable xp rewards.

Config.XPCategories = { -- Registered XP Types for Pickle's XP.
    ["strength"] = {
        label = "Strength", 
        xpStart = 1000, 
        xpFactor = 0.2, 
        maxLevel = 100
    },
    ["cooking"] = {
        label = "Cooking", 
        xpStart = 1000, 
        xpFactor = 0.2, 
        maxLevel = 100
    },
}

Config.Default = {
    permissions = { -- Permissions settings for jailing, unjailing, and other things.
        jail = {
            jobs = {["police"] = 0, ["sheriff"] = 0}, -- ["job_name"] = rank_number, ["job_name2"] = rank_number2,
            groups = {'zarzad', 'menadzer', 'leaddeveloper', 'developer', 'headadmin', 'admin', 'moderator',"founder"} -- "group1", "group2"
        },
        unjail = {
            jobs = {["police"] = 2, ["sheriff"] = 2},
            groups = {'zarzad', 'menadzer', 'leaddeveloper', 'developer', 'headadmin', 'admin', 'moderator',"founder"}
        },
        alert = {
            jobs = {["police"] = 0, ["sheriff"] = 0},
            groups = {'zarzad', 'menadzer', 'leaddeveloper', 'developer', 'headadmin', 'admin', 'moderator'}
        },
    },
    outfit = { -- Prisoner outfits to set when in jail. Please change this according to your server's clothing numbers.
        male = {
            ['arms'] = 0,
            ['tshirt_1'] = 0, 
            ['tshirt_2'] = 0,
            ['torso_1'] = 22, 
            ['torso_2'] = 0,
            ['bproof_1'] = 0,
            ['bproof_2'] = 0,
            ['decals_1'] = 0, 
            ['decals_2'] = 0,
            ['chain_1'] = 0,
            ['chain_2'] = 0,
            ['pants_1'] = 5, 
            ['pants_2'] = 7,
            ['shoes_1'] = 1, 
            ['shoes_2'] = 0,
            ['helmet_1'] = 0, 
            ['helmet_2'] = 0,
        },
        female = {
            ['arms'] = 14,
            ['tshirt_1'] = 0, 
            ['tshirt_2'] = 0,
            ['torso_1'] = 14, 
            ['torso_2'] = 0,
            ['bproof_1'] = 0,
            ['bproof_2'] = 0,
            ['decals_1'] = 0, 
            ['decals_2'] = 0,
            ['chain_1'] = 0,
            ['chain_2'] = 0,
            ['pants_1'] = 3, 
            ['pants_2'] = 15,
            ['shoes_1'] = 1, 
            ['shoes_2'] = 0,
            ['helmet_1'] = 0, 
            ['helmet_2'] = 0,
        }
    }
}

Config.Activities = {
    ["workout"] = {
        label = "Zacznij / przestań trenować", -- Will have Start / Stop in front of interaction.
        sections = { -- Sections for this activity.
            ["lift"] = {
                label = "Podnoszenie ciężarów",
                rewards = {type = "minusTime", amount = math.random(1, 25)},
                process = function(data) -- Section function. 
                    local ped = PlayerPedId()
                    FreezeEntityPosition(ped, true)
                    SetEntityCoords(ped, data.coords.x, data.coords.y, data.coords.z - 1.0)
                    SetEntityHeading(ped, data.heading)
                    PlayAnim(ped, "amb@world_human_muscle_free_weights@male@barbell@base", "base", -8.0, 8.0, -1, 1, 1.0)
                    local prop = CreateProp(`prop_curl_bar_01`, data.coords.x, data.coords.y, data.coords.z + 1.0, true, true, false)
                    local off, rot = vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0)
                    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 28422), off.x, off.y, off.z, rot.x, rot.y, rot.z, false, false, false, true, 2, true)
                    local result
                    for i=1, 2 do 
                        result = lib.skillCheck({'easy', 'easy', 'easy'}, {'e'})
                        if not result then
                            break
                        end
                        Wait(1000)
                    end
                    FreezeEntityPosition(ped, false)
                    ClearPedTasks(ped)
                    DeleteEntity(prop)
                    return result 
                end
            },
            ["situp"] = {
                label = "Brzuszki",
                rewards = nil,
                process = function(data) -- Section function. 
                    local ped = PlayerPedId()
                    FreezeEntityPosition(ped, true)
                    SetEntityCoords(ped, data.coords.x, data.coords.y, data.coords.z - 1.0)
                    SetEntityHeading(ped, data.heading)
                    PlayAnim(ped, "amb@world_human_sit_ups@male@idle_a", "idle_a", -8.0, 8.0, -1, 1, 1.0)
                    local result
                    for i=1, 2 do 
                        result = lib.skillCheck({'easy', 'easy', 'easy'}, {'e'})
                        if not result then
                            break
                        end
                        Wait(1000)
                    end
                    FreezeEntityPosition(ped, false)
                    ClearPedTasks(ped)
                    return result 
                end
            },
            ["pushup"] = {
                label = "Pompki",
                rewards = { -- Rewards for completing the section.
                    {type = "minusTime", amount = math.random(1, 25)},
                },
                process = function(data) -- Section function. 
                    local ped = PlayerPedId()
                    FreezeEntityPosition(ped, true)
                    SetEntityCoords(ped, data.coords.x, data.coords.y, data.coords.z - 1.0)
                    SetEntityHeading(ped, data.heading)
                    PlayAnim(ped, "amb@world_human_push_ups@male@idle_a", "idle_d", -8.0, 8.0, -1, 1, 1.0)
                    local result
                    for i=1, 2 do 
                        result = lib.skillCheck({'easy', 'easy', 'easy'}, {'e'})
                        if not result then
                            break
                        end
                        Wait(1000)
                    end
                    FreezeEntityPosition(ped, false)
                    ClearPedTasks(ped)
                    return result 
                end
            },
            ["pullup"] = {
                label = "Podciąganie",
                rewards = nil,
                process = function(data) -- Section function.
                    local ped = PlayerPedId()
                    FreezeEntityPosition(ped, true)
                    SetEntityCoords(ped, data.coords.x, data.coords.y, data.coords.z - 1.0)
                    SetEntityHeading(ped, data.heading)
                    TaskStartScenarioInPlace(ped, "prop_human_muscle_chin_ups", 0, -1)
                    Wait(3000)
                    local result
                    for i=1, 2 do 
                        result = lib.skillCheck({'easy', 'easy', 'easy'}, {'e'})
                        if not result then
                            break
                        end
                        Wait(1000)
                    end
                    FreezeEntityPosition(ped, false)
                    ClearPedTasks(ped)
                    return result 
                end
            },
        }
    },
    ["clean"] = {
        label = "Zacznij / przestań czyścić podłogi", -- Will have Start / Stop in front of interaction.
        sections = { -- Sections for this activity.
            ["sweep"] = {
                label = "Zacznij zamiatać",
                rewards = {type = "minusTime", amount = math.random(1, 8)},
                process = function(data) -- Section function. 
                    local ped = PlayerPedId()
                    FreezeEntityPosition(ped, true)
                    SetEntityCoords(ped, data.coords.x, data.coords.y, data.coords.z)
                    SetEntityHeading(ped, data.heading)
                    PlayAnim(ped, "anim@amb@drug_field_workers@rake@male_a@base", "base", -8.0, 8.0, -1, 1, 1.0)
                    local prop = CreateProp(`prop_tool_broom`, data.coords.x, data.coords.y, data.coords.z + 1.0, true, true, false)
                    local off, rot = vector3(-0.01, 0.04, -0.03), vector3(0.0, 0.0, 0.0)
                    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 28422), off.x, off.y, off.z, rot.x, rot.y, rot.z, false, false, false, true, 2, true)
                    Wait(3000)
                    FreezeEntityPosition(ped, false)
                    ClearPedTasks(ped)
                    DeleteEntity(prop)
                    return true
                end
            },
        }
    },
    ["kitchen"] = {
        label = "Zacznij / przestań pracę w kuchni", -- Will have Start / Stop in front of interaction.
        sections = { -- Sections for this activity.
            ["stock"] = {
                label = "Zbierz składniki",
                rewards = nil, -- Rewards for completing the section.
                process = function(data) -- Section function. 
                    local ped = PlayerPedId()
                    FreezeEntityPosition(ped, true)
                    SetEntityHeading(ped, data.heading)
                    PlayAnim(ped, "amb@world_human_stand_fire@male@idle_a", "idle_a", -8.0, 8.0, -1, 1, 1.0)
                    Wait(5000)
                    FreezeEntityPosition(ped, false)
                    ClearPedTasks(ped)
                    return true
                end
            },
            ["cook"] = {
                label = "Gotuj danie",
                rewards = nil, -- Rewards for completing the section.
                process = function(data) -- Section function. 
                    local ped = PlayerPedId()
                    FreezeEntityPosition(ped, true)
                    SetEntityHeading(ped, data.heading)
                    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BBQ", 0, 1)
                    local result
                    for i=1, 2 do 
                        result = lib.skillCheck({'easy', 'easy', 'easy'}, {'e'})
                        if not result then
                            break
                        end
                        Wait(1000)
                    end
                    FreezeEntityPosition(ped, false)
                    ClearPedTasks(ped)
                    return result 
                end
            },
            ["toppings"] = {
                label = "Dodaj dodatki",
                rewards = nil, -- Rewards for completing the section.
                process = function(data) -- Section function. 
                    local ped = PlayerPedId()
                    FreezeEntityPosition(ped, true)
                    SetEntityHeading(ped, data.heading)
                    PlayAnim(ped, "amb@world_human_stand_fire@male@idle_a", "idle_a", -8.0, 8.0, -1, 1, 1.0)
                    Wait(5000)
                    FreezeEntityPosition(ped, false)
                    ClearPedTasks(ped)
                    return true
                end
            },
            ["delivery"] = {
                label = "Dostarcz jedzenie",
                rewards = {type = "minusTime", amount = math.random(1, 25)},
                process = function(data) -- Section function. 
                    local ped = PlayerPedId()
                    local prop = GetActivityEntity("tray")
                    if not object then 
                        prop = CreateProp(`prop_food_tray_03`, data.coords.x, data.coords.y, data.coords.z + 1.0, true, true, false)
                        AddActivityEntity("tray", prop)
                        local off, rot = vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0)
                        AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 28422), off.x, off.y, off.z, rot.x, rot.y, rot.z, false, false, false, true, 2, true)
                    end
                    FreezeEntityPosition(ped, true)
                    SetEntityHeading(ped, data.heading)
                    PlayAnim(ped, "mini@repair", "fixing_a_ped", -8.0, 8.0, -1, 1, 1.0)
                    Wait(500)
                    DetachEntity(prop, true, true)
                    FreezeEntityPosition(prop, true)
                    PlaceObjectOnGroundProperly(prop)
                    SetEntityHeading(prop, data.heading)
                    Wait(1000)
                    FreezeEntityPosition(ped, false)
                    ClearPedTasks(ped)
                    DeleteActivityEntity("tray")
                    return true
                end
            },
        }
    },
}

Config.Breakout = {
    alert = true, -- This will start the siren, and notify all law enforcement with permission.
    time = 120, -- In seconds, at the end of this time, the tunnel will close for other people to climb into.
    model = {modelType = "prop", hash = `prop_rock_1_i`, offset = vector3(0.0, 0.0, -0.2)},
    required = {
        {type = "item", name = "shovel", label = "Szpadel", amount = 1},
    }, 
    process = function(data)
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, true)
        SetEntityCoords(ped, data.coords.x, data.coords.y, data.coords.z - 1.0)
        SetEntityHeading(ped, data.heading)
        PlayAnim(ped, "random@burial", "a_burial", -8.0, 8.0, -1, 1, 1.0)
        local prop = CreateProp(`prop_tool_shovel`, data.coords.x, data.coords.y, data.coords.z + 1.0, true, true, false)
        local off, rot = vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0)
        AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 28422), off.x, off.y, off.z, rot.x, rot.y, rot.z, false, false, false, true, 2, true)
        local result
        for i=1, 2 do 
            result = lib.skillCheck({'medium', 'easy', 'medium'}, {'e'})
            if not result then
                break
            end
            Wait(1000)
        end
        FreezeEntityPosition(ped, false)
        ClearPedTasks(ped)
        DeleteEntity(prop)
        return result 
    end
}   

Config.Alerts = function(index, disabled)
    local prison = Config.Prisons[index]
    if (not disabled) then
        ShowNotification("W więźieniu: " .. prison.label .. " został włączony alarm!")
    end
end

Config.Prisons = {
    ["default"] = { -- Default is used as the prison location for players when not defined otherwise.
        label = "Bolingbroke - Zakład karny", -- Prison label for notifications & texts.
        coords = vector3(1691.8187, 2604.5383, 45.5648), -- Location of the prison.
        radius = 250.0, -- This is the radius that prisoners will be freed at when exceeding this number. 
        permissions = nil, -- When nil, defaults to Config.Default.permissions.  
        outfit = nil, -- When nil, defaults to Config.Default.outfit.  
        blip = {
            label = "Bolingbroke - Zakład karny",
            coords = vector3(1691.8187, 2604.5383, 45.5648),
            id = 188,
            color = 44,
            scale = 0.85,
        },
        hospital = {
            coords = vector3(1768.1461, 2570.0391, 45.7299),
            heading = 310.6851
        },
        release = {
            coords = vector3(1837.1589, 2590.9373, 46.0144-.95),
            heading = 183.1588
        },
        breakout = {
            start = {
                coords = vector3(1759.4132, 2471.3728, 45.7407),
                heading = 211.9629
            }, 
            enter = {
                coords = vector3(-472.8028, 2089.3516, 120.0673),
                heading = 195.9083
            },
            leave = {
                coords = vector3(-595.8946, 2088.1353, 131.3309),
                heading = 43.9493
            },
            finish = {
                coords = vector3(1947.4604, 2683.6985, 42.7468),
                heading = 33.8545
            },
        },
        activities = {
            {
                name = "workout",
                model = {hash = `u_m_y_prisoner_01`},
                coords = vector3(1750.0331, 2479.8518, 45.7407),
                heading = 27.7556,
                randomSection = true, -- Chooses random section when true, or top-to-bottom when false.
                sections = {
                    {
                        name = "lift",
                        coords = vector3(1743.8164, 2483.1914, 45.7407),
                        heading = 202.0358
                    },
                    {
                        name = "situp",
                        coords = vector3(1743.3867, 2480.9863, 45.7593),
                        heading = 123.3956
                    },
                    {
                        name = "pushup",
                        coords = vector3(1743.8944, 2479.2173, 45.7593),
                        heading = 119.1793
                    },
                    {
                        name = "pullup",
                        coords = vector3(1746.5868, 2481.5996, 45.7407),
                        heading = 118.0926
                    },
                }
            },
            {
                name = "clean",
                model = {hash = `u_m_y_prisoner_01`},
                coords = vector3(1773.9653, 2493.1362, 45.7408),
                heading = 111.6702,
                randomSection = true, -- Chooses random section when true, or top-to-bottom when false.
                sections = {
                    {
                        name = "sweep",
                        coords = vector3(1767.6052, 2501.1599, 44.7407), -- Location of the cell.
                        heading = 207.8018, -- Direction to face the player upon spawn.
                    },
                    {
                        name = "sweep",
                        coords = vector3(1765.1724, 2498.3315, 44.7407), -- Location of the cell.
                        heading = 207.8018, -- Direction to face the player upon spawn.
                    },
                    {
                        name = "sweep",
                        coords = vector3(1762.1005, 2496.5417, 44.7407), -- Location of the cell.
                        heading = 207.8018, -- Direction to face the player upon spawn.
                    },
                    {
                        name = "sweep",
                        coords = vector3(1755.3977, 2492.9087, 44.7407), -- Location of the cell.
                        heading = 207.8018, -- Direction to face the player upon spawn.
                    },
                    {
                        name = "sweep",
                        coords = vector3(1752.5946, 2491.2573, 44.7407), -- Location of the cell.
                        heading = 207.8018, -- Direction to face the player upon spawn.
                    },
                    {
                        name = "sweep",
                        coords = vector3(1749.4236, 2489.4070, 44.7407), -- Location of the cell.
                        heading = 207.8018, -- Direction to face the player upon spawn.
                    },
                }
            },
            {
                name = "kitchen",
                model = {hash = `s_m_y_chef_01`},
                coords = vector3(1787.3306, 2562.6624, 45.6731),
                heading = 111.6702,
                randomSection = false, -- Chooses random section when true, or top-to-bottom when false.
                sections = {
                    {
                        name = "stock",
                        coords = vector3(1785.7053, 2564.3765, 45.6731), -- Location of the cell.
                        heading = 4.2023, -- Direction to face the player upon spawn.
                    },
                    {
                        name = "cook",
                        coords = vector3(1780.9863, 2564.6482, 45.5927), -- Location of the cell.
                        heading = 5.9864, -- Direction to face the player upon spawn.
                    },
                    {
                        name = "toppings",
                        coords = vector3(1781.5797, 2560.6870, 45.6731), -- Location of the cell.
                        heading = 179.1711, -- Direction to face the player upon spawn.
                    },
                    {
                        name = "delivery",
                        coords = vector3(1785.5145, 2554.4749, 45.6731), -- Location of the cell.
                        heading = 270.9756, -- Direction to face the player upon spawn.
                    },
                }
            },
        },
        cells = {
            {
                coords = vector3(1767.6052, 2501.1599, 44.7407), -- Location of the cell.
                heading = 207.8018, -- Direction to face the player upon spawn.
                size = 1.5, -- Size to check to see if any players are inside the cell.
            },
            {
                coords = vector3(1765.1724, 2498.3315, 44.7407), -- Location of the cell.
                heading = 207.8018, -- Direction to face the player upon spawn.
                size = 1.5, -- Size to check to see if any players are inside the cell.
            },
            {
                coords = vector3(1762.1005, 2496.5417, 44.7407), -- Location of the cell.
                heading = 207.8018, -- Direction to face the player upon spawn.
                size = 1.5, -- Size to check to see if any players are inside the cell.
            },
            {
                coords = vector3(1755.3977, 2492.9087, 44.7407), -- Location of the cell.
                heading = 207.8018, -- Direction to face the player upon spawn.
                size = 1.5, -- Size to check to see if any players are inside the cell.
            },
            {
                coords = vector3(1752.5946, 2491.2573, 44.7407), -- Location of the cell.
                heading = 207.8018, -- Direction to face the player upon spawn.
                size = 1.5, -- Size to check to see if any players are inside the cell.
            },
            {
                coords = vector3(1749.4236, 2489.4070, 44.7407), -- Location of the cell.
                heading = 207.8018, -- Direction to face the player upon spawn.
                size = 1.5, -- Size to check to see if any players are inside the cell.
            },
        },
        stores = {},
        lootables = {
            -- {
            --     label = "Drewno", -- Lootable Label.
            --     coords = vector3(1627.9252, 2539.87, 45.7227),
            --     heading = 277.6246,
            --     model = {modelType = "prop", hash = `prop_cons_plank`},
            --     regenTime = 5, -- Time after redemption it can be redeemed again.
            --     rewards = { -- Rewards for redeeming the lootable.
            --         {type = "item", name = "wood", amount = 1},
            --     },
            -- },
            -- {
            --     label = "Metal",
            --     coords = vector3(1776.5386, 2563.7231, 45.57),
            --     heading = 1.5599,
            --     model = {modelType = "prop", hash = `prop_ladel`, offset = vector3(0.0, 0.0, 1.0)},
            --     regenTime = 5, -- Time after redemption it can be redeemed again.
            --     rewards = { -- Rewards for redeeming the lootable.
            --         {type = "item", name = "metal", amount = 1},
            --     },
            -- },
            -- {
            --     label = "Lina",
            --     coords = vector3(1689.0037, 2548.8884, 45.5604),
            --     heading = 35.3041,
            --     model = {modelType = "prop", hash = `prop_rope_family_3`},
            --     regenTime = 5, -- Time after redemption it can be redeemed again.
            --     rewards = { -- Rewards for redeeming the lootable.
            --         {type = "item", name = "rope", amount = 1},
            --     },
            -- },
        }
    }
}