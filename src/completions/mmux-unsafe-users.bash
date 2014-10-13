# unsafeusers.bash --
#
# Completions for the "mmux-unsafe-users" script.

complete -F p-mmux-unsafe-users /usr/sbin/mmux-unsafe-users
complete -F p-mmux-unsafe-users mmux-unsafe-users
function p-mmux-unsafe-users () {
    local word_to_be_completed=${COMP_WORDS[${COMP_CWORD}]}
    # COMP_CWORD is zero based.  Index 0 is the "mmux-unsafe-users" word.
    case "$COMP_CWORD" in
        1)
            local first_word_completions='add del bind unbind enable-x disable-x help'
            COMPREPLY=(`compgen -W "$first_word_completions" -- "$word_to_be_completed"`)
            ;;
    esac
}

### end of file
