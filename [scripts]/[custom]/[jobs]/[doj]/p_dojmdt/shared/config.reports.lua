Config.Reports = {}

Config.Reports.Permissions = {
    ['doj'] = { --@param jobName: string
        ['0'] = 'lawyer', --@param grade: role [grade 0 is laweyer]
        ['1'] = 'irs', -- grade 1 is IRS
        ['2'] = 'prosecutor', -- grade 2 is prosecutor
        ['3'] = 'judge' -- grade 3 is judge
    }
}