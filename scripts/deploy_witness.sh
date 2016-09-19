#!/bin/bash

CONFIG_FILE="$HOME/steem-tools/steem-docker/data/witness_node_data_dir"

function deploy_witness() {
    echo "Installing steem-in-a-box with docker"
    install_docker
    install_steembox
    # PWD should now be steem-docker
    echo "Configuring witness"
    cd data/witness_node_data_dir
    # we do an initial config here
    # so it's safe to assume we can add/remove anything we want
    config_unset p2p-endpoint miner mining-threads 
    config_set rpc-endpoint "0.0.0.0:8090"
    config_witness "${@}"
    cd ../..
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
    config_set witness $WITNESSNAME
}
