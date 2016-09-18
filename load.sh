#!/bin/bash
for f in plugins/*.sh; do
    echo "Loading $f"
    source $f
done
