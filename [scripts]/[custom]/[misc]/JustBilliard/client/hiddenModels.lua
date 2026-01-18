-- Hide default in-game pool tables and other props. F.e. in Yellow Jack bar.
local locations = {
    -- Yellow jack
    {
        coords = vector3(1992.8033447265625, 3047.312255859375, 46.22865295410156),
        hashes = {
            `prop_pooltable_3b`,
            `prop_poolball_4`,
            `prop_poolball_12`,
            `prop_poolball_15`,
            `prop_poolball_cue`,
            `prop_pool_cue`, 
        },
    },
}

CreateThread(function()
    for k,v in ipairs(locations) do
        local coords = v.coords
        local hashes = v.hashes
        for _,hash in pairs(hashes) do
            CreateModelHideExcludingScriptObjects(coords.x, coords.y, coords.z, 3.0, hash, true)
        end
    end
end)