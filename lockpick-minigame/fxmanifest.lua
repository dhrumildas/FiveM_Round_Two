fx_version 'cerulean'
game 'gta5'

description 'Simple Car Robbery Mission'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua', -- Optional if you use locales, but safe to omit for simple scripts
    'config.lua'      -- Optional
}

client_scripts {
    'client.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'qb-vehiclekeys',
    't3_lockpick'
}