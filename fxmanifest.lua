fx_version 'cerulean'
game 'gta5'
author 'Jumar'
version '1.0.0'

lua54 'yes'

shared_scripts {

	'@ox_lib/init.lua',
	'@es_extended/imports.lua',
	'config.lua'
}

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
	'client/**/*.lua',
}

server_scripts {
	'server/**/*.lua'
}

dependencies {
	'ox_inventory'
}


escrow_ignore {
	'config.lua',
	'cl_function.lua',
	'sv_function.lua'
}