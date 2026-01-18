

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'QF Developers'
description 'esx_core'
this_is_a_map 'yes'
shared_scripts {
    '@es_extended/imports.lua',
	'@esx_hash/hasher.lua',
    '@ox_lib/init.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'server/config.lua',
    'server/scripts/**/*.lua',
	'server/main/*.lua',
}

ui_page 'web/index.html'

files {
    'stream/meta/*.meta',
    'stream/meta/*.ymt',
    'stream/xml/*.xml',
    'stream/*.meta',
    'web/index.html'
}

data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weaponcompactrifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weaponmusket.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weaponmachinepistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weapons_smg_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weaponminismg.meta'
data_file 'WEAPON_ANIMATIONS_FILE' 'stream/meta/weaponanimations.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weapon_ceramicpistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weaponflashlight.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weaponheavypistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weaponmachete.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weapon_militaryrifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weaponcombatpdw.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weapon_pistolxm3.meta'
data_file 'WEAPONCOMPONENTSINFO_FILE' 'stream/meta/weaponcomponents.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weaponvintagepistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weapons_pistol_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weapons_snspistol_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weaponsnspistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weapons_heavysniper_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'stream/meta/weapons.meta'
-- data_file 'LOADOUTS_FILE' 'stream/meta/loadouts.meta'
data_file 'PED_TASK_DATA_FILE' 'stream/meta/motiontasks.ymt'
data_file 'PED_METADATA_FILE' 'stream/meta/pedaccuracy.meta'
data_file 'HANDLING_FILE' 'stream/meta/vehicleaihandlinginfo.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'stream/meta/vehiclelayouts.meta'
data_file 'CARCOLS_FILE' 'stream/meta/carcols.meta'
data_file 'HANDLING_FILE' 'stream/meta/handling.meta'
data_file 'AMBIENT_PROP_MODEL_SET_FILE' 'stream/meta/propsets.meta'
data_file 'VEHICLE_VARIATION_FILE' 'stream/meta/carvariations.meta'
data_file 'FIVEM_LOVES_YOU_4B38E96CC036038F' 'stream/meta/events.meta'
data_file 'MP_STATS_UI_LIST_FILE' 'stream/xml/mpstatssetupui.xml'
data_file 'MP_STATS_DISPLAY_LIST_FILE' 'stream/xml/mpstatssetup.xml'

exports {
    'showHeadbag',
    'hideHeadbag'
}