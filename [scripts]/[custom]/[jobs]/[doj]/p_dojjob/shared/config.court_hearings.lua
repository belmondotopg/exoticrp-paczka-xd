while not Config do Wait(1) end

Config.CourtHearings = {}

Config.CourtHearings.TVs = { -- TV's with incoming court hearings
    ['CityHall_1'] = {
        coords = vec3(-530.80987548828, -189.45886962891, 38.521027374268),
        rotation = vec3(0.000000, 0.000000, 30.000000),
        distance = 30.0 -- spawn distance
    },

    -- FM CITY HALL LS
    -- ['LS_1'] = {
    --     coords = vector3(-508.8709, -609.7953, 36.2965),
    --     rotation = vector3(0.0, 0.0, 268.4732),
    --     distance = 30.0 -- spawn distance
    -- },
}

-- If you want to manage TV Players, remember you shouldn't restart the script while u on server because it will break the TV
Config.CourtHearings.EnableTVCreator = true -- enable TV creator [/tv_creator command]

Config.CourtHearings.TVPlayer = { -- playable TV's
    ['CityHall_1'] = {
        coords = vec3(-525.797058, -184.147018, 41.082928),
        menuCoords = vec3(-525.797058, -184.147018, 39.182928),
        rotation = vec3(0.000000, 0.000000, -30.000000),
        scale = vector3(1.35, 1.35, 1.35), -- scale x, y, z
        distance = 7.5, -- spawn distance
        jobs = {['doj'] = 9}, -- which jobs can manage the TV
    },

    -- FM CITY HALL LS
    -- ['LS_1'] = {
    --     coords = vec3(-524.146790, -585.560364, 37.803066),
    --     menuCoords = vector3(-523.7545, -583.8952, 35.7031),
    --     rotation = vec3(000000, 0.000000, -90.257896),
    --     scale = vector3(1.35, 1.35, 1.35), -- scale x, y, z
    --     distance = 7.5, -- spawn distance
    --     jobs = {['doj'] = 0}, -- which jobs can manage the TV
    -- },
}

Config.CourtHearings.Gavels = { -- Gavel's on Court hearings
    ['CityHall_1'] = {
        coords = vec3(-523.09997558594, -185.28038024902, 38.982963562012),
        jobs = {['doj'] = 0},
        volume = 0.6, -- sound volume [0.0 - 1.0]
        distance = 20.0 -- sound distance
    },

    -- FM CITY HALL LS
    -- ['LS_1'] = {
    --     coords = vector3(-516.02, -589.89, 36.2),
    --     jobs = {['doj'] = 0},
    --     volume = 0.5, -- sound volume [0.0 - 1.0]
    --     distance = 17.5 -- sound distance
    -- },
}

Config.CourtHearings.Microphones = {
    ['CityHall_Judge'] = {
        coords = vec3(-523.09997558594, -185.28038024902, 38.982963562012),
    },
    ['CityHall_Defense'] = {
        coords = vec3(-518.62750244141, -187.81289672852, 38.3381690979),
    },
    ['CityHall_Prosecutor'] = {
        coords = vec3(-523.27606201172, -190.50547790527, 38.338459014893),
    },

    -- FM CITY HALL LS
    -- ['LS_Judge'] = {
    --     coords = vector3(-516.6210, -589.0395, 36.2142),
    -- },
    -- ['LS_Defense'] = {
    --     coords = vector3(-518.3167, -595.8582, 35.6031),
    -- },
    -- ['LS_Prosecutor'] = {
    --     coords = vector3(-513.0540, -595.8336, 35.6031),
    -- },
}