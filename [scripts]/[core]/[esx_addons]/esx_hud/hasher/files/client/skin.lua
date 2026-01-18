local SendNUIMessage = SendNUIMessage

LocalPlayer.state:set('InSkin', false, true)

local function tofloat(num)
    return num + 0.0
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew)
	ESX.PlayerData = xPlayer

    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(0)
    end
    if not isNew then
        InitAppearance()
    end
end)

local HEAD_OVERLAYS = {
    "blemishes",
    "beard",
    "eyebrows",
    "ageing",
    "makeUp",
    "blush",
    "complexion",
    "sunDamage",
    "lipstick",
    "moleAndFreckles",
    "chestHair",
    "bodyBlemishes",
}

local FACE_FEATURES = {
    "noseWidth",
    "nosePeakHigh",
    "nosePeakSize",
    "noseBoneHigh",
    "nosePeakLowering",
    "noseBoneTwist",
    "eyeBrownHigh",
    "eyeBrownForward",
    "cheeksBoneHigh",
    "cheeksBoneWidth",
    "cheeksWidth",
    "eyesOpening",
    "lipsThickness",
    "jawBoneWidth",
    "jawBoneBackSize",
    "chinBoneLowering",
    "chinBoneLenght",
    "chinBoneSize",
    "chinHole",
    "neckThickness",
}

local DATA_CLOTHES = {
    head = {
        animations = {
            on = {
                dict = "mp_masks@standard_car@ds@",
                anim = "put_on_mask",
                move = 51,
                duration = 600
            },
            off = {
                dict = "missheist_agency2ahelmet",
                anim = "take_off_helmet_stand",
                move = 51,
                duration = 1200
            }
        },
        components = {
            male = {
                {1, 0}
            },
            female = {
                {1, 0}
            }
        },
        props = {
            male = {
                {0, -1}
            },
            female = {}
        }
    },
    body = {
        animations = {
            on = {
                dict = "clothingtie",
                anim = "try_tie_negative_a",
                move = 51,
                duration = 1200
            },
            off = {
                dict = "clothingtie",
                anim = "try_tie_negative_a",
                move = 51,
                duration = 1200
            }
        },
        components = {
            male = {
                {11, 252},
                {3, 15},
                {8, 15},
                {10, 0},
                {5, 0}
            },
            female = {
                {11, 15},
                {8, 14},
                {3, 15},
                {10, 0},
                {5, 0}
            }
        },
        props = {
            male = {},
            female = {}
        }
    },
    bottom = {
        animations = {
            on = {
                dict = "re@construction",
                anim = "out_of_breath",
                move = 51,
                duration = 1300
            },
            off = {
                dict = "re@construction",
                anim = "out_of_breath",
                move = 51,
                duration = 1300
            }
        },
        components = {
            male = {
                {4, 61},
                {6, 34}
            },
            female = {
                {4, 15},
                {6, 35}
            }
        },
        props = {
            male = {},
            female = {}
        }
    }
}

local PED_COMPONENTS_IDS = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
local PED_PROPS_IDS = {0, 1, 2, 6, 7}

local APPEARANCE = {}
local UNAPPEARANCE = {}

local hashesComputed = false
local PED_TATTOOS = {}
local pedModelsByHash = {}

local libCache = lib.onCache
local cachePed = cache.ped

local WEAR_CLOTHES = {
    head = true,
    body = true,
    bottom = true,
    all = true,
}

libCache('ped', function(ped)
    cachePed = ped
end)

local function computePedModelsByHash()
    for i = 1, #Config.Peds.pedConfig do
        local peds = Config.Peds.pedConfig[i].peds
        for j = 1, #peds do
            pedModelsByHash[joaat(peds[j])] = peds[j]
        end
    end
end

local function isPedFreemodeModel(ped)
    local model = GetEntityModel(ped)
    return model == `mp_m_freemode_01` or model == `mp_f_freemode_01`
end

local function getPedModel(ped)
    if not hashesComputed then
        computePedModelsByHash()
        hashesComputed = true
    end
    return pedModelsByHash[GetEntityModel(ped)]
end


local function getPedDecorationType()
    local pedModel = GetEntityModel(cachePed)
    local decorationType

    if pedModel == `mp_m_freemode_01` then
        decorationType = "male"
    elseif pedModel == `mp_f_freemode_01` then
        decorationType = "female"
    else
        decorationType = IsPedMale(cachePed) and "male" or "female"
    end

    return decorationType
end

local function setTattoos(ped, tattoos, style)
    local isMale = getPedDecorationType() == "male"
    ClearPedDecorations(ped)
    for k in pairs(tattoos) do
        for i = 1, #tattoos[k] do
            local tattoo = tattoos[k][i]
            local tattooGender = isMale and tattoo.hashMale or tattoo.hashFemale
            for _ = 1, (tattoo.opacity or 0.1) * 10 do
                AddPedDecorationFromHashes(ped, joaat(tattoo.collection), joaat(tattooGender))
            end
        end
    end
    TriggerEvent("rcore_tattoos:applyOwnedTattoos")
end

local function setPedTattoos(ped, tattoos)
    PED_TATTOOS = tattoos
    setTattoos(ped, tattoos)
end

local function getPedTattoos()
    return PED_TATTOOS
end

local function addPedTattoo(ped, tattoos)
    setTattoos(ped, tattoos)
end

local function removePedTattoo(ped, tattoos)
    setTattoos(ped, tattoos)
end

local function setPreviewTattoo(ped, tattoos, tattoo)
    local isMale = getPedDecorationType() == "male"
    local tattooGender = isMale and tattoo.hashMale or tattoo.hashFemale

    ClearPedDecorations(ped)
    for _ = 1, (tattoo.opacity or 0.1) * 10 do
        AddPedDecorationFromHashes(ped, joaat(tattoo.collection), tattooGender)
    end
    for k in pairs(tattoos) do
        for i = 1, #tattoos[k] do
            local aTattoo = tattoos[k][i]
            if aTattoo.name ~= tattoo.name then
                local aTattooGender = isMale and aTattoo.hashMale or aTattoo.hashFemale
                for _ = 1, (aTattoo.opacity or 0.1) * 10 do
                    AddPedDecorationFromHashes(ped, joaat(aTattoo.collection), joaat(aTattooGender))
                end
            end
        end
    end
end

local function getPedHeadBlend(ped)
    local shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix = Citizen.InvokeNative(0x2746BD9D88C5C5D0, ped, Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0))

    shapeMix = tonumber(string.sub(shapeMix, 0, 4))
    if shapeMix > 1 then shapeMix = 1 end

    skinMix = tonumber(string.sub(skinMix, 0, 4))
    if skinMix > 1 then skinMix = 1 end

    if not thirdMix then
        thirdMix = 0
    end
    thirdMix = tonumber(string.sub(thirdMix, 0, 4))
    if thirdMix > 1 then thirdMix = 1 end


    return {
        shapeFirst = shapeFirst,
        shapeSecond = shapeSecond,
        shapeThird = shapeThird,
        skinFirst = skinFirst,
        skinSecond = skinSecond,
        skinThird = skinThird,
        shapeMix = shapeMix,
        skinMix = skinMix,
        thirdMix = thirdMix
    }
end

local function getPedDefaultHeadBlend(ped)
    local shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix = Citizen.InvokeNative(0x2746BD9D88C5C5D0, ped, Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0))

    return {
        shapeFirst = 0,
        shapeSecond = 0,
        shapeThird = 0,
        skinFirst = skinFirst,
        skinSecond = skinSecond,
        skinThird = skinThird,
        shapeMix = shapeMix,
        skinMix = skinMix,
        thirdMix = thirdMix
    }
end

local function round(number, decimalPlaces)
    return tonumber(string.format("%." .. (decimalPlaces or 0) .. "f", number))
end

local function getPedFaceFeatures(ped)
    local size = #FACE_FEATURES
    local faceFeatures2 = table.create(0, size)

    for i = 1, size do
        local feature = FACE_FEATURES[i]
        faceFeatures2[feature] = round(GetPedFaceFeature(ped, i-1), 1)
    end

    return faceFeatures2
end

local function getPedDefaultFaceFeatures()
    local size = #FACE_FEATURES
    local faceFeatures = table.create(0, size)

    for i = 1, size do
        local feature = FACE_FEATURES[i]
        faceFeatures[feature] = 0
    end

    return faceFeatures
end


local function getPedHeadOverlays(ped)
    local size = #HEAD_OVERLAYS
    local headOverlays2 = table.create(0, size)

    for i = 1, size do
        local overlay = HEAD_OVERLAYS[i]
        local _, value, _, firstColor, secondColor, opacity = GetPedHeadOverlayData(ped, i-1)

        if value ~= 255 then
            opacity = round(opacity, 1)
        else
            value = 0
            opacity = 0
        end

        headOverlays2[overlay] = {style = value, opacity = opacity, color = firstColor, secondColor = secondColor}
    end

    return headOverlays2
end

local function getPedComponents(ped)
    local size = #PED_COMPONENTS_IDS
    local components = table.create(size, 0)

    for i = 1, size do
        local componentId = PED_COMPONENTS_IDS[i]
        components[i] = {
            component_id = componentId,
            drawable = GetPedDrawableVariation(ped, componentId),
            texture = GetPedTextureVariation(ped, componentId),
        }
    end

    return components
end

local function getPedProps(ped)
    local size = #PED_PROPS_IDS
    local props = table.create(size, 0)

    for i = 1, size do
        local propId = PED_PROPS_IDS[i]
        props[i] = {
            prop_id = propId,
            drawable = GetPedPropIndex(ped, propId),
            texture = GetPedPropTextureIndex(ped, propId),
        }
    end
    return props
end

local function getPedHair(ped)
    return {
        style = GetPedDrawableVariation(ped, 2),
        color = GetPedHairColor(ped),
        highlight = GetPedHairHighlightColor(ped),
        texture = GetPedTextureVariation(ped, 2)
    }
end


local function getPedAppearance(ped)
    local eyeColor = GetPedEyeColor(ped)

    return {
        model = getPedModel(ped) or "mp_m_freemode_01",
        headBlend = getPedHeadBlend(ped),
        faceFeatures = getPedFaceFeatures(ped),
        headOverlays = getPedHeadOverlays(ped),
        components = getPedComponents(ped),
        props = getPedProps(ped),
        hair = getPedHair(ped),
        tattoos = getPedTattoos(),
        eyeColor = eyeColor < 63 and eyeColor or 0
    }
end

function GetGenderById(genderId)
    if genderId == 1 then
        return "Female"
    end
    return "Male"
end

local playerCam
local SkinMenu = {}
local function getMenu(skintype)
    if skintype == nil or not skintype then
        skintype = 'skin'
    end

    APPEARANCE = getPedAppearance(cachePed)
    UNAPPEARANCE = getPedAppearance(cachePed)

    local headBlend = APPEARANCE['headBlend']
    local faceFeatures = APPEARANCE['faceFeatures']
    local headOverlays = APPEARANCE['headOverlays']
    local components = APPEARANCE['components']
    local props = APPEARANCE['props']
    local hair = APPEARANCE['hair']
    local eyeColor = APPEARANCE['eyeColor']

    if skintype == 'skin' then
        SkinMenu = {
            skinType = 'skin',
            options = {
                {
                    option = {
                        optionName = 'Twarz',
                        optionIcon = 'fa-regular fa-face-smile'
                    },
                    sideOptions = {
                        {
                            sideOptionName = 'Pochodzenie',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Ped',
                                    SOI_type = 'select',
                                    SOI_opt = {},
                                },
                                {
                                    SOI_name = 'Twarz',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Ojciec',
                                            SOI_opt_sourcename = 'shapeFirst',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['shapeFirst'],
                                            SOI_opt_maxNumber = 45
                                        },
                                        {
                                            SOI_opt_name = 'Matka',
                                            SOI_opt_sourcename = 'shapeSecond',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['shapeSecond'],
                                            SOI_opt_maxNumber = 45
                                        },
                                        {
                                            SOI_opt_name = 'Mix',
                                            SOI_opt_sourcename = 'shapeMix',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['shapeMix'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Skóra',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Ojciec',
                                            SOI_opt_sourcename = 'skinFirst',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['skinFirst'],
                                            SOI_opt_maxNumber = 45
                                        },
                                        {
                                            SOI_opt_name = 'Matka',
                                            SOI_opt_sourcename = 'skinSecond',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['shapeSecond'],
                                            SOI_opt_maxNumber = 45
                                        },
                                        {
                                            SOI_opt_name = 'Mix',
                                            SOI_opt_sourcename = 'skinMix',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['skinMix'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Rasa',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Kształt',
                                            SOI_opt_sourcename = 'shapeThird',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['shapeThird'],
                                            SOI_opt_maxNumber = 45
                                        },
                                        {
                                            SOI_opt_name = 'Skóra',
                                            SOI_opt_sourcename = 'skinThird',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['skinThird'],
                                            SOI_opt_maxNumber = 45
                                        },
                                        {
                                            SOI_opt_name = 'Mix',
                                            SOI_opt_sourcename = 'thirdMix',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['thirdMix'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                    }
                                },
                            }
                        },
                        {
                            sideOptionName = 'Wygląd',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Nos',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Szerokość',
                                            SOI_opt_sourcename = 'noseWidth_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['noseWidth'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Wysokość',
                                            SOI_opt_sourcename = 'nosePeakHigh_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['nosePeakHigh'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Rozmiar',
                                            SOI_opt_sourcename = 'nosePeakSize_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['nosePeakSize'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Wysokość kości',
                                            SOI_opt_sourcename = 'noseBoneHigh_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['noseBoneHigh'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Wysokość szczytu',
                                            SOI_opt_sourcename = 'nosePeakLowering_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['nosePeakLowering'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Skręt kości',
                                            SOI_opt_sourcename = 'noseBoneTwist_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['noseBoneTwist'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Brwi',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Wysokość',
                                            SOI_opt_sourcename = 'eyeBrownHigh_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['eyeBrownHigh'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Głębokość',
                                            SOI_opt_sourcename = 'eyeBrownForward_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['eyeBrownForward'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Policzki',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Wysokość kości',
                                            SOI_opt_sourcename = 'cheeksBoneHigh_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['cheeksBoneHigh'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Szerokość kości',
                                            SOI_opt_sourcename = 'cheeksBoneWidth_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['cheeksBoneWidth'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Szerokość policzków',
                                            SOI_opt_sourcename = 'cheeksWidth_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['cheeksWidth'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Szczęka',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Szerokość',
                                            SOI_opt_sourcename = 'jawBoneWidth_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['jawBoneWidth'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Rozmiar',
                                            SOI_opt_sourcename = 'jawBoneBackSize_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['jawBoneBackSize'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Podbródek',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Wysokość',
                                            SOI_opt_sourcename = 'chinBoneLowering_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['chinBoneLowering'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Długość',
                                            SOI_opt_sourcename = 'chinBoneLenght_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['chinBoneLenght'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Rozmiar',
                                            SOI_opt_sourcename = 'chinBoneSize_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['chinBoneSize'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Wklęśnięcie',
                                            SOI_opt_sourcename = 'chinHole_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['chinHole'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Skazy',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'blemishes:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blemishes']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'blemishes:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blemishes']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(0) - 1
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Zmarszczki',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'ageing:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['ageing']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'ageing:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['ageing']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(3) - 1
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Karnacja',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'complexion:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['complexion']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'complexion:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['complexion']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(6) - 1
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Poparzenia',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'sunDamage:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['sunDamage']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'sunDamage:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['sunDamage']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(7) - 1
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Piegi',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'moleAndFreckles:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['moleAndFreckles']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'moleAndFreckles:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['moleAndFreckles']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(9) - 1
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Dodatki',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Otwartość oczu',
                                            SOI_opt_sourcename = 'eyesOpening_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['eyesOpening'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Grubość ust',
                                            SOI_opt_sourcename = 'lipsThickness_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['lipsThickness'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Grubość szyji',
                                            SOI_opt_sourcename = 'neckThickness_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['neckThickness'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                    }
                                },
                            }
                        }
                    }
                },
                {
                    option = {
                        optionName = 'Wygląd',
                        optionIcon = 'fa-solid fa-wand-magic-sparkles'
                    },
                    sideOptions = {
                        {
                            sideOptionName = 'Głowa',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Włosy',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'style',
                                            SOI_opt_trigger = 'change_hair',
                                            SOI_opt_currentNumber = hair['style'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 2) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'texture',
                                            SOI_opt_trigger = 'change_hair',
                                            SOI_opt_currentNumber = hair['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 2) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'color',
                                            SOI_opt_trigger = 'change_hair',
                                            SOI_opt_currentNumber = hair['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'highlight',
                                            SOI_opt_trigger = 'change_hair',
                                            SOI_opt_currentNumber = hair['highlight'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        -- {
                                        --     SOI_opt_name = 'Pokrycie włosów',
                                        --     SOI_opt_sourcename = 'fade',
                                        --     SOI_opt_trigger = 'change_hair',
                                        --     SOI_opt_currentNumber = 0,
                                        --     SOI_opt_maxNumber = #Config.ZONE_HAIR
                                        -- },
                                        -- {
                                        --     SOI_opt_name = 'Gęstość pokrycia',
                                        --     SOI_opt_sourcename = 'fade_opacity',
                                        --     SOI_opt_trigger = 'change_hair',
                                        --     SOI_opt_currentNumber = 0,
                                        --     SOI_opt_maxNumber = 5
                                        -- },
                                    }
                                },
                                {
                                    SOI_name = 'Brwi',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'eyebrows:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['eyebrows']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'eyebrows:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['eyebrows']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(2) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'eyebrows:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['eyebrows']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'eyebrows:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['eyebrows']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Kolor oczu',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = '',
                                            SOI_opt_trigger = 'change_eyeColor',
                                            SOI_opt_currentNumber = eyeColor,
                                            SOI_opt_maxNumber = 30
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Broda',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'beard:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['beard']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'beard:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['beard']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(1) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'beard:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['beard']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'beard:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['beard']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                            }
                        },
                        {
                            sideOptionName = 'Ciało',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Włosy na ciele',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'chestHair:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['chestHair']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'chestHair:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['chestHair']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(10) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'chestHair:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['chestHair']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'chestHair:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['chestHair']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Skazy na ciele',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'bodyBlemishes:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['bodyBlemishes']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'bodyBlemishes:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['bodyBlemishes']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(11) - 1
                                        },
                                    }
                                },
                            }
                        },
                        {
                            sideOptionName = 'Makijaż',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Ogólny makijaż',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'makeUp:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['makeUp']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'makeUp:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['makeUp']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(4) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'makeUp:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['makeUp']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'makeUp:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['makeUp']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Rumieńce',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'blush:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blush']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'blush:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blush']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(5) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'blush:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blush']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'blush:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blush']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Szminka',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'lipstick:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['lipstick']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'lipstick:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['lipstick']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(8) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'lipstick:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['lipstick']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'lipstick:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['lipstick']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                            }
                        },
                    }
                },
                {
                    option = {
                        optionName = 'Ubrania',
                        optionIcon = 'fa-solid fa-clothes-hanger'
                    },
                    sideOptions = {
                        {
                            sideOptionName = 'Ciuchy',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Rękawiczki',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_3:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[3+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 3)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_3:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[3+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 3)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'T-Shirt',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_8:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[8+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 8)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_8:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[8+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 8)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Kamizelka',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_9:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[9+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 9)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_9:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[9+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 9)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Bluza',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_11:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[11+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 11)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_11:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[11+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 11)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Spodnie',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_4:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[4+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 4)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_4:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[4+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 4)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Buty',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_6:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[6+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 6)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_6:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[6+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 6)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Torba',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_5:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[5+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 5)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_5:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[5+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 5)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Czapka',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'prop_id_0:drawable',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropDrawableVariations(cachePed, 0) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'prop_id_0:texture',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, 0) - 2
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Okulary',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'prop_id_1:drawable',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[2]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropDrawableVariations(cachePed, 1) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'prop_id_1:texture',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[2]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, 1) - 2
                                        },
                                    }
                                },
                            }
                        },
                        {
                            sideOptionName = 'Dodatki',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Maska',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_1:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[1+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 1)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_1:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[1+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 1)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Łańcuch',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_7:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[7+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 7)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_7:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[7+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 7)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Dodatki',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_10:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[10+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 10)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_10:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[10+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 10)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Na uszy',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'prop_id_2:drawable',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[3]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropDrawableVariations(cachePed, 2) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'prop_id_2:texture',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[3]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, 2) - 2
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Zegarek',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'prop_id_6:drawable',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[4]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropDrawableVariations(cachePed, 6) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'prop_id_6:texture',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[4]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, 6) - 2
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Bransoletka',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'prop_id_7:drawable',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[5]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropDrawableVariations(cachePed, 7) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'prop_id_7:texture',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[5]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, 7) - 2
                                        },
                                    }
                                },
                            }
                        },
                    }
                },
            }
        }

        local groups = {
            zarzad = true,
            leaddeveloper = true,
            headadmin = true,
            menadzer = true,
            admin = true,
        }
        
        local peds = {}
        if groups[ESX.PlayerData.group] then
            for k, v in pairs(Config.Peds['pedConfig'][1]['peds']) do
                local has = v == APPEARANCE.model and true or false

                table.insert(peds, {
                    SOI_opt_name = v,
                    SOI_tattoo_has = has
                })
            end
        else
            local isMan = APPEARANCE.model == 'mp_m_freemode_01' and true or false

            peds = {
                {
                    SOI_opt_name = 'mp_m_freemode_01',
                    SOI_tattoo_has = isMan
                },
                {
                    SOI_opt_name = 'mp_f_freemode_01',
                    SOI_tattoo_has = not isMan
                }
            }
        end

        SkinMenu['options'][1]['sideOptions'][1]['sideOptionItems'][1]['SOI_opt'] = peds

    elseif skintype == 'clotheshop' then
        SkinMenu = {
            skinType = 'clotheshop',
            options = {
                {
                    option = {
                        optionName = 'Ubrania',
                        optionIcon = 'fa-solid fa-clothes-hanger'
                    },
                    sideOptions = {
                        {
                            sideOptionName = 'Ciuchy',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Rękawiczki',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_3:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[3+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 3)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_3:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[3+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 3)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'T-Shirt',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_8:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[8+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 8)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_8:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[8+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 8)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Kamizelka',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_9:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[9+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 9)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_9:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[9+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 9)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Bluza',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_11:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[11+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 11)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_11:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[11+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 11)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Spodnie',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_4:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[4+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 4)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_4:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[4+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 4)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Buty',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_6:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[6+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 6)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_6:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[6+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 6)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Torba',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_5:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[5+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 5)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_5:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[5+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 5)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Czapka',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'prop_id_0:drawable',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropDrawableVariations(cachePed, 0) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'prop_id_0:texture',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, 0) - 2
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Okulary',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'prop_id_1:drawable',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[2]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropDrawableVariations(cachePed, 1) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'prop_id_1:texture',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[2]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, 1) - 2
                                        },
                                    }
                                },
                            }
                        },
                        {
                            sideOptionName = 'Dodatki',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Maska',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_1:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[1+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 1)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_1:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[1+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 1)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Łańcuch',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_7:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[7+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 7)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_7:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[7+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 7)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Dodatki',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_10:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[10+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 10)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_10:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[10+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 10)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Na uszy',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'prop_id_2:drawable',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[3]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropDrawableVariations(cachePed, 2) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'prop_id_2:texture',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[3]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, 2) - 2
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Zegarek',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'prop_id_6:drawable',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[4]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropDrawableVariations(cachePed, 6) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'prop_id_6:texture',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[4]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, 6) - 2
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Bransoletka',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'prop_id_7:drawable',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[5]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropDrawableVariations(cachePed, 7) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'prop_id_7:texture',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[5]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, 7) - 2
                                        },
                                    }
                                },
                            }
                        },
                    }
                }
            }
        }
    elseif skintype == 'barbershop' then
        SkinMenu = {
            skinType = 'skin',
            options = {
                {
                    option = {
                        optionName = 'Wygląd',
                        optionIcon = 'fa-solid fa-wand-magic-sparkles'
                    },
                    sideOptions = {
                        {
                            sideOptionName = 'Głowa',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Włosy',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'style',
                                            SOI_opt_trigger = 'change_hair',
                                            SOI_opt_currentNumber = hair['style'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 2) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'texture',
                                            SOI_opt_trigger = 'change_hair',
                                            SOI_opt_currentNumber = hair['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 2) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'color',
                                            SOI_opt_trigger = 'change_hair',
                                            SOI_opt_currentNumber = hair['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'highlight',
                                            SOI_opt_trigger = 'change_hair',
                                            SOI_opt_currentNumber = hair['highlight'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    --     {
                                    --         SOI_opt_name = 'Pokrycie włosów',
                                    --         SOI_opt_sourcename = 'fade',
                                    --         SOI_opt_trigger = 'change_hair',
                                    --         SOI_opt_currentNumber = 0,
                                    --         SOI_opt_maxNumber = #Config.ZONE_HAIR
                                    --     },
                                    --     {
                                    --         SOI_opt_name = 'Gęstość pokrycia',
                                    --         SOI_opt_sourcename = 'fade_opacity',
                                    --         SOI_opt_trigger = 'change_hair',
                                    --         SOI_opt_currentNumber = 0,
                                    --         SOI_opt_maxNumber = 5
                                    --     },
                                    }
                                },
                                {
                                    SOI_name = 'Brwi',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'eyebrows:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['eyebrows']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'eyebrows:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['eyebrows']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(2) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'eyebrows:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['eyebrows']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'eyebrows:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['eyebrows']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Kolor oczu',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = '',
                                            SOI_opt_trigger = 'change_eyeColor',
                                            SOI_opt_currentNumber = eyeColor,
                                            SOI_opt_maxNumber = 30
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Broda',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'beard:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['beard']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'beard:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['beard']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(1) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'beard:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['beard']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'beard:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['beard']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                            }
                        },
                        {
                            sideOptionName = 'Ciało',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Włosy na ciele',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'chestHair:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['chestHair']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'chestHair:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['chestHair']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(10) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'chestHair:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['chestHair']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'chestHair:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['chestHair']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Skazy na ciele',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'bodyBlemishes:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['bodyBlemishes']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'bodyBlemishes:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['bodyBlemishes']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(11) - 1
                                        },
                                    }
                                },
                            }
                        },
                        {
                            sideOptionName = 'Makijaż',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Ogólny makijaż',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'makeUp:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['makeUp']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'makeUp:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['makeUp']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(4) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'makeUp:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['makeUp']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'makeUp:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['makeUp']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Rumieńce',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'blush:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blush']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'blush:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blush']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(5) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'blush:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blush']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'blush:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blush']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Szminka',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'lipstick:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['lipstick']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'lipstick:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['lipstick']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(8) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'lipstick:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['lipstick']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'lipstick:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['lipstick']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                            }
                        },
                    },
                }
            }
        }
    else
        SkinMenu = {
            skinType = 'skin',
            options = {
                {
                    option = {
                        optionName = 'Twarz',
                        optionIcon = 'fa-regular fa-face-smile'
                    },
                    sideOptions = {
                        {
                            sideOptionName = 'Pochodzenie',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Twarz',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Ojciec',
                                            SOI_opt_sourcename = 'shapeFirst',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['shapeFirst'],
                                            SOI_opt_maxNumber = 45
                                        },
                                        {
                                            SOI_opt_name = 'Matka',
                                            SOI_opt_sourcename = 'shapeSecond',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['shapeSecond'],
                                            SOI_opt_maxNumber = 45
                                        },
                                        {
                                            SOI_opt_name = 'Mix',
                                            SOI_opt_sourcename = 'shapeMix',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['shapeMix'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Skóra',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Ojciec',
                                            SOI_opt_sourcename = 'skinFirst',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['skinFirst'],
                                            SOI_opt_maxNumber = 45
                                        },
                                        {
                                            SOI_opt_name = 'Matka',
                                            SOI_opt_sourcename = 'skinSecond',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['shapeSecond'],
                                            SOI_opt_maxNumber = 45
                                        },
                                        {
                                            SOI_opt_name = 'Mix',
                                            SOI_opt_sourcename = 'skinMix',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['skinMix'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Rasa',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Kształt',
                                            SOI_opt_sourcename = 'shapeThird',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['shapeThird'],
                                            SOI_opt_maxNumber = 45
                                        },
                                        {
                                            SOI_opt_name = 'Skóra',
                                            SOI_opt_sourcename = 'skinThird',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['skinThird'],
                                            SOI_opt_maxNumber = 45
                                        },
                                        {
                                            SOI_opt_name = 'Mix',
                                            SOI_opt_sourcename = 'thirdMix',
                                            SOI_opt_trigger = 'change_headBlend',
                                            SOI_opt_currentNumber = headBlend['thirdMix'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                    }
                                },
                            }
                        },
                        {
                            sideOptionName = 'Wygląd',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Nos',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Szerokość',
                                            SOI_opt_sourcename = 'noseWidth_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['noseWidth'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Wysokość',
                                            SOI_opt_sourcename = 'nosePeakHigh_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['nosePeakHigh'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Rozmiar',
                                            SOI_opt_sourcename = 'nosePeakSize_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['nosePeakSize'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Wysokość kości',
                                            SOI_opt_sourcename = 'noseBoneHigh_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['noseBoneHigh'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Wysokość szczytu',
                                            SOI_opt_sourcename = 'nosePeakLowering_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['nosePeakLowering'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Skręt kości',
                                            SOI_opt_sourcename = 'noseBoneTwist_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['noseBoneTwist'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Brwi',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Wysokość',
                                            SOI_opt_sourcename = 'eyeBrownHigh_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['eyeBrownHigh'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Głębokość',
                                            SOI_opt_sourcename = 'eyeBrownForward_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['eyeBrownForward'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Policzki',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Wysokość kości',
                                            SOI_opt_sourcename = 'cheeksBoneHigh_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['cheeksBoneHigh'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Szerokość kości',
                                            SOI_opt_sourcename = 'cheeksBoneWidth_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['cheeksBoneWidth'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Szerokość policzków',
                                            SOI_opt_sourcename = 'cheeksWidth_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['cheeksWidth'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Szczęka',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Szerokość',
                                            SOI_opt_sourcename = 'jawBoneWidth_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['jawBoneWidth'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Rozmiar',
                                            SOI_opt_sourcename = 'jawBoneBackSize_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['jawBoneBackSize'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Podbródek',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Wysokość',
                                            SOI_opt_sourcename = 'chinBoneLowering_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['chinBoneLowering'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Długość',
                                            SOI_opt_sourcename = 'chinBoneLenght_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['chinBoneLenght'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Rozmiar',
                                            SOI_opt_sourcename = 'chinBoneSize_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['chinBoneSize'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Wklęśnięcie',
                                            SOI_opt_sourcename = 'chinHole_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['chinHole'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Skazy',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'blemishes:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blemishes']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'blemishes:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blemishes']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(0) - 1
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Zmarszczki',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'ageing:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['ageing']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'ageing:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['ageing']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(3) - 1
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Karnacja',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'complexion:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['complexion']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'complexion:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['complexion']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(6) - 1
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Poparzenia',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'sunDamage:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['sunDamage']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'sunDamage:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['sunDamage']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(7) - 1
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Piegi',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'moleAndFreckles:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['moleAndFreckles']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'moleAndFreckles:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['moleAndFreckles']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(9) - 1
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Dodatki',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Otwartość oczu',
                                            SOI_opt_sourcename = 'eyesOpening_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['eyesOpening'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Grubość ust',
                                            SOI_opt_sourcename = 'lipsThickness_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['lipsThickness'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                        {
                                            SOI_opt_name = 'Grubość szyji',
                                            SOI_opt_sourcename = 'neckThickness_new',
                                            SOI_opt_trigger = 'change_faceFeature',
                                            SOI_opt_currentNumber = faceFeatures['neckThickness'] * 20,
                                            SOI_opt_minNumber = 0,
                                            SOI_opt_maxNumber = 20,
                                        },
                                    }
                                },
                            }
                        }
                    }
                },
                {
                    option = {
                        optionName = 'Wygląd',
                        optionIcon = 'fa-solid fa-wand-magic-sparkles'
                    },
                    sideOptions = {
                        {
                            sideOptionName = 'Głowa',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Włosy',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'style',
                                            SOI_opt_trigger = 'change_hair',
                                            SOI_opt_currentNumber = hair['style'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 2) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'texture',
                                            SOI_opt_trigger = 'change_hair',
                                            SOI_opt_currentNumber = hair['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 2) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'color',
                                            SOI_opt_trigger = 'change_hair',
                                            SOI_opt_currentNumber = hair['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'highlight',
                                            SOI_opt_trigger = 'change_hair',
                                            SOI_opt_currentNumber = hair['highlight'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        -- {
                                        --     SOI_opt_name = 'Pokrycie włosów',
                                        --     SOI_opt_sourcename = 'fade',
                                        --     SOI_opt_trigger = 'change_hair',
                                        --     SOI_opt_currentNumber = 0,
                                        --     SOI_opt_maxNumber = #Config.ZONE_HAIR
                                        -- },
                                        -- {
                                        --     SOI_opt_name = 'Gęstość pokrycia',
                                        --     SOI_opt_sourcename = 'fade_opacity',
                                        --     SOI_opt_trigger = 'change_hair',
                                        --     SOI_opt_currentNumber = 0,
                                        --     SOI_opt_maxNumber = 5
                                        -- },
                                    }
                                },
                                {
                                    SOI_name = 'Brwi',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'eyebrows:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['eyebrows']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'eyebrows:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['eyebrows']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(2) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'eyebrows:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['eyebrows']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'eyebrows:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['eyebrows']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Kolor oczu',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = '',
                                            SOI_opt_trigger = 'change_eyeColor',
                                            SOI_opt_currentNumber = eyeColor,
                                            SOI_opt_maxNumber = 30
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Broda',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'beard:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['beard']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'beard:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['beard']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(1) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'beard:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['beard']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'beard:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['beard']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                            }
                        },
                        {
                            sideOptionName = 'Ciało',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Włosy na ciele',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'chestHair:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['chestHair']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'chestHair:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['chestHair']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(10) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'chestHair:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['chestHair']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'chestHair:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['chestHair']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Skazy na ciele',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'bodyBlemishes:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['bodyBlemishes']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'bodyBlemishes:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['bodyBlemishes']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(11) - 1
                                        },
                                    }
                                },
                            }
                        },
                        {
                            sideOptionName = 'Makijaż',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Ogólny makijaż',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'makeUp:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['makeUp']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'makeUp:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['makeUp']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(4) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'makeUp:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['makeUp']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'makeUp:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['makeUp']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Rumieńce',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'blush:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blush']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'blush:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blush']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(5) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'blush:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blush']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'blush:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['blush']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Szminka',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Gęstość',
                                            SOI_opt_sourcename = 'lipstick:opacity',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['lipstick']['opacity'] * 10,
                                            SOI_opt_maxNumber = 10,
                                        },
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'lipstick:style',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['lipstick']['style'],
                                            SOI_opt_maxNumber = GetPedHeadOverlayNum(8) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Kolor',
                                            SOI_opt_sourcename = 'lipstick:color',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['lipstick']['color'],
                                            SOI_opt_maxNumber = 63
                                        },
                                        {
                                            SOI_opt_name = 'Drugi kolor',
                                            SOI_opt_sourcename = 'lipstick:secondColor',
                                            SOI_opt_trigger = 'change_headOverlay',
                                            SOI_opt_currentNumber = headOverlays['lipstick']['secondColor'],
                                            SOI_opt_maxNumber = 63
                                        },
                                    }
                                },
                            }
                        },
                    }
                },
                {
                    option = {
                        optionName = 'Ubrania',
                        optionIcon = 'fa-solid fa-clothes-hanger'
                    },
                    sideOptions = {
                        {
                            sideOptionName = 'Ciuchy',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Rękawiczki',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_3:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[3+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 3)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_3:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[3+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 3)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'T-Shirt',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_8:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[8+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 8)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_8:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[8+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 8)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Kamizelka',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_9:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[9+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 9)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_9:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[9+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 9)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Bluza',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_11:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[11+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 11)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_11:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[11+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 11)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Spodnie',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_4:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[4+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 4)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_4:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[4+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 4)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Buty',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_6:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[6+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 6)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_6:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[6+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 6)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Torba',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_5:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[5+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 5)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_5:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[5+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 5)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Czapka',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'prop_id_0:drawable',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropDrawableVariations(cachePed, 0) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'prop_id_0:texture',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, 0) - 2
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Okulary',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'prop_id_1:drawable',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[2]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropDrawableVariations(cachePed, 1) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'prop_id_1:texture',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[2]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, 1) - 2
                                        },
                                    }
                                },
                            }
                        },
                        {
                            sideOptionName = 'Dodatki',
                            sideOptionItems = {
                                {
                                    SOI_name = 'Maska',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_1:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[1+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 1)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_1:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[1+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 1)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Łańcuch',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_7:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[7+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 7)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_7:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[7+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 7)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Dodatki',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'component_id_10:drawable',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[10+1]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedDrawableVariations(cachePed, 10)
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'component_id_10:texture',
                                            SOI_opt_trigger = 'change_component',
                                            SOI_opt_currentNumber = components[10+1]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, 10)
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Na uszy',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'prop_id_2:drawable',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[3]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropDrawableVariations(cachePed, 2) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'prop_id_2:texture',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[3]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, 2) - 2
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Zegarek',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'prop_id_6:drawable',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[4]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropDrawableVariations(cachePed, 6) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'prop_id_6:texture',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[4]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, 6) - 2
                                        },
                                    }
                                },
                                {
                                    SOI_name = 'Bransoletka',
                                    SOI_opt = {
                                        {
                                            SOI_opt_name = 'Styl',
                                            SOI_opt_sourcename = 'prop_id_7:drawable',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[5]['drawable'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropDrawableVariations(cachePed, 7) - 1
                                        },
                                        {
                                            SOI_opt_name = 'Wariant',
                                            SOI_opt_sourcename = 'prop_id_7:texture',
                                            SOI_opt_trigger = 'change_prop',
                                            SOI_opt_currentNumber = props[5]['texture'],
                                            SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, 7) - 2
                                        },
                                    }
                                },
                            }
                        },
                    }
                }
            }
        }
    end 

    local coords = GetEntityCoords(cachePed)
    local heading = GetEntityHeading(cachePed)
    
    local function HeadingToVector(heading)
        local radian = heading * math.pi / 180.0
        return -math.sin(radian), math.cos(radian)
    end
    
    local dx, dy = HeadingToVector(heading)
    local camCoords = vector3(coords.x + dx * 2.0, coords.y + dy * 2.0, coords.z + 0.5)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    local newZ = camCoords.z
    newZ = math.max(math.min(newZ, coords.z + 0.5 + 0.3), coords.z - 0.5)

    SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtCoord(cam, coords.x, coords.y, newZ)
    playerCam = cam
    
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)

    TaskStandStill(cachePed, -1)

    Citizen.Wait(500)

    SendNUIMessage({
        action = 'setSkinData',
        data = SkinMenu
    })

    SetNuiFocus(true, true)
end

RegisterNetEvent('esx_hud:updateOutfit', function(outfitID)
    if not outfitID then return end

    lib.callback("qf_skinmenu/getOutfits", false, function(outfits)
        local outfitExists = false
        for k, v in pairs(outfits) do
            if v.id == outfitID then
                outfitExists = true
                break
            end
        end

        if not outfitExists then
            ESX.ShowNotification('Wystąpił błąd w załadowaniu twojego outfitu! Spróbuj ponownie pózniej.')
            return
        end

        local pedModel = getPedModel(cachePed)
        local pedComponents = getPedComponents(cachePed)
        local pedProps = getPedProps(cachePed)

        TriggerServerEvent("qf_skinmenu/updateOutfit", outfitID, pedModel, pedComponents, pedProps)
    end)
end)

local function openShop(shop)
    if not LocalPlayer.state.inSpawnSelector then
        Wait(500)
        LocalPlayer.state:set('InSkin', true, true)
        
        if shop == nil or not shop then
            shop = 'skin'
        end

        Citizen.Wait(500)

        if shop ~= 'skin' then
            ESX.ShowNotification('Menu zostanie otwarte za 5 sekund, ustaw się w wygodnym miejscu.')

            Citizen.Wait(5000)
        end

        SendNUIMessage({
            action = 'showSkinMenu',
            data = true
        })

        SetNuiFocus(true, true)

        Citizen.Wait(500)
        getMenu(shop)
    end
end

local function RegisterChangeOutfitMenu(id, parent, outfits, mType)
    local changeOutfitMenu = {
        id = id,
        title = 'Zmień strój',
        menu = parent,
        options = {}
    }


    for k, v in pairs(outfits) do
        changeOutfitMenu.options[#changeOutfitMenu.options + 1] = {
            title = v.outfitname,
            description = v.model,
            event = "esx_hud:changeOutfit",
            args = {
                type = mType,
                name = v.outfitname,
                model = v.model,
                components = v.components,
                props = v.props,
                disableSave = mType and true or false
            }
        }
    end


    table.sort(changeOutfitMenu.options, function(a, b)
        return a.title < b.title
    end)

    lib.registerContext(changeOutfitMenu)
end 

RegisterNetEvent('esx_hud:updateOutfit', function(id)
    local pedModel = getPedModel(cachePed)
    local pedComponents = getPedComponents(cachePed)
    local pedProps = getPedProps(cachePed)
    TriggerServerEvent('qf_skinmenu/updateOutfit', id, pedModel, pedComponents, pedProps)
end)

RegisterNetEvent('esx_hud:deleteOutfit', function(id)
    TriggerServerEvent('qf_skinmenu/deleteOutfit', id)
end)

RegisterNetEvent('esx_hud:generateOutfitCode', function(id)
    lib.callback("qf_skinmenu/generateOutfitCode", false, function(code)
        if not code then
            ESX.ShowNotification('Wystąpił błąd w załadowaniu twojego outfitu! Spróbuj ponownie pózniej.')
            return
        end
        lib.setClipboard(code)
        lib.inputDialog('Wygenerowano kod stroju', {
            {
                type = "input",
                label = 'Oto twój kod stroju',
                default = code,
                disabled = true
            }
        })
    end, id)
end)

local function RegisterUpdateOutfitMenu(id, parent, outfits)
    local updateOutfitMenu = {
        id = id,
        title = 'Aktualizacja stroju',
        menu = parent,
        options = {}
    }
    for k, v in pairs(outfits) do
        updateOutfitMenu.options[#updateOutfitMenu.options + 1] = {
            title = v.outfitname,
            description = v.model,
            event = "esx_hud:updateOutfit",
            args = v.id
        }
    end

    table.sort(updateOutfitMenu.options, function(a, b)
        return a.title < b.title
    end)

    lib.registerContext(updateOutfitMenu)
end

local function RegisterDeleteOutfitMenu(id, parent, outfits)
    local deleteOutfitMenu = {
        id = id,
        title = 'Usuwanie stroju',
        menu = parent,
        options = {}
    }

    table.sort(outfits, function(a, b)
        return a.outfitname < b.outfitname
    end)

    for k, v in pairs(outfits) do
        deleteOutfitMenu.options[#deleteOutfitMenu.options + 1] = {
            title = 'Usuń strój: "'..v.outfitname..'"',
            event = 'esx_hud:deleteOutfit',
            args = v.id
        }
    end

    lib.registerContext(deleteOutfitMenu)
end

local function RegisterGenerateOutfitCodeMenu(id, parent, outfits)
    local generateOutfitCodeMenu = {
        id = id,
        title = 'Generowanie kodu stroju',
        menu = parent,
        options = {}
    }

    for k, v in pairs(outfits) do
        generateOutfitCodeMenu.options[#generateOutfitCodeMenu.options + 1] = {
            title = v.outfitname,
            description = v.model,
            event = "esx_hud:generateOutfitCode",
            args = v.id
        }
    end
    
    lib.registerContext(generateOutfitCodeMenu)
end

RegisterNetEvent('esx_hud:importOutfitCode', function()
    local response = lib.inputDialog('Wprowadź kod stroju', {
        {
            type = "input",
            label = 'Nazwij strój',
            placeholder = 'Jedyny w rodzaju strój',
            default = 'Zaimportowany strój',
            required = true
        },
        {
            type = "input",
            label = 'Kod stroju',
            placeholder = "fAaBlCsDzEyFwGyHsIsJiKeL",
            required = true
        }
    })

    if not response then
        return
    end

    local outfitName = response[1]
    local outfitCode = response[2]
    if outfitCode ~= nil then
        Wait(500)
        lib.callback("qf_skinmenu/importOutfitCode", false, function(success)
            if success then
                ESX.ShowNotification('Dodano nowy strój!')
            else
                ESX.ShowNotification('Coś poszło nie tak, spróbuj ponownie później!')
            end
        end, outfitName, outfitCode)
    end 
end)


local previewPed = nil
local isClothingUIOpen = false

local function openClotheShop(title)
    local outfits = lib.callback.await("qf_skinmenu/getOutfits", false)

    SendNUIMessage({
        eventName = "clotheshop:open",
        outfits = outfits
    })
    
    SetNuiFocus(true, true)
    isClothingUIOpen = true
    
    TriggerScreenblurFadeIn(300)
    
    SetFrontendActive(false)
    Wait(200)
    ReplaceHudColourWithRgba(117, 0, 0, 0, 0)
    SetFrontendActive(true)
    ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_EMPTY"), false, -1)

    Wait(50)
    N_0x98215325a695e78a(false)

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    previewPed = ClonePed(playerPed, GetEntityHeading(playerPed), false, false)
    SetEntityVisible(previewPed, false, false)
    SetEntityCoords(previewPed, playerCoords.x, playerCoords.y, -10.0, false, false, false, false)
    FreezeEntityPosition(previewPed, true)
    
    Wait(50)
    GivePedToPauseMenu(previewPed, 1)
    SetPauseMenuPedLighting(true)
    SetPauseMenuPedSleepState(true)
end

exports("openClotheShopMORDKOKOCHANA", openClotheShop)

local function closeClotheShop()
    if isClothingUIOpen then
        SetNuiFocus(false, false)
        isClothingUIOpen = false
        
        TriggerScreenblurFadeOut(500)
        
        Wait(100)
        SetFrontendActive(false)
        
        if previewPed and DoesEntityExist(previewPed) then
            DeleteEntity(previewPed)
            previewPed = nil
        end
        
        SendNUIMessage({
            eventName = "clotheshop:close"
        })
    end
end

RegisterNUICallback('clotheshop:copyOutfitCode', function(data, cb)
    lib.setClipboard(data.code)
    cb({ success = true })
end)

RegisterNUICallback('clotheshop:previewOutfit', function(data, cb)
    if not previewPed or not DoesEntityExist(previewPed) then
        cb({ success = false, error = "Preview ped not found" })
        return
    end
    
    local outfitId = data.id
    lib.callback('qf_skinmenu/getOutfitById', false, function(outfit)
        if outfit then
            local components = json.decode(outfit.components)
            local props = json.decode(outfit.props)
            
            exports['qf_skinmenu']:setPedComponents(previewPed, components)
            exports['qf_skinmenu']:setPedProps(previewPed, props)
            
            cb({ success = true })
        else
            cb({ success = false, error = "Outfit not found" })
        end
    end, outfitId)
end)

RegisterNUICallback('clotheshop:wearOutfit', function(data, cb)
    local outfitId = data.id
    
    lib.callback('qf_skinmenu/getOutfitById', false, function(outfit)
        if outfit then
            local components = json.decode(outfit.components)
            local props = json.decode(outfit.props)
            
            exports['qf_skinmenu']:setPedComponents(cachePed, components)
            exports['qf_skinmenu']:setPedProps(cachePed, props)
            
            ESX.ShowNotification('Założyłeś strój: ' .. outfit.outfitname)
            closeClotheShop()
            cb({ success = true })
        else
            ESX.ShowNotification('Nie udało się założyć stroju!')
            cb({ success = false, error = "Outfit not found" })
        end
    end, outfitId)
end)

RegisterNUICallback('clotheshop:deleteOutfit', function(data, cb)
    local outfitId = data.id
    
    TriggerServerEvent('qf_skinmenu/deleteOutfit', outfitId)
    
    Wait(200)
    local outfits = lib.callback.await("qf_skinmenu/getOutfits", false)
    cb({ success = true, outfits = outfits })
end)

RegisterNUICallback('clotheshop:updateOutfit', function(data, cb)
    local outfitId = data.id
    
    local pedModel = exports['qf_skinmenu']:getPedModel(cachePed)
    local pedComponents = exports['qf_skinmenu']:getPedComponents(cachePed)
    local pedProps = exports['qf_skinmenu']:getPedProps(cachePed)
    
    TriggerServerEvent('qf_skinmenu/updateOutfit', outfitId, pedModel, pedComponents, pedProps)
    
    ESX.ShowNotification('Zaktualizowano strój!')
    cb({ success = true })
end)

RegisterNUICallback('clotheshop:generateCode', function(data, cb)
    local outfitId = data.id
    
    lib.callback("qf_skinmenu/generateOutfitCode", false, function(code)
        if code then
            cb({ success = true, code = code })
        else
            cb({ success = false, error = "Nie udało się wygenerować kodu" })
        end
    end, outfitId)
end)

RegisterNUICallback('clotheshop:importOutfit', function(data, cb)
    local outfitName = data.name
    local outfitCode = data.code
    
    lib.callback("qf_skinmenu/importOutfitCode", false, function(success)
        if success then
            ESX.ShowNotification('Zaimportowano strój!')
            Wait(200)
            local outfits = lib.callback.await("qf_skinmenu/getOutfits", false)
            cb({ success = true, outfits = outfits })
        else
            cb({ success = false, error = "Nie udało się zaimportować stroju" })
        end
    end, outfitName, outfitCode)
end)

RegisterNUICallback('clotheshop:openShop', function(data, cb)
    closeClotheShop()
    Wait(100)
    exports['qf_skinmenu']:openClothingShop()
    cb({ success = true })
end)

RegisterNUICallback('clotheshop:close', function(data, cb)
    closeClotheShop()
    cb({ success = true })
end)

local function setPedHeadBlend(ped, headBlend)
    if headBlend and isPedFreemodeModel(ped) then
        SetPedHeadBlendData(ped, headBlend.shapeFirst, headBlend.shapeSecond, headBlend.shapeThird, headBlend.skinFirst, headBlend.skinSecond, headBlend.skinThird, tofloat(headBlend.shapeMix or 0), tofloat(headBlend.skinMix or 0), tofloat(headBlend.thirdMix or 0), false)
    end
end

local function setPedFaceFeatures(ped, faceFeatures)
    if faceFeatures then
        for k, v in pairs(FACE_FEATURES) do
            if tofloat(faceFeatures[v]) < -1 then
                faceFeatures[v] = -1
            elseif tofloat(faceFeatures[v]) > 100 then
                faceFeatures[v] = 1
            end

            SetPedFaceFeature(ped, k-1, tofloat(faceFeatures[v]))
        end
    end
end

local function setPedHeadOverlays(headOverlays)
    if headOverlays then
        for k, v in pairs(HEAD_OVERLAYS) do
            local headOverlay = headOverlays[v]
            SetPedHeadOverlay(cachePed, k-1, headOverlay.style, tofloat(headOverlay.opacity))

            if headOverlay.color then
                local colorType = 1
                if v == "blush" or v == "lipstick" or v == "makeUp" then
                    colorType = 2
                end

                SetPedHeadOverlayColor(cachePed, k-1, colorType, headOverlay.color, headOverlay.secondColor)
            end
        end
    end
end

local function setPedHair(ped, hair, tattoos)
    if hair then
        SetPedComponentVariation(ped, 2, hair.style, hair.texture, 0)
        SetPedHairColor(ped, hair.color, hair.highlight)
        if isPedFreemodeModel(ped) then
            setTattoos(ped, tattoos or PED_TATTOOS, hair.style)
        end
    end
end

local function setPedEyeColor(ped, eyeColor)
    if eyeColor then
        SetPedEyeColor(ped, eyeColor)
    end
end


local function setPedComponent(ped, component)
    if component then
        if isPedFreemodeModel(ped) and (component.component_id == 0 or component.component_id == 2) then
            return
        end

        SetPedComponentVariation(ped, component.component_id, component.drawable, component.texture, 0)
    end
end

local function setPedComponents(ped, components)
    if components then
        for _, v in pairs(components) do
            setPedComponent(ped, v)
        end
    end
end

local function setPedProp(ped, prop)
    if prop then
        if prop.drawable == -1 then
            ClearPedProp(ped, prop.prop_id)
        else
            if ESX.IsPlayerLoaded() then
                if ESX.PlayerData.job.name ~= "police" then
                    if prop.prop_id == 0 and prop.drawable == 39 then ClearPedProp(ped, prop.prop_id) return end
                end
            end

            SetPedPropIndex(ped, prop.prop_id, prop.drawable, prop.texture, false)
        end
    end
end

local function setPedProps(ped, props)
    if props then
        for _, v in pairs(props) do
            setPedProp(ped, v)
        end
    end
end

local function wearClothes(typeClothes)
    local dataClothes = DATA_CLOTHES[typeClothes]
    local animationsOn = dataClothes.animations.on
    local components = dataClothes.components[getPedDecorationType()]
    local appliedComponents = APPEARANCE.components
    local props = dataClothes.props[getPedDecorationType()]
    local appliedProps = APPEARANCE.props

    RequestAnimDict(animationsOn.dict)
    while not HasAnimDictLoaded(animationsOn.dict) do
        Wait(0)
    end

    for i = 1, #components do
        local componentId = components[i][1]
        for j = 1, #appliedComponents do
            local applied = appliedComponents[j]
            if applied.component_id == componentId then
                SetPedComponentVariation(cachePed, componentId, applied.drawable, applied.texture, 2)
            end
        end
    end

    for i = 1, #props do
        local propId = props[i][1]
        for j = 1, #appliedProps do
            local applied = appliedProps[j]
            if applied.prop_id == propId then
                SetPedPropIndex(cachePed, propId, applied.drawable, applied.texture, true)
            end
        end
    end

    TaskPlayAnim(cachePed, animationsOn.dict, animationsOn.anim, 3.0, 3.0, animationsOn.duration, animationsOn.move, 0, false, false, false)
end

local function removeClothes(typeClothes)
    local dataClothes = DATA_CLOTHES[typeClothes]
    local animationsOff = dataClothes.animations.off
    local components = dataClothes.components[getPedDecorationType()]
    local props = dataClothes.props[getPedDecorationType()]

    RequestAnimDict(animationsOff.dict)
    while not HasAnimDictLoaded(animationsOff.dict) do
        Wait(0)
    end

    for i = 1, #components do
        local component = components[i]
        SetPedComponentVariation(cachePed, component[1], component[2], 0, 2)
    end

    for i = 1, #props do
        ClearPedProp(cachePed, props[i][1])
    end

    TaskPlayAnim(cachePed, animationsOff.dict, animationsOff.anim, 3.0, 3.0, animationsOff.duration, animationsOff.move, 0, false, false, false)
end

local function setPlayerModel(model)
    if type(model) == "string" then
        model = joaat(model)
    end

    if IsModelInCdimage(model) and IsModelValid(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
        end

        SetPlayerModel(PlayerId(), model)
        local playerPed = PlayerPedId()
        Wait(150)
        SetModelAsNoLongerNeeded(model)

        if isPedFreemodeModel(playerPed) then
            SetPedDefaultComponentVariation(playerPed)
            SetPedHeadBlendData(playerPed, 0, 0, 0, 0, 0, 0, 0, 0, 0, false)
        end

        PED_TATTOOS = {}
        return playerPed
    end

    return PlayerId()
end

local function closeSkin()
    LocalPlayer.state:set('InSkin', false, true)

    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'showSkinMenu',
        data = false
    })
    wearClothes('head')
    wearClothes('bottom')
    wearClothes('body')
    WEAR_CLOTHES = {
        head = true,
        body = true,
        bottom = true,
        all = true,
    }

    RenderScriptCams(false, false, 0, true, true)
    ClearPedTasks(cachePed)
    
    setPlayerModel(APPEARANCE.model)
    setPedComponents(cachePed, APPEARANCE.components)
    setPedProps(cachePed, APPEARANCE.props)

    if APPEARANCE.headBlend and isPedFreemodeModel(cachePed) then setPedHeadBlend(cachePed, APPEARANCE.headBlend) end
    if APPEARANCE.faceFeatures then setPedFaceFeatures(cachePed, APPEARANCE.faceFeatures) end
    if APPEARANCE.headOverlays then setPedHeadOverlays(APPEARANCE.headOverlays) end
    if APPEARANCE.hair then setPedHair(cachePed, APPEARANCE.hair, APPEARANCE.tattoo) end
    if APPEARANCE.eyeColor then setPedEyeColor(cachePed, APPEARANCE.eyeColor) end
    if APPEARANCE.tattoos ~= nil or APPEARANCE.tattoos ~= {} then setPedTattoos(cachePed, APPEARANCE.tattoos) end

    TriggerServerEvent("esx_hud:saveAppearance", APPEARANCE)
end

local function setPedAppearance(ped, appearance)
    if appearance then
        if appearance.components then setPedComponents(ped, appearance.components) end
        if appearance.props then setPedProps(ped, appearance.props) end
        if appearance.headBlend and isPedFreemodeModel(ped) then setPedHeadBlend(ped, appearance.headBlend) end
        if appearance.faceFeatures then setPedFaceFeatures(ped, appearance.faceFeatures) end
        if appearance.headOverlays then setPedHeadOverlays(appearance.headOverlays) end
        if appearance.hair then setPedHair(ped, appearance.hair, appearance.tattoos) end
        if appearance.eyeColor then setPedEyeColor(ped, appearance.eyeColor) end
        if appearance.tattoos then setPedTattoos(ped, appearance.tattoos) end
    end
end

exports('setPedAppearance', setPedAppearance)

local function setPlayerAppearance(appearance)
    if appearance then
        setPlayerModel(appearance.model)
        setPedAppearance(cachePed, appearance)
    else
        setPlayerModel('mp_m_freemode_01')
        setPedAppearance(cachePed, {
            Hair = {style = 0, texture = 0, highlight = 0, color = 0},
            Components = {
                {component_id = 0, drawable = 0, texture = 0},
                {component_id = 1, drawable = 0, texture = 0},
                {component_id = 2, drawable = 0, texture = 0},
                {component_id = 3, drawable = 0, texture = 0},
                {component_id = 4, drawable = 0, texture = 0},
                {component_id = 5, drawable = 0, texture = 0},
                {component_id = 6, drawable = 0, texture = 0},
                {component_id = 7, drawable = 0, texture = 0},
                {component_id = 8, drawable = 0, texture = 0},
                {component_id = 9, drawable = 0, texture = 0},
                {component_id = 10, drawable = 0, texture = 0},
                {component_id = 11, drawable = 0, texture = 0}
            },
            Props = {
                {prop_id = 0, texture = -1, drawable = -1},
                {prop_id = 1, texture = -1, drawable = -1},
                {prop_id = 2, texture = -1, drawable = -1},
                {prop_id = 6, texture = -1, drawable = -1},
                {prop_id = 7, texture = -1, drawable = -1}
            }
        })
    end
end

function InitAppearance()
    while not ESX.GetPlayerData() do
        Citizen.Wait(1000)
    end

    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(1000)
    end
    
    local appearance = lib.callback.await("esx_hud:getAppearance", false)
    if not appearance then
        return
    end
    if appearance == 0 then
        InitializeCharacter(GetGenderById(appearance))
    else
        setPlayerAppearance(appearance)
    end

    ResetBlips()
end

local stats = {
    health = 0,
    armour = 0
}

local function BackupPlayerStats()
    stats = {
        health = GetEntityHealth(cachePed),
        armour = GetPedArmour(cachePed)
    }
end

local function RestorePlayerStats()
    if stats then
        SetEntityMaxHealth(cachePed, 200)
        Wait(1000)
        SetEntityHealth(cachePed, stats.health)
        SetPedArmour(cachePed, stats.armour)
        stats = {}
    end
end

RegisterNetEvent("esx_hud:changeOutfit", function(data)
    local pedModel = getPedModel(cachePed)
    local appearanceDB
    if pedModel ~= data.model then
        local p = promise.new()
        lib.callback("esx_hud:getAppearance", false, function(appearance)
            BackupPlayerStats()
            if appearance then
                setPlayerAppearance(appearance)
                RestorePlayerStats()
            else
                ESX.ShowNotification('Wystąpił błąd w załadowaniu twojego outfitu! Spróbuj ponownie pózniej.')
            end
            p:resolve(appearance)
        end, data.model)
        appearanceDB = Citizen.Await(p)
    else
        appearanceDB = getPedAppearance(cachePed)
    end
    if appearanceDB then
        setPedComponents(cachePed, json.decode(data.components))
        setPedProps(cachePed, json.decode(data.props))
        setPedHair(cachePed, appearanceDB.hair, appearanceDB.tattoos)
        ESX.ShowNotification('Zmieniono strój!')

        local appearance = getPedAppearance(cachePed)
        TriggerServerEvent("esx_hud:saveAppearance", appearance)
    end
end)

RegisterNUICallback('esx_hud:skin_save_player', function(data, cb)
    closeSkin()
end)

RegisterNUICallback('change_headBlend', function(data, cb)
    if string.match(string.lower(data.sourcename), 'mix') then
        APPEARANCE.headBlend[data.sourcename] = data.value / 10
    else
        APPEARANCE.headBlend[data.sourcename] = data.value
    end


    setPedHeadBlend(cachePed, APPEARANCE.headBlend)
end)

RegisterNUICallback('change_faceFeature', function(data, cb)
    
    if string.match(string.lower(data.sourcename), '_new') then
        local data1 = string.match(data.sourcename, "(.*)_new")
        APPEARANCE.faceFeatures[data1] = data.value / 20

    else
        APPEARANCE.faceFeatures[data.sourcename] = data.value
    end

    setPedFaceFeatures(cachePed, APPEARANCE.faceFeatures)
end)

RegisterNUICallback('change_headOverlay', function(data, cb)
    local data1, data2 = string.match(data.sourcename, "(.*):(.*)")
    APPEARANCE.headOverlays[data1][data2] = data.value

    if data2 == 'opacity' then
        APPEARANCE.headOverlays[data1][data2] = data.value / 10
    end


    setPedHeadOverlays(APPEARANCE.headOverlays)
end)

RegisterNUICallback('change_hair', function(data, cb)
    -- if data.sourcename == 'fade' or data.sourcename == 'fade_opacity' then
    --     if data.sourcename == 'fade_opacity' then
    --         PED_TATTOOS["ZONE_HAIR"]['opacity'] = data.value
    --     end

    --     ClearPedDecorations(cachePed)
    --     TriggerEvent("rcore_tattoos:applyOwnedTattoos")

    --     local isMale = getPedDecorationType() == "male"
    --     local aTattoo = Config.ZONE_HAIR[data.value]
    --     local aTattooGender = isMale and aTattoo.hashMale or aTattoo.hashFemale


    --     if PED_TATTOOS["ZONE_HAIR"]['opacity'] == 0 then return end
    --     for _ = 1, PED_TATTOOS["ZONE_HAIR"]['opacity'] do
    --         AddPedDecorationFromHashes(cachePed, joaat(aTattoo.collection), joaat(aTattooGender))
    --         PED_TATTOOS["ZONE_HAIR"]['collection'] = aTattoo.collection
    --     end
    --     return
    -- end

    APPEARANCE.hair[data.sourcename] = data.value

    setPedHair(cachePed, APPEARANCE.hair)

end)

RegisterNUICallback('change_eyeColor', function(data, cb)
    APPEARANCE.eyeColor = data.value

    setPedEyeColor(cachePed, APPEARANCE.eyeColor)
end)

RegisterNUICallback('change_component', function(data, cb)
    local data1, data2 = string.match(data.sourcename, "(.*):(.*)")

    local component_id_string = data1:gsub('component_id_', '')
    local component_id = tonumber(component_id_string)
    local updated_component = 0

    if data2 == 'drawable' then
        for k, v in ipairs(SkinMenu['options']) do
            for g, h in ipairs(v.sideOptions) do
                for a, b in ipairs(h.sideOptionItems) do
                    if b.SOI_type and b.SOI_type == 'select' then
                        goto skip
                    end
                    for i, j in ipairs(b.SOI_opt) do
                        local data1_s, data2_s = string.match(j.SOI_opt_sourcename, "(.*):(.*)")
                        if data1_s == data1 then
                            if data2_s == 'drawable' then
                                j.SOI_opt_currentNumber = data.value
                            end

                            if data2_s == 'texture' then
                                j.SOI_opt_maxNumber = GetNumberOfPedTextureVariations(cachePed, component_id, data.value)
                                j.SOI_opt_currentNumber = 0
                                break
                            end
                        end
                    end
                    ::skip::
                end
    
            end
        end
    
        SendNUIMessage({
            action = 'setSkinData',
            data = SkinMenu
        })

        SetNuiFocus(true, true)
    end

    for k, v in ipairs(APPEARANCE.components) do
        if v.component_id == component_id then
            v[data2] = data.value
            
            if data2 == 'drawable' then
                v['texture'] = 0
            end
            updated_component = k
            break
        end
    end

    setPedComponent(cachePed, APPEARANCE.components[updated_component])
end)

RegisterNUICallback('change_prop', function(data, cb)
    local data1, data2 = string.match(data.sourcename, "(.*):(.*)")

    local prop_id_string = data1:gsub('prop_id_', '')
    local prop_id = tonumber(prop_id_string)
    local updated_prop = 0


    if data2 == 'drawable' then
        for k, v in ipairs(SkinMenu['options']) do
            for g, h in ipairs(v.sideOptions) do
                for a, b in ipairs(h.sideOptionItems) do
                    if b.SOI_type and b.SOI_type == 'select' then
                        goto skip
                    end
                    for i, j in ipairs(b.SOI_opt) do
                        local data1_s, data2_s = string.match(j.SOI_opt_sourcename, "(.*):(.*)")
                        if data1_s == data1 then
                            if data2_s == 'drawable' then
                                j.SOI_opt_currentNumber = data.value
                            end

                            if data2_s == 'texture' then
                                j.SOI_opt_maxNumber = GetNumberOfPedPropTextureVariations(cachePed, prop_id, data.value)
                                j.SOI_opt_currentNumber = 0
                                break
                            end

                        end
                    end

                    ::skip::
                end
            end
        end
    
        SendNUIMessage({
            action = 'setSkinData',
            data = SkinMenu
        })

        SetNuiFocus(true, true)
    end


    for k, v in ipairs(APPEARANCE.props) do
        if v.prop_id == prop_id then
            if data2 == 'drawable' then
                v[data2] = data.value - 1
            else
                v[data2] = data.value
            end

            if data2 == 'drawable' then
                v['texture'] = 0
            end
            updated_prop = k
            break
        end
    end

    setPedProp(cachePed, APPEARANCE.props[updated_prop])
end)

RegisterNUICallback('cameraChange', function(data, cb)
    if data.rotate ~= 0 then
        local rotationFactor = 0.5
        local header = GetEntityHeading(cachePed)
        local newHeader = header + (data.rotate * rotationFactor)
        SetEntityHeading(cachePed, newHeader)
    end

    if data.move ~= 0 and playerCam then
        local coords = GetCamCoord(playerCam)
        local playerCoords = GetEntityCoords(cachePed)

        local smoothMoveFactor = 0.005
        local newZ = coords.z + (data.move * smoothMoveFactor)

        local maxZDifference = 0.8
        newZ = math.max(math.min(newZ, playerCoords.z + maxZDifference), playerCoords.z - maxZDifference)

        SetCamCoord(playerCam, coords.x, coords.y, newZ)
        PointCamAtCoord(playerCam, playerCoords.x, playerCoords.y, newZ)
    end
end)

RegisterNUICallback('cameraZoom', function(data, cb)
    if data.zoom ~= 0 and playerCam then
        local zoomFactor = 0.05
        local coords = GetCamCoord(playerCam)
        local playerCoords = GetEntityCoords(cachePed)
        
        local distance = Vdist(coords.x, coords.y, coords.z, playerCoords.x, playerCoords.y, playerCoords.z)
        local newDistance = distance + (data.zoom * zoomFactor)
        
        local minDistance = 0.7
        local maxDistance = 2 
    
        newDistance = math.max(math.min(newDistance, maxDistance), minDistance)
        
        local directionX = (coords.x - playerCoords.x) / distance
        local directionY = (coords.y - playerCoords.y) / distance
        local directionZ = (coords.z - playerCoords.z) / distance
        
        local newCoordsX = playerCoords.x + directionX * newDistance
        local newCoordsY = playerCoords.y + directionY * newDistance
    
        local newZ = coords.z

        local maxZDifference = 0.5
        newZ = math.max(math.min(newZ, playerCoords.z + maxZDifference + 0.3), playerCoords.z - maxZDifference)

        SetCamCoord(playerCam, newCoordsX, newCoordsY, newZ)
        PointCamAtCoord(playerCam, playerCoords.x, playerCoords.y, newZ)
    end
end)

local handsup = false

local function showHands()
    if handsup then
		handsup = false
		ClearPedTasks(cachePed)
	else							
		handsup = true
        lib.requestAnimDict('anim@move_hostages@male')
		TaskPlayAnim(cachePed, "anim@move_hostages@male", "male_idle", 8.0, 8.0, 1.0, 50, 0, 0, 0, 0)
	end
end

RegisterNUICallback('take_clothes_off', function(data, cb)
    if data.value == 'handsUp' then
        showHands()
    elseif data.value ~= 'all' then
        if WEAR_CLOTHES[data.value] then
            WEAR_CLOTHES[data.value] = false
            removeClothes(data.value)
        else
            WEAR_CLOTHES[data.value] = true
            wearClothes(data.value)
        end
    else
        if WEAR_CLOTHES['all'] then
            WEAR_CLOTHES['all'] = false
            removeClothes('head')
            removeClothes('bottom')
            removeClothes('body')
        else
            WEAR_CLOTHES['all'] = true
            wearClothes('head')
            wearClothes('bottom')
            wearClothes('body')
        end
    end
end)

RegisterNUICallback('esx_hud:skin_pay_clothes', function(data, cb)
    TriggerServerEvent('esx_hud:skin_pay_clothes', data.value)
    closeSkin()
end)

RegisterNUICallback('esx_hud:skin_save_wardrobe', function(data, cb)
    TriggerServerEvent('esx_hud:saveOutfit', data.value, APPEARANCE.model, APPEARANCE.components, APPEARANCE.props)
end)

RegisterNUICallback('esx_hud:close_without_saving', function(data, cb)
    LocalPlayer.state:set('InSkin', false, true)

    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'showSkinMenu',
        data = false
    })

    wearClothes('head')
    wearClothes('bottom')
    wearClothes('body')

    WEAR_CLOTHES = {
        head = true,
        body = true,
        bottom = true,
        all = true,
    }

    RenderScriptCams(false, false, 0, true, true)
    ClearPedTasks(cachePed)

    setPlayerModel(UNAPPEARANCE.model)
    setPedComponents(cachePed, UNAPPEARANCE.components)
    setPedProps(cachePed, UNAPPEARANCE.props)

    if UNAPPEARANCE.headBlend and isPedFreemodeModel(cachePed) then 
        setPedHeadBlend(cachePed, UNAPPEARANCE.headBlend)
    elseif LocalPlayer.state.blendOld ~= nil then
        if LocalPlayer.state.blendOld then
            setPedFaceFeatures(cachePed, LocalPlayer.state.blendOld)
        end
    end

    if UNAPPEARANCE.faceFeatures then 
        setPedFaceFeatures(cachePed, UNAPPEARANCE.faceFeatures)
    elseif LocalPlayer.state.faceOld ~= nil then
        if LocalPlayer.state.faceOld then
            setPedFaceFeatures(cachePed, LocalPlayer.state.faceOld)
        end
    end

    if UNAPPEARANCE.headOverlays then setPedHeadOverlays(UNAPPEARANCE.headOverlays) end

    if UNAPPEARANCE.hair then
        setPedHair(cachePed, UNAPPEARANCE.hair, UNAPPEARANCE.tattoo)
    elseif LocalPlayer.state.hairOld ~= nil then
        if LocalPlayer.state.hairOld then
            setPedHair(cachePed, LocalPlayer.state.hairOld, LocalPlayer.state.tattooOld)
        end
    end

    if UNAPPEARANCE.eyeColor then setPedEyeColor(cachePed, UNAPPEARANCE.eyeColor) end
    if UNAPPEARANCE.tattoos then setPedTattoos(cachePed, UNAPPEARANCE.tattoos) end

    TriggerServerEvent("esx_hud:saveAppearance", UNAPPEARANCE)
end)

RegisterNUICallback("apply_tattoo", function(data, cb)
    local paid = not data.tattoo or lib.callback.await("esx_hud:payForTattoo", false, data.tattoo)
    if paid then
        addPedTattoo(cachePed, data.updatedTattoos or data)
    end
    cb(paid)
end)

RegisterNUICallback("preview_tattoo", function(previewTattoo, cb)
    cb(1)
    setPreviewTattoo(cachePed, previewTattoo.data, previewTattoo.tattoo)
end)

RegisterNUICallback("delete_tattoo", function(data, cb)
    cb(1)
    removePedTattoo(cachePed, data)
end)


RegisterNetEvent("esx_hud:openClothingShopMenuHousing", function()
    openClotheShop('Garderoba')
end)

RegisterNetEvent("esx_hud:openOutfitMenu", function()
    openClotheShop()
end)

RegisterNetEvent("esx_hud:skinMenu", function()
    openShop('skin')
end)

local ReloadSkinCooldown = 5000
local reloadSkinTimer = 0
local function InCooldown()
    return (GetGameTimer() - reloadSkinTimer) < ReloadSkinCooldown
end

RegisterNetEvent("esx_hud:reloadSkin", function(bypassChecks)
    if not bypassChecks and InCooldown() or cache.vehicle or IsPedFalling(cachePed) then
        return
    end

    reloadSkinTimer = GetGameTimer()
    BackupPlayerStats()

    lib.callback("esx_hud:getAppearance", false, function(appearance)
        if not appearance then
            return
        end
        setPlayerAppearance(appearance)
        RestorePlayerStats()
    end)
end)

RegisterNetEvent("esx_hud:ClearStuckProps", function()
    if InCooldown() or LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
        return
    end

    reloadSkinTimer = GetGameTimer()

    for _, v in pairs(GetGamePool("CObject")) do
        if IsEntityAttachedToEntity(cachePed, v) then
            SetEntityAsMissionEntity(v, true, true)
            DeleteObject(v)
            DeleteEntity(v)
        end
    end
end)

local function ConvertComponents(oldSkin, components)
    return {
        {
            component_id = 0,
            drawable = (components and components[1].drawable) or 0,
            texture = (components and components[1].texture) or 0
        },
        {
            component_id = 1,
            drawable = oldSkin.mask_1 or (components and components[2].drawable) or 0,
            texture = oldSkin.mask_2 or (components and components[2].texture) or 0
        },
        {
            component_id = 2,
            drawable = (components and components[3].drawable) or 0,
            texture = (components and components[3].texture) or 0
        },
        {
            component_id = 3,
            drawable = oldSkin.arms or (components and components[4].drawable) or 0,
            texture = oldSkin.arms_2 or (components and components[4].texture) or 0,
        },
        {
            component_id = 4,
            drawable = oldSkin.pants_1 or (components and components[5].drawable) or 0,
            texture = oldSkin.pants_2 or (components and components[5].texture) or 0
        },
        {
            component_id = 5,
            drawable = oldSkin.bags_1 or (components and components[6].drawable) or 0,
            texture = oldSkin.bags_2 or (components and components[6].texture) or 0
        },
        {
            component_id = 6,
            drawable = oldSkin.shoes_1 or (components and components[7].drawable) or 0,
            texture = oldSkin.shoes_2 or (components and components[7].texture) or 0
        },
        {
            component_id = 7,
            drawable = oldSkin.chain_1 or (components and components[8].drawable) or 0,
            texture = oldSkin.chain_2 or (components and components[8].texture) or 0
        },
        {
            component_id = 8,
            drawable = oldSkin.tshirt_1 or (components and components[9].drawable) or 0,
            texture = oldSkin.tshirt_2 or (components and components[9].texture) or 0
        },
        {
            component_id = 9,
            drawable = oldSkin.bproof_1 or (components and components[10].drawable) or 0,
            texture = oldSkin.bproof_2 or (components and components[10].texture) or 0
        },
        {
            component_id = 10,
            drawable = oldSkin.decals_1 or (components and components[11].drawable) or 0,
            texture = oldSkin.decals_2 or (components and components[11].texture) or 0
        },
        {
            component_id = 11,
            drawable = oldSkin.torso_1 or (components and components[12].drawable) or 0,
            texture = oldSkin.torso_2 or (components and components[12].texture) or 0
        }
    }
end

local function ConvertProps(oldSkin, props)
    return {
        {
            texture = oldSkin.helmet_2 or (props and props[1].texture) or -1,
            drawable = oldSkin.helmet_1 or (props and props[1].drawable) or -1,
            prop_id = 0
        },
        {
            texture = oldSkin.glasses_2 or (props and props[2].texture) or -1,
            drawable = oldSkin.glasses_1 or (props and props[2].drawable) or -1,
            prop_id = 1
        },
        {
            texture = oldSkin.ears_2 or (props and props[3].texture) or -1,
            drawable = oldSkin.ears_1 or (props and props[3].drawable) or -1,
            prop_id = 2
        },
        {
            texture = oldSkin.watches_2 or (props and props[4].texture) or -1,
            drawable = oldSkin.watches_1 or (props and props[4].drawable) or -1,
            prop_id = 6
        },
        {
            texture = oldSkin.bracelets_2 or (props and props[5].texture) or -1,
            drawable = oldSkin.bracelets_1 or (props and props[5].drawable) or -1,
            prop_id = 7
        }
    }
end

function SetInitialClothes(initial, loadSkin)
    if loadSkin then
        setPlayerModel(initial.Model)
        setPedTattoos(cachePed, {})
        setPedComponents(cachePed, initial.Components)
        setPedProps(cachePed, initial.Props)
        setPedHair(cachePed, initial.Hair, {})
        ClearPedDecorations(cachePed)
    elseif not LocalPlayer.state.inSpawnSelector then
        getMenu('skin')
        setPlayerModel(initial.Model)
        setPedTattoos(cachePed, {})
        setPedComponents(cachePed, initial.Components)
        setPedProps(cachePed, initial.Props)
        setPedHair(cachePed, initial.Hair, {})
        ClearPedDecorations(cachePed)
    else
        while LocalPlayer.state.inSpawnSelector do
            Wait(100)
        end
        Wait(3500)
        ESX.ShowNotification('Menu zostanie otwarte za 5 sekund, ustaw się w wygodnym miejscu.')

        Wait(5000)
        getMenu('skin')
    end
end

function InitializeCharacter(gender, onSubmit, onCancel)
    SetInitialClothes(Config.InitialPlayerClothes[gender])
    Citizen.Wait(2000)
    openShop('skin')
end

local firstSpawn = false

local function GetPlayerGender()
    PlayerData = ESX.GetPlayerData()
    if PlayerData.sex == "f" then
        return "Female"
    end
    return "Male"
end

local function GetGender(isNew)
    if isNew or not Config.GenderBasedOnPed then
        return GetPlayerGender()
    end

    local model = getPedModel(cachePed)
    if model == "mp_f_freemode_01" then
        return "Female"
    end
    return "Male"
end

AddEventHandler("esx_skin:resetFirstSpawn", function()
    firstSpawn = true
end)

AddEventHandler("esx_skin:playerRegistered", function()
    if(firstSpawn) then
        InitializeCharacter(GetGender(true))
    end
end)

RegisterNetEvent("skinchanger:loadSkin2", function(ped, skin)
    if not skin.model then skin.model = "mp_m_freemode_01" end
    setPedAppearance(ped, skin)
    ESX.SetPlayerData("ped", cachePed)
end)

RegisterNetEvent("skinchanger:getSkin", function(cb)
    while not ESX.GetPlayerData() do
        Citizen.Wait(1000)
    end

    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(1000)
    end
    
    lib.callback("esx_hud:getAppearance", false, function(appearance)
        cb(appearance)
        ESX.SetPlayerData("ped", cachePed)
    end)
end)

RegisterNetEvent("skinchanger:loadSkin", function(skin, cb)
    if skin.model then
        setPlayerAppearance(skin)
    else
        SetInitialClothes(Config.InitialPlayerClothes[GetGender(true)], true)
    end
    if ESX.GetPlayerData() and ESX.GetPlayerData().loadout then
        TriggerEvent("esx:restoreLoadout")
    end
    ESX.SetPlayerData("ped", cachePed)
	if cb ~= nil then
		cb()
	end
end)

RegisterNetEvent("skinchanger:loadClothes", function(_, clothes)
    local components = ConvertComponents(clothes, getPedComponents(cachePed))
    local props = ConvertProps(clothes, getPedProps(cachePed))

    setPedComponents(cachePed, components)
    setPedProps(cachePed, props)
end)

RegisterNetEvent("esx_skin:openSaveableMenu", function(onSubmit, onCancel)
    InitializeCharacter(GetGender(true), onSubmit, onCancel)
end)

RegisterNetEvent('esx_hud:openClothingShop', function()
    openClotheShop()
end)

RegisterNetEvent('esx_hud:openBarberShop', function()
    openShop("barbershop")
end)

function IsPlayerAllowedForOutfitRoom(outfitRoom)
    local isAllowed = false
    local count = #outfitRoom.citizenIDs
    for i = 1, count, 1 do
        local esx_meta = ESX.GetPlayerData()

        if esx_meta.identifier == outfitRoom.citizenIDs[i] then
            isAllowed = true
            break
        end
    end
    return isAllowed or not outfitRoom.citizenIDs or count == 0
end

function OpenOutfitRoom(outfitRoom)
    local isAllowed = IsPlayerAllowedForOutfitRoom(outfitRoom)
    if isAllowed then
        openClotheShop('Outfity')
    end
end

local hairOld = nil
local faceOld = nil
local blendOld = nil
local skin1, skin2, skin3, skin4, skin5, skin6 = nil, nil, nil, nil, nil, nil
local clothType

lib.addRadialItem({
	{
		label = 'Ubrania',
		icon = 'fa-solid fa-shirt',
        id = 'ubrania',
		menu = 'ubrania_menu'
	},
})

lib.registerRadial({
	id = 'ubrania_menu',
	items = {
        {
			label = 'Tułów',
			icon = 'fa-solid fa-shirt',
			onSelect = function ()
                clothType = 'torso'
                skin1 = GetPedDrawableVariation(cachePed, 11)
                skin2 = GetPedTextureVariation(cachePed, 11)
            
                skin3 = GetPedDrawableVariation(cachePed, 3)
                skin4 = GetPedTextureVariation(cachePed, 3)
            
                skin5 = GetPedDrawableVariation(cachePed, 8)
                skin6 = GetPedTextureVariation(cachePed, 8)
            
                if GetPedDrawableVariation(cachePed, 11) ~= 15 then
                    SetPedComponentVariation(cachePed, 11, 15, 0, 0)

                    if GetPedDrawableVariation(cachePed, 3) ~= 15 then
                        SetPedComponentVariation(cachePed, 3, 15, 0, 0)
                    end

                    SetPedComponentVariation(cachePed, 8, -1, 0, 2)
                    TriggerServerEvent('esx_core:add:clothestorso', skin1, skin2, skin3, skin4, skin5, skin6, clothType)
                    
                    lib.requestAnimDict('clothingtie')
                    TaskPlayAnim(cachePed, 'clothingtie', 'try_tie_negative_a', 3.0, 3.0, 1200, 51, 0, false, false, false)
                end
			end
		},
        {
			label = 'Spodnie',
			icon = 'fa-solid fa-people-arrows',
			onSelect = function ()
                clothType = 'jeans'
                skin1 = GetPedDrawableVariation(cachePed, 4)
                skin2 = GetPedTextureVariation(cachePed, 4)
            
                if GetPedDrawableVariation(cachePed, 4) ~= 14 then
                    SetPedComponentVariation(cachePed, 4, 14, 1, 2)
                    TriggerServerEvent('esx_core:add:clothes', skin1, skin2, clothType)
                    
                    lib.requestAnimDict('re@construction')
                    TaskPlayAnim(cachePed, 're@construction', 'out_of_breath', 3.0, 3.0, 1300, 51, 0, false, false, false)
                end
			end
		},
        {
			label = 'Buty',
			icon = 'fa-solid fa-shoe-prints',
			onSelect = function ()
                clothType = 'shoes'
                skin1 = GetPedDrawableVariation(cachePed, 6)
                skin2 = GetPedTextureVariation(cachePed, 6)
                
                if GetPedDrawableVariation(cachePed,6) ~= 34 then
                    SetPedComponentVariation(cachePed, 6, 34, 0, 2)
                    TriggerServerEvent('esx_core:add:clothes', skin1, skin2, clothType)

                    lib.requestAnimDict('random@domestic')
                    TaskPlayAnim(cachePed, 'random@domestic', 'pickup_low', 3.0, 3.0, 1200, 0, 0, false, false, false)
                end
			end
		},
        {
			label = 'Maska',
			icon = 'fa-solid fa-masks-theater',
			onSelect = function ()
				clothType = 'mask'
                skin1 = GetPedDrawableVariation(cachePed, 1)
                skin2 = GetPedTextureVariation(cachePed, 1)

                if GetPedDrawableVariation(cachePed, 1) ~= 0 and GetPedDrawableVariation(cachePed, 1) ~= -1 then
                    SetPedComponentVariation(cachePed, 1, -1, 0, 2)
                    TriggerServerEvent('esx_core:add:clothes', skin1, skin2, clothType)

                    lib.requestAnimDict('mp_masks@standard_car@ds@')
                    TaskPlayAnim(cachePed, 'mp_masks@standard_car@ds@', 'put_on_mask', 3.0, 3.0, 800, 51, 0, false, false, false)
                end
			end
		},
		{
			label = 'Czapka',
			icon = 'fa-solid fa-hat-cowboy',
			onSelect = function ()
                clothType = 'helmet'
                skin1 = GetPedPropIndex(cachePed, 0)
                skin2 = GetPedPropTextureIndex(cachePed, 0)
            
                if GetPedPropIndex(cachePed,0) ~= -1 then
                    ClearPedProp(cachePed, 0)
                    TriggerServerEvent('esx_core:add:clothes', skin1, skin2, clothType)

                    lib.requestAnimDict('mp_masks@standard_car@ds@')
                    TaskPlayAnim(cachePed, 'mp_masks@standard_car@ds@', 'put_on_mask', 3.0, 3.0, 600, 51, 0, false, false, false)
                end
			end
		},
        {
			label = 'Okulary',
			icon = 'fa-solid fa-glasses',
			onSelect = function ()
                clothType = 'glasses'
                skin1 = GetPedPropIndex(cachePed, 1)
                skin2 = GetPedPropTextureIndex(cachePed, 1)
            
                if GetPedPropIndex(cachePed,1) ~= -1  then
                    ClearPedProp(cachePed, 1)
                    TriggerServerEvent('esx_core:add:clothes', skin1, skin2, clothType)

                    lib.requestAnimDict('clothingspecs')
                    TaskPlayAnim(cachePed, 'clothingspecs', 'take_off', 3.0, 3.0, 1200, 51, 0, false, false, false)
                end
			end
		},
        {
			label = 'Rękawiczki',
			icon = 'fa-solid fa-mitten',
			onSelect = function ()
                clothType = 'arms'
                skin1 = GetPedDrawableVariation(cachePed, 3)
                skin2 = GetPedTextureVariation(cachePed, 3)
            
                if GetPedDrawableVariation(cachePed,3) ~= 15  then
                    SetPedComponentVariation(cachePed, 3, 15, 0, 0)
                    TriggerServerEvent('esx_core:add:clothes', skin1, skin2, clothType)

                    lib.requestAnimDict('nmt_3_rcm-10')
                    TaskPlayAnim(cachePed, 'nmt_3_rcm-10', 'cs_nigel_dual-10', 3.0, 3.0, 600, 51, 0, false, false, false)
                end
			end
		},
        {
			label = 'Torba',
			icon = 'fa-solid fa-people-carry-box',
			onSelect = function ()
                clothType = 'bagcloth'
                skin1 = GetPedPropIndex(cachePed, 5)
                skin2 = GetPedPropTextureIndex(cachePed, 5)
            
                if GetPedPropIndex(cachePed,5) ~= -1  then
                    ClearPedProp(cachePed, 5)
                    TriggerServerEvent('esx_core:add:clothes', skin1, skin2, clothType)

                    lib.requestAnimDict('clothingtie')
                    TaskPlayAnim(cachePed, 'clothingtie', 'try_tie_negative_a', 3.0, 3.0, 1200, 51, 0, false, false, false)
                end
			end
		},
        {
			label = 'Kamizelka',
			icon = 'fa-solid fa-vest',
			onSelect = function ()
                clothType = 'vest'

                skin1 = GetPedDrawableVariation(cachePed, 9)
                skin2 = GetPedTextureVariation(cachePed, 9)
    
                if GetPedDrawableVariation(cachePed, 9) ~= -1 then
                    SetPedComponentVariation(cachePed, 9, -1, 0, 2)
                    TriggerServerEvent('esx_core:add:clothes', skin1, skin2, clothType)

                    lib.requestAnimDict('clothingtie')
                    TaskPlayAnim(cachePed, 'clothingtie', 'try_tie_negative_a', 3.0, 3.0, 1200, 51, 0, false, false, false)
                end
			end
		},
        {
			label = 'Łańcuch',
			icon = 'fa-solid fa-link',
			onSelect = function ()
                clothType = 'chain'
                skin1 = GetPedDrawableVariation(cachePed, 7)
                skin2 = GetPedTextureVariation(cachePed, 7)

                if GetPedDrawableVariation(cachePed, 7) ~= 0 and GetPedDrawableVariation(cachePed, 7) ~= -1 then
                    SetPedComponentVariation(cachePed, 7, -1, 0, 2)
                    TriggerServerEvent('esx_core:add:clothes', skin1, skin2, clothType)

                    lib.requestAnimDict('clothingtie')
                    TaskPlayAnim(cachePed, 'clothingtie', 'try_tie_negative_a', 3.0, 3.0, 1200, 51, 0, false, false, false)
                end
			end
		},
        {
			label = 'Branzoletka',
			icon = 'fa-solid fa-ring',
			onSelect = function ()
                clothType = 'bracelet'
                skin1 = GetPedPropIndex(cachePed, 7)
                skin2 = GetPedPropTextureIndex(cachePed, 7)
            
                if GetPedPropIndex(cachePed,7) ~= -1  then
                    ClearPedProp(cachePed, 7)
                    TriggerServerEvent('esx_core:add:clothes', skin1, skin2, clothType)

                    lib.requestAnimDict('nmt_3_rcm-10')
                    TaskPlayAnim(cachePed, 'nmt_3_rcm-10', 'cs_nigel_dual-10', 3.0, 3.0, 1200, 51, 0, false, false, false)
                end
			end
		},
        {
			label = 'Zegarek',
			icon = 'fa-solid fa-clock',
			onSelect = function ()
                clothType = 'watchcloth'
                skin1 = GetPedPropIndex(cachePed, 6)
                skin2 = GetPedPropTextureIndex(cachePed, 6)
            
                if GetPedPropIndex(cachePed,6) ~= -1  then
                    ClearPedProp(cachePed, 6)
                    TriggerServerEvent('esx_core:add:clothes', skin1, skin2, clothType)

                    lib.requestAnimDict('nmt_3_rcm-10')
                    TaskPlayAnim(cachePed, 'nmt_3_rcm-10', 'cs_nigel_dual-10', 3.0, 3.0, 1200, 51, 0, false, false, false)
                end
			end
		},
        {
			label = 'Ucho',
			icon = 'fa-solid fa-ear-listen',
			onSelect = function ()
                clothType = 'ears'
                skin1 = GetPedPropIndex(cachePed, 2)
                skin2 = GetPedPropTextureIndex(cachePed, 2)
            
                if GetPedPropIndex(cachePed,2) ~= -1  then
                    ClearPedProp(cachePed, 2)
                    TriggerServerEvent('esx_core:add:clothes', skin1, skin2, clothType)

                    lib.requestAnimDict('mp_cp_stolen_tut')
                    TaskPlayAnim(cachePed, 'mp_cp_stolen_tut', 'b_think', 3.0, 3.0, 900, 51, 0, false, false, false)
                end
			end
		},
        {
			label = 'Popraw włosy',
			icon = 'fa-solid fa-scissors',
			onSelect = function ()
                if hairOld ~= nil then
                    SetPedComponentVariation(cachePed, 2, hairOld, 0, 2)
                    hairOld = nil
                else
                    hairOld = client.getPedHair(cachePed).style
                    SetPedComponentVariation(cachePed, 2, -1, 0, 2)	
                end
			end
		},
        {
			label = 'Popraw maskę',
			icon = 'fa-regular fa-face-smile-beam',
			onSelect = function ()
                if faceOld ~= nil and blendOld ~= nil then
                    setPedFaceFeatures(cachePed, faceOld)
                    setPedHeadBlend(cachePed, blendOld)
                    faceOld = nil
                    blendOld = nil
                else
                    faceOld = getPedFaceFeatures(cachePed)
                    blendOld = getPedHeadBlend(cachePed)
                    local faceFeatures = getPedDefaultFaceFeatures()
                    local headBlend = getPedDefaultHeadBlend(cachePed)
                    setPedFaceFeatures(cachePed, faceFeatures)
                    setPedHeadBlend(cachePed, headBlend)
                end
			end
		},
	}
})

RegisterNetEvent('kariee:changeOrgOutfit', function(components, props)
    setPedComponents(cachePed, json.decode(components))
    setPedProps(cachePed, json.decode(props))
    ClearPedDecorations(cachePed)
end)

RegisterNetEvent('kariee:takeClothes', function(sourcePed, target)
    local pedComponents = getPedComponents(target)
    local pedProps = getPedProps(target)

    setPedComponents(sourcePed, pedComponents)
    setPedProps(sourcePed, pedProps)
end)

RegisterNUICallback('change_model', function(data, cb)
    APPEARANCE.model = data.value

    setPlayerModel(APPEARANCE.model)
end)

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        InitAppearance()
    end
end)