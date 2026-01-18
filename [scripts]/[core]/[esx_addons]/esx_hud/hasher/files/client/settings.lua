RegisterNUICallback("nui:visible:close", function(data, cb) 
    if (data["elementId"] == "settings") then
        SetNuiFocus(false, false)
        cb(true)
    end 
end)

--LECOM KOTY LECOM DOBRZE CHLOPAKI ROBIA DOBRY PRZEKAZ LECI 
