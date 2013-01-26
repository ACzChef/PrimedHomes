proc(_home_dispacth, @args,
	@args = parse_args(@args)
	if(array_size(@args)) {
		@first = array_remove(@args, 0)
	} else {
		msg(color('Yellow'). '----' .color('White'). 'PrimedHomes Help - (<> = Required | [] = Optional)' color('Yellow'). '----')
		msg(color('Green'). '/home help [Command] '.color('White'). 'Displays this message or more specific info for a command.')
		msg(color('Green'). '/home set <Home> ' .color('White'). '- Set\'s a home to teleport to with /home.')
		msg(color('Green'). '/home delete <Home> ' .color('White'). '- Delete\'s a home previously made with /home set.')
		msg(color('Green'). '/home <Home> [Player] ' .color('White'). '- Teleport\'s you to a home previously made with /home set.')
		msg(color('Green'). '/home list ' .color('White'). '- List\'s all your homes.')
		msg(color('Green'). '/home info <Home> ' .color('White') '- Get\'s extra info on a specific home such as location, etc.')
		msg(color('Green'). '/home allow <Home> <Player> ' .color('White'). '- Allows another player to teleport to a home.')
		msg(color('Green'). '/home deny <Home> <Player> ' .color('White') '- Denies another player to teleport to a home.')
		die(color('Yellow')'-------------------------------------------')
	}

	switch(@first,
		array('set', 'create'),
			#get name from @args[0]
			#see if home exists
			#store home
			,
		array('delete', 'remove'),
			#Get name from @args[0]
			#see if home exists
			#delete home
			,
		array('list'),
			#get homes of player
			#list them
			,
		array('info'),
			#get name from @args[0]
			#see if home exists
			#list info
			,
		array('allow'),
			#get name from @args[0]
			#get player from @args[1]
			#see if home exists
			#see if player is online
			#Allow player
			,
		array('deny'),
			#get name from @args[0]
			#get player from @args[1]
			#see if home exists
			#see if player is online
			#Deny player
			,
		#else,
			#get name from @args[0]
			#see if home exists
			#see if @args[1] exists
			#go to home
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