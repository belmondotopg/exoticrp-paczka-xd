-----------------------------------------------------------------------------------------------------------
-------------------------------------------- TUNING POJAZDÓW ----------------------------------------------
-----------------------------------------------------------------------------------------------------------
--
-- Tutaj możesz tworzyć, edytować i usuwać różne części tuningowe. Wszystkie zmiany, które wprowadzają
-- w handlingu pojazdu są tutaj, więc możesz swobodnie modyfikować według własnych potrzeb. PROSZĘ
-- pamiętać, że jeśli 2 różne opcje tuningu modyfikują te same wartości handlingu i są ustawione na
-- nadpisywanie, mogą się wzajemnie nadpisywać w nieprzewidywalny sposób. Albo ustaw wartości na NIE
-- nadpisywać, albo upewnij się, że różne części tuningowe modyfikują unikalne części handlingu, aby
-- zapobiec niepożądanym rezultatom.
--
-- Oto przewodnik wyjaśniający, co oznaczają różne opcje, aby pomóc Ci dostosować części tuningowe.
--
-----------------------------------------------------------------------------------------------------------
--  name                      Nazwa modyfikacji, która będzie wyświetlana w tablecie.
-----------------------------------------------------------------------------------------------------------
--  info                      Opcjonalne, ale możesz podać dodatkowe informacje, które będą widoczne w UI
--                            po kliknięciu ikony informacji podczas wybierania ulepszenia. Może być
--                            używane do ostrzegania mechaników o pojazdach, na których nie powinno się
--                            stosować ulepszenia, lub wynikach z testowania wartości handlingu.
-----------------------------------------------------------------------------------------------------------
--  itemName                  Dla mechaników skonfigurowanych do używania przedmiotów przy ulepszeniach,
--                            jest to nazwa wymaganego przedmiotu.
-----------------------------------------------------------------------------------------------------------
--  price                     Dla mechaników skonfigurowanych do zakupu ulepszeń, będzie to koszt dla
--                            mechanika zastosowania ulepszenia.
-----------------------------------------------------------------------------------------------------------
--  audioNameHash             Dowolna nazwa pojazdu z gry lub nazwa pakietu dźwiękowego dodatku
--                            (TYLKO ZAMIANY SILNIKA!)
-----------------------------------------------------------------------------------------------------------
--  handling                  Dodaj/usuń atrybuty i wartości handlingu.
--                            Więcej pomocy i informacji o wartościach handlingu: https://gtamods.com/wiki/Handling.meta
-----------------------------------------------------------------------------------------------------------
--  handlingApplyOrder        Kolejność, w jakiej ta opcja tuningu powinna być zastosowana. Jest to
--                            przydatne, gdy opcje tuningu mają nakładające się wartości handlingu!
--                            Podaj numer priorytetu, a najniższe numery będą zastosowane jako pierwsze.
-----------------------------------------------------------------------------------------------------------
--  handlingOverwritesValues  Czy podane wartości handlingu powinny nadpisać istniejące wartości
--                            pojazdu, czy powinny modyfikować istniejące wartości pojazdu. Działa to
--                            również dla wartości ujemnych.
--                           
--                            Na przykład: aktualna wartość fDriveInertia pojazdu wynosi 1.0
--                               true  = wartość 0.5 ustawia fDriveInertia na 0.5
--                               false = wartość 0.5 oznacza [1.0 + 0.5] i ustawia fDriveInertia na 1.5
-----------------------------------------------------------------------------------------------------------
-- restricted (opcjonalne)    Może być false (bez ograniczeń), "electric" lub "combustion"
-----------------------------------------------------------------------------------------------------------
-- blacklist                  Lista nazw archetypów (kody spawnu), które nie mogą używać tej modyfikacji
-----------------------------------------------------------------------------------------------------------
-- minGameBuild               Funkcjonalność ograniczona do określonej wersji gry, np. manualne skrzynie biegów
-----------------------------------------------------------------------------------------------------------

Config.Tuning = {
  --
  -- ZAMIANY SILNIKA
  -- Tutaj możesz dostosować lub dodać nowe opcje zamiany silnika.
  --
  engineSwaps = {
    [1] = {
      name = "I4 2.0L",
      icon = "engine.svg",
      info = "Dwuturbodoładowany silnik 2.5L",
      itemName = "i4_engine",
      price = 125000,
      audioNameHash = "aq58honk20a",
      handlingOverwritesValues = true,
      handlingApplyOrder = 1,
      handling = {
        fInitialDriveForce = 0.32,
        fDriveInertia = 1.0,
        fInitialDriveMaxFlatVel = 175.0,
        fClutchChangeRateScaleUpShift = 2.5,
        fClutchChangeRateScaleDownShift = 2.5
      },
      restricted = "combustion",
    },
    [2] = {
      name = "V6 3.8L",
      icon = "engine.svg",
      audioNameHash = "aq10nisvr38dett",
      info = "Dostrojony silnik V6",
      itemName = "v6_engine",
      price = 350000,
      handlingOverwritesValues = true,
      handlingApplyOrder = 1,
      handling = {
        fInitialDriveForce = 0.36,
        fDriveInertia = 1.0,
        fInitialDriveMaxFlatVel = 190.0,
        fClutchChangeRateScaleUpShift = 5.0,
        fClutchChangeRateScaleDownShift = 5.0
      },
      restricted = "combustion",
    },
    [3] = {
      name = "V8 5.0L",
      icon = "engine.svg",
      info = "Wolnossący silnik V8 6.5L",
      itemName = "v8_engine",
      price = 650000,
      audioNameHash = "lg57mustangtv8",
      handlingOverwritesValues = true,
      handlingApplyOrder = 1,
      handling = {
        fInitialDriveForce = 0.39,
        fDriveInertia = 1.0,
        fInitialDriveMaxFlatVel = 205.0,
        fClutchChangeRateScaleUpShift = 5.0,
        fClutchChangeRateScaleDownShift = 5.0
      },
      restricted = "combustion",
    },
    [4] = {
      name = "V12 6.5L",
      icon = "engine.svg",
      info = "Ogromny potwór V12 6L",
      itemName = "v12_engine",
      price = 900000,
      audioNameHash = "ta023l539",
      handlingOverwritesValues = true,
      handlingApplyOrder = 1,
      handling = {
        fInitialDriveForce = 0.42,
        fDriveInertia = 1.0,
        fInitialDriveMaxFlatVel = 230.0,
        fClutchChangeRateScaleUpShift = 5.0,
        fClutchChangeRateScaleDownShift = 5.0
      },
      restricted = "combustion",
      blacklist = {"ikx3_90xxs24"} -- Example of the blacklist feature - feel free to remove this (it couldn't fit a v12 though man, come on)
    }
  },

  --
  -- OPONY
  -- Tutaj możesz dostosować lub dodać nowe opcje opon.
  --
  tyres = {
    [1] = {
      name = "Slicki",
      icon = "wheels/offroad.svg",
      info = false,
      itemName = "slick_tyres",
      price = 15000,
      handlingOverwritesValues = false,
      handlingApplyOrder = 2,
      handling = {
        fTractionCurveMin = 0.5,
        fTractionCurveMax = 0.5
      },
    },
    [2] = {
      name = "Półslicki",
      icon = "wheels/offroad.svg",
      info = false,
      itemName = "semi_slick_tyres",
      price = 10000,
      handlingOverwritesValues = false,
      handlingApplyOrder = 2,
      handling = {
        fTractionCurveMin = 0.25,
        fTractionCurveMax = 0.25
      },
    },
    [3] = {
      name = "Offroad",
      icon = "wheels/offroad.svg",
      info = false,
      itemName = "offroad_tyres",
      price = 15000,
      handlingOverwritesValues = true,
      handlingApplyOrder = 2,
      handling = {
        fTractionLossMult = 0.0
      },
    }
  },

  --
  -- HAMULCE
  -- Tutaj możesz dostosować lub dodać nowe opcje hamulców.
  --
  brakes = {
    [1] = {
      name = "Ceramiczne",
      icon = "brakes.svg",
      info = "Potężne hamulce z ogromną siłą hamowania",
      itemName = "ceramic_brakes",
      price = 25000,
      handlingOverwritesValues = false,
      handlingApplyOrder = 3,
      handling = {
        fBrakeForce = 3.0
      },
    }
  },

  --
  -- UKŁADY NAPĘDOWE
  -- Tutaj możesz dostosować lub dodać nowe opcje układu napędowego.
  --
  drivetrains = {
    [1] = {
      name = "AWD",
      icon = "drivetrain.svg",
      info = false,
      itemName = "awd_drivetrain",
      price = 50000,
      handlingOverwritesValues = true,
      handlingApplyOrder = 4,
      handling = {
        fDriveBiasFront = 0.5
      },
    },
    [2] = {
      name = "RWD",
      icon = "drivetrain.svg",
      info = false,
      itemName = "rwd_drivetrain",
      price = 40000,
      handlingOverwritesValues = true,
      handlingApplyOrder = 4,
      handling = {
        fDriveBiasFront = 0.0
      },
    },
    [3] = {
      name = "FWD",
      icon = "drivetrain.svg",
      info = false,
      itemName = "fwd_drivetrain",
      price = 40000,
      handlingOverwritesValues = true,
      handlingApplyOrder = 4,
      handling = {
        fDriveBiasFront = 1.0
      },
    }
  },

  --
  -- TURBODOŁADOWANIE
  -- Uwaga: Ta kategoria jest unikalna, ponieważ tylko włącza/wyłącza mod 18 (standardowa opcja turbodoładowania GTA)
  -- Nie możesz dodać dodatkowych opcji turbodoładowania, możesz tylko dostosować/usunąć istniejącą.
  -- Nie możesz dodać żadnych zmian w handlingu. Utwórz nowe przedmioty/inne kategorie w tym celu.
  --
  turbocharging = {
    [1] = {
      name = "Turbodoładowanie",
      icon = "turbo.svg",
      info = false,
      itemName = "turbocharger",
      price = 25000,
      restricted = "combustion",
    }
  },

  --
  -- TUNING DRIFT
  -- Nie możesz dodać dodatkowych opcji tuningu drift, możesz tylko dostosować/usunąć istniejącą.
  --
  driftTuning = {
    [1] = {
      name = "Tuning Drift",
      icon = "wheels/tuner.svg",
      info = false,
      itemName = "drift_tuning_kit",
      price = 50000,
      handlingOverwritesValues = true,
      handlingApplyOrder = 5,
      handling = {
        fInitialDragCoeff = 12.22,
        fInitialDriveForce = 3.0,
        fInitialDriveMaxFlatVel = 155.0,
        fSteeringLock = 58.0,
        fTractionCurveMax = 0.6,
        fTractionCurveMin = 1.3,
        fTractionCurveLateral = 21.0,
        fLowSpeedTractionLossMult = 0.5,
        fTractionBiasFront = 0.49
      },
    }
  },

  -- 
  -- SKRZYNIA BIEGÓW (b3095 lub nowsza)
  -- To jest unikalna kategoria, która aktualizuje flagi poprzez opcję boolean 'manualGearbox'.
  -- Pozwala to przełączać ręczne przełożenia, gdzie gracz musi sam zmieniać biegi.
  -- Dowiedz się więcej: https://docs.jgscripts.com/mechanic/manual-transmissions-and-smooth-first-gear
  -- 
  gearboxes = {
    [1] = {
      name = "Skrzynia Manualna",
      icon = "transmission.svg",
      info = false,
      itemName = "manual_gearbox",
      price = 30000,
      manualGearbox = true,
      restricted = "combustion",
      minGameBuild = 3095
    }
  }

  --
  -- PRZYKŁAD NOWEJ WŁASNEJ KATEGORII
  -- 
  -- ["Transmissions"] = {
  --   [1] = {
  --     name = "Skrzynia 8-biegowa",
  --     icon = "transmission.svg",
  --     info = "Testowanie tworzenia nowej kategorii",
  --     itemName = "transmission",
  --     price = 1000,
  --     handlingOverwritesValues = true,
  --     handling = {
  --       nInitialDriveGears = 8
  --     },
  --     restricted = false,
  --   }
  -- }
  --
  -- -- WAŻNA UWAGA --
  -- W pliku config.lua, w sekcji "tuning" lokalizacji mechanika, będziesz musiał dodać
  -- dodatkową linię, aby była widoczna i włączona w tablecie
  --
  -- ["Transmissions"] = { enabled = true, requiresItem = false },
}