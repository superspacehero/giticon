#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

testBodyAndEndArgs_C001() {
  actual="$("$commit_sh" --type hotfix -m \"Correct crashing issue#5218\" --breaking)"

  assertContains "$actual" "!"
}

# Load and run shUnit2.
. shunit2
