

fx_version 'cerulean'
games { 'gta5' }
author 'https://justscripts.net/'
version '1.0.5'
lua54 'yes'

shared_scripts {
    'shared/utils.lua',
    'shared/controls.lua',
    'shared/events.lua',
    'shared/frameworks.lua',
    'shared/settings.lua',
    'shared/types.lua',

    'config.lua',
    'shared/configValdiation.lua',

    'locale.lua',
    'locales/*.lua',
}

client_scripts {
    'client/utils.lua',
    'client/main.lua',
    'client/cueController.lua',
    'client/framework.lua',
    'client/instructionalButtons.lua',
    'client/instructionalButtonsUsage.lua',
    'client/cueCamera.lua',
    'client/ballPlacement.lua',
    'client/hiddenModels.lua',
    'client/progressBar.lua',
    'client/playerPositionAtTable.lua',
    'client/cueAsPropInHand.lua',
    'client/cueStands.lua',
    'client/target.lua',
    'client/blips.lua',
    'client/resetTable.lua',
    'client/turn.lua',
}

server_scripts {
    'box2d/planck.js',
    'box2d/PoolSimulation.js',

    'server/main.lua',
    'server/cueAsPropInHand.lua',
    'server/framework.lua',
    'server/turn.lua',
}

ui_page 'ui/index.html'
files {
    'ui/*.js',
    'ui/*.css',
    'ui/*.html',
    'ui/sounds/*.mp3',
    'ui/sounds/*.wav',
}

file 'stream/js_pool_props.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/js_pool_props.ytyp'

escrow_ignore {
    'config.lua',
    'shared/*.*',
    'locales/*.*',
    'server/framework.lua',
    'client/framework.lua',
    'client/utils.lua',
    'client/target.lua',
    'client/hiddenModels.lua',
}
dependency '/assetpacks'
dependency '/assetpacks'