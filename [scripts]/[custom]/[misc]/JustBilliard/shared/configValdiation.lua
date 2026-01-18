if Config.EnableInteractionTargetScript and GetResourceState(Config.TargetScriptName) ~= 'started' then
    Config.EnableInteractionTargetScript = false
    print(('^3[Warning]: "%s" not found. You have to start it before "%s"^0'):format(Config.TargetScriptName, GetCurrentResourceName()))
end