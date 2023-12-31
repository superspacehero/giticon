#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

export test_only

testNo_global_table_row_number_U001() {

  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1

  unset table_row_number

  # Call with no params
  result=$(set_commit_variables)

  assertContains "$result" "$result" "error"
}

testNo_global_active_table_U001() {

  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1

  unset active_table p_wanted_row_number

  result=$(set_commit_variables)

  assertContains "$result" "$result" "error"
}

testBad_param_U001() {

  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1

  # Call with bad param
  result=$(set_commit_variables "333")

  assertContains "$result" "$result" "error"
}

testFind_row_1_U001() {

  test_only=true

  # shellcheck source=${PROJECT_ROOT}/commit.sh
  . "$commit_sh"

  run_init
  run_stage_A_1

  set_commit_variables "1"

   # shellcheck disable=SC2154
  assertTrue "commit variables are set, $commit_index, $commit_icon, $commit_type" \
    "[ -n $commit_index ] && [ -n $commit_type ]"
  assertSame "commit_index is 1" "1" "$commit_index"
}

# Load and run shUnit2.
. shunit2
