Config = {}

Config.Blips = {
    {
        Pos     = vector3(-601.1630, -2225.7285, 5.9925),
        Sprite  = 524,
        Display = 4,
        Scale   = 0.8,
        Colour  = 63,
        Label   = "Giełda samochodowa"
    },
}

Config.Peds = {
    {
        id = 15 + math.random(111, 999),
        distance = 200,
        coords = vec3(-601.1630, -2225.7285, 5.9925),
        heading = 139.5197,
        label = "Rozmawiaj",
    },
}

Config.VehiclesPlaces = {
    vec4(-604.2440, -2220.2351, 6.9930, 183.8472-.95),
    vec4(-609.0752, -2215.9553, 5.9958, 173.9686-.95),
    vec4(-613.8499, -2212.6401, 6.0044, 187.77960-.95),
}

Config.MarketDurationDays = 3

Config.TestDrive = {
    SpawnLocation = vec4(-712.9095, -2233.2588, 5.9366, 2.8587),
    Duration = 90,
    Cooldown = 3600,
    ReturnLocation = vec3(-600.5149, -2222.7605, 5.9921)
}