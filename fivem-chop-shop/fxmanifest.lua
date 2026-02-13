fx_version 'cerulean'
game 'gta5'

author 'AEZAKMI'
description 'Mission invite via NPWD Messages + Chopshop Integration'
version '5.1.1'

lua54 'yes'

shared_scripts {
  'config.lua',
}

client_scripts {
  '@PolyZone/client.lua',
  '@PolyZone/CircleZone.lua',
  'client.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server.lua',
}

dependencies {
  'qb-core',
  'npwd',
  'oxmysql',
  'PolyZone',
  'qb-target'
}