--------------------
-- PROGRESS BAR ----
--------------------

function useProgressBar(text, time, animation, freeze, onFinish, onCancel, prop)
    time = time / 1000
    local data = {
        anim = animation,
        prop = prop,
        duration = time,
        label = text,
        useWhileDead = true,
        disable = {
            move = true,
        }
    }
    if exports.esx_hud:progressBar(data) then onFinish() else onCancel() end
end