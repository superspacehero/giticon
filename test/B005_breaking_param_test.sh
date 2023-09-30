#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

export test_only

testBreakingFlagB005() {

  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1 "--breaking"

  # shellcheck disable=SC2154
  assertTrue "is_flag_breaking is true" "$is_flag_breaking"
}

# Load and run shUnit2.
. shunit2
