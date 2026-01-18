fx_version 'cerulean'

game 'gta5'

description 'RTX HOUSING'

author 'RTX Development'

version '7.5'

server_scripts {
	--'@mysql-async/lib/MySQL.lua',  -- enable this and remove oxmysql line (line 11) if you use mysql-async (only enable this for qbcore/esx framework)
	'@oxmysql/lib/MySQL.lua', -- enable this and remove mysql async line (line 10) if you use oxmysql (only enable this for qbcore/esx framework)
	'config.lua',
	'configs/*.lua',
	'language/main.lua',
	'server/main.lua',
	'server/other.lua'
}

client_scripts {
	'config.lua',
	'configs/*.lua',
	'language/main.lua',
	'client/main.lua',
	'client/other.lua'
}

files {
	'html/ui.html',
	'html/sounds/*.mp3',
	'html/*.css',
	'html/img/*.webp',
	'html/img/furnitures/*.webp',
	'html/img/previewimages/*.webp',
	'html/img/dancers/*.webp',
	'html/*.js',
	'html/BebasNeueBold.ttf',
	'html/sign/index.html',
	'html/sign/styles.css',
	'html/sign/scripts.js'	
}

exports {
	'IsPlayerInPropertyZone',
	'IsCoordsInsideZone',
	'GetPropertyData',
	'HasPlayerAnyPropertyPermissions',
	'GetPropertyPermissions',
	'GetPropertyPermission',
	'IsPlayerInsideProperty',
	'GetPlayerOwnedProperties',
	'TeleportPlayerToStartingApartment',	
}

server_exports {
	'GetPropertyData',
	'GetAllProperties',
	'RemovePropertyOwnership',
	'DeleteProperty',
	'IsPlayerInsideProperty',
	'CheckPropertyKeys',
	'GetPropertyPermissions',
	'HasPlayerAnyPropertyPermissions',
	'GetPropertyPermission',
	'EnterPropertyPlayer',
	'ExitPropertyPlayer',
	'GivePropertySource',
	'GivePropertyIdentifier',	
	'GiveStarterApartment',	
	'TeleportPlayerToStartingApartment',	
}


ui_page 'html/ui.html'

lua54 'yes'

escrow_ignore {
  'config.lua',
  'language/main.lua',
  'server/other.lua',
  'client/other.lua',
  'configs/shells.lua',
  'configs/ipls.lua',
  'configs/deliveries.lua',
  'configs/kitchen.lua',
  'configs/furniture.lua',
}
dependency '/assetpacks'