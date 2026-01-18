Config = {}

Config.useModernUI = true               -- W marcu 2023 prace przeszły ogromną przeróbkę i interfejs został zmieniony. Ustaw na false, aby używać STAREGO nie wspieranego już interfejsu.
Config.splitReward = false          -- Ta opcja działa tylko gdy useModernUI jest false. Jeśli ta opcja jest true, wypłata to: (Config.OnePercentWorth * Progress ) / PartyCount, jeśli false to: (Config.OnePercentWorth * Progress)
Config.UseBuiltInNotifications = false   -- Ustaw na false jeśli chcesz używać stylu powiadomień swojego frameworka. W przeciwnym razie będą używane wbudowane nowoczesne powiadomienia.=

Config.letBossSplitReward = true                    -- Jeśli true, szef może zarządzać procentami nagród dla całej grupy w menu. Jeśli ustawisz na false, wszyscy otrzymają tę samą kwotę.
Config.multiplyRewardWhileWorkingInGroup = true     -- Jeśli false, nagroda pozostanie domyślna. Na przykład 1000$ za ukończenie całej pracy. Jeśli ustawisz na true, wypłata będzie zależeć od ilości graczy w grupie. Na przykład, jeśli za pełną pracę jest 1000$, a gracz będzie pracował w 4-osobowej grupie, nagroda wyniesie 4000$. (baseReward * partyCount)

Config.MailboxRenewalTime = 45000 * 60      -- Tylko jeden list może zostać pobrany z jednej skrzynki. To jest globalne, więc jeśli jeden gracz zbierze ze skrzynki, następny gracz nie będzie mógł już z niej wziąć. To jest czas odnowienia, w tym przypadku po 45 minutach będziesz mógł ponownie zbierać listy z tej konkretnej skrzynki
Config.SyncMailboxStatus = true        -- Jeśli true, to gdy jeden gracz zbierze listy z jednej skrzynki, drugi gracz zobaczy informację, że skrzynka jest pusta. Jeśli false, każdy gracz ma swój własny status skrzynek. 
Config.Props = {
    --Propsy z których można zbierać listy
    
    `prop_postbox_01a`,
    -- Dodaj więcej jeśli chcesz!
}

Config.UseTarget = true                        -- Zmień na true jeśli chcesz używać systemu celowania. Wszystkie ustawienia dotyczące systemu celowania są w pliku target.lua.
Config.RequiredJob = "postman"                     -- Ustaw na "none" jeśli nie chcesz używać prac. Jeśli używasz target, musisz ustawić parametr "job" wewnątrz każdego exportu w target.lua
Config.RequireJobAlsoForFriends = true          -- Jeśli false, tylko host musi mieć pracę, jeśli true to wszyscy z grupy muszą mieć Config.RequiredJob
Config.RequiredItem = "none"                    -- Wymagany przedmiot potrzebny do rozpoczęcia pracy. Ustaw na "none", jeśli nie chcesz używać RequiredItem
Config.RequireOneFriendMinimum = false          -- Ustaw na true jeśli chcesz zmusić graczy do tworzenia drużyn
Config.Scenario = "prop_human_parking_meter"    -- Animacja która odgrywa się podczas przeszukiwania skrzynki. Uwaga: to musi być Scenario, nie animacja
Config.JobVehicleModel = "17mov_PostmanCar"              -- Model pojazdu służbowego
Config.Price = 400                                -- 2$ za jeden list

Config.RequireWorkClothes = true                   -- Ustaw na true, aby zmieniać ubrania graczy za każdym razem gdy zaczynają pracę.
Config.RequireItemFromWholeTeam = true              -- Jeśli false, tylko host musi mieć wymagany przedmiot, w przeciwnym razie cała drużyna go potrzebuje.

Config.EnableVehicleTeleporting = true          -- Jeśli true, skrypt teleportuje hosta do pojazdu firmowego. Jeśli false, pojazd firmowy się pojawi, ale cały zespół musi wejść do samochodu ręcznie
Config.PenaltyAmount = 500                      -- Kara która jest nakładana gdy gracz kończy pracę bez pojazdu firmowego
Config.DontPayRewardWithoutVehicle = false      -- Ustaw na true jeśli nie chcesz płacić nagrody graczom którzy chcą zakończyć bez pojazdu firmowego (akceptując karę)
Config.DeleteVehicleWithPenalty = false         -- Usuń pojazd nawet jeśli nie jest pojazdem firmowym
Config.JobCooldown = 0 * 60 -- 10 * 60            -- 0 minut przerwy między wykonywaniem prac (w nawiasach przykład dla 10 minut)
Config.GiveKeysToAllLobby = true                -- Ustaw na false jeśli chcesz dawać klucze tylko twórcy grupy podczas rozpoczynania pracy
Config.ProgressBarOffset = "255px"                   -- Wartość w px przesunięcia licznika na ekranie
Config.ProgressBarAlign = "bottom-right"            -- Wyrównanie paska postępu

-- ^ Opcje: top-left, top-center, top-right, bottom-left, bottom-center, bottom-right

Config.RewardItemsToGive = {
    -- {
    --     item_name = "water",
    --     chance = 100,
    --     amountPerMailbox = 1,
    -- },
}

Config.RestrictBlipToRequiredJob = true            -- Ustaw na true, aby ukryć blip pracy dla graczy, którzy nie mają RequiredJob. Jeśli wymagana praca to "none", ta opcja nie będzie miała żadnego efektu.
Config.Blips = {                                -- Tutaj możesz skonfigurować blip firmy.
    [1] = {
        Sprite = 365,
        Color = 44,
        Scale = 0.8,
        Pos = vector3(-232.16, -915.15, 32.31),
        Label = 'Praca Listonosza'
    },
}

Config.MarkerSettings = {                       -- używane tylko gdy Config.UseTarget = false. Kolory markera. Active = gdy gracz stoi wewnątrz markera.
    Active = {
        r = 88, 
        g = 105,
        b = 255,
        a = 200,
    },
    UnActive = {
        r = 43,
        g = 57,
        b = 181,
        a = 200,
    }
}

Config.Locations = {                            -- Tutaj możesz zmienić wszystkie podstawowe lokalizacje pracy. 
    DutyToggle = {
        Coords = {
            vector3(-232.16, -915.15, 32.31),
        },
        CurrentAction = 'open_dutyToggle',
        CurrentActionMsg = 'Naciśnij ~INPUT_CONTEXT~ aby ~y~rozpocząć/zakończyć~s~ pracę.',
        type = 'duty',
        scale = {x = 1.0, y = 1.0, z = 1.0}
    },
    FinishJob = {
        Coords = {
            vector3(-276.66, -894.68, 31.08),
        },
        CurrentAction = 'finish_job',
        CurrentActionMsg = 'Naciśnij ~INPUT_CONTEXT~ aby ~y~zakończyć ~s~pracę.',
        scale = {x = 3.0, y = 3.0, z = 3.0}
    },

}

Config.SpawnPoint = vector4(-276.66, -894.68, 31.08, 337.31)  -- Punkt spawnu pojazdu
Config.EnableCloakroom = true                                 -- Ustaw na false jeśli chcesz ukryć przycisk "Szatnia" w WorkMenu

Config.Clothes = {
    male = {
        ["mask"] = {clotheId = 0, variation = 0},
        ["arms"] = {clotheId = 0, variation = 0},
        ["pants"] = {clotheId = 10, variation = 0},
        ["bag"] = {clotheId = 0, variation = 0},
        ["shoes"] = {clotheId = 36, variation = 0},
        ["t-shirt"] = {clotheId = 15, variation = 0},
        ["torso"] = {clotheId = 250, variation = 0},
        ["decals"] = {clotheId = 0, variation = 0},
        ["kevlar"] = {clotheId = 0, variation = 0},
    },
    
    female = {
        ["mask"] = {clotheId = 0, variation = 0},
        ["arms"] = {clotheId = 14, variation = 0},
        ["pants"] = {clotheId = 6, variation = 0},
        ["bag"] = {clotheId = 0, variation = 0},
        ["shoes"] = {clotheId = 0, variation = 0},
        ["t-shirt"] = {clotheId = 15, variation = 0},
        ["torso"] = {clotheId = 258, variation = 0},
        ["decals"] = {clotheId = 0, variation = 0},
        ["kevlar"] = {clotheId = 0, variation = 0},
    }
}

Config.Lang = {

    -- Tutaj możesz zmienić wszystkie tłumaczenia używane w client.lua i server.lua. Nie zapomnij przetłumaczyć tego również w plikach HTML i JS.

    -- Client
    ["no_permission"] = "Tylko właściciel grupy może to zrobić!",
    ["keybind"] = 'Interakcja z Markerem',
    ["too_far"] = "Twoja grupa rozpoczęła pracę, ale jesteś zbyt daleko od siedziby. Nadal możesz do nich dołączyć.",
    ["kicked"] = "Wyrzuciłeś %s z grupy",
    ["alreadyWorking"] = "Najpierw ukończ poprzednie zamówienie.",
    ["quit"] = "Opuściłeś zespół",
    ["cantSpawnVeh"] = "Miejsce spawnu ciężarówki jest zajęte.",
    ["nobodyNearby"] = "Nikogo nie ma w pobliżu",
    ["pickLetter"] = "Zbierz listy",
    ["checking"] = "Sprawdzasz skrzynkę pocztową",
    ["spawnpointOccupied"] = "Miejsce spawnu samochodu jest zajęte",
    ["notADriver"] = "Musisz być kierowcą pojazdu aby zakończyć pracę",
    ["cantInvite"] = "Aby móc zaprosić więcej osób, musisz najpierw zakończyć pracę",
    ["tutorial"] = "Praca polega na zbieraniu listów ze skrzynek pocztowych. Pospiesz się, jedna skrzynka może być opróżniona tylko raz na jakiś czas, nie pozwól konkurencji Cię wyprzedzić! Te skrzynki możesz znaleźć przy głównych drogach",
    ["wrongReward1"] = "Procent wypłaty powinien być między 0 a 100",
    ["wrongReward2"] = "Całkowity procent wszystkich wypłat przekroczył 100%",
    ["partyIsFull"] = "Nie udało się wysłać zaproszenia, twoja grupa jest pełna",
    ["inviteSent"] = "Zaproszenie wysłane!",
    ["cantLeaveLobby"] = "Nie możesz opuścić lobby podczas pracy. Najpierw zakończ pracę.",
    ["wrongVeh"] = "Twój ostatni pojazd nie jest pojazdem służbowym. Musisz prowadzić pojazd służbowy",
    
    -- Server
    ["isAlreadyHost"] = "Ten gracz prowadzi swój zespół.",
    ["isBusy"] = "Ten gracz już należy do innego zespołu.", 
    ["hasActiveInvite"] = "Ten gracz ma już aktywne zaproszenie od kogoś innego.",
    ["HaveActiveInvite"] = "Masz już aktywne zaproszenie do dołączenia do zespołu.",
    ["InviteDeclined"] = "Twoje zaproszenie zostało odrzucone.",
    ["InviteAccepted"] = "Twoje zaproszenie zostało przyjęte!",
    ["error"] = "Wystąpił problem z dołączaniem do zespołu. Spróbuj ponownie później.",
    ["kickedOut"] = "Zostałeś wyrzucony z zespołu!",
    ["reward"] = "Otrzymałeś wypłatę w wysokości $",
    ["RequireOneFriend"] = "Ta praca wymaga przynajmniej jednego członka zespołu",
    ["deposit"] = "Pobraliśmy kaucję za samochód",
    ["depositReturned"] = "Zwróciliśmy kaucję za samochód",
    ["empty"] = "Ktoś już zebrał listy z tej skrzynki, spróbuj ponownie później",
    ["collected"] = "Zebrałeś listy",
    ["broken"] = "Skrzynka pocztowa została uszkodzona. Nie można z niej zebrać listów",
    ["dontHaveReqItem"] = "Ty lub ktoś z twojego zespołu nie ma wymaganego przedmiotu do rozpoczęcia pracy",
    ["penalty"] = "Zapłaciłeś grzywnę w wysokości ",
    ["clientsPenalty"] = "Lider zespołu zaakceptował karę. Nie otrzymałeś wypłaty",
    ["notEverybodyHasRequiredJob"] = "Nie wszyscy twoi znajomi mają wymaganą pracę",
    ["someoneIsOnCooldown"] = "%s nie może teraz rozpocząć pracy (cooldown: %s)", 
    ["hours"] = "godz",
    ["minutes"] = "min",
    ["seconds"] = "sek",
    ["newBoss"] = "Poprzedni lider lobby opuścił serwer. Teraz jesteś liderem zespołu",
} 