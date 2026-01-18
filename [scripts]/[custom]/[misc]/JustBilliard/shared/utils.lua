function debugPrint(...)
    if not DEBUG_ENABLED then
        return false
    end

    return print(...)
end