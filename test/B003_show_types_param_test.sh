#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

testShowCommitParam_B003() {
  actual="$("$commit_sh" --show-types)"

  assertContains "$actual" "Icon"
}

testJParam_B003() {
  actual="$("$commit_sh" -j)"

  assertContains "$actual" "Icon"
}

# Load and run shUnit2.
. shunit2
