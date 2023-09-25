#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

testTitleArg_C006() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1_2 "do something"

  # shellcheck disable=SC2154
  assertTrue "is_argument_1 is true" "$is_argument_1"
  # shellcheck disable=SC2154
  assertEquals "argument_1 equals \"do something\"" "$argument_1" "do something"

}

# Load and run shUnit2.
. shunit2
