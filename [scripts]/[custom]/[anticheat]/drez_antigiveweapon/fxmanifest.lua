

fx_version "cerulean"
game "gta5"
lua54 "yes"
author "Drez https://github.com/Drezx | https://drez.tebex.io/"


client_scripts {
    "config/client_config.lua",
    "client/client.lua",
}

server_scripts {
    "config/client_config.lua",
    "config/server_config.lua",
    "server/server.lua",
}

escrow_ignore {
    "config/client_config.lua",
    "config/server_config.lua",
}
dependency '/assetpacks'