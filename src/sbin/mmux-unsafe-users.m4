#!/bin/bash
#
# Part of: MMUX Unsafe Users Management
# Contents: unsafe users management script
# Date: Sat Oct 11, 2014
#
# Abstract
#
#
#
# Copyright (C) 2014 Marco Maggi <marco.maggi-ipsu@poste.it>
#
# This  program  is free  software:  you  can redistribute  it
# and/or modify it  under the terms of the  GNU General Public
# License as published by the Free Software Foundation, either
# version  3 of  the License,  or (at  your option)  any later
# version.
#
# This  program is  distributed in  the hope  that it  will be
# useful, but  WITHOUT ANY WARRANTY; without  even the implied
# warranty  of  MERCHANTABILITY or  FITNESS  FOR A  PARTICULAR
# PURPOSE.   See  the  GNU  General Public  License  for  more
# details.
#
# You should  have received a  copy of the GNU  General Public
# License   along   with    this   program.    If   not,   see
# <http://www.gnu.org/licenses/>.
#

#page
#### global variables

declare -r script_PROGNAME=mmux-unsafe-users
declare -r script_VERSION=0.1d0
declare -r script_COPYRIGHT_YEARS='2014'
declare -r script_AUTHOR='Marco Maggi'
declare -r script_LICENSE=GPL
declare script_USAGE="usage: ${script_PROGNAME} [action] [options]"
declare script_DESCRIPTION='Unsafe users management operations.'
declare script_EXAMPLES=

declare -r SCRIPT_ARGV0="$0"
declare -r UNSAFE_HOME_PARENT=/home/unsafe-users

# Safe users group name, at most 16 characters.
#
#                           0123456789012345
declare -r SAFE_USERS_GROUP=mmux-safe-usrs

# Unsafe users group name, at most 16 characters.
#
#                             0123456789012345
declare -r UNSAFE_USERS_GROUP=mmux-unsafe-usrs

#page
#### library loading

mbfl_INTERACTIVE=no
mbfl_LOADED=no
mbfl_HARDCODED=
mbfl_INSTALLED=$(mbfl-config) &>/dev/null
for item in "$MBFL_LIBRARY" "$mbfl_HARDCODED" "$mbfl_INSTALLED"
do
    if test -n "$item" -a -f "$item" -a -r "$item"
    then
        if ! source "$item" &>/dev/null
	then
            printf '%s error: loading MBFL file "%s"\n' \
                "$script_PROGNAME" "$item" >&2
            exit 2
        fi
	break
    fi
done
unset -v item
if test "$mbfl_LOADED" != yes
then
    printf '%s error: incorrect evaluation of MBFL\n' \
        "$script_PROGNAME" >&2
    exit 2
fi

#page
#### program declarations

mbfl_dialog_enable_programs

mbfl_program_enable_sudo
mbfl_file_enable_remove

mbfl_declare_program /bin/mount
mbfl_declare_program /bin/umount
mbfl_declare_program /bin/grep
mbfl_declare_program /bin/chmod
mbfl_declare_program /usr/bin/install
mbfl_declare_program /usr/bin/xhost

mbfl_declare_program /usr/sbin/useradd
mbfl_declare_program /usr/sbin/userdel
mbfl_declare_program /usr/sbin/usermod
mbfl_declare_program /usr/sbin/groupadd
mbfl_declare_program /usr/sbin/groupdel
mbfl_declare_program /usr/sbin/groupmod

#page
#### script actions

mbfl_declare_action_set MAIN
mbfl_declare_action MAIN ADD		NONE add		'Add an unsafe user.'
mbfl_declare_action MAIN DEL		NONE del		'Delete an unsafe user.'
mbfl_declare_action MAIN BIND		NONE bind		'Mount unsafe users home directories under safe user one.'
mbfl_declare_action MAIN UNBIND		NONE unbind		'Unmount unsafe users home directories under safe user one.'
mbfl_declare_action MAIN ENABLE_X	NONE enable-x		'Enable unsafe users running X applications in safe user X server.'
mbfl_declare_action MAIN DISABLE_X	NONE disable-x		'Disable unsafe users running X applications in safe user X server.'
mbfl_declare_action MAIN SUDO_ADD	NONE sudo-add		'Internal action.'
mbfl_declare_action MAIN SUDO_DEL	NONE sudo-del		'Internal action.'
mbfl_declare_action MAIN SUDO_BIND	NONE sudo-bind		'Internal action.'
mbfl_declare_action MAIN SUDO_UNBIND	NONE sudo-unbind	'Internal action.'
mbfl_declare_action MAIN HELP		NONE help		'Print help screen and exit.'

## --------------------------------------------------------------------

function script_before_parsing_options_ADD () {
    script_USAGE="usage: ${script_PROGNAME} add UNSAFE-USERNAME --safe-user=SAFE-USERNAME [options]"
    script_DESCRIPTION='Add an unsafe user.'
    mbfl_declare_option SAFE_USERNAME '' S safe-user witharg 'Select the name of the safe user.'
}
function script_before_parsing_options_DEL () {
    script_USAGE="usage: ${script_PROGNAME} del UNSAFE-USERNAME --safe-user=SAFE-USERNAME [options]"
    script_DESCRIPTION='Remove an unsafe user.'
    mbfl_declare_option SAFE_USERNAME '' S safe-user witharg 'Select the name of the safe user.'
}
function script_before_parsing_options_BIND () {
    script_USAGE="usage: ${script_PROGNAME} bind [options]"
    script_DESCRIPTION='Mount unsafe users home directories under safe user one.'
    mbfl_declare_option SAFE_USERNAME '' S safe-user witharg 'Select the name of the safe user.'
}
function script_before_parsing_options_UNBIND () {
    script_USAGE="usage: ${script_PROGNAME} unbind [options]"
    script_DESCRIPTION='Unmount unsafe users home directories under safe user one.'
    mbfl_declare_option SAFE_USERNAME '' S safe-user witharg 'Select the name of the safe user.'
}
function script_before_parsing_options_ENABLE_X () {
    script_USAGE="usage: ${script_PROGNAME} enable-x [options]"
    script_DESCRIPTION='Enable unsafe users running X applications in safe user X server.'
    mbfl_declare_option SAFE_USERNAME '' S safe-user witharg 'Select the name of the safe user.'
}
function script_before_parsing_options_DISABLE_X () {
    script_USAGE="usage: ${script_PROGNAME} disable-x [options]"
    script_DESCRIPTION='Disable unsafe users running X applications in safe user X server.'
    mbfl_declare_option SAFE_USERNAME '' S safe-user witharg 'Select the name of the safe user.'
}

### --------------------------------------------------------------------

function script_before_parsing_options_SUDO_ADD () {
    script_USAGE="usage: ${script_PROGNAME} sudo-add SAFE-USERNAME UNSAFE-USERNAME [options]"
    script_DESCRIPTION='Internal action.'
}
function script_before_parsing_options_SUDO_DEL () {
    script_USAGE="usage: ${script_PROGNAME} sudo-del SAFE-USERNAME UNSAFE-USERNAME [options]"
    script_DESCRIPTION='Internal action.'
}
function script_before_parsing_options_SUDO_BIND () {
    script_USAGE="usage: ${script_PROGNAME} sudo-bind [options]"
    script_DESCRIPTION='Internal action.'
}
function script_before_parsing_options_SUDO_UNBIND () {
    script_USAGE="usage: ${script_PROGNAME} sudo-unbind [options]"
    script_DESCRIPTION='Internal action.'
}

#page
#### adding unsafe users

function script_action_ADD () {
    local FLAGS
    if mbfl_wrong_num_args 1 $ARGC
    then
	local SAFE_USERNAME=$script_option_SAFE_USERNAME
	local UNSAFE_USERNAME=${ARGV[0]}

	if test -z "$SAFE_USERNAME"
	then
	    mbfl_message_error 'missing safe username option selection'
	    exit_because_failure
	fi
	if ! mbfl_string_is_identifier "$SAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid safe username: %s' "$SAFE_USERNAME"
	    exit_because_failure
	fi
	if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid unsafe username: %s' "$UNSAFE_USERNAME"
	    exit_because_failure
	fi

	mbfl_option_verbose		&& FLAGS="$FLAGS --verbose"
    	mbfl_option_interactive		&& FLAGS="$FLAGS --interactive"
	mbfl_option_show_program	&& FLAGS="$FLAGS --show-program"
	mbfl_option_test		&& FLAGS="$FLAGS --test"

	mbfl_program_declare_sudo_user root
	if mbfl_program_exec "$SCRIPT_ARGV0" sudo-add "$SAFE_USERNAME" "$UNSAFE_USERNAME" $FLAGS
	then exit_success
	else
    	    mbfl_message_error 'adding user'
    	    exit_failure
	fi
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}
function script_action_SUDO_ADD () {
    local INSTALL USERADD USERMOD CHMOD CHMOD_FLAGS
    INSTALL=$(mbfl_program_found /usr/bin/install)  || exit_because_program_not_found
    USERADD=$(mbfl_program_found /usr/sbin/useradd) || exit_because_program_not_found
    USERMOD=$(mbfl_program_found /usr/sbin/usermod) || exit_because_program_not_found
    CHMOD=$(mbfl_program_found /bin/chmod)          || exit_because_program_not_found
    if mbfl_wrong_num_args 2 $ARGC
    then
	local SAFE_USERNAME=${ARGV[0]}
	local UNSAFE_USERNAME=${ARGV[1]}
	local UNSAFE_HOME="$UNSAFE_HOME_PARENT/$UNSAFE_USERNAME"

	if ! mbfl_string_is_identifier "$SAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid safe username: %s' "$SAFE_USERNAME"
	    exit_because_failure
	fi
	if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid unsafe username: %s' "$UNSAFE_USERNAME"
	    exit_because_failure
	fi

	# Make user the unsafe home directories parent exists.
	if ! mbfl_file_is_directory "$UNSAFE_HOME_PARENT"
	then
	    mbfl_message_verbose_printf 'creating top directory for unsafe users home: %s\n' "$UNSAFE_HOME_PARENT"
	    if mbfl_program_exec "$INSTALL" -m 0755 -o root -g root "$UNSAFE_HOME_PARENT"
	    then
		mbfl_message_error_printf 'creating unsafe home directories parent: %s' "$UNSAFE_HOME_PARENT"
		exit_because_failure
	    fi
	fi

	# Create the unsafe user.
	#
	# We assume  there exists a  group with the same  name of
	# the safe user.  We create a group with the same name of
	# the unsafe user.
	mbfl_message_verbose_printf 'creating unsafe user: %s\n' "$UNSAFE_USERNAME"
	if ! mbfl_program_exec "$USERADD" \
	    --base-dir		"$UNSAFE_HOME_PARENT"		\
	    --home		"$UNSAFE_HOME"			\
	    --create-home					\
	    --user-group					\
	    --groups		$UNSAFE_USERS_GROUP,audio,video	\
	    --shell		/bin/false			\
	    "$UNSAFE_USERNAME"
	then
	    mbfl_message_error_printf 'creating unsafe user: %s' "$UNSAFE_USERNAME"
	    mbfl_file_remove_directory_silently "$UNSAFE_HOME"
	    exit_because_failure
	fi

	# Set permissions for the unsafe user's home directory.
	CHMOD_FLAGS=--recursive
	if mbfl_option_verbose
	then CHMOD_FLAGS="${CHMOD_FLAGS} --verbose"
	fi
	if ! mbfl_program_exec "$CHMOD" 2770 "$UNSAFE_HOME" $CHMOD_FLAGS
	then mbfl_message_error 'setting permissions to unsafe user home'
	fi

	# Add safe user to the unsafe user's group.
	if ! mbfl_program_exec "$USERMOD" "$SAFE_USERNAME" \
	    --append --groups "$UNSAFE_USERNAME"
	then
	    mbfl_message_error "adding safe user to unsafe user's group"
	fi

	# Create  a  "~/.plan"  text  file   in  the  unsafe  user  home
	# directory.   It is  used by  the program  "finger" to  display
	# descriptive  informations  about  the user  account;  see  the
	# manpage of "finger" for details.
	printf 'Unsafe user account associated to the user "%s".\n' \
	    "$SAFE_USERNAME" >"$UNSAFE_HOME"/.plan
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

#page
#### deleting unsafe users

function script_action_DEL () {
    local FLAGS
    if mbfl_wrong_num_args 1 $ARGC
    then
	local SAFE_USERNAME=$script_option_SAFE_USERNAME
	local UNSAFE_USERNAME=${ARGV[0]}

	if test -z "$SAFE_USERNAME"
	then
	    mbfl_message_error 'missing safe username option selection'
	    exit_because_failure
	fi
	if ! mbfl_string_is_identifier "$SAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid safe username: %s' "$SAFE_USERNAME"
	    exit_because_failure
	fi
	if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid unsafe username: %s' "$UNSAFE_USERNAME"
	    exit_because_failure
	fi

	mbfl_option_verbose		&& FLAGS="$FLAGS --verbose"
    	mbfl_option_interactive		&& FLAGS="$FLAGS --interactive"
	mbfl_option_show_program	&& FLAGS="$FLAGS --show-program"
	mbfl_option_test		&& FLAGS="$FLAGS --test"

	mbfl_program_declare_sudo_user root
	if mbfl_program_exec "$SCRIPT_ARGV0" sudo-del "$SAFE_USERNAME" "$UNSAFE_USERNAME" $FLAGS
	then exit_success
	else
    	    mbfl_message_error 'deleting user'
    	    exit_failure
	fi
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}
function script_action_SUDO_DEL () {
    local USERDEL GROUPDEL
    USERDEL=$(mbfl_program_found /usr/sbin/userdel) || exit_because_program_not_found
    GROUPDEL=$(mbfl_program_found /usr/sbin/groupdel) || exit_because_program_not_found
    if mbfl_wrong_num_args 2 $ARGC
    then
	local SAFE_USERNAME=${ARGV[0]}
	local UNSAFE_USERNAME=${ARGV[1]}

	if ! mbfl_string_is_identifier "$SAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid safe username: %s' "$SAFE_USERNAME"
	    exit_because_failure
	fi
	if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid unsafe username: %s' "$UNSAFE_USERNAME"
	    exit_because_failure
	fi

	if mbfl_option_interactive
	then
	    local MESSAGE=$(printf 'delete the user "%s"' "$UNSAFE_USERNAME")
	    if ! mbfl_dialog_yes_or_no "$MESSAGE"
	    then
		mbfl_message_verbose_printf 'skipping deletion of user: %s\n' "$UNSAFE_USERNAME"
		exit_success
	    fi
	fi

	mbfl_message_verbose_printf 'deleting user: %s\n' "$UNSAFE_USERNAME"
	if ! mbfl_program_exec "$USERDEL" "$UNSAFE_USERNAME" --remove
	then mbfl_message_error_printf 'removing unsafe user: %s' "$UNSAFE_USERNAME"
	fi

	# When  "groupdel"  removes  the unsafe  group:  it  also
	# removes it  from the list  of groups of which  the safe
	# user is part.
	mbfl_message_verbose_printf 'deleting group: %s\n' "$UNSAFE_USERNAME"
	if ! mbfl_program_exec "$GROUPDEL" "$UNSAFE_USERNAME"
	then mbfl_message_error_printf 'removing unsafe group: %s' "$UNSAFE_USERNAME"
	fi
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

#page
#### binding unsafe users home to safe user directory

function script_action_BIND () {
    local FLAGS
    if mbfl_wrong_num_args 0 $ARGC
    then
	local SAFE_USERNAME=$script_option_SAFE_USERNAME
	local UNSAFE_USERNAME

	if test -z "$SAFE_USERNAME"
	then SAFE_USERNAME=$USER
	fi
	if test -z "$SAFE_USERNAME"
	then
	    mbfl_message_error 'missing safe username option selection'
	    exit_because_failure
	fi
	if ! mbfl_string_is_identifier "$SAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid safe username: %s' "$SAFE_USERNAME"
	    exit_because_failure
	fi

	mbfl_message_verbose_printf 'binding home directories of unsafe users associated to: %s\n' "$SAFE_USERNAME"

	local UNSAFE_MOUNT_POINT_PARENT="/home/$SAFE_USERNAME/var/unsafe-users"
	local UNSAFE_USERS_LIST_FILE="/home/$SAFE_USERNAME/.mmux-unsafe-users"
	if ! mbfl_file_is_file "$UNSAFE_USERS_LIST_FILE"
	then
	    mbfl_message_error_printf 'missing list of unsafe users file: %s\n' "$UNSAFE_USERS_LIST_FILE"
	    exit_because_failure
	fi

	mbfl_option_verbose		&& FLAGS="$FLAGS --verbose"
    	mbfl_option_interactive		&& FLAGS="$FLAGS --interactive"
	mbfl_option_show_program	&& FLAGS="$FLAGS --show-program"
	mbfl_option_test		&& FLAGS="$FLAGS --test"

	while read UNSAFE_USERNAME
	do
	    if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
	    then
		mbfl_message_error_printf 'invalid unsafe username: %s' "$UNSAFE_USERNAME"
		exit_because_failure
	    fi

	    mbfl_message_verbose_printf 'binding home directory of unsafe user: %s\n' "$UNSAFE_USERNAME"

	    local UNSAFE_HOME="$UNSAFE_HOME_PARENT/$UNSAFE_USERNAME"
	    local UNSAFE_MOUNT_POINT="$UNSAFE_MOUNT_POINT_PARENT/$UNSAFE_USERNAME"
	    if ! mbfl_file_is_directory "$UNSAFE_MOUNT_POINT"
	    then
		mbfl_message_verbose_printf 'creating mount point for unsafe user home: %s\n' "$UNSAFE_MOUNT_POINT"
		if ! mbfl_program_exec "$INSTALL" -m 0700 -d "$UNSAFE_MOUNT_POINT"
		then
    		    mbfl_message_error 'creating mount point for unsafe user home directory'
    		    exit_failure
		fi
	    fi

	    if unsafe_home_is_mounted_p "$UNSAFE_HOME" "$UNSAFE_MOUNT_POINT"
	    then mbfl_message_verbose_printf 'unsafe user home directory already bound to: %s\n' "$UNSAFE_MOUNT_POINT"
	    else
		mbfl_program_declare_sudo_user root
		if ! mbfl_program_exec "$SCRIPT_ARGV0" sudo-bind "$SAFE_USERNAME" "$UNSAFE_USERNAME" $FLAGS
		then mbfl_message_error_printf 'binding unsafe user home to safe user directory, unsafe user: %s' "$UNSAFE_USERNAME"
		fi
	    fi
	done <"$UNSAFE_USERS_LIST_FILE"
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}
function script_action_SUDO_BIND () {
    INSTALL=$(mbfl_program_found /usr/bin/install)	|| exit_because_program_not_found
    MOUNT=$(mbfl_program_found   /bin/mount)		|| exit_because_program_not_found
    if mbfl_wrong_num_args 2 $ARGC
    then
	local SAFE_USERNAME=${ARGV[0]}
	local UNSAFE_USERNAME=${ARGV[1]}

	if ! mbfl_string_is_identifier "$SAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid safe username: %s' "$SAFE_USERNAME"
	    exit_because_failure
	fi
	if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid unsafe username: %s' "$UNSAFE_USERNAME"
	    exit_because_failure
	fi

	local UNSAFE_MOUNT_POINT_PARENT="/home/$SAFE_USERNAME/var/unsafe-users"
	local UNSAFE_USERS_LIST_FILE="/home/$SAFE_USERNAME/.mmux-unsafe-users"
	local UNSAFE_HOME="$UNSAFE_HOME_PARENT/$UNSAFE_USERNAME"
	local UNSAFE_MOUNT_POINT="$UNSAFE_MOUNT_POINT_PARENT/$UNSAFE_USERNAME"
	if ! unsafe_home_is_mounted_p "$UNSAFE_HOME" "$UNSAFE_MOUNT_POINT"
	then
	    if ! mbfl_program_exec "$MOUNT" --bind "$UNSAFE_HOME" "$UNSAFE_MOUNT_POINT"
	    then
		mbfl_message_error_printf 'binding unsafe user home directory to safe user directory'
		exit_because_failure
	    fi
	fi
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

#page
#### unbinding unsafe users home to safe user directory

function script_action_UNBIND () {
    local FLAGS
    if mbfl_wrong_num_args 0 $ARGC
    then
	local SAFE_USERNAME=$script_option_SAFE_USERNAME
	local UNSAFE_USERNAME

	if test -z "$SAFE_USERNAME"
	then SAFE_USERNAME=$USER
	fi
	if test -z "$SAFE_USERNAME"
	then
	    mbfl_message_error 'missing safe username option selection'
	    exit_because_failure
	fi
	if ! mbfl_string_is_identifier "$SAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid safe username: %s' "$SAFE_USERNAME"
	    exit_because_failure
	fi

	mbfl_message_verbose_printf 'unbinding home directories of unsafe users associated to: %s\n' "$SAFE_USERNAME"

	local UNSAFE_MOUNT_POINT_PARENT="/home/$SAFE_USERNAME/var/unsafe-users"
	local UNSAFE_USERS_LIST_FILE="/home/$SAFE_USERNAME/.mmux-unsafe-users"
	if ! mbfl_file_is_file "$UNSAFE_USERS_LIST_FILE"
	then
	    mbfl_message_error_printf 'missing list of unsafe users file: %s\n' "$UNSAFE_USERS_LIST_FILE"
	    exit_because_failure
	fi

	mbfl_option_verbose		&& FLAGS="$FLAGS --verbose"
    	mbfl_option_interactive		&& FLAGS="$FLAGS --interactive"
	mbfl_option_show_program	&& FLAGS="$FLAGS --show-program"
	mbfl_option_test		&& FLAGS="$FLAGS --test"

	while read UNSAFE_USERNAME
	do
	    if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
	    then
		mbfl_message_error_printf 'invalid unsafe username: %s' "$UNSAFE_USERNAME"
		exit_because_failure
	    fi

	    mbfl_message_verbose_printf 'unbinding home directory of unsafe user: %s\n' "$UNSAFE_USERNAME"

	    local UNSAFE_HOME="$UNSAFE_HOME_PARENT/$UNSAFE_USERNAME"
	    local UNSAFE_MOUNT_POINT="$UNSAFE_MOUNT_POINT_PARENT/$UNSAFE_USERNAME"
	    if unsafe_home_is_mounted_p "$UNSAFE_HOME" "$UNSAFE_MOUNT_POINT"
	    then
		mbfl_program_declare_sudo_user root
		if ! mbfl_program_exec "$SCRIPT_ARGV0" sudo-unbind "$SAFE_USERNAME" "$UNSAFE_USERNAME" $FLAGS
		then mbfl_message_error_printf 'unbinding unsafe user home to safe user directory, unsafe user: %s' "$UNSAFE_USERNAME"
		fi
	    else mbfl_message_verbose_printf 'unsafe user home directory already unbound from: %s\n' "$UNSAFE_MOUNT_POINT"
	    fi
	done <"$UNSAFE_USERS_LIST_FILE"
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}
function script_action_SUDO_UNBIND () {
    UMOUNT=$(mbfl_program_found /bin/umount)	|| exit_because_program_not_found
    if mbfl_wrong_num_args 2 $ARGC
    then
	local SAFE_USERNAME=${ARGV[0]}
	local UNSAFE_USERNAME=${ARGV[1]}

	if ! mbfl_string_is_identifier "$SAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid safe username: %s' "$SAFE_USERNAME"
	    exit_because_failure
	fi
	if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid unsafe username: %s' "$UNSAFE_USERNAME"
	    exit_because_failure
	fi

	local UNSAFE_MOUNT_POINT_PARENT="/home/$SAFE_USERNAME/var/unsafe-users"
	local UNSAFE_USERS_LIST_FILE="/home/$SAFE_USERNAME/.mmux-unsafe-users"
	local UNSAFE_HOME="$UNSAFE_HOME_PARENT/$UNSAFE_USERNAME"
	local UNSAFE_MOUNT_POINT="$UNSAFE_MOUNT_POINT_PARENT/$UNSAFE_USERNAME"
	if unsafe_home_is_mounted_p "$UNSAFE_HOME" "$UNSAFE_MOUNT_POINT"
	then
	    if ! mbfl_program_exec "$UMOUNT" "$UNSAFE_MOUNT_POINT"
	    then
		mbfl_message_error_printf 'unbinding unsafe user home directory to safe user directory'
		exit_because_failure
	    fi
	fi
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

#page
#### enabling/disabling access to X host

function script_action_ENABLE_X () {
    local XHOST UNSAFE_USERNAME
    XHOST=$(mbfl_program_found /usr/bin/xhost)	|| exit_because_program_not_found

    # Acquire safe username.
    local SAFE_USERNAME=$script_option_SAFE_USERNAME
    if test -z "$SAFE_USERNAME"
    then SAFE_USERNAME=$USER
    fi
    if test -z "$SAFE_USERNAME"
    then
	mbfl_message_error 'missing safe username option selection'
	exit_because_failure
    fi
    if ! mbfl_string_is_identifier "$SAFE_USERNAME"
    then
	mbfl_message_error_printf 'invalid safe username: %s' "$SAFE_USERNAME"
	exit_because_failure
    fi

    if mbfl_wrong_num_args 0 $ARGC
    then
	mbfl_message_verbose_printf 'enabling X host access control\n'
	if ! mbfl_program_exec "$XHOST" -
	then
	    mbfl_message_error 'enabling X host access control'
	    exit_because_failure
	fi

	local UNSAFE_USERS_LIST_FILE="/home/$SAFE_USERNAME/.mmux-unsafe-users"
	if ! mbfl_file_is_file "$UNSAFE_USERS_LIST_FILE"
	then
	    mbfl_message_error_printf 'missing list of unsafe users file: %s\n' "$UNSAFE_USERS_LIST_FILE"
	    exit_because_failure
	fi

	while read UNSAFE_USERNAME
	do
	    if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
	    then
		mbfl_message_error_printf 'invalid unsafe username: %s' "$UNSAFE_USERNAME"
		exit_because_failure
	    fi

	    mbfl_message_verbose_printf 'enabling unsafe user running X applications: %s\n' "$UNSAFE_USERNAME"

	    if ! mbfl_program_exec "$XHOST" "+local:$UNSAFE_USERNAME"
	    then
		mbfl_message_error 'enabling unsafe user running X applications'
		exit_because_failure
	    fi
	done <"$UNSAFE_USERS_LIST_FILE"
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

function script_action_DISABLE_X () {
    local XHOST UNSAFE_USERNAME
    XHOST=$(mbfl_program_found /usr/bin/xhost)	|| exit_because_program_not_found
    local SAFE_USERNAME=$script_option_SAFE_USERNAME

    # Acquire safe username.
    if test -z "$SAFE_USERNAME"
    then SAFE_USERNAME=$USER
    fi
    if test -z "$SAFE_USERNAME"
    then
	mbfl_message_error 'missing safe username option selection'
	exit_because_failure
    fi
    if ! mbfl_string_is_identifier "$SAFE_USERNAME"
    then
	mbfl_message_error_printf 'invalid safe username: %s' "$SAFE_USERNAME"
	exit_because_failure
    fi

    if mbfl_wrong_num_args 0 $ARGC
    then
	local UNSAFE_USERS_LIST_FILE="/home/$SAFE_USERNAME/.mmux-unsafe-users"
	if ! mbfl_file_is_file "$UNSAFE_USERS_LIST_FILE"
	then
	    mbfl_message_error_printf 'missing list of unsafe users file: %s\n' "$UNSAFE_USERS_LIST_FILE"
	    exit_because_failure
	fi

	while read UNSAFE_USERNAME
	do
	    if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
	    then
		mbfl_message_error_printf 'invalid unsafe username: %s' "$UNSAFE_USERNAME"
		exit_because_failure
	    fi

	    mbfl_message_verbose_printf 'enabling unsafe user running X applications: %s\n' "$UNSAFE_USERNAME"

	    if ! mbfl_program_exec "$XHOST" "-local:$UNSAFE_USERNAME"
	    then
		mbfl_message_error 'enabling unsafe user running X applications'
		exit_because_failure
	    fi
	done <"$UNSAFE_USERS_LIST_FILE"
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

#page
#### helpers

unsafe_home_is_mounted_p () {
    mbfl_mandatory_parameter(UNSAFE_HOME, 1, unsafe home pathname)
    mbfl_mandatory_parameter(UNSAFE_MOUNT_POINT, 2, unsafe mount point)
    MOUNT=$(mbfl_program_found /bin/mount)	|| exit_because_program_not_found
    GREP=$(mbfl_program_found  /bin/grep)	|| exit_because_program_not_found
    mbfl_program_exec "$MOUNT" | mbfl_program_exec "$GREP" --silent "$UNSAFE_HOME on $UNSAFE_MOUNT_POINT"
}

#page
#### let's go

function main () {
    mbfl_main_print_usage_screen_brief
}
function script_action_HELP () {
    mbfl_actions_fake_action_set MAIN
    mbfl_main_print_usage_screen_brief
}
mbfl_main

### end of file
# Local Variables:
# mode: sh-mode
# End:
