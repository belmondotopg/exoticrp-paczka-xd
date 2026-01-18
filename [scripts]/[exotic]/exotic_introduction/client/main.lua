local isOpen = false

function switch()
    if isOpen then
        isOpen = false
    else
        isOpen = true
    end

    SetNuiFocus(isOpen, isOpen)
    SendNUIMessage({
        eventName = "nui:switch",
        open = isOpen
    })
end

RegisterNuiCallback("exotic-introduction:nui:close", function(_, cb)
    switch()
    cb("ok")
end)

RegisterCommand("poradnik", function()
    switch()
end)

exports("switchNui", switch)