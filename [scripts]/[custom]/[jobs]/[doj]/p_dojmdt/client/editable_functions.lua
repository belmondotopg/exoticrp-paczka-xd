Editable = {
    --@param text: string
    --@param type: inform | error | success
    showNotify = function(text, type)
        lib.notify({
            title = locale('notification'),
            description = text,
            type = type or 'inform'
        })
    end,
}