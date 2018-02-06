#!/bin/bash
#
# Part of Someguy123's Steem Bash Tools
# Released under GNU GPL 3.0
# https://github.com/Someguy123/steem-bash

#
# Functions related to basic
# CLI_WALLET commands
#
CLI_STARTED=0
# Name of the docker image to use
CONTNAME="steem"
# What to name the temporary CLI container
CLICONTAINER_NAME="cli_gen"
CLIPORT=5000
#CLIWS="wss://node.steem.ws"
CLIWS="wss://steemd.privex.io"
# increments each time
CLI_CALL_ID=1
# Network used for cli_wallet, to allow connection
# to other containers, e.g. RPC node, witness etc.
DKR_NETWORK="witness_nw"

function create_network() {
    # check if the network exists
    # if not, just create it
    IS_WITNESS_NET=$(sudo docker network ls -q -f name=$DKR_NETWORK | wc -l)
    if [[ ! IS_WITNESS_NET -eq 1 ]]; then
        sudo docker network create -d bridge --subnet 172.22.0.0/16 $DKR_NETWORK
    fi
}
#
# Starts CONTNAME cli_wallet, and makes it available on
# port CLIPORT
#
function cli_start() {
    if [[ $CLI_STARTED -eq 1 ]]; then
        return
    fi
    create_network
    # to be safe, kill first
    cli_stop
    sudo docker run -d --network=$DKR_NETWORK -p $CLIPORT:$CLIPORT --name="$CLICONTAINER_NAME" "$CONTNAME" cli_wallet \
        --rpc-http-endpoint="0.0.0.0:$CLIPORT" \
        -s "$CLIWS" --rpc-http-allowip="127.0.0.1" \
        --rpc-http-allowip="172.17.0.1" -d &>/dev/null
    # sleep to make sure it's fully started
    sleep 4
    wallet_running
    if [[ $? == 0 ]]; then
    	CLI_STARTED=1
        return 0
    else
        echo "ERROR: Container died! Check your settings."
        return 1
    fi
}

container_is_running() {
    contcount=$(sudo docker ps -f 'status=running' -f name=$1 | wc -l)
    if [[ $contcount -eq 2 ]]; then
	return 0
    else
	return -1
    fi
}

wallet_running() {
    container_is_running $CLICONTAINER_NAME
    return $?
}

#
# Generates a public and private key using
# the suggest_brain_key function
#
function gen_key() {
    KEYDATA=$(cli_exec "suggest_brain_key" '')
    #PRIVKEY=$(echo "$KEYDATA" | sed -r 's/.*wif_priv_key\"\:\"([a-zA-Z0-9]+)\".*/\1/')
    PRIVKEY=$(echo "$KEYDATA" | extract_json_str wif_priv_key)
    #PUBKEY=$(echo "$KEYDATA" | sed -r 's/.*pub_key\"\:\"([a-zA-Z0-9]+)\".*/\1/')
    PUBKEY=$(echo "$KEYDATA" | extract_json_str pub_key)
    echo "Private: $PRIVKEY"
    echo "Public: $PUBKEY"
}

#
# Executes a command on CLI Wallet and sends JSON response to STDOUT
# Make sure you quote the second parameter properly, as it
# will be passed to the body of the parameter array
# Examples:
# cli_exec 'get_witness' '"someguy123"'
# cli_exec 'suggest_brain_key'
#
function cli_exec() {
    echo $(sudo docker exec $CLICONTAINER_NAME curl -s \
        --data-binary '{"id":"'"$CLI_CALL_ID"'","method":"'"$1"'","params":['"$2"']}' \
        http://127.0.0.1:5000)
    CLI_CALL_ID=$((CLI_CALL_ID+1))
}

function cli_stop() {
    sudo docker stop -t 2 $CLICONTAINER_NAME &>/dev/null
    sudo docker rm -f $CLICONTAINER_NAME &>/dev/null
    CLI_STARTED=0
    STEEM_CONNECTED=0
}
