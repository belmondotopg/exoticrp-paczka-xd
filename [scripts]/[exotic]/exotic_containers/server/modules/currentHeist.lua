local Heist = require('server.classes.heist')

---@type ContainerHeist?
local currentHeist = nil

return {
    ---@param playerIdentifier string? Player Framework Identifier who started the heist
    ---@param coords vector4? Heist coordinates
    start = function(playerIdentifier, coords)
        if not playerIdentifier or not coords then return lib.print.error('"playerIdentifier" or "coords" missing.') end
        currentHeist = Heist:new(playerIdentifier, coords)
    end,
    stop = function()
        if not currentHeist then return false end

        currentHeist:stop()
        currentHeist = nil
        return true
    end,
    getCurrent = function()
        return currentHeist
    end,
}
