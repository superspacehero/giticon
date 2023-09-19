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

  # Capture the exit code
  "${temp_dir}"/commit.sh
  exit_code=$?

  # Check if the exit code is as expected (102 in this case)
  assertSame "Expected exit code 102" 102 "$exit_code"
}

# Load and run shUnit2.
. shunit2