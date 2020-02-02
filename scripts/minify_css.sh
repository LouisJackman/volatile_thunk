#!/bin/sh

set -o errexit
set -o nounset

for css in output/theme/css/*.css
do
    python3 -m csscompressor -o "$css" "$css"
done

