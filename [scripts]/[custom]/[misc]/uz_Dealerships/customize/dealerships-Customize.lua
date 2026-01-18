-- # Dealerships and Locations

Customize.DealershipLocations = {
    -- # Premium Deluxe Motorsport
    {
        name = 'Salon Samochodowy', -- Blip Name
        uiColor = { r = 255, g = 128, b = 0 }, -- UI Color (only rgb color is supported)
        categories = {'sports', 'super', 'muscle', 'sportsclassics', 'sedans', 'coupes', 'suvs', 'offroad', 'motorcycles', 'compacts', 'vans'}, -- multiple categories can be selected
        coords = {
            openShowroom = vector3(-56.6702, -1097.7786, 27.5380-.95),
            showroomVehicleSpawn = vector3(199.53, -1000.94, -99.0),--vec4(199.55, -1000.94, -99.0, 181.57)
            buyVehicleSpawn = vector4(-9.86, -1096.73, 26.67, 103.29),
            testDriveSpawn = vector4(-55.69, -1109.05, 26.44, 73.7),
            alternativeSpawns = {
                vec4(-10.98, -1099.56, 26.67, 104.06),
                vec4(-11.58, -1102.42, 26.67, 103.2),
                vec4(-12.66, -1105.16, 26.67, 101.48),
                vec4(-13.87, -1108.02, 26.67, 100.41)
            },
        },
        blip = { hide = false, id = 326, color = 3, scale = 0.6 },
        interactType = 'target', -- default: marker, target: qb-target, ox_target
        drawtextType = 'default', -- default: fivem - (doesn't work if target is active)
        setMarker = function(coords) -- DrawMarker: https://docs.fivem.net/natives/?_0x28477EC23D892089
            DrawMarker(21, coords.x, coords.y, coords.z,  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 120, 0, 0, 1, 0)
        end,
        interaction = {
            enabled = true, -- interaction: true, false
            engine = {
                enabled = true,
                icon = 'fa-solid fa-gear',
            },
            boot = {
                enabled = true,
                icon = 'fa-solid fa-box',
            },
            bonnet = {
                enabled = true,
                icon = 'fa-solid fa-car-battery',
            },
            doors = {
                enabled = true,
                icon = 'fa-solid fa-door-closed',
            },
            lights = {
                enabled = true,
                icon = 'fa-solid fa-lightbulb',
            }
        },
        customRoom = {
            enabled = true,
            image = '1.gif', -- webp, jpg, png, gif
            roomDimensions = {
                width = 11.0, -- width of the room
                length = 11.0, -- length of the room
                height = 3.0, -- height of the room
                floorZ = -0.98, -- floor height of the room
            },
            Wall = {
                Ceiling = false,
                Ground = false,
                left = false,
                right = false,
                front = false,
                back = false,
            }
        },
        colourOptions = { -- https://docs.fivem.net/docs/game-references/vehicle-references/vehicle-colours/ or https://pastebin.com/pwHci0xK
            { hex = '#000000', index = 0 }, -- Black
            { hex = '#1A1A1A', index = 1 }, -- Graphite
            { hex = '#333333', index = 3 }, -- Dark Steel
            { hex = '#C0C0C0', index = 4 }, -- Silver
            { hex = '#777777', index = 7 }, -- Shadow Silver
            { hex = '#e81416', index = 27 }, -- Red
            { hex = '#C00E1A', index = 28 }, -- Torino Red
            { hex = '#650101', index = 34 }, -- Cabernet Red
            { hex = '#FF3399', index = 135 }, -- Hot Pink
            { hex = '#ff7518', index = 38 }, -- Orange
            { hex = '#FC5E03', index = 36 }, -- Sunrise Orange
            { hex = '#DFB141', index = 99 }, -- Gold
            { hex = '#ffbf00', index = 88 }, -- Yellow
            { hex = '#355E3B', index = 49 }, -- Dark Green
            { hex = '#79c314', index = 92 }, -- Lime Green
            { hex = '#59B268', index = 53 }, -- Bright Green
            { hex = '#233874', index = 62 }, -- Dark Blue
            { hex = '#487de7', index = 64 }, -- Blue
            { hex = '#83B8E6', index = 74 }, -- Light Blue
            { hex = '#70369d', index = 145 }, -- Bright Purple
            { hex = '#4A55A7', index = 72 }, -- Spinnaker Purple
            { hex = '#6F4830', index = 97 }, -- Maple Brown
            { hex = '#A35638', index = 104 }, -- Sienna Brown
            { hex = '#ffffff', index = 111 }, -- Ice White
        },

        camera = {
            angle = 35.0,          -- Camera angle (degrees)
            height = 0.5,         -- Camera height from the center of the vehicle
            distance = 6.0,       -- Camera distance from the vehicle
            fov = 45.0,           -- Camera field of view (FOV)
            sensitivityX = 0.2,   -- X axis sensitivity
            sensitivityY = 0.004, -- Y axis sensitivity
            zoomAmount = 0.3,     -- Zoom amount
            isMoving = false,     -- Is the camera moving?
            lastMoveTime = 0,     -- Last move time
            minHeight = -0.5,     -- Minimum height
            maxHeight = 1.5,      -- Maximum height
            minDistance = 2.0,    -- Minimum distance
            maxDistance = 7.0    -- Maximum distance || 10.0
        }
    },

    -- # Marina Shop
    -- {
    --     name = 'Marina Shop ', -- Blip Name
    --     uiColor = { r = 255, g = 128, b = 0 }, -- UI Color (only rgb color is supported)
    --     categories = {'boats'}, -- multiple categories can be selected
    --     coords = {
    --         openShowroom = vec3(-743.52, -1334.23, 1.6),
    --         showroomVehicleSpawn = vector3(-712.5, -1342.56, 0.12),
    --         buyVehicleSpawn = vec4(-747.32, -1375.5, 0.13, 141.46),
    --         testDriveSpawn = vec4(-766.63, -1399.76, 0.12, 141.45),
    --         alternativeSpawns = {
    --             vec4(-727.05, -1326.59, -0.50, 229.5),
    --             vec4(-732.84, -1333.5, -0.50, 229.5),
    --             vec4(-737.84, -1340.83, -0.50, 229.5),
    --             vec4(-741.53, -1349.7, -0.50, 229.5),
    --         },
    --     },
    --     blip = { hide = false, id = 410, color = 3, scale = 0.6 },
    --     interactType = 'default', -- default: marker, target: qb-target, ox_target
    --     drawtextType = 'default', -- default: fivem - (doesn't work if target is active)
    --     setMarker = function(coords) -- DrawMarker: https://docs.fivem.net/natives/?_0x28477EC23D892089
    --         DrawMarker(21, coords.x, coords.y, coords.z,  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 120, 0, 0, 1, 0)
    --     end,
    --     colourOptions = { -- https://docs.fivem.net/docs/game-references/vehicle-references/vehicle-colours/ or https://pastebin.com/pwHci0xK
    --         { hex = '#000000', index = 0 }, -- Black
    --         { hex = '#1A1A1A', index = 1 }, -- Graphite
    --         { hex = '#333333', index = 3 }, -- Dark Steel
    --         { hex = '#C0C0C0', index = 4 }, -- Silver
    --         { hex = '#777777', index = 7 }, -- Shadow Silver
    --         { hex = '#e81416', index = 27 }, -- Red
    --         { hex = '#C00E1A', index = 28 }, -- Torino Red
    --         { hex = '#650101', index = 34 }, -- Cabernet Red
    --         { hex = '#FF3399', index = 135 }, -- Hot Pink
    --         { hex = '#ff7518', index = 38 }, -- Orange
    --         { hex = '#FC5E03', index = 36 }, -- Sunrise Orange
    --         { hex = '#DFB141', index = 99 }, -- Gold
    --         { hex = '#ffbf00', index = 88 }, -- Yellow
    --         { hex = '#355E3B', index = 49 }, -- Dark Green
    --         { hex = '#79c314', index = 92 }, -- Lime Green
    --         { hex = '#59B268', index = 53 }, -- Bright Green
    --         { hex = '#233874', index = 62 }, -- Dark Blue
    --         { hex = '#487de7', index = 64 }, -- Blue
    --         { hex = '#83B8E6', index = 74 }, -- Light Blue
    --         { hex = '#70369d', index = 145 }, -- Bright Purple
    --         { hex = '#4A55A7', index = 72 }, -- Spinnaker Purple
    --         { hex = '#6F4830', index = 97 }, -- Maple Brown
    --         { hex = '#A35638', index = 104 }, -- Sienna Brown
    --         { hex = '#ffffff', index = 111 }, -- Ice White
    --     },
    --     interaction = {
    --         enabled = true, -- interaction: true, false
    --         engine = {
    --             enabled = true,
    --             icon = 'fa-solid fa-gear',
    --         },
    --         boot = {
    --             enabled = true,
    --             icon = 'fa-solid fa-box',
    --         },
    --         bonnet = {
    --             enabled = true,
    --             icon = 'fa-solid fa-car-battery',
    --         },
    --         doors = {
    --             enabled = true,
    --             icon = 'fa-solid fa-door-closed',
    --         },
    --         lights = {
    --             enabled = true,
    --             icon = 'fa-solid fa-lightbulb',
    --         }
    --     },
    --     customRoom = {
    --         enabled = false,
    --         image = '1.gif', -- webp, jpg, png, gif
    --         roomDimensions = {
    --             width = 11.0, -- width of the room
    --             length = 11.0, -- length of the room
    --             height = 3.0, -- height of the room
    --             floorZ = -0.98, -- floor height of the room
    --         },
    --         Wall = {
    --             Ceiling = false,
    --             Ground = false,
    --             left = false,
    --             right = false,
    --             front = false,
    --             back = false,
    --         }
    --     },

    --     camera = {
    --         angle = 35.0,
    --         height = 4.5,
    --         distance = 6.0,
    --         fov = 45.0,
    --         sensitivityX = 0.2,
    --         sensitivityY = 0.004,
    --         zoomAmount = 0.3,
    --         isMoving = false,
    --         lastMoveTime = 0,
    --         minHeight = -0.5,
    --         maxHeight = 5.5,
    --         minDistance = 5.0,
    --         maxDistance = 25.0
    --     }
    -- },

    -- # Air Shop
    -- {
    --     name = 'Air Shop', -- Blip Name
    --     uiColor = { r = 255, g = 128, b = 0 },
    --     categories = {'helicopters', 'planes'}, -- multiple categories can be selected
    --     coords = {
    --         openShowroom = vec3(-1621.55, -3152.66, 13.99),
    --         showroomVehicleSpawn = vector3(-1650.15, -3140.17, 13.99),
    --         buyVehicleSpawn = vec4(-1617.49, -3086.17, 13.94, 329.2),
    --         testDriveSpawn = vec4(-1617.49, -3086.17, 13.94, 329.2),
    --         alternativeSpawns = {
    --             vec4(-1651.36, -3162.66, 12.99, 346.89),
    --             vec4(-1668.53, -3152.56, 12.99, 303.22),
    --             vec4(-1632.02, -3144.48, 12.99, 31.08),
    --             vec4(-1663.74, -3126.32, 12.99, 275.03),
    --         },
    --     },
    --     blip = { hide = false, id = 251, color = 3, scale = 0.7 },
    --     interactType = 'default', -- default: marker, target: qb-target, ox_target
    --     drawtextType = 'default', -- default: fivem - (doesn't work if target is active)
    --     setMarker = function(coords) -- DrawMarker: https://docs.fivem.net/natives/?_0x28477EC23D892089
    --         DrawMarker(21, coords.x, coords.y, coords.z,  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 120, 0, 0, 1, 0)
    --     end,
    --     colourOptions = { -- https://docs.fivem.net/docs/game-references/vehicle-references/vehicle-colours/ or https://pastebin.com/pwHci0xK
    --         { hex = '#000000', index = 0 }, -- Black
    --         { hex = '#1A1A1A', index = 1 }, -- Graphite
    --         { hex = '#333333', index = 3 }, -- Dark Steel
    --         { hex = '#C0C0C0', index = 4 }, -- Silver
    --         { hex = '#777777', index = 7 }, -- Shadow Silver
    --         { hex = '#e81416', index = 27 }, -- Red
    --         { hex = '#C00E1A', index = 28 }, -- Torino Red
    --         { hex = '#650101', index = 34 }, -- Cabernet Red
    --         { hex = '#FF3399', index = 135 }, -- Hot Pink
    --         { hex = '#ff7518', index = 38 }, -- Orange
    --         { hex = '#FC5E03', index = 36 }, -- Sunrise Orange
    --         { hex = '#DFB141', index = 99 }, -- Gold
    --         { hex = '#ffbf00', index = 88 }, -- Yellow
    --         { hex = '#355E3B', index = 49 }, -- Dark Green
    --         { hex = '#79c314', index = 92 }, -- Lime Green
    --         { hex = '#59B268', index = 53 }, -- Bright Green
    --         { hex = '#233874', index = 62 }, -- Dark Blue
    --         { hex = '#487de7', index = 64 }, -- Blue
    --         { hex = '#83B8E6', index = 74 }, -- Light Blue
    --         { hex = '#70369d', index = 145 }, -- Bright Purple
    --         { hex = '#4A55A7', index = 72 }, -- Spinnaker Purple
    --         { hex = '#6F4830', index = 97 }, -- Maple Brown
    --         { hex = '#A35638', index = 104 }, -- Sienna Brown
    --         { hex = '#ffffff', index = 111 }, -- Ice White
    --     },
    --     interaction = {
    --         enabled = false, -- interaction: true, false
    --         engine = {
    --             enabled = false,
    --             icon = 'fa-solid fa-gear',
    --         },
    --         boot = {
    --             enabled = false,
    --             icon = 'fa-solid fa-box',
    --         },
    --         bonnet = {
    --             enabled = false,
    --             icon = 'fa-solid fa-car-battery',
    --         },
    --         doors = {
    --             enabled = false,
    --             icon = 'fa-solid fa-door-closed',
    --         },
    --         lights = {
    --             enabled = true,
    --             icon = 'fa-solid fa-lightbulb',
    --         }
    --     },
    --     customRoom = {
    --         enabled = false,
    --         image = '1.gif', -- webp, jpg, png, gif
    --         roomDimensions = {
    --             width = 11.0, -- width of the room
    --             length = 11.0, -- length of the room
    --             height = 3.0, -- height of the room
    --             floorZ = -0.98, -- floor height of the room
    --         },
    --         Wall = {
    --             Ceiling = false,
    --             Ground = false,
    --             left = false,
    --             right = false,
    --             front = false,
    --             back = false,
    --         }
    --     },
    --     -- finance
    --     finance = {
    --         {
    --             paymentCount = 4,                 -- Total number of installments
    --             downPaymentRate = 0.2,            -- Down payment rate (e.g. 0.2 = %20)
    --             interestRate = 0.05,              -- Interest rate (e.g. 0.05 = %5)
    --             paymentIntervalHours = 12,        -- Game time between installments
    --             repoGracePeriodHours = 1,         -- Repo grace period (hours)
    --         },
    --     },

    --     camera = {
    --         angle = 35.0,
    --         height = 0.5,
    --         distance = 6.0,
    --         fov = 45.0,
    --         sensitivityX = 0.2,
    --         sensitivityY = 0.004,
    --         zoomAmount = 0.3,
    --         isMoving = false,
    --         lastMoveTime = 0,
    --         minHeight = -0.5,
    --         maxHeight = 4.5,
    --         minDistance = 5.0,
    --         maxDistance = 25.0
    --     }
    -- },
}