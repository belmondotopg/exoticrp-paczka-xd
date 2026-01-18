Config = {}

Config.Debug = false
Config.BlipPrefix = "FIRMA | "

Config.Upgrades = {
    ["personalStash"] = {
        label = "Wielkość szafki pracowniczej",
        defaultWeight = 10000,
        defaultSlots = 10,
        increaseWeight = 10000,
        increaseSlots = 1,
        maxLevel = 5,
        basePrice = 50000
    },
    ["globalStash"] = {
        label = "Wielkość szafki firmowej",
        defaultWeight = 10000,
        defaultSlots = 10,
        increaseWeight = 10000,
        increaseSlots = 1,
        maxLevel = 5,
        basePrice = 50000
    },
    ["employeeLimit"] = {
        label = "Limit pracowników",
        defaultLimit = 10,
        increaseLimit = 10,
        maxLevel = 10,
        basePrice = 50000
    }
}

Config.Businesses = {
    ["uwucafe"] = {
        account = "uwucafe",
        label = "UwU Cafe",

        blip = {
            coords = vec3(-583.3208, -1060.1566, 22.3442),
            sprite = 558,
            color = 0,
            scale = 1.0,
        },

        personalStash = {
            coords = vec3(-586.2237, -1049.9690, 22.8116),
            size = vec3(1.0, 3.0, 2.5),
            rotation = 0.0,
        },

        globalStash = {
            coords = vec3(-590.9099, -1067.9557, 22.1548),
            size = vec3(1.0, 3.0, 2.5),
            rotation = 0.0,
        },

        dishesStash = {
            coords = vec3(-587.9708, -1059.1274, 22.3304),
            size = vec3(1.0, 3.0, 2.5),
            rotation = 0.0,
        },

        wardrobe = {
            coords = vec3(-586.2237, -1049.9690, 22.8116),
            size = vec3(1.0, 3.0, 2.5),
            rotation = 0.0,
            minGrade = 0,
            addClothesGrade = 5,
        },

        bossMenu = {
            coords = vec3(-596.3521, -1052.7002, 22.5931),
            size = vec3(1.0, 2.5, 2.5),
            rotation = 90.0,
            minGrade = 5
        },

        cooking = {
            coords = vec3(-587.9708, -1059.1274, 22.3304),
            size = vec3(1.0, 3.0, 2.5),
            rotation = 0.0,
            dishes = {
                bubble_tea = {
                    label = "Bubble Tea",
                    hunger = 500,
                    thirst = 1000,
                    icon = "https://items.bit-scripts.com/images/food/tea_bubble_pink.png"
                },
                uwu_frappe = {
                    label = "UwU Frappé",
                    hunger = 500,
                    thirst = 1200,
                    icon = "https://items.bit-scripts.com/images/drinks/coffee_frappuccino.png"
                },
                uwu_latte = {
                    label = "UwU Latte",
                    hunger = 500,
                    thirst = 1000,
                    icon = "https://items.bit-scripts.com/images/drinks/iced_caffe_latte.png"
                },
                herbata_matcha = {
                    label = "Herbata Matcha",
                    hunger = 200,
                    thirst = 800,
                    icon = "https://items.bit-scripts.com/images/drinks/matchaTea.png"
                },
                mochi = {
                    label = "Mochi",
                    hunger = 400,
                    thirst = 0,
                    icon = "https://items.bit-scripts.com/images/food/mochi.png"
                },
                cupcake_rozany = {
                    label = "Cupcake Różany",
                    hunger = 300,
                    thirst = 0,
                    icon = "https://img.icons8.com/color/96/000000/cupcake.png"
                },
                ciastko_hello_kitty = {
                    label = "Ciastko Hello Kitty",
                    hunger = 300,
                    thirst = 0,
                    icon = "https://items.bit-scripts.com/images/food/catcookie.png"
                }
            }
        },

        tray = {
            coords = vec3(-583.9132, -1062.0280, 22.1649),
            size = vec3(1.0, 3.0, 2.5),
            rotation = 0.0,
        },

        car = {
            npc = {
                coords = vec4(-592.0035, -1056.5129, 22.3442 - 0.95, 126.9076),
                model = `a_m_y_stwhi_02`
            },
            spawnPoint = vec4(-612.3094, -1065.6530, 21.7883, 176.7619),
            model = `burrito3`
        },

        collectProducts = {
            npc = {
                coords = vec4(-1202.5708007812, -1308.5852050781, 4.903573513031 - 0.95, 113.53458404541),
                model = `s_m_y_factory_01`
            },
            coords = vec3(-1202.5708007812, -1308.5852050781, 4.903573513031)
        },

        deliverProducts = {
            coords = vec3(-597.94073486328, -1062.2202880859, 22.344198226929),
            size = vec3(3.5, 1.5, 2.5),
            rotation = 0.0,
        },

        priceLists = {
            minGrade = 0
        }
    },
    ["whitewidow"] = {
        account = "whitewidow",
        label = "White Widow",

        blip = {
            coords = vec3(109.5317, -1.6278, 67.537),
            sprite = 140,
            color = 2,
            scale = 0.8,
        },

        personalStash = {
            coords = vec3(98.0002, 4.1204, 67.5355),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -20.0,
        },

        globalStash = {
            coords = vec3(103.4689, 6.7356, 67.8132),
            size = vec3(1.0, 2.0, 2.5),
            rotation = 70.0,
        },

        wardrobe = {
            coords = vec3(98.0002, 4.1204, 67.5355),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -20.0,
        },

        bossMenu = {
            coords = vec3(117.0952, 13.3004, 67.6568),
            size = vec3(1.0, 3.0, 2.5),
            rotation = 70.0,
            minGrade = 5
        },


        cooking = {
            coords = vec3(106.1544, 4.3898, 67.2822),
            size = vec3(1.0, 3.5, 2.5),
            rotation = -20.0,
            dishes = {
                purple_haze_smoothie = {
                    label = "Purple Haze Smoothie",
                    hunger = 300,
                    thirst = 800,
                    icon = "nui://ox_inventory/web/images/purple_haze_smoothie.webp"
                },
                sativa_sunrise = {
                    label = "Sativa Sunrise",
                    hunger = 250,
                    thirst = 900,
                    icon = "nui://ox_inventory/web/images/sativa_sunrise.webp"
                },
                white_widow_elixir = {
                    label = "White Widow Elixir",
                    hunger = 200,
                    thirst = 800,
                    icon = "nui://ox_inventory/web/images/white_widow_elixir.webp"
                },
                green_smoke_gnocchi = {
                    label = "Green Smoke Gnocchi",
                    hunger = 600,
                    thirst = 0,
                    icon = "nui://ox_inventory/web/images/green_smoke_gnocchi.webp"
                },
                blunt_burger = {
                    label = "Blunt Burger",
                    hunger = 800,
                    thirst = 0,
                    icon = "nui://ox_inventory/web/images/blunt_burger.webp"
                },
                kush_curry = {
                    label = "Kush Curry",
                    hunger = 700,
                    thirst = 0,
                    icon = "nui://ox_inventory/web/images/kush_curry.webp"
                }
            }
        },

        tray = {
            coords = vec3(109.5317, -1.6278, 67.5372),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -20.0,
        },

        car = {
            npc = {
                coords = vec4(107.37673950195, 7.3482851982117, 66.781555175781, 26.996538162231),
                model = `a_m_y_stwhi_02`
            },
            spawnPoint = vec4(123.6658, 6.6637, 67.9005, 158.6046),
            model = `burrito3`
        },

        collectProducts = {
            npc = {
                coords = vec4(399.94903564453, 66.948623657227, 97.97785949707 - 0.95, 158.80067443848),
                model = `s_m_y_factory_01`
            },
            coords = vec3(399.94903564453, 66.948623657227, 97.97785949707)
        },

        deliverProducts = {
            coords = vec3(103.88246917725, 12.3, 67.996963500977),
            size = vec3(1.0, 3.5, 2.5),
            rotation = 70.0,
        },

        priceLists = {
            minGrade = 0
        }
    },
    ["bahama_mamas"] = {
        account = "bahama_mamas",
        label = "Bahama Mamas",

        blip = {
            coords = vec3(-1404.1962, -598.7533, 30.4271),
            sprite = 93,
            color = 5,
            scale = 0.8,
        },

        personalStash = {
            coords = vec3(-1376.6038, -634.5049, 30.1024),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -55.0,
        },

        globalStash = {
            coords = vec3(-1404.1962, -598.7533, 30.4271),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -57.0,
        },

        wardrobe = {
            coords = vec3(-1376.6038, -634.5049, 30.1024),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -55.0,
        },

        bossMenu = {
            coords = vec3(-1370.3772, -625.7935, 30.2560),
            size = vec3(1.0, 2.5, 2.5),
            rotation = -55.0,   
            minGrade = 5
        },


        cooking = {
            coords = vec3(-1400.0392, -597.5440, 30.275),
            size = vec3(1.0, 3.0, 2.5),
            rotation = 33.0,
            dishes = {
                tacos = {
                    label = "Tacos",
                    hunger = 300,
                    thirst = 0,
                    icon = "https://img.icons8.com/color/96/000000/taco.png"
                },
                tropikalna_salatka = {
                    label = "Tropikalna Sałatka",
                    hunger = 200,
                    thirst = 0,
                    icon = "https://img.icons8.com/color/96/000000/salad.png"
                },
                hot_dog = {
                    label = "Hot Dog",
                    hunger = 250,
                    thirst = 0,
                    icon = "https://img.icons8.com/color/96/000000/hot-dog.png"
                },
                nachosy = {
                    label = "Nachosy",
                    hunger = 200,
                    thirst = 0,
                    icon = "https://img.icons8.com/color/96/000000/nachos.png"
                },
                ocean_burger = {
                    label = "Ocean Burger",
                    hunger = 350,
                    thirst = 0,
                    icon = "https://img.icons8.com/?size=100&id=46588&format=png&color=000000"
                },
                nuggetsy_frytki = {
                    label = "Nuggetsy z Frytkami",
                    hunger = 350,
                    thirst = 0,
                    icon = "https://img.icons8.com/?size=100&id=lYzsuh8Nghu3&format=png&color=000000"
                },
                lemoniada = {
                    label = "Lemoniada",
                    hunger = 0,
                    thirst = 300,
                    icon = "https://img.icons8.com/color/96/000000/lemonade.png"
                },
                mojito = {
                    label = "Mojito",
                    hunger = 0,
                    thirst = 350,
                    icon = "https://img.icons8.com/?size=100&id=gzIqy9KTn79G&format=png&color=000000"
                },
                sunset_punch = {
                    label = "Sunset Punch",
                    hunger = 0,
                    thirst = 400,
                    icon = "https://img.icons8.com/color/96/000000/cocktail.png"
                },
                ice_tea = {
                    label = "Ice Tea",
                    hunger = 0,
                    thirst = 300,
                    icon = "https://img.icons8.com/?size=100&id=hTdrchIILpVn&format=png&color=000000"
                },
                coconout_kiss = {
                    label = "Coconout Kiss",
                    hunger = 0,
                    thirst = 400,
                    icon = "https://img.icons8.com/?size=100&id=LeE1hmzIqQay&format=png&color=000000"
                },
                drink_karaibski = {
                    label = "Drink Karaibski",
                    hunger = 0,
                    thirst = 400,
                    icon = "https://img.icons8.com/color/96/000000/cocktail.png"
                }
            }
        },

        tray = {
            coords = vec3(-1398.7833, -599.9851, 30.148),
            size = vec3(1.0, 2.0, 2.5),
            rotation = 0.0,
        },

        car = {
            npc = {
                coords = vec4(-1387.1864013672, -596.72961425781, 30.31995010376 - 0.95, 25.165561676025),
                model = `a_m_y_beach_01`
            },
            spawnPoint = vec4(-1373.2315673828, -581.52746582031, 29.723382949829, 34.812210083008),
            model = `burrito3`
        },

        collectProducts = {
            npc = {
                coords = vec4(-758.37536621094, -423.2008972168, 35.69771194458 - 0.95, 6.2783722877502),
                model = `s_m_y_factory_01`
            },
            coords = vec3(-758.37536621094, -423.2008972168, 35.69771194458)
        },

        deliverProducts = {
            coords = vec3(-1403.4243164062, -602.3115234375, 30.45),
            size = vec3(1.0, 2.0, 2.5),
            rotation = 37.0,
        },

        priceLists = {
            minGrade = 0
        }
    },
    ["beanmachine"] = {
        account = "beanmachine",
        label = "Bean Machine",

        blip = {
            coords = vec3(343.6937, -779.1819, 29.3760),
            sprite = 559,
            color = 0,
            scale = 1.0,
        },

        personalStash = {
            coords = vec3(342.9885, -764.7857, 29.3955),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -20.0,
        },

        globalStash = {
            coords = vec3(348.52230834961, -759.88317871094, 29.451580047607),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -20.0,
        },

        wardrobe = {
            coords = vec3(342.9885, -764.7857, 29.3955),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -20.0,
        },

        bossMenu = {
            coords = vec3(351.2943, -762.0154, 29.5474),
            size = vec3(1.0, 3.0, 2.5),
            rotation = 70.0,
            minGrade = 4
        },

        cooking = {
            coords = vec3(343.6937, -779.1819, 29.3760),
            size = vec3(1.0, 2.5, 2.5),
            rotation = -20.0,
            dishes = {
                espresso = {
                    label = "Espresso",
                    hunger = 50,
                    thirst = 200,
                    icon = "https://img.icons8.com/color/96/coffee.png"
                },
                cappuccino = {
                    label = "Cappuccino",
                    hunger = 60,
                    thirst = 250,
                    icon = "https://img.icons8.com/?size=100&id=7vhhfcFoLK4d&format=png&color=000000"
                },
                latte = {
                    label = "Latte",
                    hunger = 70,
                    thirst = 250,
                    icon = "https://img.icons8.com/?size=100&id=opLWxaWUAACV&format=png&color=000000"
                },
                mocha = {
                    label = "Mocha",
                    hunger = 80,
                    thirst = 250,
                    icon = "https://img.icons8.com/?size=100&id=TMntsbmYIeTi&format=png&color=000000"
                },
                americano = {
                    label = "Americano",
                    hunger = 50,
                    thirst = 250,
                    icon = "https://img.icons8.com/?size=100&id=zyGPc7K85NQa&format=png&color=000000"
                },
                flat_white = {
                    label = "Flat White",
                    hunger = 70,
                    thirst = 250,
                    icon = "https://img.icons8.com/?size=100&id=rHivtuMJ1giH&format=png&color=000000"
                },
                macchiato = {
                    label = "Macchiato",
                    hunger = 60,
                    thirst = 220,
                    icon = "https://img.icons8.com/?size=100&id=VjKLdlvRMNdT&format=png&color=000000"
                },

                donut_klasyczny = {
                    label = "Donut Klasyczny",
                    hunger = 300,
                    thirst = 0,
                    icon = "https://img.icons8.com/?size=100&id=JW7cA6BZfEkb&format=png&color=000000"
                },
                donut_czekoladowy = {
                    label = "Donut Czekoladowy",
                    hunger = 320,
                    thirst = 0,
                    icon = "https://img.icons8.com/?size=100&id=70411&format=png&color=000000"
                },
                donut_nadzienie = {
                    label = "Donut z Nadzieniem",
                    hunger = 320,
                    thirst = 0,
                    icon = "https://img.icons8.com/?size=100&id=xiajvrecvGKs&format=png&color=000000"
                },

                muffin_borowkowy = {
                    label = "Muffin Borówkowy",
                    hunger = 350,
                    thirst = 0,
                    icon = "https://img.icons8.com/?size=100&id=120052&format=png&color=000000"
                },
                muffin_czekoladowy = {
                    label = "Muffin Czekoladowy",
                    hunger = 350,
                    thirst = 0,
                    icon = "https://img.icons8.com/?size=100&id=RpV2RkyGB73j&format=png&color=000000"
                },
                muffin_waniliowy = {
                    label = "Muffin Waniliowy",
                    hunger = 350,
                    thirst = 0,
                    icon = "https://img.icons8.com/?size=100&id=35784&format=png&color=000000"
                },

                sernik = {
                    label = "Sernik",
                    hunger = 500,
                    thirst = 0,
                    icon = "https://img.icons8.com/color/96/cheesecake.png"
                },
                brownie = {
                    label = "Brownie",
                    hunger = 500,
                    thirst = 0,
                    icon = "https://img.icons8.com/?size=100&id=SvFX8RvJ3dKW&format=png&color=000000"
                },
                ciasto_marchewkowe = {
                    label = "Ciasto Marchewkowe",
                    hunger = 500,
                    thirst = 0,
                    icon = "https://img.icons8.com/?size=100&id=TlgHVw0hLP3X&format=png&color=000000"
                },
                szarlotka = {
                    label = "Szarlotka",
                    hunger = 500,
                    thirst = 0,
                    icon = "https://img.icons8.com/color/96/apple-pie.png"
                },
                ciasto_drozdzowe = {
                    label = "Ciasto Drożdżowe",
                    hunger = 500,
                    thirst = 0,
                    icon = "https://img.icons8.com/color/96/bread.png"
                }
            }
        },

        tray = {
            coords = vec3(342.5835, -776.7031, 29.2303),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -20.0,
        },

        collectProducts = {
            npc = {
                coords = vec4(808.74670410156, -1050.0284423828, 28.196805953979 - 0.95, 1.0379329919815),
                model = `s_m_y_factory_01`
            },
            coords = vec3(808.74670410156, -1050.0284423828, 28.196805953979)
        },

        deliverProducts = {
            coords = vec3(344.82083129883, -777.09100341797, 29.261987686157),
            size = vec3(1.0, 2.0, 2.5),
            rotation = -20.0,
        },
        car = {
            npc = {
                coords = vec4(335.10092163086, -771.90087890625, 29.324262619019 - 0.95, 70.482177734375),
                model = `a_m_y_beach_01`
            },
            spawnPoint = vec4(334.42630004883, -762.02404785156, 28.997379302979, 162.30184936523),
            model = `burrito3`
        },

        priceLists = {
            minGrade = 0
        }
    },
    ["pearl"] = {
        account = "pearl",
        label = "Pearls Restaurant",

        blip = {
            coords = vec3(-1833.2772216797, -1190.8859863281, 14.309240341187),
            sprite = 317,
            color = 15,
            scale = 0.8,
        },

        personalStash = {
            coords = vec3(-1837.5074462891, -1188.0935546875, 14.317486763),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -30.0,
        },

        globalStash = {
            coords = vec3(-1843.7729492188, -1198.9173583984, 14.309239387512),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -30.0,
        },

        dishesStash = {
            coords = vec3(-1839.0543212891, -1193.3558349609, 14.315967559814),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -30.0,
        },

        wardrobe = {
            coords = vec3(-1837.5074462891, -1188.0935546875, 14.317486763),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -30.0,
            minGrade = 0,
            addClothesGrade = 5,
        },

        bossMenu = {
            coords = vec3(-1840.0128173828, -1183.8884277344, 14.328951835632),
            size = vec3(1.0, 2.5, 2.5),
            rotation = 60.0,
            minGrade = 5
        },

        cooking = {
            coords = vec3(-1845.290625, -1196.0922119141, 14.309240341187),
            size = vec3(2.0, 3.0, 2.5),
            rotation = -30.0,
            dishes = {
                pearl_salad = {
                    label = "Sałatka",
                    hunger = 300,
                    thirst = 0,
                    icon = "https://items.bit-scripts.com/images/food/gp_salad.png"
                },
                pearl_mussels = {
                    label = "Mule",
                    hunger = 300,
                    thirst = 0,
                    icon = "https://items.bit-scripts.com/images/food/mussels.png"
                },
                pearl_salmoncream = {
                    label = "Krem z łososia",
                    hunger = 300,
                    thirst = 0,
                    icon = "https://items.bit-scripts.com/images/food/salmon.png"
                },
                pearl_kawa = {
                    label = "Kawa",
                    hunger = 0,
                    thirst = 300,
                    icon = "https://items.bit-scripts.com/images/drinks/coffee_frappuccino.png"
                },
                pearl_cola = {
                    label = "Cola",
                    hunger = 0,
                    thirst = 300,
                    icon = "https://items.bit-scripts.com/images/drinks/cola.png"
                },
                pearl_lemonade = {
                    label = "Lemoniada",
                    hunger = 0,
                    thirst = 300,
                    icon = "https://items.bit-scripts.com/images/drinks/green_tea_lemonade.png"
                },
                pearl_codfish = {
                    label = "Smażony dorsz",
                    hunger = 500,
                    thirst = 0,
                    icon = "https://items.bit-scripts.com/images/food/seafood_grilledfish.png"
                },
                pearl_cwelburger = {
                    label = "Kraboburger",
                    hunger = 500,
                    thirst = 0,
                    icon = "https://items.bit-scripts.com/images/food/burger-torpedo.png"
                },
                pearl_virginmojito = {
                    label = "Virgin Mojito",
                    hunger = 0,
                    thirst = 500,
                    icon = "https://items.bit-scripts.com/images/drinks/mojito.png"
                },
                pearl_cocktail1 = {
                    label = "Koktail mango–banan",
                    hunger = 0,
                    thirst = 500,
                    icon = "https://items.bit-scripts.com/images/drinks/opmcocktail.png"
                },
                pearl_cocktail2 = {
                    label = "Koktail truskawka–arbuz",
                    hunger = 0,
                    thirst = 500,
                    icon = "https://items.bit-scripts.com/images/drinks/dbcocktail.png"
                },
                pearl_teqsun = {
                    label = "Tequila Sunrise",
                    hunger = 0,
                    thirst = 300,
                    icon = "https://items.bit-scripts.com/images/drinks/shooter_tequila.png"
                },
            }
        },

        tray = {
            coords = vec3(-1834.2700927734, -1190.2043945312, 14.313443183899),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -30.0,
        },

        car = {
            npc = {
                coords = vec4(-1813.4230957031, -1182.4710693359, 13.017733573914 - 0.95, 330.88549804688),
                model = `a_m_y_stwhi_02`
            },
            spawnPoint = vec4(-1800.6101074219, -1177.0510253906, 12.832901954651, 320.55316162109),
            model = `burrito3`
        },

        collectProducts = {
            npc = {
                coords = vec4(-1347.9903564453, -720.22961425781, 24.934234619141 - 0.95, 127.5454864502),
                model = `s_m_y_factory_01`
            },
            coords = vec3(-1347.9903564453, -720.22961425781, 24.934234619141)
        },

        deliverProducts = {
            coords = vec3(-1843.6850585938, -1193.0679931641, 14.309238433838),
            size = vec3(1.0, 2.0, 2.5),
            rotation = 60.0,
        },

        priceLists = {
            minGrade = 0
        }
    },
    ["pizza"] = {
        account = "pizza",
        label = "Corretto Italian Restaurant",

        blip = {
            coords = vec3(-1191.1739501953, -1400.3687744141, 4.4729418754578),
            sprite = 681,
            color = 44,
            scale = 0.8,
        },

        personalStash = {
            coords = vec3(-1190.1795654297, -1387.2003173828, 4.6326818466187),
            size = vec3(1.0, 2.5, 2.5),
            rotation = -55.0,
        },

        globalStash = {
            coords = vec3(-1198.2604980469, -1400.1301269531, 4.4729452133179),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -55.0,
        },

        dishesStash = {
            coords = vec3(-1194.0552734375, -1396.8791992188, 4.4729452133179),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -55.0,
        },

        wardrobe = {
            coords = vec3(-1190.1795654297, -1387.2003173828, 4.6326818466187),
            size = vec3(1.0, 2.5, 2.5),
            rotation = -55.0,
            minGrade = 0,
            addClothesGrade = 5,
        },

        bossMenu = {
            coords = vec3(-1181.3693847656, -1408.4584960938, 10.437502861023),
            size = vec3(1.0, 2.5, 2.5),
            rotation = 35.0,
            minGrade = 5
        },

        cooking = {
            coords = vec3(-1196.0836181641, -1394.667382812, 4.4729528427124),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -55.0,
            dishes = {
                pizza_margherrita = {
                    label = "Pizza Margherrita",
                    hunger = 500,
                    thirst = 0,
                    icon = "https://items.bit-scripts.com/images/food/pmargharita.png"
                },
                pizza_carbonara = {
                    label = "Carbonara",
                    hunger = 500,
                    thirst = 0,
                    icon = "https://items.bit-scripts.com/images/ingredients/spaghetti.png"
                },
                pizza_bolognese = {
                    label = "Bolognese",
                    hunger = 500,
                    thirst = 0,
                    icon = "https://items.bit-scripts.com/images/food/bolognese.png"
                },
                pizza_lasagne = {
                    label = "Lasagne",
                    hunger = 300,
                    thirst = 0,
                    icon = "https://items.bit-scripts.com/images/food/lasagna.png"
                },
                pizza_tiramisu = {
                    label = "Tiramisu",
                    hunger = 300,
                    thirst = 0,
                    icon = "https://items.bit-scripts.com/images/food/tiramisu.png"
                },
                pizza_espresso = {
                    label = "Espresso",
                    hunger = 0,
                    thirst = 500,
                    icon = "https://items.bit-scripts.com/images/drinks/espresso.png"
                },
                pizza_cappuccino = {
                    label = "Cappuccino",
                    hunger = 0,
                    thirst = 300,
                    icon = "https://items.bit-scripts.com/images/drinks/cb_capuccino.png"
                },
                pizza_lemonsoda = {
                    label = "Lemon Soda",
                    hunger = 0,
                    thirst = 300,
                    icon = "https://items.bit-scripts.com/images/food/lemonade.png"
                },
                pizza_herbatacytrynowa = {
                    label = "Herbata Cytrynowa",
                    hunger = 0,
                    thirst = 500,
                    icon = "https://items.bit-scripts.com/images/drinks/earl_grey_tea.png"
                },
                pizza_prosecco = {
                    label = "Prosecco",
                    hunger = 0,
                    thirst = 200,
                    icon = "https://items.bit-scripts.com/images/drinks/wine_prosecco.png"
                },
                pizza_amaretto = {
                    label = "Amaretto",
                    hunger = 0,
                    thirst = 200,
                    icon = "https://items.bit-scripts.com/images/drinks/amaretto.png"
                },
            }
        },

        tray = {
            coords = vec3(-1186.3804931641, -1398.4039306641, 4.4729433059692),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -55.0,
        },

        car = {
            npc = {
                coords = vec4(-1177.7999267578, -1407.2286376953, 4.6956977844238 - 0.95, 263.43078613281),
                model = `a_m_y_stwhi_02`
            },
            spawnPoint = vec4(-1180.7470703125, -1397.5747070312, 4.4530749320984, 304.35134887695),
            model = `burrito3`
        },

        collectProducts = {
            npc = {
                coords = vec4(-700.33422851562, -1143.0531005859, 10.814213752747 - 0.95, 47.825923919678),
                model = `s_m_y_factory_01`
            },
            coords = vec3(-700.33422851562, -1143.0531005859, 10.814213752747)
        },

        deliverProducts = {
            coords = vec3(-1197.2055664062, -1402.5914306641, 4.4729490280151),
            size = vec3(1.0, 3.0, 2.5),
            rotation = -55.0,
        },

        priceLists = {
            minGrade = 0
        }
    },
    -- ["mexicana"] = {
    --     account = "mexicana",
    --     label = "El Barrio del Oro",

    --     blip = {
    --         coords = vec3(386.54058837891, -319.46926879883, 51.061405181885),
    --         sprite = 681,
    --         color = 44,
    --         scale = 0.8,
    --     },

    --     personalStash = {
    --         coords = vec3(-1190.1795654297, -1387.2003173828, 4.6326818466187),
    --         size = vec3(1.0, 2.5, 2.5),
    --         rotation = -55.0,
    --     },

    --     globalStash = {
    --         coords = vec3(-1198.2604980469, -1400.1301269531, 4.4729452133179),
    --         size = vec3(1.0, 3.0, 2.5),
    --         rotation = -55.0,
    --     },

    --     dishesStash = {
    --         coords = vec3(-1194.0552734375, -1396.8791992188, 4.4729452133179),
    --         size = vec3(1.0, 3.0, 2.5),
    --         rotation = -55.0,
    --     },

    --     wardrobe = {
    --         coords = vec3(-1190.1795654297, -1387.2003173828, 4.6326818466187),
    --         size = vec3(1.0, 2.5, 2.5),
    --         rotation = -55.0,
    --         minGrade = 0,
    --         addClothesGrade = 5,
    --     },

    --     bossMenu = {
    --         coords = vec3(-1181.3693847656, -1408.4584960938, 10.437502861023),
    --         size = vec3(1.0, 2.5, 2.5),
    --         rotation = 35.0,
    --         minGrade = 5
    --     },

    --     cooking = {
    --         coords = vec3(-1196.0836181641, -1394.667382812, 4.4729528427124),
    --         size = vec3(1.0, 3.0, 2.5),
    --         rotation = -55.0,
    --         dishes = {
    --             pizza_margherrita = {
    --                 label = "Pizza Margherrita",
    --                 hunger = 500,
    --                 thirst = 0,
    --                 icon = "https://items.bit-scripts.com/images/food/pmargharita.png"
    --             },
    --             pizza_carbonara = {
    --                 label = "Carbonara",
    --                 hunger = 500,
    --                 thirst = 0,
    --                 icon = "https://items.bit-scripts.com/images/ingredients/spaghetti.png"
    --             },
    --             pizza_bolognese = {
    --                 label = "Bolognese",
    --                 hunger = 500,
    --                 thirst = 0,
    --                 icon = "https://items.bit-scripts.com/images/food/bolognese.png"
    --             },
    --             pizza_lasagne = {
    --                 label = "Lasagne",
    --                 hunger = 300,
    --                 thirst = 0,
    --                 icon = "https://items.bit-scripts.com/images/food/lasagna.png"
    --             },
    --             pizza_tiramisu = {
    --                 label = "Tiramisu",
    --                 hunger = 300,
    --                 thirst = 0,
    --                 icon = "https://items.bit-scripts.com/images/food/tiramisu.png"
    --             },
    --             pizza_espresso = {
    --                 label = "Espresso",
    --                 hunger = 0,
    --                 thirst = 500,
    --                 icon = "https://items.bit-scripts.com/images/drinks/espresso.png"
    --             },
    --             pizza_cappuccino = {
    --                 label = "Cappuccino",
    --                 hunger = 0,
    --                 thirst = 300,
    --                 icon = "https://items.bit-scripts.com/images/drinks/cb_capuccino.png"
    --             },
    --             pizza_lemonsoda = {
    --                 label = "Lemon Soda",
    --                 hunger = 0,
    --                 thirst = 300,
    --                 icon = "https://items.bit-scripts.com/images/food/lemonade.png"
    --             },
    --             pizza_herbatacytrynowa = {
    --                 label = "Herbata Cytrynowa",
    --                 hunger = 0,
    --                 thirst = 500,
    --                 icon = "https://items.bit-scripts.com/images/drinks/earl_grey_tea.png"
    --             },
    --             pizza_prosecco = {
    --                 label = "Prosecco",
    --                 hunger = 0,
    --                 thirst = 200,
    --                 icon = "https://items.bit-scripts.com/images/drinks/wine_prosecco.png"
    --             },
    --             pizza_amaretto = {
    --                 label = "Amaretto",
    --                 hunger = 0,
    --                 thirst = 200,
    --                 icon = "https://items.bit-scripts.com/images/drinks/amaretto.png"
    --             },
    --         }
    --     },

    --     tray = {
    --         coords = vec3(-1186.3804931641, -1398.4039306641, 4.4729433059692),
    --         size = vec3(1.0, 3.0, 2.5),
    --         rotation = -55.0,
    --     },

    --     car = {
    --         npc = {
    --             coords = vec4(-1177.7999267578, -1407.2286376953, 4.6956977844238 - 0.95, 263.43078613281),
    --             model = `a_m_y_stwhi_02`
    --         },
    --         spawnPoint = vec4(-1180.7470703125, -1397.5747070312, 4.4530749320984, 304.35134887695),
    --         model = `burrito3`
    --     },

    --     collectProducts = {
    --         npc = {
    --             coords = vec4(-700.33422851562, -1143.0531005859, 10.814213752747 - 0.95, 47.825923919678),
    --             model = `s_m_y_factory_01`
    --         },
    --         coords = vec3(-700.33422851562, -1143.0531005859, 10.814213752747)
    --     },

    --     deliverProducts = {
    --         coords = vec3(-1197.2055664062, -1402.5914306641, 4.4729490280151),
    --         size = vec3(1.0, 3.0, 2.5),
    --         rotation = -55.0,
    --     },

    --     priceLists = {
    --         minGrade = 0
    --     }
    -- }
}