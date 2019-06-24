# Installs a seed node, with shared_memory.bin kept in the blockchain folder (on disk)
# Usage: deploy_seed_disk (shm_size: optional)
function deploy_seed_disk() {
    if [[ $# -lt 1 ]]; then
        SHMSIZE='64G'
    else
        SHMSIZE="$1"
    fi
    echo "Installing seed node with disk shm - steem-in-a-box with docker"
    deploy_base
    # PWD should now be steem-docker

    echo "Setting up config.ini"
    cd data/witness_node_data_dir

    # we do an initial config here
    # so it's safe to assume we can add/remove anything we want
    config_unset miner mining-threads
    config_set rpc-endpoint "0.0.0.0:8090"
    config_set shared-file-size "100G"
    # comment/remove shared-file-dir so it stores on disk instead of /dev/shm
    config_unset shared-file-dir

    cd "$SIAB_FOLDER"
    echo "Downloading blocks..."
    ./run.sh dlblocks

    echo "Steem node is ready. Running replay now."
    ./run.sh replay
}

# Installs a seed node with shared_memory.bin kept in /dev/shm
# Usage: deploy_seed (shm_size: optional)
function deploy_seed() {
    if [[ $# -lt 1 ]]; then
        SHMSIZE='64G'
    else
        SHMSIZE="$1"
    fi
    echo "Installing seed node with /dev/shm size $SHMSIZE - steem-in-a-box with docker"
    deploy_base
    # PWD should now be steem-docker

    echo "Setting up config.ini"
    cd data/witness_node_data_dir
    
    # we do an initial config here
    # so it's safe to assume we can add/remove anything we want
    config_unset miner mining-threads 
    config_set rpc-endpoint "0.0.0.0:8090"
    config_set shared-file-size "${SHMSIZE}G"

    cd "$SIAB_FOLDER"
    sudo ./run.sh shm_size "${SHMSIZE}G"
    echo "Downloading blocks..."
    ./run.sh dlblocks

    echo "Steem node is ready. Running replay now."
    ./run.sh replay
}