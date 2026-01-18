RegisterNetEvent('exotic_nurek:updateMetadata', function(slotId, oxy)
    local source = source
    if not slotId or not oxy then
        return
    end
    
    local oxyPercent = (oxy / Config.fulltank) * 100
    local metadata = {
        oxy = oxy,
        description = string.format('Tlen: %.0f%%', oxyPercent)
    }
    
    exports.ox_inventory:SetMetadata(source, slotId, metadata)
end)