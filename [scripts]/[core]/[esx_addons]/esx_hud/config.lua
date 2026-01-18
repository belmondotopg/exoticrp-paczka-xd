Config = {}
Config.Avatar = true

Config.StatisticsLabels = {
    ["stamina"] = "Kondycja",
    ["strength"] = "Siła",
    ["lung"] = "Płuca",
}

Config.ShopPrices = {
    clotheshop = 500,
    barbershop = 500
}

Config.CardsLocale = {
    ["document-id"] = function(data)
        local CharacterName = data.get("firstName") .. " " .. data.get("lastName")
        return "Wyciąga z portfela Dowód Osobisty (" .. CharacterName .. ")"
    end,
    ["business-card"] = function(data)
        local CharacterName = data.get("firstName") .. " " .. data.get("lastName")
    
        local PhoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(data.source)
        if not PhoneNumber then
            PhoneNumber = "Brak numeru telefonu"
        end
    
        return "Wyciąga z portfela Wizytówkę (" .. CharacterName .. " - " .. PhoneNumber .. ")"
    end,
    ["badge"] = function(data)
        local CharacterName = data.get("firstName") .. " " .. data.get("lastName")
        local CharacterJob = data.job.label .. " - " .. data.job.grade_label
        local rawBadge = data.get("badge") or "0"
        
        local Badge = rawBadge:gsub("%D", "")

        
        return "Wyciąga odznake: [" .. Badge .. "] " .. CharacterName .. " - " .. CharacterJob
    end
}

Config.CardsData = {
    ["document-id"] = {
		mugshot = function(data, MugShot)
			return MugShot
		end,
		firstName = function(data)
			return data.get("firstName")
		end,
		lastName = function(data)
			return data.get("lastName")
		end,
		ssn = function(data)
			return Player(data.source).state.ssn
		end,
		birthDate = function(data)
			local dateofbirth = data.get("dateofbirth")
			if not dateofbirth then
				return nil
			end
			
			if type(dateofbirth) == "number" then
				return dateofbirth
			end
			
			if type(dateofbirth) == "string" then
				local year, month, day = dateofbirth:match("(%d+)-(%d+)-(%d+)")
				if year and month and day then
					local date = os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = 0, min = 0, sec = 0})
					return date
				end
				
				day, month, year = dateofbirth:match("(%d+)/(%d+)/(%d+)")
				if day and month and year then
					local date = os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = 0, min = 0, sec = 0})
					return date
				end
			end
			
			return nil
		end,
		gender = function(data)
			return data.get("sex")
		end,
		nationality = function(data)
			return data.get("nationality")
		end,
		gunLicense = function(data, MugShot, PlayerLicenses)
			return PlayerLicenses["weapon"]
		end,
		height = function(data)
			return data.get("height")
		end,
		drivingLicense = {
			a = function(data, MugShot, PlayerLicenses)
				return PlayerLicenses["drive_bike"]
			end,
			b = function(data, MugShot, PlayerLicenses)
				return PlayerLicenses["drive"]
			end,
			c = function(data, MugShot, PlayerLicenses)
				return PlayerLicenses["drive_truck"]
			end
		}
	},
	["business-card"] = {
		mugshot = function(data, MugShot)
			return MugShot
		end,
		firstName = function(data)
			return data.get("firstName")
		end,
		lastName = function(data)
			return data.get("lastName")
		end,
		ssn = function(data)
			return Player(data.source).state.ssn
		end,
		phoneNumber = function(data)
			return exports["lb-phone"]:GetEquippedPhoneNumber(data.source)
		end,
		job = function(data)
			return data.job.label .. " - " .. data.job.grade_label
		end
	},
	["badge"] = {
        firstName = function(data)
			return data.get("firstName")
		end,
		lastName = function(data)
			return data.get("lastName")
		end,
		mugshot = function(data, MugShot)
			return MugShot
		end,
        ssn = function(data)
			return Player(data.source).state.ssn
		end,
		badge = function(data) 
            local rawBadge = data.get("badge") or "0"
            local Badge = rawBadge:gsub("%D", "")
			return Badge
		end,
		grade = function(data)
			return data.job.grade_label
		end,
		fraction = function(data)
			return data.job.label
		end
	}
}

Config.DailyCase = {
    ["money"] = {
        ["Chance"] = {0,10},
        ["Amount"] = {1000, 5000}
    },
    ["WEAPON_PISTOL"] = {
        ["Chance"] = {11,15},
        ["Amount"] = {1, 1}
    },
    ["cocaine_packaged"] = {
        ["Chance"] = {16,25},
        ["Amount"] = {5, 10}
    },
    ["trap_phone"] = {
        ["Chance"] = {26,35},
        ["Amount"] = {1, 2}
    },
    ["zakpendrive"] = {
        ["Chance"] = {36,50},
        ["Amount"] = {1, 2}
    },
    ["infected_disk"] = {
        ["Chance"] = {51,60},
        ["Amount"] = {1, 2}
    },
    ["spust"] = {
        ["Chance"] = {61,70},
        ["Amount"] = {1, 2}
    },
    ["malalufa"] = {
        ["Chance"] = {71,80},
        ["Amount"] = {1, 2}
    }
}

Config.NametagColors = {
    ["Founder"] = {14, 13, 13, 255},
    ["Owner"] = {63, 60, 60, 255},
    ["Co-Owner"] = {243, 255, 167, 255},
    ["Management"] = {56, 30, 30, 255},
    ["Head Administrator"] = {87, 18, 18, 255},
    ["Administrator"] = {255, 73, 73, 255},
    ["Trial Administrator"] = {255, 109, 109, 255},
    ["Senior Moderator"] = {158, 121, 0, 255},
    ["Moderator"] = {228, 175, 3, 255},
    ["Trial Moderator"] = {255, 210, 64, 255},
    ["Support"] = {47, 148, 0, 255},
    ["Trial Support"] = {149, 255, 100, 255}
}

Config.DMVQuestionTable = {
    {
        question = "Jeśli masz 80 km/h, a zbliżasz się do terenu zabudowanego, musisz:",
        answers = {
            { text = "Przyspieszyć", correct = false },
            { text = "Zahamować po czym jechać 50 km/h", correct = false },
            { text = "Zwolnić", correct = true },
            { text = "Zachować prędkość", correct = false },
        }
    },

    {
        question = "Jeśli skręcasz w prawo na światłach bezkolizyjnych, ale widzisz przejście dla pieszych, co robisz:",
        answers = {
            { text = "Przepuszczam pieszego", correct = false },
            { text = "Sprawdzam, czy w pobliżu nie ma innych pojazdów", correct = false },
            { text = "Zachowuje szczególną ostrożność i przejeżdżam", correct = true },
            { text = "Ignoruje pieszego", correct = false },
        }
    },

    {
        question = "Bez wcześniejszego wskazania prędkość w obszarze zabudowanym wynosi = __ km/h",
        answers = {
            { text = "40", correct = false },
            { text = "50", correct = true },
            { text = "60", correct = false },
            { text = "70", correct = false },
        }
    },

    {
        question = "Przed każdą zmianą pasa ruchu należy:",
        answers = {
            { text = "Spojrzeć w lusterka", correct = false },
            { text = "Sprawdzić swoje martwe pole", correct = false },
            { text = "Zasygnalizować swoje zamiary", correct = false },
            { text = "Wszystko powyższe", correct = true },
        }
    },

    {
        question = "Jaki poziom alkoholu we krwi NIE jest klasyfikowany jako jazda po pijanemu?",
        answers = {
            { text = "0.02%", correct = true },
            { text = "0.19%", correct = false },
            { text = "0.05%", correct = false },
            { text = "0.04%", correct = false },
        }
    },

    {
        question = "Kiedy możesz kontynuować jazdę na światłach?",
        answers = {
            { text = "Kiedy zaświeci się zielone", correct = true },
            { text = "Kiedy nie ma nikogo na skrzyżowaniu", correct = false },
            { text = "Kiedy zaświeci się żółte", correct = false },
            { text = "Kiedy jest zielony lub czerwony ale skręcasz w prawo", correct = false },
        }
    },

    {
        question = "Przewożąc ładunek gabarytowy możesz poruszać się tylko:",
        answers = {
            { text = "Drogami do tego przeznaczonymi", correct = true },
            { text = "Nocami", correct = false },
            { text = "Drogami ekspresowymi", correct = false },
            { text = "Skrzyżowaniami o ruchu okrężnym", correct = false },
        }
    },

    {
        question = "Posiadając prawo jazdy kategorii B możesz prowadzić :",
        answers = {
            { text = "Pojazdem samochodowym o dopuszczalnej masie całkowitej nieprzekraczającej 3.5 t, z wyjątkiem autobusu i motocykla", correct = false },
            { text = "Zespołem pojazdów złożonym z pojazdu, o którym mowa wyżej, oraz z przyczepy lekkiej", correct = false },
            { text = "Zespołem pojazdów złożonym z pojazdu, o którym mowa wyżej, oraz z przyczepy innej niż lekka, o ile łączna dopuszczalna masa całkowita zespołu tych pojazdów nie przekracza 4250 kg", correct = false },
            { text = "Wszystkie powyższe", correct = true },
        }
    },

    {
        question = "Jedziesz autostradą, która wskazuje maksymalną prędkość 120 km/h. Większość aut jedzie z prędkością 140km/h, więc nie powinieneś jechać szybciej niż:",
        answers = {
            { text = "120 km/h", correct = true },
            { text = "130 km/h", correct = false },
            { text = "140 km/h", correct = false },
            { text = "150 km/h", correct = false },
        }
    },

    {
        question = "Wyprzedzając inne pojazdy należy:",
        answers = {
            { text = "Zwolnić", correct = false },
            { text = "Trąbić na wyprzedzany pojazd", correct = false },
            { text = "Oglądać wyprzedzany pojazd", correct = false },
            { text = "Zwiększyć prędkość", correct = true },
        }
    },
}

Config.WeaponQuestionTable = {
    {
        question = "Jaki jest minimalny wiek wymagany do uzyskania licencji na broń w stanie San Andreas?",
        answers = {
            { text = "16 lat", correct = false },
            { text = "18 lat", correct = false },
            { text = "21 lat", correct = true },
        }
    },

    {
        question = "Co grozi za posiadanie broni palnej bez ważnej licencji w Los Santos?",
        answers = {
            { text = "Mandat pieniężny", correct = false },
            { text = "Konfiskata broni i kara więzienia", correct = true },
            { text = "Tymczasowe odebranie prawa jazdy", correct = false },
        }
    },

    {
        question = "Czy licencja na broń w Los Santos pozwala nosić ją w każdym miejscu?",
        answers = {
            { text = "Tak, bez żadnych ograniczeń", correct = false },
            { text = "Tylko w dzielnicach mieszkalnych", correct = false },
            { text = "Nie, obowiązują określone strefy i zasady", correct = true },
        }
    },

    {
        question = "Który rodzaj broni wymaga ukończenia szkolenia przed uzyskaniem licencji?",
        answers = {
            { text = "Broń palna", correct = true },
            { text = "Broń biała", correct = false },
            { text = "Broń kolekcjonerska", correct = false },
        }
    },

    {
        question = "Która z poniższych sytuacji może skutkować cofnięciem licencji na broń?",
        answers = {
            { text = "Zgubienie dokumentu tożsamości", correct = false },
            { text = "Popełnienie poważnego przestępstwa", correct = true },
            { text = "Zmiana miejsca zamieszkania", correct = false },
        }
    },

    {
        question = "Co jest sprawdzane podczas badań psychologicznych przed wydaniem licencji?",
        answers = {
            { text = "Stabilność psychiczna i odporność na stres", correct = true },
            { text = "Styl życia i hobby", correct = false },
            { text = "Status majątkowy", correct = false },
        }
    },

    {
        question = 'Kim jest "uprawniony posiadacz broni" w Los Santos?',
        answers = {
            { text = "Osobą, która posiada broń do celów kolekcjonerskich", correct = false },
            { text = "Osobą zarejestrowaną i posiadającą ważną licencję", correct = true },
            { text = "Funkcjonariuszem służb publicznych", correct = false },
        }
    },

    {
        question = "Czy jedna licencja pozwala na zakup nieograniczonej ilości broni?",
        answers = {
            { text = "Tak", correct = false },
            { text = "Nie, obowiązują limity", correct = true },
            { text = "Tylko po zdaniu dodatkowego egzaminu", correct = false },
        }
    },

    {
        question = "Co obejmuje szkolenie z pierwszej pomocy wymagane przy licencji na broń?",
        answers = {
            { text = "Podstawowe techniki ratowania życia i tamowanie krwotoków", correct = true },
            { text = "Wyłącznie obsługę defibrylatora", correct = false },
            { text = "Tylko teorię bez ćwiczeń praktycznych", correct = false },
        }
    },

    {
        question = "Czy osoba z historią problemów psychicznych może uzyskać licencję na broń?",
        answers = {
            { text = "Nie, w żadnym przypadku", correct = false },
            { text = "Tak, jeśli pozytywnie przejdzie ocenę psychologiczną", correct = true },
            { text = "Tak, bez dodatkowych badań", correct = false },
        }
    },

    {
        question = "Czym różni się licencja na broń krótką od licencji na broń długą?",
        answers = {
            { text = "Rodzajem i konstrukcją broni", correct = true },
            { text = "Kolorem i wykończeniem", correct = false },
            { text = "Miejscem zakupu broni", correct = false },
        }
    },

    {
        question = "Kto przeprowadza egzamin oraz rozmowę kwalifikacyjną na licencję na broń?",
        answers = {
            { text = "Pracownik sklepu z bronią", correct = false },
            { text = "Stanowa komisja licencyjna San Andreas", correct = true },
            { text = "Psycholog policyjny", correct = false },
        }
    },

    {
        question = 'Co oznacza pojęcie "dobra reputacja" w procesie przyznawania licencji?',
        answers = {
            { text = "Brak poważnych wykroczeń i przestępstw w przeszłości", correct = true },
            { text = "Wysokie dochody", correct = false },
            { text = "Znajomości w administracji stanowej", correct = false },
        }
    },

    {
        question = "Jakie działania może podjąć obywatel po odmowie wydania licencji na broń?",
        answers = {
            { text = "Zignorować decyzję i złożyć nowy wniosek", correct = false },
            { text = "Złożyć wniosek o ponowne rozpatrzenie decyzji", correct = true },
            { text = "Kupić broń nielegalnie", correct = false },
        }
    },

    {
        question = "Dlaczego w stanie San Andreas wprowadzono obowiązek licencji na broń?",
        answers = {
            { text = "W celu zwiększenia bezpieczeństwa publicznego", correct = true },
            { text = "Aby ograniczyć sprzedaż amunicji", correct = false },
            { text = "Z powodów czysto administracyjnych", correct = false },
        }
    },
}

Config.Peds = {
    pedConfig = {
        {
            peds = {
                "mp_m_freemode_01",
                "mp_f_freemode_01",
                "a_f_m_beach_01",
                "a_f_m_bevhills_01",
                "a_f_m_bevhills_02",
                "a_f_m_bodybuild_01",
                "a_f_m_business_02",
                "a_f_m_downtown_01",
                "a_f_m_eastsa_01",
                "a_f_m_eastsa_02",
                "a_f_m_fatbla_01",
                "a_f_m_fatcult_01",
                "a_f_m_fatwhite_01",
                "a_f_m_ktown_01",
                "a_f_m_ktown_02",
                "a_f_m_prolhost_01",
                "a_f_m_salton_01",
                "a_f_m_skidrow_01",
                "a_f_m_soucent_01",
                "a_f_m_soucent_02",
                "a_f_m_soucentmc_01",
                "a_f_m_tourist_01",
                "a_f_m_tramp_01",
                "a_f_m_trampbeac_01",
                "a_f_o_genstreet_01",
                "a_f_o_indian_01",
                "a_f_o_ktown_01",
                "a_f_o_salton_01",
                "a_f_o_soucent_01",
                "a_f_o_soucent_02",
                "a_f_y_beach_01",
                "a_f_y_bevhills_01",
                "a_f_y_bevhills_02",
                "a_f_y_bevhills_03",
                "a_f_y_bevhills_04",
                "a_f_y_business_01",
                "a_f_y_business_02",
                "a_f_y_business_03",
                "a_f_y_business_04",
                "a_f_y_clubcust_01",
                "a_f_y_clubcust_02",
                "a_f_y_clubcust_03",
                "a_f_y_eastsa_01",
                "a_f_y_eastsa_02",
                "a_f_y_eastsa_03",
                "a_f_y_epsilon_01",
                "a_f_y_femaleagent",
                "a_f_y_fitness_01",
                "a_f_y_fitness_02",
                "a_f_y_genhot_01",
                "a_f_y_golfer_01",
                "a_f_y_hiker_01",
                "a_f_y_hippie_01",
                "a_f_y_hipster_01",
                "a_f_y_hipster_02",
                "a_f_y_hipster_03",
                "a_f_y_hipster_04",
                "a_f_y_indian_01",
                "a_f_y_juggalo_01",
                "a_f_y_runner_01",
                "a_f_y_rurmeth_01",
                "a_f_y_scdressy_01",
                "a_f_y_skater_01",
                "a_f_y_soucent_01",
                "a_f_y_soucent_02",
                "a_f_y_soucent_03",
                "a_f_y_tennis_01",
                "a_f_y_topless_01",
                "a_f_y_tourist_01",
                "a_f_y_tourist_02",
                "a_f_y_vinewood_01",
                "a_f_y_vinewood_02",
                "a_f_y_vinewood_03",
                "a_f_y_vinewood_04",
                "a_f_y_yoga_01",
                "a_f_y_gencaspat_01",
                "a_f_y_smartcaspat_01",
                "a_m_m_acult_01",
                "a_m_m_afriamer_01",
                "a_m_m_beach_01",
                "a_m_m_beach_02",
                "a_m_m_bevhills_01",
                "a_m_m_bevhills_02",
                "a_m_m_business_01",
                "a_m_m_eastsa_01",
                "a_m_m_eastsa_02",
                "a_m_m_farmer_01",
                "a_m_m_fatlatin_01",
                "a_m_m_genfat_01",
                "a_m_m_genfat_02",
                "a_m_m_golfer_01",
                "a_m_m_hasjew_01",
                "a_m_m_hillbilly_01",
                "a_m_m_hillbilly_02",
                "a_m_m_indian_01",
                "a_m_m_ktown_01",
                "a_m_m_malibu_01",
                "a_m_m_mexcntry_01",
                "a_m_m_mexlabor_01",
                "a_m_m_og_boss_01",
                "a_m_m_paparazzi_01",
                "a_m_m_polynesian_01",
                "a_m_m_prolhost_01",
                "a_m_m_rurmeth_01",
                "a_m_m_salton_01",
                "a_m_m_salton_02",
                "a_m_m_salton_03",
                "a_m_m_salton_04",
                "a_m_m_skater_01",
                "a_m_m_skidrow_01",
                "a_m_m_socenlat_01",
                "a_m_m_soucent_01",
                "a_m_m_soucent_02",
                "a_m_m_soucent_03",
                "a_m_m_soucent_04",
                "a_m_m_stlat_02",
                "a_m_m_tennis_01",
                "a_m_m_tourist_01",
                "a_m_m_tramp_01",
                "a_m_m_trampbeac_01",
                "a_m_m_tranvest_01",
                "a_m_m_tranvest_02",
                "a_m_o_acult_01",
                "a_m_o_acult_02",
                "a_m_o_beach_01",
                "a_m_o_genstreet_01",
                "a_m_o_ktown_01",
                "a_m_o_salton_01",
                "a_m_o_soucent_01",
                "a_m_o_soucent_02",
                "a_m_o_soucent_03",
                "a_m_o_tramp_01",
                "a_m_y_acult_01",
                "a_m_y_acult_02",
                "a_m_y_beach_01",
                "a_m_y_beach_02",
                "a_m_y_beach_03",
                "a_m_y_beachvesp_01",
                "a_m_y_beachvesp_02",
                "a_m_y_bevhills_01",
                "a_m_y_bevhills_02",
                "a_m_y_breakdance_01",
                "a_m_y_busicas_01",
                "a_m_y_business_01",
                "a_m_y_business_02",
                "a_m_y_business_03",
                "a_m_y_clubcust_01",
                "a_m_y_clubcust_02",
                "a_m_y_clubcust_03",
                "a_m_y_cyclist_01",
                "a_m_y_dhill_01",
                "a_m_y_downtown_01",
                "a_m_y_eastsa_01",
                "a_m_y_eastsa_02",
                "a_m_y_epsilon_01",
                "a_m_y_epsilon_02",
                "a_m_y_gay_01",
                "a_m_y_gay_02",
                "a_m_y_genstreet_01",
                "a_m_y_genstreet_02",
                "a_m_y_golfer_01",
                "a_m_y_hasjew_01",
                "a_m_y_hiker_01",
                "a_m_y_hippy_01",
                "a_m_y_hipster_01",
                "a_m_y_hipster_02",
                "a_m_y_hipster_03",
                "a_m_y_indian_01",
                "a_m_y_jetski_01",
                "a_m_y_juggalo_01",
                "a_m_y_ktown_01",
                "a_m_y_ktown_02",
                "a_m_y_latino_01",
                "a_m_y_methhead_01",
                "a_m_y_mexthug_01",
                "a_m_y_motox_01",
                "a_m_y_motox_02",
                "a_m_y_musclbeac_01",
                "a_m_y_musclbeac_02",
                "a_m_y_polynesian_01",
                "a_m_y_roadcyc_01",
                "a_m_y_runner_01",
                "a_m_y_runner_02",
                "a_m_y_salton_01",
                "a_m_y_skater_01",
                "a_m_y_skater_02",
                "a_m_y_soucent_01",
                "a_m_y_soucent_02",
                "a_m_y_soucent_03",
                "a_m_y_soucent_04",
                "a_m_y_stbla_01",
                "a_m_y_stbla_02",
                "a_m_y_stlat_01",
                "a_m_y_stwhi_01",
                "a_m_y_stwhi_02",
                "a_m_y_sunbathe_01",
                "a_m_y_surfer_01",
                "a_m_y_vindouche_01",
                "a_m_y_vinewood_01",
                "a_m_y_vinewood_02",
                "a_m_y_vinewood_03",
                "a_m_y_vinewood_04",
                "a_m_y_yoga_01",
                "a_m_m_mlcrisis_01",
                "a_m_y_gencaspat_01",
                "a_m_y_smartcaspat_01",
                "a_c_boar",
                "a_c_cat_01",
                "a_c_chickenhawk",
                "a_c_chimp",
                "a_c_chop",
                "a_c_cormorant",
                "a_c_cow",
                "a_c_coyote",
                "a_c_crow",
                "a_c_deer",
                "a_c_dolphin",
                "a_c_fish",
                "a_c_hen",
                "a_c_humpback",
                "a_c_husky",
                "a_c_killerwhale",
                "a_c_mtlion",
                "a_c_pig",
                "a_c_pigeon",
                "a_c_poodle",
                "a_c_pug",
                "a_c_rabbit_01",
                "a_c_rat",
                "a_c_retriever",
                "a_c_rhesus",
                "a_c_rottweiler",
                "a_c_seagull",
                "a_c_sharkhammer",
                "a_c_sharktiger",
                "a_c_shepherd",
                "a_c_stingray",
                "a_c_westy",
                "cs_amandatownley",
                "cs_andreas",
                "cs_ashley",
                "cs_bankman",
                "cs_barry",
                "cs_beverly",
                "cs_brad",
                "cs_bradcadaver",
                "cs_carbuyer",
                "cs_casey",
                "cs_chengsr",
                "cs_chrisformage",
                "cs_clay",
                "cs_dale",
                "cs_davenorton",
                "cs_debra",
                "cs_denise",
                "cs_devin",
                "cs_dom",
                "cs_dreyfuss",
                "cs_drfriedlander",
                "cs_fabien",
                "cs_fbisuit_01",
                "cs_floyd",
                "cs_guadalope",
                "cs_gurk",
                "cs_hunter",
                "cs_janet",
                "cs_jewelass",
                "cs_jimmyboston",
                "cs_jimmydisanto",
                "cs_joeminuteman",
                "cs_johnnyklebitz",
                "cs_josef",
                "cs_josh",
                "cs_karen_daniels",
                "cs_lamardavis",
                "cs_lazlow",
                "cs_lazlow_2",
                "cs_lestercrest",
                "cs_lifeinvad_01",
                "cs_magenta",
                "cs_manuel",
                "cs_marnie",
                "cs_martinmadrazo",
                "cs_maryann",
                "cs_michelle",
                "cs_milton",
                "cs_molly",
                "cs_movpremf_01",
                "cs_movpremmale",
                "cs_mrk",
                "cs_mrs_thornhill",
                "cs_mrsphillips",
                "cs_natalia",
                "cs_nervousron",
                "cs_nigel",
                "cs_old_man1a",
                "cs_old_man2",
                "cs_omega",
                "cs_orleans",
                "cs_paper",
                "cs_patricia",
                "cs_priest",
                "cs_prolsec_02",
                "cs_russiandrunk",
                "cs_siemonyetarian",
                "cs_solomon",
                "cs_stevehains",
                "cs_stretch",
                "cs_tanisha",
                "cs_taocheng",
                "cs_taostranslator",
                "cs_tenniscoach",
                "cs_terry",
                "cs_tom",
                "cs_tomepsilon",
                "cs_tracydisanto",
                "cs_wade",
                "cs_zimbor",
                "csb_abigail",
                "csb_agent",
                "csb_alan",
                "csb_anita",
                "csb_anton",
                "csb_avon",
                "csb_ballasog",
                "csb_bogdan",
                "csb_bride",
                "csb_bryony",
                "csb_burgerdrug",
                "csb_car3guy1",
                "csb_car3guy2",
                "csb_chef",
                "csb_chef2",
                "csb_chin_goon",
                "csb_cletus",
                "csb_cop",
                "csb_customer",
                "csb_denise_friend",
                "csb_dix",
                "csb_djblamadon",
                "csb_englishdave",
                "csb_fos_rep",
                "csb_g",
                "csb_groom",
                "csb_grove_str_dlr",
                "csb_hao",
                "csb_hugh",
                "csb_imran",
                "csb_jackhowitzer",
                "csb_janitor",
                "csb_maude",
                "csb_money",
                "csb_mp_agent14",
                "csb_mrs_r",
                "csb_mweather",
                "csb_ortega",
                "csb_oscar",
                "csb_paige",
                "csb_popov",
                "csb_porndudes",
                "csb_prologuedriver",
                "csb_prolsec",
                "csb_ramp_gang",
                "csb_ramp_hic",
                "csb_ramp_hipster",
                "csb_ramp_marine",
                "csb_ramp_mex",
                "csb_rashcosvki",
                "csb_reporter",
                "csb_roccopelosi",
                "csb_screen_writer",
                "csb_sol",
                "csb_stripper_01",
                "csb_stripper_02",
                "csb_talcc",
                "csb_talmm",
                "csb_tonya",
                "csb_tonyprince",
                "csb_trafficwarden",
                "csb_undercover",
                "csb_vagspeak",
                "csb_agatha",
                "csb_avery",
                "csb_brucie2",
                "csb_thornton",
                "csb_tomcasino",
                "csb_vincent",
                "g_f_importexport_01",
                "g_f_importexport_01",
                "g_f_y_ballas_01",
                "g_f_y_families_01",
                "g_f_y_lost_01",
                "g_f_y_vagos_01",
                "g_m_importexport_01",
                "g_m_m_armboss_01",
                "g_m_m_armgoon_01",
                "g_m_m_armlieut_01",
                "g_m_m_chemwork_01",
                "g_m_m_chiboss_01",
                "g_m_m_chicold_01",
                "g_m_m_chigoon_01",
                "g_m_m_chigoon_02",
                "g_m_m_korboss_01",
                "g_m_m_mexboss_01",
                "g_m_m_mexboss_02",
                "g_m_y_armgoon_02",
                "g_m_y_azteca_01",
                "g_m_y_ballaeast_01",
                "g_m_y_ballaorig_01",
                "g_m_y_ballasout_01",
                "g_m_y_famca_01",
                "g_m_y_famdnf_01",
                "g_m_y_famfor_01",
                "g_m_y_korean_01",
                "g_m_y_korean_02",
                "g_m_y_korlieut_01",
                "g_m_y_lost_01",
                "g_m_y_lost_02",
                "g_m_y_lost_03",
                "g_m_y_mexgang_01",
                "g_m_y_mexgoon_01",
                "g_m_y_mexgoon_02",
                "g_m_y_mexgoon_03",
                "g_m_y_pologoon_01",
                "g_m_y_pologoon_02",
                "g_m_y_salvaboss_01",
                "g_m_y_salvagoon_01",
                "g_m_y_salvagoon_02",
                "g_m_y_salvagoon_03",
                "g_m_y_strpunk_01",
                "g_m_y_strpunk_02",
                "g_m_m_casrn_01",
                "mp_f_bennymech_01",
                "mp_f_boatstaff_01",
                "mp_f_cardesign_01",
                "mp_f_chbar_01",
                "mp_f_cocaine_01",
                "mp_f_counterfeit_01",
                "mp_f_deadhooker",
                "mp_f_execpa_01",
                "mp_f_execpa_02",
                "mp_f_forgery_01",
                "mp_f_helistaff_01",
                "mp_f_meth_01",
                "mp_f_misty_01",
                "mp_f_stripperlite",
                "mp_f_weed_01",
                "mp_g_m_pros_01",
                "mp_m_avongoon",
                "mp_m_boatstaff_01",
                "mp_m_bogdangoon",
                "mp_m_claude_01",
                "mp_m_cocaine_01",
                "mp_m_counterfeit_01",
                "mp_m_exarmy_01",
                "mp_m_execpa_01",
                "mp_m_famdd_01",
                "mp_m_fibsec_01",
                "mp_m_forgery_01",
                "mp_m_g_vagfun_01",
                "mp_m_marston_01",
                "mp_m_meth_01",
                "mp_m_niko_01",
                "mp_m_securoguard_01",
                "mp_m_shopkeep_01",
                "mp_m_waremech_01",
                "mp_m_weapexp_01",
                "mp_m_weapwork_01",
                "mp_m_weed_01",
                "mp_s_m_armoured_01",
                "s_f_m_fembarber",
                "s_f_m_maid_01",
                "s_f_m_shop_high",
                "s_f_m_sweatshop_01",
                "s_f_y_airhostess_01",
                "s_f_y_bartender_01",
                "s_f_y_baywatch_01",
                "s_f_y_clubbar_01",
                "s_f_y_cop_01",
                "s_f_y_factory_01",
                "s_f_y_hooker_01",
                "s_f_y_hooker_02",
                "s_f_y_hooker_03",
                "s_f_y_migrant_01",
                "s_f_y_movprem_01",
                "s_f_y_ranger_01",
                "s_f_y_scrubs_01",
                "s_f_y_sheriff_01",
                "s_f_y_shop_low",
                "s_f_y_shop_mid",
                "s_f_y_stripper_01",
                "s_f_y_stripper_02",
                "s_f_y_stripperlite",
                "s_f_y_sweatshop_01",
                "s_f_y_casino_01",
                "s_m_m_ammucountry",
                "s_m_m_armoured_01",
                "s_m_m_armoured_02",
                "s_m_m_autoshop_01",
                "s_m_m_autoshop_02",
                "s_m_m_bouncer_01",
                "s_m_m_ccrew_01",
                "s_m_m_chemsec_01",
                "s_m_m_ciasec_01",
                "s_m_m_cntrybar_01",
                "s_m_m_dockwork_01",
                "s_m_m_doctor_01",
                "s_m_m_fiboffice_01",
                "s_m_m_fiboffice_02",
                "s_m_m_fibsec_01",
                "s_m_m_gaffer_01",
                "s_m_m_gardener_01",
                "s_m_m_gentransport",
                "s_m_m_hairdress_01",
                "s_m_m_highsec_01",
                "s_m_m_highsec_02",
                "s_m_m_janitor",
                "s_m_m_lathandy_01",
                "s_m_m_lifeinvad_01",
                "s_m_m_linecook",
                "s_m_m_lsmetro_01",
                "s_m_m_mariachi_01",
                "s_m_m_marine_01",
                "s_m_m_marine_02",
                "s_m_m_migrant_01",
                "s_m_m_movalien_01",
                "s_m_m_movprem_01",
                "s_m_m_movspace_01",
                "s_m_m_paramedic_01",
                "s_m_m_pilot_01",
                "s_m_m_pilot_02",
                "s_m_m_postal_01",
                "s_m_m_postal_02",
                "s_m_m_prisguard_01",
                "s_m_m_scientist_01",
                "s_m_m_security_01",
                "s_m_m_snowcop_01",
                "s_m_m_strperf_01",
                "s_m_m_strpreach_01",
                "s_m_m_strvend_01",
                "s_m_m_trucker_01",
                "s_m_m_ups_01",
                "s_m_m_ups_02",
                "s_m_o_busker_01",
                "s_m_y_airworker",
                "s_m_y_ammucity_01",
                "s_m_y_armymech_01",
                "s_m_y_autopsy_01",
                "s_m_y_barman_01",
                "s_m_y_baywatch_01",
                "s_m_y_blackops_01",
                "s_m_y_blackops_02",
                "s_m_y_blackops_03",
                "s_m_y_busboy_01",
                "s_m_y_chef_01",
                "s_m_y_clown_01",
                "s_m_y_clubbar_01",
                "s_m_y_construct_01",
                "s_m_y_construct_02",
                "s_m_y_cop_01",
                "s_m_y_dealer_01",
                "s_m_y_devinsec_01",
                "s_m_y_dockwork_01",
                "s_m_y_doorman_01",
                "s_m_y_dwservice_01",
                "s_m_y_dwservice_02",
                "s_m_y_factory_01",
                "s_m_y_fireman_01",
                "s_m_y_garbage",
                "s_m_y_grip_01",
                "s_m_y_hwaycop_01",
                "s_m_y_marine_01",
                "s_m_y_marine_02",
                "s_m_y_marine_03",
                "s_m_y_mime",
                "s_m_y_pestcont_01",
                "s_m_y_pilot_01",
                "s_m_y_prismuscl_01",
                "s_m_y_prisoner_01",
                "s_m_y_ranger_01",
                "s_m_y_robber_01",
                "s_m_y_sheriff_01",
                "s_m_y_shop_mask",
                "s_m_y_strvend_01",
                "s_m_y_swat_01",
                "s_m_y_uscg_01",
                "s_m_y_valet_01",
                "s_m_y_waiter_01",
                "s_m_y_waretech_01",
                "s_m_y_winclean_01",
                "s_m_y_xmech_01",
                "s_m_y_xmech_02",
                "s_m_y_casino_01",
                "s_m_y_westsec_01",
                "hc_driver",
                "hc_gunman",
                "hc_hacker",
                "ig_abigail",
                "ig_agent",
                "ig_amandatownley",
                "ig_andreas",
                "ig_ashley",
                "ig_avon",
                "ig_ballasog",
                "ig_bankman",
                "ig_barry",
                "ig_benny",
                "ig_bestmen",
                "ig_beverly",
                "ig_brad",
                "ig_bride",
                "ig_car3guy1",
                "ig_car3guy2",
                "ig_casey",
                "ig_chef",
                "ig_chef2",
                "ig_chengsr",
                "ig_chrisformage",
                "ig_clay",
                "ig_claypain",
                "ig_cletus",
                "ig_dale",
                "ig_davenorton",
                "ig_denise",
                "ig_devin",
                "ig_dix",
                "ig_djblamadon",
                "ig_djblamrupert",
                "ig_djblamryans",
                "ig_djdixmanager",
                "ig_djgeneric_01",
                "ig_djsolfotios",
                "ig_djsoljakob",
                "ig_djsolmanager",
                "ig_djsolmike",
                "ig_djsolrobt",
                "ig_djtalaurelia",
                "ig_djtalignazio",
                "ig_dom",
                "ig_dreyfuss",
                "ig_drfriedlander",
                "ig_englishdave",
                "ig_fabien",
                "ig_fbisuit_01",
                "ig_floyd",
                "ig_g",
                "ig_groom",
                "ig_hao",
                "ig_hunter",
                "ig_janet",
                "ig_jay_norris",
                "ig_jewelass",
                "ig_jimmyboston",
                "ig_jimmyboston_02",
                "ig_jimmydisanto",
                "ig_joeminuteman",
                "ig_johnnyklebitz",
                "ig_josef",
                "ig_josh",
                "ig_karen_daniels",
                "ig_kerrymcintosh",
                "ig_kerrymcintosh_02",
                "ig_lacey_jones_02",
                "ig_lamardavis",
                "ig_lazlow",
                "ig_lazlow_2",
                "ig_lestercrest",
                "ig_lestercrest_2",
                "ig_lifeinvad_01",
                "ig_lifeinvad_02",
                "ig_magenta",
                "ig_malc",
                "ig_manuel",
                "ig_marnie",
                "ig_maryann",
                "ig_maude",
                "ig_michelle",
                "ig_milton",
                "ig_molly",
                "ig_money",
                "ig_mp_agent14",
                "ig_mrk",
                "ig_mrs_thornhill",
                "ig_mrsphillips",
                "ig_natalia",
                "ig_nervousron",
                "ig_nigel",
                "ig_old_man1a",
                "ig_old_man2",
                "ig_omega",
                "ig_oneil",
                "ig_orleans",
                "ig_ortega",
                "ig_paige",
                "ig_paper",
                "ig_patricia",
                "ig_popov",
                "ig_priest",
                "ig_prolsec_02",
                "ig_ramp_gang",
                "ig_ramp_hic",
                "ig_ramp_hipster",
                "ig_ramp_mex",
                "ig_rashcosvki",
                "ig_roccopelosi",
                "ig_russiandrunk",
                "ig_sacha",
                "ig_screen_writer",
                "ig_siemonyetarian",
                "ig_sol",
                "ig_solomon",
                "ig_stevehains",
                "ig_stretch",
                "ig_talcc",
                "ig_talina",
                "ig_talmm",
                "ig_tanisha",
                "ig_taocheng",
                "ig_taostranslator",
                "ig_tenniscoach",
                "ig_terry",
                "ig_tomepsilon",
                "ig_tonya",
                "ig_tonyprince",
                "ig_tracydisanto",
                "ig_trafficwarden",
                "ig_tylerdix",
                "ig_tylerdix_02",
                "ig_vagspeak",
                "ig_wade",
                "ig_zimbor",
                "player_one",
                "player_two",
                "player_zero",
                "ig_agatha",
                "ig_avery",
                "ig_brucie2",
                "ig_thornton",
                "ig_tomcasino",
                "ig_vincent",
                "u_f_m_corpse_01",
                "u_f_m_miranda",
                "u_f_m_miranda_02",
                "u_f_m_promourn_01",
                "u_f_o_moviestar",
                "u_f_o_prolhost_01",
                "u_f_y_bikerchic",
                "u_f_y_comjane",
                "u_f_y_corpse_01",
                "u_f_y_corpse_02",
                "u_f_y_danceburl_01",
                "u_f_y_dancelthr_01",
                "u_f_y_dancerave_01",
                "u_f_y_hotposh_01",
                "u_f_y_jewelass_01",
                "u_f_y_mistress",
                "u_f_y_poppymich",
                "u_f_y_poppymich_02",
                "u_f_y_princess",
                "u_f_y_spyactress",
                "u_f_m_casinocash_01",
                "u_f_m_casinoshop_01",
                "u_f_m_debbie_01",
                "u_f_o_carol",
                "u_f_o_eileen",
                "u_f_y_beth",
                "u_f_y_lauren",
                "u_f_y_taylor",
                "u_m_m_aldinapoli",
                "u_m_m_bankman",
                "u_m_m_bikehire_01",
                "u_m_m_doa_01",
                "u_m_m_edtoh",
                "u_m_m_fibarchitect",
                "u_m_m_filmdirector",
                "u_m_m_glenstank_01",
                "u_m_m_griff_01",
                "u_m_m_jesus_01",
                "u_m_m_jewelsec_01",
                "u_m_m_jewelthief",
                "u_m_m_markfost",
                "u_m_m_partytarget",
                "u_m_m_prolsec_01",
                "u_m_m_promourn_01",
                "u_m_m_rivalpap",
                "u_m_m_spyactor",
                "u_m_m_streetart_01",
                "u_m_m_willyfist",
                "u_m_o_filmnoir",
                "u_m_o_finguru_01",
                "u_m_o_taphillbilly",
                "u_m_o_tramp_01",
                "u_m_y_abner",
                "u_m_y_antonb",
                "u_m_y_babyd",
                "u_m_y_baygor",
                "u_m_y_burgerdrug_01",
                "u_m_y_chip",
                "u_m_y_corpse_01",
                "u_m_y_cyclist_01",
                "u_m_y_danceburl_01",
                "u_m_y_dancelthr_01",
                "u_m_y_dancerave_01",
                "u_m_y_fibmugger_01",
                "u_m_y_guido_01",
                "u_m_y_gunvend_01",
                "u_m_y_hippie_01",
                "u_m_y_imporage",
                "u_m_y_juggernaut_01",
                "u_m_y_justin",
                "u_m_y_mani",
                "u_m_y_militarybum",
                "u_m_y_paparazzi",
                "u_m_y_party_01",
                "u_m_y_pogo_01",
                "u_m_y_prisoner_01",
                "u_m_y_proldriver_01",
                "u_m_y_rsranger_01",
                "u_m_y_sbike",
                "u_m_y_smugmech_01",
                "u_m_y_staggrm_01",
                "u_m_y_tattoo_01",
                "u_m_y_zombie_01",
                "u_m_m_blane",
                "u_m_m_curtis",
                "u_m_m_vince",
                "u_m_o_dean",
                "u_m_y_caleb",
                "u_m_y_croupthief_01",
                "u_m_y_gabriel",
                "u_m_y_ushi"
            }
        }
    }
}

Config.InitialPlayerClothes = {
    Male = {
        Model = "mp_m_freemode_01",
        Components = {
            {
                component_id = 0, -- Face
                drawable = 0,
                texture = 0
            },
            {
                component_id = 1, -- Mask
                drawable = 0,
                texture = 0
            },
            {
                component_id = 2, -- Hair
                drawable = 0,
                texture = 0
            },
            {
                component_id = 3, -- Upper Body
                drawable = 0,
                texture = 0
            },
            {
                component_id = 4, -- Lower Body
                drawable = 0,
                texture = 0
            },
            {
                component_id = 5, -- Bag
                drawable = 0,
                texture = 0
            },
            {
                component_id = 6, -- Shoes
                drawable = 0,
                texture = 0
            },
            {
                component_id = 7, -- Scarf & Chains
                drawable = 0,
                texture = 0
            },
            {
                component_id = 8, -- Shirt
                drawable = 0,
                texture = 0
            },
            {
                component_id = 9, -- Body Armor
                drawable = 0,
                texture = 0
            },
            {
                component_id = 10, -- Decals
                drawable = 0,
                texture = 0
            },
            {
                component_id = 11, -- Jacket
                drawable = 0,
                texture = 0
            }
        },
        Props = {
            {
                prop_id = 0, -- Hat
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 1, -- Glasses
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 2, -- Ear
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 6, -- Watch
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 7, -- Bracelet
                drawable = -1,
                texture = -1
            }
        },
        Hair = {
            color = 0,
            highlight = 0,
            style = 0,
            texture = 0
        }
    },
    Female = {
        Model = "mp_f_freemode_01",
        Components = {
            {
                component_id = 0, -- Face
                drawable = 0,
                texture = 0
            },
            {
                component_id = 1, -- Mask
                drawable = 0,
                texture = 0
            },
            {
                component_id = 2, -- Hair
                drawable = 0,
                texture = 0
            },
            {
                component_id = 3, -- Upper Body
                drawable = 0,
                texture = 0
            },
            {
                component_id = 4, -- Lower Body
                drawable = 0,
                texture = 0
            },
            {
                component_id = 5, -- Bag
                drawable = 0,
                texture = 0
            },
            {
                component_id = 6, -- Shoes
                drawable = 0,
                texture = 0
            },
            {
                component_id = 7, -- Scarf & Chains
                drawable = 0,
                texture = 0
            },
            {
                component_id = 8, -- Shirt
                drawable = 0,
                texture = 0
            },
            {
                component_id = 9, -- Body Armor
                drawable = 0,
                texture = 0
            },
            {
                component_id = 10, -- Decals
                drawable = 0,
                texture = 0
            },
            {
                component_id = 11, -- Jacket
                drawable = 0,
                texture = 0
            }
        },
        Props = {
            {
                prop_id = 0, -- Hat
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 1, -- Glasses
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 2, -- Ear
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 6, -- Watch
                drawable = -1,
                texture = -1
            },
            {
                prop_id = 7, -- Bracelet
                drawable = -1,
                texture = -1
            }
        },
        Hair = {
            color = 0,
            highlight = 0,
            style = 0,
            texture = 0
        }
    }
}

Config.Stores = {
    {
        type = "clothing",
        coords = vector4(1691.3279, 4818.3813, 42.0653, 3.3755),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false, -- false => uses the size + rotation to create the zone | true => uses points to create the zone
        showBlip = true, -- overrides the blip visibilty configured above for the group
        points = {
            vector3(1686.9018554688, 4829.8330078125, 42.07),
            vector3(1698.8566894531, 4831.4604492188, 42.07),
            vector3(1700.2448730469, 4817.7734375, 42.07),
            vector3(1688.3682861328, 4816.2954101562, 42.07)
        }
    },
    {
        type = "clothing",
        coords = vector4(-708.8116, -151.9780, 37.4152, 126.7329),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-719.86212158203, -147.83151245117, 37.42),
            vector3(-709.10491943359, -141.53076171875, 37.42),
            vector3(-699.94342041016, -157.44494628906, 37.42),
            vector3(-710.68774414062, -163.64665222168, 37.42)
        }
    },
    {
        type = "clothing",
        coords = vector4(-1197.0688, -778.9126, 17.3301, 32.6548),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-1206.9552001953, -775.06304931641, 17.32),
            vector3(-1190.6080322266, -764.03198242188, 17.32),
            vector3(-1184.5672607422, -772.16949462891, 17.32),
            vector3(-1199.24609375, -783.07928466797, 17.32)
        }
    },
    {
        type = "clothing",
        coords = vector4(422.4266, -810.3492, 29.4934, 357.9216),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(419.55020141602, -798.36547851562, 29.49),
            vector3(431.61773681641, -798.31909179688, 29.49),
            vector3(431.19784545898, -812.07122802734, 29.49),
            vector3(419.140625, -812.03594970703, 29.49)
        }
    },
    {
        type = "clothing",
        coords = vector4(-164.9082, -302.8863, 39.7333, 254.4492),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-160.82145690918, -313.85919189453, 39.73),
            vector3(-172.56513977051, -309.82858276367, 39.73),
            vector3(-166.5775604248, -292.48077392578, 39.73),
            vector3(-154.84906005859, -296.51647949219, 39.73)
        }
    },
    {
        type = "clothing",
        coords = vector4(78.4780, -1388.8091, 29.3784, 179.3360),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(81.406135559082, -1400.7791748047, 29.38),
            vector3(69.335029602051, -1400.8251953125, 29.38),
            vector3(69.754981994629, -1387.078125, 29.38),
            vector3(81.500122070312, -1387.3002929688, 29.38)
        }
    },
    {
        type = "clothing",
        coords = vector4(-817.3361, -1074.1746, 11.3304, 119.9364),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-826.26251220703, -1082.6293945312, 11.33),
            vector3(-832.27856445312, -1072.2819824219, 11.33),
            vector3(-820.16442871094, -1065.7727050781, 11.33),
            vector3(-814.08953857422, -1076.1878662109, 11.33)
        }
    },
    {
        type = "clothing",
        coords = vector4(-1449.7612, -238.0342, 49.8177, 46.7139),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-1448.4829101562, -226.39401245117, 49.82),
            vector3(-1439.2475585938, -234.70428466797, 49.82),
            vector3(-1451.5389404297, -248.33193969727, 49.82),
            vector3(-1460.7554931641, -240.02815246582, 49.82)
        }
    },
    {
        type = "clothing",
        coords = vector4(-0.3170, 6511.9644, 31.8801, 311.0250),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(6.4955291748047, 6522.205078125, 31.88),
            vector3(14.737417221069, 6513.3872070312, 31.88),
            vector3(4.3691010475159, 6504.3452148438, 31.88),
            vector3(-3.5187695026398, 6513.1538085938, 31.88)
        }
    },
    {
        type = "clothing",
        coords = vector4(621.3063, 2753.8684, 42.0882, 90.5308),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(612.58312988281, 2747.2814941406, 42.09),
            vector3(612.26214599609, 2767.0520019531, 42.09),
            vector3(622.37548828125, 2767.7614746094, 42.09),
            vector3(623.66833496094, 2749.5180664062, 42.09)
        }
    },
    {
        type = "clothing",
        coords = vector4(1200.7535, 2707.0825, 38.2249, 83.7538),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(1188.7923583984, 2704.2021484375, 38.22),
            vector3(1188.7498779297, 2716.2661132812, 38.22),
            vector3(1202.4979248047, 2715.8479003906, 38.22),
            vector3(1202.3558349609, 2703.9294433594, 38.22)
        }
    },
    {
        type = "clothing",
        coords = vector4(-3172.6565, 1054.9655, 20.8633, 241.6897),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-3162.0075683594, 1056.7303466797, 20.86),
            vector3(-3170.8247070312, 1039.0412597656, 20.86),
            vector3(-3180.0979003906, 1043.1201171875, 20.86),
            vector3(-3172.7292480469, 1059.8623046875, 20.86)
        }
    },
    {
        type = "clothing",
        coords = vector4(-1096.3019, 2710.9580, 19.1101, 124.7705),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-1103.3004150391, 2700.8195800781, 19.11),
            vector3(-1111.3771972656, 2709.884765625, 19.11),
            vector3(-1100.8548583984, 2718.638671875, 19.11),
            vector3(-1093.1976318359, 2709.7365722656, 19.11)
        }
    },
    {
        type = "clothing",
        coords = vector4(123.0146, -212.8421, 54.5577, 249.8327),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(133.60948181152, -210.31390380859, 54.56),
            vector3(125.8349609375, -228.48097229004, 54.56),
            vector3(116.3140335083, -225.02020263672, 54.56),
            vector3(122.56930541992, -207.83396911621, 54.56)
        }
    },
    {
        type = "barber",
        coords = vector4(-821.9037, -183.3548, 37.5689, 206.1096),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-825.06127929688, -182.67497253418, 37.57),
            vector3(-808.82415771484, -179.19134521484, 37.57),
            vector3(-808.55261230469, -184.9720916748, 37.57),
            vector3(-819.77899169922, -191.81831359863, 37.57)
        }
    },
    {
        type = "barber",
        coords = vector4(136.4343, -1709.9264, 29.2918, 134.6021),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(132.57008361816, -1710.5053710938, 29.29),
            vector3(138.77899169922, -1702.6778564453, 29.29),
            vector3(142.73052978516, -1705.6853027344, 29.29),
            vector3(135.49719238281, -1712.9750976562, 29.29)
        }
    },
    {
        type = "barber",
        coords = vector4(-1284.5297, -1118.0813, 6.9903, 84.8334),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-1287.4735107422, -1115.4364013672, 6.99),
            vector3(-1277.5638427734, -1115.1229248047, 6.99),
            vector3(-1277.2469482422, -1120.1147460938, 6.99),
            vector3(-1287.4561767578, -1119.2506103516, 6.99)
        }
    },
    {
        type = "barber",
        coords = vector4(1933.2540, 3729.1968, 32.8446, 203.3190),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(1932.4931640625, 3725.3374023438, 32.84),
            vector3(1927.2720947266, 3733.7663574219, 32.84),
            vector3(1931.4379882812, 3736.5327148438, 32.84),
            vector3(1936.0697021484, 3727.2839355469, 32.84)
        }
    },
    {
        type = "barber",
        coords = vector4(1210.5443, -473.0623, 66.2082, 74.9098),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(1208.3327636719, -469.84338378906, 65.2),
            vector3(1217.9066162109, -472.40216064453, 65.2),
            vector3(1216.9870605469, -477.00939941406, 65.2),
            vector3(1206.1077880859, -473.83499145508, 65.2)
        }
    },
    {
        type = "barber",
        coords = vector4(-33.2336, -150.5209, 57.0768, 338.9945),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-29.730783462524, -148.67495727539, 56.1),
            vector3(-32.919719696045, -158.04254150391, 56.1),
            vector3(-37.612594604492, -156.62759399414, 56.1),
            vector3(-33.30192565918, -147.31649780273, 56.1)
        }
    },
    {
        type = "barber",
        coords = vector4(-279.9737, 6228.8325, 31.6958, 46.9237),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-280.29818725586, 6232.7265625, 30.7),
            vector3(-273.06427001953, 6225.9692382812, 30.7),
            vector3(-276.25280761719, 6222.4013671875, 30.7),
            vector3(-282.98211669922, 6230.015625, 30.7)
        }
    },
    {
        type = "tattoo",
        coords = vector4(1324.6284, -1653.2167, 52.2772, 41.2505),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(1323.9360351562, -1649.2370605469, 52.2),
            vector3(1328.0186767578, -1654.3087158203, 52.2),
            vector3(1322.5780029297, -1657.7045898438, 52.2),
            vector3(1319.2043457031, -1653.0885009766, 52.2)
        }
    },
    {
        type = "tattoo",
        coords = vector4(-1152.4583, -1426.8777, 4.9559, 28.3206),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-1152.7110595703, -1422.8382568359, 4.95),
            vector3(-1149.0043945312, -1428.1975097656, 4.95),
            vector3(-1154.6730957031, -1431.1898193359, 4.95),
            vector3(-1157.7064208984, -1426.3433837891, 4.95)
        }
    },
    {
        type = "tattoo",
        coords = vector4(322.3687, 182.5132, 103.5880, 155.4108),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(319.28741455078, 179.9383392334, 103.59),
            vector3(321.537109375, 186.04516601562, 103.59),
            vector3(327.24526977539, 183.12303161621, 103.59),
            vector3(325.01351928711, 177.8542175293, 103.59)
        }
    },
    {
        type = "tattoo",
        coords = vector4(-3171.8884, 1075.5702, 20.8306, 247.1972),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-3169.5861816406, 1072.3740234375, 20.83),
            vector3(-3175.4802246094, 1075.0703125, 20.83),
            vector3(-3172.2041015625, 1080.5860595703, 20.83),
            vector3(-3167.076171875, 1078.0391845703, 20.83)
        }
    },
    {
        type = "tattoo",
        coords = vector4(1864.1, 3747.91, 33.03, 17.23),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(1864.7208, 3749.6487, 33.0294),
            vector3(1866.390625, 3752.8081054688, 33.03),
            vector3(1868.6164550781, 3747.3562011719, 33.03),
            vector3(1863.65234375, 3744.5034179688, 33.03)
        }
    },
    {
        type = "tattoo",
        coords = vector4(-293.7820, 6197.9819, 31.4889, 316.6166),
        size = vector3(4, 4, 4),
        rotation = 45,
        usePoly = false,
        points = {
            vector3(-289.42239379883, 6198.68359375, 31.49),
            vector3(-294.69515991211, 6194.5366210938, 31.49),
            vector3(-298.23013305664, 6199.2451171875, 31.49),
            vector3(-294.1501159668, 6203.2700195312, 31.49)
        }
    },
}

Config.UseRadialMenu = true
Config.ClothingCost = 100
Config.BarberCost = 100
Config.TattooCost = 100
Config.TextUIOptions = {
    position = "left-center"
}

Config.Blips = {
    ["clothing"] = {
        Show = true,
        Sprite = 73,
        Color = 47,
        Scale = 0.7,
        Name = "Sklep z ubraniami",
    },
    ["barber"] = {
        Show = true,
        Sprite = 71,
        Color = 0,
        Scale = 0.7,
        Name = "Fryzjer",
    },
}

Config.TargetConfig = {
    ["clothing"] = {
        model = "s_f_m_shop_high",
        scenario = "WORLD_HUMAN_STAND_MOBILE",
        icon = "fas fa-tshirt",
        label = "Sklep z ubraniami",
        distance = 50
    },
    ["barber"] = {
        model = "s_m_m_hairdress_01",
        scenario = "WORLD_HUMAN_STAND_MOBILE",
        icon = "fas fa-scissors",
        label = "Fryzjer",
        distance = 50
    },
    ["clothingroom"] = {
        model = "mp_g_m_pros_01",
        scenario = "WORLD_HUMAN_STAND_MOBILE",
        icon = "fas fa-sign-in-alt",
        label = "--",
        distance = 50
    },
    ["playeroutfitroom"] = {
        model = "mp_g_m_pros_01",
        scenario = "WORLD_HUMAN_STAND_MOBILE",
        icon = "fas fa-sign-in-alt",
        label = "Garderoba",
        distance = 50
    },
}

Config.DisableComponents = {
    Masks = false,
    UpperBody = false,
    LowerBody = false,
    Bags = false,
    Shoes = false,
    ScarfAndChains = false,
    BodyArmor = false,
    Shirts = false,
    Decals = false,
    Jackets = false
}

Config.DisableProps = {
    Hats = false,
    Glasses = false,
    Ear = false,
    Watches = false,
    Bracelets = false
}