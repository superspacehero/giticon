#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

export test_only

testTypeFlag_C001() {

  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1_2 "--type" "hotfix"

  assertTrue "is_flag_type is true" "$is_flag_type"
  assertContains "flag_type contains \"hotfix\"" "$flag_type" "hotfix"
}

# Load and run shUnit2.
. shunit2
