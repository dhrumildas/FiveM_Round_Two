fx_version 'cerulean'
game 'gta5'

author 'Dhrumil'
description 'Mission invite via NPWD Messages (QBCore)'
version '1.0.0'

lua54 'yes'

shared_scripts {
  'config.lua',
}

client_scripts {
  'client.lua',
}

server_scripts {
  'server.lua',
}

dependencies {
  'qb-core',
  'npwd'
}
