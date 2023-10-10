#!/bin/sh
# shellcheck disable=SC2154

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

  temp_sq=$SQUEEZE_MESSAGE
  temp_em=$ADD_EMOJI
  SQUEEZE_MESSAGE="n"
  ADD_EMOJI="n"

  run_stage_A_1 "${test_arg_1}"
  run_stage_A_2
  run_stage_A_3

  assertFalse "Should not be prompted" "$was_prompted"

  run_stage_B
  run_stage_C

  actual="$git_commit_string"
  expected="git commit -m \"$test_arg_1\""

  SQUEEZE_MESSAGE=$temp_sq
  ADD_EMOJI=$temp_em
  unset temp_sq temp_em

  assertEquals "$expected" "$actual"
}

# Load and run shUnit2.
. shunit2
