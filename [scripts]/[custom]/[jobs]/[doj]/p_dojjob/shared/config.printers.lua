while not Config do Wait(1) end

--@param coords vector3
--@param radius number
--@param jobs table
Config.Printers = {
    ['CityHall_1'] = {
        coords = vec3(-554.64227294922, -182.35157775879, 38.221019744873),
        radius = 0.5,
        jobs = {
            ['doj'] = 0,
        },
    },
    ['CityHall_2'] = {
        coords = vec3(-581.89764404297, -221.33930969238, 38.221019744873),
        radius = 0.5,
        jobs = {
            ['doj'] = 0,
        },
    },
    ['CityHall_3'] = {
        coords = vec3(-587.99871826172, -209.9955291748, 38.221019744873),
        radius = 0.5,
        jobs = {
            ['doj'] = 0,
        },
    },
    ['Public'] = {
        coords = vec3(-1079.9, -244.0, 37.7),
        radius = 1.0,
    },

    -- FM CITY HALL LS
    -- ['LS_CityHall_1'] = {
    --     coords = vector3(-560.58, -603.95, 35.65),
    --     radius = 0.5,
    --     jobs = {
    --         ['doj'] = 0,
    --     },
    -- },
    -- ['LS_CityHall_2'] = {
    --     coords = vector3(-567.14, -604.0, 35.7),
    --     radius = 0.5,
    --     jobs = {
    --         ['doj'] = 0,
    --     },
    -- },
}