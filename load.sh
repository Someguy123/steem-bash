#!/bin/bash
for f in plugins/*.sh; do
    echo "Loading $f"
    source $f
done


for f in scripts/*.sh; do
    echo "Loading $f"
    source $f
done
