---@class MissionStarter
---@field coords vector3 Point coordinates (Center point of zone)
---@field radius number? Radius of zone. Defaults to 30

---@type MissionStarter[]
return {
    {
        coords = vec3(-926.40484619141, 158.7657623291, 63.475769042969),
        radius = 50.0,
        deskCoords = vec4(-926.40484619141, 158.7657623291, 63.475769042969-0.95, 55.03244018555),
        targetData = {
            coords = vec3(-926.40484619141, 158.7657623291, 63.475769042969),
            radius = 0.5,
            options = {
                {
                    icon = 'fas fa-laptop',
                    label = 'Rozpocznij hackowanie',
                    requiredItems = 'flipper',
                    actionId = 'hackComputer',
                    distance = 3
                },
                {
                    icon = 'fas fa-burst',
                    label = 'Rozjeb komputer',
                    weapon = 'WEAPON_CROWBAR', -- to musi istnieć ponieważ ox_target nie wysyła "items" do onSelect
                    requiredItems = 'WEAPON_CROWBAR',
                    equipped = true, -- dziala tylko jesli "weapon" jest zdefiniowane. jesli jest true, to wymaga wyciągnięcia tej broni.
                    actionId = 'destroyComputer',
                    distance = 3
                }
            }
        }
    }
}