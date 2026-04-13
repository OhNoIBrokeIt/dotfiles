#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '


# ── Custom prompt ─────────────────────────────────────────
__git_info() {
    local branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        local dirty=""
        git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null || dirty=" \[\e[1;31m\]✘\[\e[0m\]"
        [ $(git ls-files --others --exclude-standard 2>/dev/null | wc -l) -gt 0 ] && dirty="$dirty \[\e[1;31m\]?\[\e[0m\]"
        echo -e " \[\e[1;35m\]$(printf '\ue725') $branch\[\e[0m\]$dirty"
    fi
}
PS1='\[\e[1;35m\]'"$(printf '\uf1b0')"'\[\e[0m\] \[\e[1;34m\]\u\[\e[0m\] \[\e[1;32m\]'"$(printf '\uf07b')"' \W\[\e[0m\]$(__git_info) \[\e[2;37m\]$(date +%H:%M)\[\e[0m\] \[\e[1;33m\][bash]\[\e[0m\] \[\e[1;32m\]❯\[\e[0m\] '

# ── Custom prompt ─────────────────────────────────────────
__git_info() {
    local branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        local dirty=""
        git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null || dirty=" \[\e[1;31m\]✘\[\e[0m\]"
        [ $(git ls-files --others --exclude-standard 2>/dev/null | wc -l) -gt 0 ] && dirty="$dirty \[\e[1;31m\]?\[\e[0m\]"
        echo -e " \[\e[1;35m\]$(printf '\ue725') $branch\[\e[0m\]$dirty"
    fi
}
PS1='\[\e[1;35m\]'"$(printf '\uf1b0')"'\[\e[0m\] \[\e[1;34m\]\u\[\e[0m\] \[\e[1;32m\]'"$(printf '\uf07b')"' \W\[\e[0m\]$(__git_info) \[\e[2;37m\]$(date +%H:%M)\[\e[0m\] \[\e[1;33m\][bash]\[\e[0m\] \[\e[1;32m\]❯\[\e[0m\] '
export PATH=$PATH:~/.spicetify
. "$HOME/.cargo/env"
