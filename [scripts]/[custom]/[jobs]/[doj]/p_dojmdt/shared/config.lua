Config = {}

Config.Debug = false -- true = debug prints
Config.Language = 'pl' -- en / de / pl / fr / es / it / nl / ru / tr / ar
Config.Manufacturer = true -- true = show manufacturer on vehicle details [set false if it seems to be duplicated]

Config.canOpenTablet = function()
    local playerState = LocalPlayer.state
    if playerState.isDead or playerState.isCuffed then
        return false
    end
    
    return true
end

Config.Permissions = {
    ['doj'] = {
        ['0'] = { -- Stażysta
            ['citizens'] = true, ['reports'] = true, ['courts'] = true,
            ['add_citizen_note'] = true,
        },
        ['1'] = { -- Urzędnik
            ['citizens'] = true, ['reports'] = true, ['courts'] = true, ['companies'] = true,
            ['add_citizen_note'] = true, ['add_citizen_tag'] = true,
        },
        ['2'] = { -- Starszy Urzędnik
            ['citizens'] = true, ['reports'] = true, ['courts'] = true,
            ['companies'] = true, ['inspections'] = true,
            ['add_citizen_note'] = true, ['add_citizen_tag'] = true, ['delete_citizen_note'] = true,
        },
        ['3'] = { -- Adwokat Prywatny
            ['citizens'] = true, ['reports'] = true, ['courts'] = true,
            ['add_citizen_note'] = true, ['add_citizen_tag'] = true, ['delete_citizen_note'] = true,
            ['create_announcement'] = true,
        },
        ['4'] = { -- Aplikant Adwokatury
            ['citizens'] = true, ['reports'] = true, ['courts'] = true,
            ['add_citizen_note'] = true, ['add_citizen_tag'] = true,
        },
        ['5'] = { -- Adwokat
            ['citizens'] = true, ['reports'] = true, ['courts'] = true, ['companies'] = true,
            ['add_citizen_note'] = true, ['delete_citizen_note'] = true,
            ['add_citizen_license'] = true, ['remove_citizen_license'] = true,
            ['create_announcement'] = true,
        },
        ['6'] = { -- Starszy Adwokat
            ['citizens'] = true, ['reports'] = true, ['courts'] = true, ['companies'] = true,
            ['add_citizen_note'] = true, ['delete_citizen_note'] = true,
            ['add_citizen_license'] = true, ['remove_citizen_license'] = true,
            ['create_announcement'] = true, ['delete_announcement'] = true,
        },
        ['7'] = { -- Aplikant Prokuratury
            ['citizens'] = true, ['reports'] = true, ['courts'] = true,
            ['add_citizen_note'] = true,
        },
        ['8'] = { -- Prokurator
            ['citizens'] = true, ['reports'] = true, ['courts'] = true, ['inspections'] = true,
            ['add_citizen_license'] = true, ['remove_citizen_license'] = true,
            ['add_citizen_note'] = true, ['delete_citizen_note'] = true,
            ['create_announcement'] = true,
        },
        ['9'] = { -- Starszy Prokurator
            ['citizens'] = true, ['reports'] = true, ['courts'] = true, ['inspections'] = true,
            ['companies'] = true,
            ['add_citizen_license'] = true, ['remove_citizen_license'] = true,
            ['add_citizen_note'] = true, ['delete_citizen_note'] = true,
            ['create_announcement'] = true, ['delete_announcement'] = true,
            ['transfer_vehicle'] = true,
        },
        ['10'] = { -- Sędzia Adept
            ['citizens'] = true, ['reports'] = true, ['courts'] = true,
            ['add_citizen_note'] = true, ['add_citizen_tag'] = true,
        },
        ['11'] = { -- Sędzia
            ['citizens'] = true, ['reports'] = true, ['courts'] = true,
            ['add_citizen_license'] = true, ['remove_citizen_license'] = true,
            ['add_citizen_note'] = true, ['delete_citizen_note'] = true,
            ['create_announcement'] = true,
        },
        ['12'] = { -- Sędzia Federalny
            ['citizens'] = true, ['vehicles'] = true, ['reports'] = true,
            ['courts'] = true, ['inspections'] = true, ['companies'] = true,
            ['finances'] = true, ['announcements'] = true,
            ['add_citizen_license'] = true, ['remove_citizen_license'] = true,
            ['fire_player'] = true, ['hire_player'] = true, ['promote_player'] = true,
            ['withdraw_money'] = true, ['deposit_money'] = true, ['account_balance'] = true,
            ['society_transactions'] = true, ['society_chart'] = true,
            ['create_announcement'] = true, ['delete_announcement'] = true,
            ['transfer_vehicle'] = true,
        },
        ['13'] = { -- Adwokat Generalny
            ['citizens'] = true, ['vehicles'] = true, ['reports'] = true,
            ['courts'] = true, ['inspections'] = true, ['companies'] = true,
            ['finances'] = true, ['announcements'] = true,
            ['add_citizen_license'] = true, ['remove_citizen_license'] = true,
            ['fire_player'] = true, ['hire_player'] = true, ['promote_player'] = true,
            ['withdraw_money'] = true, ['deposit_money'] = true, ['account_balance'] = true,
            ['society_transactions'] = true, ['society_chart'] = true,
            ['create_announcement'] = true, ['delete_announcement'] = true,
            ['transfer_vehicle'] = true,
        },
        ['14'] = { -- Prokurator Generalny
            ['citizens'] = true, ['vehicles'] = true, ['reports'] = true,
            ['courts'] = true, ['inspections'] = true, ['companies'] = true,
            ['finances'] = true, ['announcements'] = true, ['employees'] = true, ['society'] = true,
            ['add_citizen_license'] = true, ['remove_citizen_license'] = true,
            ['fire_player'] = true, ['hire_player'] = true, ['promote_player'] = true,
            ['withdraw_money'] = true, ['deposit_money'] = true, ['account_balance'] = true,
            ['society_transactions'] = true, ['society_chart'] = true,
            ['charge_account'] = true, ['donate_account'] = true, ['save_account_note'] = true,
            ['create_inspection'] = true, ['transfer_vehicle'] = true,
            ['create_announcement'] = true, ['delete_announcement'] = true,
        },
        ['15'] = { -- Sędzia Główny
            ['citizens'] = true, ['vehicles'] = true, ['reports'] = true,
            ['courts'] = true, ['inspections'] = true, ['companies'] = true,
            ['finances'] = true, ['announcements'] = true, ['employees'] = true, ['society'] = true,
            ['add_citizen_license'] = true, ['remove_citizen_license'] = true,
            ['change_citizen_picture'] = true,
            ['fire_player'] = true, ['hire_player'] = true, ['promote_player'] = true,
            ['withdraw_money'] = true, ['deposit_money'] = true, ['account_balance'] = true,
            ['society_transactions'] = true, ['society_chart'] = true,
            ['charge_account'] = true, ['donate_account'] = true, ['save_account_note'] = true,
            ['create_inspection'] = true, ['transfer_vehicle'] = true,
            ['create_announcement'] = true, ['delete_announcement'] = true,
        },
        ['16'] = { -- Gubernator
            ['citizens'] = true, ['vehicles'] = true, ['reports'] = true,
            ['courts'] = true, ['inspections'] = true, ['companies'] = true,
            ['finances'] = true, ['announcements'] = true, ['employees'] = true, ['society'] = true,
            ['add_citizen_license'] = true, ['remove_citizen_license'] = true,
            ['change_citizen_picture'] = true, ['add_citizen_note'] = true, ['delete_citizen_note'] = true,
            ['add_citizen_tag'] = true, ['delete_citizen_tag'] = true,
            ['fire_player'] = true, ['hire_player'] = true, ['promote_player'] = true,
            ['withdraw_money'] = true, ['deposit_money'] = true, ['account_balance'] = true,
            ['society_transactions'] = true, ['society_chart'] = true,
            ['charge_account'] = true, ['donate_account'] = true, ['save_account_note'] = true,
            ['create_inspection'] = true, ['transfer_vehicle'] = true,
            ['create_announcement'] = true, ['delete_announcement'] = true,
            ['change_company_picture'] = true,
        },
    }
}