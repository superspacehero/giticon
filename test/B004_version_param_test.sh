#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

testVersionParam_B004() {
  actual="$("$commit_sh" --version)"

  assertContains "$actual" ".sh v"
}

# Load and run shUnit2.
. shunit2
