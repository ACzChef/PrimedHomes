# aczchef.primedhomes.
#	+-<warp> array
#	|	+-<name> string
#	|	+-<location> vector
#	|	+-<facing> vector
#	|	+-<owner> string
#	|	+-<sharedto> array
#	|		+-<player> string
#	|		+-<player> string
#	|		+-...
#	|
#	+-options


proc(_name_sanitize, @n,
    return(reg_replace('[^0-9a-zA-Z.]', '_', to_lower(@n)))
)

proc('_create_home', @name, @p = player(), 
	
	if(@p == '~console') {
		die(color('Red'). 'Player context is required')
	}

	if(is_null(@name) || @name == '') {
		console(color('Red'). 'Error: _create_home recieved an invalid name (This message shouldn\'t have shown.)')
		die(color('Red'). 'Error: You didnt specify the name. (This message shouldn\'t have shown.)')
	}
)