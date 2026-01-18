Bags = {}

Citizen.CreateThread(LoadDatabase)

exports("useBag", function(event, item, inventory, slot)
    if event == 'usingItem' then
        local itemSlot = exports.ox_inventory:GetSlot(inventory.id, slot)

        UseBag(inventory.id, itemSlot.metadata)

        return true
    end
end)

lib.callback.register('exotic_clothingbag:switchBagPrivacy', SwitchBagPrivacy)
lib.callback.register('exotic_clothingbag:takeBag', TakeBag)
lib.callback.register('exotic_clothingbag:openBag', OpenBag)
lib.callback.register('exotic_clothingbag:createNewOutfit', CreateNewOutfit)
lib.callback.register('exotic_clothingbag:deleteOutfit', DeleteOutfit)
lib.callback.register('exotic_clothingbag:dressUp', DressUp)
lib.callback.register('exotic_clothingbag:previewOutfit', PreviewOutfit)
