local HeistConfig = require('config.heist')

---@param spotIndex number
---@return table<string, number>
return function(spotIndex)
    local spot = HeistConfig.lootSpots[spotIndex]
    if not spot or not spot.rewards then return {} end

    local items = {}

    for i = 1, #spot.rewards do
        local reward = spot.rewards[i]
        local roll = math.random(0, 100)

        if roll <= reward.chance then
            local amount = math.random(reward.min, reward.max)
            items[#items + 1] = { reward.item, amount }
        end
    end

    return items
end
