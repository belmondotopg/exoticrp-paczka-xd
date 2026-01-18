Config = {}
Config.AuthorizedGrade = {
    uwucafe = 4,
    whitewidow = 4,
    bahama_mamas = 4,
    beanmachine = 4,
    pizza = 4,
    pearl = 4,
    mexicana = 4,
    taxi = 5,
    lumberjack = 4,
    weazelnews = 4,
    police = 11,
    sheriff = 11,
    ambulance = 11,
    mechanik = 6,
    ec = 6,
    doj = 12,
}

Config.JobLicenses = {
    police = {
        'WU',
        'HELI',
        'CB',
        'SEU',
        'AIAD',
        'DTU',
        'SAHP',
        'SWAT',
    },
    sheriff = {
        'WU',
        'HELI',
        'CB',
        'SEU',
        'AIAD',
        'DTU',
        'SAHP',
        'SWAT',
    },
    ambulance = {
        'OU',
        'AFT',
        'SMU',
        'DIS',
        'MIAD'
    },
}

Config.UpgradesLegal = {
    {
        upgrade_name = 'Ulepszenie ilości slotów pracowników w Firmie',
        upgrade_source = 'legal_slots',
        upgrade_price = 5000000,
    },
}

Config.Delays = {
    RateLimitWindow = 5000,
    UpdateDelay = 300,
    GeneralWait = 100
}

Config.Limits = {
    MaxMoneyTransfer = 100000000,
    MaxBadgeLength = 10,
    MaxIdentifierLength = 100,
    MaxWebhookURLLength = 500
}

Config.Constants = {
    HIRE_DISTANCE = 3.0,
    ONE_WEEK_IN_SECONDS = 7 * 24 * 60 * 60
}

Config.AllowedUpgradeColumns = {
    ['legal_slots'] = true,
}

Config.LegalJobs = {
    'uwucafe',
    'whitewidow',
    'bahama_mamas',
    'beanmachine',
    'lumberjack',
    'pizza',
    'pearl',
    'mexicana',
    'taxi',
    'weazelnews',
}

Config.FractionJobs = {
    'police',
    'sheriff',
    'ambulance',
    'mechanik',
    'ec'
}

Config.RateLimits = {
    depositMoney = {maxCalls = 10, timeWindow = 5},
    withdrawMoney = {maxCalls = 10, timeWindow = 5},
    transferMoney = {maxCalls = 5, timeWindow = 5},
    targetChangeGrade = {maxCalls = 10, timeWindow = 5},
    targetChangeBadge = {maxCalls = 10, timeWindow = 5},
    fireTargetPlayer = {maxCalls = 5, timeWindow = 5},
    hirePlayer = {maxCalls = 5, timeWindow = 5},
    addLicense = {maxCalls = 10, timeWindow = 5},
    hoursReset = {maxCalls = 1, timeWindow = 60},
    tuneCountReset = {maxCalls = 1, timeWindow = 60},
    coursesReset = {maxCalls = 1, timeWindow = 60},
    targetResetCourses = {maxCalls = 5, timeWindow = 5},
    targetResetHours = {maxCalls = 5, timeWindow = 5},
    tuneReset = {maxCalls = 1, timeWindow = 60},
    discordWebhook = {maxCalls = 5, timeWindow = 10},
    buyUpgradeLegal = {maxCalls = 5, timeWindow = 5},
}