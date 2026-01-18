-- PASTE IT IN qbx_core/shared/jobs

['doj'] = {
    label = 'DOJ',
    type = 'doj',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        [0] = {
            name = 'Lawyer',
            payment = 50
        },
        [1] = {
            name = 'IRS',
            payment = 75
        },
        [2] = {
            name = 'Prosecutor',
            payment = 100
        },
        [3] = {
            name = 'Judge',
            payment = 125
        },
    },
},