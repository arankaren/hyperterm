#!/bin/bash

# Set up symbols
function _symbols() {

    # Import colors
    _colors_bash "$@"

    __ps="$(printf '%b%b%b' "${BOLD}${LEMON}" "\x7C" "${RESET}")" # |
    __ss="$(printf '%b%b' "${BOLD}${CYAN}" "\xE2\x9C\x94")" # ✔
    __dss="$(printf '%b%b' "${BOLD}${RED}" "\x2A")" # ∗
    __ahs="$(printf '%b%b' "${BOLD}${CYAN}" "\xE2\x86\x91")" # ↑
    __bhs="$(printf '%b%b' "${BOLD}${RED}" "\xE2\x86\x93")" # ↓
    __duphs="$(printf '%b%b' "${BOLD}${YELLOW}" "\xE2\x96\x82" )" # ▲
    __duplls="$(printf '%b%b' "${BOLD}${RED}" "\xE2\x96\xBC")" # ▼
    __duus="$(printf '%b%b%b' "${BOLD}${CYAN}" "\x64" "\x75")" # du
    __upulls="$(printf '%b%b' "${BOLD}${GREEN}" "\xE2\x96\xBD")" # ▽
    __sts="$(printf '%b%b%b' "${BOLD}${CYAN}" "\xE2\x86\x92" "\x4D")" # →M
    __usts="$(printf '%b%b%b' "${BOLD}${RED}" "\xE2\x86\x90" "\x4D")" # ←M
    __stusts="$(printf '%b%b%b%b' "${BOLD}${RED}" "\x3C" "\x4D" "\x3E")" # <M>
    __uts="$(printf '%b%b' "${BOLD}${RED}" "\x3F")" # ?
    __nfs="$(printf '%b%b' "${BOLD}${CYAN}" "\x2B")" # +
    __dfs="$(printf '%b%b' "${BOLD}${RED}" "\x44")" # D
    __rns="$(printf '%b%b%b' "${BOLD}${RED}" "\xE2\x8E\x87" "\x20")" # ⎇
}

function _get_git_branch() {
    # On branches, this will return the branch name
    # On non-branches, (no branch)
    ref="$(git symbolic-ref HEAD 2> /dev/null | sed -e 's/refs\/heads\///')"
    if [[ -n $ref ]]; then
        printf '%s' "$ref"
    else
        printf "(no branch)"
    fi
}

function _get_git_progress() {
    # Detect in-progress actions (e.g. merge, rebase)
    # https://github.com/git/git/blob/v1.9-rc2/wt-status.c#L1199-L1241
    git_dir="$(git rev-parse --git-dir)"

    # git merge
    if [[ -f "$git_dir/MERGE_HEAD" ]]; then
        printf " [merge]"
    elif [[ -d "$git_dir/rebase-apply" ]]; then
        # git am
        if [[ -f "$git_dir/rebase-apply/applying" ]]; then
            printf " [am]"
            # git rebase
        else
            printf " [rebase]"
        fi
    elif [[ -d "$git_dir/rebase-merge" ]]; then
        # git rebase --interactive/--merge
        printf " [rebase]"
    elif [[ -f "$git_dir/CHERRY_PICK_HEAD" ]]; then
        # git cherry-pick
        printf " [cherry-pick]"
    fi
    if [[ -f "$git_dir/BISECT_LOG" ]]; then
        # git bisect
        printf " [bisect]"
    fi
    if [[ -f "$git_dir/REVERT_HEAD" ]]; then
	# git revert --no-commit
        printf " [revert]"
    fi
}

_prompt_is_branch1_behind_branch2 () {
    # $ git log origin/master..master -1
    # commit 4a633f715caf26f6e9495198f89bba20f3402a32
    # Author: Todd Wolfson <todd@twolfson.com>
    # Date:   Sun Jul 7 22:12:17 2013 -0700
    #
    #     Unsynced commit

    # Find the first log (if any) that is in branch1 but not branch2
    first_log="$(git log "$1..$2" -1 2> /dev/null)"

    # Exit with 0 if there is a first log, 1 if there is not
    [[ -n "$first_log" ]]
}

_prompt_branch_exists () {
    # List remote branches | # Find our branch and exit with 0 or 1 if found/not found
    git branch --remote 2> /dev/null | grep --quiet "$1"
}

_prompt_parse_git_ahead () {
    # Grab the local and remote branch
    branch="$(_get_git_branch)"
    remote="$(git config --get "branch.${branch}.remote" || echo -n "origin")"
    remote_branch="$remote/$branch"

    # $ git log origin/master..master
    # commit 4a633f715caf26f6e9495198f89bba20f3402a32
    # Author: Todd Wolfson <todd@twolfson.com>
    # Date:   Sun Jul 7 22:12:17 2013 -0700
    #
    #     Unsynced commit

    # If the remote branch is behind the local branch
    # or it has not been merged into origin (remote branch doesn't exist)
    if (_prompt_is_branch1_behind_branch2 "$remote_branch" "$branch" || ! _prompt_branch_exists "$remote_branch"); then echo -n "0"; else  echo -n "1"; fi
}

_prompt_parse_git_behind() {
    # Grab the branch
    branch="$(_get_git_branch)"
    remote="$(git config --get "branch.${branch}.remote" || echo -n "origin")"
    remote_branch="$remote/$branch"

    # $ git log master..origin/master
    # commit 4a633f715caf26f6e9495198f89bba20f3402a32
    # Author: Todd Wolfson <todd@twolfson.com>
    # Date:   Sun Jul 7 22:12:17 2013 -0700
    #
    #   Unsynced commit

    # If the local branch is behind the remote branch
    if _prompt_is_branch1_behind_branch2 "$branch" "$remote_branch"; then echo -n '0'; else echo -n '1'; fi
}

function _prompt_parse_git_dirty() {
    # If the git status has *any* changes (e.g. dirty), printf our character
    if [[ -n "$(git status --porcelain 2> /dev/null)" ]]; then echo -n '0'; else echo -n '1'; fi
}

# start counter on git
function _git_dirty_count() {
    local _dirty_status
    local _git_status
    _dirty_status="$(_prompt_parse_git_dirty)"
    _git_status="$(git status --porcelain 2> /dev/null)"
    if [[ "$_dirty_status" == 0 ]]; then
        local change_count
        change_count="$(echo "$_git_status" | wc -l | tr -d '[:space:]')"
        case $change_count in
            1) printf '%b\u2022%s' "${BOLD}${GREY}" "$change_count";;
            2) printf '%b\u2236%s' "${BOLD}${GREY}" "$change_count";;
            3) printf '%b\u2026%s' "${BOLD}${GREY}" "$change_count";;
            *) printf '%b\u00BB%s' "${BOLD}${GREY}" "$change_count";;
        esac
    fi
}

function _git_upstream() {
    ___upstream="$(git rev-parse --symbolic-full-name --abbrev-ref "@{upstream}" 2> /dev/null)"
}

function _git_behind_count() {
    local __behind_count
    _git_upstream
    if [[ -n $___upstream ]]; then
        __behind_count="$(git rev-list --left-right --count "$___upstream"...HEAD | cut -f1 2> /dev/null)"
        case $__behind_count in
            0) echo -n '';;
            *) echo -n "$__behind_count";;
        esac
    fi
}

function _git_ahead_count() {
    local __ahead_count
    _git_upstream
    if [[ -n $___upstream ]]; then
        __ahead_count="$(git rev-list --left-right --count "$___upstream"...HEAD | cut -f2 2> /dev/null)"
        case $__ahead_count in
            0) echo -n '';;
            *) echo -n "$__ahead_count";;
        esac
    fi
}
# ends counter on git

function _prompt_parse_git_untracked() {
    local untracked
    local evaltask
    untracked="$(git status 2>&1 | tee)"
    grep -E 'Untracked files:' <<<"$untracked" &> /dev/null
    evaltask=$?
    if [ "$evaltask" -eq 0 ]; then echo -n '0'; else echo -n '1'; fi
}

function _prompt_parse_git_newfile() {
    local newfile
    local evaltask
    newfile="$(git status 2>&1 | tee)"
    grep -E 'new file:' <<<"$newfile" &> /dev/null
    evaltask=$?
    if [ "$evaltask" -eq 0 ]; then echo -n '0'; else echo -n '1'; fi
}

function _prompt_parse_git_deleted_file() {
    local deleted_file
    local evaltask
    deleted_file="$(git status 2>&1 | tee)"
    grep -E 'deleted:' <<<"$deleted_file" &> /dev/null
    evaltask=$?
    if [ "$evaltask" -eq 0 ]; then echo -n '0'; else echo -n '1'; fi
}

function _prompt_parse_git_renamed() {
    local renamed
    local evaltask
    renamed="$(git status 2>&1 | tee)"
    grep -E 'renamed:' <<<"$renamed" &> /dev/null
    evaltask=$?
    if [ "$evaltask" -eq 0 ]; then echo -n '0'; else echo -n '1'; fi
}

function _prompt_parse_git_unstage() {
    local unstage
    local evaltask
    unstage="$(git status 2>&1 | tee)"
    grep -E 'not staged' <<<"$unstage" &> /dev/null
    evaltask=$?
    if [ "$evaltask" -eq 0 ]; then echo -n '0'; else echo -n '1'; fi
}

function _prompt_parse_git_stage() {
    local stage
    local evaltask
    stage="$(git status -s 2>&1 | tee)"
    grep -E 'M' <<<"$stage" &> /dev/null
    evaltask=$?
    if [ "$evaltask" -eq 0 ]; then echo -n '0'; else echo -n '1'; fi
}

function _prompt_is_on_git() {
    git rev-parse 2> /dev/null
}

function _prompt_get_git_status() {

    _symbols "$@"

    # Grab the git dirty and git behind
    count_dirty="$(_git_dirty_count)"
    count_behind="$(_git_behind_count)"
    count_ahead="$(_git_ahead_count)"
    dirty_branch="$(_prompt_parse_git_dirty)"
    branch_ahead="$(_prompt_parse_git_ahead)"
    branch_behind="$(_prompt_parse_git_behind)"
    branch_stage="$(_prompt_parse_git_stage)"
    branch_unstage="$(_prompt_parse_git_unstage)"
    branch_untracked="$(_prompt_parse_git_untracked)"
    branch_newfile="$(_prompt_parse_git_newfile)"
    branch_deleted_file="$(_prompt_parse_git_deleted_file)"
    branch_renamed="$(_prompt_parse_git_renamed)"

    # Iterate through all the cases and if it matches, then printf
    case ${dirty_branch}${branch_ahead}${branch_behind}${branch_stage}${branch_unstage}${branch_newfile}${branch_untracked}${branch_deleted_file}${branch_renamed} in
        111111111) printf '%s' "${__ss}";;
        100111111) printf '%s' "${__ps}${__ahs}$count_ahead${__ps}${__bhs}$count_behind";;
        110111111) printf '%s%s' "${__upulls}" "$count_behind";;
        101111111) printf '%s%s' "${__ahs}" "$count_ahead";;
        111001111) printf '%s%s' "${__ps}${__duus}${__stusts}" "$count_dirty";;
        010111111) printf '%s%s%s' "${__duplls}" "$count_behind" "$count_dirty";;
        001111111) printf '%s%s%s' "${__duphs}" "$count_ahead" "$count_dirty";;
        000111111) printf '%s%s%s' "${__duus}" "$count_behind-$count_ahead" "$count_dirty";;

        000111011) printf '%s%s' "${__ps}${__ahs}$count_ahead${__ps}${__bhs}$count_behind${__ps}${__uts}${__ps}" "$count_dirty" ;;

        010111011) printf '%s%s' "${__ps}${__bhs}$count_behind${__ps}${__dss}${__uts}" "${__ps}$count_dirty";;
        010110111) printf '%s%s' "${__ps}${__bhs}$count_behind${__ps}${__dss}${__nfs}" "${__ps}$count_dirty";;
        010110011) printf '%s%s' "${__ps}${__bhs}$count_behind${__ps}${__dss}${__nfs}${__uts}" "${__ps}$count_dirty";;
        010100001) printf '%s%s' "${__ps}${__bhs}$count_behind${__ps}${__dss}${__nfs}${__usts}${__uts}${__dfs}" "${__ps}$count_dirty";;
        010000001) printf '%s%s' "${__ps}${__bhs}$count_behind${__ps}${__dss}${__nfs}${__stusts}${__uts}${__dfs}" "${__ps}$count_dirty";;
        010010100) printf '%s%s' "${__ps}${__bhs}$count_behind${__ps}${__dss}${__nfs}${__dfs}${__rns}" "${__ps}${__sts}${__ps}$count_dirty";;
        010010000) printf '%s%s' "${__ps}${__bhs}$count_behind${__ps}${__dss}${__nfs}${__dfs}${__rns}${__ps}${__uts}" "${__ps}${__sts}${__ps}$count_dirty";;

        011001111) printf '%s%s' "${__ps}${__dss}${__stusts}" "$count_dirty";;
        011000111) printf '%s%s' "${__ps}${__dss}${__stusts}${__nfs}" "$count_dirty";;
        011001101) printf '%s%s' "${__ps}${__dss}${__stusts}${__dfs}" "$count_dirty";;
        011001011) printf '%s%s' "${__ps}${__dss}${__stusts}${__uts}" "$count_dirty" ;;
        011001001) printf '%s%s' "${__ps}${__dss}${__stusts}${__uts}${__dfs}" "$count_dirty";;
        011000101) printf '%s%s' "${__ps}${__dss}${__stusts}${__nfs}${__dfs}" "$count_dirty";;
        011000001) printf '%s%s' "${__ps}${__dss}${__stusts}${__nfs}${__uts}${__dfs}" "$count_dirty";;
        011011111) printf '%s%s' "${__ps}${__dss}${__sts}" "$count_dirty";;
        011010111) printf '%s%s' "${__ps}${__dss}${__sts}${__nfs}" "$count_dirty";;
        011010101) printf '%s%s' "${__ps}${__dss}${__sts}${__nfs}${__dfs}" "$count_dirty" ;;
        011010001) printf '%s%s' "${__ps}${__dss}${__sts}${__nfs}${__uts}${__dfs}" "$count_dirty";;
        011011011) printf '%s%s' "${__ps}${__dss}${__sts}${__uts}" "$count_dirty";;
        011011101) printf '%s%s' "${__ps}${__dss}${__sts}${__dfs}" "$count_dirty";;
        011110111) printf '%s%s' "${__ps}${__dss}${__nfs}" "$count_dirty";;
        011110011) printf '%s%s' "${__ps}${__dss}${__nfs}${__uts}" "$count_dirty";;
        011111011) printf '%s%s' "${__ps}${__dss}${__uts}" "$count_dirty";;
        011101001) printf '%s%s' "${__ps}${__dss}${__usts}${__uts}${__dfs}" "$count_dirty";;
        011111110) printf '%s%s' "${__ps}${__dss}${__rns}" "$count_dirty";;
        011110110) printf '%s%s' "${__ps}${__dss}${__nfs}${__rns}" "$count_dirty";;
        011110010) printf '%s%s' "${__ps}${__dss}${__nfs}${__uts}${__rns}" "$count_dirty";;
        011011110) printf '%s%s' "${__ps}${__dss}${__sts}${__rns}" "$count_dirty";;
        011010100) printf '%s%s' "${__ps}${__dss}${__sts}${__nfs}${__dfs}${__rns}" "$count_dirty" ;;
        011010000) printf '%s%s' "${__ps}${__dss}${__sts}${__nfs}${__uts}${__dfs}${__rns}" "$count_dirty";;
        011001010) printf '%s%s' "${__ps}${__dss}${__stusts}${__uts}${__rns}" "$count_dirty";;
        011001000) printf '%s%s' "${__ps}${__dss}${__stusts}${__uts}${__dfs}${__rns}" "$count_dirty";;
        011000011) printf '%s%s' "${__ps}${__dss}${__stusts}${__nfs}${__uts}" "$count_dirty";;
        011000110) printf '%s%s' "${__ps}${__dss}${__stusts}${__nfs}${__rns}" "$count_dirty";;
        011000010) printf '%s%s' "${__ps}${__dss}${__stusts}${__nfs}${__uts}${__rns}" "$count_dirty";;
        011000000) printf '%s%s' "${__ps}${__dss}${__stusts}${__nfs}${__uts}${__dfs}${__rns}" "$count_dirty";;
        011000100) printf '%s%s' "${__ps}${__dss}${__stusts}${__nfs}${__dfs}${__rns}" "$count_dirty";;
        011010010) printf '%s%s' "${__ps}${__dss}${__sts}${__nfs}${__uts}${__rns}" "$count_dirty";;
        011011010) printf '%s%s' "${__ps}${__dss}${__sts}${__uts}${__rns}" "$count_dirty";;
        011111010) printf '%s%s' "${__ps}${__dss}${__uts}${__rns}" "$count_dirty";;

        001001111) printf '%s%s' "${__ps}${__duus}${__stusts}" "$count_dirty";;
        001000111) printf '%s%s' "${__ps}${__duus}${__stusts}${__nfs}" "$count_dirty";;
        001001101) printf '%s%s' "${__ps}${__duus}${__stusts}${__dfs}" "$count_dirty";;
        001001011) printf '%s%s' "${__ps}${__duus}${__stusts}${__uts}" "$count_dirty";;
        001001001) printf '%s%s' "${__ps}${__duus}${__stusts}${__uts}${__dfs}" "$count_dirty";;
        001000101) printf '%s%s' "${__ps}${__duus}${__stusts}${__nfs}${__dfs}" "$count_dirty";;
        001000001) printf '%s%s' "${__ps}${__duus}${__stusts}${__nfs}${__uts}${__dfs}" "$count_dirty";;
        001011111) printf '%s%s' "${__ps}${__duus}${__sts}" "$count_dirty";;
        001010111) printf '%s%s' "${__ps}${__duus}${__sts}${__nfs}" "$count_dirty" ;;
        001010101) printf '%s%s' "${__ps}${__duus}${__sts}${__nfs}${__dfs}" "$count_dirty" ;;
        001010001) printf '%s%s' "${__ps}${__duus}${__sts}${__nfs}${__uts}${__dfs}" "$count_dirty";;
        001011011) printf '%s%s' "${__ps}${__duus}${__sts}${__uts}" "$count_dirty";;
        001011101) printf '%s%s' "${__ps}${__duus}${__sts}${__dfs}" "$count_dirty";;
        001110111) printf '%s%s' "${__ps}${__duus}${__nfs}" "$count_dirty";;
        001110011) printf '%s%s' "${__ps}${__duus}${__nfs}${__uts}" "$count_dirty";;
        001111011) printf '%s%s' "${__ps}${__duus}${__uts}" "$count_dirty";;
        001101001) printf '%s%s' "${__ps}${__duus}${__usts}${__uts}${__dfs}" "$count_dirty";;
        001101101) printf '%s%s' "${__ps}${__duus}${__usts}${__dfs}" "$count_dirty";;
        001111110) printf '%s%s' "${__ps}${__duus}${__rns}" "$count_dirty";;
        001110110) printf '%s%s' "${__ps}${__duus}${__nfs}${__rns}" "$count_dirty";;
        001110010) printf '%s%s' "${__ps}${__duus}${__nfs}${__uts}${__rns}" "$count_dirty";;
        001011110) printf '%s%s' "${__ps}${__duus}${__sts}${__rns}" "$count_dirty";;
        001010100) printf '%s%s' "${__ps}${__duus}${__sts}${__nfs}${__dfs}${__rns}" "$count_dirty" ;;
        001010000) printf '%s%s' "${__ps}${__duus}${__sts}${__nfs}${__uts}${__dfs}${__rns}" "$count_dirty";;
        001001010) printf '%s%s' "${__ps}${__duus}${__stusts}${__uts}${__rns}" "$count_dirty";;
        001001000) printf '%s%s' "${__ps}${__duus}${__stusts}${__uts}${__dfs}${__rns}" "$count_dirty";;
        001000011) printf '%s%s' "${__ps}${__duus}${__stusts}${__nfs}${__uts}" "$count_dirty";;
        001000110) printf '%s%s' "${__ps}${__duus}${__stusts}${__nfs}${__rns}" "$count_dirty";;
        001000010) printf '%s%s' "${__ps}${__duus}${__stusts}${__nfs}${__uts}${__rns}" "$count_dirty";;
        001000000) printf '%s%s' "${__ps}${__duus}${__stusts}${__nfs}${__uts}${__dfs}${__rns}" "$count_dirty";;
        001000100) printf '%s%s' "${__ps}${__duus}${__stusts}${__nfs}${__dfs}${__rns}" "$count_dirty";;
        001010010) printf '%s%s' "${__ps}${__duus}${__sts}${__nfs}${__uts}${__rns}" "$count_dirty";;
        001011010) printf '%s%s' "${__ps}${__duus}${__sts}${__uts}${__rns}" "$count_dirty";;
        001111010) printf '%s%s' "${__ps}${__duus}${__uts}${__rns}" "$count_dirty";;
        *) echo -n "${__uts}" ;;
    esac

    #
    #             dirty + unpushed = du                       stage + unstage = <M>
    #              ∗               ↑               ↓             →M             ←M                +                  ?                 D                  ⎇
    # echo "${dirty_branch}${branch_ahead}${branch_behind}${branch_stage}${branch_unstage}${branch_newfile}${branch_untracked}${branch_deleted_file}${branch_renamed}"
    #              0               1               0              1               1               1                  0                 1                   1
}

_prompt_get_git_info() {
    # Import colors
    _colors_bash "$@"

    # Grab branch
    branch=$(_get_git_branch)

    # If there are any branches
    if [[ -n $branch ]]; then
        # Add on the git status
        output=$(_prompt_get_git_status "$@")
        # Printf our output
        printf '%b%s%b' "${BOLD}${LEMON}" "git:($branch$output" "${BOLD}${LEMON})"
    fi
}

__prompt_git() {
    if _prompt_is_on_git &> /dev/null; then
        echo -n "${BOLD}${WHITE} on $RESET" && \
            echo -n "$(_prompt_get_git_info "$@")" && \
            echo -n "${BOLD}${RED}$(_get_git_progress)" && \
            echo -n "$RESET"
    fi
}
