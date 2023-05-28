# /etc/sudoers.d/mmux-unsafe-users-management.conf --
#
# Configuration file for "sudo" usage by the package MMUX Unsafe Users
# Management.

# User alias specification
User_Alias	MMUX_SAFE_USERS_GROUP	= %mmux-safe-usrs

# Command aliases
Cmnd_Alias	MMUX_UNSAFE_USERS_ADD		= __SBINDIR__/mmux-unsafe-users-manager sudo-unsafe-users-add
Cmnd_Alias	MMUX_UNSAFE_USERS_DEL		= __SBINDIR__/mmux-unsafe-users-manager sudo-unsafe-users-del
Cmnd_Alias	MMUX_UNSAFE_USERS_SETUP		= __SBINDIR__/mmux-unsafe-users-manager sudo-unsafe-users-setup
Cmnd_Alias	MMUX_UNSAFE_USERS_NORMALISE	= __SBINDIR__/mmux-unsafe-users-manager sudo-unsafe-users-normalise
Cmnd_Alias	MMUX_UNSAFE_USERS_CMDS		= MMUX_UNSAFE_USERS_ADD, MMUX_UNSAFE_USERS_DEL, MMUX_UNSAFE_USERS_SETUP, MMUX_UNSAFE_USERS_NORMALISE

# User privilege  specification: all the  users in the  selected group
# can  run the  script "mmux-unsafe-users-manager"  with the  "sudo-*"
# actions on all the hosts, if they issue the root password.
MMUX_SAFE_USERS_GROUP ALL = MMUX_UNSAFE_USERS_CMDS

### end of file
# Local Variables:
# mode: script
# End:
