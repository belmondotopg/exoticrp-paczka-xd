PlayerData = {}
CurrentBag = 0
ClonedPed, Cam = nil, nil

Citizen.CreateThread(Init)

lib.callback.register('exotic_clothingbag:placeBag', PlaceBag)

RegisterNuiCallback("closeUI", CloseNui)
RegisterNuiCallback("switchPrivacy", SwitchPrivacy)
RegisterNuiCallback("createNewOutfit", CreateNewOutfit)
RegisterNuiCallback("deleteOutfit", DeleteOutfit)
RegisterNuiCallback("dressUp", DressUp)
RegisterNuiCallback("previewOutfit", PreviewOutfit)
