#!/bin/sh
# shellcheck disable=SC2034
# Remove shellcheck when coding

#########
#
# This script is a convenient way to output a
# `git commit` with a Type and optional emoji
# prepended to the message, for example: 
#
#   `git commit -m "🏃 perf: Switch to Hmap"
#
# Using Commit Types helps to monitor project
# work in a convenient way and an emoji makes
# scanning a list of commits easier. 
#
# Included in this package (default names):
#    1. script                    (commit.sh)
#    2. resource configurations   (.giticon.rc)
#    3. commit types              (commit_types.csv)
#
#########

VERSION="0.0.1"
RC_FILE_NAME=".giticon.rc"

#
#   Help Functions
#

show_brief_help()
{
  # Parameter
  p_exit_code=${1:-"2"}

  # ${0##*/} is Arg0 with just the file name

  # shellcheck disable=SC2039
  echo "
USAGE: \e[33m\$ ${0##*/} [-h|--help] [-j|--show-types] [OPTIONS] [ARGUMENTS]\e[0m

TRY
  \e[33m\$ ${0##*/}\e[0m      With no arguments, for interactive prompts
  \e[33m\$ ${0##*/} -h\e[0m   For the full usage help
  \e[33m\$ ${0##*/} -j\e[0m   For the Table of Commit Types
"

  # Help should go to stderr
  exit "$p_exit_code"
}

show_help()
{
  # Parameter
  p_exit_code=${1:-"2"}

  # ${0##*/} is Arg0 with just the file name

  # shellcheck disable=SC2039
  echo "
USAGE: \e[33m\$ ${0##*/} [OPTIONS] [title] [body] [end]\e[0m

ARGUMENTS
  [title]          Alternative to combined --type, --scope, and --message flags

                   Use the format: <type>[(<scope>)][!|:]<description>

                     Where:
                       - <type> can be found in the .giticon.rc
                       - <scope> label is within parenthesis
                       - ! is used to indicate a breaking change
                       - : is used to separate commit type from description when no scope
                       - <description> completes the sentence, \"Commit will...\"

  [body]           If necessary, answer why change was made, or how commit
                   addresses issue, or what effect commit has

  [end]            Optional meta-data, like: breaking change, issue number, test results

OPTIONS
  -h, --help       Show command line options and table of commit types
  -j, --show-types Show the Table of Commit Types

      --breaking   Include the breaking exclamation in the message title
  -m, --message    Passed through to 'git commit' with prepended type and scope
      --scope      Scope to prepend to message title
      --type       Commit Type to prepend to message title

      --version    Show the version

GIT COMMIT OPTIONS

  Remaining flagged options are passed through to 'git commit', including:

  -a, --all       Commit all changed files
      --amend     Amend previous commit
      --dry-run   Show what would be committed

EXAMPLES
  \e[33m\$ ${0##*/}\e[0m

    Will prompt for commit type, amend option, and description

  \e[33m\$ ${0##*/} \"init: Add files to start project\"\e[0m

    Will make commit with message, \"🎉 init: Add files to start project\"

  \e[33m\$ ${0##*/} --amend init \"Add content to kick off project\"\e[0m

    Git will --amend the last commit with, \"🎉 init: Add content to kick off project\"
"

  # Help should go to stderr
  exit "$p_exit_code"
}

show_version()
{
  # shellcheck disable=SC2039
  echo "\e[33m\$ ${0##*/} v${VERSION}\e[0m"
}


#################################
#
# Stage A: Parsing
# -----------------
#
# There are three sources of input data:
#    1. flags
#    2. arguments (Message title, body, and end)
#    3. prompts
#
# Of course the option flags and arguments come from the
# command line but here we think of them as different 
# because in our design they represent two different 
# styles of entering data, for example:
#
#     $ commit "typo: Correct misspelling"
#  versus
#     $ commit -type typo -m "Correct misspelling"
#
# The third source, "prompts", arise when the data on the
# command line is not sufficient to complete the commit
# message.
#
# Some flags short-circuit the processing and immediately
# display the information and exit, such as the help flag.
#
# The message flag and the message argument cannot be used
# at the same time.
#
# The following variables will be initialized to an empty 
# string (""), unless otherwise noted.
#
# (1) Flags
#
# From the command line the following options and
# arguments can be passed:
#
#   flag_message
#   flag_type
#   flag_scope
#   is_flag_breaking
#
#   is_flag_help (short-circuits)
#   is_flag_show_types (short-circuits)
#   is_flag_version (short-circuits)
#
#   git_commit_params
#
# (2) Message Arguments
#
#   arg_type
#   arg_scope
#   arg_delimiter
#   arg_title
#   arg_body
#   arg_end
#
# (3) Prompts
#
# If script is called with no given message, then the user
# will be prompted and the following variables may be set:
#
#   was_prompted
#   prompt_type
#   prompt_icon
#   prompt_scope
#   prompt_breaking
#   prompt_title
#   prompt_body
#   prompt_end
#
#
# Stage B: Preprocess
# -------------------
#
# At this stage we validate and coerce the earlier
# prompts and flags into:
#
#   options_icon
#   options_type
#   options_scope
#   options_delimiter
#
# And then we will derive four variables:
#
#   message_title
#   message_body
#   message_end
#   git_commit_params
#
#
# Stage C: Git Commit String
# --------------------------
#
# To wrap up, a single `git commit` with parameters
# will be generated:
#
#   git_commit_string
#
#################################


#
#   Initialization Variables
#

init_error_numbers() {
  ERROR_RC_NOT_FOUND=102
  ERROR_MULTIPLE_MESSAGES=103
  ERROR_BAD_PARAMS=104
}

init_available_options() {
  git_options="-- -a --all --ahead-behind --amend --author --branch -c --reedit-message
  -C --reuse-message --cleanup --date --dry-run -e --edit -F --file --fixup -h --help
  -i --include --interactive --long -m --message -n --no-verify --no-post-rewrite
  -o --only -p --patch --pathspec-from-file --pathspec-file-nul --porcelain -q --quiet
  --reset-author -s --signoff -S --gpg-sign --short --squash --status -t --template
  --trailer -u --untracked-files -v --verbose -z --null"

  our_options="-h --help -j --breaking --version -m --message --scope --type"
}

# init_environment() will set:
#   ADD_EMOJI
#   COMMIT_CSV_FILE
#   INVALID_FLAG_ACTION
#   PROJECT_ROOT
#   PROMPT_FOR_SCOPE
#   PROMPT_FOR_BREAKING
#   PROMPT_FOR_BODY
#   PROMPT_FOR_END
#   RC_FILE_NAME
#   SQUEEZE_MESSAGE
#   TERMINATE_ON_WARNING
#   EXECUTE_COMMIT
#   VERSION
#
init_environment() {
  if [ -z "$VERSION" ]; then VERSION="giticon-shell"; fi
  if [ -z "$RC_FILE_NAME" ]; then RC_FILE_NAME=".giticon.rc"; fi

  # Attempt to get the project root directory using git
  git_output=$(git rev-parse --show-toplevel 2>/dev/null)

  # For the rc file, favor the current directory so the project rc can be overridden
  if [ -f "$PWD/$RC_FILE_NAME" ]; then
    rc_file_path="$PWD/$RC_FILE_NAME"
    PROJECT_ROOT="$PWD"
    # shellcheck disable=SC1090
    . "$rc_file_path"
  elif [ -f "$git_output/$RC_FILE_NAME" ]; then
    rc_file_path="$git_output/$RC_FILE_NAME"
    PROJECT_ROOT="$git_output"
    # shellcheck disable=SC1090
    . "$rc_file_path"
  else
    # Show an error and exit
    echo "\e[31m\$ $RC_FILE_NAME not found in project root, $PROJECT_ROOT\e[0m"
    show_brief_help $ERROR_RC_NOT_FOUND
  fi

  # Set the file path for the csv file if it is missing
  if [ -z "$COMMIT_CSV_FILE" ]; then
    COMMIT_CSV_FILE="${PROJECT_ROOT}/commit_types.csv"
  fi

  # Check for a relative path
  if [ "${COMMIT_CSV_FILE#./}" != "$COMMIT_CSV_FILE" ] ||
     [ "$(basename "$COMMIT_CSV_FILE")" = "$COMMIT_CSV_FILE" ]; then
    # Make it absolute by placing in project root directory
    COMMIT_CSV_FILE="${PROJECT_ROOT}/$COMMIT_CSV_FILE"
  fi

  if [ -z "$ADD_EMOJI" ]; then ADD_EMOJI="Y"; fi
  if [ -z "$PROMPT_FOR_SCOPE" ]; then PROMPT_FOR_SCOPE="N"; fi
  if [ -z "$PROMPT_FOR_BREAKING" ]; then PROMPT_FOR_BREAKING="N"; fi
  if [ -z "$PROMPT_FOR_BODY" ]; then PROMPT_FOR_BODY="N"; fi
  if [ -z "$PROMPT_FOR_END" ]; then PROMPT_FOR_END="N"; fi
  if [ -z "$SQUEEZE_MESSAGE" ]; then SQUEEZE_MESSAGE="N"; fi
  if [ -z "$INVALID_FLAG_ACTION" ]; then INVALID_FLAG_ACTION="warn"; fi
  if [ -z "$TERMINATE_ON_WARNING" ]; then TERMINATE_ON_WARNING="Y"; fi
  if [ -z "$EXECUTE_COMMIT" ]; then EXECUTE_COMMIT="Y"; fi

  ADD_EMOJI=$(echo $ADD_EMOJI | tr '[:upper:]' '[:lower:]')
  PROMPT_FOR_SCOPE=$(echo $PROMPT_FOR_SCOPE | tr '[:upper:]' '[:lower:]')
  PROMPT_FOR_BREAKING=$(echo $PROMPT_FOR_BREAKING | tr '[:upper:]' '[:lower:]')
  PROMPT_FOR_BODY=$(echo $PROMPT_FOR_BODY | tr '[:upper:]' '[:lower:]')
  PROMPT_FOR_END=$(echo $PROMPT_FOR_END | tr '[:upper:]' '[:lower:]')
  SQUEEZE_MESSAGE=$(echo $SQUEEZE_MESSAGE | tr '[:upper:]' '[:lower:]')
  INVALID_FLAG_ACTION=$(echo $INVALID_FLAG_ACTION | tr '[:upper:]' '[:lower:]')
  TERMINATE_ON_WARNING=$(echo $TERMINATE_ON_WARNING | tr '[:upper:]' '[:lower:]')
  EXECUTE_COMMIT=$(echo $EXECUTE_COMMIT | tr '[:upper:]' '[:lower:]')
}

init_instruction_data() {
  was_prompted=false
  prompt_type=""
  prompt_icon=""
  prompt_scope=""
  prompt_breaking=""
  prompt_title=""
  prompt_body=""
  prompt_end=""
  flag_message=""
  flag_type=""
  flag_scope=""
  is_flag_breaking=false
  is_flag_help=false
  is_flag_show_types=false
  is_flag_version=false
  git_commit_params=""
  arg_type=""
  arg_scope=""
  arg_delimiter=""
  arg_title=""
  arg_body=""
  arg_end=""
  options_icon=""
  options_type=""
  options_scope=""
  options_delimiter=""
  message_title=""
  message_body=""
  message_end=""
  git_commit_string=""
}

# init_working_variables() will set:
#   active_table
#   table_row_number
#   row_count
#   width_of_index
#   width_of_type
#   width_of_icon
#
init_working_variables() {

  # active_table
  set_table_backup_csv
  set_active_table "$COMMIT_CSV_FILE" "$backup_csv"

  # row_count
  set_row_count

  # width_of_index
  set_string_length "$row_count"
  width_of_index="$string_length"

  # width_of_type
  set_type_string_max_width
  width_of_type=$type_string_max_width

  # width_of_icon
  width_of_icon=1

  # table_row_number
  table_row_number=1
}


#
#   Set Variable Functions
#   (in alphabetical order)
#

    # This is a POSIX-compliant shell script.
    # As such, the functions "set" variables
    # rather than return a value.
    #
    # The functions are named "set_" and then
    # the name of the variable.
    #
    # Parameters that are required are specified at
    # the top of the function.

# set_commit_variables() will set:
#   commit_desc
#   commit_icon
#   commit_index
#   commit_type
#
set_commit_variables() {
  # Parameter
  p_wanted_row_number="${1:-$table_row_number}"

  commit_index=""
  commit_icon=""
  commit_desc=""
  commit_type=""

  if [ -z "$active_table" ] || [ -z "$p_wanted_row_number" ]; then
    echo "error 409"
    exit 2
  fi

  commit_row=$(echo "$active_table" | sed -n "$p_wanted_row_number"p)

  if [ -z "$commit_row" ]; then
    echo "error 416"
    exit 2
  fi

  reg_index="\([0-9]*\)"
  reg_type="\(\w*\)"
  reg_icon="\([^,]*\)"
  reg_desc="\"\(.*\)\""
  regex="\s*$reg_index,\s*$reg_type,\s*$reg_icon,\s*$reg_desc"

#  commit_all=$(echo "$p_commit_row" | sed -n "s/$regex/1:\1 2:\2 3:\3 4:\4/p")
  commit_index=$(echo "$commit_row" | sed -n "s/$regex/\1/p")
  commit_icon=$(echo "$commit_row" | sed -n "s/$regex/\3/p")
  commit_desc=$(echo "$commit_row" | sed -n "s/$regex/\4/p")
  commit_type=$(echo "$commit_row" | sed -n "s/$regex/\2/p")

  unset commit_row p_wanted_row_number
}


set_table_row_number() {
  # Parameter
  p_wanted_row_number="$1"

  if [ "$p_wanted_row_number" -le "$row_count" ]; then
    table_row_number="$p_wanted_row_number"
  else
    table_row_number=1
  fi

  unset p_wanted_row_number
}

# set_table_row_number_from_type() will set:
#   active_row_from_type equal to found row number, or
#   zero if not found
set_table_row_number_from_type() {
  # Parameter
  p_commit_type_name="$1"

  # Trim a trailing colon
  p_commit_type_name="${p_commit_type_name%"${p_commit_type_name##*[! :]}"}"

  i=1
  while [ "$i" -le "$row_count" ]
  do
    set_commit_variables "$i"

    if [ "$commit_type" = "$p_commit_type_name" ]; then
      set_table_row_number "$i"
      break
    fi

    i=$((i + 1))
  done

  if [ "$table_row_number" -lt "0" ] || [ "$i" -gt "$row_count" ]; then
    table_row_number=0
  fi

  unset p_commit_type_name temp_num
}

set_active_table() {
  # Parameters
  p_csv_file="$1"
  p_backup_data="$2"

  # Check if the file exists
  if [ -f "$p_csv_file" ]; then
    # Read CSV data from the file
    active_table=$(cat "$p_csv_file")
  else
    # CSV data (backup)
    active_table="${p_backup_data}"
  fi

  # Keep all but the first line if it is the header
  active_table=$(echo "$active_table" | grep -v -i ICON)

  # Add line numbers
  active_table=$(printf "%s" "$active_table" | nl -s',')

  unset p_csv_file p_backup_data
}

set_table_backup_csv() {
  backup_csv="Type,Icon,Description
feat,✨,\"A new feature\"
fix,✔️,\"A bug fix\"
docs,📝,\"Documentation only changes\"
style,🌼,\"Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)\"
refactor,♻️,\"A code change that neither fixes a bug nor adds a feature\"
perf,🏃,\"A code change that improves performance\"
test,🦋,\"Adding missing tests\"
chore,🧺,\"Changes to the build process or auxiliary tools and libraries such as documentation generation\""
}

set_formatted_commit_row() {
  # Parameters
  p_row_number="$1"
  p_show_index="$2"

  formatted_commit_row=""

  # Set the Commit row variables; use header is needed
  if [ "$p_row_number" -gt "0" ]; then
    set_table_row_number "$p_row_number"
    set_commit_variables "$table_row_number"

    # Add parenthesis to surround the index
    padded_index=$(printf "%$((width_of_index+2))s\t" "$(printf "(%d)" "$commit_index")")
  elif [ "$p_row_number" -eq "0" ]; then
    commit_index=" "
    padded_index=$(printf "%$((width_of_index+2))s\t" " ")
    commit_type="----"
    commit_icon="----"
    commit_desc="-----------"
  elif [ "$p_row_number" -lt "0" ]; then
    commit_index=" "
    padded_index=$(printf "%$((width_of_index+2))s\t" " ")
    commit_type="Type"
    commit_icon="Icon"
    commit_desc="Description"
  fi

  # Format the row variables
  if [ "$p_show_index" = "y" ]; then
    if [ "$ADD_EMOJI" = "y" ]; then
      formatted_commit_row=$(
          echo "$padded_index,$commit_type,$commit_icon,$commit_desc" |
          awk -F, -v c1="$width_of_index" -v c2="$width_of_type" -v c3="$width_of_icon" '
              {
                # Description may have commas so combine them  
                desc = $4
                for (i=5; i<=NF; i++) desc = desc "," $i
                
                printf "%" c1 "s%-" c2 "s%-" c3 "s\t%s\n", $1, $2, $3, desc
                #       1       2        3          desc
              }
          '
      )
    else
      formatted_commit_row=$(
          echo "$padded_index,$commit_type,$commit_desc" |
          awk -F, -v c1="$width_of_index" -v c2="$width_of_type" '
              {
                # Description may have commas so combine them  
                desc = $3
                for (i=5; i<=NF; i++) desc = desc "," $i

                printf "%" c1 "s%-" c2 "s\t%s\n", $1, $2, desc
                #       1       2          3
              }
          '
      )
    fi
  else
    if [ "$ADD_EMOJI" = "y" ]; then
      formatted_commit_row=$(
          echo "$padded_index,$commit_type,$commit_icon,$commit_desc" |
          awk -F, -v c2="$width_of_type" -v c3="$width_of_icon" '
              {
                # Description may have commas so combine them  
                desc = $4
                for (i=5; i<=NF; i++) desc = desc "," $i
                
                printf "%-" c2 "s%-" c3 "s\t%s\n", $2, $3, desc
                #       2        3          desc
              }
          '
      )
    else
      formatted_commit_row=$(
          echo "$padded_index,$commit_type,$commit_desc" |
          awk -F, -v c2="$width_of_type" '
              {
                # Description may have commas so combine them  
                desc = $3
                for (i=5; i<=NF; i++) desc = desc "," $i
                
                printf "%-" c2 "s\t%s\n", $2, desc
                #       2          desc
              }
          '
      )
    fi
  fi

  unset p_row_number # don't unset p_show_index
}

# shellcheck disable=SC2120
set_git_commit_message() {
  # Parameters
  p_title="$1"
  p_body="$2"
  p_end="$3"

  if [ -n "$p_end" ] && [ -z "$p_body" ]; then
    # Set to -- to keep consistent with placeholder syntax of API
    p_body="--"
  fi

  git_commit_message=""

  # If the active row is not set we can't modify the message
  if [ "$table_row_number" -eq "0" ]; then
    show_help
  fi

  set_message_title_with_type "$p_title"

  if [ -z "$message_title_with_type" ] && [ -z "$p_end" ] && [ -z "$p_body" ]; then
    git_commit_message=""
  elif [ -z "$p_end" ] && [ -z "$p_body" ]; then
    git_commit_message=$(printf "%s" "$message_title_with_type")
  elif [ -z "$p_end" ]; then
    git_commit_message=$(printf "%s\n%s" "$message_title_with_type" "$p_body")
  else
    git_commit_message=$(printf "%s\n%s\n%s" "$message_title_with_type" "$p_body" "$p_end")
  fi

  unset p_title p_body p_end message_title_with_type
}

set_type_string_max_width() {
  type_string_max_width=4

  temp_num="$table_row_number"

  # Process each line
  i=1
  while [ "$i" -le "$row_count" ]
  do
    set_commit_variables "$i"

    set_string_length "$commit_type"

    if [ "$string_length" -gt "$type_string_max_width" ]; then
        type_string_max_width="$string_length"
    fi

    i=$((i + 1))
  done
  table_row_number="$temp_num"

  unset temp_num
}

set_message_title_with_type() {
  # Parameter
  p_title="$1"

  regex_icon="\([^${commit_icon}]*\)\(${commit_icon}\)\(.*\)"
  regex_type="\([^a-z]*\)\(${commit_type}\):\?\(.*\)"

  if [ "$ADD_EMOJI" = "y" ]; then
    icon_capture=$(echo "$p_title" | sed -n "s/$regex_icon/\2/p")
    type_capture=$(echo "$p_title" | sed -n "s/$regex_type/\2/p")

    if [ -z "$type_capture" ] && [ -z "$icon_capture" ]; then
      message_title_with_type="$commit_icon $commit_type: $p_title"
    elif [ -z "$icon_capture" ]; then
      message_title_with_type="$commit_icon $p_title"
    else
      message_title_with_type="$p_title"
    fi
  else
    type_capture=$(echo "$p_title" | sed -n "s/$regex_type/\2/p")

    if [ -z "$type_capture" ]; then
      message_title_with_type="$commit_type: $p_title"
    else
      message_title_with_type="$p_title"
    fi
  fi

  unset p_title
}

set_row_count() {
  row_count=$(($(printf "%s" "$active_table" | tr -cd '.\n' | wc -l) + 1))
}

set_string_length() {
  # Parameter
  p_string="$1"

  string_length=$(printf "%s" "$p_string" | wc -c)

  unset p_string
}


#
#   Show Functions
#

show_table_of_commits() {
  # Show the header first
  set_formatted_commit_row -1
  echo "$formatted_commit_row"
  set_formatted_commit_row 0
  echo "$formatted_commit_row"

  temp_num="$table_row_number"

  i=1
  while [ "$i" -le "$row_count" ]
  do
    set_formatted_commit_row "$i"
    echo "$formatted_commit_row"
    i=$((i + 1))
  done
  table_row_number="$temp_num"

  unset temp_num
}

# shellcheck disable=SC2120
show_commits() {

  # Parameters
  p_show_index=${1:-"y"}

  # Show the header first
  set_formatted_commit_row -1 "$p_show_index"
  echo "$formatted_commit_row"
  set_formatted_commit_row 0 "$p_show_index"
  echo "$formatted_commit_row"

  temp_num="$table_row_number"

  i=1
  while [ "$i" -le "$row_count" ]
  do
    set_formatted_commit_row "$i" "$p_show_index"
    echo "$formatted_commit_row"
    i=$((i + 1))
  done
  table_row_number="$temp_num"

  if [ "$ADD_EMOJI" != "y" ] && [ "$p_show_index" != "y" ]; then
    echo "  *ADD_EMOJI not turned on"
  fi

  unset p_show_index temp_num
}


#
# Stage A: Parsing
# -----------------
#

is_flag() {
  # Parameters
  p_parameter=${1:-""}

  if [ "${p_parameter#-}" != "$p_parameter" ] || [ "${p_parameter#--}" != "$p_parameter" ]; then
    unset p_parameter
    return 0
  else
    unset p_parameter
    return 1
  fi
}

is_flag_and_param() {
  # Parameters
  p_param1=${1:-""}
  p_param2=${2:-""}

  if [ "${p_param1#-}" != "$p_param1" ] && [ "${p_param1#--}" = "$p_param1" ] && \
     [ "${p_param2#-}" = "$p_param2" ] && [ "${p_param2#--}" = "$p_param2" ]; then
    unset p_param1 p_param2
    return 0
  else
    unset p_param1 p_param2
    return 1
  fi
}

is_git_option() {
  # Parameters
  p_parameter=${1:-"fff"}

  for item in $git_options; do
    if [ "$item" = "$p_parameter" ]; then
      found=$item
      break
    fi
  done

  # If any target item is found, break out of the loop
  if [ -n "$found" ]; then
    unset p_parameter found
    return 0
  else
    unset p_parameter found

    return 1
  fi
}

#
# (1) Flags
#   and
# (2) Message Arguments
#

parse_command_line() {
  # Initialize variables
  is_flag_help=false
  is_flag_breaking=false
  is_flag_show_types=false
  is_flag_version=false
  is_flag_message=false
  flag_message=""
  is_flag_scope=false
  flag_scope=""
  is_flag_type=false
  flag_type=""
  is_argument_1=false
  argument_1=""
  is_argument_2=false
  argument_2=""
  is_argument_3=false
  argument_3=""
  git_commit_params=
  bad_commit_params=

  set -- "$@"

  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help)
        is_flag_help=true
        shift
        return 0
        ;;
      -j|--show-types)
        is_flag_show_types=true
        shift
        return 0
        ;;
      --version)
        is_flag_version=true
        shift
        return 0
        ;;
      --breaking)
        is_flag_breaking=true
        shift
        ;;
      -m|--message)
        if ! $is_flag_message; then
          is_flag_message=true
          shift
          if ! is_flag "$1"; then
            flag_message=$1
            shift
          fi
        else
          # Pass it to git
          git_commit_params="$git_commit_params -m"
          shift
          if ! is_flag "$1"; then
            git_commit_params="$git_commit_params $1"
            shift
          fi
        fi
        ;;
      --scope)
        if ! $is_flag_scope; then
          is_flag_scope=true
          shift
          if ! is_flag "$1"; then
            flag_scope=$1
            shift
          fi
        else
          # Pass it to bad
          bad_commit_params="$bad_commit_params --scope"
          shift
          if ! is_flag "$1"; then
            bad_commit_params="$bad_commit_params $1"
            shift
          fi
        fi
        ;;
      --type)
        if ! $is_flag_type; then
          is_flag_type=true
          shift
          if ! is_flag "$1"; then
            flag_type=$1
            shift
          fi
        else
          # Pass it to bad
          bad_commit_params="$bad_commit_params --type"
          shift
          if ! is_flag "$1"; then
            bad_commit_params="$bad_commit_params $1"
            shift
          fi
        fi
        ;;
      --)
        if [ -z "$git_commit_params" ]; then
          if $is_argument_1 && $is_argument_2; then
            git_commit_params="git_commit_params --"
          elif $is_argument_1; then
            is_argument_2=true
          else
            is_argument_1=true
          fi
        else
          git_commit_params="$git_commit_params --"
        fi
        shift
        ;;
      *)
        if is_git_option "$1"; then
          git_commit_params="$git_commit_params $1"

          if is_flag_and_param "$1" "$2"; then
            shift
            git_commit_params="$git_commit_params $1"
          fi
        elif ! is_flag "$1"; then
          if ! $is_argument_1; then
            is_argument_1=true
            argument_1=$1
          elif ! $is_argument_2; then
            is_argument_2=true
            argument_2=$1
          elif ! $is_argument_3; then
            is_argument_3=true
            argument_3=$1
          else
            bad_commit_params="$bad_commit_params $1"
          fi
        else
          bad_commit_params="$bad_commit_params $1"
        fi
        shift
        ;;
    esac
  done

  # Resolve conflicting command line parameters
  if $is_flag_message && [ -n "$argument_1" ]; then
    # Show an error and exit
    echo "\e[31m\$ Conflicting title: $argument_1 and -m $flag_message \e[0m"
    show_brief_help $ERROR_MULTIPLE_MESSAGES
  fi

  # Resolve conflicting command line parameters
  if [ -n "$bad_commit_params" ]; then
    # Show an error and exit
    echo "\e[31m\$ Invalid param: $bad_commit_params \e[0m"
    show_help $ERROR_BAD_PARAMS
  fi
}

check_for_stop_early() {

  if $is_flag_help; then
    show_help
    exit 2  # Help will have already exited, but just in case
  fi

  if $is_flag_version; then
    show_version
    exit 0
  fi

  if $is_flag_show_types; then
    show_table_of_commits
    exit 0
  fi
}

distill_arg_1() {
  arg_1="$1"

  arg_icon=""
  arg_type=""
  arg_scope=""
  arg_delimiter=""
  arg_title=""

  # icon, use \x28 instead of \(
  reg_icon="\([^A-Za-z0-9 !:\\x28]*\) *\(.*\)"
  regex=$reg_icon

  whole=$arg_1

  first=$(echo "$whole" | sed "s/$regex/\1/;t;d")
  middle=$(echo "$whole" | sed "s/$regex/\2/;t;d")
  end=""

  if [ -n "$first" ]; then
    arg_icon=$first
    whole=$middle
  fi

  # delimiter
  reg_delimiter='\([^:!]*\) *\(:\|!\) *\(.*\)'
  regex=$reg_delimiter

  if [ -n "$(echo "$whole" | sed "s/^$regex$/\1\2\3/;t;d")" ]; then
    first=$(echo "$whole" | sed "s/^$regex$/\1/;t;d")
    middle=$(echo "$whole" | sed "s/$regex/\2/;t;d")
    end=$(echo "$whole" | sed "s/$regex/\3/;t;d")

    if [ -n "$middle" ]; then
      arg_delimiter=$middle
      arg_title=$end
      whole=$first
    fi
  fi

  # scope, use \x28 \x29 instead of \( \)
  reg_scope="\([^ \\x28]*\) *\\x28\(.*\)\\x29 *\(.*\)"
  regex=$reg_scope

  if [ -n "$(echo "$whole" | sed "s/^$regex$/\1\2\3/;t;d")" ]; then
    first=$(echo "$whole" | sed "s/^$regex$/\1/;t;d")
    middle=$(echo "$whole" | sed "s/^$regex$/\2/;t;d")
    end=$(echo "$whole" | sed "s/^$regex$/\3/;t;d")

    if [ -n "$middle" ]; then
      arg_scope=$middle
    fi

    if [ -z "$end" ] && [ -n "$arg_title" ]; then
      arg_type="${first%"${first##*[![:blank:]]}"}"
    elif [ -z "$end" ]; then
      whole=$first
    else
      arg_type="${first%"${first##*[![:blank:]]}"}"
      arg_title=$end
    fi
  else

    # type
    reg_type="\([[:alnum:]]\+\) *"
    regex=$reg_type

    if [ -n "$(echo "$whole" | sed "s/^$regex$/\1/;t;d")" ]; then
      first=$(echo "$whole" | sed "s/^$regex$/\1/;t;d")

      if [ -n "$first" ]; then
        arg_type=$first
      fi
    else

      reg_type=" *\(.\+\) *"
      regex=$reg_type

      if [ -n "$(echo "$whole" | sed "s/^$regex$/\1/;t;d")" ]; then
        first=$(echo "$whole" | sed "s/^$regex$/\1/;t;d")

        if [ -n "$first" ]; then
          arg_title=$first
        fi
      fi
    fi
  fi

  if [ -n "$arg_title" ] && [ -z "$arg_type" ] && [ -z "$arg_scope" ] && [ -z "$arg_delimiter" ]; then
    if [ -n "${arg_title##* *}" ]; then
      set_table_row_number_from_type "$arg_title"

      if [ "$table_row_number" -ge 1 ]; then
        arg_type=$arg_title
        arg_title=""
      fi
    fi
  fi
}

# distill_message_args will set:
#
#   arg_title
#   arg_icon
#   arg_type
#   arg_scope
#   arg_type
#   arg_delimiter
#   arg_body
#   arg_end
#
distill_message_args() {

  if [ -n "$argument_1" ]; then
    distill_arg_1 "$argument_1"
  fi

  if [ -n "$argument_2" ]; then
    arg_body=$argument_2
  fi

  if [ -n "$argument_3" ]; then
    arg_end=$argument_3
  fi
}


#
# (3) Prompts
#

prompt_for_breaking() {
  # shellcheck disable=SC2039
  printf "Is this a breaking change [y/N]:"
  read -r word
  case $word in
    [Yy]* )
      prompt_breaking="!"
      ;;
    * )
      prompt_breaking=""
  esac
}

prompt_for_title() {
  echo
  # shellcheck disable=SC2039
  printf "Finish the sentence: This commit will... "
  read -r desc_input
  echo

  prompt_title="$desc_input"
}

prompt_for_scope() {
  echo
  # shellcheck disable=SC2039
  printf "Optional scope (e.g. Android): "
  read -r scope_input
  echo

  prompt_scope="$scope_input"
  case "$scope_input" in
    (*\(*\)*)
      # The string is surrounded by parentheses
      prompt_scope=$(echo "$scope_input" | sed -n 's/\x28 *\(.*\) *\x29/\1/p')
      ;;
    *)
      prompt_scope="$scope_input"
      ;;
  esac
}

prompt_for_type() {
  is_valid_type=false

  while ! $is_valid_type; do

    show_commits
    echo
    # shellcheck disable=SC2039
    printf "Row number or Commit Type: "
    read -r selection

    # Check for 'q'
    if [ "$selection" = "q" ]; then exit 0; fi

    # Check if we have an integer in range
    if [ "$selection" -eq "$selection" ] 2>/dev/null; then
      if [ "$selection" -gt 0 ] && [ "$selection" -le "$row_count" ]; then
        set_commit_variables "$selection"
        is_valid_type=true
        break
      fi
    fi

    set_table_row_number_from_type "$selection"

    if [ "$table_row_number" -le 0 ]; then
      echo "Invalid selection, try again..."
      continue
    fi

    set_commit_variables "$table_row_number"
    is_valid_type=true
  done

  prompt_type="$commit_type"
  prompt_icon="$commit_icon"

  unset selection
}

prompt_for_missing_data() {

  is_prompt_for_type=false
  is_prompt_for_scope=false
  is_prompt_for_breaking=false
  is_prompt_for_title=false
  is_prompt_for_body=false
  is_prompt_for_end=false

  if [ -z "$flag_type" ] && [ -z "$arg_type" ]; then is_prompt_for_type=true; fi

  if [ "$PROMPT_FOR_SCOPE" = "y" ]; then
    if [ -z "$flag_scope" ] && [ -z "$arg_scope" ]; then is_prompt_for_scope=true; fi
  fi

  if [ "$PROMPT_FOR_BREAKING" = "y" ]; then
    if ! $is_flag_breaking && [ -z "$arg_delimiter" ]; then is_prompt_for_breaking=true; fi
  fi

  if [ -z "$flag_message" ] && [ -z "$arg_title" ]; then is_prompt_for_title=true; fi

  if [ "$PROMPT_FOR_BODY" = "y" ]; then
    # Current no $flag_body
    if [ -z "$arg_body" ]; then is_prompt_for_body=true; fi
  fi

  if [ "$PROMPT_FOR_END" = "y" ]; then
    # Current no $flag_end
    if [ -z "$arg_end" ]; then is_prompt_for_end=true; fi
  fi

  # Only prompt if we don't have redirected input
  if [ -t 0 ]; then
    if $is_prompt_for_type; then prompt_for_type; fi
    if $is_prompt_for_scope; then prompt_for_scope; fi
    if $is_prompt_for_breaking; then prompt_for_breaking; fi
    if $is_prompt_for_title; then prompt_for_title; fi
#    if $is_prompt_for_body; then true; fi  # TODO: Add body prompt
#    if $is_prompt_for_end; then true; fi  # TODO: Add end prompt

    if $is_prompt_for_type || $is_prompt_for_scope || \
       $is_prompt_for_breaking || $is_prompt_for_title || \
       $is_prompt_for_body || $is_prompt_for_end; then
      was_prompted=true
    fi
  fi
}


#
# Stage B: Preprocess
# -------------------
#

# consolidate_parsed_data() will set:
#   options_icon
#   options_type
#   options_scope
#   options_delimiter
#   message_title
#   message_body
#   message_end
#   git_commit_params
#
consolidate_parsed_data() {

  # Stage A should provide:
  #   flag_message
  #   flag_type
  #   flag_scope
  #   is_flag_breaking
  #   git_commit_params
  #
  #   arg_icon
  #   arg_type
  #   arg_scope
  #   arg_delimiter
  #   arg_title
  #   arg_body
  #   arg_end

  # options_icon
  if [ -n "$prompt_icon" ]; then
    options_icon="$prompt_icon"
  elif [ -n "$arg_icon" ]; then
    options_icon="$arg_icon"
  else
    options_icon=""
  fi

  # options_type
  if [ -n "$prompt_type" ]; then
    options_type="$prompt_type"
  elif [ -n "$arg_type" ]; then
    options_type="$arg_type"
  elif [ -n "$flag_type" ]; then
    options_type="$flag_type"
  else
    options_type=""
  fi

  # options_scope
  if [ -n "$prompt_scope" ]; then
    options_scope="$prompt_scope"
  elif [ -n "$arg_scope" ]; then
    options_scope="$arg_scope"
  elif [ -n "$flag_scope" ]; then
    options_scope="$flag_scope"
  else
    options_scope=""
  fi

  # options_delimiter
  if [ -n "$prompt_breaking" ]; then
    options_delimiter="$prompt_breaking"
  elif [ -n "$arg_delimiter" ]; then
    options_delimiter="$arg_delimiter"
  elif $is_flag_breaking; then
    options_delimiter="!"
  else
    options_delimiter=""
  fi

  # message_title
  if [ -n "$prompt_title" ]; then
    message_title="$prompt_title"
  elif [ -n "$arg_title" ]; then
    message_title="$arg_title"
  elif [ -n "$flag_message" ]; then
    message_title="$flag_message"
  else
    message_title=""
  fi

  # message_body
  if [ -n "$prompt_body" ]; then
    message_body="$prompt_body"
  elif [ -n "$arg_title" ]; then
    message_body="$arg_body"
  else
    message_body=""
  fi

  # message_end
  if [ -n "$prompt_end" ]; then
    message_end="$prompt_end"
  elif [ -n "$arg_end" ]; then
    message_end="$arg_end"
  else
    message_end=""
  fi

  # Now set the delimiter if it needed
  if [ -z "$options_delimiter" ]; then
    if [ -n "$options_type" ] && [ -z "$options_scope" ] && [ -n "$message_title" ]; then
      options_delimiter=":"
    fi
  fi

  # Set the icon if we have a type and ADD_EMOJI is wanted
  if [ -z "$options_icon" ]; then
    if [ -n "$options_type" ] && [ "$ADD_EMOJI" = "y" ]; then
      set_table_row_number_from_type "$options_type"

      if [ "$table_row_number" -gt 0 ]; then
        set_commit_variables "$table_row_number"
        options_icon="$commit_icon"
      fi
    fi
  fi

  # git_commit_params already set
}


#
# Stage C: Git Commit String
# --------------------------
#
set_git_commit_string() {

  # Stage B should provide the following variables:
  #   options_icon
  #   options_type
  #   options_scope
  #   options_delimiter
  #   message_title
  #   message_body
  #   message_end
  #   git_commit_params

  if [ "$SQUEEZE_MESSAGE" = "y" ]; then sp=""; else sp=" "; fi

  outstr=""

  if [ -n "$options_delimiter" ]; then outstr="$options_delimiter"; else outstr=""; fi
  if [ -n "$message_title" ] && [ -n "$options_delimiter" ]; then outstr="$outstr$sp"; fi
  if [ -n "$message_title" ]; then outstr="$outstr$message_title"; fi
  if [ -n "$options_scope" ] && [ -z "$options_delimiter" ] && [ -n "$message_title" ]; then outstr="$sp$outstr"; fi
  if [ -n "$options_scope" ]; then outstr="($options_scope)$outstr"; fi
  if [ -n "$options_type" ] && [ -n "$options_scope" ]; then outstr="$sp$outstr"; fi
  if [ -n "$options_type" ]; then outstr="$options_type$outstr"; fi
  if [ -n "$options_icon" ]; then outstr="$options_icon$sp$outstr"; fi

  message=""
  if [ -n "$outstr" ]; then message="-m \"$outstr\""; fi

  git_commit_string=""

  if [ -n "$git_commit_params" ] || [ -n "$message" ]; then git_commit_string="git commit"; fi
  if [ -n "$git_commit_params" ]; then git_commit_string="$git_commit_string$git_commit_params"; fi
  if [ -n "$message" ]; then git_commit_string="$git_commit_string $message"; fi
}


#
# Run Functions
# -------------
#
if [ "$ready_test" ]; then
  set_test_id() {
    # TESTING_ID will come from the test fixture
    test_id=$TESTING_ID
  }
fi

run_init() {
  # First set the environment and init variables
  init_error_numbers
  init_environment
  init_instruction_data
  init_available_options
  init_working_variables
}

run_stage_A_1() {
  parse_command_line ${1+"$@"}
  check_for_stop_early
}

run_stage_A_2() {
  distill_message_args
}

run_stage_A_3() {
  prompt_for_missing_data
}

run_stage_B() {
  consolidate_parsed_data
}

run_stage_C() {
  # Stage C: Git Commit String
  set_git_commit_string
}

run() {
  run_init
  run_stage_A_1 ${1+"$@"}
  run_stage_A_2
  run_stage_A_3
  run_stage_B
  run_stage_C

  # shellcheck disable=SC2154
  if [ -z "$test_only" ]; then

    if $was_prompted; then
      echo
      echo "     $git_commit_string"
      echo
      # This is Posix so echo the char and wait for the enter key
      read -r char
      echo

      # just in case they want to exit and don't know to press ctrl-C
      if [ "$char" = "\x1B" ] || [ "$char" = "q" ] || [ "$char" = "n" ]; then
        exit 0
      fi
    elif [ "$EXECUTE_COMMIT" = "n" ]; then
      echo "$git_commit_string"
    fi
  else
    echo "$git_commit_string"
  fi
}

# >>>>>*<<<<<

# shellcheck disable=SC2154
if [ -z "$test_only" ]; then
  # This is prevented from running during tests

  run ${1+"$@"}

  if [ "$EXECUTE_COMMIT" = "y" ]; then
    eval "$git_commit_string"
  fi
fi

# >>> End of Script <<<
