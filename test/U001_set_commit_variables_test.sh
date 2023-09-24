#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

testNo_global_table_row_number_U001() {

  test_only=true

  . $commit_sh

  unset table_row_number

  # Call with no params
  result=$(set_commit_variables)

  assertContains "$result" "$result" "type"
}

testNo_global_active_table_U001() {

  test_only=true

  . $commit_sh

  unset active_table p_wanted_row_number

  result=$(set_commit_variables)

  assertContains "$result" "$result" "error"
}

testBad_param_U001() {

  test_only=true

  . $commit_sh

  # Call with bad param
  result=$(set_commit_variables "333")

  assertContains "$result" "$result" "error"
}

testFind_row_1_U001() {

  test_only=true

  . $commit_sh

  echo "active_table: $active_table"

  # Call with bad param
  result=$(set_commit_variables "1")

  assertContains "$result" "$result" "error"
}


# Load and run shUnit2.
. shunit2
