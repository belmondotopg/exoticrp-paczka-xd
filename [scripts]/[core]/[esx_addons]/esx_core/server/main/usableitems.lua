local function startProgress(src, seconds, label, callback, animData)
    if animData then
        if animData.type == 'eat' then
            TriggerClientEvent('esx_basicneeds:onEat', src, animData.prop, false, seconds)
        elseif animData.type == 'drink' then
            TriggerClientEvent('esx_basicneeds:onDrink', src, animData.prop, animData.addon or false, seconds)
        end
    end
    
    TriggerClientEvent('esx_hud:startProgress', src, {
        duration = seconds,
        label    = label,
        canCancel = true,
        disable  = { combat = true, movement = true, car = true }
    })

    local p = promise.new()
    local eventName = ('progressResult:%s'):format(src)

    RegisterNetEvent(eventName)
    local handler

    handler = AddEventHandler(eventName, function(success)
        p:resolve(success)
    end)

    SetTimeout(seconds * 1000 + 5000, function()
        if p.state == 0 then
            p:resolve(false)
        end
    end)

    local success = Citizen.Await(p)
    RemoveEventHandler(handler)

    if success then
        callback()
    else
        TriggerClientEvent('esx:showNotification', src, '~r~Anulowano użycie przedmiotu.')
        if animData then
            TriggerClientEvent('esx_basicneeds:clearAnimation', src)
        end
    end
end

local function canUseBasicItem(src, statusName, callback)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    
    local status = xPlayer.get('status') or {}
    for i = 1, #status do
        if status[i].name == statusName then
            local currentValue = status[i].val or 0
            local maxValue = 1000000
            local percentFilled = (currentValue / maxValue) * 100
            
            if percentFilled > 30 then
                if statusName == 'hunger' then
                    TriggerClientEvent('esx:showNotification', src, '~r~Nie jesteś już głodny! Odwiedź restaurację aby napełnić głód w pełni.')
                else
                    TriggerClientEvent('esx:showNotification', src, '~r~Nie jesteś już spragniony! Odwiedź restaurację aby napełnić pragnienie w pełni.')
                end
                callback(false)
                return
            end
            callback(true)
            return
        end
    end
    callback(true)
end

local function useFoodItem(src, xPlayer, config)
    startProgress(src, config.duration, config.label, function()
        xPlayer.removeInventoryItem(config.itemName, 1)
        if config.effects then
            for status, value in pairs(config.effects) do
                local statusType = config.statusType or 'basic'
                if status == 'drunk' and value == true then
                    value = math.random(200000, 2000000)
                end
                TriggerClientEvent('esx_status:add', src, status, value, statusType)
            end
        end
        if config.notification then
            TriggerClientEvent('esx:showNotification', src, config.notification)
        end
        if config.customCallback then
            config.customCallback(src, xPlayer)
        end
    end, config.animData)
end

local function registerFoodItem(itemName, config)
    ESX.RegisterUsableItem(itemName, function(source)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        
        if config.requireStatus then
            canUseBasicItem(src, config.requireStatus, function(canUse)
                if not canUse then return end
                useFoodItem(src, xPlayer, config)
            end)
        else
            useFoodItem(src, xPlayer, config)
        end
    end)
end

local function registerDrinkItem(itemName, config)
    registerFoodItem(itemName, config)
end

-- ============================================================================
-- PRZEDMIOTY SPECJALNE
-- ============================================================================

ESX.RegisterUsableItem('bon_domlimitowany', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('bon_domlimitowany', 1)

    exports.esx_core:SendLog(source, "Bony limitowane", "Gracz " .. GetPlayerName(source) .. " wyrzucił przedmiot: Bon na dom Limitowany w ilości: 1", "bon-limitka")
    TriggerClientEvent('esx:showNotification', source, 'Użyłeś/aś bonu na dom limitowany! Wyjdź i wejdź ponownie.')
end)

ESX.RegisterUsableItem('bon_helikopter', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('bon_helikopter', 1)

    exports.esx_core:SendLog(source, "Bony limitowane", "Gracz " .. GetPlayerName(source) .. " wyrzucił przedmiot: Bon na helikopter w ilości: 1", "bon-limitka")
    TriggerClientEvent('esx:showNotification', source, 'Użyłeś/aś bonu na helikopter! Wyjdź i wejdź ponownie.')
end)

ESX.RegisterUsableItem('bon_limitka', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('bon_limitka', 1)

    exports.esx_core:SendLog(source, "Bony limitowane", "Gracz " .. GetPlayerName(source) .. " wyrzucił przedmiot: Bon na limitowany pojazd w ilości: 1", "bon-limitka")
    TriggerClientEvent('esx:showNotification', source, 'Użyłeś/aś bonu na limitowany pojazd! Wyjdź i wejdź ponownie.')
end)

ESX.RegisterUsableItem('bon_limitka_dzwiek', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('bon_limitka_dzwiek', 1)

    exports.esx_core:SendLog(source, "Bony limitowane", "Gracz " .. GetPlayerName(source) .. " wyrzucił przedmiot: Bon na custom dźwięk auta w ilości: 1", "bon-limitka")
    TriggerClientEvent('esx:showNotification', source, 'Użyłeś/aś bonu na custom dźwięk auta! Wyjdź i wejdź ponownie.')
end)

ESX.RegisterUsableItem('bon_drugapostac', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem('bon_drugapostac', 1)
    local identifier = ESX.ExtractIdentifiers(source).license
    local slots = MySQL.single.await('SELECT `slots` FROM `multicharacter_slots` WHERE identifier = ?', {identifier})
    if not slots then
        MySQL.update.await('INSERT INTO `multicharacter_slots` (`identifier`, `slots`) VALUES (?, ?)', {identifier, 2})
    else
        MySQL.update.await('UPDATE `multicharacter_slots` SET `slots` = `slots` + 1 WHERE `identifier` = ?', {identifier})
    end
    TriggerClientEvent('esx:showNotification', source, 'Użyłeś/aś bonu na drugą postać! Wyjdź i wejdź ponownie.')
end)

ESX.RegisterUsableItem('kontrakt', function(source)
    TriggerClientEvent('esx_core_contract:getVehicle', source)
end)

ESX.RegisterUsableItem('kaskswat', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    startProgress(src, 4, 'Zakładasz kask SWAT...', function()
        xPlayer.removeInventoryItem('kaskswat', 1)
        SetPedPropIndex(GetPlayerPed(src), 0, 39, 0, true)
    end)
end)

ESX.RegisterUsableItem('magazynek', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    startProgress(src, 5, 'Otwierasz magazynek...', function()
        xPlayer.removeInventoryItem('magazynek', 1)
        if math.random(1, 100) >= 95 then
            TriggerClientEvent('esx:showNotification', src, 'Otworzyłeś magazynek i rozsypałeś wszystkie naboje!')
        else
            TriggerClientEvent('esx:showNotification', src, 'Poprawnie otworzono magazynek')
            xPlayer.addInventoryItem('ammo-9', 12)
        end
    end)
end)

ESX.RegisterUsableItem('cigarette', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if GetVehiclePedIsIn(GetPlayerPed(src), false) ~= 0 then
        xPlayer.showNotification('Nie możesz używać tego w pojeździe!')
        return
    end
    if xPlayer.getInventoryItem('lighter').count < 1 then
        TriggerClientEvent('esx:showNotification', src, 'Nie posiadasz zapalniczki!')
        return
    end
    startProgress(src, 6, 'Palenie papierosa...', function()
        xPlayer.removeInventoryItem('cigarette', 1)
        TriggerClientEvent('esx_basicneeds:takeSmoke', src, false, 'papierosa')
    end)
end)

ESX.RegisterUsableItem('joint', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if GetVehiclePedIsIn(GetPlayerPed(src), false) ~= 0 then
        xPlayer.showNotification('Nie możesz używać tego w pojeździe!')
        return
    end
    if xPlayer.getInventoryItem('lighter').count < 1 then
        TriggerClientEvent('esx:showNotification', src, 'Nie posiadasz zapalniczki!')
        return
    end
    startProgress(src, 8, 'Palenie jointa...', function()
        xPlayer.removeInventoryItem('joint', 1)
        TriggerClientEvent('esx_basicneeds:takeSmoke', src, false, 'jointa')
    end)
end)

ESX.RegisterUsableItem('krotkofalowka', function(source)
    TriggerClientEvent('pma-radio:toogle', source, 'krótkofalówkę')
end)

ESX.RegisterUsableItem('radio', function(source)
    TriggerClientEvent('pma-radio:toogle', source, 'radio')
end)

-- ============================================================================
-- PRZEDMIOTY JEDZENIA I PICIA
-- ============================================================================

local foodItems = {
    {name = 'bread', duration = 5, label = 'Jesz chleb...', effects = {hunger = 100000}, 
     notification = 'Zjadłeś/aś Chleb', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'prop_sandwich_01'}},
    
    {name = 'tost', duration = 6, label = 'Jesz tosta...', effects = {hunger = 200000}, 
     notification = 'Zjadłeś/aś Tosta', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'prop_sandwich_01'}},
    
    {name = 'sandwich', duration = 7, label = 'Jesz kanapkę...', effects = {hunger = 200000}, 
     notification = 'Zjadłeś/aś Kanapke', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'prop_sandwich_01'}},
    
    {name = 'hamburger', duration = 8, label = 'Jesz hamburgera...', effects = {hunger = 450000}, 
     notification = 'Zjadłeś/aś hamburgera', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'prop_cs_burger_01'}},
    
    {name = 'chocolate', duration = 3, label = 'Jesz czekoladę...', effects = {hunger = 100000}, 
     notification = 'Zjadłeś/aś czekoladę', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'prop_choc_ego'}},
    
    {name = 'orange', duration = 5, label = 'Jesz pomarańczę...', effects = {hunger = 50000}, 
     notification = 'Zjadłeś/aś soczystą pomarańczę', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'ng_proc_food_ornge1a'}},
    
    -- Batoniki i przekąski
    {name = 'snikkel_candy', duration = 4, label = 'Jesz batonika z orzechami...', effects = {hunger = 200000}, 
     notification = 'Zjadłeś/aś batonik z orzechami', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'prop_choc_meto'}},
    
    {name = 'twerks_candy', duration = 4, label = 'Jesz batonika czekoladowego...', effects = {hunger = 200000}, 
     notification = 'Zjadłeś/aś batonik z czekoladą', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'prop_choc_meto'}},
    
    {name = 'chipsy', duration = 4, label = 'Jesz chipsy...', effects = {hunger = 100000}, 
     notification = 'Zjadłeś/aś chipsy', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'prop_cs_crisps_01'}},
    
    {name = 'cupcake', duration = 5, label = 'Jesz babeczkę...', effects = {hunger = 100000}, 
     notification = 'Zjadłeś/aś babeczkę', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'ng_proc_food_ornge1a'}},
    
    -- Desery i ciasta
    {name = 'sernik', duration = 9, label = 'Jesz sernik...', effects = {hunger = 400000}, 
     notification = 'Zjadłeś/aś kawałek sernika – pycha!',
     animData = {type = 'eat', prop = 'prop_cs_cake'}},
    
    {name = 'brownie', duration = 7, label = 'Jesz brownie...', effects = {hunger = 300000}, 
     notification = 'Zjadłeś/aś brownie – czekoladowy raj!',
     animData = {type = 'eat', prop = 'prop_choc_meto'}},
    
    {name = 'ciasto_marchewkowe', duration = 8, label = 'Jesz ciasto marchewkowe...', effects = {hunger = 350000}, 
     notification = 'Zjadłeś/aś ciasto marchewkowe – słodko i zdrowo!',
     animData = {type = 'eat', prop = 'prop_cs_cake'}},
    
    {name = 'szarlotka', duration = 9, label = 'Jesz szarlotkę...', effects = {hunger = 400000}, 
     notification = 'Zjadłeś/aś szarlotkę z cynamonem – mniam!',
     animData = {type = 'eat', prop = 'prop_cs_cake'}},
    
    {name = 'ciasto_drozdzowe', duration = 10, label = 'Jesz ciasto drożdżowe...', effects = {hunger = 450000}, 
     notification = 'Zjadłeś/aś ciasto drożdżowe – domowe smaki!',
     animData = {type = 'eat', prop = 'prop_cs_cake'}},
    
    -- Restauracyjne jedzenie
    {name = 'uwu_budhabowl', duration = 12, label = 'Jesz Buddha Bowl...', effects = {hunger = 1000000}, 
     notification = 'Zjadłeś/aś Sałatkę', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_cs_salad'}},
    
    {name = 'uwu_chocsandy', duration = 10, label = 'Jesz czekoladowe ciasto...', effects = {hunger = 1000000}, 
     notification = 'Zjadłeś/aś Ciasto', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_cs_cake'}},
    
    {name = 'uwu_pancake2', duration = 11, label = 'Jesz naleśniki...', effects = {hunger = 1000000}, 
     notification = 'Zjadłeś/aś Naleśniki', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_cs_plate_01'}},
    
    {name = 'tokyo_sushi', duration = 10, label = 'Jesz sushi...', effects = {hunger = 1000000}, 
     notification = 'Zjadłeś/aś Sushi', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_cs_plate_01'}},
    
    {name = 'tokyo_daifuku', duration = 8, label = 'Jesz daifuku...', effects = {hunger = 1000000}, 
     notification = 'Zjadłeś/aś Daifuku', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_donut_01'}},
    
    {name = 'tokyo_onigiri', duration = 9, label = 'Jesz onigiri...', effects = {hunger = 1000000}, 
     notification = 'Zjadłeś/aś Onigiri', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_sandwich_01'}},
    
    {name = 'taco_tostadas', duration = 11, label = 'Jesz Tostadas de Pollo...', effects = {hunger = 1000000}, 
     notification = 'Zjadłeś/aś Tostadas de Pollo', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_taco_01'}},
    
    {name = 'tacos', duration = 9, label = 'Jesz tacos...', effects = {hunger = 500000}, 
     notification = 'Zjadłeś/aś tacos – ostre i soczyste!', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_taco_01'}},
    
    {name = 'tropikalna_salatka', duration = 10, label = 'Jesz tropikalną sałatkę...', effects = {hunger = 350000}, 
     notification = 'Zjadłeś/aś tropikalną sałatkę – świeże i egzotyczne!', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_cs_salad'}},
    
    {name = 'grillowany_losos', duration = 13, label = 'Jesz grillowanego łososia...', effects = {hunger = 600000}, 
     notification = 'Zjadłeś/aś grillowanego łososia – premium!', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_cs_steak'}},
    
    {name = 'hot_dog', duration = 7, label = 'Jesz hot doga...', effects = {hunger = 400000}, 
     notification = 'Zjadłeś/aś hot doga – klasyka uliczna!',
     animData = {type = 'eat', prop = 'prop_cs_hotdog_01'}},
    
    {name = 'nachosy', duration = 8, label = 'Jesz nachosy...', effects = {hunger = 300000}, 
     notification = 'Zjadłeś/aś nachosy z sosem – chrupiące!',
     animData = {type = 'eat', prop = 'prop_cs_crisps_01'}},
    
    {name = 'saszlyki', duration = 12, label = 'Jesz szaszłyki...', effects = {hunger = 550000}, 
     notification = 'Zjadłeś/aś szaszłyki – grillowane mięso!', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_cs_steak'}},
    
    {name = 'ocean_burger', duration = 12, label = 'Jesz Ocean Burgera...', effects = {hunger = 700000}, 
     notification = 'Zjadłeś/aś Ocean Burger – rybny hit!', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_cs_burger_01'}},
    
    {name = 'nuggetsy_frytki', duration = 11, label = 'Jesz nuggetsy z frytkami...', effects = {hunger = 600000}, 
     notification = 'Zjadłeś/aś nuggetsy z frytkami – fast-food!', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_cs_burger_01'}},
    
    {name = 'green_smoke_gnocchi', duration = 11, label = 'Jesz Green Smoke Gnocchi...', effects = {hunger = 500000}, 
     notification = 'Zjadłeś/aś Green Smoke Gnocchi – ziołowe delicje!', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_cs_plate_01'}},
    
    {name = 'blunt_burger', duration = 14, label = 'Jesz Blunt Burgera...', effects = {hunger = 800000}, 
     notification = 'Zjadłeś/aś Blunt Burger – mega sycący!', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_cs_burger_01'}},
    
    {name = 'kush_curry', duration = 12, label = 'Jesz Kush Curry...', effects = {hunger = 600000}, 
     notification = 'Zjadłeś/aś Kush Curry – ostre i aromatyczne!', statusType = 'company',
     animData = {type = 'eat', prop = 'prop_cs_bowl_01'}},
    
    -- Japońskie desery
    {name = 'mochi', duration = 5, label = 'Jesz mochi...', effects = {hunger = 200000}, 
     notification = 'Zjadłeś/aś mochi – kleiste i słodkie!',
     animData = {type = 'eat', prop = 'prop_donut_01'}},
    
    {name = 'cupcake_rozany', duration = 6, label = 'Jesz różanego cupcake...', effects = {hunger = 250000}, 
     notification = 'Zjadłeś/aś różany cupcake – delikatny!',
     animData = {type = 'eat', prop = 'ng_proc_food_ornge1a'}},
    
    {name = 'ciastko_hello_kitty', duration = 5, label = 'Jesz ciastko Hello Kitty...', effects = {hunger = 200000}, 
     notification = 'Zjadłeś/aś ciastko Hello Kitty – urocze!',
     animData = {type = 'eat', prop = 'prop_donut_02'}},
    
    -- Donuty
    {name = 'donut_klasyczny', duration = 5, label = 'Jesz donuta klasycznego...', effects = {hunger = 300000}, 
     notification = 'Zjadłeś/aś donuta klasycznego', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'prop_donut_01'}},
    
    {name = 'donut_czekoladowy', duration = 5, label = 'Jesz donuta czekoladowego...', effects = {hunger = 320000}, 
     notification = 'Zjadłeś/aś donuta czekoladowego', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'prop_donut_01'}},
    
    {name = 'donut_nadzienie', duration = 5, label = 'Jesz donuta z nadzieniem...', effects = {hunger = 320000}, 
     notification = 'Zjadłeś/aś donuta z nadzieniem', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'prop_donut_01'}},
    
    -- Muffiny
    {name = 'muffin_borowkowy', duration = 5, label = 'Jesz muffina borówkowego...', effects = {hunger = 350000}, 
     notification = 'Zjadłeś/aś muffina borówkowego', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'ng_proc_food_ornge1a'}},
    
    {name = 'muffin_czekoladowy', duration = 5, label = 'Jesz muffina czekoladowego...', effects = {hunger = 350000}, 
     notification = 'Zjadłeś/aś muffina czekoladowego', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'ng_proc_food_ornge1a'}},
    
    {name = 'muffin_waniliowy', duration = 5, label = 'Jesz muffina waniliowego...', effects = {hunger = 350000}, 
     notification = 'Zjadłeś/aś muffina waniliowego', requireStatus = 'hunger',
     animData = {type = 'eat', prop = 'ng_proc_food_ornge1a'}},

    -- Pearl
    {name = 'pearl_salad', duration = 5, label = 'Jesz sałatkę...', effects = {hunger = 300000}, 
    notification = 'Zjadłeś/aś sałatkę', statusType = 'company',
    animData = {type = 'eat', prop = 'ex_mp_h_acc_fruitbowl_02'}},
    
    {name = 'pearl_mussels', duration = 5, label = 'Jesz mule...', effects = {hunger = 300000}, 
    notification = 'Zjadłeś/aś mule', statusType = 'company',
    animData = {type = 'eat', prop = 'prop_cs_steak'}},
    
    {name = 'pearl_salmoncream', duration = 5, label = 'Jesz krem z łososia...', effects = {hunger = 300000}, 
    notification = 'Zjadłeś/aś krem z łososia!', statusType = 'company',
    animData = {type = 'eat', prop = 'prop_food_burg2'}},

    {name = 'pearl_codfish', duration = 10, label = 'Jesz smażonego dorsza...', effects = {hunger = 500000}, 
    notification = 'Zjadłeś/aś Smażonego dorsza – mega sycący!', statusType = 'company',
    animData = {type = 'eat', prop = 'prop_food_burg2'}},

    {name = 'pearl_cwelburger', duration = 10, label = 'Jesz kraboburgera...', effects = {hunger = 500000}, 
    notification = 'Zjadłeś/aś Kraboburger – mega sycący!', statusType = 'company',
    animData = {type = 'eat', prop = 'prop_cs_burger_01'}},

    -- Pizza
    {name = 'pizza_margherrita', duration = 10, label = 'Jesz pizzę...', effects = {hunger = 500000}, 
    notification = 'Zjadłeś/aś pizzę – mega sycąca!', statusType = 'company',
    animData = {type = 'eat', prop = 'v_res_tt_pizzaplate'}},
    
    {name = 'pizza_carbonara', duration = 10, label = 'Jesz carbonarę...', effects = {hunger = 500000}, 
    notification = 'Zjadłeś/aś carbonarę – mega sycąca!', statusType = 'company',
    animData = {type = 'eat', prop = 'prop_cs_bowl_01b'}},

    {name = 'pizza_bolognese', duration = 10, label = 'Jesz bolognese...', effects = {hunger = 500000}, 
    notification = 'Zjadłeś/aś bolognese – mega sycący!', statusType = 'company',
    animData = {type = 'eat', prop = 'prop_cs_bowl_01b'}},
    
    {name = 'pizza_lasagne', duration = 5, label = 'Jesz lasagne...', effects = {hunger = 300000}, 
    notification = 'Zjadłeś/aś lasange', statusType = 'company',
    animData = {type = 'eat', prop = 'prop_taco_01'}},

    {name = 'pizza_tiramisu', duration = 5, label = 'Jesz tiramisu...', effects = {hunger = 300000}, 
    notification = 'Zjadłeś/aś tiramisu', statusType = 'company',
    animData = {type = 'eat', prop = 'v_res_cakedome'}},
}

-- Napoje bezalkoholowe
local drinkItems = {
    -- Podstawowe napoje
    {name = 'water_bottle', duration = 4, label = 'Pijesz wodę...', effects = {thirst = 100000}, 
     notification = 'Wypiłeś/aś wodę', requireStatus = 'thirst',
     animData = {type = 'drink', prop = 'h4_prop_club_water_bottle'}},
    
    {name = 'cola', duration = 4, label = 'Pijesz Colę...', effects = {thirst = 100000}, 
     notification = 'Wypiłeś/aś Coca-Cole', requireStatus = 'thirst',
     animData = {type = 'drink', prop = 'prop_ecola_can'}},
    
    {name = 'icetea', duration = 5, label = 'Pijesz Ice-Tea...', effects = {thirst = 100000}, 
     notification = 'Wypiłeś/aś Ice-Tea', requireStatus = 'thirst',
     animData = {type = 'drink', prop = 'h4_prop_club_tonic_bottle'}},
    
    {name = 'milk', duration = 5, label = 'Pijesz mleko...', effects = {thirst = 100000}, 
     notification = 'Wypiłeś/aś mleko', requireStatus = 'thirst',
     animData = {type = 'drink', prop = 'v_res_tt_milk'}},
    
    {name = 'orange_juice', duration = 5, label = 'Pijesz sok pomarańczowy...', effects = {thirst = 50000}, 
     notification = 'Wypiłeś/aś świeży sok z pomarańczy', requireStatus = 'thirst',
     animData = {type = 'eat', prop = 'ng_proc_food_ornge1a'}},
    
    {name = 'kawa', duration = 5, label = 'Pijesz kawę...', effects = {thirst = 100000}, 
     notification = 'Wypiłeś kawę.', requireStatus = 'thirst',
     animData = {type = 'drink', prop = 'prop_orang_can_01'}},
    
    {name = 'tokyo_matcha', duration = 6, label = 'Pijesz Tokyo Matcha...', effects = {thirst = 500000}, 
     notification = 'Wypiłeś Matche, czujesz nagły przypływ energii.',
     animData = {type = 'drink', prop = 'prop_orang_can_01', addon = 'kawa'},
     customCallback = function(src, xPlayer)
         TriggerClientEvent('esx_basicneeds:startEnergyEffect', src, 600000)
     end},
    
    {name = 'redbull', duration = 4, label = 'Pijesz RedBulla...', 
     notification = 'Wypiłeś Redbulla, czujesz przypływ energii.',
     animData = {type = 'drink', prop = 'prop_orang_can_01', addon = 'kawa'},
     customCallback = function(src, xPlayer)
         TriggerClientEvent('esx_basicneeds:startEnergyEffect', src, 600000)
     end},
    
    {name = 'snus_arbuz', duration = 3, label = 'Wkładasz snusa arbuzowego...', 
     notification = 'Czujesz nagły przypływ energii.',
     animData = {type = 'drink', prop = 'prop_orang_can_01', addon = 'snus'}},
    
    {name = 'snus_owoce', duration = 3, label = 'Wkładasz snusa owocowego...', 
     notification = 'Czujesz nagły przypływ energii.',
     animData = {type = 'drink', prop = 'prop_orang_can_01', addon = 'snus'}},
    
    {name = 'snus_jagoda', duration = 3, label = 'Wkładasz snusa jagodowego...', 
     notification = 'Czujesz nagły przypływ energii.',
     animData = {type = 'drink', prop = 'prop_orang_can_01', addon = 'snus'}},
    
    -- Restauracyjne napoje
    {name = 'uwu_foamtea', duration = 7, label = 'Pijesz Foam Tea...', effects = {thirst = 1000000}, 
     notification = 'Wypiłeś Herbatę', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_coffee_cup'}},
    
    {name = 'tokyo_sokmango', duration = 7, label = 'Pijesz sok mango...', effects = {thirst = 1000000}, 
     notification = 'Wypiłeś Sok Mango', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_orang_can_01'}},
    
    {name = 'taco_horchata', duration = 8, label = 'Pijesz Horchata Fresca...', effects = {thirst = 1000000}, 
     notification = 'Zjadłeś/aś Horchata Fresca', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_orang_can_01'}},
    
    {name = 'taco_agua', duration = 7, label = 'Pijesz Agua de Jamaica...', effects = {thirst = 1000000}, 
     notification = 'Zjadłeś/aś Agua de Jamaica', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_orang_can_01'}},
    
    {name = 'lemoniada', duration = 6, label = 'Pijesz lemoniadę...', effects = {thirst = 400000}, 
     notification = 'Wypiłeś/aś lemoniadę – orzeźwiająca!',
     animData = {type = 'drink', prop = 'prop_orang_can_01'}},
    
    {name = 'ice_tea', duration = 6, label = 'Pijesz Ice Tea...', effects = {thirst = 300000}, 
     notification = 'Wypiłeś/aś Ice Tea – chłodząca herbata!',
     animData = {type = 'drink', prop = 'h4_prop_club_tonic_bottle'}},
    
    {name = 'coconout_kiss', duration = 8, label = 'Pijesz Coconout Kiss...', effects = {thirst = 500000}, 
     notification = 'Wypiłeś/aś Coconout Kiss – kokosowy pocałunek!', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_cocktail'}},
    
    {name = 'purple_haze_smoothie', duration = 7, label = 'Pijesz Purple Haze Smoothie...', effects = {thirst = 400000}, 
     notification = 'Wypiłeś/aś Purple Haze Smoothie – fioletowa energia!', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_orang_can_01'}},
    
    {name = 'sativa_sunrise', duration = 7, label = 'Pijesz Sativa Sunrise...', effects = {thirst = 350000}, 
     notification = 'Wypiłeś/aś Sativa Sunrise – poranny boost!', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_cocktail'}},
    
    {name = 'white_widow_elixir', duration = 8, label = 'Pijesz White Widow Elixir...', effects = {thirst = 500000}, 
     notification = 'Wypiłeś/aś White Widow Elixir – mistyczny!', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_whiskey_bottle'}},
    
    {name = 'bubble_tea', duration = 6, label = 'Pijesz Bubble Tea...', effects = {thirst = 300000}, 
     notification = 'Wypiłeś/aś Bubble Tea – bąbelkowa frajda!',
     animData = {type = 'drink', prop = 'prop_orang_can_01'}},
    
    {name = 'uwu_frappe', duration = 8, label = 'Pijesz UwU Frappé...', effects = {thirst = 400000}, 
     notification = 'Wypiłeś/aś UwU Frappé – słodki i puszysty!', statusType = 'company',
     animData = {type = 'drink', prop = 'brum_heartfrappe'}},
    
    {name = 'uwu_latte', duration = 7, label = 'Pijesz UwU Latte...', effects = {thirst = 350000}, 
     notification = 'Wypiłeś/aś UwU Latte – kawaii kawa!', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_coffee_cup'}},
    
    {name = 'herbata_matcha', duration = 6, label = 'Pijesz herbatę matcha...', effects = {thirst = 300000}, 
     notification = 'Wypiłeś/aś herbatę matcha – zielona energia!',
     animData = {type = 'drink', prop = 'prop_orang_can_01'}},
    
    {name = 'zielona_herbata', duration = 6, label = 'Pijesz Zieloną Herbatę...', effects = {thirst = 300000}, 
     notification = 'Wypiłeś/aś Zieloną Herbatę – zielona energia!', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_coffee_cup'}},

    -- Pearl
    {name = 'pearl_kawa', duration = 7, label = 'Pijesz kawę...', effects = {thirst = 300000}, 
     notification = 'Wypiłeś/aś Kawę', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_coffee_cup'}},
    
    {name = 'pearl_cola', duration = 7, label = 'Pijesz colę...', effects = {thirst = 300000}, 
     notification = 'Wypiłeś/aś Colę', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_ecola_can'}},
    
    {name = 'pearl_lemonade', duration = 8, label = 'Pijesz Lemoniadę...', effects = {thirst = 300000}, 
     notification = 'Wypiłeś/aś Lemoniadę', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_pinacolada'}},

    {name = 'pearl_virginmojito', duration = 7, label = 'Pijesz Virgin Mojito...', effects = {thirst = 500000}, 
     notification = 'Wypiłeś/aś Virgin Mojito', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_mojito'}},
    
    {name = 'pearl_cocktail1', duration = 7, label = 'Pijesz koktail mango–banan...', effects = {thirst = 500000}, 
     notification = 'Wypiłeś/aś Koktail mango–banan', statusType = 'company',
     animData = {type = 'drink', prop = 'm25_2_prop_m52_cocktail'}},
    
    {name = 'pearl_cocktail2', duration = 8, label = 'Pijesz koktail truskawka–arbuz...', effects = {thirst = 500000}, 
     notification = 'Wypiłeś/aś Koktail truskawka–arbuz', statusType = 'company',
     animData = {type = 'drink', prop = 'm25_2_prop_m52_cocktail'}},

    -- Pizza
    {name = 'pizza_espresso', duration = 7, label = 'Pijesz espresso...', effects = {thirst = 500000}, 
     notification = 'Wypiłeś/aś Espresso', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_coffee_cup'}},
    
    {name = 'pizza_cappuccino', duration = 7, label = 'Pijesz cappuccino...', effects = {thirst = 300000}, 
     notification = 'Wypiłeś/aś Colę', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_coffee_cup'}},
    
    {name = 'pizza_lemonsoda', duration = 8, label = 'Pijesz lemon Soda...', effects = {thirst = 300000}, 
     notification = 'Wypiłeś/aś Lemon Soda', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_pinacolada'}},

    {name = 'pizza_herbatacytrynowa', duration = 7, label = 'Pijesz herbatę cytrynową...', effects = {thirst = 500000}, 
     notification = 'Wypiłeś/aś Herbatę Cytrynową', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_orang_can_01'}},
    
    -- Kawy
    {name = 'espresso', duration = 5, label = 'Pijesz espresso...', effects = {hunger = 50000, thirst = 200000}, 
     notification = 'Wypiłeś/aś espresso', requireStatus = 'thirst',
     animData = {type = 'drink', prop = 'prop_coffee_cup'}},
    
    {name = 'cappuccino', duration = 6, label = 'Pijesz cappuccino...', effects = {hunger = 60000, thirst = 250000}, 
     notification = 'Wypiłeś/aś cappuccino', requireStatus = 'thirst',
     animData = {type = 'drink', prop = 'prop_coffee_cup'}},
    
    {name = 'latte', duration = 6, label = 'Pijesz latte...', effects = {hunger = 70000, thirst = 250000}, 
     notification = 'Wypiłeś/aś latte', requireStatus = 'thirst',
     animData = {type = 'drink', prop = 'prop_coffee_cup'}},
    
    {name = 'mocha', duration = 6, label = 'Pijesz mocha...', effects = {hunger = 80000, thirst = 250000}, 
     notification = 'Wypiłeś/aś mocha', requireStatus = 'thirst',
     animData = {type = 'drink', prop = 'prop_coffee_cup'}},
    
    {name = 'americano', duration = 5, label = 'Pijesz americano...', effects = {hunger = 50000, thirst = 250000}, 
     notification = 'Wypiłeś/aś americano', requireStatus = 'thirst',
     animData = {type = 'drink', prop = 'prop_coffee_cup'}},
    
    {name = 'flat_white', duration = 6, label = 'Pijesz flat white...', effects = {hunger = 70000, thirst = 250000}, 
     notification = 'Wypiłeś/aś flat white', requireStatus = 'thirst',
     animData = {type = 'drink', prop = 'prop_coffee_cup'}},
    
    {name = 'macchiato', duration = 6, label = 'Pijesz macchiato...', effects = {hunger = 60000, thirst = 220000}, 
     notification = 'Wypiłeś/aś macchiato', requireStatus = 'thirst',
     animData = {type = 'drink', prop = 'prop_coffee_cup'}},
}

-- Napoje alkoholowe
local alcoholItems = {
    {name = 'beer', duration = 6, label = 'Pijesz piwo...', effects = {drunk = true}, 
     notification = 'Wypiłeś/aś piwo',
     animData = {type = 'drink', prop = 'prop_cs_beer_bot_01'}},
    
    {name = 'whiskey', duration = 7, label = 'Pijesz whiskey...', effects = {drunk = true}, 
     notification = 'Wypiłeś/aś whiskey',
     animData = {type = 'drink', prop = 'prop_whiskey_bottle'}},
    
    {name = 'vodka', duration = 7, label = 'Pijesz wódkę...', effects = {drunk = true}, 
     notification = 'Wypiłeś/aś wódkę',
     animData = {type = 'drink', prop = 'prop_vodka_bottle'}},
    
    {name = 'vanilla_tequila', duration = 7, label = 'Pijesz tequilę...', effects = {drunk = true}, 
     notification = 'Wypiłeś/aś Tequila', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_whiskey_bottle'}},
    
    {name = 'vanilla_kastishoot', duration = 6, label = 'Pijesz Kasti Shoot...', effects = {drunk = true}, 
     notification = 'Wypiłeś/aś Kasti Shoot', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_whiskey_bottle'}},
    
    {name = 'vanilla_smerfowy', duration = 7, label = 'Pijesz Smerfowego...', effects = {drunk = true}, 
     notification = 'Wypiłeś/aś Smerfa', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_whiskey_bottle'}},
    
    {name = 'vanilla_krewoponenta', duration = 7, label = 'Pijesz Krew Oponenta...', effects = {drunk = true}, 
     notification = 'Wypiłeś/aś Krew Oponenta', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_whiskey_bottle'}},
    
    {name = 'vanilla_jackdaniels', duration = 7, label = 'Pijesz Jacka Danielsa...', effects = {drunk = true}, 
     notification = 'Wypiłeś/aś whiskey', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_whiskey_bottle'}},
    
    {name = 'mojito', duration = 8, label = 'Pijesz Mojito...', effects = {thirst = 350000, drunk = 150000}, 
     notification = 'Wypiłeś/aś Mojito – miętowy relaks!', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_cocktail'}},
    
    {name = 'sunset_punch', duration = 8, label = 'Pijesz Sunset Punch...', effects = {thirst = 450000, drunk = true}, 
     notification = 'Wypiłeś/aś Sunset Punch – tropikalny!', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_cocktail'}},
    
    {name = 'drink_karaibski', duration = 9, label = 'Pijesz Drink Karaibski...', effects = {thirst = 450000, drunk = 250000}, 
     notification = 'Wypiłeś/aś Drink Karaibski – rajski!', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_rum_bottle'}},
    
    {name = 'taco_margarita', duration = 8, label = 'Pijesz Margaritę...', effects = {thirst = 1000000}, 
     notification = 'Zjadłeś/aś Margarita Tradicional', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_cocktail'}},

    -- Pearl
    {name = 'pearl_teqsun', duration = 5, label = 'Pijesz Tequila Sunrise...', effects = {thirst = 300000, drunk = true}, 
     notification = 'Wypiłeś/aś Tequila Sunrise', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_tequsunrise'}},

    -- Pizza
    {name = 'pizza_prosecco', duration = 5, label = 'Pijesz Prosecco...', effects = {thirst = 300000, drunk = true}, 
     notification = 'Wypiłeś/aś Prosecco', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_cs_champ_flute'}},

    {name = 'pizza_amaretto', duration = 5, label = 'Pijesz Amaretto...', effects = {thirst = 300000, drunk = true}, 
     notification = 'Wypiłeś/aś Amaretto', statusType = 'company',
     animData = {type = 'drink', prop = 'prop_cs_champ_flute'}},
}

for _, item in ipairs(foodItems) do
    item.itemName = item.name
    registerFoodItem(item.name, item)
end

for _, item in ipairs(drinkItems) do
    item.itemName = item.name
    registerDrinkItem(item.name, item)
end

for _, item in ipairs(alcoholItems) do
    item.itemName = item.name
    registerDrinkItem(item.name, item)
end