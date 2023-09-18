#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

# Utils
setUpOutputDirs(){
  original_pwd="${PWD}"
  OUTPUT_DIR="${SHUNIT_TMPDIR}/output"
  mkdir "${OUTPUT_DIR}"
  STDOUTF="${OUTPUT_DIR}/stdout"
  STDERRF="${OUTPUT_DIR}/stderr"
}

#assertCommandSuccess() {
#   set -e "$@" > "$STDOUTF" 2> "$STDERRF"
#  assertTrue "The command $1 did not return 0 exit status" $?
#}

setUp() {

  setUpOutputDirs

  temp_dir="$SHUNIT_TMPDIR/shellLocation_test"
  temp_commit_sh="${temp_dir}/commit.sh"

  mkdir "$temp_dir"
  cp "$commit_sh" "$temp_commit_sh"
  cd "$temp_dir" || exit 2
}

tearDown() {
  cd "$original_pwd" || cd ~ || exit 2
  rm -fr "${temp_dir}"
}

testRcNotFound() {
  actual="$("$temp_commit_sh" --version 2>&1)"

#  echo "actual = $actual"

  assertEquals 1002 "$("$temp_commit_sh" --version)" "$actual"
}

# Load and run shUnit2.
. shunit2