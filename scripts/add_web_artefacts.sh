#!/bin/sh

set -o errexit
set -o nounset

ai_name=ai-pathfinding-project
ai_uri="https://gitlab.com/louis.jackman/$ai_name/uploads/83029f4f9dc13a865165f9ebf86cbb6b/$ai_name.tgz"

conway_name=conways-game-of-life
conway_uri="https://gitlab.com/louis.jackman/$conway_name/uploads/f4b5829775380f7cb8bcc1053feb45f5/$conway_name.tgz"

add() {
    local name="$1"
    shift
    local uri="$1"
    shift

    mkdir -p "$OUTPUT_DIR/projects/$name"
    (
        cd "$OUTPUT_DIR/projects/$name"
        curl -LOSfs "$uri"
        tar -xzf "$name.tgz"
        rm "$name.tgz"
    )
}

main() {
    local name
    local uri

    mkdir -p "$OUTPUT_DIR/projects"
    for project in ai conway
    do
        eval "name=\$${project}_name"
        eval "uri=\$${project}_uri"
        add "$name" "$uri" &
    done
    wait
}

main

