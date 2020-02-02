#!/bin/sh

set -o errexit
set -o nounset

for script in output/theme/scripts/*
do
    python3 -m rjsmin <"$script" >"$script.min"
    mv "$script.min" "$script"
done

