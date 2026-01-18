Framework = {}

--------------------
-- Init framework --
--------------------
if Config.Framework == FRAMEWORK_ESX then
    ESX = exports[FRAMEWORK_ESX]:getSharedObject()
elseif Config.Framework == FRAMEWORK_QB then
    QBCore = exports[FRAMEWORK_QB]:GetCoreObject()
end

-------------------
-- Notifications --
-------------------
function Framework.showSuccessNotification(msg)
    if Config.Framework == FRAMEWORK_ESX then
        ESX.ShowNotification(msg, 'success')
    elseif Config.Framework == FRAMEWORK_QB then
        QBCore.Functions.Notify(msg, 'success')
    else
        ShowDefaultNotification(msg)
    end
end
function Framework.showWarningNotification(msg)
    if Config.Framework == FRAMEWORK_ESX then
        ESX.ShowNotification(msg, 'info')
    elseif Config.Framework == FRAMEWORK_QB then
        QBCore.Functions.Notify(msg, 'warning')
    else
        ShowDefaultNotification(msg)
    end
end
function Framework.showErrorNotification(msg)
    if Config.Framework == FRAMEWORK_ESX then
        ESX.ShowNotification(msg, 'error')
    elseif Config.Framework == FRAMEWORK_QB then
        QBCore.Functions.Notify(msg, 'error')
    else
        ShowDefaultNotification(msg)
    end
end
RegisterNetEvent(EVENTS['showSuccessNotification'], function(id, ...)
    Framework.showSuccessNotification(_(id, ...))
end)
RegisterNetEvent(EVENTS['showWarningNotification'], function(id, ...)
    Framework.showWarningNotification(_(id, ...))
end)
RegisterNetEvent(EVENTS['showErrorNotification'], function(id, ...)
    Framework.showErrorNotification(_(id, ...))
end)