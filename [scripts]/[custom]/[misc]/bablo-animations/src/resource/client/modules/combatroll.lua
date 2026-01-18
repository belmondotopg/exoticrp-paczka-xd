if not Config.Modules['DisableCombatRoll'] then return end

CreateThread(function()
    while true do
        if GetIsTaskActive(cache.ped, 3) then
            TaskPlayAnim(cache.ped, "combat@aim_variations@1h", "aim_med", 8.0, -8.0, 100, 1, 0, false, false, false)
            Wait(0)
        else
            Wait(200)
        end
    end
end)
