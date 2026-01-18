fx_version "cerulean"

description "Complete Gangs/Organizations System."
author "OTHERPLANET"
version '2.1.3'

lua54 'yes'

game 'gta5'

ui_page 'web/build/index.html'

shared_scripts {
	'@ox_lib/init.lua',
}

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
	'config/MainConfig.lua',
	'framework/shared.lua',
	'locales/*.lua',
	'config/GraffitiForbidden.lua',
	'config/TurfConfig.lua',
	'config/ClothingConfig.lua',
	'config/Missions/*.lua',
	'config/ClothingConfig.lua',
	'framework/client/shared.lua',
	'framework/client/esx.lua',
	'framework/client/qb.lua',
	'framework/client/qbox.lua',
	'integrations/client/**',
	'client/**',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config/MainConfig.lua',
	'framework/shared.lua',
	'locales/*.lua',
	'config/ServerConfig.lua',
	'config/TurfConfig.lua',
	'config/Missions/*.lua',
	'framework/server/shared.lua',
	'framework/server/esx.lua',
	'framework/server/qb.lua',
	'framework/server/qbox.lua',
	'integrations/server/**',
	'server/**',
}

files {
	'web/build/index.html',
	'web/build/**/*',
	'dui/**'
}

escrow_ignore {
	'client/library/**',
	'config/**',
	'locales/**',
	'framework/**',
	'integrations/**',
}
dependency '/assetpacks'