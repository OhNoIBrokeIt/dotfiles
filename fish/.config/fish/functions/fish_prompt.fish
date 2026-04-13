function fish_prompt
    set -l last_status $status

    set -l c_user  (set_color --bold brblue)
    set -l c_dir   (set_color --bold green)
    set -l c_git   (set_color --bold magenta)
    set -l c_err   (set_color --bold red)
    set -l c_time  (set_color --dim white)
    set -l c_shell (set_color --bold cyan)
    set -l c_reset (set_color normal)

    printf '%s%s%s ' $c_git \uf1b0 $c_reset
    printf '%s%s%s' $c_user $USER $c_reset
    printf ' %s\uf07b %s%s' $c_dir (prompt_pwd --full-length-dirs 1) $c_reset

    set -l git_branch (git branch --show-current 2>/dev/null)
    if test -n "$git_branch"
        set -l git_dirty ''
        if not git diff --quiet 2>/dev/null; or not git diff --cached --quiet 2>/dev/null
            set git_dirty (printf ' %s✘%s' $c_err $c_reset)
        end
        set -l untracked (git ls-files --others --exclude-standard 2>/dev/null | wc -l)
        if test $untracked -gt 0
            set git_dirty "$git_dirty"(printf ' %s?%s' $c_err $c_reset)
        end
        printf ' %s\ue725 %s%s%s' $c_git $git_branch $c_reset $git_dirty
    end

    printf ' %s%s%s' $c_time (date +%H:%M) $c_reset
    printf ' %s[fish]%s' $c_shell $c_reset

    if test $last_status -ne 0
        printf ' %s❯%s ' (set_color --bold red) $c_reset
    else
        printf ' %s❯%s ' (set_color --bold brblue) $c_reset
    end
end
