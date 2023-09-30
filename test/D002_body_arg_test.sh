#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

export test_only

testBodyArg_D002() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1 "--" "why we did it"

  # shellcheck disable=SC2154
  assertTrue "is_argument_1 is true" "$is_argument_1"
  # shellcheck disable=SC2154
  assertEquals "argument_1 equals \"\"" "" "$argument_1"
  # shellcheck disable=SC2154
  assertTrue "is_argument_2 is true" "$is_argument_2"
  # shellcheck disable=SC2154
  assertEquals "argument_2 equals \"\"" "why we did it" "$argument_2"
  # shellcheck disable=SC2154
  assertFalse "is_argument_3 is false" "$is_argument_3"
}

# Load and run shUnit2.
. shunit2
