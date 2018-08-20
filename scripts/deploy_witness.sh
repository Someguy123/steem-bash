#!/bin/bash
#
# Part of Someguy123's Steem Bash Tools
# Released under GNU GPL 3.0
# https://github.com/Someguy123/steem-bash


function deploy_witness() {
    echo -n "How big do you want SHM? (e.g. enter 16 for 16gb): "
    read SHMSIZE
    echo "SHM SIZE is $SHMSIZE"
    echo "Installing steem-in-a-box with docker"
    install_ntp
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
    config_set shared-file-size "$SHMSIZE"G
    config_witness "${@}"
    echo "For easier configuration in the future, add the following to your .bashrc or .zshrc :"
    echo "export CONFIG_FILE=$PWD/config.ini"
    echo "DOCKER_NAME=witness" >> .env
    echo "PORTS=" >> .env
    cd ../..
    sudo ./run.sh shm_size "$SHMSIZE"G
    # okay we're done, so clean up the cli_wallet
    cli_stop
    echo "Downloading blocks..."
    ./run.sh dlblocks
    echo "Installing @furion's conductor"
    export UNLOCK=""
    echo "export UNLOCK=\"\"" >> $HOME/.profile
    install_conductor
    echo "Witness is ready. To start: ./run.sh replay"
    echo "Your config info:"
    echo "  User: $WITNESSNAME"
    echo "  Public Signing Key: $PUBKEY"
    echo "  Private Signing Key: $PRIVKEY"
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
