# mmux-unsafe-users-manager.bash --
#
# Completions for the "mmux-unsafe-users-manager" script.

complete -F p-mmux-unsafe-users-manager /usr/sbin/mmux-unsafe-users-manager
complete -F p-mmux-unsafe-users-manager mmux-unsafe-users-manager
function p-mmux-unsafe-users-manager () {
    local word_to_be_completed=${COMP_WORDS[${COMP_CWORD}]}
    # COMP_CWORD is zero based.  Index 0 is the "mmux-unsafe-users-manager" word.
    case "$COMP_CWORD" in
        1)
            local first_word_completions='add del bind unbind enable-x disable-x help'
            COMPREPLY=(`compgen -W "$first_word_completions" -- "$word_to_be_completed"`)
            ;;
    esac
}

### end of file
