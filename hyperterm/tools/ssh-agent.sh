#!/bin/bash

#------------
# SSH-AGENT
#------------
function sshagent_start {

    # clean previous ssh credentials
    (rm -rf /tmp/ssh-* > /dev/null)

    SSH_ENV="$HOME/.ssh/environment"
    printf '\e[1;36m%s\e[m\n' "Initialising new SSH agent..."
    ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    chmod 600 "${SSH_ENV}"
    # shellcheck source=/dev/null
    source "${SSH_ENV}" > /dev/null
    ssh-add -t 5d
    printf '\e[1;36m%s\e[m\n' "succeeded"
}

function sshagent_stop {

    # clean previous ssh credentials
    (rm -rf /tmp/ssh-* > /dev/null)

    ssh-agent -k > /dev/null
}

function sshagent_findsockets {
    find /tmp -uid "$(id -u)" -type s -name agent.\* 2>/dev/null
}

function sshagent_testsocket {
    if [ ! -x "$(command -v ssh-add)" ] ; then
        echo "ssh-add is not available; agent testing aborted"
        return 1
    fi

    if [ X"$1" != X ] ; then
        export SSH_AUTH_SOCK=$1
    fi

    if [ X"$SSH_AUTH_SOCK" = X ] ; then
        return 2
    fi

    if [ -S "$SSH_AUTH_SOCK" ] ; then
        ssh-add -l > /dev/null
        if [ $? = 2 ] ; then
            echo "Socket $SSH_AUTH_SOCK is dead!  Deleting!"
            rm -f "$SSH_AUTH_SOCK"
            return 4
        else
            echo "Found ssh-agent $SSH_AUTH_SOCK"
            return 0
        fi
    else
        echo "$SSH_AUTH_SOCK is not a socket!"
        return 3
    fi
}

function sshagent_reload {
    # ssh agent sockets can be attached to a ssh daemon process or an
    # ssh-agent process.

    AGENTFOUND=0

    # Attempt to find and use the ssh-agent in the current environment
    if sshagent_testsocket ; then AGENTFOUND=1 ; fi

    # If there is no agent in the environment, search /tmp for
    # possible agents to reuse before starting a fresh ssh-agent
    # process.
    if [ $AGENTFOUND = 0 ] ; then
        for agentsocket in $(sshagent_findsockets) ; do
            if [ $AGENTFOUND != 0 ] ; then break ; fi
            if sshagent_testsocket "$agentsocket" ; then AGENTFOUND=1 ; fi
        done
    fi

    # If at this point we still haven't located an agent, it's time to
    # start a new one
    if [ $AGENTFOUND = 0 ] ; then
        eval "$(ssh-agent)"
    fi

    # Clean up
    unset AGENTFOUND
    unset agentsocket

    # Finally, show what keys are currently in the agent
    ssh-add -l
}

if [[ -f "$HOME/.ssh/environment" ]]; then
    sshagent_reload > /dev/null
fi

# Alias agents
alias sagent_start="sshagent_start"
alias sagent_stop="sshagent_stop"

# Clean up not global functions
unset -f sshagent_findsockets sshagent_testsocket
