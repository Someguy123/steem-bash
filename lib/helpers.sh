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


