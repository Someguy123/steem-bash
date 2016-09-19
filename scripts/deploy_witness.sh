#!/bin/bash
#
# Part of Someguy123's Steem Bash Tools
# Released under GNU GPL 3.0
# https://github.com/Someguy123/steem-bash


function deploy_witness() {
    echo "Installing steem-in-a-box with docker"
    install_docker
    install_steembox
    # PWD should now be steem-docker
    echo "Configuring witness"
    cd data/witness_node_data_dir
    # fire up a temporary CLI_WALLET for generating keys and things
    cli_start
    # we do an initial config here
    # so it's safe to assume we can add/remove anything we want
    config_unset p2p-endpoint miner mining-threads 
    config_set rpc-endpoint "0.0.0.0:8090"
    config_witness "${@}"
    echo "For easier configuration in the future, add the following to your .bashrc or .zshrc :"
    echo "export CONFIG_FILE=$PWD/config.ini"
    cd ../..
    # okay we're done, so clean up the cli_wallet
    cli_stop
    echo "Witness is ready. To start: ./run.sh start"
}

function config_witness() {
    if [[ $# -lt 1 ]]; then
        echo -n "Witness name: " 
        read WITNESSNAME
    else
        WITNESSNAME=$1
    fi
    if [[ $# -lt 2 ]]; then
        echo "No signing key specified, so generating keys"
        gen_key
        SIGNING_PRIVKEY=$PRIVKEY
    else
        SIGNING_PRIVKEY=$2
    fi
    config_set private-key $SIGNING_PRIVKEY
    config_set witness '"'$WITNESSNAME'"'
}
