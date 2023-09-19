#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

testBreakingParam() {
  actual="$("$commit_sh" --breaking)"

  assertContains "$actual" "!"
}

# Load and run shUnit2.
. shunit2