#!/bin/bash

# Set up symbols
function _symbols() {

    # Import colors
    _colors_bash "$@"

    _synced_symbol="$(printf '%b\u2714' "${BOLD}${CYAN}")" # ✔
    _dirty_synced_symbol="$(printf '%b\u002A' "${BOLD}${RED}")" # ∗
    _unpushed_symbol="$(printf '%b\u2191' "${BOLD}${CYAN}")" # ↑
    _dirty_unpushed_symbol="$(printf '%b\u25B2' "${BOLD}${YELLOW}")" # ▲
    _unpulled_symbol="$(printf '%b\u25BD' "${BOLD}${GREEN}")" # ▽
    _dirty_unpulled_symbol="$(printf '%b\u25BC' "${BOLD}${RED}")" # ▼
    _stage_symbol="$(printf '%b\u2192\u004D' "${BOLD}${CYAN}")" # →M
    _unstage_symbol="$(printf '%b\u2190\u004D' "${BOLD}${RED}")" # ←M
    _untracked_symbol="$(printf '%b\u003F' "${BOLD}${RED}")" # ?
    _newfile_symbol="$(printf '%b\u002B' "${BOLD}${CYAN}")" # +
    _deleted_file_symbol="$(printf '%b\u2013' "${BOLD}${RED}")" # –
    _renamed_symbol="$(printf '%b\u2387 ' "${BOLD}${RED}")" # ⎇
    _unpushed_unpulled_symbol="$(printf '%b\u2B21' "${BOLD}${RED}")" # ⬡
    _dirty_unpushed_unpulled_symbol="$(printf '%b\u2B22' "${BOLD}${RED}")" # ⬢
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
    if (_prompt_is_branch1_behind_branch2 "$remote_branch" "$branch" ||
	    ! _prompt_branch_exists "$remote_branch"); then
        # printf our character
        printf '%s' '0'
    fi
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
    if _prompt_is_branch1_behind_branch2 "$branch" "$remote_branch"; then
        # printf our character
        printf '%s' '0'
    fi
}

function _prompt_parse_git_dirty() {
    # If the git status has *any* changes (e.g. dirty), printf our character
    if [[ -n "$(git status --porcelain 2> /dev/null)" ]]; then
        printf '%s' '0'
    fi
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
        if [[ "$change_count" == 1 ]]; then
            printf '%b\u2022%s' "${BOLD}${GREY}" "$change_count"
        elif [[ "$change_count" == 2 ]]; then
            printf '%b\u2236%s' "${BOLD}${GREY}" "$change_count"
        elif [[ "$change_count" == 3 ]]; then
            printf '%b\u2026%s' "${BOLD}${GREY}" "$change_count"
        else
            printf '%b\u00BB%s' "${BOLD}${GREY}" "$change_count"
        fi
    else
        printf ''
    fi
}
# ends counter on git

function _prompt_parse_git_untracked() {
    local untracked
    local evaltask
    untracked="$(git status 2>&1 | tee)"
    grep -E 'Untracked files:' <<<"$untracked" &> /dev/null
    evaltask=$?
    if [ "$evaltask" -eq 0 ]; then
        printf '%s' '0'
    else
        printf '%s' '1'
    fi
}

function _prompt_parse_git_newfile() {
    local newfile
    local evaltask
    newfile="$(git status 2>&1 | tee)"
    grep -E 'new file:' <<<"$newfile" &> /dev/null
    evaltask=$?
    if [ "$evaltask" -eq 0 ]; then
        printf '%s' '0'
    else
        printf '%s' '1'
    fi
}

function _prompt_parse_git_deleted_file() {
    local deleted_file
    local evaltask
    deleted_file="$(git status 2>&1 | tee)"
    grep -E 'deleted:' <<<"$deleted_file" &> /dev/null
    evaltask=$?
    if [ "$evaltask" -eq 0 ]; then
        printf '%s' '0'
    else
        printf '%s' '1'
    fi
}

function _prompt_parse_git_renamed() {
    local renamed
    local evaltask
    renamed="$(git status 2>&1 | tee)"
    grep -E 'renamed:' <<<"$renamed" &> /dev/null
    evaltask=$?
    if [ "$evaltask" -eq 0 ]; then
        printf '%s' '0'
    else
        printf '%s' '1'
    fi
}

function _prompt_parse_git_unstage() {
    local unstage
    local evaltask
    unstage="$(git status 2>&1 | tee)"
    grep -E 'not staged' <<<"$unstage" &> /dev/null
    evaltask=$?
    if [ "$evaltask" -eq 0 ]; then
        printf '%s' '0'
    else
        printf '%s' '1'
    fi
}

function _prompt_parse_git_stage() {
    local stage
    local evaltask
    stage="$(git status -s 2>&1 | tee)"
    grep -E 'M' <<<"$stage" &> /dev/null
    evaltask=$?
    if [ "$evaltask" -eq 0 ]; then
        printf '%s' '0'
    else
        printf '%s' '1'
    fi
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
    if [[ "$dirty_branch" == 0 && "$branch_ahead" == 0 && "$branch_behind" == 0 ]]; then
        printf '%s%s' "$_dirty_unpushed_unpulled_symbol" "$git_count"

    elif [[ "$branch_ahead" == 0 && "$branch_behind" == 0 ]]; then
        printf '%s%s' "$_unpushed_unpulled_symbol" "$git_count"

    elif [[ "$dirty_branch" == 0 && "$branch_ahead" == 0 ]]; then
        printf '%s%s' "$_dirty_unpushed_symbol" "$git_count"

    elif [[ "$branch_ahead" == 0 ]]; then
        printf '%s%s' "$_unpushed_symbol" "$git_count"

    elif [[ "$dirty_branch" == 0 && "$branch_behind" == 0 ]]; then
        printf '%s%s' "$_dirty_unpulled_symbol" "$git_count"

    elif [[ "$branch_behind" == 0 ]]; then
        printf '%s%s' "$_unpulled_symbol" "$git_count"

    elif [[ "$branch_unstage" == 0 && "$branch_untracked" == 0 ]]; then
        printf '%s%s' "${_unstage_symbol}${_untracked_symbol}" "$git_count"

    elif [[ "$branch_stage" == 0 && "$branch_untracked" == 0 ]]; then
        printf '%s%s' "${_stage_symbol}${_untracked_symbol}" "$git_count"

    elif [[ "$branch_stage" == 0 && "$branch_unstage" == 0 ]]; then
        printf '%s%s' "$_unstage_symbol" "$git_count"

    elif [[ "$branch_newfile" == 0 && "$branch_untracked" == 0 ]]; then
        printf '%s%s' "${_newfile_symbol}${_untracked_symbol}" "$git_count"

    elif [[ "$branch_untracked" == 0 ]]; then
        printf '%s%s' "$_untracked_symbol" "$git_count"

    elif [[ "$branch_stage" == 0 ]]; then
        printf '%s%s' "$_stage_symbol" "$git_count"

    elif [[ "$branch_newfile" == 0 ]]; then
        printf '%s%s' "$_newfile_symbol" "$git_count"

    elif [[ "$branch_deleted_file" == 0 ]]; then
        printf '%s%s' "$_deleted_file_symbol" "$git_count"

    elif [[ "$branch_renamed" == 0 ]]; then
        printf '%s%s' "$_renamed_symbol" "$git_count"

    elif [[ "$dirty_branch" == 0 ]]; then
        printf '%s%s' "$_dirty_synced_symbol" "$git_count"

    else # clean
        printf '%s' "$_synced_symbol"
    fi
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
