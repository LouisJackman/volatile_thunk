#!/bin/sh

set -o errexit
set -o nounset

input_line=

input() {
    local prompt=$1
    shift

    printf "%s" "$prompt: "
    read input_line
}

title_to_path_component() {
    echo "$1" \
        | tr '[A-Z]' '[a-z]' \
        | sed -E 's/[[:space:]]+/-/g' \
        | sed -E 's/[^[:alnum:]-]+//g'
}

get_new_hugo_content_path() {
    local title="$1"
    shift

    local title_path_component
    title_path_component=$(title_to_path_component "$title")

    local now
    now=$(date +'%Y/%m/%d')
    printf "%s" "posts/$now/$title_path_component/post"
}

insert_tags=$(cat <<-'EOF'

   (NR == 1) && /\+\+\+/ {
        in_header = 1
        print
        next
    }

    /\+\+\+/ {
        in_header = 0
    }

    in_header && (tolower($0) ~ /^ *title *= */) {
        print "title = \"" title "\""
        next
    }

    in_header && (tolower($0) ~ /^ *date *= */) {
        sub(/T.*$/, "")
        print $0 "\""
        next
    }

    in_header && (tolower($0) ~ /^ *tags *= */) {
        gsub(/,/, "\", \"", tags)
        print "tags = [\"" tags "\"]"
        next
    }

    1
 
EOF
)
readonly insert_tags

lookup_editor() {
    local editor
    if [ -n "$VISUAL" ]
    then
        editor=$VISUAL
    elif [ -n "$EDITOR" ]
    then
        editor=$EDITOR
    else
        editor=vi
    fi
    echo "$editor"
}

main() {
    input "The post's title"
    local title="$input_line"

    input "The post's tags (separate with commas)"
    local tags
    tags=$(
        echo "$input_line" \
            | tr '[A-Z]' '[a-z]'
    )

    local hugo_content_path
    hugo_content_path=$(get_new_hugo_content_path "$title")

    hugo new "$hugo_content_path".toml
    mv content/"$hugo_content_path".toml content/"$hugo_content_path".md

    awk \
        -v tags="$tags" \
        -v title="$title" \
        "$insert_tags" \
        content/"$hugo_content_path.md" \
        >content/"$hugo_content_path".md.bk

    mv content/"$hugo_content_path".md.bk content/"$hugo_content_path".md

    local editor
    editor=$(lookup_editor)

    "$editor" content/"$hugo_content_path".md
}

main

