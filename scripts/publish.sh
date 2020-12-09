#!/bin/sh

set -o errexit
set -o nounset

confirm() {
    local message="$1"
    shift

    local input
    while :
    do
        printf '%s ("y" or "n"): ' "$message"
        read input
        if echo "$input" | grep -Ei '^[[:space:]]*y[[:space:]]*$' >/dev/null
        then
            return 0
        elif echo "$input" | grep -Ei '^[[:space:]]*n[[:space:]]*$' >/dev/null
        then
            return 1
        else
            echo 'Invalid input; specify "y" or "n".' >&2
        fi
    done
}

review() {
    local article_path="$1"
    shift

    git add "$article_path"
    while :
    do
        git diff --staged
        if confirm "Do you want to commit that?"
        then
            break
        fi
    done
}

find_latest() {
    find content/posts -iname '*.md' \
        | sort -ru \
        | head -n 1
}

extract_title() {
    local path="$1"
    shift

    local script
    script=$(cat <<-'EOF'

        tolower($0) ~ /^ *title *= */ {
            sub( \
                /^ *[tT][iI][tT][lL][eE] *= *\"/, \
                "" \
            )
            sub(/\"$/, "")
            print $0
            exit
        }

EOF
    )

    awk "$script" "$path"
}

commit() {
    local path="$1"
    shift

    local title
    title="$(extract_title "$path")"

    git commit -m "Publish \"$title\""
}

publish() {
    git show HEAD
    if confirm 'Do you want to push that?'
    then
        git push
    else
        echo "When you're ready to publish, run 'git push'."
    fi
}

main() {
    local latest
    latest="$(find_latest)"

    review "$latest"
    commit "$latest"
    publish
}

main

