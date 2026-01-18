return {
    ['moneywash_bon_1'] = {
        label = 'Bon do Pralni (50k)',
        weight = 5,
        stack = true
    },

    ['moneywash_bon_2'] = {
        label = 'Bon do Pralni (100k)',
        weight = 5,
        stack = true
    },

    ['moneywash_bon_3'] = {
        label = 'Bon do Pralni (200k)',
        weight = 5,
        stack = true
    },

    ['gasmask'] = {
        label = 'Maska gazowa',
        weight = 350,
        stack = true,
        close = true,
    },

    ["house_key"] = {
        label = "Klucz do domu",
        weight = 1,
        stack = true,
        close = true,
    },

    ['karta_zakladnika'] = {
        label = 'Karta zakładnika',
        weight = 500,
        stack = true
    },    

    ['daily_case'] = {
        label = 'Skrzynia Zadań',
        weight = 0,
        stack = true,
        server = { export = "esx_hud.openCase" },
    },

    ['photo'] = {
        label = 'Zdjęcie',
        weight = 10,
        stack = true,
        close = true,
        description = nil
    },

    ['processed_photo'] = {
        label = 'Obróbione zdjęcie',
        weight = 10,
        stack = true,
        close = true,
        description = nil
    },

    ['parachute'] = {
        allowArmed = true,
        label = 'Spadochron',
        weight = 5000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 10
        }
    },

    ['kabelki'] = {
        label = 'Kabelki do majstrowania',
        weight = 1000,
    },
    ['opaski'] = {
        label = 'Opaska Policyjna',
        weight = 1000,
    },
    ['klucz_do_opaski'] = {
        label = 'Klucz do opaski',
        weight = 1000,
    },
    ['nadajnik_gps'] = {
        label = 'Nadajnik GPS',
        weight = 500,
    },

    ['wedka'] = {
        allowArmed = true,
        label = 'Wędka',
        weight = 1000,
    },

    ['kaskswat'] = {
        allowArmed = true,
        label = 'Kask S.W.A.T.',
        weight = 3000,
    },

    ['strzykawka'] = {
        allowArmed = true,
        label = 'Strzykawka',
        weight = 2000,
    },

    ['obraz'] = {
        allowArmed = true,
        label = 'Obraz',
        weight = 3000,
    },

    ['bizuteria'] = {
        allowArmed = true,
        label = 'Biżuteria',
        weight = 2000,
    },

    ['figurka'] = {
        allowArmed = true,
        label = 'Figurka',
        weight = 5000,
    },

    ['zegarek'] = {
        allowArmed = true,
        label = 'Zegarek',
        weight = 500,
    },

    ['konsola'] = {
        allowArmed = true,
        label = 'Konsola',
        weight = 1500,
    },

    ['pustypendrive'] = {
        allowArmed = true,
        label = 'Pusty pendrive',
        weight = 100,
    },

    ['lockpick'] = {
        allowArmed = true,
        label = 'Wytrych',
        weight = 150,
        consume = 0.25,
    },

    ['money'] = {
        allowArmed = true,
        label = 'Pieniądze',
    },

    ['black_money'] = {
        allowArmed = true,
        label = 'Brudne pieniądze',
    },

    ['gps'] = {
        allowArmed = true,
        label = 'GPS',
        weight = 1000,
    },

    ['radio'] = {
        allowArmed = true,
        label = 'Radio',
        stack = true,
        weight = 1000,
        client = {
            usetime = 0,
            event = 'pma-radio:toogle'
        }
    },

    ['armour50pd'] = {
        allowArmed = true,
        label = 'Kamizelka 50% LSPD',
        weight = 2500,
        stack = true,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 5
        }
    },

    ['armour100pd'] = {
        allowArmed = true,
        label = 'Kamizelka 100% LSPD',
        weight = 5000,
        stack = true,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 5
        }
    },

    ['armour50'] = {
        allowArmed = true,
        label = 'Kamizelka 50%',
        weight = 2500,
        stack = true,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 5
        }
    },
    ['printer_document'] = {
		label = 'Dokument',
		weight = 10,
		stack = false,
		close = true,
		consume = 0,
		server = {
			export = 'p_dojjob.printer_document'
		}
	},

    ['armour100'] = {
        allowArmed = true,
        label = 'Kamizelka 100%',
        weight = 5000,
        stack = true,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 5
        }
    },

    ['bodycam'] = {
        label = 'Bodycam',
        weight = 100,
        stack = false,
    },

    ['desc_remover'] = {
        label = 'Zmywacz',
        weight = 100,
        stack = false,
    },

    ['clothing'] = {
        allowArmed = true,
        label = 'Ubrania',
        consume = 0,
    },

    ['mastercard'] = {
        allowArmed = true,
        label = 'Mastercard',
        stack = false,
        weight = 10,
    },

    ['scrapmetal'] = {
        allowArmed = true,
        label = 'Złom',
        weight = 80,
    },

    ['scratchcardbasic'] = {
        allowArmed = true,
        label = 'Zdrapka Basic',
        weight = 50,
    },

    ['scratchcardpremium'] = {
        allowArmed = true,
        label = 'Zdrapka Premium',
        weight = 50,
    },

    ['wiertlo'] = {
        allowArmed = true,
        label = 'Wiertło',
        weight = 3000,
    },

    ['weed'] = {
        allowArmed = true,
        label = 'Marihuana',
        weight = 250,
    },

    ['kabura'] = {
        allowArmed = true,
        label = 'Kabura',
        description = 'Pozwala w szybszy i wygodniejszy sposób dobyć broń krótką',
        weight = 1000,
    },

    ['cocaine'] = {
        allowArmed = true,
        label = 'Liść kokainy',
        weight = 250,
    },

    ['cocaine_packaged'] = {
        allowArmed = true,
        label = 'Kokaina (paczka)',
        weight = 500,
    },

    ['opium'] = {
        allowArmed = true,
        label = 'Mieszanka opium',
        weight = 250,
    },

    ['opium_packaged'] = {
        allowArmed = true,
        label = 'Zapakowane opium',
        weight = 500,
    },

    ['meth'] = {
        allowArmed = true,
        label = 'Metamfetamina',
        weight = 250,
    },

    ['meth_packaged'] = {
        allowArmed = true,
        label = 'Metamfetamina (paczka)',
        weight = 500,
        consume = 1,
    },

    ["phone"] = {
        label = "Telefon",
        weight = 190,
        stack = false,
        consume = 0,
        client = {
            export = "esx_menu.openPhone",
            remove = function()
                TriggerEvent("lb-phone:itemRemoved")
            end,
            add = function()
                TriggerEvent("lb-phone:itemAdded")
            end
        }
    },
    ['simcard'] = {
        label = 'Karta Sim',
        weight = 50,
        stack = false,
        close = true,
        consume = 0,
        server = { export = "simcards.simcard" },
        remove = function()
            TriggerEvent("lb-phone:itemRemoved")
        end,
    },
    
    ['stolen_phone'] = {
        label = 'Ukradziony Telefon',
        weight = 190,
        stack = true,
        consume = 0,
    },

    ['scuba_gear'] = {
        label = 'Strój nurka',
        weight = 5000,
        stack = false,
        consume = 0,
        client = {
            export = 'fiveplay-treasure.UseScubaGearItem',
        }
    },

    ['atm_bomb'] = {
        label = 'Bomba do bankomatu',
        weight = 1000,
        stack = true,
        close = true,
    },

    ['proch'] = {
        label = 'Proch strzelniczy',
        weight = 1,
        stack = true,
    },

    ['garbage'] = {
        label = 'Śmieci',
        weight = 20,
        stack = true,
    },

    ['nurek'] = {
        allowArmed = true,
        label = 'Zestaw do nurkowania',
        weight = 5000,
        stack = false,
        client = {
            export = 'esx_core.nurekWear'
        }
    },

    ['handcuffs'] = {
        allowArmed = true,
        label = 'Kajdanki',
        weight = 500,
    },

    ['shovel'] = {
        allowArmed = true,
        label = 'Szpadel',
        weight = 1000,
    },

    ['krotkofalowka'] = {
        allowArmed = true,
        label = 'Krótkofalówka',
        weight = 1000,
        client = {
            usetime = 0,
            event = 'pma-radio:toogle'
        }
    },

    ['magazynek'] = {
        allowArmed = true,
        label = 'Magazynek',
        weight = 140,
    },

    ['advancedrepairkit'] = {
        allowArmed = true,
        label = 'Zaawansowany zestaw naprawczy',
        weight = 1500,
        description = 'Zaawansowany zestaw do pełnej naprawy pojazdów (100%). Tylko dla mechaników. Użyj przez ox_target na pojazd.',
    },

    ['cleaningkit'] = {
        allowArmed = true,
        label = 'Zestaw czyszczący',
        weight = 500,
        description = 'Zestaw do czyszczenia pojazdów. Czyści brud i decale. Użyj przez ox_target na pojazd.',
    },


    ["mini_shovel"] = {
        label = "Łopateczka",
        weight = 50,
    },

    ["bulletcasings"] = {
        label = "Łuska",
        weight = 3,
    },

    ["fertilizer"] = {
        label = "Nawóz",
        weight = 50,
    },

    ["cannabis_seed"] = {
        label = "Nasionko Cannabis",
        weight = 50,
    },

    ['cannabis_top'] = {
        label = "Top Cannabis",
        weight = 100,
    },

    ['cannabis_gram'] = {
        label = "Cannabis (gram)",
        weight = 1,
        stack = true,
        close = true,
    },

    ['cannabis_joint'] = {
        label = "Joint Cannabis",
        weight = 2,
        stack = true,
        close = true,
    },

    ['grinder'] = {
        label = "Młynek do zioła",
        weight = 100,
    },

    ['ocb_paper'] = {
        label = "Bletka",
        weight = 10,
    },

    ['ogkush_seed'] = {
        label = "Nasionko OG Kush",
        weight = 50,
    },

    ['ogkush_top'] = {
        label = "Top OG Kush",
        weight = 100,
    },

    ['ogkush_gram'] = {
        label = "OG Kush (gram)",
        weight = 1,
        stack = true,
        close = true,
    },

    ['ogkush_joint'] = {
        label = "Joint OG Kush",
        weight = 2,
        stack = true,
        close = true,
    },
    
    ['oghaze_seed'] = {
        label = "Nasionko OG Haze",
        weight = 50,
    },

    ['oghaze_top'] = {
        label = "Top OG Haze",
        weight = 100,
    },

    ['oghaze_gram'] = {
        label = "OG Haze (gram)",
        weight = 1,
        stack = true,
        close = true,
    },

    ['oghaze_joint'] = {
        label = "Joint OG Haze",
        weight = 2,
        stack = true,
        close = true,
    },

    ['skladniki'] = {
        label = 'Składniki',
        weight = 100,
        stack = true,
        close = true,
    },

    ['pz'] = {
        label = 'Przyjęcie magazynowe',
        weight = 5,
        stack = true,
        close = true,
    },

    ['cigarette'] = {
        allowArmed = true,
        label = 'Papieros',
        weight = 2,
    },

    ['joint'] = {
        allowArmed = true,
        label = 'Joint',
        weight = 2,
    },

    ['bagniak_packaged'] = {
        allowArmed = true,
        label = 'Bagniak',
        weight = 2,
    },

    ['bread'] = {
        allowArmed = true,
        label = 'Chleb',
        weight = 200,
    },

    ['tost'] = {
        allowArmed = true,
        label = 'Tost',
        weight = 200,
    },

    ['sandwich'] = {
        allowArmed = true,
        label = 'Kanapka',
        weight = 200,
    },

    ['snikkel_candy'] = {
        allowArmed = true,
        label = 'Batonik z orzechami',
        weight = 200,
    },

    ['twerks_candy'] = {
        allowArmed = true,
        label = 'Batonik czekoladowy',
        weight = 200,
    },

    ['chipsy'] = {
        allowArmed = true,
        label = 'Chipsy',
        weight = 200,
    },

    ['cupcake'] = {
        allowArmed = true,
        label = 'Babeczka',
        weight = 200,
    },

    ['hamburger'] = {
        allowArmed = true,
        label = 'Hamburger',
        weight = 200,
    },

    ['chocolate'] = {
        allowArmed = true,
        label = 'Czekolada',
        weight = 200,
    },

    ['orange'] = {
        allowArmed = true,
        label = 'Pomarańcza',
        weight = 200,
    },

    ['paintingh'] = {
        label = 'Obraz C',
        weight = 10,
        stack = true,
        close = true,
    },

    ['paintingj'] = {
        label = 'Obraz D',
        weight = 10,
        stack = true,
        close = true,
    },

    ['paintingg'] = {
        label = 'Obraz G',
        weight = 10,
        stack = true,
        close = true,
    },

    ['paintingf'] = {
        label = 'Obraz F',
        weight = 10,
        stack = true,
        close = true,
    },

    ['vanwatch'] = {
        allowArmed = true,
        label = 'Zegarek Vangelico',
        weight = 150,
    },
    ['vanring'] = {
        allowArmed = true,
        label = 'Pierścionek Vangelico',
        weight = 100,
    },

    ['vannecklace2'] = {
        allowArmed = true,
        label = 'Mały Naszyjnik Vangelico',
        weight = 130,
    },

    ['vandiamond'] = {
        label = 'Diament Vangelico',
        weight = 10,
        stack = true,
        close = true,
    },

    ['vanpanther'] = {
        label = 'Panther Vangelico',
        weight = 10,
        stack = true,
        close = true,
    },

    ['vannecklace'] = {
        label = 'Naszyjnik Vangelico',
        weight = 10,
        stack = true,
        close = true,
    },

    ['vanbottle'] = {
        label = 'Butelka Vangelico',
        weight = 10,
        stack = true,
        close = true,
    },

    ['orange_juice'] = {
        allowArmed = true,
        label = 'Sok pomarańczowy',
        weight = 200,
    },

    ['cola'] = {
        allowArmed = true,
        label = 'Coca Cola',
        weight = 200,
    },

    ['icetea'] = {
        allowArmed = true,
        label = 'Ice Tea',
        weight = 200,
    },

    ['milk'] = {
        allowArmed = true,
        label = 'Mleko',
        weight = 200,
    },

    ['beer'] = {
        allowArmed = true,
        label = 'Piwo',
        weight = 250,
    },

    ['whiskey'] = {
        allowArmed = true,
        label = 'Whiskey',
        weight = 250,
    },

    ['vodka'] = {
        allowArmed = true,
        label = 'Wódka',
        weight = 250,
    },

    ['kawa_drink'] = {
        allowArmed = true,
        label = 'Kawa',
        weight = 200,
        client = { image = 'kawa.webp' },
    },

    ['kontrakt'] = {
        allowArmed = true,
        label = 'Kontrakt',
        weight = 100,
    },

    ['panic'] = {
        allowArmed = true,
        label = 'Panic Button',
    },

    ['lighter'] = {
        allowArmed = true,
        label = 'Zapalniczka',
        weight = 10,
    },

    ['medikit'] = {
        allowArmed = true,
        label = 'Apteczka',
        weight = 500,
    },

    ['szmata'] = {
        allowArmed = true,
        label = 'Szmata',
        weight = 10,
    },

    ['tasma'] = {
        allowArmed = true,
        label = 'Taśma',
        weight = 100,
    },

    ['bandage'] = {
        allowArmed = true,
        label = 'Bandaż medyczny',
        weight = 250,
    },

    ['lornetka'] = {
        allowArmed = true,
        label = 'Lornetka',
        weight = 1000,
    },

    ['gopro'] = {
        allowArmed = true,
        label = 'GoPro',
        weight = 500,
    },

    ['apteka_opatrunek'] = {
        allowArmed = true,
        label = 'Opatrunek',
        weight = 250,
    },

    ['apteka_bandaz'] = {
        allowArmed = true,
        label = 'Bandaż',
        weight = 500,
    },

    ['advancedlockpick'] = {
        allowArmed = true,
        label = 'Zaawansowany wytrych',
        weight = 300,
        consume = 0.01,
    },

    ['diamond_ring'] = {
        allowArmed = true,
        label = 'Pierścionek z diamentem',
        weight = 80,
    },

    ['rolex'] = {
        allowArmed = true,
        label = 'Rolex',
        weight = 80,
    },

    ['c4'] = {
        allowArmed = true,
        label = 'Ładunek C4',
        weight = 1000,
    },

    ['ladunektermiczny'] = {
        allowArmed = true,
        label = 'Ładunek termiczny',
        weight = 1000,
    },

    ['zakpendrive'] = {
        allowArmed = true,
        label = 'Zakodowany pendrive',
        weight = 200,
    },

    ['gold'] = {
        allowArmed = true,
        label = 'Złoto',
        weight = 50,
    },

    ['diamond'] = {
        allowArmed = true,
        label = 'Diament',
        weight = 50,
    },

    ['cutter'] = {
        allowArmed = true,
        label = 'Przecinarka',
        weight = 50,
    },

    ['vangelico_key'] = {
        allowArmed = true,
        label = 'Klucz jubilerski',
        weight = 50,
    },

    ['infected_disk'] = {
        allowArmed = true,
        label = 'Zainfekowany dysk',
        weight = 50,
    },

    ['goldwatch'] = {
        allowArmed = true,
        label = 'Złoty zegarek',
        weight = 50,
    },

    ['ring'] = {
        allowArmed = true,
        label = 'Złoty pierścień',
        weight = 50,
    },

    ['necklace'] = {
        allowArmed = true,
        label = 'Złoty naszyjnik',
        weight = 50,
    },

    ['malyszkielet'] = {
        allowArmed = true,
        label = 'Mały szkielet',
        weight = 50,
    },

    ['sprezyna'] = {
        allowArmed = true,
        label = 'Sprężyna',
        weight = 50,
    },

    ['bag'] = {
        allowArmed = false,
        label = 'Torba',
        weight = 500,
        stack = false,
        close = false,
        consume = 0,
        client = {
            export = 'esx_core.openBag'
        },
        buttons = {
            {
                label = 'Zmień nazwę',
                action = function(slotId)
                    TriggerEvent('esx_core:cl:bag:rename', slotId)
                end
            }
        }
    },

    ['malalufa'] = {
        allowArmed = true,
        label = 'Mała lufa',
        weight = 10,
    },

    ['spust'] = {
        allowArmed = true,
        label = 'Spust',
        weight = 10,
    },

    ['easter_egg'] = {
        allowArmed = true,
        label = 'Jajko wielkanocne',
        weight = 50,
    },

    ['czescmetalu'] = {
        allowArmed = true,
        label = 'Część metalu',
        weight = 10,
    },

    ['tshirt'] = {
        label = 'T-shirt',
        weight = 200,
        stack = true,
        close = true,
        client = {
            usetime = 0,
            event = 'esx_core:clothes:tshirt'
        }
    },

    ['bagcloth'] = {
        label = 'Torba',
        weight = 300,
        stack = true,
        close = true,
        server = {
            export = 'exotic_clothingbag.useBag'
        },
    },


    ['ears'] = {
        label = 'Ucho',
        weight = 50,
        stack = true,
        close = true,
        client = {
            usetime = 0,
            event = 'esx_core:clothes:ears'
        }
    },

    ['torso'] = {
        label = 'Tułów',
        weight = 500,
        stack = true,
        close = true,
        client = {
            usetime = 0,
            event = 'esx_core:clothes:torso'
        }
    },

    ['arms'] = {
        label = 'Rękawiczki',
        weight = 100,
        stack = true,
        close = true,
        client = {
            usetime = 0,
            event = 'esx_core:clothes:arms'
        }
    },

    ['jeans'] = {
        label = 'Spodnie',
        weight = 600,
        stack = true,
        close = true,
        client = {
            usetime = 0,
            event = 'esx_core:clothes:jeans'
        }
    },

    ['shoes'] = {
        label = 'Buty',
        weight = 800,
        stack = true,
        close = true,
        client = {
            usetime = 0,
            event = 'esx_core:clothes:shoes'
        }
    },

    ['mask'] = {
        label = 'Maska',
        weight = 100,
        stack = true,
        close = true,
        client = {
            usetime = 0,
            event = 'esx_core:clothes:mask'
        }
    },

    ['chain'] = {
        label = 'Łańcuch',
        weight = 150,
        stack = true,
        close = true,
        client = {
            usetime = 0,
            event = 'esx_core:clothes:chain'
        }
    },

    ['watchcloth'] = {
        label = 'Zegarek (ubranie)',
        weight = 100,
        stack = true,
        close = true,
        client = {
            usetime = 0,
            event = 'esx_core:clothes:watches'
        }
    },

    ['bracelet'] = {
        label = 'Bransoletka',
        weight = 50,
        stack = true,
        close = true,
        client = {
            usetime = 0,
            event = 'esx_core:clothes:bracelet'
        }
    },

    ['glasses'] = {
        label = 'Okulary',
        weight = 50,
        stack = true,
        close = true,
        client = {
            usetime = 0,
            event = 'esx_core:clothes:glasses'
        }
    },

    ['helmet'] = {
        label = 'Czapka',
        weight = 200,
        stack = true,
        close = true,
        client = {
            usetime = 0,
            event = 'esx_core:clothes:helmet'
        }
    },

    ['vest'] = {
        label = 'Kamizelka',
        weight = 400,
        stack = true,
        close = true,
        client = {
            usetime = 0,
            event = 'esx_core:clothes:vest'
        }
    },

    ['worek'] = {
        label = 'Worek na głowę',
        weight = 15,
        stack = true,
        allowArmed = true
    },

    ['kluczyki'] = {
        label = 'Klucz do auta',
        weight = 50,
        client = {
            export = 'esx_carkeys.kluczyki'
        },
    },

    ['roza'] = {
        label = 'Róża',
        weight = 50,
        client = {
            remove = function()
                for k, v in pairs(GetGamePool('CObject')) do
                    if IsEntityAttachedToEntity(cache.ped, v) then
                        SetEntityAsMissionEntity(v, true, true)
                        DeleteObject(v)
                        DeleteEntity(v)
                    end
                end
            end
        },
    },

    ['kocyk'] = {
        label = 'Kocyk',
        weight = 50,
        consume = 1,
    },

    ['kocyk_zestaw'] = {
        label = 'Zestaw z kocykiem',
        weight = 50,
        consume = 1,
    },

    ['spray'] = {
        label = 'Spray',
        weight = 250,
        close = true,
        consume = 0
    },

    ['cannabis'] = {
        label = 'Konopie',
        weight = 3,
        stack = true,
        close = true,
    },

    ['carokit'] = {
        label = 'Zestaw karoserii',
        weight = 3,
        stack = true,
        close = true,
    },

    ['carotool'] = {
        label = 'Narzędzia',
        weight = 2,
        stack = true,
        close = true,
    },

    ['clothe'] = {
        label = 'Tkanina',
        weight = 1,
        stack = true,
        close = true,
    },

    ['copper'] = {
        label = 'Miedź',
        weight = 1,
        stack = true,
        close = true,
    },

    ['cutted_wood'] = {
        label = 'Cięte drewno',
        weight = 1,
        stack = true,
        close = true,
    },

    
    ['wood'] = {
        label = 'Kawałki drzewa',
        weight = 1,
        stack = true,
        close = true,
    },

    ['essence'] = {
        label = 'Benzyna',
        weight = 1,
        stack = true,
        close = true,
    },

    ['fabric'] = {
        label = 'Materiał',
        weight = 1,
        stack = true,
        close = true,
    },

    ['fixtool'] = {
        label = 'Narzędzia naprawcze',
        weight = 2,
        stack = true,
        close = true,
    },

    ['gazbottle'] = {
        label = 'Butla z gazem',
        weight = 2,
        stack = true,
        close = true,
    },

    ['iron'] = {
        label = 'Żelazo',
        weight = 1,
        stack = true,
        close = true,
    },

    ['marijuana'] = {
        label = 'Marihuana',
        weight = 2,
        stack = true,
        close = true,
    },

    ['packaged_chicken'] = {
        label = 'Filet z kurczaka',
        weight = 1,
        stack = true,
        close = true,
    },

    ['packaged_plank'] = {
        label = 'Zapakowane deski',
        weight = 2000,
        stack = true,
        close = true,
    },

    ['petrol'] = {
        label = 'Ropa naftowa',
        weight = 1,
        stack = true,
        close = true,
    },

    ['petrol_raffin'] = {
        label = 'Przetworzona ropa',
        weight = 1,
        stack = true,
        close = true,
    },

    ['slaughtered_chicken'] = {
        label = 'Ubity kurczak',
        weight = 1,
        stack = true,
        close = true,
    },

    ['stone'] = {
        label = 'Kamień',
        weight = 1,
        stack = true,
        close = true,
    },

    ['washed_stone'] = {
        label = 'Umyty kamień',
        weight = 1,
        stack = true,
        close = true,
    },

    ['water_bottle'] = {
        label = 'Woda',
        weight = 1,
        stack = true,
        close = true,
    },

    ['wool'] = {
        label = 'Wełna',
        weight = 1,
        stack = true,
        close = true,
    },

    ['drizzlecream'] = {
        allowArmed = true,
        label = 'Lody',
        weight = 150,
    },

    ['uwu_pancake'] = {
        allowArmed = true,
        label = 'Naleśniki',
        weight = 200,
    },

    ['uwu_bubbletea'] = {
        allowArmed = true,
        label = 'Bubble Tea',
        weight = 250,
    },

    ['uwu_sushi'] = {
        allowArmed = true,
        label = 'Sushi',
        weight = 300,
    },

    ['uwu_sandy'] = {
        allowArmed = true,
        label = 'Kanapka',
        weight = 200,
    },

    ['uwu_burger'] = {
        allowArmed = true,
        label = 'Burger',
        weight = 350,
    },

    ['uwu_ramen'] = {
        allowArmed = true,
        label = 'Ramen',
        weight = 400,
    },

    ['uwu_boba'] = {
        allowArmed = true,
        label = 'Boba',
        weight = 250,
    },

    ['uwu_mochi'] = {
        allowArmed = true,
        label = 'Mochi',
        weight = 100,
    },

    ['uwu_pocky'] = {
        allowArmed = true,
        label = 'Pocky',
        weight = 50,
    },

    ['uwu_budhabowl'] = {
        allowArmed = true,
        label = 'Sałatka',
        weight = 250,
    },

    ['uwu_sourcream'] = {
        allowArmed = true,
        label = 'Krem',
        weight = 100,
    },

    ['uwu_tea'] = {
        allowArmed = true,
        label = 'Herbata',
        weight = 200,
    },

    ['uwu_chocolate'] = {
        allowArmed = true,
        label = 'Czekolada',
        weight = 100,
    },

    ['snus_arbuz'] = {
        allowArmed = true,
        label = 'Woreczek nikotynowy arbuz',
        weight = 5,
    },

    ['snus_owoce'] = {
        allowArmed = true,
        label = 'Woreczek nikotynowy owoce letnie',
        weight = 5,
    },

    ['snus_jagoda'] = {
        allowArmed = true,
        label = 'Woreczek nikotynowy jagoda',
        weight = 5,
    },

    ['redbull'] = {
        allowArmed = true,
        label = 'Red Bull',
        weight = 250,
    },

    ['uwu_chocsandy'] = {
        allowArmed = true,
        label = 'Ciastko',
        weight = 100,
    },

    ['uwu_foamtea'] = {
        allowArmed = true,
        label = 'Herbata piankowa',
        weight = 200,
    },

    ['uwu_pancake2'] = {
        allowArmed = true,
        label = 'Pancakes UwU',
        weight = 200,
    },

    ['tokyo_matcha'] = {
        allowArmed = true,
        label = 'Matcha',
        weight = 200,
    },

    ['tokyo_sokmango'] = {
        allowArmed = true,
        label = 'Sok mango',
        weight = 250,
    },

    ['tokyo_daifuku'] = {
        allowArmed = true,
        label = 'Daifuku',
        weight = 100,
    },

    ['tokyo_onigiri'] = {
        allowArmed = true,
        label = 'Onigiri',
        weight = 150,
    },

    ['tokyo_sushi'] = {
        allowArmed = true,
        label = 'Sushi',
        weight = 300,
    },

    ['tokyo_jagody'] = {
        allowArmed = true,
        label = 'Jagody goji',
        weight = 50,
    },

    ['tokyo_matcha1'] = {
        allowArmed = true,
        label = 'Matcha',
        weight = 200,
    },

    ['tokyo_mango'] = {
        allowArmed = true,
        label = 'Mango',
        weight = 200,
    },

    ['tokyo_maka'] = {
        allowArmed = true,
        label = 'Mąka',
        weight = 500,
    },

    ['tokyo_truskawki'] = {
        allowArmed = true,
        label = 'Truskawki',
        weight = 100,
    },

    ['tokyo_ryz'] = {
        allowArmed = true,
        label = 'Ryż',
        weight = 500,
    },

    ['tokyo_wodorosty'] = {
        allowArmed = true,
        label = 'Wodorosty',
        weight = 50,
    },

    ['tokyo_losos'] = {
        allowArmed = true,
        label = 'Łosoś',
        weight = 300,
    },

    ['taco_agua'] = {
        allowArmed = true,
        label = 'Agua de Jamaica',
        weight = 250,
    },

    ['taco_burrito'] = {
        allowArmed = true,
        consume = 1,
        label = 'Burrito Barbacoa',
        weight = 400,
    },

    ['taco_wanila'] = {
        allowArmed = true,
        label = 'Ekstrakt wanilii',
        weight = 50,
    },

    ['taco_lemon'] = {
        allowArmed = true,
        label = 'Esencja limonki',
        weight = 50,
    },

    ['taco_horchata'] = {
        allowArmed = true,
        label = 'Horchata Fresca',
        weight = 250,
    },

    ['taco_kurczak'] = {
        allowArmed = true,
        label = 'Kurczak',
        weight = 300,
    },

    ['taco_kwaity'] = {
        allowArmed = true,
        label = 'Kwiaty hibiskusa',
        weight = 20,
    },

    ['taco_margarita'] = {
        allowArmed = true,
        label = 'Margarita Tradicional',
        weight = 200,
    },

    ['taco_barbacoa'] = {
        allowArmed = true,
        label = 'Mięso barbacoa',
        weight = 300,
    },

    ['taco_ryz'] = {
        allowArmed = true,
        label = 'Ryż',
        weight = 500,
    },

    ['taco_salsa'] = {
        allowArmed = true,
        label = 'Salsa',
        weight = 100,
    },

    ['taco_ser'] = {
        allowArmed = true,
        label = 'Ser',
        weight = 200,
    },

    ['taco_sol'] = {
        allowArmed = true,
        label = 'Sól',
        weight = 50,
    },

    ['taco_syrop'] = {
        allowArmed = true,
        label = 'Syrop cukrowy',
        weight = 100,
    },

    ['taco_tostadas'] = {
        allowArmed = true,
        label = 'Tostadas de Pollo',
        weight = 350,
    },

    ['vanilla_tequila'] = {
        allowArmed = true,
        label = 'Tequila',
        weight = 750,
    },

    ['vanilla_spirytus'] = {
        allowArmed = true,
        label = 'Spirytus',
        weight = 750,
    },

    ['vanilla_bananowy'] = {
        allowArmed = true,
        label = 'Sok bananowy',
        weight = 250,
    },

    ['vanilla_kastishoot'] = {
        allowArmed = true,
        label = 'Kasti Shoot',
        weight = 200,
    },

    ['vanilla_aperolo'] = {
        allowArmed = true,
        label = 'Aperol',
        weight = 700,
    },

    ['vanilla_sokpomaranczowy'] = {
        allowArmed = true,
        label = 'Sok pomarańczowy',
        weight = 250,
    },

    ['vanilla_smerfowy'] = {
        allowArmed = true,
        label = 'Smerfowy potwór',
        weight = 200,
    },

    ['vanilla_martini'] = {
        allowArmed = true,
        label = 'Martini',
        weight = 200,
    },

    ['vanilla_sokjagodowy'] = {
        allowArmed = true,
        label = 'Sok jagodowy',
        weight = 250,
    },

    ['vanilla_krewoponenta'] = {
        allowArmed = true,
        label = 'Krew oponenta',
        weight = 200,
    },

    ['vanilla_soktruskawkowy'] = {
        allowArmed = true,
        label = 'Sok truskawkowy',
        weight = 250,
    },

    ['vanilla_jackdaniels'] = {
        allowArmed = true,
        label = 'Jack Daniels',
        weight = 750,
    },

    ['vanilla_jackdaniels1'] = {
        allowArmed = true,
        label = 'Jack Daniels',
        weight = 750,
    },

    ['vanilla_cocacola'] = {
        allowArmed = true,
        label = 'Coca Cola',
        weight = 330,
    },

    ['bmc_coffe'] = {
        allowArmed = true,
        label = 'Kawa',
        weight = 200,
        degrade = 0.1,
    },

    ['bmc_bratte'] = {
        allowArmed = true,
        label = 'Kawa mrożona',
        weight = 250,
    },

    ['bmc_cheesecake'] = {
        allowArmed = true,
        label = 'Sernik',
        weight = 300,
    },

    ['bmc_beancoffee'] = {
        allowArmed = true,
        label = 'Ziarna kawy',
        weight = 100,
    },

    ['bmc_milk'] = {
        allowArmed = true,
        label = 'Mleko',
        weight = 250,
    },

    ['bmc_icecube'] = {
        allowArmed = true,
        label = 'Kostki lodu',
        weight = 50,
    },

    ['bmc_rhinohorn'] = {
        allowArmed = true,
        label = 'Mąka',
        weight = 500,
    },

    ['bmc_sugar'] = {
        allowArmed = true,
        label = 'Cukier',
        weight = 200,
    },

    ['bmc_chocolate'] = {
        allowArmed = true,
        label = 'Czekolada',
        weight = 100,
    },

    ['atom_burger'] = {
        allowArmed = true,
        label = 'Atom Burger',
        weight = 350,
        degrade = 0.1,
    },

    ['atom_cola'] = {
        allowArmed = true,
        label = 'Atom Cola',
        weight = 330,
    },

    ['atom_fries'] = {
        allowArmed = true,
        label = 'Atom Frytki',
        weight = 200,
    },

    ['atom_milkshake'] = {
        allowArmed = true,
        label = 'Atom Milkshake',
        weight = 300,
    },

    ['atom_burgerbun'] = {
        allowArmed = true,
        label = 'Bułka',
        weight = 50,
    },

    ['atom_burgerpatty'] = {
        allowArmed = true,
        label = 'Wołowina',
        weight = 150,
    },

    ['atom_crushedice'] = {
        allowArmed = true,
        label = 'Lód',
        weight = 50,
    },

    ['atom_sugar'] = {
        allowArmed = true,
        label = 'Cukier',
        weight = 200,
    },

    ['atom_potatoes'] = {
        allowArmed = true,
        label = 'Ziemniaki',
        weight = 300,
    },

    ['atom_salt'] = {
        allowArmed = true,
        label = 'Sól',
        weight = 50,
    },

    ['atom_milk'] = {
        allowArmed = true,
        label = 'Mleko',
        weight = 250,
    },

    ['krawiec_clothes'] = {
        allowArmed = true,
        label = 'Ubrania',
        weight = 500,
    },

    ['krawiec_packetclothes'] = {
        allowArmed = true,
        label = 'Spakowane ubrania',
        weight = 1000,
    },

    ['bon10procent'] = {
        allowArmed = true,
        label = 'Bon 10% do sklepu',
        weight = 5,
    },

    ['bon_boost'] = {
        allowArmed = true,
        label = 'Bon boost limitka',
        weight = 5,
    },

    ['bon_firma'] = {
        allowArmed = true,
        label = 'Bon na firmę',
        weight = 5,
    },

    ['bon_gccoins'] = {
        allowArmed = true,
        label = 'Bon na 3000 GC',
        weight = 5,
    },

    ['bon_helikopter'] = {
        allowArmed = true,
        label = 'Bon na helikopter',
        weight = 5,
    },

    ['bon_jacht'] = {
        allowArmed = true,
        label = 'Bon na jacht',
        weight = 5,
    },

    ['bon_drugapostac'] = {
        allowArmed = true,
        label = 'Bon na drugą postać',
        weight = 5,
    },

    ['bon_customnumer'] = {
        allowArmed = true,
        label = 'Bon na własny numer telefonu',
        weight = 5,
    },

    ['bon_customrejka'] = {
        allowArmed = true,
        label = 'Bon na customową rejestrację',
        weight = 5,
    },

    ['bon_limitka_dzwiek'] = {
        allowArmed = true,
        label = 'Bon custom dźwięk auta',
        weight = 5,
    },

    ['bon_limitka'] = {
        allowArmed = true,
        label = 'Bon na limitowany pojazd',
        weight = 5,
    },

    ['bon_mafia'] = {
        allowArmed = true,
        label = 'Bon mafia',
        weight = 5,
    },

    ['bon_domlimitowany'] = {
        allowArmed = true,
        label = 'Bon na dom Limitowany',
        weight = 5,
    },

    ['bon_napady'] = {
        allowArmed = true,
        label = 'Bon napady',
        weight = 5,
    },

    ['bon_przepranie'] = {
        allowArmed = true,
        label = 'Bon pralnia',
        weight = 5,
    },

    ['fioletowypendrive'] = {
        allowArmed = true,
        label = 'Fioletowy pendrive',
        weight = 100,
    },

    ['zielonypendrive'] = {
        allowArmed = true,
        label = 'Zielony pendrive',
        weight = 100,
    },

    ['c4_bomb'] = {
        allowArmed = true,
        label = 'Bomba C4',
        weight = 30
    },

    ['big_drill'] = {
        allowArmed = true,
        label = 'Duże wiertło',
        weight = 5000
    },

    ['thermite'] = {
        allowArmed = true,
        label = 'Termit',
        weight = 50,
    },

    ['hack_usb'] = {
        allowArmed = true,
        label = 'USB z hackami',
        weight = 20,
    },

    ['pogo'] = {
        allowArmed = true,
        label = 'Pogo',
        weight = 50,
    },

    ['bottle'] = {
        allowArmed = true,
        label = 'Butelka',
        weight = 30,
    },

    ['panther'] = {
        allowArmed = true,
        label = 'Pantera',
        weight = 30,
    },

    ['artskull'] = {
        allowArmed = true,
        label = 'Artystyczna czaszka',
        weight = 40,
    },

    ['artegg'] = {
        allowArmed = true,
        label = 'Pomalowane jajko',
        weight = 15
    },

    ['denaturat'] = {
        allowArmed = true,
        label = 'Denaturat',
        weight = 20
    },

    ['clean_disk'] = {
        allowArmed = true,
        label = 'Dysk HDD',
        weight = 20
    },

    ['clean_pendrive'] = {
        allowArmed = true,
        label = 'Pendrive 16GB',
        weight = 15
    },

    ['karta_g6'] = {
        allowArmed = true,
        label = 'Karta pracownika G6',
        weight = 100
    },

    ['identyfikator_g6'] = {
        allowArmed = true,
        label = 'Identyfikator pracownika G6',
        weight = 250
    },

    ['ulepszony_ladunektermiczny'] = {
        allowArmed = true,
        label = 'Ulepszony ładunek termiczny',
        weight = 2500
    },

    ['alive_chicken'] = {
        label = 'Żywy kurczak',
        weight = 1500,
        stack = true,
        close = true,
    },

    ['blowpipe'] = {
        label = 'Palnik',
        weight = 2,
        stack = true,
        close = true,
    },

    ['dropflare'] = {
        label = 'Nieoznakowana flara',
        weight = 1000,
        stack = true,
        close = true,
        client = {
            export = 'esx_drops.useDropFlare'
        }
    },

    ['kreatyna'] = {
        label = 'Kreatyna',
        weight = 100,
        stack = true,
        close = true,
        description = 'Suplement wspierający wzrost siły',
        consume = 1,
        client = {
            image = 'kreatyna.png',
            export = 'esx_gym.useItem',
            usetime = 3,
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = {
                model = `xm3_prop_xm3_lsd_bottle_03a`,
                bone = 18905,
                pos = vec3(0.09, -0.065, 0.045),
                rot = vec3(-100.0, 0.0, -25.0)
            },
            disable = { move = false, car = true, combat = true }
        }
    },

    ['l_karnityna'] = {
        label = 'L-karnityna',
        weight = 100,
        stack = true,
        close = true,
        description = 'Suplement przyspieszający zdobywanie wytrzymałości',
        consume = 1,
        client = {
            image = 'l_karnityna.png',
            export = 'esx_gym.useItem',
            usetime = 3,
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = {
                model = `xm3_prop_xm3_bottle_pills_01a`,
                bone = 18905,
                pos = vec3(0.09, -0.065, 0.045),
                rot = vec3(-100.0, 0.0, -25.0)
            },
            disable = { move = false, car = true, combat = true }
        }
    },

    ['bialko'] = {
        label = 'Odżywka białkowa',
        weight = 250,
        stack = true,
        close = true,
        description = 'Uniwersalne wsparcie w budowie masy mięśniowej',
        consume = 1,
        client = {
            image = 'bialko.png',
            export = 'esx_gym.useItem',
            usetime = 4,
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = {
                model = `prop_ld_flow_bottle`,
                bone = 18905,
                pos = vec3(0.09, -0.065, 0.045),
                rot = vec3(-100.0, 0.0, -25.0)
            },
            disable = { move = false, car = true, combat = true }
        }
    },

    ['flipper'] = {
        label = 'Flipper ZERO',
        weight = 200,
        consume = 0,
        description = 'Takie małe a tak dużo możesz zdziałać...'
    },

    ["przykladowedanie"] = {
        label = "Przykładowe danie",
        allowArmed = true,
        weight = 200,
        degrade = 1440,
        close = true,
        consume = 1,
        client = {
            export = 'exotic_businesses.useItem',
            usetime = 3,
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = {
                model = `xm3_prop_xm3_lsd_bottle_03a`,
                bone = 18905,
                pos = vec3(0.09, -0.065, 0.045),
                rot = vec3(-100.0, 0.0, -25.0)
            },
            disable = { move = false, car = true, combat = true }
        }
    },
	--ryby
	["losos"] = { 
		label = "Łosoś", 
		weight = 0,
		client = { image = 'losos.png' },
	},
	["halibut"] = { 
		label = "Halibut", 
		weight = 0,
		client = { image = 'halibut.png' },
	},
	["tunczyk"] = { 
		label = "Tuńczyk", 
		weight = 0,
		client = { image = 'tunczyk.png' },
	},
	["makrela"] = { 
		label = "Makrela", 
		weight = 0,
		client = { image = 'makrela.png' },
	},
	["barwena"] = { 
		label = "Barwena", 
		weight = 0,
		client = { image = 'barwena.png' },
	},
	["pstrag"] = { 
		label = "Pstrąg", 
		weight = 0,
		client = { image = 'pstrag.png' },
	},
	["dorsz"] = { 
		label = "Dorsz", 
		weight = 0,
		client = { image = 'dorsz.png' },
	},
	["karmazyn"] = { 
		label = "Karmazyn", 
		weight = 0,
		client = { image = 'karmazyn.png' },
	},
	["miecznik"] = { 
		label = "Miecznik", 
		weight = 0,
		client = { image = 'miecznik.png' },
	},
	["rekin"] = { 
		label = "Mały Rekin", 
		weight = 0,
		client = { image = 'rekin.png' },
	},
	["sandacz"] = { 
		label = "Sandacz", 
		weight = 0,
		client = { image = 'sandacz.png' },
	},
	["fladra"] = { 
		label = "Flądra", 
		weight = 0,
		client = { image = 'fladra.png' },
	},
	["okon"] = { 
		label = "Okoń morski", 
		weight = 0,
		client = { image = 'okon.png' },
	},

	['rod_oak'] = {
		label   = 'Wędka dębowa',
		stack   = false,
		weight  = 500,
		consume = 0,
		metadata = {
			level  = 'Poziom',
			xp     = 'XP',
			nextxp = 'Do następnego',
			type   = 'Rodzaj'
		},
		client = { image = 'debowa.png' },
		server = { init = function(m) m.level=m.level or 1; m.xp=m.xp or 0; m.nextxp=m.nextxp or 100; m.type=1; return m end }
	},
	['rod_bamboo'] = {
		label = 'Wędka bambusowa', stack=false, weight=500, consume=0,
		metadata={level='Poziom',xp='XP',nextxp='Do następnego',type='Rodzaj'},
		client={image='bambusowa.png'},
		server={init=function(m) m.level=m.level or 1; m.xp=m.xp or 0; m.nextxp=m.nextxp or 100; m.type=2; return m end}
	},
	['rod_carbon'] = {
		label = 'Wędka karbonowa', stack=false, weight=500, consume=0,
		metadata={level='Poziom',xp='XP',nextxp='Do następnego',type='Rodzaj'},
		client={image='karbonowa.png'},
		server={init=function(m) m.level=m.level or 1; m.xp=m.xp or 0; m.nextxp=m.nextxp or 100; m.type=3; return m end}
	},
	['rod_titan'] = {
		label = 'Wędka tytanowa', stack=false, weight=500, consume=0,
		metadata={level='Poziom',xp='XP',nextxp='Do następnego',type='Rodzaj'},
		client={image='tytanowa.png'},
		server={init=function(m) m.level=m.level or 1; m.xp=m.xp or 0; m.nextxp=m.nextxp or 100; m.type=4; return m end}
	},
	['rod_mythic'] = {
		label = 'Wędka mityczna', stack=false, weight=500, consume=0,
		metadata={level='Poziom',xp='XP',nextxp='Do następnego',type='Rodzaj'},
		client={image='mityczna.png'},
		server={init=function(m) m.level=m.level or 1; m.xp=m.xp or 0; m.nextxp=0; m.type=5; return m end}
	},

	['clam'] = {
		label = 'Małża',
		weight = 0,
		stack = true,
		close = true,
		description = 'Świeżo złowiona małża. Może zawierać perłę.',
		client = {
			image = 'clam.png',
			usetime = 2500,
			export = 'exotic_rybak.openClam'
		}
	},

	['white_pearl'] = {
		label = 'Biała Perła',
		weight = 0,
		stack = true,
		description = 'Pospolita biała perła znaleziona w małży.',
		client = {
			image = 'white_pearl.png'
		}
	},

	['red_pearl'] = {
		label = 'Czerwona Perła',
		weight = 0,
		stack = true,
		description = 'Rzadka czerwona perła znaleziona w małży.',
		client = {
			image = 'red_pearl.png'
		}
	},

	['blue_pearl'] = {
		label = 'Niebieska Perła',
		weight = 0,
		stack = true,
		description = 'Bardzo rzadka niebieska perła znaleziona w małży.',
		client = {
			image = 'blue_pearl.png'
		}
	},

	['fishing_case'] = {
        label = 'Skrzynka Rybaka',
        weight = 500,
        stack = true,
        close = true,
        description = 'Tajemnicza skrzynka wyłowiona z morza. Kto wie co może się w niej znajdować?',
        client = {
            image = 'rybak_chest.png',
            usetime = 1000,
            export = 'exotic_rybak.openCase'
        }
    },

    -- Mechanik
    ["engine_oil"] = {
        label = "Olej silnikowy",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["tyre_replacement"] = {
        label = "Wymiana opon",
        weight = 12000,
        stack = true,
        close = true,
    },
    ["clutch_replacement"] = {
        label = "Wymiana sprzęgła",
        weight = 15000,
        stack = true,
        close = true,
    },
    ["air_filter"] = {
        label = "Filtr powietrza",
        weight = 100,
        stack = true,
        close = true,
    },
    ["spark_plug"] = {
        label = "Świeca zapłonowa",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["brakepad_replacement"] = {
        label = "Wymiana klocków hamulcowych",
        weight = 5000,
        stack = true,
        close = true,
    },
    ["suspension_parts"] = {
        label = "Części zawieszenia",
        weight = 20000,
        stack = true,
        close = true,
    },
    -- Silniki
    ["i4_engine"] = {
        label = "Silnik I4",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["v6_engine"] = {
        label = "Silnik V6",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["v8_engine"] = {
        label = "Silnik V8",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["v12_engine"] = {
        label = "Silnik V12",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["turbocharger"] = {
        label = "Turbosprężarka",
        weight = 1000,
        stack = true,
        close = true,
    },
    -- Silniki elektryczne
    ["ev_motor"] = {
        label = "Silnik elektryczny",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["ev_battery"] = {
        label = "Bateria EV",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["ev_coolant"] = {
        label = "Płyn chłodzący EV",
        weight = 1000,
        stack = true,
        close = true,
    },
    -- Układy napędowe
    ["awd_drivetrain"] = {
        label = "Napęd AWD",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["rwd_drivetrain"] = {
        label = "Napęd RWD",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["fwd_drivetrain"] = {
        label = "Napęd FWD",
        weight = 1000,
        stack = true,
        close = true,
    },
    -- Części tuningowe
    ["slick_tyres"] = {
        label = "Opony slicki",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["semi_slick_tyres"] = {
        label = "Opony semi-slicki",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["offroad_tyres"] = {
        label = "Opony terenowe",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["drift_tuning_kit"] = {
        label = "Zestaw do driftu",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["ceramic_brakes"] = {
        label = "Hamulce ceramiczne",
        weight = 1000,
        stack = true,
        close = true,
    },
    -- Części kosmetyczne
    ["lighting_controller"] = {
        label = "Kontroler oświetlenia",
        weight = 100,
        stack = true,
        close = true,
        client = {
            event = "jg-mechanic:client:show-lighting-controller",
        }
    },
    ["stancing_kit"] = {
        label = "Zestaw do stancingu",
        weight = 100,
        stack = true,
        close = true,
        client = {
            event = "jg-mechanic:client:show-stancer-kit",
        }
    },
    ["cosmetic_part"] = {
        label = "Części kosmetyczne",
        weight = 100,
        stack = true,
        close = true,
    },
    ["respray_kit"] = {
        label = "Zestaw do malowania",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["vehicle_wheels"] = {
        label = "Komplet kół",
        weight = 25000,
        stack = true,
        close = true,
    },
    ["tyre_smoke_kit"] = {
        label = "Zestaw dymu z opon",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["bulletproof_tyres"] = {
        label = "Opony kuloodporne",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["extras_kit"] = {
        label = "Zestaw dodatków",
        weight = 1000,
        stack = true,
        close = true,
    },
    -- Nitro i czyszczenie
    ["nitrous_bottle"] = {
        label = "Butla z nitro",
        weight = 5000,
        stack = true,
        close = true,
        client = {
            event = "jg-mechanic:client:use-nitrous-bottle",
        }
    },
    ["empty_nitrous_bottle"] = {
        label = "Pusta butla z nitro",
        weight = 2000,
        stack = true,
        close = true,
    },
    ["nitrous_install_kit"] = {
        label = "Zestaw do montażu nitro",
        weight = 1000,
        stack = true,
        close = true,
    },
    ["cleaning_kit"] = {
        label = "Zestaw czyszczący",
        weight = 1000,
        stack = true,
        close = true,
        client = {
            event = "jg-mechanic:client:clean-vehicle",
        }
    },
    ["repair_kit"] = {
        label = "Zestaw naprawczy",
        weight = 1000,
        stack = true,
        close = true,
        client = {
            event = "jg-mechanic:client:repair-vehicle",
        }
    },
    ["duct_tape"] = {
        label = "Taśma klejąca",
        weight = 1000,
        stack = true,
        close = true,
        client = {
            event = "jg-mechanic:client:use-duct-tape",
        }
    },
    -- Części wydajnościowe
    ["performance_part"] = {
        label = "Części wydajnościowe",
        weight = 1000,
        stack = true,
        close = true,
    },
    -- Tablet mechanika
    ["mechanic_tablet"] = {
        label = "Tablet mechanika",
        weight = 500,
        stack = false,
        close = true,
        client = {
            event = "jg-mechanic:client:use-tablet",
        }
    },
    -- Skrzynia biegów
    ["manual_gearbox"] = {
        label = "Skrzynia biegów manualna",
        weight = 30000,
        stack = true,
        close = true,
    },

    ['crime_tablet'] = {
        label = 'Tablet Crime',
        weight = 500,
        type = 'item',
        image = 'tablet.png', -- Optional, if you want an image for it
        useable = true,
        description = 'Tablet do różnorodnych zadań związanych z przestępczością.',
        client = {
        event = 'op-crime:openCrimeTablet'
        }
    },
    ['rope'] = {
        label = "Lina",
        weight = 250,
        client = {
        event = "op-crime:openHandcuffsMenu",
        }
    },
    ['spray_remover'] = {
        label = "Zmywacz do sprayu",
        weight = 250,
        client = {
            event = "op-crime:useRemover",
        }
    },
    ['spray_can'] = {
        label = "Spray",
        weight = 300,
        description = 'Spray używany do przejmowania stref gangowych',
        client = {
            event = "op-crime:useSpray",
        }
    },

    ['police_stormram'] = {
        label = 'Taran policyjny',
        weight = 5000,
        stack = true,
        close = true,
    },


--------------------------------------------------------------------------------------------------------------
--                  /$$   /$$ /$$      /$$ /$$   /$$        /$$$$$$   /$$$$$$  /$$$$$$$$ /$$$$$$$$
--                 | $$  | $$| $$  /$ | $$| $$  | $$       /$$__  $$ /$$__  $$| $$_____/| $$_____/
--                 | $$  | $$| $$ /$$$| $$| $$  | $$      | $$  \__/| $$  \ $$| $$      | $$      
--                 | $$  | $$| $$/$$ $$ $$| $$  | $$      | $$      | $$$$$$$$| $$$$$   | $$$$$   
--                 | $$  | $$| $$$$_  $$$$| $$  | $$      | $$      | $$__  $$| $$__/   | $$__/   
--                 | $$  | $$| $$$/ \  $$$| $$  | $$      | $$    $$| $$  | $$| $$      | $$      
--                 |  $$$$$$/| $$/   \  $$|  $$$$$$/      |  $$$$$$/| $$  | $$| $$      | $$$$$$$$
--                  \______/ |__/     \__/ \______/        \______/ |__/  |__/|__/      |________/                                                                             
--------------------------------------------------------------------------------------------------------------

    ['mleko'] = {label = 'Mleko', weight = 100, stack = true, close = true},
    ['syrop_truskawkowy'] = {label = 'Syrop Truskawkowy', weight = 50, stack = true, close = true},
    ['kulki_tapioki'] = {label = 'Kulki Tapioki', weight = 50, stack = true, close = true},
    ['lod'] = {label = 'Lód', weight = 20, stack = true, close = true},
    ['espresso'] = {label = 'Espresso', weight = 50, stack = true, close = true},
    ['smietanka'] = {label = 'Śmietanka', weight = 50, stack = true, close = true},
    ['posypka'] = {label = 'Posypka', weight = 20, stack = true, close = true},
    ['kawa'] = {label = 'Kawa', weight = 50, stack = true, close = true},
    ['pianka'] = {label = 'Pianka', weight = 20, stack = true, close = true},
    ['matcha'] = {label = 'Matcha', weight = 50, stack = true, close = true},
    ['ciasto_ryzowe'] = {label = 'Ciasto Ryżowe', weight = 50, stack = true, close = true},
    ['pasta_fasolowa'] = {label = 'Pasta Fasolowa', weight = 50, stack = true, close = true},
    ['cukier_puder'] = {label = 'Cukier Puder', weight = 20, stack = true, close = true},
    ['ciasto'] = {label = 'Ciasto', weight = 50, stack = true, close = true},
    ['krem_rozany'] = {label = 'Krem Różany', weight = 50, stack = true, close = true},
    ['papilotka'] = {label = 'Papilotka', weight = 10, stack = true, close = true},
    ['lukier_rozowy'] = {label = 'Lukier Różowy', weight = 20, stack = true, close = true},
    --szamka vvv
    ['bubble_tea'] = {label = 'Bubble Tea', weight = 200, stack = true, close = true},
    ['uwu_frappe'] = {label = 'UwU Frappé', weight = 250, stack = true, close = true},
    ['uwu_latte'] = {label = 'UwU Latte', weight = 200, stack = true, close = true},
    ['herbata_matcha'] = {label = 'Herbata Matcha', weight = 150, stack = true, close = true},
    ['mochi'] = {label = 'Mochi', weight = 100, stack = true, close = true},
    ['cupcake_rozany'] = {label = 'Cupcake Różany', weight = 120, stack = true, close = true},
    ['ciastko_hello_kitty'] = {label = 'Ciastko Hello Kitty', weight = 120, stack = true, close = true},

--------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------
--          /$$      /$$ /$$   /$$ /$$$$$$ /$$$$$$$$ /$$$$$$$$       /$$      /$$ /$$$$$$ /$$$$$$$   /$$$$$$  /$$      /$$
--         | $$  /$ | $$| $$  | $$|_  $$_/|__  $$__/| $$_____/      | $$  /$ | $$|_  $$_/| $$__  $$ /$$__  $$| $$  /$ | $$
--         | $$ /$$$| $$| $$  | $$  | $$     | $$   | $$            | $$ /$$$| $$  | $$  | $$  \ $$| $$  \ $$| $$ /$$$| $$
--         | $$/$$ $$ $$| $$$$$$$$  | $$     | $$   | $$$$$         | $$/$$ $$ $$  | $$  | $$  | $$| $$  | $$| $$/$$ $$ $$
--         | $$$$_  $$$$| $$__  $$  | $$     | $$   | $$__/         | $$$$_  $$$$  | $$  | $$  | $$| $$  | $$| $$$$_  $$$$
--         | $$$/ \  $$$| $$  | $$  | $$     | $$   | $$            | $$$/ \  $$$  | $$  | $$  | $$| $$  | $$| $$$/ \  $$$
--         | $$/   \  $$| $$  | $$ /$$$$$$   | $$   | $$$$$$$$      | $$/   \  $$ /$$$$$$| $$$$$$$/|  $$$$$$/| $$/   \  $$
--         |__/     \__/|__/  |__/|______/   |__/   |________/      |__/     \__/|______/|_______/  \______/ |__/     \__/
                                                                                                                                                                                                                                                                                                                  
--------------------------------------------------------------------------------------------------------------

    ['borowki'] = {label = 'Borówki', weight = 30, stack = true, close = true},
    ['banan'] = {label = 'Banan', weight = 30, stack = true, close = true},
    ['lawenda'] = {label = 'Lawenda', weight = 10, stack = true, close = true},
    ['olej_cbd'] = {label = 'Olej CBD', weight = 20, stack = true, close = true},
    ['mleko_migdalowe'] = {label = 'Mleko Migdałowe', weight = 50, stack = true, close = true},
    ['sok_pomaranczowy'] = {label = 'Świeży Sok z Pomarańczy', weight = 40, stack = true, close = true},
    ['marakuja'] = {label = 'Marakuja', weight = 30, stack = true, close = true},
    ['syrop_konopny'] = {label = 'Syrop Konopny', weight = 20, stack = true, close = true},
    ['mieta'] = {label = 'Mięta', weight = 5, stack = true, close = true},
    ['zielona_herbata'] = {label = 'Zielona Herbata', weight = 20, stack = true, close = true},
    ['imbir'] = {label = 'Imbir', weight = 10, stack = true, close = true},
    ['cytryna'] = {label = 'Cytryna', weight = 10, stack = true, close = true},
    ['miod'] = {label = 'Miód', weight = 20, stack = true, close = true},
    ['gnocchi'] = {label = 'Gnocchi', weight = 30, stack = true, close = true},
    ['maslo_cbd'] = {label = 'Masło CBD', weight = 20, stack = true, close = true},
    ['szalwia'] = {label = 'Szałwia', weight = 5, stack = true, close = true},
    ['pistacje'] = {label = 'Pistacje', weight = 15, stack = true, close = true},
    ['pesto_konopne'] = {label = 'Pesto Konopne', weight = 20, stack = true, close = true},
    ['ser_weganski'] = {label = 'Ser Wegański', weight = 20, stack = true, close = true},
    ['jackfruit'] = {label = 'Jackfruit', weight = 30, stack = true, close = true},
    ['makas_konopna'] = {label = 'Mąka Konopna', weight = 20, stack = true, close = true},
    ['mleko_kokosowe'] = {label = 'Mleko Kokosowe', weight = 50, stack = true, close = true},
    ['warzywa'] = {label = 'Warzywa', weight = 40, stack = true, close = true},
    ['ryz_jasminowy'] = {label = 'Ryż Jaśminowy', weight = 50, stack = true, close = true},

    -- Gotowe produkty
    ['purple_haze_smoothie'] = {label = 'Purple Haze Smoothie', weight = 200, stack = true, close = true},
    ['sativa_sunrise'] = {label = 'Sativa Sunrise', weight = 200, stack = true, close = true},
    ['white_widow_elixir'] = {label = 'White Widow Elixir', weight = 200, stack = true, close = true},
    ['green_smoke_gnocchi'] = {label = 'Green Smoke Gnocchi', weight = 300, stack = true, close = true},
    ['blunt_burger'] = {label = 'Blunt Burger', weight = 400, stack = true, close = true},
    ['kush_curry'] = {label = 'Kush Curry', weight = 350, stack = true, close = true},

--------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------
--          /$$$$$$$   /$$$$$$  /$$   /$$  /$$$$$$  /$$      /$$  /$$$$$$        /$$      /$$  /$$$$$$  /$$      /$$  /$$$$$$   /$$$$$$ 
--         | $$__  $$ /$$__  $$| $$  | $$ /$$__  $$| $$$    /$$$ /$$__  $$      | $$$    /$$$ /$$__  $$| $$$    /$$$ /$$__  $$ /$$__  $$
--         | $$  \ $$| $$  \ $$| $$  | $$| $$  \ $$| $$$$  /$$$$| $$  \ $$      | $$$$  /$$$$| $$  \ $$| $$$$  /$$$$| $$  \ $$| $$  \__/
--         | $$$$$$$ | $$$$$$$$| $$$$$$$$| $$$$$$$$| $$ $$/$$ $$| $$$$$$$$      | $$ $$/$$ $$| $$$$$$$$| $$ $$/$$ $$| $$$$$$$$|  $$$$$$ 
--         | $$__  $$| $$__  $$| $$__  $$| $$__  $$| $$  $$$| $$| $$__  $$      | $$  $$$| $$| $$__  $$| $$  $$$| $$| $$__  $$ \____  $$
--         | $$  \ $$| $$  | $$| $$  | $$| $$  | $$| $$\  $ | $$| $$  | $$      | $$\  $ | $$| $$  | $$| $$\  $ | $$| $$  | $$ /$$  \ $$
--         | $$$$$$$/| $$  | $$| $$  | $$| $$  | $$| $$ \/  | $$| $$  | $$      | $$ \/  | $$| $$  | $$| $$ \/  | $$| $$  | $$|  $$$$$$/
--         |_______/ |__/  |__/|__/  |__/|__/  |__/|__/     |__/|__/  |__/      |__/     |__/|__/  |__/|__/     |__/|__/  |__/ \______/ 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
--------------------------------------------------------------------------------------------------------------
    -- Jedzenie
    ['tortilla'] = {label = 'Tortilla', weight = 50, stack = true, close = true},
    ['mieso_mielone'] = {label = 'Mięso Mielone', weight = 80, stack = true, close = true},
    ['ser'] = {label = 'Ser', weight = 40, stack = true, close = true},
    ['salata'] = {label = 'Sałata', weight = 20, stack = true, close = true},
    ['sos_mango_lime'] = {label = 'Sos Mango-Lime', weight = 20, stack = true, close = true},
    ['bulka'] = {label = 'Bułka', weight = 40, stack = true, close = true},
    ['kielbasa'] = {label = 'Kiełbasa', weight = 60, stack = true, close = true},
    ['cebula_mango'] = {label = 'Cebula z Mango', weight = 20, stack = true, close = true},
    ['chipsy_nacho'] = {label = 'Chipsy Nacho', weight = 50, stack = true, close = true},
    ['ser_cheddar'] = {label = 'Ser Cheddar', weight = 40, stack = true, close = true},
    ['salsa_pomidorowa'] = {label = 'Salsa Pomidorowa', weight = 20, stack = true, close = true},
    ['kawalki_kurczaka'] = {label = 'Kawałki Kurczaka', weight = 80, stack = true, close = true},
    ['ananas'] = {label = 'Ananas', weight = 30, stack = true, close = true},
    ['papryka_czerwona'] = {label = 'Papryka Czerwona', weight = 20, stack = true, close = true},
    ['kotlet_rybny'] = {label = 'Kotlet z Ryby', weight = 80, stack = true, close = true},
    ['sos_majonez_cytryna'] = {label = 'Sos Majonez-Cytryna', weight = 20, stack = true, close = true},
    ['frytki_batata'] = {label = 'Frytki z Batata', weight = 50, stack = true, close = true},
    ['sos_slodko_kwasny'] = {label = 'Sos Słodko-Kwaśny', weight = 20, stack = true, close = true},

    -- Picie
    ['limonka'] = {label = 'Limonka', weight = 10, stack = true, close = true},
    ['sprite'] = {label = 'Sprite', weight = 50, stack = true, close = true},
    ['lod'] = {label = 'Lód', weight = 20, stack = true, close = true},
    ['bialy_rum'] = {label = 'Biały Rum', weight = 50, stack = true, close = true},
    ['mieta'] = {label = 'Mięta', weight = 5, stack = true, close = true},
    ['sok_pomaranczowy'] = {label = 'Sok Pomarańczowy', weight = 50, stack = true, close = true},
    ['grenadyna'] = {label = 'Grenadyna', weight = 20, stack = true, close = true},
    ['wodka'] = {label = 'Wódka', weight = 50, stack = true, close = true},
    ['owocowa_herbata'] = {label = 'Owocowa Herbata', weight = 30, stack = true, close = true},
    ['sok_cytrynowy'] = {label = 'Sok Cytrynowy', weight = 20, stack = true, close = true},
    ['sok_ananasowy'] = {label = 'Sok Ananasowy', weight = 50, stack = true, close = true},
    ['mleko_kokosowe'] = {label = 'Mleko Kokosowe', weight = 50, stack = true, close = true},
    ['syrop_waniliowy'] = {label = 'Syrop Waniliowy', weight = 20, stack = true, close = true},
    ['rum_kokosowy'] = {label = 'Rum Kokosowy', weight = 50, stack = true, close = true},
    ['sok_z_marakui'] = {label = 'Sok z Marakui', weight = 50, stack = true, close = true},

    -- Jedzenie
    ['tacos'] = {
        label = 'Tacos',
        weight = 300,
        stack = true,
        close = true,
        client = { image = 'tacos.webp' }
    },
    ['tropikalna_salatka'] = {
        label = 'Tropikalna Sałatka',
        weight = 250,
        stack = true,
        close = true,
        client = { image = 'tropikalna_salatka.webp' }
    },
    ['grillowany_losos'] = {
        label = 'Grillowany Łosoś',
        weight = 350,
        stack = true,
        close = true,
        client = { image = 'grillowany_losos.webp' }
    },
    ['hot_dog'] = {
        label = 'Hot Dog',
        weight = 300,
        stack = true,
        close = true,
        client = { image = 'hot_dog.webp' }
    },
    ['nachosy'] = {
        label = 'Nachosy',
        weight = 300,
        stack = true,
        close = true,
        client = { image = 'nachosy.webp' }
    },
    ['saszlyki'] = {
        label = 'Szaszłyki',
        weight = 350,
        stack = true,
        close = true,
        client = { image = 'saszlyki.webp' }
    },
    ['ocean_burger'] = {
        label = 'Ocean Burger',
        weight = 400,
        stack = true,
        close = true,
        client = { image = 'ocean_burger.webp' }
    },
    ['nuggetsy_frytki'] = {
        label = 'Nuggetsy z Frytkami',
        weight = 400,
        stack = true,
        close = true,
        client = { image = 'nuggetsy_frytki.webp' }
    },

    -- Picie
    ['lemoniada'] = {
        label = 'Lemoniada',
        weight = 200,
        stack = true,
        close = true,
        client = { image = 'lemoniada.webp' }
    },
    ['mojito'] = {
        label = 'Mojito',
        weight = 200,
        stack = true,
        close = true,
        client = { image = 'mojito.webp' }
    },
    ['sunset_punch'] = {
        label = 'Sunset Punch',
        weight = 250,
        stack = true,
        close = true,
        client = { image = 'sunset_punch.webp' }
    },
    ['ice_tea'] = {
        label = 'Ice Tea',
        weight = 200,
        stack = true,
        close = true,
        client = { image = 'ice_tea.webp' }
    },
    ['coconout_kiss'] = {
        label = 'Coconout Kiss',
        weight = 250,
        stack = true,
        close = true,
        client = { image = 'coconout_kiss.webp' }
    },
    ['drink_karaibski'] = {
        label = 'Drink Karaibski',
        weight = 250,
        stack = true,
        close = true,
        client = { image = 'drink_karaibski.webp' }
    },

--------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
--       /$$$$$$$  /$$$$$$$$  /$$$$$$  /$$   /$$       /$$      /$$  /$$$$$$   /$$$$$$  /$$   /$$ /$$$$$$ /$$   /$$ /$$$$$$$$
--      | $$__  $$| $$_____/ /$$__  $$| $$$ | $$      | $$$    /$$$ /$$__  $$ /$$__  $$| $$  | $$|_  $$_/| $$$ | $$| $$_____/
--      | $$  \ $$| $$      | $$  \ $$| $$$$| $$      | $$$$  /$$$$| $$  \ $$| $$  \__/| $$  | $$  | $$  | $$$$| $$| $$      
--      | $$$$$$$ | $$$$$   | $$$$$$$$| $$ $$ $$      | $$ $$/$$ $$| $$$$$$$$| $$      | $$$$$$$$  | $$  | $$ $$ $$| $$$$$   
--      | $$__  $$| $$__/   | $$__  $$| $$  $$$$      | $$  $$$| $$| $$__  $$| $$      | $$__  $$  | $$  | $$  $$$$| $$__/   
--      | $$  \ $$| $$      | $$  | $$| $$\  $$$      | $$\  $ | $$| $$  | $$| $$    $$| $$  | $$  | $$  | $$\  $$$| $$      
--      | $$$$$$$/| $$$$$$$$| $$  | $$| $$ \  $$      | $$ \/  | $$| $$  | $$|  $$$$$$/| $$  | $$ /$$$$$$| $$ \  $$| $$$$$$$$
--      |_______/ |________/|__/  |__/|__/  \__/      |__/     |__/|__/  |__/ \______/ |__/  |__/|______/|__/  \__/|________/
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
--------------------------------------------------------------------------------------------------------------

    ['filtr'] = {label = 'Filtr', weight = 5, stack = true, close = true},
    ['mleczna_pianka'] = {label = 'Mleczna Pianka', weight = 20, stack = true, close = true},
    ['czekolada'] = {label = 'Czekolada', weight = 50, stack = true, close = true},
    ['maka'] = {label = 'Mąka', weight = 50, stack = true, close = true},
    ['jajko'] = {label = 'Jajko', weight = 30, stack = true, close = true},
    ['lukier'] = {label = 'Lukier', weight = 20, stack = true, close = true},
    ['kakao'] = {label = 'Kakao', weight = 40, stack = true, close = true},
    ['polewa_czekoladowa'] = {label = 'Polewa Czekoladowa', weight = 30, stack = true, close = true},
    ['dzem'] = {label = 'Dżem', weight = 30, stack = true, close = true},
    ['wanilia'] = {label = 'Wanilia', weight = 10, stack = true, close = true},
    ['twarog'] = {label = 'Twaróg', weight = 100, stack = true, close = true},
    ['spod_ciasteczkowy'] = {label = 'Spód Ciasteczkowy', weight = 50, stack = true, close = true},
    ['maslo'] = {label = 'Masło', weight = 40, stack = true, close = true},
    ['marchewka'] = {label = 'Marchewka', weight = 30, stack = true, close = true},
    ['cynamon'] = {label = 'Cynamon', weight = 10, stack = true, close = true},
    ['jablka'] = {label = 'Jabłka', weight = 40, stack = true, close = true},
    ['drozdze'] = {label = 'Drożdże', weight = 10, stack = true, close = true},
    ['cukier'] = {label = 'Cukier', weight = 20, stack = true, close = true},

    ['espresso'] = {
        label = 'Espresso',
        weight = 100,
        stack = true,
        close = true,
        client = {
            image = 'espresso.webp',
        },
    },
    ['cappuccino'] = {
        label = 'Cappuccino',
        weight = 150,
        stack = true,
        close = true,
        client = {
            image = 'cappuccino.webp',
        },
    },
    ['latte'] = {
        label = 'Latte',
        weight = 150,
        stack = true,
        close = true,
        client = {
            image = 'cappuccino.webp',
        },
    },
    ['mocha'] = {
        label = 'Mocha',
        weight = 150,
        stack = true,
        close = true,
        client = {
            image = 'cappuccino.webp',
        },
    },
    ['americano'] = {
        label = 'Americano',
        weight = 120,
        stack = true,
        close = true,
        client = {
            image = 'espresso.webp',
        },
    },
    ['flat_white'] = {
        label = 'Flat White',
        weight = 150,
        stack = true,
        close = true,
        client = {
            image = 'cappuccino.webp',
        },
    },
    ['macchiato'] = {
        label = 'Macchiato',
        weight = 150,
        stack = true,
        close = true,
        client = {
            image = 'cappuccino.webp',
        },
    },

    ['donut_klasyczny'] = {
        label = 'Donut Klasyczny',
        weight = 200,
        stack = true,
        close = true,
        client = {
            image = 'donut.webp',
        },
    },
    ['donut_czekoladowy'] = {
        label = 'Donut Czekoladowy',
        weight = 220,
        stack = true,
        close = true,
        client = {
            image = 'donut.webp',
        },
    },
    ['donut_nadzienie'] = {
        label = 'Donut z Nadzieniem',
        weight = 220,
        stack = true,
        close = true,
        client = {
            image = 'donut.webp',
        },
    },

    ['muffin_borowkowy'] = {
        label = 'Muffin Borówkowy',
        weight = 200,
        stack = true,
        close = true,
        client = {
            image = 'cupcake.webp',
        },
    },
    ['muffin_czekoladowy'] = {
        label = 'Muffin Czekoladowy',
        weight = 200,
        stack = true,
        close = true,
        client = {
            image = 'cupcake.webp',
        },
    },
    ['muffin_waniliowy'] = {
        label = 'Muffin Waniliowy',
        weight = 200,
        stack = true,
        close = true,
        client = {
            image = 'cupcake.webp',
        },
    },

    ['sernik'] = {
        label = 'Sernik',
        weight = 500,
        stack = true,
        close = true,
        client = {
            image = 'ciasto.webp',
        },
    },
    ['brownie'] = {
        label = 'Brownie',
        weight = 450,
        stack = true,
        close = true,
        client = {
            image = 'chocolate.webp',
        },
    },
    ['ciasto_marchewkowe'] = {
        label = 'Ciasto Marchewkowe',
        weight = 500,
        stack = true,
        close = true,
        client = {
            image = 'ciasto.webp',
        },
    },
    ['szarlotka'] = {
        label = 'Szarlotka',
        weight = 500,
        stack = true,
        close = true,
        client = {
            image = 'ciasto.webp',
        },
    },
    ['ciasto_drozdzowe'] = {
        label = 'Ciasto Drożdżowe',
        weight = 600,
        stack = true,
        close = true,
        client = {
            image = 'ciasto.webp',
        },
    },


--------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------

    -- PEARL

--------------------------------------------------------------------------------------------------------------

    -- Gotowe produkty
    ['pearl_teqsun'] = {label = 'Tequila Sunrise', weight = 200, stack = true, close = true},
    ['pearl_cocktail2'] = {label = 'Koktail truskawka–arbuz', weight = 200, stack = true, close = true},
    ['pearl_cocktail1'] = {label = 'Koktail mango–banan', weight = 200, stack = true, close = true},
    ['pearl_virginmojito'] = {label = 'Virgin Mojito', weight = 300, stack = true, close = true},
    ['pearl_cwelburger'] = {label = 'Kraboburger', weight = 400, stack = true, close = true},
    ['pearl_codfish'] = {label = 'Smażony dorsz', weight = 350, stack = true, close = true},
    ['pearl_lemonade'] = {label = 'Lemoniada', weight = 300, stack = true, close = true},
    ['pearl_cola'] = {label = 'Cola', weight = 400, stack = true, close = true},
    ['pearl_kawa'] = {label = 'Kawa', weight = 350, stack = true, close = true},
    ['pearl_salmoncream'] = {label = 'Krem z łososia', weight = 300, stack = true, close = true},
    ['pearl_mussels'] = {label = 'Mule', weight = 400, stack = true, close = true},
    ['pearl_salad'] = {label = 'Sałatka', weight = 350, stack = true, close = true},

--------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------

    -- PIZZA

--------------------------------------------------------------------------------------------------------------

    -- Gotowe produkty
    ['pizza_margherrita'] = {label = 'Pizza Margherrita', weight = 200, stack = true, close = true},
    ['pizza_carbonara'] = {label = 'Carbonara', weight = 200, stack = true, close = true},
    ['pizza_bolognese'] = {label = 'Bolognese', weight = 200, stack = true, close = true},
    ['pizza_lasagne'] = {label = 'Lasagne', weight = 300, stack = true, close = true},
    ['pizza_tiramisu'] = {label = 'Tiramisu', weight = 400, stack = true, close = true},
    ['pizza_espresso'] = {label = 'Espresso', weight = 350, stack = true, close = true},
    ['pizza_cappuccino'] = {label = 'Cappuccino', weight = 300, stack = true, close = true},
    ['pizza_lemonsoda'] = {label = 'Lemon Soda', weight = 400, stack = true, close = true},
    ['pizza_herbatacytrynowa'] = {label = 'Herbata Cytrynowa', weight = 350, stack = true, close = true},
    ['pizza_prosecco'] = {label = 'Prosecco', weight = 300, stack = true, close = true},
    ['pizza_amaretto'] = {label = 'Amaretto', weight = 400, stack = true, close = true},

--------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------

    -- MEXICANA

--------------------------------------------------------------------------------------------------------------

    -- Gotowe produkty
    ['pizza_margherrita'] = {label = 'Pizza Margherrita', weight = 200, stack = true, close = true},
    ['pizza_carbonara'] = {label = 'Carbonara', weight = 200, stack = true, close = true},
    ['pizza_bolognese'] = {label = 'Bolognese', weight = 200, stack = true, close = true},
    ['pizza_lasagne'] = {label = 'Lasagne', weight = 300, stack = true, close = true},
    ['pizza_tiramisu'] = {label = 'Tiramisu', weight = 400, stack = true, close = true},
    ['pizza_espresso'] = {label = 'Espresso', weight = 350, stack = true, close = true},
    ['pizza_cappuccino'] = {label = 'Cappuccino', weight = 300, stack = true, close = true},
    ['pizza_lemonsoda'] = {label = 'Lemon Soda', weight = 400, stack = true, close = true},
    ['pizza_herbatacytrynowa'] = {label = 'Herbata Cytrynowa', weight = 350, stack = true, close = true},
    ['pizza_prosecco'] = {label = 'Prosecco', weight = 300, stack = true, close = true},
    ['pizza_amaretto'] = {label = 'Amaretto', weight = 400, stack = true, close = true},

--------------------------------------------------------------------------------------------------------------

}
