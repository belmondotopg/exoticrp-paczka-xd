local generalJobType

local BossOpen = false
local TabletEntity = nil
local tabletModel = "prop_cs_tablet"
local tabletDict = "amb@world_human_seat_wall_tablet@female@base"
local tabletAnim = "base"

CreateThread(function()
    SendNUIMessage({
        action = 'setImages',
        data = 'nui://esx_society/web/images'
    })
end)

local function attachObject()
	if TabletEntity == nil then
		RequestModel(tabletModel)
		while not HasModelLoaded(tabletModel) do
			Wait(1)
		end
		TabletEntity = CreateObject(GetHashKey(tabletModel), 1.0, 1.0, 1.0, 1, 1, 0)
		AttachEntityToEntity(TabletEntity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.12, 0.10, -0.13, 25.0, 170.0, 160.0, true, true, false, true, 1, true)
	end
end

local function startAnim()
    local playerPed = PlayerPedId()

    RequestAnimDict(tabletDict)
    while not HasAnimDictLoaded(tabletDict) do
        Wait(0)
    end

    attachObject()

    TaskPlayAnim(playerPed, tabletDict, tabletAnim, 3.0, -3.0, -1, 50, 0, false, false, false)

    while BossOpen do
        Wait(1)
        if not IsEntityPlayingAnim(playerPed, tabletDict, tabletAnim, 3) then
            TaskPlayAnim(playerPed, tabletDict, tabletAnim, 8.0, -8.0, -1, 50, 0, false, false, false)
        end
    end

    ClearPedTasks(PlayerPedId())

    if TabletEntity then
        DeleteEntity(TabletEntity)
        TabletEntity = nil
    end
end

RegisterNetEvent('esx_society:fullyOpenBoss', function(data, isEMS, btype, permid, fullAccess, jt)
    CreateThread(startAnim)
    BossOpen = true
    generalJobType = btype

    SendNUIMessage({
        action = 'setData',
        data = {
            userSetts = {
                ManageFraction = btype == 'fraction' and true or false,
                ManagePermID = permid,
                ManageLegal = btype == 'legal' and true or false,
                ManageEMS = isEMS,
                ManageGrade = Config.AuthorizedGrade[data.playerData.job],
            },

            userJobData = data.userJobData,
            psData = data.playersData,
            pData = data.playerData,
        }
    })

    SendNUIMessage({
        action = 'setJobLicenses',
        data = Config.JobLicenses[data.playerData.job]
    })

    SendNUIMessage({
        action = 'setHistory',
        data = data.historyData,
    })

    SendNUIMessage({
        action = 'setTuneHistory',
        data = data.tunehistoryData,
    })

    SendNUIMessage({
        action = 'isRadial',
        data = not fullAccess,
    })

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'setVisible',
        data = true,
    })
end)

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    BossOpen = false
    SendNUIMessage({
        action = 'setVisible',
        data = false,
    })
    cb('ok')
end)

RegisterNUICallback('GetPromition', function(data, cb)
    ESX.TriggerServerCallback('esx_society:getPromotion', function(callbackdata)
        SendNUIMessage({
            action = 'openPromotion',
            data = callbackdata
        })
    end, {identifier = data.identifier, jobType = generalJobType})
    cb('ok')
end)

RegisterNetEvent('esx_society:openZatrudnienie', function()
    ESX.TriggerServerCallback('esx_society:getPlayerInfo', function(info)
        SendNUIMessage({
            action = 'setPlayerAround',
            data = info or {}
        })
    end, generalJobType)
end)

RegisterNUICallback('openZatrudnienie', function(data, cb)
    TriggerEvent('esx_society:openZatrudnienie')
    cb('ok')
end)

RegisterNUICallback('hirePlayer', function(data, cb)
    TriggerServerEvent('esx_society:hirePlayer', data.targetIdentifier, generalJobType)
    cb('ok')
end)

RegisterNetEvent('esx_society:setPlayersData', function(data)
    SendNUIMessage({
        action = 'setPlayersData',
        data = data
    })
end)

RegisterNetEvent('esx_society:setJobData', function(data)
    SendNUIMessage({
        action = 'setJobData',
        data = data
    })
end)

RegisterNetEvent('esx_society:setPlayerData', function(data)
    SendNUIMessage({
        action = 'setPlayerData',
        data = data
    })
end)

RegisterNUICallback('targetChangeGrade', function(data, cb)
    TriggerServerEvent('esx_society:targetChangeGrade', data.identifier, data.grade, generalJobType)
    cb('ok')
end)

RegisterNUICallback('targetChangeBadge', function(data, cb)
    TriggerServerEvent('esx_society:targetChangeBadge', data.identifier, data.badge, generalJobType)
    cb('ok')
end)

RegisterNUICallback('fireTargetPlayer', function(data, cb)
    TriggerServerEvent('esx_society:fireTargetPlayer', data.identifier, generalJobType)
    cb('ok')
end)

RegisterNUICallback('hoursReset', function(data, cb)
    TriggerServerEvent('esx_society:hoursReset')
    cb('ok')
end)

RegisterNUICallback('tuneCountReset', function(data, cb)
    TriggerServerEvent('esx_society:tuneCountReset')
    cb('ok')
end)

RegisterNUICallback('coursesReset', function(data, cb)
    TriggerServerEvent('esx_society:coursesReset')
    cb('ok')
end)

RegisterNUICallback('targetResetCourses', function(data, cb)
    TriggerServerEvent('esx_society:targetResetCourses', data.identifier, generalJobType)
    cb('ok')
end)

RegisterNUICallback('targetResetHours', function(data, cb)
    TriggerServerEvent('esx_society:targetResetHours', data.identifier, generalJobType)
    cb('ok')
end)

RegisterNUICallback('clearTuneHistory', function(data, cb)
    TriggerServerEvent('esx_society:tuneReset')
    cb('ok')
end)

RegisterNUICallback('withdrawMoney', function(data, cb)
    TriggerServerEvent('esx_society:withdrawMoney', data, generalJobType)
    cb('ok')
end)

RegisterNUICallback('depositMoney', function(data, cb)
    TriggerServerEvent('esx_society:depositMoney', data, generalJobType)
    cb('ok')
end)

RegisterNUICallback('discordWebhook', function(data, cb)
    TriggerServerEvent('esx_society:discordWebhook', data, generalJobType)
    cb('ok')
end)

RegisterNUICallback('addLicense', function(data, cb)
    TriggerServerEvent('esx_society:addLicense', data.identifier, data.license, data.hasLicense)
    cb('ok')
end)

RegisterNUICallback('transferMoney', function(data, cb)
    TriggerServerEvent('esx_society:transferMoney', data.identifier, data.money)
    cb('ok')
end)

RegisterNetEvent('esx_society:setHistory', function(history)
    SendNUIMessage({
        action = 'setHistory',
        data = history,
    })
end)

RegisterNetEvent('esx_society:setTuneHistory', function(history)
    SendNUIMessage({
        action = 'setTuneHistory',
        data = history,
    })
end)

RegisterNUICallback('esx_society:acceptChallenge', function(data, cb)
    TriggerServerEvent('esx_society:acceptChallenge', data.value)

    cb(true)
end)

RegisterNUICallback('esx_society:dropChallenge', function(data, cb)
    TriggerServerEvent('esx_society:dropChallenge', data.value)

    cb(true)
end)

RegisterNUICallback('esx_society:getReward', function(data, cb)
    TriggerServerEvent('esx_society:getReward', data.value)
    cb(true)
end)

RegisterNetEvent('esx_society:updateUpgradesLegal', function(data)
    SendNUIMessage({
        action = 'setUpgradeLegalData',
        data = data
    })
end)

RegisterNUICallback('kariee/buyUpgradeLegal', function(data, cb)
    TriggerServerEvent('esx_society:buyUpgradeLegal', data)
    cb(true)
end)