#!/bin/sh

set -o errexit
set -o nounset

ai_name=ai-pathfinding-project
ai_uri="https://github.com/LouisJackman/$ai_name/releases/download/$AI_PATHFINDING_RELEASE/$ai_name.tgz"

conway_name=conways-game-of-life
conway_uri="https://github.com/LouisJackman/$conway_name/releases/download/$CONWAYS_GAME_OF_LIFE_RELEASE/$conway_name.tgz"

add() {
    local name="$1"
    shift
    local uri="$1"
    shift

    mkdir -p "output/theme/projects/$name"
    (
        cd "output/theme/projects/$name"
        curl -LOSfs "$uri"
        tar -xzf "$name.tgz"
        rm "$name.tgz"
    )
}

main() {
    local name
    local uri

    mkdir -p output/theme/projects
    for project in ai conway
    do
        eval "name=\$${project}_name"
        eval "uri=\$${project}_uri"
        add "$name" "$uri" &
    done
    wait
}

main

