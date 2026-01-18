local headbagObject = 0

local function getRidOfHeadbag()
    if DoesEntityExist(headbagObject) then
        DeleteEntity(headbagObject)
        SetEntityAsNoLongerNeeded(headbagObject)
        headbagObject = 0
    end
end

exports("showHeadbag", function()
    getRidOfHeadbag()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end
    
    local model = `prop_money_bag_01`
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    
    headbagObject = CreateObject(model, 0, 0, 0, true, true, true)
    if DoesEntityExist(headbagObject) then
        local boneIndex = GetPedBoneIndex(ped, 12844)
        AttachEntityToEntity(headbagObject, ped, boneIndex, 0.2, 0.04, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
        SetEntityCompletelyDisableCollision(headbagObject, false, true)
        SetModelAsNoLongerNeeded(model)
    end
    
    SendNUIMessage({
        type = "worekShow"
    })
end)

exports("hideHeadbag", function()
    getRidOfHeadbag()
    SendNUIMessage({
        type = "worekHide"
    })
end)