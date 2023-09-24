#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

export test_only


#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)

temp_dir="$SHUNIT_TMPDIR/shellLocation_test"
temp_commit_sh="${temp_dir}/commit.sh"



testInvalidParams_B002() {
  actual="$("$temp_commit_sh" --version)"

#  echo "actual = $actual"
  show_slim_help

  assertEquals 1002 "$("$temp_commit_sh" --version)" "$actual"
}

# Load and run shUnit2.
. shunit2
