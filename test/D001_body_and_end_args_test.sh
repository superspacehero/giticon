#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

export test_only

testBodyAndEndArgs_D001() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1 "do something" "--" "id:5"

  # shellcheck disable=SC2154
  assertTrue "is_argument_1 is true" "$is_argument_1"
  # shellcheck disable=SC2154
  assertEquals "argument_1 equals \"do something\"" "$argument_1" "do something"
  # shellcheck disable=SC2154
  assertTrue "is_argument_2 is true" "$is_argument_2"
  # shellcheck disable=SC2154
  assertEquals "argument_2 equals \"\"" "$argument_2" ""
  # shellcheck disable=SC2154
  assertTrue "is_argument_3 is true" "$is_argument_3"
  # shellcheck disable=SC2154
  assertEquals "argument_3 equals \"id:5\"" "$argument_3" "id:5"
}

# Load and run shUnit2.
. shunit2
