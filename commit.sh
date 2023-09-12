#!/bin/bash

declare -A types
declare -A emojis
declare -a order

init_type() {
    local key="$1"
    local emoji="$2"
    local description="$3"
    types["$key"]="$description"
    emojis["$key"]="$emoji"
    order+=("$key")
}

# Maybe one day I'll work out how to properly use these functions.
# For now, they're just here for reference.
# # Function to extract scope from input
# extract_scope() {
#     echo "$1" | grep -oP '\(\K[^)]+'
# }

# # Function to extract message from input
# extract_message() {
#     echo "$1" | grep -oP '"\K[^"]+'
# }

# Get the root directory of the git repository
GIT_ROOT=$(git rev-parse --show-toplevel)
DEFAULT_CSV_PATH="$GIT_ROOT/types.csv"

# Check for a .giticon.rc file
if [[ -f "$GIT_ROOT/.giticon.rc" ]]; then
    CSV_PATH=$(cat "$GIT_ROOT/.giticon.rc")
else
    CSV_PATH=$DEFAULT_CSV_PATH
fi

if [[ -f $CSV_PATH ]]; then
    while IFS=',' read -r key emoji description; do
        if [[ "$key" != "Type" ]]; then
            init_type "$key" "$emoji" "$description"
        fi
    done < $CSV_PATH
else
    init_type "access" "♿" "Improvement for accessibility"
    init_type "api" "❗" "API addition, deprecation, or deletion"
    init_type "asset" "📸" "Add or update assets"
    init_type "clean" "🗑️" "Delete, deprecate, prune, or otherwise remove files"
    init_type "ci" "👷" "CI config files and scripts"
    init_type "config" "🔧" "Change to build configs, scripts, or external dependencies"
    init_type "data" "🗃️" "Add or update a Dataset"
    init_type "doc" "📝" "Documentation changes including source comments"
    init_type "extern" "👽️" "Update due to external API or other changes"
    init_type "feat" "✨" "A new feature"
    init_type "fix" "✔️" "Fix a bug or get a test working"
    init_type "git" "🙈" "A change to the .gitignore / .gitkeep files, or other git changes"
    init_type "hotfix" "🚨" "Critical hotfix"
    init_type "i18n" "🌐" "Internationalization and localization"
    init_type "init" "🎉" "The first commit of a new project or feature"
    init_type "lint" "👕" "Lint or other warning clean up"
    init_type "log" "📋" "Changes that effect logs"
    init_type "memo" "🌼" "Internal memo, status report, or other such documents"
    init_type "metric" "📡" "Instrumentation or metrics"
    init_type "perf" "🏃" "Improve performance"
    init_type "refactor" "♻️" "Improve structure or format of code"
    init_type "revert" "⏪" "Reverts a previous commit"
    init_type "seo" "🎌" "SEO improvements, A/B tests, or other changes"
    init_type "test" "🦋" "Add test or fix test code"
    init_type "typo" "💄" "Fix typos, whitespace, or cosmetic change"
    init_type "ui" "🎨" "Improve user experience, usability, responsiveness"
    init_type "version" "🔖" "Simple marker to tag a version bump"
    init_type "wip" "⚗️" "Mark code as stable but still being worked on"
fi

# Initialize options and message variable
DRY_RUN=false
AMEND=false
MESSAGE=""
SCOPE=""

# Loop to process flags
while [[ "$1" ]]; do
    case "$1" in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -a|--amend)
            AMEND=true
            shift
            ;;
        -m|--message)
            shift
            MESSAGE="$1"
            shift
            ;;
        -s|--scope)
            shift
            SCOPE="$1"
            shift
            ;;
        *)
            # If the argument is not a known flag, break the loop
            break
            ;;
    esac
done

# Check for command line argument for direct type
if [[ $1 && ${emojis[$1]} ]]; then
    selected_type=$1
else
    echo "Select a commit type:"
    for i in "${!order[@]}"; do
        type=${order[$i]}
        index=$((i+1))
        echo "$index) ${emojis[$type]} $type: ${types[$type]}"
    done

    read -p "Enter number or type key: " selection
    if [[ $selection =~ ^[0-9]+$ ]]; then
        selected_type=${order[$((selection-1))]}
    elif [[ ${emojis[$selection]} ]]; then
        selected_type=$selection
    else
        echo "Invalid selection"
        exit 1
    fi
fi

# If the MESSAGE is empty, then it's likely the scope might be too.
# Only ask for them if they haven't been set via the command line.
if [[ -z "$MESSAGE" ]]; then
    # Only ask for scope if it hasn't been set by the -s flag.
    if [[ -z "$SCOPE" ]]; then
        read -p "Optional scope (e.g. Android): " scope_input
        SCOPE=${SCOPE:-$scope_input}
    fi

    read -p "This commit will...(e.g. Let swipe go all the way to bottom): " desc_input
    desc=${MESSAGE:-$desc_input}
else
    desc="$MESSAGE"
fi

# If dry run option is enabled, print the commit message without committing
if $DRY_RUN; then
    if [[ -n "$SCOPE" ]]; then
        echo "${emojis[$selected_type]} $selected_type($SCOPE): $desc"
    else
        echo "${emojis[$selected_type]} $selected_type: $desc"
    fi
else
    if $AMEND; then
        if [[ -n "$SCOPE" ]]; then
            git commit --amend -m "${emojis[$selected_type]} $selected_type($SCOPE): $desc"
        else
            git commit --amend -m "${emojis[$selected_type]} $selected_type: $desc"
        fi
    else
        if [[ -n "$SCOPE" ]]; then
            git commit -m "${emojis[$selected_type]} $selected_type($SCOPE): $desc"
        else
            git commit -m "${emojis[$selected_type]} $selected_type: $desc"
        fi
    fi
fi