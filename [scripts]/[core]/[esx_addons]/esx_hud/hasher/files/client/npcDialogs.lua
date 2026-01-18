local callback = nil

function sendNPCDialogSync(dialogId, showProgress, pages)
    while callback ~= nil do
        Citizen.Wait(0)
    end
    
    local dialogData = {
        id = dialogId,
        showProgress = showProgress,
        pages = pages
    }
    
    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "npc-dialogs",
        visible = true
    })
    
    SendNUIMessage({
        eventName = "nui:data:update",
        dataId = "npc-dialogs",
        data = dialogData
    })
    
    SetNuiFocus(true, true)
    
    local returnedData = false
    callback = function(data)
        returnedData = data
        SetNuiFocus(false, false)
        SendNUIMessage({
            eventName = "nui:visible:update",
            elementId = "npc-dialogs",
            visible = false
        })
        callback = nil
    end
    
    while returnedData == false do
        Citizen.Wait(0)
    end
    
    return returnedData
end

function sendNPCDialogAsync(dialogId, showProgress, pages, cb)
    while callback ~= nil do
        Citizen.Wait(0)
    end
    
    local dialogData = {
        id = dialogId,
        showProgress = showProgress,
        pages = pages
    }
    
    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "npc-dialogs",
        visible = true
    })
    
    SendNUIMessage({
        eventName = "npc-dialogs",
        data = dialogData
    })
    
    SetNuiFocus(true, true)
    
    callback = function(data) 
        SetNuiFocus(false, false)
        SendNUIMessage({
            eventName = "nui:visible:update",
            elementId = "npc-dialogs",
            visible = false
        })
        cb(data)
        callback = nil
    end
end

function sendDialogNpcSync(npcName, npcQuestion, dialogOptions)
    while callback ~= nil do
        Citizen.Wait(0)
    end
    
    local buttons = {}
    local hasCancel = false
    
    for _, option in ipairs(dialogOptions) do
        if option.id == "cancel" then
            hasCancel = true
        end
        
        table.insert(buttons, {
            value = option.id,
            label = option.text
        })
    end
    
    if not hasCancel then
        table.insert(buttons, {
            value = "cancel",
            label = "Jednak nie chcę z Tobą rozmawiać."
        })
    end
    
    local dialogId = "legacy-dialog-" .. GetGameTimer()
    local showProgress = false
    local pages = {
        {
            name = "main_question",
            question = {
                userName = npcName,
                text = npcQuestion
            },
            buttons = buttons
        }
    }
    
    local result = sendNPCDialogSync(dialogId, showProgress, pages)
    
    if result.cancelled then
        return "cancel"
    else
        return result.answers.main_question or "cancel"
    end
end

function sendDialogNpcAsync(npcName, npcQuestion, dialogOptions, cb)
    while callback ~= nil do
        Citizen.Wait(0)
    end
    
    local buttons = {}
    local hasCancel = false
    
    for _, option in ipairs(dialogOptions) do
        if option.id == "cancel" then
            hasCancel = true
        end
        
        table.insert(buttons, {
            value = option.id,
            label = option.text
        })
    end
    
    if not hasCancel then
        table.insert(buttons, {
            value = "cancel",
            label = "Jednak nie chcę z Tobą rozmawiać."
        })
    end
    
    local dialogId = "legacy-dialog-async-" .. GetGameTimer()
    local showProgress = false
    local pages = {
        {
            name = "main_question",
            question = {
                userName = npcName,
                text = npcQuestion
            },
            buttons = buttons
        }
    }
    
    sendNPCDialogAsync(dialogId, showProgress, pages, function(result)
        if result.cancelled then
            cb("cancel")
        else
            cb(result.answers.main_question or "cancel")
        end
    end)
end

_G.sendNPCDialogSync = sendNPCDialogSync
_G.sendNPCDialogAsync = sendNPCDialogAsync
_G.sendDialogNpcSync = sendDialogNpcSync
_G.sendDialogNpcAsync = sendDialogNpcAsync

exports('sendNPCDialogSync', sendNPCDialogSync)
exports('sendNPCDialogAsync', sendNPCDialogAsync)
exports('sendDialogNpcSync', sendDialogNpcSync)
exports('sendDialogNpcAsync', sendDialogNpcAsync)

RegisterNUICallback('npc-dialogs:close', function(data, cb)
    if callback then 
        callback({ cancelled = true })
    end
    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "npc-dialogs",
        visible = false
    })
    cb('ok')
end)

RegisterNUICallback('npc-dialogs:cancel', function(data, cb)
    if callback then 
        callback({ cancelled = true })
    end
    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "npc-dialogs",
        visible = false
    })
    cb('ok')
end)

RegisterNUICallback('npc-dialogs:submit', function(data, cb)
    if callback then
        data = json.decode(data)
        callback({
            id = data.id,
            answers = data.answers,
            cancelled = false
        })
    end

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "npc-dialogs",
        visible = false
    })
    
    cb('ok')
end)