#
# Part of: MMUX Unsafe Users Management
# Contents: unsafe users management script
# Date: Oct 11, 2014
#
# Abstract
#
#
#
# Copyright (C) 2014, 2018, 2020 Marco Maggi <mrc.mgg@gmail.com>
#
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU
# General Public  License as  published by  the Free Software  Foundation, either  version 3  of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that  it will be useful, but WITHOUT ANY WARRANTY; without
# even the  implied warranty of MERCHANTABILITY  or FITNESS FOR  A PARTICULAR PURPOSE.  See  the GNU
# General Public License for more details.
#
# You should  have received a copy  of the GNU General  Public License along with  this program.  If
# not, see <http://www.gnu.org/licenses/>.
#

#page
#### global variables

declare -r script_PROGNAME=mmux-unsafe-users
declare -r script_VERSION=0.3.1
declare -r script_COPYRIGHT_YEARS='2014, 2018'
declare -r script_AUTHOR='Marco Maggi'
declare -r script_LICENSE=GPL
declare script_USAGE="usage: ${script_PROGNAME} [action] [options]"
declare script_DESCRIPTION='Unsafe users management operations.'
declare script_EXAMPLES=

declare -r script_REQUIRED_MBFL_VERSION=v3.0.0-devel.4
declare -r COMPLETIONS_SCRIPT_NAMESPACE='p-mmux-unsafe-users-manager'

### ------------------------------------------------------------------------

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

mbfl_library_loader

#page
#### program declarations

mbfl_dialog_enable_programs

mbfl_program_enable_sudo
mbfl_file_enable_remove

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

mbfl_declare_action_set HELP
mbfl_declare_action HELP	HELP_USAGE	NONE		usage		'Print the help screen and exit.'
mbfl_declare_action HELP	HELP_PRINT_COMPLETIONS_SCRIPT NONE print-completions-script 'Print the completions script for this program.'

## --------------------------------------------------------------------

mbfl_declare_action_set MAIN
mbfl_declare_action MAIN ADD		NONE add		'Add an unsafe user.'
mbfl_declare_action MAIN DEL		NONE del		'Delete an unsafe user.'
mbfl_declare_action MAIN ENABLE_X	NONE enable-x		'Enable unsafe users running X applications in safe user X server.'
mbfl_declare_action MAIN DISABLE_X	NONE disable-x		'Disable unsafe users running X applications in safe user X server.'
mbfl_declare_action MAIN SUDO_ADD	NONE sudo-add		'Internal action.'
mbfl_declare_action MAIN SUDO_DEL	NONE sudo-del		'Internal action.'
mbfl_declare_action MAIN HELP		HELP help		'Help the user of this script.'

#page
#### adding unsafe users

function script_before_parsing_options_ADD () {
    script_USAGE="usage: ${script_PROGNAME} add UNSAFE-USERNAME --safe-user=SAFE-USERNAME [options]"
    script_DESCRIPTION='Add an unsafe user.'
    mbfl_declare_option SAFE_USERNAME '' S safe-user witharg 'Select the name of the safe user.'
}
function script_action_ADD () {
    if ! mbfl_wrong_num_args 1 $ARGC
    then
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi

    mbfl_command_line_argument(UNSAFE_USERNAME, 0)
    local SAFE_USERNAME=$script_option_SAFE_USERNAME
    mbfl_local_varref(SUBSCRIPT_FLAGS)

    if ! mbfl_string_is_identifier "$SAFE_USERNAME"
    then
	mbfl_message_error_printf 'invalid safe username: "%s"' "$SAFE_USERNAME"
	exit_because_failure
    fi
    if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
    then
	mbfl_message_error_printf 'invalid unsafe username: "%s"' "$UNSAFE_USERNAME"
	exit_because_failure
    fi

    mbfl_getopts_gather_mbfl_options_var mbfl_datavar(SUBSCRIPT_FLAGS)
    mbfl_program_declare_sudo_user root
    if mbfl_program_exec "$SCRIPT_ARGV0" sudo-add "$SAFE_USERNAME" "$UNSAFE_USERNAME" $SUBSCRIPT_FLAGS
    then exit_success
    else
    	mbfl_message_error 'adding user'
    	exit_because_failure
    fi
}

### ------------------------------------------------------------------------

function script_before_parsing_options_SUDO_ADD () {
    script_USAGE="usage: ${script_PROGNAME} sudo-add SAFE-USERNAME UNSAFE-USERNAME [options]"
    script_DESCRIPTION='Internal action.'
}
function script_action_SUDO_ADD () {
    if ! mbfl_wrong_num_args 2 $ARGC
    then
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi

    mbfl_local_varref(INSTALL)
    mbfl_local_varref(USERADD)
    mbfl_local_varref(USERMOD)
    mbfl_local_varref(CHMOD)
    local CHMOD_FLAGS
    mbfl_program_found_var mbfl_datavar(INSTALL)	/usr/bin/install  || exit $?
    mbfl_program_found_var mbfl_datavar(USERADD)	/usr/sbin/useradd || exit $?
    mbfl_program_found_var mbfl_datavar(USERMOD)	/usr/sbin/usermod || exit $?
    mbfl_program_found_var mbfl_datavar(CHMOD)		/bin/chmod        || exit $?

    mbfl_command_line_argument(SAFE_USERNAME,   0)
    mbfl_command_line_argument(UNSAFE_USERNAME, 1)
    local -r UNSAFE_HOME="${UNSAFE_HOME_PARENT}/${UNSAFE_USERNAME}"

    if ! mbfl_string_is_identifier "$SAFE_USERNAME"
    then
	mbfl_message_error_printf 'invalid safe username: "%s"' "$SAFE_USERNAME"
	exit_because_failure
    fi
    if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
    then
	mbfl_message_error_printf 'invalid unsafe username: "%s"' "$UNSAFE_USERNAME"
	exit_because_failure
    fi

    # Make sure the unsafe home directories parent exists.
    if ! mbfl_file_is_directory "$UNSAFE_HOME_PARENT"
    then
	mbfl_message_verbose_printf 'creating top directory for unsafe users home: %s\n' "$UNSAFE_HOME_PARENT"
	if mbfl_program_exec "$INSTALL" -m 0750 -o root -g mmux-unsafe-usrs -d "$UNSAFE_HOME_PARENT"
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
	 --home			"$UNSAFE_HOME"			\
	 --create-home						\
	 --user-group						\
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

    # Create a  "~/.plan" text file in  the unsafe user home  directory.  It is used  by the program
    # "finger"  to display  descriptive informations  about  the user  account; see  the manpage  of
    # "finger" for details.
    printf 'Unsafe user account associated to the user "%s".\n' \
	   "$SAFE_USERNAME" >"$UNSAFE_HOME"/.plan
}

#page
#### deleting unsafe users

function script_before_parsing_options_DEL () {
    script_USAGE="usage: ${script_PROGNAME} del UNSAFE-USERNAME --safe-user=SAFE-USERNAME [options]"
    script_DESCRIPTION='Remove an unsafe user.'
    mbfl_declare_option SAFE_USERNAME '' S safe-user witharg 'Select the name of the safe user.'
}
function script_action_DEL () {
    if ! mbfl_wrong_num_args 1 $ARGC
    then
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi

    mbfl_command_line_argument(UNSAFE_USERNAME, 0)
    local SAFE_USERNAME=$script_option_SAFE_USERNAME
    mbfl_local_varref(SUBSCRIPT_FLAGS)

    if ! mbfl_string_is_identifier "$SAFE_USERNAME"
    then
	mbfl_message_error_printf 'invalid safe username: "%s"' "$SAFE_USERNAME"
	exit_because_failure
    fi
    if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
    then
	mbfl_message_error_printf 'invalid unsafe username: "%s"' "$UNSAFE_USERNAME"
	exit_because_failure
    fi

    mbfl_getopts_gather_mbfl_options_var mbfl_datavar(SUBSCRIPT_FLAGS)
    mbfl_program_declare_sudo_user root
    if mbfl_program_exec "$SCRIPT_ARGV0" sudo-del "$SAFE_USERNAME" "$UNSAFE_USERNAME" $SUBSCRIPT_FLAGS
    then exit_success
    else
    	mbfl_message_error 'deleting user'
    	exit_because_failure
    fi
}

### ------------------------------------------------------------------------

function script_before_parsing_options_SUDO_DEL () {
    script_USAGE="usage: ${script_PROGNAME} sudo-del SAFE-USERNAME UNSAFE-USERNAME [options]"
    script_DESCRIPTION='Internal action.'
}
function script_action_SUDO_DEL () {
    if ! mbfl_wrong_num_args 2 $ARGC
    then
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi

    mbfl_local_varref(USERDEL)
    mbfl_local_varref(GROUPDEL)
    mbfl_program_found_var mbfl_datavar(USERDEL)	/usr/sbin/userdel  || exit $?
    mbfl_program_found_var mbfl_datavar(GROUPDEL)	/usr/sbin/groupdel || exit $?
    mbfl_command_line_argument(SAFE_USERNAME,   0)
    mbfl_command_line_argument(UNSAFE_USERNAME, 1)

    if ! mbfl_string_is_identifier "$SAFE_USERNAME"
    then
	mbfl_message_error_printf 'invalid safe username: "%s"' "$SAFE_USERNAME"
	exit_because_failure
    fi
    if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
    then
	mbfl_message_error_printf 'invalid unsafe username: "%s"' "$UNSAFE_USERNAME"
	exit_because_failure
    fi

    if mbfl_option_interactive
    then
	local MESSAGE
	printf -v MESSAGE 'delete the user "%s"' "$UNSAFE_USERNAME"
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

    # When "groupdel" removes the unsafe group: it also  removes it from the list of groups of which
    # the safe user is part.
    mbfl_message_verbose_printf 'deleting group: %s\n' "$UNSAFE_USERNAME"
    if ! mbfl_program_exec "$GROUPDEL" "$UNSAFE_USERNAME"
    then mbfl_message_error_printf 'removing unsafe group: %s' "$UNSAFE_USERNAME"
    fi
}

#page
#### enabling access to X host

function script_before_parsing_options_ENABLE_X () {
    script_USAGE="usage: ${script_PROGNAME} enable-x [options]"
    script_DESCRIPTION='Enable unsafe users running X applications in safe user X server.'
    mbfl_declare_option SAFE_USERNAME '' S safe-user witharg 'Select the name of the safe user.'
}
function script_action_ENABLE_X () {
    if ! mbfl_wrong_num_args 0 $ARGC
    then
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi

    mbfl_local_varref(XHOST)
    mbfl_program_found_var mbfl_datavar(XHOST)	/usr/bin/xhost || exit $?

    mbfl_message_verbose_printf 'acquire safe username\n'
    mbfl_local_varref(SAFE_USERNAME, "$script_option_SAFE_USERNAME")
    if mbfl_string_is_empty "$SAFE_USERNAME"
    then mbfl_system_whoami_var mbfl_datavar(SAFE_USERNAME)
    fi
    if mbfl_string_is_empty "$SAFE_USERNAME"
    then
	mbfl_message_error 'missing safe username option selection'
	exit_because_failure
    fi
    if ! mbfl_string_is_identifier "$SAFE_USERNAME"
    then
	mbfl_message_error_printf 'invalid safe username: "%s"' "$SAFE_USERNAME"
	exit_because_failure
    fi

    mbfl_message_verbose_printf 'enabling X host access control\n'
    if ! mbfl_program_exec "$XHOST" -
    then
	mbfl_message_error 'enabling X host access control'
	exit_because_failure
    fi

    eval local -r UNSAFE_USERS_LIST_FILE=~${SAFE_USERNAME}/.mmux-unsafe-users
    if ! mbfl_file_is_file "$UNSAFE_USERS_LIST_FILE"
    then
	mbfl_message_error_printf 'missing list of unsafe users file: %s\n' "$UNSAFE_USERS_LIST_FILE"
	exit_because_failure
    fi

    local UNSAFE_USERNAME
    while read UNSAFE_USERNAME
    do
	if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid unsafe username: "%s"' "$UNSAFE_USERNAME"
	    exit_because_failure
	fi

	mbfl_message_verbose_printf 'enabling unsafe user running X applications: %s\n' "$UNSAFE_USERNAME"

	if ! mbfl_program_exec "$XHOST" "+local:$UNSAFE_USERNAME"
	then
	    mbfl_message_error 'enabling unsafe user running X applications'
	    exit_because_failure
	fi
    done <"$UNSAFE_USERS_LIST_FILE"
}

#page
#### disabling access to X host

function script_before_parsing_options_DISABLE_X () {
    script_USAGE="usage: ${script_PROGNAME} disable-x [options]"
    script_DESCRIPTION='Disable unsafe users running X applications in safe user X server.'
    mbfl_declare_option SAFE_USERNAME '' S safe-user witharg 'Select the name of the safe user.'
}
function script_action_DISABLE_X () {
    if ! mbfl_wrong_num_args 0 $ARGC
    then
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi

    mbfl_local_varref(XHOST)
    mbfl_program_found_var mbfl_datavar(XHOST)	/usr/bin/xhost || exit $?

    mbfl_message_verbose_printf 'acquire safe username\n'
    mbfl_local_varref(SAFE_USERNAME, "$script_option_SAFE_USERNAME")
    if mbfl_string_is_empty "$SAFE_USERNAME"
    then mbfl_system_whoami_var mbfl_datavar(SAFE_USERNAME)
    fi
    if mbfl_string_is_empty "$SAFE_USERNAME"
    then
	mbfl_message_error 'missing safe username option selection'
	exit_because_failure
    fi
    if ! mbfl_string_is_identifier "$SAFE_USERNAME"
    then
	mbfl_message_error_printf 'invalid safe username: "%s"' "$SAFE_USERNAME"
	exit_because_failure
    fi

    eval local -r UNSAFE_USERS_LIST_FILE=~${SAFE_USERNAME}/.mmux-unsafe-users
    if ! mbfl_file_is_file "$UNSAFE_USERS_LIST_FILE"
    then
	mbfl_message_error_printf 'missing list of unsafe users file: %s\n' "$UNSAFE_USERS_LIST_FILE"
	exit_because_failure
    fi

    local UNSAFE_USERNAME
    while read UNSAFE_USERNAME
    do
	if ! mbfl_string_is_identifier "$UNSAFE_USERNAME"
	then
	    mbfl_message_error_printf 'invalid unsafe username: "%s"' "$UNSAFE_USERNAME"
	    exit_because_failure
	fi

	mbfl_message_verbose_printf 'enabling unsafe user running X applications: %s\n' "$UNSAFE_USERNAME"

	if ! mbfl_program_exec "$XHOST" "-local:$UNSAFE_USERNAME"
	then
	    mbfl_message_error 'enabling unsafe user running X applications'
	    exit_because_failure
	fi
    done <"$UNSAFE_USERS_LIST_FILE"
}

#page
#### help actions

function script_before_parsing_options_HELP () {
    script_USAGE="usage: ${script_PROGNAME} help [action] [options]"
    script_DESCRIPTION='Help the user of this program.'
}
function script_action_HELP () {
    # By faking the  selection of the MAIN action: we  cause "mbfl_main_print_usage_screen_brief" to
    # print the main usage screen.
    mbfl_actions_fake_action_set MAIN
    mbfl_main_print_usage_screen_brief
}

### ------------------------------------------------------------------------

function script_before_parsing_options_HELP_USAGE () {
    script_USAGE="usage: ${script_PROGNAME} help usage [options]"
    script_DESCRIPTION='Print the usage screen and exit.'
}
function script_action_HELP_USAGE () {
    if mbfl_wrong_num_args 0 $ARGC
    then
	# By faking the selection of  the MAIN action: we cause "mbfl_main_print_usage_screen_brief"
	# to print the main usage screen.
	mbfl_actions_fake_action_set MAIN
	mbfl_main_print_usage_screen_brief
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

## --------------------------------------------------------------------

function script_before_parsing_options_HELP_PRINT_COMPLETIONS_SCRIPT () {
    script_PRINT_COMPLETIONS="usage: ${script_PROGNAME} help print-completions-script [options]"
    script_DESCRIPTION='Print the command-line completions script and exit.'
}
function script_action_HELP_PRINT_COMPLETIONS_SCRIPT () {
    if mbfl_wrong_num_args 0 $ARGC
    then mbfl_actions_completion_print_script "$COMPLETIONS_SCRIPT_NAMESPACE" "$script_PROGNAME"
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

#page
#### let's go

function main () {
    mbfl_main_print_usage_screen_brief
}
mbfl_main

### end of file
# Local Variables:
# mode: sh
# End:
