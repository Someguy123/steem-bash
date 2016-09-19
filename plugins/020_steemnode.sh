#!/bin/bash
#
# Part of Someguy123's Steem Bash Tools
# Released under GNU GPL 3.0
# https://github.com/Someguy123/steem-bash


if [[ ! $(command -v cli_exec) ]]; then
    echo "ERROR: cliwallet.sh plugin not loaded"
    exit
fi

STEEM_CONTAINER=seed
STEEM_CONNECTED=0
#
# Required before any local node commands will function.
# Connects the node (e.g. witness) to an internal docker network,
# then starts the cli_wallet with a connection to the node
#
function connect_steem() {
    if [[ $STEEM_CONNECTED -eq 1 ]]; then
        return
    fi
    echo "Stopping any existing containers..."
    cli_stop &> /dev/null
    # create internal network if needed
    create_network
    # connect the witness/rpc node to the network
    docker network connect $DKR_NETWORK $STEEM_CONTAINER
    # override existing WS connection
    local CLIWS="ws://$STEEM_CONTAINER:8090"
    echo "Starting new connection to $CLIWS"
    # finally, start the connection
    cli_start
    STEEM_CONNECTED=1
}

function steem_status() {
    connect_steem
    _INFO=$(cli_exec 'info')
    _ABOUT=$(cli_exec 'about')
    LAST_BLOCK=$(echo $_INFO | extract_json_str head_block_age)
    HEAD_BLOCK=$(echo $_INFO | extract_json_int head_block_num)
    CLI_VERSION=$(echo $_ABOUT | extract_json_str client_version)
    echo "Last block was: $LAST_BLOCK"
    echo "Block number: $HEAD_BLOCK"
    echo "Client Version: $CLI_VERSION"
}
