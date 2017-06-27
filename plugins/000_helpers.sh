#!/bin/bash
#
# Part of Someguy123's Steem Bash Tools
# Released under GNU GPL 3.0
# https://github.com/Someguy123/steem-bash

# let's avoid locale issues...

export LANGUAGE="en_GB.UTF-8"
export LANG="en_GB.UTF-8"
export LC_ALL="en_GB.UTF-8"
export LC_CTYPE="en_US.UTF-8"

#
# Extracts a string key from JSON via stdin
# $ echo '{"x": "y"}' | extract_json_str x
# would result in the letter y
function extract_json_str() {
    sed -r 's/.*'"$1"'\"\:[[:space:]]?\"([^\"]*?)\".*/\1/'
}

#
# Extracts an integer key from JSON via stdin
# $ echo '{"x": 1234}' | extract_json_int x
# would result in the number 1234
function extract_json_int() {
    sed -r 's/.*'"$1"'\"\:[[:space:]]?([0-9]+).*/\1/'
}

function extract_json_float() {
    sed -r 's/.*'"$1"'\"\:[[:space:]]?([0-9\.]+).*/\1/'
}
# WARNING CAN'T HANDLE NESTED OBJECTS
#
# $ echo '{"x": {"y": "p"}}' | extract_json_object x
# would result in {"y": "p"}
#
function extract_json_object() {
    sed -r 's/.*'"$1"'\"\:[[:space:]]?(\{[^}]*?\}).*/\1/'
}


#
# Steem Node Config
#
function get_config_location() {
    if ((${#CONFIG_FILE[@]})); then
        echo $CONFIG_FILE
    else
        echo "$PWD/config.ini"
    fi
}

function has_item() {
    grep -c "^$1" $(get_config_location)
}

function config_set() {
    echo "Setting $1 to $2 in file $(get_config_location)"
    if [[ $(has_item $1) -eq 0 ]]; then
        # config item not found. try to uncomment
        sed -i -e 's/^#[[:space:]]'"$1"'.*/'"$1"' = '"$2"'/' $(get_config_location)
        if [[ $(has_item $1) -eq 0 ]]; then
            echo "WARNING: $1 was not found as a comment. Prepending to the start of the file"
            # is it still not here? fine. we'll add it to the start
            prepend_config "$1 = $2"
        fi
    else
        # already an entry, let's replace it
        sed -i -e "s/^$1.*/$1 = $2/" $(get_config_location)
    fi
}

function add_seed() {
    prepend_config "seed-node = $1"
}

function config_unset() {
    for conitem in "$@"
    do
        echo "Removing item $conitem from $(get_config_location)"

        if [[ $(has_item $conitem) -eq 1 ]]; then
            sed -i -e 's/^'"$conitem"'.*/# \0/' $(get_config_location)
        fi
    done
}

function install_deps() {
    command -v python3 curl git pip3 > /dev/null
    if [[ $? -eq 1 ]]; then
        echo "Installing dependencies"
        # we're missing dependencies, let's install them
        sudo apt install -qy python3 python3-pip curl git
    fi
}

function install_docker() {
    install_deps
    # if we already have docker, we can skip it
    if [[ $(command -v docker) ]]; then
        return
    fi
    curl -sSL https://get.docker.com/ | sh
}

function install_conductor() {
    sudo apt install -qy python3-pip python3.5-dev libssl-dev
    pip3 install -U git+https://github.com/Netherdrake/conductor
    echo "ADD YOUR ACTIVE KEY"
    steempy addkey
    echo "INIT WITNESS"
    conductor init
}

function install_steembox() {
    install_deps
    if [[ -d "steem-docker" ]]; then
        echo "Steem-docker is in this directory! CD'ing in"
        cd steem-docker
        return
    fi
    if [[ $(pwd|grep "steem-docker") ]]; then
        echo "You're already inside steem-docker!"
        return
    fi
    git clone https://github.com/Someguy123/steem-docker
    cd steem-docker
    ./run.sh install
    return
}
function prepend_config() {
    prep=$(echo $1 && cat $(get_config_location)) 
    echo $prep > $(get_config_location)
}
