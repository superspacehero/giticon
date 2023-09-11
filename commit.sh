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
    while IFS='|' read -r key emoji description; do
        init_type "$key" "$emoji" "$description"
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

# Check for dry run option
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    shift
else
    DRY_RUN=false
fi

# Check for append to latest commit option
if [[ "$1" == "--amend" ]]; then
    AMEND=true
    shift
else
    AMEND=false
fi

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

read -p "Optional scope (e.g. Android): " scope
read -p "This commit will...(e.g. Let swipe go all the way to bottom): " desc

# If dry run option is enabled, print the commit message without committing
if $DRY_RUN; then
    if [[ -n "$scope" ]]; then
        echo "${emojis[$selected_type]} $selected_type($scope): $desc"
    else
        echo "${emojis[$selected_type]} $selected_type: $desc"
    fi
else
    if $AMEND; then
        if [[ -n "$scope" ]]; then
            git commit --amend -m "${emojis[$selected_type]} $selected_type($scope): $desc"
        else
            git commit --amend -m "${emojis[$selected_type]} $selected_type: $desc"
        fi
    else
        if [[ -n "$scope" ]]; then
            git commit -m "${emojis[$selected_type]} $selected_type($scope): $desc"
        else
            git commit -m "${emojis[$selected_type]} $selected_type: $desc"
        fi
    fi
fi
