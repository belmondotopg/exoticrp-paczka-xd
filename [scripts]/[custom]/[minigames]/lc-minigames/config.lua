Config = {}

Config.DebugEnabled = false

-- Ace Permissions (Who can use the commands.)
Config.Permission = 'founder' -- admin / god / mod
Config.CommandNames = {
    TestMinigame = { 'TestMinigame', 'testmg' },
    MinigameEditor = { 'MinigameEditor', 'mgEditor' }
}

-- Allow merging any missing keys for Global Config / Minigame Config after an update.
-- This will NOT override any of your custom settings, this will only add new settings that have been added from updates.
Config.MergeMissingKeys = true



-- I HIGHLY DISCOURAGE CHANGING ANY OF THE CONFIGS BELOW UNLESS YOU KNOW WHAT YOU'RE DOING.
-- THIS IS THE DEFAULT CONFIG THAT SETS THE FIRST TIME YOU OPEN THE EDITOR.
-- AFTER THE FIRST TIME YOU SAVE ON THE EDITOR, IT WILL BEGIN USING YOUR CONFIG FROM YOUR DATABASE, SO NOTHING BELOW WILL CHANGE ANYTHING.

Config.Profiles = {}

Config.GlobalConfig = {}
Config.GlobalConfig.serverImage = 'https://i.postimg.cc/NGRQ1hbf/exoticrp.png'
Config.GlobalConfig.accentColor = "#9751c6" --9751c6
Config.GlobalConfig.container = {
    enabled = true,
    color = Config.GlobalConfig.accentColor,
    backgroundColor = '#0c0a09',
    borderRadius = 16,
    countdown = {
        enabled = true,
        color = Config.GlobalConfig.accentColor,
        border = '#FFFFFF33',
        animate = true,
    },
    results = {
        animate = true,
        enabled = true,
        successColor = '#73EB33FF',
        failColor = '#EB3333FF',
    },
    divider = {
        height = 2,
        width = 100,
        enabled = true,
        enableShadow = true,
        color = Config.GlobalConfig.accentColor,
        shadow = Config.GlobalConfig.accentColor .. 'CC',
    },
    progressBar = {
        default = true,
        enabled = true,
        fillColor = Config.GlobalConfig.accentColor,
        enableGlow = true,
        opacity = 100,
        width = 4,
    }
}

Config.Minigames = {}
Config.Minigames.AimLab = {
    audio = {
        failSound = { value = 'fail.mp3', volume = 1.0 },
        clickSound = { value = 'click.wav', volume = 1.0 },
    },
    info = {
        id = 'AimLab',
        name = 'Aim Labs',
        title = 'ROZBROJENIE WĘZŁA FIREWALLA',
        description =
        'Wrogi firewall uruchomił aktywne węzły zabezpieczeń.\n\nZneutralizuj każdy świecący węzeł, zanim zakończy swój cykl.\nReaguj szybko i celnie — zbyt wiele chybionych strzałów spowoduje niepowodzenie włamania.',
        successMessage = 'Firewall rozbrojony. Dostęp przyznany.',
        failureMessage = 'Przejęcie węzła nie powiodło się. Włamanie zablokowane.',
    },

    game = {
        logic = {
            endDelay = 1500,
            loadingTime = 3000,
            duration = 15000,
            gridSize = 8,
            _clamp = {
                gridSize = { min = 2, max = 12, step = 1 },
            }
        },
        target = {
            targetGoal = 20,
            targetGoalVariance = 5,
            allowedMisses = 0,
            _clamp = {
                targetGoal = { min = 5, max = 50, step = 1 },
                targetGoalVariance = { min = 0, max = 10, step = 1 },
            },
            targetSpawn = {
                spawnDelay = 500,
                spawnDelayRandomness = 900,
                _clamp = {
                    spawnDelay = { min = 100, max = 2000, step = 100 },
                    spawnDelayRandomness = { min = 0, max = 1000, step = 10 },
                }
            },
        }
    },
    appearance = {
        container = Config.GlobalConfig.container,
        target = {
            color = Config.GlobalConfig.accentColor,
            size = 95,
            borderRadius = 30,
            hoverOpacity = 60,
            enableGlow = true,
            _clamp = {
                borderRadius = { min = 0, max = 60, step = 5 },
                size = { min = 1, max = 100, step = 1 },
                hoverOpacity = { min = 0, max = 100, step = 1 },
            },
            successIcon = {
                enabled = true,
                icon = 'CheckIcon',
                color = '#ffffff',
                size = 50,
                _clamp = {
                    size = { min = 1, max = 100, step = 1 },
                }
            },
            failedIcon = {
                enabled = true,
                icon = 'XMarkIcon',
                color = '#ff0005',
                size = 50,
                _clamp = {
                    size = { min = 1, max = 100, step = 1 },
                }
            }
        }
    }
}
Config.Minigames.ArrowClicker = {
    audio = {
        failSound = { value = 'fail.mp3', volume = 1.0 },
        clickSound = { value = 'click.wav', volume = 1.0 },
    },
    info = {
        id = 'ArrowClicker',
        name = 'Arrow Clicker',
        title = 'Arrow Clicker',
    },
    game = {
        target = {
            targetGoal = 8,
        },
        logic = {
            endDelay = 200,
            duration = 10000,
        },
        _clamp = {
            targetGoal = { min = 3, max = 15, step = 1 }
        }
    },
    appearance = {
        success = {
            color = Config.GlobalConfig.accentColor
        },
        fail = {
            color = '#ff4447'
        },
        container = {
            enabled = Config.GlobalConfig.container.enabled,
            color = Config.GlobalConfig.container.color,
            backgroundColor = Config.GlobalConfig.container.backgroundColor,
            borderRadius = Config.GlobalConfig.container.borderRadius,
            progressBar = Config.GlobalConfig.container.progressBar
        }
        ,
    }
}
Config.Minigames.ArrowGridMaze = {
    audio = {
        failSound = { value = 'fail.mp3', volume = 1.0 },
        clickSound = { value = 'click.wav', volume = 1.0 },
    },
    info = {
        id = 'ArrowGridMaze',
        name = 'Arrow Grid Maze',
        title = 'Przełamanie Labiryntu Firewall',
        description =
        'Prześledź bezpieczną ścieżkę przez siatkę węzłów kierunkowych, aby dotrzeć do celu. Jeden błędny ruch i dostęp zostanie odrzucony.',
        successMessage = 'Ścieżka węzła ukończona. Firewall przełamany.',
        failureMessage = 'Śledzenie ścieżki nie powiodło się. Dostęp odrzucony.'

    },
    game = {
        logic = {
            endDelay = 1500,
            loadingTime = 3000,
            duration = 10000,
            gridSize = 5,
            _clamp = {
                gridSize = { min = 2, max = 12, step = 1 },
            }
        }
    },
    appearance = {
        container = Config.GlobalConfig.container
    }
}
Config.Minigames.Balance = {
    audio = {
        keySound = { value = 'lockpick.mp3', volume = 1.0 },
    },
    info = {
        id = 'Balance',
        name = 'Balance',
    },
    game = {
        logic = {
            endDelay = 600,
            duration = 10000,
            controlPower = 0.2,
            randomBobPower = 0.3,
            damping = 1.0,
            _clamp = {
                controlPower = { min = 0.1, max = 1.0, step = 0.05 },
                randomBobPower = { min = 0.1, max = 1.0, step = 0.05 },
                damping = { min = 0.5, max = 1.0, step = 0.01 },
            },
            zone = {
                success = {
                    degrees = 30,
                    _clamp = {
                        degrees = { min = 10, max = 75, step = 1 },
                    },
                },
                mid = {
                    degrees = 15,
                    _clamp = {
                        degrees = { min = 0, max = 30, step = 1 },
                    },
                }
            }
        }
    },
    appearance = {
        canvas = {
            width = 420,

        },
        zone = {
            success = {
                color = '#00ff004d',
                border = '#00ff00',
                borderRadius = 2,
            },
            mid = {
                color = '#ffd7004d',
                border = '#ffff00',
                borderRadius = 2,
            },
            fail = {
                color = '#8b000066',
                border = '#ff0000',
                borderRadius = 2,
            }
        },

        line = {
            progressive = true,
            color = '#00ff00',
            length = 30,
            width = 3,
        },
        circle = {
            fill = '#00ff004d',
            radius = 10,
            border = '#00ff00',
            borderRadius = 2,
        },
        keycap = {
            enabled = true,
            type = 'mechanical',
            _options = {
                type = { 'mechanical', 'flat' }
            },
        },
        progressBar = Config.GlobalConfig.container.progressBar
    }
}
Config.Minigames.BreakerPuzzle = {
    audio = {
        clickSound = { value = 'tick.mp3', volume = 1.0 },
        failSound = { value = 'error.mp3', volume = 1.0 },
        successSound = { value = 'complete.mp3', volume = 1.0 },
    },
    info = {
        id = 'BreakerPuzzle',
        name = 'Breaker Puzzle',
        title = 'Zagubiony⚡Kod',
        label1 = 'Uruchamianie Systemu',
        label2 = 'Inicjalizacja obwodów, proszę czekać.'
    },
    game = {
        logic = {
            endDelay = 600,
            loadingTime = 2000,
            totalRounds = 3,
            totalSwitches = 10,
        },
        round = {
            displayDelay = 800,
            switches = 5,
            duration = 6000,
        }
    },
    appearance = {
        colors = {
            numberColor = '#f7901e',
            onColor = '#1eff6b',
            offColor = '#222222',
            timerColor = '#ffffff'
        },
        progressBar = {
            default = Config.GlobalConfig.container.progressBar.default,
            enabled = Config.GlobalConfig.container.progressBar.enabled,
            fillColor = Config.GlobalConfig.container.progressBar.fillColor,
            enableGlow = Config.GlobalConfig.container.progressBar.enableGlow,
            opacity = Config.GlobalConfig.container.progressBar.opacity,
            width = 2,
        }
    }
}
Config.Minigames.CodeFind = {
    audio = {
        failSound = { value = 'fail2.mp3', volume = 1.0 },
        successSound = { value = 'success.mp3', volume = 1.0 },
    },
    info = {
        id = 'CodeFind',
        name = 'Code Find',
        title = 'PROTOKÓŁ BRUTEFORCE',
        description =
        'Fragment zakodowanego kodu został wyodrębniony z bufora firewall.\n\nPrzeskanuj siatkę i wyizoluj poprawną sekwencję, zanim system się zresetuje.\nBądź czujny — jeden błędny kod i włamanie się nie powiedzie.',
        successMessage = 'Kod dostępu zweryfikowany. Połączenie ustanowione.',
        failureMessage = 'Niezgodność kodu. Próba włamania zarejestrowana.',

    },
    game = {
        logic = {
            endDelay = 600,
            loadingTime = 3000,
            duration = 10000,
            totalRounds = 3,
            gridSize = 3,
            scrambleInterval = 3000,
            useSimilar = false,
            codeType = 'random',
            codeLength = 'random',
            _options = {
                codeType = { 'letters', 'numbers', 'mixed', 'symbols', 'hex', 'morse', 'emoji', 'random' },
                codeLength = { 3, 4, 5, 6, 7, 8, 'random' },
            },
            codeLengthMin = 3,
            codeLengthMax = 8,
            codeTypes = { 'letters', 'numbers', 'mixed', 'symbols', 'hex', 'morse', 'emoji', 'random' },
            _toggles = {
                codeTypes = { 'letters', 'numbers', 'mixed', 'symbols', 'hex', 'morse', 'emoji', 'random' },
            },
            _clamp = {
                gridSize = { min = 2, max = 12, step = 1 },
            }
        }
    },
    appearance = {
        container = Config.GlobalConfig.container
    }
}
Config.Minigames.ColorMemory = {
    audio = {
        failSound = { value = 'fail2.mp3', volume = 1.0 },
        successSound = { value = 'success.mp3', volume = 1.0 },
        completeSound = { value = 'complete.mp3', volume = 1.0 },
    },
    info = {
        id = 'ColorMemory',
        name = 'Color Memory',
        title = 'Naruszenie Systemu',
        descriptionRemember = 'Zapamiętaj kody dostępu!',
        descriptionAnswer = 'Wprowadź poprawną sekwencję!',
        descriptionQuestion = 'Ile bloków było {color}?',
        successMessage = 'Dostęp przyznany. Ominąłeś firewall.',
        failureMessage = 'Dostęp odrzucony. Uruchomiłeś alarm.',
    },
    game = {
        logic = {
            endDelay = 600,
            gridSize = 5,
            totalRounds = 3,
            loadingTime = 3000,
            blankChance = 60,
            tileShape = 'square',
            displayDelay = 4500,
            answerTime = 4500,
            _options = {
                tileShape = { 'square', 'circle' }
            },
            _clamp = {
                gridSize = { min = 2, max = 12, step = 1 },
                blankChance = { min = 0, max = 80, step = 1 },
            }
        }
    },
    appearance = {
        container = Config.GlobalConfig.container
    }
}
Config.Minigames.FlappyBird = {
    audio = {
        flapSound = { value = 'flap.mp3', volume = 1.0 },
        failSound = { value = 'hit.mp3', volume = 1.0 },
        successSound = { value = 'success.mp3', volume = 1.0 },
    },
    info = {
        id = 'FlappyBird',
        name = 'Flappy Bird',
        title = 'Flappy Bird',
        description = 'Unikaj rur i skacz, dopóki nie skończy się czas!',
        successMessage = 'Przeżyłeś!',
        failureMessage = 'Nie udało się!',
    },
    game = {
        logic = {
            endDelay = 600,
            loadingTime = 3000,
            duration = 10000,
            pipeSpawnInterval = 1000,
            speed = 300,
            gravity = 1500,
        }
    },
    appearance = {
        container = Config.GlobalConfig.container,
        pipe = {
            color = Config.GlobalConfig.accentColor,
            width = 100,
            gap = 250,
            shadow = true,
            shadowColor = '#00000080'
        },
        cap = {
            color = Config.GlobalConfig.accentColor,
            width = 25,
            height = 40,
        },
        background = {
            image = 'https://r2.fivemanage.com/zncWNUy4y5AG60qjDUf5n/animatedBg3.png',
            color = Config.GlobalConfig.container.backgroundColor,
            opacity = 0.95,
            bgSpeed = 100,
            _clamp = {
                opacity = { min = 0.0, max = 1.0, step = 0.01 }
            }
        },
        bird = {
            image = 'https://r2.fivemanage.com/zncWNUy4y5AG60qjDUf5n/birdSprite.png',
            opacity = 0.85,
            birdSize = 50,
            enableShadow = true,
            color = '#ffffff',
            shadowColor = '#00000080',
            _clamp = {
                birdSize = { min = 10, max = 100, step = 5 },
                opacity = { min = 0.0, max = 1.0, step = 0.01 }
            }
        }
    }
}
Config.Minigames.KnobTurn = {
    audio = {
        failSound = { value = 'fail.mp3', volume = 1.0 },
        tickSound = { value = 'tick.mp3', volume = 1.0 },
        successSound = { value = 'success.mp3', volume = 1.0 },
    },
    info = {
        id = 'KnobTurn',
        name = 'Knob Turn',
        title = 'Łamacz Sejfów',
        description = 'Obróć pokrętła, aby ustawić poprawną kombinację i otworzyć sejf.',
        successMessage = 'Udało ci się otworzyć sejf!',
        failureMessage = 'Kombinacja była niepoprawna. Sejf pozostaje zamknięty.',
    },
    game = {
        logic = {
            endDelay = 600,
            loadingTime = 3000,
            duration = 15000,
        }
    },
    appearance = {
        percentColor = '#ffffff',
        tickActiveColor = Config.GlobalConfig.accentColor,
        tickInactiveColor = '#2e2e2e',
        container = Config.GlobalConfig.container
    }
}
Config.Minigames.LettersFall = {
    audio = {
        failSound = { value = 'fail.mp3', volume = 1.0 },
        successSound = { value = 'success.mp3', volume = 1.0 },
    },
    info = {
        id = 'LettersFall',
        name = 'Letters Fall',
        title = 'Letters Fall',
        description = 'Wpisz spadające słowa, zanim uderzą w ziemię!',
        successMessage = 'Udało ci się wyleczyć pacjenta!',
        failureMessage = 'Nie udało ci się wyleczyć na czas!',
    },
    game = {
        logic = {
            endDelay = 600,
            loadingTime = 3000,
            duration = 15000,
            wordSpawnInterval = 1200,
            wordSpeed = 1,
            maxWords = 1000,
            scenario = 'medical',
            scenarios = {
                medical = { 'CELL', 'VEIN', 'KIDNEY', 'LUNG', 'BRAIN', 'HEART', 'BLOOD', 'MUSCLE', 'TISSUE' },
                theft = { 'WALLET', 'LOCK', 'ALARM', 'KEY', 'HACK', 'VAULT', 'CASH', 'STEAL', 'FENCE' },
                combat = { 'STRIKE', 'BLOCK', 'PARRY', 'DODGE', 'KICK', 'SWING', 'CLASH', 'GUARD' }
            }
        }
    },
    appearance = {
        container = Config.GlobalConfig.container
    }
}
Config.Minigames.LockSpinner = {
    audio = {
        pickSound = { value = 'pick.mp3', volume = 1.0 },
        endSound = { value = 'end.mp3', volume = 1.0 },
    },
    info = {
        id = 'LockSpinner',
        name = 'Lock Spinner',
        description = 'Naciśnij E, aby otworzyć zamek!',
        successMessage = 'Otworzyłeś wszystkie zamki!',
        failureMessage = 'Nie udało ci się otworzyć zamka!',
    },
    game = {
        logic = {
            endDelay = 200,
            speed = 1.0,
            bufferTime = 200,
            targetGoal = 4,
            loadingTime = 3000,
            _clamp = {
                targetGoal = { min = 1, max = 10, step = 1 }
            }
        }
    },
    appearance = {
        countdown = {
            textColor = '#ffffff',
        },
        text = {
            textColor = '#ffffff',
            border = Config.GlobalConfig.accentColor,
            borderRadius = 0.5,
            backgroundColor = '#0c0a0999',
            shadow = Config.GlobalConfig.accentColor .. 'CC',
        },
        ring = {
            width = 30,
            color = '#00000066'
        },
        hole = {
            fillStyle = '#00000066',
            strokeStyle = Config.GlobalConfig.accentColor,
            radius = 20,
            strokeWidth = 2
        },
        holeHit = {
            fillStyle = Config.GlobalConfig.accentColor .. 60,
            strokeStyle = Config.GlobalConfig.accentColor
        },
        holeFailed = {
            fillStyle = '#ff444760',
            strokeStyle = '#ff4447'
        },
        ballFailed = {
            fillStyle = '#ff4447',
            shadowColor = '#ff4447',
        },
        ball = {
            radius = 10,
            shadowBlur = 12,
            shadowColor = Config.GlobalConfig.accentColor,
            fillStyle = Config.GlobalConfig.accentColor,
        },
        background = { color = '#00000000' },
        keycap = {
            enabled = true,
            textColor = '#ffffff',
            border = '#ffffff1a',
            borderRadius = 0.375,
            backgroundColor = '#0c0a09cc',
            shadow = '#ffffff66',
        }
    }
}
Config.Minigames.Lockpick = {
    audio = {
        pickSound = { value = 'pick.mp3', volume = 1.0 },
        endSound = { value = 'end.mp3', volume = 1.0 },
    },
    info = {
        id = 'Lockpick',
        name = 'Lockpicking',
        description = 'Naciśnij E, aby otworzyć zamek!',
        successMessage = 'Otworzyłeś wszystkie zamki!',
        failureMessageEarly = 'Otworzyłeś zamek za wcześnie!',
        failureMessageLate = 'Otworzyłeś zamek za późno!',
        failureMessageMissed = 'Przegapiłeś zamek!',
    },
    game = {
        logic = {
            endDelay = 600,
            speed = 1,
            targetGoal = 10,
            loadingTime = 3000,
            _clamp = {
                targetGoal = { min = 1, max = 30, step = 1 }
            }
        }
    },
    appearance = {
        countdown = {
            textColor = '#ffffff',
        },
        text = {
            textColor = '#ffffff',
            border = Config.GlobalConfig.accentColor,
            borderRadius = 0.5,
            backgroundColor = '#0c0a0999',
            shadow = Config.GlobalConfig.accentColor .. 'CC',
        },
        bar = {
            width = 10,
            height = 1.25,
            fill = Config.GlobalConfig.accentColor .. 'CC',
            border = Config.GlobalConfig.accentColor,
            borderRadius = 0.375,
            backgroundColor = '#0c0a0999',
            shadow = '#ffffff99',
        },
        pick = {
            zIndex = 30,
            size = 0.6,
            bounceSize = 1.5,
            border = '#ffffff1a',
            borderRadius = 0.375,
            backgroundColor = '#ffffff',
            shadow = Config.GlobalConfig.accentColor .. 'CC',
            proximity = {
                proxEnabled = false,
                closeColor = '#00FF00',
                mediumColor = '#FFFF00',
                farColor = '#888888',
                thresholds = {
                    close = 0.5,
                    medium = 1.25,
                },
            },
        },
        lock = {
            zIndex = 20,
            width = 2,
            height = 2,
            enabled = true,
            active = {
                backgroundColor = '#0c0a09cc',
                border = Config.GlobalConfig.accentColor,
                borderRadius = 0.375,
                size = 1.1,
            },
            next = {
                backgroundColor = '#0c0a09cc',
                border = Config.GlobalConfig.accentColor .. 'CC',
                borderRadius = 0.375,
                size = 0.95,
            },
            completed = {
                backgroundColor = '#0c0a09cc',
                border = '#87da21cc',
                borderRadius = 0.375,
                size = 0.75,
            },
        },
        icon = {
            zIndex = 40,
            enabled = false,
            active = {
                icon = 'fa-solid fa-lock',
                color = '#ffffff',
                size = 0.7,
                shadow = Config.GlobalConfig.accentColor,
            },
            next = {
                icon = 'fa-solid fa-lock',
                color = '#ffffffcc',
                size = 0.5,
                shadow = Config.GlobalConfig.accentColor,
            },
            completed = {
                icon = 'fa-solid fa-lock-open',
                color = '#ffffffcc',
                size = 0.35,
                shadow = Config.GlobalConfig.accentColor,
            },
        },
        keycap = {
            enabled = true,
            textColor = '#ffffff',
            border = '#ffffff1a',
            borderRadius = 0.375,
            backgroundColor = '#0c0a09cc',
            shadow = '#ffffff66',
        }
    }
}
Config.Minigames.MineSweeper = {
    audio = {
        explosionSound = { value = 'explosion.mp3', volume = 1.0 },
        clickSound = { value = 'click.wav', volume = 1.0 },
    },
    info = {
        id = 'MineSweeper',
        name = 'Mine Sweeper',
        title = 'Saper',
        description = 'Odkryj wszystkie pola bez min lub oznacz wszystkie miny!',
        successMessage = 'Oczyściłeś pole!',
        failureMessage = 'Trafiłeś na minę.',
    },
    game = {
        logic = {
            endDelay = 600,
            gridSize = 6,
            mineCount = 4,
            loadingTime = 2000,
            safeStart = true,
            showTotalMines = true,
            enableFlagging = true,
        }
    },
    appearance = {
        container = Config.GlobalConfig.container,
    }
}
Config.Minigames.PairMatch = {
    audio = {
        successSound = { value = 'success.mp3', volume = 1.0 },
        wrongSound = { value = 'fail2.mp3', volume = 1.0 },
        failSound = { value = 'fail.mp3', volume = 1.0 },
    },
    info = {
        id = 'PairMatch',
        name = 'Pair Match',
        title = 'Dopasuj Pary',
        description = 'Zapamiętaj planszę i dopasuj pary!',
        successMessage = 'Dopasowałeś wszystkie pary!',
        failureMessage = 'Nie udało ci się dopasować par!',
    },
    game = {
        logic = {
            endDelay = 600,
            loadingTime = 3000,
            displayTime = 5000,
            gridSize = 6,
            requiredMatches = 12,
            allowedMisses = 0,
        }
    },
    appearance = {
        shapes = {
            mystery = { displayImage = 'nui://lc-minigames/web/assets/PairMatch/0.png', color = '#FFFFFF'},
            hexagon = { displayImage = 'nui://lc-minigames/web/assets/PairMatch/1.png', color = '#FFBB0B'},
            circle = { displayImage = 'nui://lc-minigames/web/assets/PairMatch/2.png', color = '#FF1515'},
            square = { displayImage = 'nui://lc-minigames/web/assets/PairMatch/3.png', color = '#FF2F93'},
            octagon = { displayImage = 'nui://lc-minigames/web/assets/PairMatch/4.png', color = '#A20BFF'},
            pentagon = { displayImage = 'nui://lc-minigames/web/assets/PairMatch/5.png', color = '#0BD3FF'},
            diamond = { displayImage = 'nui://lc-minigames/web/assets/PairMatch/6.png', color = '#4AFF0B'},
        },
        container = Config.GlobalConfig.container
    }
}
Config.Minigames.PipeConnect = {
    audio = {
        successSound = { value = 'success.mp3', volume = 1.0 },
        failSound = { value = 'fail.mp3', volume = 1.0 },
    },
    info = {
        id = 'PipeConnect',
        name = 'Cable Connect',
        title = 'Cable Connect',
        description = 'Zainfekuj system, obracając węzły danych i rozprzestrzeniając błąd do pliku docelowego.',
        successMessage = 'System został pomyślnie zainfekowany.',
        failureMessage = 'Infekcja nie powiodła się. Kod pozostaje bezpieczny.',
    },
    game = {
        logic = {
            endDelay = 600,
            duration = 10000,
            gridSize = 8,
        }
    },
    appearance = {
        container = Config.GlobalConfig.container
    }
}
Config.Minigames.PipeDodge = {
    audio = {
        successSound = { value = 'success.mp3', volume = 1.0 },
        failSound = { value = 'fail.mp3', volume = 1.0 },
    },
    info = {
        id = 'PipeDodge',
        name = 'Pipe Dodge',
        title = 'Przełamanie Firewall',
        description = 'Nawiguj przez protokoły bezpieczeństwa i omijaj firewalle, aby dotrzeć do rdzenia.',
        successMessage = 'Włamanie udane. Rdzeń przeniknięty.',
        failureMessage = 'Ślad wykryty. Włamanie nie powiodło się.',

    },
    game = {
        movementKeys = {
            keyUp = { 'ArrowUp', 'W' },
            keyDown = { 'ArrowDown', 'S' },
            keyLeft = { 'ArrowLeft', 'A' },
            keyRight = { 'ArrowRight', 'D' },
        },
        logic = {
            endDelay = 600,
            loadingTime = 2000,
            duration = 10000,
            pipeCount = 10,
            gapHeight = 100,
            pipeSpeed = 30,
            ballSpeed = 100,
            lowGraphicsMode = false,
        }
    },
    appearance = {
        canvas = {
            width = 640,
            height = 640,
        },
        ball = {
            radius = 8,
            shadowBlur = 20,
            shadowColor = Config.GlobalConfig.accentColor,
            fillStyle = Config.GlobalConfig.accentColor,
        },
        pipe = {
            width = 10,
            shadowBlur = 15,
            shadowColor = '#ffffff',
            fillStyle = '#ffffff40',
            highlightNext = true,
            highlightFill = Config.GlobalConfig.accentColor,
            highlightColor = Config.GlobalConfig.accentColor,
            highlightBlur = 15,
        },
        container = Config.GlobalConfig.container,
    }
}
Config.Minigames.PipeJigsaw = {
    audio = {
        successSound = { value = 'success.mp3', volume = 1.0 },
        failSound = { value = 'fail.mp3', volume = 1.0 },
    },
    info = {
        id = 'PipeJigsaw',
        name = 'Cable Jigsaw',
        title = 'Łączenie przewodów',
        description = 'Zmontuj sieć kablową, aby ustanowić stabilne połączenie danych.',
        successMessage = 'Strumień danych ustanowiony. Transfer udany.',
        failureMessage = 'Połączenie niepełne. Dane utracone.',
    },
    game = {
        logic = {
            endDelay = 600,
            loadingTime = 3000,
            duration = 20000,
            gridSize = 5,
            _clamp = {
                gridSize = { min = 2, max = 12, step = 1 },
            }
        }
    },
    appearance = {
        cable = {
            color = Config.GlobalConfig.accentColor,
        },
        container = Config.GlobalConfig.container
    }
}
Config.Minigames.RhythmArrows = {
    audio = {
        successSound = { value = 'success.mp3', volume = 1.0 },
        failSound = { value = 'fail.mp3', volume = 1.0 },
        clickSound = { value = 'click.wav', volume = 1.0 },
    },
    info = {
        id = 'RhythmArrows',
        name = 'Rhythm Arrows',
        title = 'Rhythm Arrows',
        description = 'Omijaj hasło, wprowadzając poprawną sekwencję klawiszy!',
        successMessage = 'Dostęp przyznany.',
        failureMessage = 'Włamanie nie powiodło się. Połączenie zakończone.',

    },
    game = {
        logic = {
            endDelay = 1000,
            loadingTime = 2000,
            speed = 1,
            bufferTime = 200,
        }
    },
    appearance = {
        game = {
            width = 80,
            _clamp = {
                width = { min = 15, max = 100, step = 1 }
            }
        },
        keyCap = {
            type = 'mechanical',
            _options = {
                type = { 'mechanical', 'flat' }
            }
        },
        success = {
            color = Config.GlobalConfig.accentColor
        },
        fail = {
            color = '#ff4447'
        },
        container = Config.GlobalConfig.container,
    }
}
Config.Minigames.RhythmClick = {
    debug = {
        viewBounds = true,
    },
    info = {
        id = 'RhythmClick',
        name = 'Rhythm Clicker',
    },
    audio = {
        failSound = { value = 'fail.mp3', volume = 1.0 },
        clickSound = { value = 'click.wav', volume = 1.0 },
        clackSound = { value = 'clack.wav', volume = 1.0 },
    },
    game = {
        logic = {
            endDelay = 600,
            introBeeps = 5,
        },
        target = {
            targetSpawn = {
                spawnDelay = 600,
                spawnDelayRandomness = 0,
                _clamp = {
                    spawnDelay = { min = 100, max = 2000, step = 100 },
                    spawnDelayRandomness = { min = 0, max = 1000, step = 10 },
                }
            },
            targetGoal = 10,
            targetTiming = {
                clickWindowMin = 0.85,
                clickWindowMax = 1.15,
                minRadius = 70,
                maxRadius = 70,
                shrinkTime = 875,
            },
            _clamp = {
                targetGoal = { min = 1, max = 30, step = 1 }
            }
        },
        canvas = {
            spawnBounds = {
                left = 0.55,
                right = 0.95,
                top = 0.30,
                bottom = 0.70,
                _clamp = {
                    left = { min = 0, max = 1, step = 0.01 },
                    right = { min = 0, max = 1, step = 0.01 },
                    top = { min = 0, max = 1, step = 0.01 },
                    bottom = { min = 0, max = 1, step = 0.01 },
                }
            }
        }
    },
    appearance = {
        cursor = {
            scale = 60,
            _clamp = {
                scale = {
                    min = 10,
                    max = 100,
                    step = 1,
                }
            }
        },
        target = {
            baseRadius = 70,
            inactiveOpacity = 0.5,
            active = {
                baseFillColor = '#00000099',
                baseBorderColor = Config.GlobalConfig.accentColor,
                baseBorderWidth = 2,

                innerGlowStart = 0.7,
                innerGlowColor = '#00000099',
                innerGlowColor2 = '#00000099',

                innerFillColor = '#0000004d',
                borderColor = Config.GlobalConfig.accentColor,
                borderWidth = 5,
                outerGlowColor = Config.GlobalConfig.accentColor,
                outerGlowWidth = 2,
                ringColor = '#ffffff00',
                fontColor = '#ffffff',
                fontSize = 0.75,
                shadowBlur = 10,
                shadowColor = Config.GlobalConfig.accentColor,
                _clamp = {
                    fontSize = {
                        min = 0.30,
                        max = 1.0,
                        step = 0.05
                    }
                }
            },
            default = {

                baseFillColor = '#00000099',
                baseBorderColor = Config.GlobalConfig.accentColor,
                baseBorderWidth = 2,

                innerGlowStart = 0.5,
                innerGlowColor = '#ffffff00',
                innerGlowColor2 = '#ffffff00',

                innerFillColor = '#0000004d',
                borderColor = Config.GlobalConfig.accentColor,
                borderWidth = 2,
                outerGlowColor = Config.GlobalConfig.accentColor,
                outerGlowWidth = 3,
                ringColor = '#ffffff00',
                fontColor = '#ffffff',
                fontSize = 0.55,
                shadowBlur = 10,
                shadowColor = Config.GlobalConfig.accentColor,
                _clamp = {
                    fontSize = {
                        min = 0.30,
                        max = 1.0,
                        step = 0.05
                    }
                }
            },
            failed = {
                baseFillColor = '#000000cc',
                outerGlowColor = '#ff4d4d',
            },
        }
    },
}
Config.Minigames.SymbolMemory = {
    audio = {
        successSound = { value = 'success.mp3', volume = 1.0 },
        failSound = { value = 'fail.mp3', volume = 1.0 },
    },
    info = {
        id = 'SymbolMemory',
        name = 'Symbol Memory',
        title = 'Zapamiętywanie symboli',
        description = 'Zapamiętaj symbole!',
        successMessage = 'Zapamiętałeś wszystkie symbole!',
        failureMessageTime = 'Skończył ci się czas!',
        failureMessageWrong = 'Wybrano niepoprawny symbol!',
    },
    game = {
        logic = {
            endDelay = 600,
            loadingTime = 3000,
            displayTime = 5000,
            questionTime = 8000,
            totalRounds = 3,
        }
    },
    appearance = {
        container = Config.GlobalConfig.container,
    }
}
