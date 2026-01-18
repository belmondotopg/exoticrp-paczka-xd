

games {
    "gta5"
}

version "3.0.9"

fx_version "cerulean"

nui_callback_strict_mode "true"

use_experimental_fxv2_oal "yes"

lua54 "yes"

ui_page "src/web/dist/index.html"

files {
    "src/web/dist/index.html",
    "src/web/dist/**/*",
    "controls.json",
    "data/weapons.meta",
    "data/weaponanimations.meta",
    "colors.css"
}

data_file "DLC_ITYP_REQUEST" "stream/bzzz_props.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/bzzz_camp_props.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/bzzz_murderpack.ytyp"
data_file 'DLC_ITYP_REQUEST' 'bzzz_prop_give_gift.ytyp'
data_file "DLC_ITYP_REQUEST" "stream/custom_prop.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/samnick_prop_lighter01.ytyp"
data_file 'DLC_ITYP_REQUEST' 'natty_props_lollipops.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_heart.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_heartfrappe.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_shake_bubblegum.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_shake_cherry.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/kaykaymods_props.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_shake_chocolate.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_shake_coffee.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_shake_doublechocolate.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_shake_frappe.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_shake_lemon.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_shake_mint.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_shake_raspberry.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_shake_rsaltedcaramel.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_shake_strawberry.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_shake_vanilla.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_cherryshake_vanilla.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_cherryshake_bubblegum.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_cherryshake_cherry.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_cherryshake_chocolate.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_cherryshake_coffee.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_cherryshake_doublechocolate.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_cherryshake_frappe.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_cherryshake_lemon.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_cherryshake_mint.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_cherryshake_raspberry.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_cherryshake_salted.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brum_cherryshake_strawberry.ytyp'

data_file "WEAPONINFO_FILE_PATCH" "data/weapons.meta"
data_file "WEAPON_ANIMATIONS_FILE" "data/weaponanimations.meta"

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua",
    "src/resource/shared/modules/callbacks.lua",
    "src/resource/shared/**/*.lua",
    "animations/*.lua",
    "animations/creators/*.lua",
    "locales/*.lua"
}

client_scripts {
    "src/resource/client/**/*.lua",
    "frameworks/qbox/client.lua",
    'frameworks/custom/client.lua',
    "frameworks/esx/client.lua",
    "frameworks/qbcore/client.lua"
}

server_scripts {
    "webhooks.lua",
    'src/resource/server/**/*.lua',
    'frameworks/qbox/server.lua',
    'frameworks/custom/server.lua',
    'frameworks/esx/server.lua',
    'frameworks/qbcore/server.lua',
}

dependencies {
    "ox_lib"
}

escrow_ignore {
    "config.lua",
    "webhooks.lua",
    "controls.json",
    'frameworks/**/*.lua',
    "animations/*.lua",
    "animations/creators/*.lua",
    "locales/*.lua",
    "src/resource/shared/funcs.lua",
    "src/resource/client/modules/*.lua",
    "src/resource/shared/modules/backward_compatibility.lua",
    "stream/**/*",
    "colors.css"
}

dependency '/assetpacks'