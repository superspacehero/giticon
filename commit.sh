#!/bin/sh

#
#   Help Functions
#

# ${0##*/} references Arg0 with just the file name

show_slim_help()
{
  # Parameter
  p_exit_code=${1:-"2"}

  # shellcheck disable=SC2039
  echo "
USAGE: \e[33m\$ ${0##*/} [-h|--help] [-j|--show-types] [OPTIONS] [ARGUMENTS]\e[0m

TRY
  \e[33m\$ ${0##*/}\e[0m      With no arguments, for interactive prompts
  \e[33m\$ ${0##*/} -h\e[0m   For usage help
  \e[33m\$ ${0##*/} -j\e[0m   For the Table of Commit Types
"

  # Help should go to stderr
  exit "$p_exit_code"
}

show_help()
{
    # shellcheck disable=SC2039
    echo "
USAGE: \e[33m\$ ${0##*/} [OPTIONS] [message] [body] [footer]\e[0m

ARGUMENTS
  [message]        Alternative to combined --type, --scope, and --message flags
                   Use the format: <type>[(<scope>)][!]:<description>

                     Where:
                       - <type> can be found in the .giticon.rc
                       - <scope> label is within parenthesis
                       - ! is used to indicate a breaking change
                       - : separates commit type from description
                       - <description> completes the sentence, \"Commit will...\"

  [body]           If necessary answer why change was made, or how commit
                   addresses issue, or what effect commit has

  [footer]         Optional meta-data, like: breaking change, issue number, test results

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
    exit 2
}

show_version()
{
  # shellcheck disable=SC2039
  echo "\e[33m\$ ${0##*/} v${VERSION}\e[0m"
}


#
#   Environment Settings
#

VERSION="0.0.1"
RC_FILE_NAME=".giticon.rc"

ERROR_RC_NOT_FOUND=102

# Attempt to get the project root directory using git
git_output=$(git rev-parse --show-toplevel 2>/dev/null)

# Set the project root to either the project or PWD
if [ -n "$git_output" ]; then
  PROJECT_ROOT="$git_output"
else
  PROJECT_ROOT="$PWD"
fi

rc_file_path="$PROJECT_ROOT/$RC_FILE_NAME"

# Check for a .giticon.rc file
if [ -f "$rc_file_path" ]; then
  # Load environment settings from the rc file
  # shellcheck source=$PROJECT_ROOT/.giticon.rc
  . "$rc_file_path"
else
  # Show an error and exit
  echo "\e[31m\$ $RC_FILE_NAME not found in project root \e[0m"
  show_slim_help $ERROR_RC_NOT_FOUND
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
if [ -z "$PROMPT_FOR_OPTION" ]; then PROMPT_FOR_OPTION="N"; fi
if [ -z "$PROMPT_FOR_BREAKING" ]; then PROMPT_FOR_BREAKING="N"; fi
if [ -z "$PROMPT_FOR_BODY" ]; then PROMPT_FOR_BODY="N"; fi
if [ -z "$PROMPT_FOR_END" ]; then PROMPT_FOR_END="N"; fi
if [ -z "$SQUEEZE_MESSAGE" ]; then SQUEEZE_MESSAGE="N"; fi
if [ -z "$INVALID_FLAG_ACTION" ]; then INVALID_FLAG_ACTION="warn"; fi
if [ -z "$TERMINATE_ON_WARNING" ]; then TERMINATE_ON_WARNING="Y"; fi

ADD_EMOJI=$(echo $ADD_EMOJI | tr '[:upper:]' '[:lower:]')
PROMPT_FOR_OPTION=$(echo $PROMPT_FOR_OPTION | tr '[:upper:]' '[:lower:]')
PROMPT_FOR_BREAKING=$(echo $PROMPT_FOR_BREAKING | tr '[:upper:]' '[:lower:]')
PROMPT_FOR_BODY=$(echo $PROMPT_FOR_BODY | tr '[:upper:]' '[:lower:]')
PROMPT_FOR_END=$(echo $PROMPT_FOR_END | tr '[:upper:]' '[:lower:]')
SQUEEZE_MESSAGE=$(echo $SQUEEZE_MESSAGE | tr '[:upper:]' '[:lower:]')
INVALID_FLAG_ACTION=$(echo $INVALID_FLAG_ACTION | tr '[:upper:]' '[:lower:]')
TERMINATE_ON_WARNING=$(echo $TERMINATE_ON_WARNING | tr '[:upper:]' '[:lower:]')


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

set_active_row_from_number() {
  # Parameter
  p_wanted_row_number="$1"

  if [ "$p_wanted_row_number" -le "$row_count" ]; then
    active_row_number="$p_wanted_row_number"
  else
    active_row_number=1
  fi

  unset p_wanted_row_number
}

# set_active_row_from_type() will set:
#   active_row_from_type equal to found row number, or
#   zero if not found
set_active_row_from_type() {
  # Parameter
  p_commit_type_name="$1"

  # Trim an trailing colon
  p_commit_type_name="${p_commit_type_name%"${p_commit_type_name##*[! :]}"}"

  i=1
  while [ "$i" -le "$row_count" ]
  do
    set_variables_from_row "$i"

    if [ "$commit_type" = "$p_commit_type_name" ]; then
      set_active_row_from_number "$i"
      break
    fi

    i=$((i + 1))
  done

  if [ "$active_row_number" -lt "0" ] || [ "$i" -gt "$row_count" ]; then
    active_row_number=0
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

set_backup_csv() {
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

set_formatted_commit_row()
{
  # Parameters
  p_row_number="$1"
  p_show_index="$2"

  formatted_commit_row=""

  # Set the Commit row variables; use header is needed
  if [ "$p_row_number" -gt "0" ]; then
    set_active_row_from_number "$p_row_number"
    set_variables_from_row "$active_row_number"

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
                  printf "%" c1 "s%-" c2 "s%-" c3 "s\t%s\n", $1, $2, $3, $4
                  #       1       2        3          4
              }
          '
      )
    else
      formatted_commit_row=$(
          echo "$padded_index,$commit_type,$commit_desc" |
          awk -F, -v c1="$width_of_index" -v c2="$width_of_type" '
              {
                  printf "%" c1 "s%-" c2 "s\t%s\n", $1, $2, $3
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
                  printf "%-" c2 "s%-" c3 "s\t%s\n", $2, $3, $4
                  #       2        3          4
              }
          '
      )
    else
      formatted_commit_row=$(
          echo "$padded_index,$commit_type,$commit_desc" |
          awk -F, -v c2="$width_of_type" '
              {
                  printf "%-" c2 "s\t%s\n", $2, $3
                  #       2          3
              }
          '
      )
    fi
  fi

  unset p_row_number
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
  if [ "$active_row_number" -eq "0" ]; then
    show_help
  fi

  set_new_title "$p_title"

  if [ -z "$new_message" ] && [ -z "$p_end" ] && [ -z "$p_body" ]; then
    git_commit_message=""
  elif [ -z "$p_end" ] && [ -z "$p_body" ]; then
    git_commit_message=$(printf "%s" "$new_message")
  elif [ -z "$p_end" ]; then
    git_commit_message=$(printf "%s\n%s" "$new_message" "$p_body")
  else
    git_commit_message=$(printf "%s\n%s\n%s" "$new_message" "$p_body" "$p_end")
  fi

  unset p_title p_body p_end new_message
}

# set_init_variables() will set:
#   active_table
#   active_row_number
#   row_count
#   width_of_index
#   width_of_type
#   width_of_icon
#
set_init_variables() {
  if test -n "${width_of_type-}"; then
    # Don't init again
    return 0
  fi

  # active_table
  set_backup_csv
  set_active_table "$COMMIT_CSV_FILE" "$backup_csv"

  # row_count
  set_row_count

  # width_of_index
  set_string_length "$row_count"
  width_of_index="$string_length"

  # width_of_type
  set_max_width_of_type
  width_of_type=$max_width_of_type

  # width_of_icon
  width_of_icon=1

  # active_row_number
  active_row_number=1
}

set_max_width_of_type() {
  max_width_of_type=4

  temp_num="$active_row_number"

  # Process each line
  i=1
  while [ "$i" -le "$row_count" ]
  do
    set_variables_from_row "$i"

    set_string_length "$commit_type"

    if [ "$string_length" -gt "$max_width_of_type" ]; then
        max_width_of_type="$string_length"
    fi

    i=$((i + 1))
  done
  active_row_number="$temp_num"

  unset temp_num
}

set_new_title() {
  # Parameter
  p_title="$1"

  regex_icon="\([^${commit_icon}]*\)\(${commit_icon}\)\(.*\)"
  regex_type="\([^a-z]*\)\(${commit_type}\):\?\(.*\)"

  if [ "$ADD_EMOJI" = "y" ]; then
    icon_capture=$(echo "$p_title" | sed -n "s/$regex_icon/\2/p")
    type_capture=$(echo "$p_title" | sed -n "s/$regex_type/\2/p")

    if [ -z "$type_capture" ] && [ -z "$icon_capture" ]; then
      new_message="$commit_icon $commit_type: $p_title"
    elif [ -z "$icon_capture" ]; then
      new_message="$commit_icon $p_title"
    else
      new_message="$p_title"
    fi
  else
    type_capture=$(echo "$p_title" | sed -n "s/$regex_type/\2/p")

    if [ -z "$type_capture" ]; then
      new_message="$commit_type: $p_title"
    else
      new_message="$p_title"
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

# set_variables_from_row() will set:
#   commit_desc
#   commit_icon
#   commit_index
#   commit_type
#
set_variables_from_row()
{
  # Parameter
  p_wanted_row_number="$1"

  commit_row=$(echo "$active_table" | sed -n "$p_wanted_row_number"p)

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


#
#   Show Functions
#

show_table_of_commits() {
  # Show the header first
  set_formatted_commit_row -1
  echo "$formatted_commit_row"
  set_formatted_commit_row 0
  echo "$formatted_commit_row"

  temp_num="$active_row_number"

  i=1
  while [ "$i" -le "$row_count" ]
  do
    set_formatted_commit_row "$i"
    echo "$formatted_commit_row"
    i=$((i + 1))
  done
  active_row_number="$temp_num"

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

  temp_num="$active_row_number"

  i=1
  while [ "$i" -le "$row_count" ]
  do
    set_formatted_commit_row "$i" "$p_show_index"
    echo "$formatted_commit_row"
    i=$((i + 1))
  done
  active_row_number="$temp_num"

  if [ "$ADD_EMOJI" != "y" ] && [ "$p_show_index" != "y" ]; then
    echo "  *ADD_EMOJI not turned on"
  fi

  unset p_show_index temp_num
}


#
#   Parse or Prompt Command line
#

#
# If script is called with no arguments or options,
# then the following variables will be set:
#
#   prompt_commit_type
#   prompt_scope
#   prompt_breaking
#   prompt_title
#   prompt_body
#   prompt_end
#
# The following options and arguments will be set:
#
#   flag_commit_type
#   flag_scope
#   flag_breaking
#
#   arg_title
#   arg_body
#   arg_end
#
#   git_commit_params
#
# The prompts and flags will be preprocessed to:
#
#   options_icon
#   options_commit_type
#   options_scope
#   options_delimiter
#
# After further processing, four variables will used
# to call the `git commit` with the git_commit_params
# passed through:
#
#   message_title
#   message_body
#   message_end
#   git_commit_params
#



# parse_args() will set:
#   flag_help         (true/false)
#   flag_breaking     (true/false)
#   flag_show_types   (true/false)
#   flag_version      (true/false)
#   message_delimiter String
#   message_title     String
#   message_body      String
#   message_end       String
#   git_commit_params String
#
#   Flags: help, show_types, version, will
#   short-circuit and not continue parsing
#   command line.
#
parse_args() {
  # Initialize variables
  flag_help=false
  flag_breaking=false
  flag_show_types=false
  flag_version=false
  message_delimiter=":"
  message_title=""
  message_body=""
  message_end=""
  git_commit_params=""

  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help)
        flag_help=true
        shift
        return 0
        ;;
      -j|--show-types)
        flag_show_types=true
        shift
        return 0
        ;;
      --version)
        flag_version=true
        shift
        return 0
        ;;
      --breaking)
        flag_breaking=true
        shift
        ;;
      -m|--message)
        flag_message=true
        shift
        ;;
      --scope)
        flag_scope=true
        shift
        ;;
      --type)
        flag_type=true
        shift
        ;;
      --)
        shift
        echo "-- $1"
        break
        ;;
      *)
        break
        ;;
    esac
  done

#   flag_message    String
#   flag_scope      String
#   flag_type       String

}

prompt_for_breaking() {
  # shellcheck disable=SC2039
  printf "Is this a breaking change [y/N]:"
  read -r word
  case $word in
    [Yy]* )
      if [ "$SQUEEZE_MESSAGE" = "y" ]; then
        message_delimiter="!"
      else
        message_delimiter="!:"
      fi
      ;;
    * )
      message_delimiter=":"
  esac
}

prompt_for_message() {
  echo
  # shellcheck disable=SC2039
  printf "Finish the sentence, \"This commit will ..."
  read -r desc_input
  echo

  message_title="$desc_input"
}

prompt_for_scope() {
  echo
  # shellcheck disable=SC2039
  printf "Optional scope (e.g. Android): "
  read -r scope_input
  echo

  message_scope="$scope_input"
  case "$scope_input" in
    (*\(*\)*)
      echo "The string is surrounded by parentheses."
      ;;
    *)
      echo "The string is not surrounded by parentheses."
      ;;
  esac
}

prompt_for_type() {
  show_commits
  echo
  # shellcheck disable=SC2039
  printf "Row number or Commit Type: "
  read -r selection
  echo

  if [ "$selection" -eq "$selection" ] 2>/dev/null; then
    if [ "$selection" -gt 0 ] && [ "$selection" -le "$row_count" ]; then
      set_formatted_commit_row "$selection"
      return 0
    fi
  fi

  set_active_row_from_type "$selection"

  if [ "$active_row_number" -le 0 ]; then
    echo "Invalid selection"
    exit 1
  fi

  set_formatted_commit_row "$active_row_number"

  unset selection
}

prompt_for_args() {
  prompt_for_type
  if [ "$PROMPT_FOR_OPTION" = "y" ]; then prompt_for_scope; fi
  if [ "$PROMPT_FOR_BREAKING" = "y" ]; then prompt_for_breaking; fi
  prompt_for_message
}


#
# >>> Run <<<
# -----------
#

# First set the init variables
set_init_variables

if [ "$#" -eq 0 ]; then
  prompt_for_args
else
  parse_args ${1+"$@"}

  if [ $flag_help = true ]; then
    show_help
  fi

  if [ $flag_version = true ]; then
    show_version
    exit 0
  fi

  if [ "$flag_show_types" = true ]; then
    show_table_of_commits
    exit 0
  fi
fi

set_git_commit_message "$message_title" "$message_body" "$message_end"

echo "grit commit" "${git_commit_params}" -m "${git_commit_message}"
#git commit --dry-run "${git_commit_params}" -m "${git_commit_message}"

# >>> End of Script <<<

# show_slim_help


echo " icon: $options_icon"
echo " type: $options_commit_type"
echo "scope: $options_scope"
echo "  del: $options_delimiter"
echo " desc: $message_title"
echo " body: $message_body"
echo "  end: $message_end"
echo "  git: $git_commit_params"
