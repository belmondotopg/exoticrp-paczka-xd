Config                            = {}
Config.DrawDistance               = 10.0
Config.MarkerSize                 = { x = 1.5, y = 1.5, z = 1.0 }
Config.EnableHandcuffTimer        = true
Config.HandcuffTimer              = 15 * 60000

Config.Blips = {
   {
      Pos     = vec3(-1076.6593017578, -834.89892578125, 10.951587677002), -- VESPUCCI
      Sprite  = 60,
      Display = 4,
      Scale   = 0.9,
      Colour  = 38,
      Label   = "Komisariat"
   },
   {
      Pos     = vector3(1833.0968, 3675.2905, 34.1892), -- sandy
      Sprite  = 60,
      Display = 4,
      Scale   = 0.9,
      Colour  = 38,
      Label   = "Komisariat"
   },
   {
      Pos = vector3(-459.0056, 6013.3682, 31.4901), -- Paleto
      Sprite  = 60,
      Display = 4,
      Scale   = 0.9,
      Colour  = 38,
      Label   = "Komisariat"
   },  
   {
      Pos = vector3(366.6578, -1600.0977, 30.0513), -- Paleto
      Sprite  = 526,
      Display = 4,
      Scale   = 0.9,
      Colour  = 10,
      Label   = "Komisariat SASD"
   },  
}

Config.AllowedJobs = {["sheriff"] = true, ["police"] = true}

Config.Interactions = {
   ["BossActions"] = {"Zarządzaj Frakcją", "Naciśnij ALT aby otworzyć zarządzanie frakcją"},
   ["SWATArmory"] = false,
   ["HCArmory"] = false,
   ["PharmacySchowki"] = {"Otwórz Schowek", "Naciśnij ALT aby otworzyć schowek"},
   ["CloakroomsPrivate"] = {"Otwórz Prywatną Przebieralnie", "Naciśnij ALT aby otworzyć prywatną przebieralnie"},
   ["Cloakrooms"] = {"Otwórz Służbową Przebieralnie", "Naciśnij ALT aby otworzyć służbową przebieralnie"},

}

Config.PoliceStations = {
   BossActions = {
      {
         coords = vec3(-1113.2901611328, -832.23327636719, 34.279983520508), -- vespucci
         size = vec3(2.15, 1.2, 1.5),
         rotation = 0,
         icon = "fa-solid fa-people-roof",
         label = "Zarządzanie",
      },
      {
         coords = vec3(386.68826293945, -1623.4372558594, 34.174205780029), -- davis
         size = vec3(2.15, 1.2, 1.5),
         rotation = 0,
         icon = "fa-solid fa-people-roof",
         label = "Zarządzanie",
      },
   },
   SWATArmory = {
      {
         coords = vec3(-1031.8673095703, -813.95373535156, 10.951591491699), --vespucci
         size = vec3(4.4, 1, 2.35),
         rotation = 0.0,
         icon = "fa-solid fa-people-roof",
         label = "Zbrojownia SWAT",
      },
      {
         coords = vec3(382.41302490234, -1599.8978271484, 25.361972808838), --davis
         size = vec3(4.4, 1, 2.35),
         rotation = 0.0,
         icon = "fa-solid fa-people-roof",
         label = "Zbrojownia SWAT",
      },
   },
   HCArmory = {
      {
         coords = vec3(-1035.6456298828, -813.25579833984, 10.951591491699), --vespucci
         size = vec3(4.4, 1, 2.35),
         rotation = 0.0,
         icon = "fa-solid fa-people-roof",
         label = "Zbrojownia H.C.",
      },
      {
         coords = vec3(382.65490722656, -1601.6481933594, 25.361972808838), --davis
         size = vec3(4.4, 1, 2.35),
         rotation = 0.0,
         icon = "fa-solid fa-people-roof",
         label = "Zbrojownia H.C.",
      },
   },
   Kosz = {
      {
         coords = vec3(-1042.6280517578, -820.11199951172, 10.951587677002), --vespucci
         size = vec3(4.4, 1, 2.35),
         rotation = 0.0,
         icon = "fa-solid fa-people-roof",
         label = "Kosz",
      },
      {
         coords = vec3(365.1697, -1598.6472, 25.4517), --davis
         size = vec3(4.4, 1, 2.35),
         rotation = 0.0,
         icon = "fa-solid fa-people-roof",
         label = "Kosz",
      },
   },
   PharmacySchowki = {
      {
         coords = vec3(-1031.9873046875, -818.4697265625, 10.951580047607), --vespucci
         size = vec3(0.95, 1.6, 2.75),
         rotation = 0.0,
         icon = "fa-solid fa-people-roof",
         label = "Schowek",
      },
      {
         coords = vec3(380.55911254883, -1632.9754638672, 29.759468078613), --davis
         size = vec3(0.95, 1.6, 2.75),
         rotation = 0.0,
         icon = "fa-solid fa-people-roof",
         label = "Schowek",
      },
   },
   CloakroomsPrivate = {
      {
         coords = vec3(-1052.8056640625, -821.05090332031, 10.951592445374), --mrpd
         size = vec3(4.2, 0.2, 2.05),
         rotation = 0.0,
         icon = "fa-solid fa-people-roof",
         label = "Szatnia prywatna",
      },
      {
         coords = vec3(381.26715087891, -1616.4206542969, 29.759475708008), --davis
         size = vec3(4.2, 0.2, 2.05),
         rotation = 0.0,
         icon = "fa-solid fa-people-roof",
         label = "Szatnia prywatna",
      },
   },
   Cloakrooms = {
      {
         coords = vec3(-1054.6209716797, -817.88562011719, 10.951592445374), --vespucci
         size = vec3(0.9, 4.1, 2.1),
         rotation = 0.0,
         icon = "fa-solid fa-people-roof",
         label = "Szatnia",
      },
      {
         coords = vec3(380.20922851562, -1611.9558105469, 29.759475708008), --davis
         size = vec3(0.9, 4.1, 2.1),
         rotation = 0.0,
         icon = "fa-solid fa-people-roof",
         label = "Szatnia",
      },
   },
}

Config.PoliceStations.Cars = {
   Vehicles = {
      {
         coords	= vector3(-418.9489, -350.2802, 33.6493), -- LS 5
         spawnPoint = vector3( -425.1623, -343.7780, 33.1091),
         heading	= 172.3051
      },
      {
         coords = vector3(-452.1808, 6005.7495, 31.8409), -- PALETO
         spawnPoint = vector3(-467.3922, 6031.5752, 31.3405),
         heading = 132.49
      },
      {
         coords = vector3(-1125.4073, -832.9854, 13.3633), -- CANALSY
         spawnPoint = vector3(-1122.0233, -844.1779, 13.4035),
         heading = 123.4813
      },
      {
         coords = vector3(-1079.0048, -856.1664, 5.0424), -- CANALSY
         spawnPoint = vector3(-1066.8285, -855.4083, 4.8674),
         heading = 211.6643
      },
      {
         coords = vec3(-1082.8408203125, -807.40496826172, 10.780227661133), -- vecpucci
         spawnPoint = vec3(-1091.4549560547, -818.46063232422, 10.182620048523),
         heading = 80.3296
      },
      {
         coords = vec3(-1071.5654296875, -830.55297851562, 5.0614566802979), -- vecpucci
         spawnPoint = vec3(-1081.8756103516, -821.78283691406, 4.4545202255249),
         heading = 128.4812
      },
      {
         coords = vec3(-1101.3278808594, -851.0185546875, 5.2262706756592), -- vecpucci
         spawnPoint = vec3(-1102.0275878906, -836.22473144531, 4.4545569419861),
         heading = 218.4812
      },
      {
         coords = vec3(359.34378051758, -1606.2902832031, 29.281478881836), -- davis
         spawnPoint = vec3(355.47268676758, -1597.0169677734, 28.683130264282),
         heading = 320.4812
      }
   },
   Boats = {
      { -- ls
         coords	= vector3(-793.634765625, -1492.0516357422, 1.5952173471451),
         spawnPoint = vector3(-797.42, -1502.67, 0.9),
         heading = 105.26
      },
      { -- sandy
         coords = vector3(714.17, 4122.62, 35.77),
         spawnPoint = vector3(702.13, 4120.45, 30.02),
         heading = 173.8
      },
      { -- paleto
         coords = vector3(-753.67, 6092.05, 1.46),
         spawnPoint = vector3(-752.81, 6085.61, -0.39),
         heading = 54.7
      },
      { -- chumash
         coords = vector3(-3420.4614257813, 955.94750976563, 8.3466844558716),
         spawnPoint = vector3(-3426.4572753906, 940.18499755859, -0.028635177761316),
         heading = 90.68
      },
      { -- molo
         coords = vector3(-1631.8667, -1160.3145, 2.3125),
         spawnPoint = vector3(-1639.8520507813, -1162.2503662109, 0.02326849848032),
         heading = 152.58
      },
      { -- doki
         coords = vector3(536.0390625, -2859.8942871094, 6.0453743934631),
         spawnPoint = vector3(524.27709960938, -2864.93359375, -0.45840790867805),
         heading = 102.82
      },
   },
   Helicopters = {
      {
         coords = vector3(-467.6176, 5996.9238, 31.2587), -- Paleto
         spawnPoint = vector3(-475.3270, 5988.6074, 31.3365),
         heading = 313.0348
      },
      {
         coords = vec3(-1105.4173583984, -831.05725097656, 37.928237915039), -- vespucci
         spawnPoint = vec3(-1095.9165039062, -835.41424560547, 38.319171905518),
         heading = 311.8357
      },
      {
         coords = vec3(-1096.3876953125, -846.35748291016, 37.927909851074), -- vespucci
         spawnPoint = vec3(-1095.9165039062, -835.41424560547, 38.319171905518),
         heading = 311.8357
      },
      {
         coords = vec3(384.40081787109, -1611.8359375, 38.026428222656), -- davis
         spawnPoint = vec3(386.2451171875, -1620.6378173828, 38.419979095459),
         heading = 229.8357
      },
   },
   VehicleFix = {},
   VehicleAddons = {
      {
         coords = vector3(-1126.0144, -863.3683, 13.5664) -- canalsy
      },
      {
         coords = vec3(-1118.349609375, -849.06756591797, 4.4532556533813)
      },
      {
         coords = vec3(362.17901611328, -1599.0184326172, 28.682794570923)
      }
   },
   VehicleDeleters = { 
      {
         coords = vector3(449.9179, -986.7402, 25.7096)
      },
      {
         coords = vector3(-425.1623, -343.7780, 33.1091) -- LS 4
      },
      {
         coords = vector3(-1116.8959, -853.4543, 13.4838) -- canals
      },
      {
         coords = vector3(-1072.0721, -856.8826, 4.8673) -- canals 2
      },
      {
         coords = vector3(-797.42, -1502.67, 0.01) -- boat - ls
      },
      {
         coords = vector3(702.13, 4120.45, 30.5) -- boat - sandy
      },
      {
         coords = vector3(-752.81, 6085.61, 0.2) -- boat - paleto
      },
      {
         coords = vector3(-3426.4572753906, 940.18499755859, -0.028635177761316+0.6) -- boat - chumash
      },
      {
         coords = vector3(-1639.8520507813, -1162.2503662109, 0.02326849848032+1) -- boat - molo
      },
      {
         coords = vector3(524.27709960938, -2864.93359375, -0.45840790867805+1) -- boat - doki
      },
      {
         coords = vec3(-1089.2193603516, -848.12030029297, 4.4545044898987)
      },
      {
         coords = vec3(-1090.3365478516, -803.05444335938, 10.17335319519)
      },
      {
         coords = vec3(389.23538208008, -1612.8995361328, 29.292091369629)
      },
      {
         coords = vec3(350.38131713867, -1592.8581542969, 28.6848487854)
      },
   },
}

Config.VehicleGroups = {
   'ADAM', -- 1
   'MARY', -- 2
   'OFF-ROAD', -- 3
   'TASK', -- 4
   'UNMARKED', -- 5
   'SEU', -- 6
   'SWAT', -- 7
   'HP', -- 8
}

Config.BoatsGroups = {
   'Łodzie', -- 1
   'Pościgowe', -- 2
}

Config.AuthorizedVehicles = {
   { 
      grade = 0,
      model = 'vc_polstanier',
      label = '[ADAM] Stanier Police Cruiser',
      groups = {1},
      livery = 0,
      extrason = {},
      extrasoff = {},
   },

   {
      grade = 2,
      model = 'vc_polfugitive',
      label = '[ADAM] Cheval Fugitive ',
      groups = {1},
      livery = 0,
      extrason = {1,2,3,6,7,8,9,10,11,12},
      extrasoff = {},
   },

   {
      grade = 3,
      model = 'vc_polbuffalosx',
      label = '[ADAM] Bravado Buffalo SX',
      groups = {1},
      livery = 0,
      extrason = {1,2,3,5,6,7,8,9,10,11,12},
      extrasoff = {},
   },

   
-- SEU --

   {
      grade = 0,
      model = 'vc_polsultanrs',
      label = '[SEU] Sultan RS',
      groups = {6},
      livery = 0,
      extrason = {1,3,4,5,6,7,8},
      extrasoff = {9},
   },

   {
      grade = 0,
      model = 'vc_polbuffalostx',
      label = '[SEU] Buffalo STX',
      groups = {6},
      livery = 0,
      extrason = {1,3,4,5,6,7,8},
      extrasoff = {9},
   },

   {
      grade = 12,
      color = 0,
      model = 'vc_polgauntleth',
      label = '[SEU] Gauntlet Interceptor',
      groups = {5},
      livery = 0,
      extrason = {1,3,4,5,6,7,8},
      extrasoff = {9},
   },

   {
      grade = 12,
      color = 0,
      model = 'vc_poldominatorgtx',
      label = '[SEU] Dominator GTX',
      groups = {5},
      livery = 0,
      extrason = {1,3,4,5,6,7,8},
      extrasoff = {9},
   },

      {
      grade = 12,
      color = 0,
      model = 'vc_polvigerozx',
      label = '[SEU] Vigero ZX',
      groups = {5},
      livery = 0,
      extrason = {1,3,4,5,6,7,8},
      extrasoff = {9},
   },


   --- MARY ---

   {
      grade = 2,
      model = 'policeb',
      label = '[MARY] Police Bike',
      groups = {2},
      livery = 0,
      extrason = {},
      extrasoff = {},
   },

   --- BOY ---

   {
      grade = 1,
      model = 'vc_polscout',
      label = '[BOY] Scout',
      groups = {3},
      livery = 0,
      extrason = {2,3,4,5,6,7,8,9,10,11},
      extrasoff = {},
   },

   {
      grade = 2,
      model = 'vc_polpatriot',
      label = '[BOY] Patriot',
      groups = {3},
      livery = 0,
      extrason = {1,2,3,4,5,6},
      extrasoff = {},
   },
  
   {
      grade = 2,
      model = 'vc_polgranger',
      label = '[BOY] Granger 3600LX',
      groups = {3},
      livery = 0,
      extrason = {1,2,3,4,5,6,7,8,9,10,11,12},
      extrasoff = {},
   },
   {
      grade = 3,
      model = 'vc_polgresley',
      label = '[BOY] Gresley XL',
      groups = {3},
      livery = 0,
      extrason = {1,2,3,4,5,6,7,8,9,10,11,12},
      extrasoff = {},
   },
   {
      grade = 3,
      model = 'vc_polterminus',
      label = '[BOY] Terminus',
      groups = {3},
      livery = 0,
      extrason = {1,2,3,4,5,6,7,8,9,10,11,12},
      extrasoff = {},
   },
   {
      grade = 4,
      model = 'vc_polbisonxl',
      label = '[BOY] Bison XL',
      groups = {3},
      livery = 0,
      extrason = {1,2,3,4,5,6,7,8,9,10,11,12},
      extrasoff = {},
   },
   {
      grade = 4,
      model = 'vc_polcaracara',
      label = '[BOY] Caracara 4x4',
      groups = {3},
      livery = 0,
      extrason = {1,3,4,5,6},
      extrasoff = {},
   },

   --- TASK ---

   {
      grade = 1,
      model = 'pbus',
      label = '[TASK] Autobus Transportowy',
      groups = {4},
      livery = 0,
      extrason = {1,2,5,7,8,9,10,11,12},
      extrasoff = {3,4,6},
   },

   {
      grade = 3,
      model = 'riot',
      label = '[TASK] Wiezniarka Riot',
      groups = {4},
      livery = 0,
      extrason = {1,2,5,7,8,9,10,11,12},
      extrasoff = {3,4,6},
   },


   --- UNMARKED ---

   {
      grade = 12,
      color = 0,
      model = 'vc_polbuffalosx',
      label = '[UNMARKED] Bravado Buffalo SX',
      groups = {5},
      livery = 3,
      extrason = {7},
      extrasoff = {1,2,3,4,5,6,8,9,10,11,12},
   },

   {
      grade = 12,
      color = 0,
      model = 'vc_polstanier',
      label = '[UNMARKED] Stanier Police Cruiser',
      groups = {5},
      livery = 3,
      extrason = {7},
      extrasoff = {1,2,3,4,5,6,8,9,10,11,12},
   },

   {
      grade = 12,
      color = 0,
      model = 'vc_polgauntleth',
      label = '[UNMARKED] Gauntlet Interceptor',
      groups = {5},
      livery = 3,
      extrason = {2},
      extrasoff = {1,3,4,5,6,7,8,9},
   },

   {
      grade = 12,
      color = 0,
      model = 'vc_poldominatorgtx',
      label = '[UNMARKED] Dominator GTX',
      groups = {5},
      livery = 3,
      extrason = {2},
      extrasoff = {1,3,4,5,8,9},
   },

      {
      grade = 12,
      color = 0,
      model = 'vc_polvigerozx',
      label = '[UNMARKED] Vigero ZX',
      groups = {5},
      livery = 3,
      extrason = {2},
      extrasoff = {1,3,4,5,8,9},
   },

   {
      grade = 3,
      color = 0,
      model = 'vc_polthrust',
      label = '[MARY] Dinka Thrust',
      groups = {2},
      livery = 0,
      extrason = {1,2,3,4,5,8},
      extrasoff = {9},
   },
}

Config.AuthorizedBoats = {
   {
      grade = 6,
      model = 'predator',
      label = 'Motorówka',
      groups = {1},
      livery = 0,
      extrason = {},
      extrasoff = {},
   },
}

Config.GPS = {
   jobs = {
      { name = 'police',label = "LSPD" },
      { name = 'ambulance',label = "SAMS" },
      { name = 'mechanik',label = "LSC" },
   }
}
Config.Crime = {
    item = 'kabelki', -- narazie nie ma itemku hehe (do wykminieni hehe)
    duration = 10000
}
Config.Bracelet = {
    item_put = 'opaski',
    item_remove = 'klucz_do_opaski',
    job = 'police',
    blip = { sprite = 66, color = 1, scale = 0.9 },
    remove_price = 50000, 
    npc = {
        model = `csb_rashcosvki`,
        coords = vector4(1892.5934, 610.7098, 189.8230, 61.0436),
    }
}