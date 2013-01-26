include('includes/util.ms')
proc(_home_dispatch, @args,
	@args = parse_args(@args)
	if(array_size(@args)) {
		@first = array_remove(@args, 0)
	} else {
		msg(color('Yellow'). '----' color('White'). 'PrimedHomes Help - (<> = Required | [] = Optional)' color('Yellow'). '----')
		msg(color('Green'). '/home help [Command] '.color('White'). 'Displays this message or more specific info for a command.')
		msg(color('Green'). '/home set <Home> ' .color('White'). '- Set\'s a home to teleport to with /home.')
		msg(color('Green'). '/home delete <Home> ' .color('White'). '- Delete\'s a home previously made with /home set.')
		msg(color('Green'). '/home <Home> [Player] ' .color('White'). '- Teleport\'s you to a home previously made with /home set.')
		msg(color('Green'). '/home list ' .color('White'). '- List\'s all your homes.')
		msg(color('Green'). '/home info <Home> ' .color('White'). '- Get\'s extra info on a specific home such as location, etc.')
		msg(color('Green'). '/home allow <Home> <Player> ' .color('White'). '- Allows another player to teleport to a home.')
		msg(color('Green'). '/home deny <Home> <Player> ' .color('White'). '- Denies another player to teleport to a home.')
		die(color('Yellow')'---------------------------------------------------')
	}

	switch(@first,
		array('set', 'create'),
			if(array_index_exists(@args, 0)) {
				@home = @args[0]
			} else {
				die(_format('You must specify a home name.', 'error'))
			}
			if(@home == '' || is_null(@home)) {
				die(_format('You must specify a home name.', 'error'))
			}
			_create_home(@home, player())
			,
		array('delete', 'remove'),
			if(array_index_exists(@args, 0)) {
				@home = @args[0]
			} else {
				die(_format('You must specify a home name.', 'error'))
			}
			if(@home == '' || is_null(@home)) {
				die(_format('You must specify a home name.', 'error'))
			}
			_delete_home(@home, player())
			,
		array('list'),
			@homes = _get_homes()
			if(!array_size(@homes)) {
				die(_format('You don\'t have any homes.', notification))
			}
			msg(_format('Here is a list of your homes.', notification))
			@id = 1
			foreach(@homes, @home,
				msg(color('Blue'). '[' .color('Yellow'). @id .color('Blue'). ']' color('Yellow'). '»' color('White'). @home['name'])
				@id++
			)
			,
		array('info'),
			msg(info)
			if(array_index_exists(@args, 0)) {
				@home = @args[0]
			} else {
				die(_format('You must specify a home name.', 'error'))
			}
			if(@home == '' || is_null(@home)) {
				die(_format('You must specify a home name.', 'error'))
			}
			@home = _get_home(@home)
			msg(_format('Here is some info on:' @home['name'], notification))
			msg(color('Blue'). '[' .color('Yellow'). 'Name' .color('Blue'). ']' color('Yellow'). '»' color('White'). @home['name'])
			msg(color('Blue'). '[' .color('Yellow'). 'Location' .color('Blue'). ']' color('Yellow'). '»' color('White'). 
			'X =' floor(@home['location'][0]). ', Y =' floor(@home['location'][1]). ', Z =' floor(@home['location'][2]). ', World =' @home['location'][3])
			if(array_size(@home['sharedto'])) {
				msg(color('Blue'). '[' .color('Yellow'). 'Players' .color('Blue'). ']' color('Yellow'). '»' color('White'). 'Players that have access to:' @home['name'])
				@id = 1
				foreach(@home['sharedto'], @player,
				msg(color('Blue'). '[' .color('Yellow'). @id .color('Blue'). ']' color('Yellow'). '»' color('White'). @player)
				@id++
				)
			} else {
				msg(color('Blue'). '[' .color('Yellow'). 'Players' .color('Blue'). ']' color('Yellow'). '»' color('White'). 'No players have access to:' @home['name'])
			}
			,
		array('allow'),
			msg(allow)
			if(array_index_exists(@args, 0)) {
				@home = @args[0]
			} else {
				die(_format('You must specify a home name.', 'error'))
			}
			if(@home == '' || is_null(@home)) {
				die(_format('You must specify a home name.', 'error'))
			}
			if(array_index_exists(@args, 1)) {
				try(@player = @args[1], die(_format('Player:' @args[1] 'Is not online.', error)))
			} else {
				die(_format('You must specify a player.', 'error'))
			}
			if(@player == '' || is_null(@player)) {
				die(_format('You must specify a player.', 'error'))
			}
			_home_share(@home, @player, true, player())
			,
		array('deny'),
			msg(deny)
			if(array_index_exists(@args, 0)) {
				@home = @args[0]
			} else {
				die(_format('You must specify a home name.', 'error'))
			}
			if(@home == '' || is_null(@home)) {
				die(_format('You must specify a home name.', 'error'))
			}
			if(array_index_exists(@args, 1)) {
				try(@player = @args[1], die(_format('Player:' @args[1] 'Is not online.', error)))
			} else {
				die(_format('You must specify a player.', 'error'))
			}
			if(@player == '' || is_null(@player)) {
				die(_format('You must specify a player.', 'error'))
			}
			_home_share(@home, @player, false, player())
			,
		array('help'),
			if(array_index_exists(@args, 0)) {
				@command = @args[0]
			} else {
				call_alias('/home')
				die()
			}

			switch(to_lower(@command),
				set,
					msg(_format('/home set <Home> - set\'s a home to teleport to later with /home this is the first thing about homes.', notification)),
				delete,
					msg(_format('/home delete <Home> - Delete\'s a home that has been made with /home set. Useful for when you\'re moving homes.', notification)),
				home,
					msg(_format('/home <Home> [Player] - Teleports to a home that has been made with /home set. When a player is specified you can teleport to their home if they allow you to have access to it with /home allow.', notification)),
				list,
					msg(_format('/home list - Lists all of the homes you have access to. Homes listed as Blue are homes that arent yours but you have access to, Homes listed as Red are homes that other players beside you have access to.', notification)),
				info,
					msg(_format('/home info <Home> - Gets extra info on a specific home that you own. The info that is returned is its Name, Location, and Shared Players.', notification)),
				allow,
					msg(_format('/home allow <Home> <player> - Allows another player to teleport to your home. If you want to later remove this use /home deny.', notification)),
				deny,
					msg(_format('/home deny <Home> <Player> - Denies another player to teleport to your home if he was allowed to before using /home allow.', notification)),
				#else,
					msg(_format('Possible /home help topics are Set, Delete, Home, List, Info, Allow, and Deny', notification))
			)
			,
		#else,
			@home = @first
			if(array_index_exists(@args, 0)) {
				try(@to = player(@args[0]), @to = @args[0])
			} else {
				@to = player()
			}
			_go_home(@home, @to, player())
	)
)

# help - (<> = required | [] = optional)
# /home set <home> - Set a home to teleport to with /home.
# /home delete <home> - Deletes a home previously made with /home set.
# /home <home> [player] - Teleports you to a home previously made with /home set. teleports to another player's home if you have access.
# /home list - Lists all your homes, homes with a "*" are homes that other players have access to.
# /home info <home> - Get extra info on a specific home such as location, players that access, etc.
# /home allow <home> <player> - Allows another player to teleport to your home.
# /home deny <home> <player> - Denies another player to teleport to your home.
## Admin commands (Shows with perms)
# /home delete <home> <player> - Deletes another players home.
# /home list <player> - list a players homes.
# /home listall - Lists all homes and their owners.
# /home <home> <player> - Takes you to another players home whether you have access or not.
# /home info <home> <player> - get info on a players home such as location, players that have access, etc.