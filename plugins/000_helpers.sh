#!/bin/bash


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
CONFIG_FILE="$PWD/config.ini"

function has_item() {
    grep -c "^$1" $CONFIG_FILE
}

function config_set() {
    echo "Setting $1 to $2 in file $CONFIG_FILE"
    echo $(has_item $1)
    if [[ $(has_item $1) -eq 0 ]]; then
        # config item not found. try to uncomment
        sed -i -e 's/^#[[:space:]]'"$1"'.*/'"$1"' = '"$2"'/' $CONFIG_FILE
        echo $(has_item $1)
        if [[ $(has_item $1) -eq 0 ]]; then
            echo "WARNING: $1 was not found as a comment. Appending to the end of the file"
            # is it still not here? fine. we'll add it to the ending
            echo "$1 = $2" >> $CONFIG_FILE
        fi
    else
        # already an entry, let's replace it
        sed -i -e "s/^$1.*/$1 = $2/" $CONFIG_FILE
    fi
}

function config_unset() {
    echo "Removing item $1 from $CONFIG_FILE"

    if [[ $(has_item $1) -eq 0 ]]; then
        sed -i -e 's/^'"$1"'.*/# \0/' $CONFIG_FILE
    fi
}

