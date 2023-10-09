#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

testTypeFlagAndTitleArg_F003() {
  # shellcheck disable=SC2034
  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  test_arg_1="Correct flag, title no working"

  # First confirm parsing is working correctly
  run_init
  run_stage_A_1 --type feat "${test_arg_1}"
  run_stage_A_2
  run_stage_A_3

  # shellcheck disable=SC2154
  assertFalse "Should not be prompted" "$was_prompted"

  temp_sq=$SQUEEZE_MESSAGE
  temp_em=$ADD_EMOJI
  SQUEEZE_MESSAGE="n"
  ADD_EMOJI="y"

  actual="$(run --type feat "${test_arg_1}")"
  expected="git commit -m \"✨ feat: $test_arg_1\""

  SQUEEZE_MESSAGE=$temp_sq
  ADD_EMOJI=$temp_em
  unset temp_sq temp_em

  assertEquals "$expected" "$actual"
}

# Load and run shUnit2.
. shunit2
