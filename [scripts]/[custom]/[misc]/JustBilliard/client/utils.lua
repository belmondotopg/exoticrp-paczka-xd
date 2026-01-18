function LocalToWorld(tablePos, tableHeading, localX, localY)
    localX = localX / TABLE_SCALE
    localY = localY / TABLE_SCALE

    local rad = math.rad(tableHeading + TABLE_ANGLE_OFFSET)
    local cosHeading = math.cos(rad)
    local sinHeading = math.sin(rad)
    
    local worldX = tablePos.x + (localX * cosHeading - localY * sinHeading)
    local worldY = tablePos.y + (localX * sinHeading + localY * cosHeading)
    
    return vector3(worldX, worldY, tablePos.z)
end

function WorldToLocal(tablePos, tableHeading, worldX, worldY)
    local rad = math.rad(tableHeading + TABLE_ANGLE_OFFSET)
    local cosHeading = math.cos(rad)
    local sinHeading = math.sin(rad)
    
    local deltaX = worldX - tablePos.x
    local deltaY = worldY - tablePos.y
    
    local localX = deltaX * cosHeading + deltaY * sinHeading
    local localY = -deltaX * sinHeading + deltaY * cosHeading
    
    return localX * TABLE_SCALE, localY * TABLE_SCALE
end

function PlayAnimation(ped, anim)
	if not DoesAnimDictExist(anim.dict) then
		return false
	end

	RequestAnimDict(anim.dict)

	while not HasAnimDictLoaded(anim.dict) do
		Wait(0)
	end

	TaskPlayAnim(ped, anim.dict, anim.name, anim.blendInSpeed, anim.blendOutSpeed, anim.duration, anim.flag, anim.playbackRate, false, false, false, '', false)

	RemoveAnimDict(anim.dict)

    

	return true
end

function ShowDefaultNotification(msg)
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {_('Pool Game'), msg}
    })
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(true, false)
    PlaySoundFrontend(-1, "CONTINUE", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
end