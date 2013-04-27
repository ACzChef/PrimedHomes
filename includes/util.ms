# aczchef.primedhomes.<player>.
#    +-<home> array
#    |    +-name string
#    |    +-location vector
#    |    +-facing vector
#    |    +-sharedto array
#    |        +-<player> string
#    |        +-<player> string
#    |        +-...
#    |
#    +-info array
#    |    +-access array
#    |        +-<player> array
#    |            +-<home> string
#    |        +-<player> array
#    |            +-<home> string
#    |            +-<home> string
#    |        +-...


proc(_name_sanitize, @n,
    return(reg_replace('[^0-9a-zA-Z.]', '_', to_lower(@n)))
)

proc('_create_home', @n, @p = player(),
    @name = @n
    @n = _name_sanitize(@n)
    if(@p == '~console') {
        die(_format('Player context is required.', error))
    }

    @homes = _get_homes(@p)
    @length = array_size(@homes)
    if(array_index_exists(@homes, 'aczchef.primedhomes.' .@p. '.info')) {
        @length -= 1
    }
    # limit of 10 homes per-player
    for(@i = 10, @i != 0, @i--,
        if(_perm('home.'. @i)) {
            if(@i > @length) {
                break()
            } else {
                die(_format('You\'ve reached your limit of homes', error))
            }
        } else {
        if(@i == 0) {
            die(_format('You\'ve reached your limit of homes', error))
        }
            continue()
        }
    )


    if(is_null(@name) || @name == '') {
        console(color('Red'). 'Error: _create_home recieved an invalid name (This message shouldn\'t have shown.)')
        die(color('Red'). 'Error: You didnt specify the name. (This message shouldn\'t have shown.)')
    }

    if(to_lower(@name) == 'bed' || to_lower(@name) == 'info') {
        die(_format('That is a restricted home name, Please choose a new one.', error))
    }

    if(_home_exists(@name, @p)) {
        die(_format('There is already a home with that name.', 'error'))
    }

    @home = array()
    @home['name'] = @name
    @home['location'] = ploc()
    @home['facing'] = pfacing()
    @home['sharedto'] = array()
    _store_home(@n, @home, @p)

    msg(_format('Home Set!', 'success'))
)

proc('_delete_home', @n, @p = player(),
    @name = @n
    @n = _name_sanitize(@n)
    if(@p == '~console') {
        die(_format('Player context is required.', error))
    }

    if(is_null(@name) || @name == '') {
        console(color('Red'). 'Error: _delete_home recieved an invalid name (This message shouldn\'t have shown.)')
        die(color('Red'). 'Error: You didnt specify the name. (This message shouldn\'t have shown.)')
    }

    if(!_home_exists(@name, @p)) {
        die(_format('You don\'t have a home by that name:' '"'.@name.'"', error))
    } else {
        @home = _get_home(@name, @p)
    }

    foreach(@home['sharedto'], @share,
        @data = _get_data(@share)
        array_remove_values(@data['access'][@p], @home['name'])
        _store_data(@data, @share)
    )

    _clear_home(@name)
    msg(_format('Home Deleted!', success))
)

proc('_go_home', @n, @to, @p = player(),
    @name = @n
    @n = _name_sanitize(@n)
    if(@p == '~console') {
        die(_format('Player context is required.', error))
    }

    if(is_null(@name) || @name == '') {
        console(color('Red'). 'Error: _go_home recieved an invalid name (This message shouldn\'t have shown.)')
        die(color('Red'). 'Error: You didnt specify the name. (This message shouldn\'t have shown.)')
    }

    if(_home_exists(@n, @to)) {
        @home = _get_home(@n, @to)
        if(@to != @p) {
            if(!array_contains(@home['sharedto'], @p)) {
                die(_format('You don\'t have access to' @to. '\'s Home:' @home['name'], error))
            }
        }
        set_ploc(@p, @home['location'])
        pfacing(@p, @home['facing'][0], @home['facing'][1])
        if(@to == @p) {
            msg(_format('Welcome Home:' @home['name'], success))
        } else {
            msg(_format('Welcome to' @to. '\'s Home:' @home['name'], success))
        }
    } else {
        if(@to == @P) {
            die(_format('You don\'t have a home by that name:' '"'.@name.'"', error))
        } else {
            die(_format('Player:' '"'.@to.'"' 'doesn\'t have a home by that name:' '"'.@name.'"', error))
        }
    }
)

proc('_home_exists', @name, @p = player(), 
    if(@name == '' || is_null(@name)) {
        console(color('Red'). 'Error: _home_exists recieved an invalid name (This message shouldn\'t have shown.)')
        die(color('Red'). 'Error: You didnt specify the name. (This message shouldn\'t have shown.)')
    }
    if(has_value('aczchef.primedhomes.' .@p. '.' ._name_sanitize(@name))) {
        return(true)
    } else {
        return(false)
    }
)

proc(_home_share, @name, @p1, @s = true, @p2 = player(),
    if(@name == '' || is_null(@name)) {
        console(color('Red'). 'Error: _home_share recieved an invalid name (This message shouldn\'t have shown.)')
        die(color('Red'). 'Error: You didnt specify the name. (This message shouldn\'t have shown.)')
    }

    if(@p1 == @p2) {
        die(_format('You can\'t give yourself access to your own homee.', error))
    }

    if(_home_exists(@name, @p2)) {
        @home = _get_home(@name, @p2)
    } else {
        die(_format('You don\'t have a home by that name:' '"'.@name.'"', error))
    }
    if(_has_data(@p1)) {
        @data = _get_data(@p1)
    } else {
        @data = array()
        @data['access'] = array()
        _store_data(@data, @p1)
    }
    if(@s) {
        if(array_contains(@home['sharedto'], @p1)) {
            die(_format('That player already has access to:' @home['name'], error))
        }
        array_push(@home['sharedto'], @p1)
        if(array_index_exists(@data['access'], @p2)) {
            array_push(@data['access'][@p2], @home['name'])
        } else {
            @data['access'][@p2] = array(@home['name'])
        }
        msg(_format(@p1 'Now has access to your home:' @home['name'], success))
    } else {
        if(!array_contains(@home['sharedto'], @p1)) {
            die(_format('That player already has no access to:' @home['name'], error))
        }
        array_remove_values(@home['sharedto'], @p1)
        if(array_size(@data['access'][@p2]) <= 1) {
            array_remove(@data['access'], @p2)
        } else {
            array_remove_values(@data['access'][@p2], @home['name'])
        }
        msg(_format(@p1 'No longer has access to your home:' @home['name'], success))
    }
    _store_data(@data, @p1)
    _store_home(@name, @home, @p2)
)

proc(_get_data, @p = player(),
    return(get_value('aczchef.primedhomes.' .@p. '.info'))
)

proc(_store_data, @data, @p = player(),
    store_value('aczchef.primedhomes.' .@p. '.info', @data)
)

proc(_has_data, @p = player(),
    return(has_value('aczchef.primedhomes.' .@p. '.info'))
)

proc(_get_home, @name, @p = player(),
    return(get_value('aczchef.primedhomes.' .@p. '.' ._name_sanitize(@name)))
)

proc(_get_homes, @p = player()
    return(get_values('aczchef.primedhomes.' .@p))
)

proc(_store_home, @name, @data, @p = player(),
    store_value('aczchef.primedhomes.' .@p. '.' ._name_sanitize(@name), @data)
)

proc(_clear_home, @name, @p = player(),
    clear_value('aczchef.primedhomes.' .@p. '.' ._name_sanitize(@name))
)

proc(_format, @message, @type,
    @type = to_lower(@type)
    if(@type == 'success') {
        return(color('Dark_Green'). '[' .color('Green'). 'Primed Homes' .color('Dark_Green'). ']' color('Green'). '»' color('White'). @message)
    } else if(@type == 'error') {
        return(color('Dark_red'). '[' .color('Red'). 'Primed Homes' .color('Dark_Red'). ']' color('Red'). '»' color('White'). @message)
    } else if(@type == 'notification') {
        return(color('Blue'). '[' .color('Yellow'). 'Primed Homes' .color('Blue'). ']' color('Yellow'). '»' color('White'). @message)
    }
)

proc(_perm, @perm, @p = player(),
    if(has_permission(@p, 'primedhomes.' .@perm) || (pisop(@p))) {
        return(true)
    } else {
        return(false)
    }
)