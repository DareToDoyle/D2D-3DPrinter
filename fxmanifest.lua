fx_version 'adamant'
game 'gta5'
lua54 'yes'
author 'DareToDoyle'
description 'D2D-Stims'
version '1.0'

ui_page "ui/index.html"

files {
	"ui/index.html",
	"ui/sounds/*.ogg",
}

shared_scripts {
    'config.lua',
	'@ox_lib/init.lua',
}

server_scripts {
	'server.lua',
}

client_scripts {
	'client.lua',
	
}
escrow_ignore {
  'config.lua', 
  'client.lua', 
  'server.lua', 
}

data_file 'DLC_ITYP_REQUEST' 'stream/bzzz_electro_prop_3dprinter.ytyp'

