#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

testTypeFlag_C001() {
  actual="$("$commit_sh" --type hotfix)"

  assertContains "$actual" "!"
}

# Load and run shUnit2.
. shunit2
