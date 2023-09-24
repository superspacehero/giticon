#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

testVersionParam_B004() {
  error_num=0

#  actual="$("$commit_sh" --version)"
  actual="$("${PROJECT_ROOT}"/commit.sh --version)"
  exit_code=$?

  assertSame "Expected zero exit code" "$error_num" "$exit_code"
  assertContains "$actual" ".sh v"
}

# Load and run shUnit2.
. shunit2
