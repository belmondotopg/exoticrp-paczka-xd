

fx_version 'cerulean'
game 'gta5'
author 'pScripts [tebex.pscripts.store]'
description 'Most Advanced DOJ MDT System'
version '1.1.2'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/config.citizens.lua',
    'shared/config.reports.lua',
    'shared/config.courts.lua',
    'shared/config.employees.lua',
    'shared/config.taxes.lua',
}

client_scripts {
    'client/*.lua',
    'client/pages/*.lua',
    'client/bridge/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
    'server/pages/*.lua',
    'server/bridge/*.lua',
    'server/banking/*.lua',
    'shared/config.logs.lua',
}

ui_page 'web/build/index.html'

files {
    'locales/*.json',
	'web/build/index.html',
	'web/build/**/*',
    'web/assets/**/*',
}

escrow_ignore {
    'server/pages/finances.lua',
    'shared/config.lua',
    'shared/config.citizens.lua',
    'shared/config.reports.lua',
    'shared/config.courts.lua',
    'shared/config.employees.lua',
    'shared/config.taxes.lua',
    'shared/config.logs.lua',
    'server/editable_functions.lua',
    'client/editable_functions.lua',
    'client/bridge/esx.lua',
    'client/bridge/qb.lua',
    'client/bridge/qbox.lua',
    'server/bridge/esx.lua',
    'server/bridge/qb.lua',
    'server/bridge/qbox.lua',
    'server/banking/crm-banking.lua',
    'server/banking/esx-cloud-banking.lua',
    'server/banking/qb-cloud-banking.lua',
    'server/banking/piotreq_banking.lua',
    'server/banking/just-banks.lua',
    'server/banking/pefcl.lua',
    'server/banking/s1n-banking.lua',
    'server/banking/tgg-banking.lua',
    'server/banking/cloud-banking.lua',
    'server/banking/esx-qs-banking.lua',
    'server/banking/qb-qs-banking.lua',
    'server/banking/esx-renewed-banking.lua',
    'server/banking/qb-renewed-banking.lua',
    'server/banking/esx-wasabi-banking.lua',
    'server/banking/qb-wasabi-banking.lua',
    'server/banking/fd_banking.lua',
    'server/banking/p_banking.lua',
    'server/banking/RxBanking.lua',
    'server/banking/esx-okokBanking.lua',
    'server/banking/qb-okokBanking.lua',
    'server/banking/nfs-banking.lua',
    'server/banking/esx-snipe-banking.lua',
    'server/banking/qb-snipe-banking.lua',
}
dependency '/assetpacks'