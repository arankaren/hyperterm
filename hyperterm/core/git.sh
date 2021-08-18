#!/bin/bash

# Set up symbols
function _symbols() {

    # Import colors
    _colors_bash "$@"

    _synced_symbol="$(printf '%b\u2714' "${BOLD}${CYAN}")" # ✔
    _d_synced_symbol="$(printf '%b|%b\u002A' "${BOLD}${LEMON}" "${BOLD}${RED}")" # ∗
    _unpushed_symbol="$(printf '%b\u2191' "${BOLD}${CYAN}")" # ↑
    _dirty_unpushed_symbol="$(printf '%b\u25B2' "${BOLD}${YELLOW}")" # ▲
    _unpulled_symbol="$(printf '%b\u25BD' "${BOLD}${GREEN}")" # ▽
    _dirty_unpulled_symbol="$(printf '%b\u25BC' "${BOLD}${RED}")" # ▼
    _stage_symbol="$(printf '%b\u2192\u004D' "${BOLD}${CYAN}")" # →M
    _unstage_symbol="$(printf '%b\u2190\u004D' "${BOLD}${RED}")" # ←M
    _stage_unstage_symbol="$(printf '%b<M>' "${BOLD}${RED}")" # <M>
    _untracked_symbol="$(printf '%b\u003F' "${BOLD}${RED}")" # ?
    _newfile_symbol="$(printf '%b\u002B' "${BOLD}${CYAN}")" # +
    _deleted_file_symbol="$(printf '%bD' "${BOLD}${RED}")" # –
    _renamed_symbol="$(printf '%b\u2387 ' "${BOLD}${RED}")" # ⎇
    _unpushed_unpulled_symbol="$(printf '%b\u2B21' "${BOLD}${RED}")" # ⬡
    _d_unpush_unpull_symbol="$(printf '%b|%bdu' "${BOLD}${LEMON}" "${BOLD}${CYAN}")" # du
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
    git_count="$(_git_dirty_count)"
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

        000111111) printf '%s%s' "$_d_unpush_unpull_symbol" "$git_count" ;;
        100111111) printf '%s%s' "$_unpushed_unpulled_symbol" "$git_count" ;;
        001111111) printf '%s%s' "$_dirty_unpushed_symbol" "$git_count" ;;
        010111111) printf '%s%s' "$_dirty_unpulled_symbol" "$git_count" ;;
        110111111) printf '%s%s' "$_unpulled_symbol" "$git_count" ;;

        011001111) printf '%s%s' "${_d_synced_symbol}${_stage_unstage_symbol}" "$git_count";;
        011000111) printf '%s%s' "${_d_synced_symbol}${_stage_unstage_symbol}${_newfile_symbol}" "$git_count";;
        011001101) printf '%s%s' "${_d_synced_symbol}${_stage_unstage_symbol}${_deleted_file_symbol}" "$git_count";;
        011001011) printf '%s%s' "${_d_synced_symbol}${_stage_unstage_symbol}${_untracked_symbol}" "$git_count" ;;
        011001001) printf '%s%s' "${_d_synced_symbol}${_stage_unstage_symbol}${_untracked_symbol}${_deleted_file_symbol}" "$git_count";;
        011000101) printf '%s%s' "${_d_synced_symbol}${_stage_unstage_symbol}${_newfile_symbol}${_deleted_file_symbol}" "$git_count";;
        011000001) printf '%s%s' "${_d_synced_symbol}${_stage_unstage_symbol}${_newfile_symbol}${_untracked_symbol}${_deleted_file_symbol}" "$git_count";;
        011011111) printf '%s%s' "${_d_synced_symbol}${_stage_symbol}" "$git_count";;
        011010111) printf '%s%s' "${_d_synced_symbol}${_stage_symbol}${_newfile_symbol}" "$git_count";;
        011010101) printf '%s%s' "${_d_synced_symbol}${_stage_symbol}${_newfile_symbol}${_deleted_file_symbol}" "$git_count" ;;
        011010001) printf '%s%s' "${_d_synced_symbol}${_stage_symbol}${_newfile_symbol}${_untracked_symbol}${_deleted_file_symbol}" "$git_count";;
        011011011) printf '%s%s' "${_d_synced_symbol}${_stage_symbol}${_untracked_symbol}" "$git_count";;
        011011101) printf '%s%s' "${_d_synced_symbol}${_stage_symbol}${_deleted_file_symbol}" "$git_count";;
        011110111) printf '%s%s' "${_d_synced_symbol}${_newfile_symbol}" "$git_count";;
        011110011) printf '%s%s' "${_d_synced_symbol}${_newfile_symbol}${_untracked_symbol}" "$git_count";;
        011111011) printf '%s%s' "${_d_synced_symbol}${_untracked_symbol}" "$git_count";;
        011101001) printf '%s%s' "${_d_synced_symbol}${_unstage_symbol}${_untracked_symbol}${_deleted_file_symbol}" "$git_count";;
        011101001) printf '%s%s' "${_d_synced_symbol}${_unstage_symbol}${_deleted_file_symbol}" "$git_count";;
        011111110) printf '%s%s' "${_d_synced_symbol}${_renamed_symbol}" "$git_count";;
        011110110) printf '%s%s' "${_d_synced_symbol}${_newfile_symbol}${_renamed_symbol}" "$git_count";;
        011110010) printf '%s%s' "${_d_synced_symbol}${_newfile_symbol}${_untracked_symbol}${_renamed_symbol}" "$git_count";;
        011010100) printf '%s%s' "${_d_synced_symbol}${_stage_symbol}${_newfile_symbol}${_deleted_file_symbol}${_renamed_symbol}" "$git_count" ;;
        011010000) printf '%s%s' "${_d_synced_symbol}${_stage_symbol}${_newfile_symbol}${_untracked_symbol}${_deleted_file_symbol}${_renamed_symbol}" "$git_count";;
        011001010) printf '%s%s' "${_d_synced_symbol}${_stage_unstage_symbol}${_untracked_symbol}${_renamed_symbol}" "$git_count";;
        011001000) printf '%s%s' "${_d_synced_symbol}${_stage_unstage_symbol}${_untracked_symbol}${_deleted_file_symbol}${_renamed_symbol}" "$git_count";;
        011000110) printf '%s%s' "${_d_synced_symbol}${_stage_unstage_symbol}${_newfile_symbol}${_renamed_symbol}" "$git_count";;
        011000010) printf '%s%s' "${_d_synced_symbol}${_stage_unstage_symbol}${_newfile_symbol}${_untracked_symbol}${_renamed_symbol}" "$git_count";;
        011000000) printf '%s%s' "${_d_synced_symbol}${_stage_unstage_symbol}${_newfile_symbol}${_untracked_symbol}${_deleted_file_symbol}${_renamed_symbol}" "$git_count";;
        011000100) printf '%s%s' "${_d_synced_symbol}${_stage_unstage_symbol}${_newfile_symbol}${_deleted_file_symbol}${_renamed_symbol}" "$git_count";;
        011010010) printf '%s%s' "${_d_synced_symbol}${_stage_symbol}${_newfile_symbol}${_untracked_symbol}${_renamed_symbol}" "$git_count";;
        011011010) printf '%s%s' "${_d_synced_symbol}${_stage_symbol}${_untracked_symbol}${_renamed_symbol}" "$git_count";;
        011111010) printf '%s%s' "${_d_synced_symbol}${_untracked_symbol}${_renamed_symbol}" "$git_count";;

        001001111) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_unstage_symbol}" "$git_count";;
        001000111) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_unstage_symbol}${_newfile_symbol}" "$git_count";;
        001001101) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_unstage_symbol}${_deleted_file_symbol}" "$git_count";;
        001001011) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_unstage_symbol}${_untracked_symbol}" "$git_count";;
        001001001) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_unstage_symbol}${_untracked_symbol}${_deleted_file_symbol}" "$git_count";;
        001000101) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_unstage_symbol}${_newfile_symbol}${_deleted_file_symbol}" "$git_count";;
        001000001) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_unstage_symbol}${_newfile_symbol}${_untracked_symbol}${_deleted_file_symbol}" "$git_count";;
        001011111) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_symbol}" "$git_count";;
        001010111) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_symbol}${_newfile_symbol}" "$git_count" ;;
        001010101) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_symbol}${_newfile_symbol}${_deleted_file_symbol}" "$git_count" ;;
        001010001) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_symbol}${_newfile_symbol}${_untracked_symbol}${_deleted_file_symbol}" "$git_count";;
        001011011) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_symbol}${_untracked_symbol}" "$git_count";;
        001011101) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_symbol}${_deleted_file_symbol}" "$git_count";;
        001110111) printf '%s%s' "${_d_unpush_unpull_symbol}${_newfile_symbol}" "$git_count";;
        001110011) printf '%s%s' "${_d_unpush_unpull_symbol}${_newfile_symbol}${_untracked_symbol}" "$git_count";;
        001111011) printf '%s%s' "${_d_unpush_unpull_symbol}${_untracked_symbol}" "$git_count";;
        001101001) printf '%s%s' "${_d_unpush_unpull_symbol}${_unstage_symbol}${_untracked_symbol}${_deleted_file_symbol}" "$git_count";;
        001101101) printf '%s%s' "${_d_unpush_unpull_symbol}${_unstage_symbol}${_deleted_file_symbol}" "$git_count";;
        001111110) printf '%s%s' "${_d_unpush_unpull_symbol}${_renamed_symbol}" "$git_count";;
        001110110) printf '%s%s' "${_d_unpush_unpull_symbol}${_newfile_symbol}${_renamed_symbol}" "$git_count";;
        001110010) printf '%s%s' "${_d_unpush_unpull_symbol}${_newfile_symbol}${_untracked_symbol}${_renamed_symbol}" "$git_count";;
        001010100) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_symbol}${_newfile_symbol}${_deleted_file_symbol}${_renamed_symbol}" "$git_count" ;;
        001010000) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_symbol}${_newfile_symbol}${_untracked_symbol}${_deleted_file_symbol}${_renamed_symbol}" "$git_count";;
        001001010) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_unstage_symbol}${_untracked_symbol}${_renamed_symbol}" "$git_count";;
        001001000) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_unstage_symbol}${_untracked_symbol}${_deleted_file_symbol}${_renamed_symbol}" "$git_count";;
        001000110) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_unstage_symbol}${_newfile_symbol}${_renamed_symbol}" "$git_count";;
        001000010) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_unstage_symbol}${_newfile_symbol}${_untracked_symbol}${_renamed_symbol}" "$git_count";;
        001000000) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_unstage_symbol}${_newfile_symbol}${_untracked_symbol}${_deleted_file_symbol}${_renamed_symbol}" "$git_count";;
        001000100) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_unstage_symbol}${_newfile_symbol}${_deleted_file_symbol}${_renamed_symbol}" "$git_count";;
        001010010) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_symbol}${_newfile_symbol}${_untracked_symbol}${_renamed_symbol}" "$git_count";;
        001011010) printf '%s%s' "${_d_unpush_unpull_symbol}${_stage_symbol}${_untracked_symbol}${_renamed_symbol}" "$git_count";;
        001111010) printf '%s%s' "${_d_unpush_unpull_symbol}${_untracked_symbol}${_renamed_symbol}" "$git_count";;

        101111111) printf '%s%s' "${_unpushed_symbol}" "$git_count" ;; # eg. ↑
        111111111) printf '%s' "${_synced_symbol}" ;; # eg. ✔

        *) echo -n "?" ;;
    esac

    #
    #             dirty + unpushed = du                       stage + unstage = <M>
    #              ∗               ↑              ⬡            →M             ←M                +                  ?                  D                 ⎇
    # echo "${dirty_branch}${branch_ahead}${branch_behind}${branch_stage}${branch_unstage}${branch_newfile}${branch_untracked}${branch_deleted_file}${branch_renamed}"
    #                 0            0              1              1                0               1                   1                 0                 1
}

_prompt_get_git_info() {
    # Import colors
    _colors_bash "$@"

    # Grab the branch
    branch="$(_get_git_branch)"

    # If there are any branches
    if [[ -n $branch ]]; then
        # Printf the branch
        output="$branch"

        # Add on the git status
        output="$output$(_prompt_get_git_status "$@")"

        # Printf our output
        printf '%b%s%b' "${BOLD}${LEMON}" "git:($output" "${BOLD}${LEMON})"
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
