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

# Check for a .giticon.rc file
if [[ -f "$GIT_ROOT/.giticon.rc" ]]; then
    source "$GIT_ROOT/.giticon.rc"
fi

if [ -z "$COMMIT_CSV_FILE_PATH" ]; then
    COMMIT_CSV_FILE_PATH="$GIT_ROOT/giticontypes.csv"
fi

if [[ -f $COMMIT_CSV_FILE_PATH ]]; then
    while IFS=',' read -r key emoji description; do
        if [[ "$key" != "Type" ]]; then
            init_type "$key" "$emoji" "$description"
        fi
    done < "$COMMIT_CSV_FILE_PATH"
else
    # European Commission Standard with emojis added
    # echo "COMMIT_CSV_FILE_PATH not found, showing Standard Commit Types instead"
    echo
    init_type "feat" "✨" "A new feature"
    init_type "fix" "✔️" "A bug fix"
    init_type "docs" "📝" "Documentation only changes"
    init_type "style" "🌼" "Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)"
    init_type "refactor" "♻️" "A code change that neither fixes a bug nor adds a feature"
    init_type "perf" "🏃" "A code change that improves performance"
    init_type "test" "🦋" "Adding missing tests"
    init_type "chore" "🧺" "Changes to the build process or auxiliary tools and libraries such as documentation generation"
fi


help()
{
    echo -e "
USAGE: \e[33m\$ ${0##*/} [OPTIONS] [message] [body] [footer]\e[0m

ARGUMENTS
  [message]   Alternative to combined --type, --scope, and --message flags
              Use the format: <type>[(<scope>)][!]:<description>

                Where:
                  - <type> can be found in the .giticon.rc
                  - <scope> label is within parenthesis
                  - ! is used to indicate a breaking change
                  - : separates commit type from description
                  - <description> completes the sentence, \"Commit will...\"

  [body]      If necessary answer why change was made, or how commit
              addresses issue, or what effect commit has

  [footer]    Optional meta-data, like: breaking change, issue number, test results

OPTIONS
  -h, --help      Show command line options and table of commit types
  -m, --message   Passed through to 'git commit' with prepended type and scope
      --scope     Scope to prepend to message
      --type      Commit Type to prepend to message

GIT COMMIT OPTIONS

  Remaining flagged options are passed through to 'git commit', including:

  -a, --all       Commit all changed files
      --amend     Amend previous commit
      --dry-run   Show what would be committed

EXAMPLES
  \e[33m\$ ${0##*/}\e[0m

    Will prompt for commit type, amend option, and description

  \e[33m\$ ${0##*/} \"init: Add files to start project\"\e[0m

    Will make commit with message: \"🎉 init: Add files to start project\"

  \e[33m\$ ${0##*/} --amend init \"Add content to kick off project\"\e[0m

    Git will --amend the last commit with: \"🎉 init: Add content to kick off project\"
"
    exit 2
}


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
        echo -e "$index) ${emojis[$type]}\t$(printf '%-9s' "$type":) ${types[$type]}"
    done

    # shellcheck disable=SC2162
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