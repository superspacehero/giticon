#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

testTitleArg_D006() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  test_arg_1="test: do something"

  # First confirm parsing is working correctly
  run_init
  run_stage_A_1 "${test_arg_1}"
  run_stage_A_2
  run_stage_A_3

  # shellcheck disable=SC2154
  assertFalse "Should not be prompted" "$was_prompted"

  actual="$(run "${test_arg_1}")"
  expected="git commit -m \"$test_arg_1\""
  assertEquals "$expected" "$actual"
}

# Load and run shUnit2.
. shunit2
