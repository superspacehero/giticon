#!/bin/sh
PROJECT_ROOT=$(git rev-parse --show-toplevel)
commit_sh="${PROJECT_ROOT}/commit.sh"

testHelpParam_B001() {
  actual="$("$commit_sh" --help)"

  assertContains "$actual" "USAGE:"
}

testHParam_B001() {
  actual="$("$commit_sh" -h)"

  assertContains "$actual" "USAGE:"
}

# Load and run shUnit2.
. shunit2
